;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: AST Lowering Engine

(in-package #:lys.lowering)

(defstruct lowered-ir
  "Encapsulates an intermediate lowered representation consumable by CPython."
  (ir-type :source-str :type symbol)
  (ir-payload "" :type string))

(defun lowered-ir-payload (ir)
  (lowered-ir-ir-payload ir))

(defun lowered-ir-type (ir)
  (lowered-ir-ir-type ir))

(defun lower-canonical-ast (node &optional (indent 0))
  "Lower CANONICAL-NODE into an executable Python representation."
  (let ((payload (%lower-to-python-string node indent)))
    (make-lowered-ir :ir-type :source-str :ir-payload payload)))

(defun %indent-spaces (level)
  (make-string (* level 4) :initial-element #\Space))

(defun %format-indented-body (node indent)
  "Ensure a statement or expression node is properly indented within a compound block."
  (if (or (lys.ast.canonical:c-block-p node)
          (lys.ast.canonical:c-assign-p node)
          (lys.ast.canonical:c-if-p node)
          (lys.ast.canonical:c-while-p node)
          (lys.ast.canonical:c-def-p node)
          (lys.ast.canonical:c-return-p node)
          (lys.ast.canonical:c-try-finally-p node))
      (%lower-to-python-string node indent)
      (format nil "~A~A" (%indent-spaces indent) (%lower-to-python-string node 0))))

(defun %c-expression-p (node)
  "Return T if canonical NODE is an expression producing a value."
  (or (lys.ast.canonical:c-literal-p node)
      (lys.ast.canonical:c-identifier-p node)
      (lys.ast.canonical:c-binary-op-p node)
      (lys.ast.canonical:c-unary-op-p node)
      (lys.ast.canonical:c-call-p node)
      (and (lys.ast.canonical:c-if-p node)
           (lys.ast.canonical:c-if-else node)
           (%c-expression-p (lys.ast.canonical:c-if-then node))
           (%c-expression-p (lys.ast.canonical:c-if-else node)))))

(defun %lower-to-python-string (node &optional (indent 0))
  "Recursively serialize CANONICAL-NODE into Python code strings."
  (cond
    ((null node) "")

    ;; Literal
    ((lys.ast.canonical:c-literal-p node)
     (let ((val (lys.ast.canonical:c-literal-value node)))
       (cond
         ((null val) "None")
         ((eq val t) "True")
         ((stringp val) (format nil "~S" val))
         (t (format nil "~A" val)))))

    ;; Identifier
    ((lys.ast.canonical:c-identifier-p node)
     (lys.ast.canonical:c-identifier-name node))

    ;; Binary Operation
    ((lys.ast.canonical:c-binary-op-p node)
     (let ((op-str (case (lys.ast.canonical:c-binary-op-op node)
                     (:+ "+") (:- "-") (:* "*") (:/ "/") (:% "%")
                     (:== "==") (:!= "!=") (:< "<") (:<= "<=")
                     (:> ">") (:>= ">=") (:and "and") (:or "or")
                     (t (string (lys.ast.canonical:c-binary-op-op node))))))
       (format nil "(~A ~A ~A)"
               (%lower-to-python-string (lys.ast.canonical:c-binary-op-left node) indent)
               op-str
               (%lower-to-python-string (lys.ast.canonical:c-binary-op-right node) indent))))

    ;; Unary Operation
    ((lys.ast.canonical:c-unary-op-p node)
     (let ((op-str (case (lys.ast.canonical:c-unary-op-op node)
                     (:- "-") (:not "not ") (:~ "~")
                     (t (string (lys.ast.canonical:c-unary-op-op node))))))
       (format nil "(~A~A)"
               op-str
               (%lower-to-python-string (lys.ast.canonical:c-unary-op-operand node) indent))))

    ;; Call
    ((lys.ast.canonical:c-call-p node)
     (let ((callee-str (%lower-to-python-string (lys.ast.canonical:c-call-callee node) indent))
           (args-str (format nil "~{~A~^, ~}"
                             (mapcar (lambda (a) (%lower-to-python-string a indent))
                                     (lys.ast.canonical:c-call-args node)))))
       (format nil "~A(~A)" callee-str args-str)))

    ;; Assign
    ((lys.ast.canonical:c-assign-p node)
     (format nil "~A~A = ~A"
             (%indent-spaces indent)
             (%lower-to-python-string (lys.ast.canonical:c-assign-target node) 0)
             (%lower-to-python-string (lys.ast.canonical:c-assign-value node) 0)))

    ;; Block
    ((lys.ast.canonical:c-block-p node)
     (let ((stmts (lys.ast.canonical:c-block-statements node)))
       (if (null stmts)
           (format nil "~Apass" (%indent-spaces indent))
           (format nil "~{~A~^~%~}"
                   (mapcar (lambda (s) (%lower-to-python-string s indent))
                           stmts)))))

    ;; If
    ((lys.ast.canonical:c-if-p node)
     (let ((cond-str (%lower-to-python-string (lys.ast.canonical:c-if-condition node) 0))
           (then-node (lys.ast.canonical:c-if-then node))
           (else-node (lys.ast.canonical:c-if-else node)))
       (if (and else-node
                (%c-expression-p then-node)
                (%c-expression-p else-node))
           (format nil "~A(~A if ~A else ~A)"
                   (%indent-spaces indent)
                   (%lower-to-python-string then-node 0)
                   cond-str
                   (%lower-to-python-string else-node 0))
           (let ((then-str (%format-indented-body then-node (1+ indent))))
             (if else-node
                 (format nil "~Aif ~A:~%~A~%~Aelse:~%~A"
                         (%indent-spaces indent)
                         cond-str
                         then-str
                         (%indent-spaces indent)
                         (%format-indented-body else-node (1+ indent)))
                 (format nil "~Aif ~A:~%~A"
                         (%indent-spaces indent)
                         cond-str
                         then-str))))))

    ;; While
    ((lys.ast.canonical:c-while-p node)
     (format nil "~Awhile ~A:~%~A"
             (%indent-spaces indent)
             (%lower-to-python-string (lys.ast.canonical:c-while-condition node) 0)
             (%format-indented-body (lys.ast.canonical:c-while-body node) (1+ indent))))

    ;; Def
    ((lys.ast.canonical:c-def-p node)
     (let ((name (lys.ast.canonical:c-def-name node))
           (params (format nil "~{~A~^, ~}" (lys.ast.canonical:c-def-params node)))
           (body-str (%format-indented-body (lys.ast.canonical:c-def-body node) (1+ indent))))
       (format nil "~Adef ~A(~A):~%~A"
               (%indent-spaces indent)
               name
               params
               body-str)))

    ;; Return
    ((lys.ast.canonical:c-return-p node)
     (let ((val (lys.ast.canonical:c-return-value node)))
       (if val
           (format nil "~Areturn ~A"
                   (%indent-spaces indent)
                   (%lower-to-python-string val 0))
           (format nil "~Areturn" (%indent-spaces indent)))))

    ;; Try-Finally
    ((lys.ast.canonical:c-try-finally-p node)
     (let ((try-str (%format-indented-body (lys.ast.canonical:c-try-finally-try-body node) (1+ indent)))
           (fin-str (if (lys.ast.canonical:c-try-finally-finally-body node)
                        (%format-indented-body (lys.ast.canonical:c-try-finally-finally-body node) (1+ indent))
                        (format nil "~Apass" (%indent-spaces (1+ indent))))))
       (format nil "~Atry:~%~A~%~Afinally:~%~A"
               (%indent-spaces indent)
               try-str
               (%indent-spaces indent)
               fin-str)))

    (t
     (format nil "~A# Unrecognized Canonical Node: ~A" (%indent-spaces indent) node))))
