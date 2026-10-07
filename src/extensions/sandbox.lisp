;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Sandboxed Macro Experiments and Extensions

(in-package #:lys.extensions)

(defstruct sandbox-environment
  "Encapsulates an isolated execution sandbox with temporary macro definitions."
  (macro-table (make-hash-table :test #'eq))
  (runtime-env (lys.env:make-environment)))

(defun run-in-sandbox (thunk)
  "Execute THUNK within an isolated macro registry snapshot, restoring state on completion."
  (let ((original-registry (alexandria:copy-hash-table lys.macros:*global-macro-registry*)))
    (unwind-protect
         (funcall thunk)
      ;; Restore original macro table
      (setf lys.macros:*global-macro-registry* original-registry))))
