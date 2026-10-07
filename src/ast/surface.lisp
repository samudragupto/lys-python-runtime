;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Surface Abstract Syntax Tree (S-AST)

(in-package #:lys.ast.surface)

(defstruct (ast-node (:constructor nil))
  "Base structure for all Abstract Syntax Tree nodes in LYSPYTHON."
  (line 1 :type integer)
  (column 0 :type integer)
  (kind :generic :type symbol))

(defstruct (ast-surface-node (:include ast-node))
  "Base structure for Surface AST nodes representing human-authored Python syntax.")

(defun node-line (node) (ast-node-line node))
(defun node-column (node) (ast-node-column node))
(defun node-kind (node) (ast-node-kind node))

;;; Expressions

(defstruct (ast-literal (:include ast-surface-node (kind :literal)))
  "Represents constant literals (numbers, strings, booleans, None)."
  (value nil))

(defstruct (ast-identifier (:include ast-surface-node (kind :identifier)))
  "Represents an identifier symbol (e.g., variable or function name)."
  (name "" :type string))

(defstruct (ast-binary-op (:include ast-surface-node (kind :binary-op)))
  "Represents an infix binary operation (e.g., +, -, *, /, ==, <, and, or)."
  (op :+ :type symbol)
  (left nil)
  (right nil))

(defstruct (ast-unary-op (:include ast-surface-node (kind :unary-op)))
  "Represents a prefix unary operation (e.g., -, not, ~)."
  (op :- :type symbol)
  (operand nil))

(defstruct (ast-call (:include ast-surface-node (kind :call)))
  "Represents a function or method invocation."
  (callee nil)
  (args nil :type list)
  (kwargs nil :type list))

(defstruct (ast-attribute (:include ast-surface-node (kind :attribute)))
  "Represents an attribute lookup (e.g., obj.attribute)."
  (value nil)
  (attr "" :type string))

(defstruct (ast-subscript (:include ast-surface-node (kind :subscript)))
  "Represents an indexing or slicing operation (e.g., array[idx])."
  (value nil)
  (slice nil))

;;; Statements and Blocks

(defstruct (ast-block (:include ast-surface-node (kind :block)))
  "Represents an ordered sequence of statements."
  (statements nil :type list))

(defstruct (ast-assign (:include ast-surface-node (kind :assign)))
  "Represents a variable assignment statement (target = value)."
  (target nil)
  (value nil))

(defstruct (ast-aug-assign (:include ast-surface-node (kind :aug-assign)))
  "Represents an augmented assignment statement (target += value)."
  (op :+ :type symbol)
  (target nil)
  (value nil))

(defstruct (ast-if (:include ast-surface-node (kind :if)))
  "Represents conditional branching (if condition: then_branch else: else_branch)."
  (condition nil)
  (then nil)
  (else nil))

(defstruct (ast-while (:include ast-surface-node (kind :while)))
  "Represents a while loop construct."
  (condition nil)
  (body nil)
  (else nil))

(defstruct (ast-for (:include ast-surface-node (kind :for)))
  "Represents a for-in iterative loop."
  (target nil)
  (iterable nil)
  (body nil)
  (else nil))

(defstruct (ast-def (:include ast-surface-node (kind :def)))
  "Represents a function definition."
  (name "" :type string)
  (params nil :type list)
  (body nil)
  (decorators nil :type list))

(defstruct (ast-class (:include ast-surface-node (kind :class)))
  "Represents a class definition."
  (name "" :type string)
  (bases nil :type list)
  (body nil))

(defstruct (ast-return (:include ast-surface-node (kind :return)))
  "Represents a return statement."
  (value nil))

(defstruct (ast-try (:include ast-surface-node (kind :try)))
  "Represents a try-except-else-finally block."
  (body nil)
  (handlers nil :type list)
  (else nil)
  (finally nil))

(defstruct (ast-with (:include ast-surface-node (kind :with)))
  "Represents a with context manager construct."
  (items nil :type list)
  (body nil))

;;; Generic Traversal and Serialization Helpers

(defun ast-children (node)
  "Return an ordered list of direct child AST nodes for traversal."
  (cond
    ((null node) nil)
    ((ast-block-p node) (ast-block-statements node))
    ((ast-binary-op-p node) (list (ast-binary-op-left node) (ast-binary-op-right node)))
    ((ast-unary-op-p node) (list (ast-unary-op-operand node)))
    ((ast-call-p node) (cons (ast-call-callee node) (ast-call-args node)))
    ((ast-attribute-p node) (list (ast-attribute-value node)))
    ((ast-subscript-p node) (list (ast-subscript-value node) (ast-subscript-slice node)))
    ((ast-assign-p node) (list (ast-assign-target node) (ast-assign-value node)))
    ((ast-aug-assign-p node) (list (ast-aug-assign-target node) (ast-aug-assign-value node)))
    ((ast-if-p node) (remove nil (list (ast-if-condition node) (ast-if-then node) (ast-if-else node))))
    ((ast-while-p node) (remove nil (list (ast-while-condition node) (ast-while-body node) (ast-while-else node))))
    ((ast-for-p node) (remove nil (list (ast-for-target node) (ast-for-iterable node) (ast-for-body node) (ast-for-else node))))
    ((ast-def-p node) (list (ast-def-body node)))
    ((ast-class-p node) (list (ast-class-body node)))
    ((ast-return-p node) (remove nil (list (ast-return-value node))))
    ((ast-try-p node) (remove nil (list (ast-try-body node) (ast-try-finally node))))
    ((ast-with-p node) (list (ast-with-body node)))
    (t nil)))

(defun serialize-ast (node)
  "Convert an AST node hierarchy into a homoiconic S-expression representation."
  (cond
    ((null node) nil)
    ((ast-literal-p node) (list :literal (ast-literal-value node)))
    ((ast-identifier-p node) (list :id (ast-identifier-name node)))
    ((ast-binary-op-p node)
     (list :binop (ast-binary-op-op node)
           (serialize-ast (ast-binary-op-left node))
           (serialize-ast (ast-binary-op-right node))))
    ((ast-unary-op-p node)
     (list :unop (ast-unary-op-op node)
           (serialize-ast (ast-unary-op-operand node))))
    ((ast-call-p node)
     (list :call (serialize-ast (ast-call-callee node))
           (mapcar #'serialize-ast (ast-call-args node))))
    ((ast-assign-p node)
     (list :assign (serialize-ast (ast-assign-target node))
           (serialize-ast (ast-assign-value node))))
    ((ast-aug-assign-p node)
     (list :aug-assign (ast-aug-assign-op node)
           (serialize-ast (ast-aug-assign-target node))
           (serialize-ast (ast-aug-assign-value node))))
    ((ast-block-p node)
     (cons :block (mapcar #'serialize-ast (ast-block-statements node))))
    ((ast-if-p node)
     (list :if (serialize-ast (ast-if-condition node))
           (serialize-ast (ast-if-then node))
           (serialize-ast (ast-if-else node))))
    ((ast-while-p node)
     (list :while (serialize-ast (ast-while-condition node))
           (serialize-ast (ast-while-body node))))
    ((ast-for-p node)
     (list :for (serialize-ast (ast-for-target node))
           (serialize-ast (ast-for-iterable node))
           (serialize-ast (ast-for-body node))))
    ((ast-def-p node)
     (list :def (ast-def-name node)
           (ast-def-params node)
           (serialize-ast (ast-def-body node))))
    ((ast-return-p node)
     (list :return (serialize-ast (ast-return-value node))))
    ((listp node) (mapcar #'serialize-ast node))
    (t (format nil "~A" node))))
