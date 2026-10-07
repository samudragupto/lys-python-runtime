;;;; LYSPYTHON Semantic Redesign 02: Design by Contract via Macro Transformation
;;;; Demonstrates synthesizing runtime pre/post condition assertions into functions.

(in-package #:lys.macros)

(define-python-macro def-with-contract (name params requires ensures body)
  "Synthesizes formal contract validation into a Python function definition.
   REQUIRES is an invariant boolean expression evaluated on entry.
   ENSURES is an invariant boolean expression evaluated before return."
  (let ((ret-var (lys.utils:make-unique-identifier "result_")))
    (lys.ast.surface:make-ast-def
     :name name
     :params params
     :body (lys.ast.surface:make-ast-block
            :statements
            (list
             ;; Precondition assertion: assert requires, "Precondition violated"
             (lys.ast.surface:make-ast-if
              :condition (lys.ast.surface:make-ast-unary-op
                          :op :not
                          :operand requires)
              :then (lys.ast.surface:make-ast-call
                     :callee (lys.ast.surface:make-ast-identifier :name "print")
                     :args (list (lys.ast.surface:make-ast-literal :value "CONTRACT ERROR: Precondition violated!"))))
             ;; Evaluate body and capture result
             (lys.ast.surface:make-ast-assign
              :target (lys.ast.surface:make-ast-identifier :name ret-var)
              :value body)
             ;; Postcondition assertion
             (lys.ast.surface:make-ast-if
              :condition (lys.ast.surface:make-ast-unary-op
                          :op :not
                          :operand ensures)
              :then (lys.ast.surface:make-ast-call
                     :callee (lys.ast.surface:make-ast-identifier :name "print")
                     :args (list (lys.ast.surface:make-ast-literal :value "CONTRACT ERROR: Postcondition violated!"))))
             ;; Return result
             (lys.ast.surface:make-ast-return
              :value (lys.ast.surface:make-ast-identifier :name ret-var)))))))
