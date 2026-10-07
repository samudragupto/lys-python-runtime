;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Integration Test: End-to-End Evaluation Pipeline

(in-package #:lys.tests)

(defun test-pipeline-arithmetic ()
  "Verify complete compilation and execution of arithmetic expressions."
  (lys.core:initialize-kernel :mode :normal)
  (let ((res (lys.runtime:eval-surface-code "(+ 10 20)")))
    (assert (lys.runtime:pipeline-result-success res))
    (assert (string= (string-trim '(#\Space #\Newline #\Return)
                                  (lys.runtime:pipeline-result-value-repr res))
                     "30"))))

(defun test-pipeline-variable-binding ()
  "Verify statement block evaluation with assignment and print execution."
  (lys.core:initialize-kernel :mode :normal)
  (let* ((code "(block (assign x 100) (assign y 50) (+ x y))")
         (res (lys.runtime:eval-surface-code code)))
    (assert (lys.runtime:pipeline-result-success res))
    (assert (string= (string-trim '(#\Space #\Newline #\Return)
                                  (lys.runtime:pipeline-result-value-repr res))
                     "150"))))
