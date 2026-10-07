;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Unit Test: AST Structures and Traversal

(in-package #:lys.tests)

(defun test-surface-ast-creation ()
  "Verify constructor invariants and child extraction on Surface AST."
  (let ((lit (lys.ast.surface:make-ast-literal :value 42 :line 1 :column 5))
        (id (lys.ast.surface:make-ast-identifier :name "x" :line 1 :column 10)))
    (assert (lys.ast.surface:ast-literal-p lit))
    (assert (= (lys.ast.surface:ast-literal-value lit) 42))
    (assert (= (lys.ast.surface:node-line lit) 1))
    (assert (lys.ast.surface:ast-identifier-p id))
    (assert (string= (lys.ast.surface:ast-identifier-name id) "x"))

    (let ((binop (lys.ast.surface:make-ast-binary-op :op :+ :left id :right lit)))
      (assert (lys.ast.surface:ast-binary-op-p binop))
      (assert (eq (lys.ast.surface:ast-binary-op-op binop) :+))
      (let ((children (lys.ast.surface:ast-children binop)))
        (assert (= (length children) 2))
        (assert (eq (first children) id))
        (assert (eq (second children) lit))))

    (let ((serialized (lys.ast.surface:serialize-ast lit)))
      (assert (equal serialized '(:literal 42))))))

(defun test-canonical-ast-creation ()
  "Verify constructor invariants on Canonical AST nodes."
  (let ((c-lit (lys.ast.canonical:make-c-literal :value "hello"))
        (c-id (lys.ast.canonical:make-c-identifier :name "greeting")))
    (assert (lys.ast.canonical:c-literal-p c-lit))
    (assert (lys.ast.canonical:c-identifier-p c-id))
    (assert (lys.ast.canonical:canonical-node-p c-lit))
    (assert (lys.ast.canonical:canonical-node-p c-id))
    (let ((c-assign (lys.ast.canonical:make-c-assign :target c-id :value c-lit)))
      (assert (lys.ast.canonical:c-assign-p c-assign))
      (assert (equal (lys.ast.canonical:serialize-canonical-node c-assign)
                     '(:c-assign (:c-id "greeting") (:c-literal "hello")))))))
