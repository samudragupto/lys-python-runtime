;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Unit Test: AST Desugaring and Normalization

(in-package #:lys.tests)

(defun test-ast-desugaring-pass ()
  "Verify that Surface AST constructs lower into Canonical AST representations."
  ;; Test literal desugaring
  (let* ((surf-lit (lys.ast.surface:make-ast-literal :value 100))
         (canon-lit (lys.transform:desugar-ast surf-lit)))
    (assert (lys.ast.canonical:c-literal-p canon-lit))
    (assert (= (lys.ast.canonical:c-literal-value canon-lit) 100)))

  ;; Test binary op desugaring
  (let* ((surf-left (lys.ast.surface:make-ast-literal :value 5))
         (surf-right (lys.ast.surface:make-ast-literal :value 10))
         (surf-binop (lys.ast.surface:make-ast-binary-op :op :* :left surf-left :right surf-right))
         (canon-binop (lys.transform:desugar-ast surf-binop)))
    (assert (lys.ast.canonical:c-binary-op-p canon-binop))
    (assert (eq (lys.ast.canonical:c-binary-op-op canon-binop) :*))
    (assert (lys.ast.canonical:c-literal-p (lys.ast.canonical:c-binary-op-left canon-binop)))
    (assert (lys.ast.canonical:c-literal-p (lys.ast.canonical:c-binary-op-right canon-binop))))

  ;; Test while desugaring
  (let* ((surf-cond (lys.ast.surface:make-ast-literal :value t))
         (surf-body (lys.ast.surface:make-ast-block :statements nil))
         (surf-while (lys.ast.surface:make-ast-while :condition surf-cond :body surf-body))
         (canon-while (lys.transform:desugar-ast surf-while)))
    (assert (lys.ast.canonical:c-while-p canon-while))
    (assert (lys.ast.canonical:c-block-p (lys.ast.canonical:c-while-body canon-while)))))
