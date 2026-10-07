;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Macro Expansion Engine

(in-package #:lys.macros)

(defstruct trace-step
  "Records an individual macro transformation step."
  (step-number 0 :type integer)
  (macro-name nil :type symbol)
  (before nil)
  (after nil))

(defparameter *expansion-trace* nil
  "Dynamic list collecting trace-step records for the active evaluation pipeline.")

(defparameter *step-counter* 0
  "Monotonically increasing step counter for expansion tracing.")

(defun get-node-operator (node)
  "Identify the operator symbol associated with an AST node or S-expression form."
  (cond
    ((null node) nil)
    ((lys.ast.surface:ast-node-p node)
     (let ((kind (lys.ast.surface:node-kind node)))
       (case kind
         (:if :if)
         (:while :while)
         (:for :for)
         (:def :def)
         (:class :class)
         (:assign :assign)
         (:aug-assign :aug-assign)
         (:call :call)
         (:return :return)
         (:try :try)
         (:with :with)
         (t nil))))
    ((listp node)
     (let ((head (first node)))
       (if (symbolp head)
           (intern (string-upcase (string head)) :keyword)
           nil)))
    (t nil)))

(defun macroexpand-1 (node &optional env)
  "Perform a single-step macro expansion on the outermost form of NODE.
   Returns two values: (VALUES EXPANDED-NODE EXPANDED-P)."
  (let ((op (get-node-operator node)))
    (if op
        (let ((defn (lookup-macro op)))
          (if defn
              (let* ((expander (macro-definition-expander defn))
                     (expanded (funcall expander node env)))
                ;; Normalize expanded form if S-expression returned and not an intermediate macro form
                (let ((final-expanded (if (and (listp expanded)
                                               (not (lookup-macro (get-node-operator expanded))))
                                          (lys.reader:parse-surface-sexpr expanded)
                                          expanded)))
                  (when lys.config:*trace-expansions-p*
                    (incf *step-counter*)
                    (push (make-trace-step
                           :step-number *step-counter*
                           :macro-name op
                           :before node
                           :after final-expanded)
                          *expansion-trace*))
                  (values final-expanded t)))
              (values node nil)))
        (values node nil))))

(defun %node-structural-digest (node)
  "Compute a structural hash of an AST node for cycle detection."
  (sxhash (format nil "~S" (if (lys.ast.surface:ast-node-p node)
                               (lys.ast.surface:serialize-ast node)
                               node))))

(defun macroexpand-fixpoint (node &optional env (depth 0) (visited-digests nil))
  "Repeatedly expand NODE until reaching an irreducible fixed point.
   Guards against infinite recursion and cycles."
  (when (> depth lys.config:*max-macro-expansion-depth*)
    (error 'lys.utils:expansion-depth-exceeded
           :depth depth
           :macro-name (get-node-operator node)
           :ast-node node))

  (let ((digest (%node-structural-digest node)))
    (when (member digest visited-digests)
      (error 'lys.utils:expansion-cycle-detected
             :macro-name (get-node-operator node)
             :cycle-node node))

    (multiple-value-bind (expanded expanded-p) (macroexpand-1 node env)
      (if expanded-p
          (if (and (lys.ast.surface:ast-node-p expanded)
                   (eq (get-node-operator expanded) (get-node-operator node)))
              (macroexpand-all expanded env depth)
              (macroexpand-fixpoint expanded env (1+ depth) (cons digest visited-digests)))
          ;; Node itself did not expand; recursively expand all its subtrees
          (macroexpand-all node env depth)))))

(defun macroexpand-all (node &optional env (depth 0))
  "Recursively traverse NODE and expand all subtrees using fixed-point expansion."
  (cond
    ((null node) nil)

    ((lys.ast.surface:ast-block-p node)
     (let ((expanded-stmts (mapcar (lambda (s) (macroexpand-fixpoint s env (1+ depth)))
                                   (lys.ast.surface:ast-block-statements node))))
       (setf (lys.ast.surface:ast-block-statements node) expanded-stmts)
       node))

    ((lys.ast.surface:ast-if-p node)
     (setf (lys.ast.surface:ast-if-condition node)
           (macroexpand-fixpoint (lys.ast.surface:ast-if-condition node) env (1+ depth)))
     (setf (lys.ast.surface:ast-if-then node)
           (macroexpand-fixpoint (lys.ast.surface:ast-if-then node) env (1+ depth)))
     (when (lys.ast.surface:ast-if-else node)
       (setf (lys.ast.surface:ast-if-else node)
             (macroexpand-fixpoint (lys.ast.surface:ast-if-else node) env (1+ depth))))
     node)

    ((lys.ast.surface:ast-while-p node)
     (setf (lys.ast.surface:ast-while-condition node)
           (macroexpand-fixpoint (lys.ast.surface:ast-while-condition node) env (1+ depth)))
     (setf (lys.ast.surface:ast-while-body node)
           (macroexpand-fixpoint (lys.ast.surface:ast-while-body node) env (1+ depth)))
     node)

    ((lys.ast.surface:ast-for-p node)
     (setf (lys.ast.surface:ast-for-iterable node)
           (macroexpand-fixpoint (lys.ast.surface:ast-for-iterable node) env (1+ depth)))
     (setf (lys.ast.surface:ast-for-body node)
           (macroexpand-fixpoint (lys.ast.surface:ast-for-body node) env (1+ depth)))
     node)

    ((lys.ast.surface:ast-def-p node)
     (setf (lys.ast.surface:ast-def-body node)
           (macroexpand-fixpoint (lys.ast.surface:ast-def-body node) env (1+ depth)))
     node)

    ((lys.ast.surface:ast-assign-p node)
     (setf (lys.ast.surface:ast-assign-value node)
           (macroexpand-fixpoint (lys.ast.surface:ast-assign-value node) env (1+ depth)))
     node)

    ((lys.ast.surface:ast-call-p node)
     (setf (lys.ast.surface:ast-call-callee node)
           (macroexpand-fixpoint (lys.ast.surface:ast-call-callee node) env (1+ depth)))
     (setf (lys.ast.surface:ast-call-args node)
           (mapcar (lambda (arg) (macroexpand-fixpoint arg env (1+ depth)))
                   (lys.ast.surface:ast-call-args node)))
     node)

    ((lys.ast.surface:ast-binary-op-p node)
     (setf (lys.ast.surface:ast-binary-op-left node)
           (macroexpand-fixpoint (lys.ast.surface:ast-binary-op-left node) env (1+ depth)))
     (setf (lys.ast.surface:ast-binary-op-right node)
           (macroexpand-fixpoint (lys.ast.surface:ast-binary-op-right node) env (1+ depth)))
     node)

    ((lys.ast.surface:ast-return-p node)
     (when (lys.ast.surface:ast-return-value node)
       (setf (lys.ast.surface:ast-return-value node)
             (macroexpand-fixpoint (lys.ast.surface:ast-return-value node) env (1+ depth))))
     node)

    (t node)))
