;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Lexical Namespaces, Frames, and Symbol Tables

(in-package #:lys.env)

(defstruct environment
  "Represents the hierarchical scope and symbol table environment."
  (frames (list (make-hash-table :test #'equal)))
  (globals (make-hash-table :test #'equal))
  (module-name "__lys_main__" :type string))

(defparameter *global-environment* nil
  "Global execution environment singleton for the active kernel.")

(defun env-push-frame (env)
  "Push a new lexical local frame onto ENV."
  (push (make-hash-table :test #'equal) (environment-frames env)))

(defun env-pop-frame (env)
  "Pop the outermost lexical local frame from ENV."
  (when (> (length (environment-frames env)) 1)
    (pop (environment-frames env))))

(defun env-bind (name value &optional (env *global-environment*))
  "Bind NAME to VALUE in the innermost local frame of ENV."
  (let* ((env (or env (setf *global-environment* (make-environment))))
         (innermost-frame (first (environment-frames env))))
    (setf (gethash (string name) innermost-frame) value)))

(defun env-bind-global (name value &optional (env *global-environment*))
  "Bind NAME to VALUE in the global module namespace of ENV."
  (let ((env (or env (setf *global-environment* (make-environment)))))
    (setf (gethash (string name) (environment-globals env)) value)))

(defun env-lookup (name &optional (env *global-environment*))
  "Look up NAME through the lexical frame stack, falling back to globals."
  (let ((env (or env *global-environment*)))
    (when env
      (let ((name-str (string name)))
        ;; Search local frames from inner to outer
        (dolist (frame (environment-frames env))
          (multiple-value-bind (val found) (gethash name-str frame)
            (when found
              (return-from env-lookup (values val t)))))
        ;; Search global namespace
        (multiple-value-bind (val found) (gethash name-str (environment-globals env))
          (when found
            (return-from env-lookup (values val t))))
        (values nil nil)))))
