;;;; LYSPYTHON Semantic Redesign 03: Pure Functional Dialect of Python
;;;; Enforces immutability by intercepting assignment macros at expansion time.

(in-package #:lys.macros)

(defparameter *bound-immutable-identifiers* (make-hash-table :test #'equal)
  "Tracks identifiers that have been bound in pure functional mode.")

(define-python-macro pure-assign (target value)
  "Assignment macro enforcing single-assignment (immutability) semantics.
   If TARGET has already been assigned in the current scope, signals a compiler error."
  (let ((name (if (lys.ast.surface:ast-identifier-p target)
                  (lys.ast.surface:ast-identifier-name target)
                  nil)))
    (when (and name (gethash name *bound-immutable-identifiers*))
      (error 'lys.utils:macro-expansion-error
             :macro-name :pure-assign
             :message (format nil "Immutability Violation: Cannot reassign identifier '~A' in pure functional mode." name)))
    (when name
      (setf (gethash name *bound-immutable-identifiers*) t))
    (lys.ast.surface:make-ast-assign :target target :value value)))
