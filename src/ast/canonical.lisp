;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Canonical Abstract Syntax Tree (C-AST)

(in-package #:lys.ast.canonical)

(defstruct (ast-canonical-node (:constructor nil))
  "Base structure for minimal, orthogonal Canonical AST nodes."
  (line 1 :type integer)
  (column 0 :type integer)
  (c-node-kind :generic :type symbol))

;;; Canonical Primitive Expressions

(defstruct (c-literal (:include ast-canonical-node (c-node-kind :literal)))
  "Canonical constant literal."
  (value nil))

(defstruct (c-identifier (:include ast-canonical-node (c-node-kind :identifier)))
  "Canonical identifier name."
  (name "" :type string))

(defstruct (c-binary-op (:include ast-canonical-node (c-node-kind :binary-op)))
  "Canonical primitive binary operation."
  (op :+ :type symbol)
  (left nil)
  (right nil))

(defstruct (c-unary-op (:include ast-canonical-node (c-node-kind :unary-op)))
  "Canonical unary operation."
  (op :- :type symbol)
  (operand nil))

(defstruct (c-call (:include ast-canonical-node (c-node-kind :call)))
  "Canonical procedure invocation."
  (callee nil)
  (args nil :type list)
  (kwargs nil :type list))

;;; Canonical Statements and Control Flow

(defstruct (c-block (:include ast-canonical-node (c-node-kind :block)))
  "Canonical statement sequence."
  (statements nil :type list))

(defstruct (c-assign (:include ast-canonical-node (c-node-kind :assign)))
  "Canonical atomic assignment (target = value)."
  (target nil)
  (value nil))

(defstruct (c-if (:include ast-canonical-node (c-node-kind :if)))
  "Canonical 2-way conditional branching."
  (condition nil)
  (then nil)
  (else nil))

(defstruct (c-while (:include ast-canonical-node (c-node-kind :while)))
  "Canonical loop primitive."
  (condition nil)
  (body nil))

(defstruct (c-def (:include ast-canonical-node (c-node-kind :def)))
  "Canonical function definition."
  (name "" :type string)
  (params nil :type list)
  (body nil))

(defstruct (c-return (:include ast-canonical-node (c-node-kind :return)))
  "Canonical control return."
  (value nil))

(defstruct (c-try-finally (:include ast-canonical-node (c-node-kind :try-finally)))
  "Canonical unwind-protect / cleanup primitive."
  (try-body nil)
  (finally-body nil))

(defun canonical-node-p (object)
  "Predicate verifying if OBJECT is an instance of ast-canonical-node."
  (typep object 'ast-canonical-node))

(defun serialize-canonical-node (node)
  "Convert a Canonical AST node into a symbolic representation."
  (cond
    ((null node) nil)
    ((c-literal-p node) (list :c-literal (c-literal-value node)))
    ((c-identifier-p node) (list :c-id (c-identifier-name node)))
    ((c-binary-op-p node)
     (list :c-binop (c-binary-op-op node)
           (serialize-canonical-node (c-binary-op-left node))
           (serialize-canonical-node (c-binary-op-right node))))
    ((c-unary-op-p node)
     (list :c-unop (c-unary-op-op node)
           (serialize-canonical-node (c-unary-op-operand node))))
    ((c-call-p node)
     (list :c-call (serialize-canonical-node (c-call-callee node))
           (mapcar #'serialize-canonical-node (c-call-args node))))
    ((c-block-p node)
     (cons :c-block (mapcar #'serialize-canonical-node (c-block-statements node))))
    ((c-assign-p node)
     (list :c-assign (serialize-canonical-node (c-assign-target node))
           (serialize-canonical-node (c-assign-value node))))
    ((c-if-p node)
     (list :c-if (serialize-canonical-node (c-if-condition node))
           (serialize-canonical-node (c-if-then node))
           (serialize-canonical-node (c-if-else node))))
    ((c-while-p node)
     (list :c-while (serialize-canonical-node (c-while-condition node))
           (serialize-canonical-node (c-while-body node))))
    ((c-def-p node)
     (list :c-def (c-def-name node)
           (c-def-params node)
           (serialize-canonical-node (c-def-body node))))
    ((c-return-p node)
     (list :c-return (serialize-canonical-node (c-return-value node))))
    ((c-try-finally-p node)
     (list :c-try-finally
           (serialize-canonical-node (c-try-finally-try-body node))
           (serialize-canonical-node (c-try-finally-finally-body node))))
    (t (format nil "~A" node))))
