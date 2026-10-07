;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Test Suite Harness and Runner

(in-package #:lys.tests)

(defparameter *test-passes* 0)
(defparameter *test-failures* 0)

(defmacro run-test-case (name &body body)
  `(progn
     (format t "Running ~A... " ',name)
     (handler-case
         (progn
           ,@body
           (incf *test-passes*)
           (format t "[PASS]~%"))
       (error (err)
         (incf *test-failures*)
         (format t "[FAIL]: ~A~%" err)))))

(defun run-unit-tests ()
  "Execute all unit tests for AST, macros, and desugaring."
  (format t "~&=== LYSPYTHON Unit Tests ===~%")
  (run-test-case test-surface-ast-creation (test-surface-ast-creation))
  (run-test-case test-canonical-ast-creation (test-canonical-ast-creation))
  (run-test-case test-macro-registration (test-macro-registration-and-lookup))
  (run-test-case test-macro-expansion (test-macro-expansion-and-trace))
  (run-test-case test-macro-cycle-detection (test-macro-cycle-detection))
  (run-test-case test-ast-desugaring-pass (test-ast-desugaring-pass))
  t)

(defun run-integration-tests ()
  "Execute end-to-end evaluation pipeline integration tests."
  (format t "~&=== LYSPYTHON Integration Tests ===~%")
  (run-test-case test-pipeline-arithmetic (test-pipeline-arithmetic))
  (run-test-case test-pipeline-variable-binding (test-pipeline-variable-binding))
  t)

(defun run-research-tests ()
  "Execute formal research validation experiments."
  (format t "~&=== LYSPYTHON Research Inversion Tests ===~%")
  (run-test-case test-dynamic-semantic-inversion (test-dynamic-semantic-inversion))
  t)

(defun run-all-tests ()
  "Execute all test suites and report total results."
  (setf *test-passes* 0)
  (setf *test-failures* 0)
  (format t "~&========================================~%")
  (format t "LYSPYTHON Test Suite Execution~%")
  (format t "========================================~%")

  (run-unit-tests)
  (run-integration-tests)
  (run-research-tests)

  (format t "~&----------------------------------------~%")
  (format t "Test Results: ~A Passed, ~A Failed~%" *test-passes* *test-failures*)
  (format t "----------------------------------------~%")

  (if (zerop *test-failures*)
      (progn
        (format t "All LYSPYTHON test suites passed successfully.~%")
        t)
      (progn
        (format t "Test failures detected.~%")
        nil)))
