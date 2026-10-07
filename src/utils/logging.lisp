;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Logging, Tracing, and Pretty-Printing Utilities

(in-package #:lys.utils)

(defparameter *log-indent-level* 0
  "Current indentation level for structured diagnostic logging.")

(defparameter *unique-id-counter* 0
  "Monotonically increasing counter for synthesized hygienic identifiers.")

(defmacro with-indent (&body body)
  "Execute BODY with incremented diagnostic indentation."
  `(let ((*log-indent-level* (1+ *log-indent-level*)))
     ,@body))

(defun %format-indent ()
  (make-string (* *log-indent-level* 2) :initial-element #\Space))

(defun log-info (fmt &rest args)
  "Log an informational message."
  (format *standard-output* "~&~A[INFO] ~?~%" (%format-indent) fmt args)
  (force-output *standard-output*))

(defun log-warn (fmt &rest args)
  "Log a warning message."
  (format *error-output* "~&~A[WARN] ~?~%" (%format-indent) fmt args)
  (force-output *error-output*))

(defun log-error (fmt &rest args)
  "Log an error message."
  (format *error-output* "~&~A[ERROR] ~?~%" (%format-indent) fmt args)
  (force-output *error-output*))

(defun log-trace (stage fmt &rest args)
  "Log a compiler or macro expansion trace step."
  (format *standard-output* "~&~A[TRACE:~A] ~?~%" (%format-indent) stage fmt args)
  (force-output *standard-output*))

(defun make-unique-identifier (&optional (prefix "lys_var_"))
  "Generate a fresh, collision-free identifier symbol for hygienic AST synthesis."
  (incf *unique-id-counter*)
  (format nil "~A~A" prefix *unique-id-counter*))

(defun format-ast-node (node)
  "Produce a concise textual representation of an AST node."
  (if (null node)
      "NIL"
      (format nil "~S" node)))

(defun print-ast-tree (node &optional (stream *standard-output*) (indent 0))
  "Recursively print an AST node hierarchy to STREAM with hierarchical indentation."
  (let ((spaces (make-string (* indent 2) :initial-element #\Space)))
    (format stream "~&~A~A~%" spaces (format-ast-node node))))
