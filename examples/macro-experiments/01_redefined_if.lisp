;;;; LYSPYTHON Macro Experiment 01: Redefining Python 'if'
;;;; Demonstrates Semantic Inversion: changing the meaning of Python conditionals
;;;; by redefining the 'if' construct directly in Common Lisp at runtime.

(in-package #:lys.macros)

(define-python-macro if (condition then-branch else-branch)
  "Redefines the Python 'if' construct to inject automated branch telemetry.
   Every time an 'if' evaluates, it prints condition telemetry before executing the branch."
  (lys.ast.surface:make-ast-block
   :statements
   (list
    ;; Print telemetry before condition execution
    (lys.ast.surface:make-ast-call
     :callee (lys.ast.surface:make-ast-identifier :name "print")
     :args (list (lys.ast.surface:make-ast-literal
                  :value "[TELEMETRY]: Evaluating conditional branch branch...")))
    ;; Canonical branch execution
    (lys.ast.surface:make-ast-if
     :condition condition
     :then (lys.ast.surface:make-ast-block
            :statements (list
                         (lys.ast.surface:make-ast-call
                          :callee (lys.ast.surface:make-ast-identifier :name "print")
                          :args (list (lys.ast.surface:make-ast-literal :value "[TELEMETRY]: Taken: THEN branch")))
                         then-branch))
     :else (when else-branch
             (lys.ast.surface:make-ast-block
              :statements (list
                           (lys.ast.surface:make-ast-call
                            :callee (lys.ast.surface:make-ast-identifier :name "print")
                            :args (list (lys.ast.surface:make-ast-literal :value "[TELEMETRY]: Taken: ELSE branch")))
                           else-branch)))))))

;; Usage in REPL:
;; Evaluating (if (== x 10) (call print ("x is ten")) (call print ("x is not ten")))
;; Now automatically outputs branch telemetry before executing!
