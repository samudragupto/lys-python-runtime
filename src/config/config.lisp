;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Runtime Configuration

(in-package #:lys.config)

(defparameter *version* "0.1.0-alpha"
  "Current version identifier of the LYSPYTHON meta-runtime.")

(defparameter *valid-runtime-modes*
  '(:normal :macro-trace :ast-trace :verbose :research)
  "Exhaustive list of supported execution modes.")

(defparameter *runtime-mode* :normal
  "Active operational mode for the evaluation pipeline.
   - :normal      : Standard evaluation, returns final CPython value.
   - :macro-trace : Emits step-by-step macro expansion diffs.
   - :ast-trace   : Visualizes Surface, Transformed, and Canonical ASTs.
   - :verbose     : Emits diagnostic logs for every pipeline phase.
   - :research    : Emits detailed execution metrics, memory states, and FFI timing.")

(defparameter *max-macro-expansion-depth* 64
  "Maximum recursion depth for fixed-point macro expansion before signaling a cycle.")

(defparameter *trace-expansions-p* t
  "When non-nil, the macro engine records every intermediate expansion step in *expansion-trace*.")

(defparameter *cpython-shared-library-path* nil
  "Explicit filesystem path to libpython shared library. When NIL, CFFI auto-discovers.")

(defparameter *tree-sitter-library-path* nil
  "Filesystem path to tree-sitter shared object.")

(defun valid-runtime-modes ()
  "Return the list of valid runtime modes."
  *valid-runtime-modes*)

(defun runtime-mode-p (mode)
  "Predicate checking if MODE is a supported runtime mode."
  (member mode *valid-runtime-modes* :test #'eq))

(defun set-runtime-mode (mode)
  "Set *runtime-mode* to MODE after verifying validity."
  (if (runtime-mode-p mode)
      (setf *runtime-mode* mode)
      (error "Invalid runtime mode ~S. Allowed modes: ~S" mode *valid-runtime-modes*)))
