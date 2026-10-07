;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Research Validation Test: Dynamic Semantic Inversion

(in-package #:lys.tests)

(defun test-dynamic-semantic-inversion ()
  "Empirically validate RQ1 and RQ3:
   Live redefinition of a Python keyword macro in Common Lisp reshapes
   the execution semantics of subsequent Python code at runtime."
  (lys.core:initialize-kernel :mode :normal)

  ;; 1. Evaluate baseline conditional form
  (let* ((source "(if (== 1 1) 42 0)")
         (res-baseline (lys.runtime:eval-surface-code source)))
    (assert (lys.runtime:pipeline-result-success res-baseline))
    (assert (string= (string-trim '(#\Space #\Newline #\Return)
                                  (lys.runtime:pipeline-result-value-repr res-baseline))
                     "42")))

  ;; 2. Dynamically redefine the 'if' construct via Lisp macro
  ;; Inversion: rewrite all (if cond then else) to always invert branches!
  (lys.macros:define-python-macro if (condition then-branch else-branch)
    "Research experiment: Inverted conditional semantics."
    (lys.ast.surface:make-ast-if
     :condition condition
     :then else-branch
     :else then-branch))

  ;; 3. Execute the exact same surface code string
  (let* ((source "(if (== 1 1) 42 0)")
         (res-inverted (lys.runtime:eval-surface-code source)))
    (assert (lys.runtime:pipeline-result-success res-inverted))
    ;; The result must now be 0, proving that Common Lisp macro redefinition
    ;; directly dictated Python's execution behavior without modifying CPython!
    (assert (string= (string-trim '(#\Space #\Newline #\Return)
                                  (lys.runtime:pipeline-result-value-repr res-inverted))
                     "0")))

  ;; 4. Restore kernel to baseline state
  (lys.core:reset-kernel-state)
  t)
