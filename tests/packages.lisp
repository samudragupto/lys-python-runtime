;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Test Package Definitions

(defpackage #:lys.tests
  (:use #:cl)
  (:export #:run-all-tests
           #:run-unit-tests
           #:run-integration-tests
           #:run-research-tests
           #:*test-passes*
           #:*test-failures*
           #:assert-true
           #:assert-equal
           #:assert-signals-error))
