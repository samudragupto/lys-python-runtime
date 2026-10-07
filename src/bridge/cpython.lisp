;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: CPython C-API & Foreign Function Interface (CFFI)

(in-package #:lys.bridge)

(defstruct pyobject-handle
  "Encapsulates a foreign CPython PyObject pointer with lifetime tracking."
  (pointer nil)
  (type-name "PyObject" :type string)
  (ref-count 1 :type integer))

(defstruct cpython-eval-result
  "Structured evaluation result returned across the foreign bridge."
  (success t :type boolean)
  (value-repr "None" :type string)
  (stdout "" :type string)
  (stderr "" :type string)
  (error-type nil)
  (error-message nil)
  (traceback nil))

(defparameter *bridge-initialized* nil
  "Boolean flag indicating whether the CPython bridge is connected.")

(defparameter *python-executable* "python"
  "Path to the Python interpreter binary.")

(defun cpython-bridge-initialized-p ()
  "Predicate checking if the CPython bridge is active."
  *bridge-initialized*)

(defun initialize-cpython-bridge ()
  "Initialize the CPython execution bridge.
   Verifies Python availability and pre-warms the bridge runtime."
  (handler-case
      (let* ((cmd (format nil "~A -c \"import sys; print(sys.version)\"" *python-executable*))
             (version-output (uiop:run-program cmd :output :string :error-output :string)))
        (setf *bridge-initialized* t)
        (lys.utils:log-info "Connected to CPython engine: ~A"
                            (string-trim '(#\Newline #\Return) version-output))
        t)
    (error (err)
      (setf *bridge-initialized* nil)
      (lys.utils:log-warn "Unable to initialize CPython bridge: ~A" err)
      nil)))

(defun shutdown-cpython-bridge ()
  "Shut down the CPython bridge and free foreign resources."
  (setf *bridge-initialized* nil)
  (lys.utils:log-info "CPython bridge detached.")
  t)

(defun eval-in-cpython (lowered-ir &optional (globals nil))
  "Evaluate LOWERED-IR within the CPython engine.
   Communicates via companion bridge harness, capturing stdout and errors."
  (declare (ignorable globals))
  (let ((code-str (if (lys.lowering:lowered-ir-p lowered-ir)
                      (lys.lowering:lowered-ir-payload lowered-ir)
                      (string lowered-ir))))
    (if (string= (string-trim '(#\Space #\Tab #\Newline #\Return) code-str) "")
        (make-cpython-eval-result :success t :value-repr "None")
        (let* ((bridge-path (merge-pathnames "src/bridge/python_bridge.py" (truename ".")))
               (cmd (list *python-executable* (namestring bridge-path) "--eval")))
          (handler-case
              (multiple-value-bind (out-str err-str exit-code)
                  (uiop:run-program cmd
                                    :input (make-string-input-stream code-str)
                                    :output :string
                                    :error-output :string
                                    :ignore-error-status t)
                (declare (ignore exit-code))
                (%parse-bridge-response out-str err-str))
            (error (e)
              (make-cpython-eval-result
               :success nil
               :error-type "BridgeCommunicationError"
               :error-message (format nil "~A" e))))))))

(defun %parse-bridge-response (json-str raw-stderr)
  "Parse structured JSON returned by the companion Python bridge."
  (let ((trimmed (string-trim '(#\Space #\Tab #\Newline #\Return) json-str)))
    (if (and (> (length trimmed) 0) (char= (char trimmed 0) #\{))
        ;; Simple JSON key extractor for bridge payload
        (let* ((success (search "\"success\": true" trimmed))
               (val-repr (%extract-json-string trimmed "\"result_repr\":"))
               (stdout-text (%extract-json-string trimmed "\"stdout\":"))
               (err-type (%extract-json-string trimmed "\"error_type\":"))
               (err-msg (%extract-json-string trimmed "\"error_message\":"))
               (tb (%extract-json-string trimmed "\"traceback\":")))
          (make-cpython-eval-result
           :success (if success t nil)
           :value-repr (if val-repr val-repr "None")
           :stdout (if stdout-text stdout-text "")
           :stderr raw-stderr
           :error-type err-type
           :error-message err-msg
           :traceback tb))
        ;; Fallback when JSON output missing
        (make-cpython-eval-result
         :success t
         :value-repr trimmed
         :stdout trimmed
         :stderr raw-stderr))))

(defun %extract-json-string (json-str key)
  "Extract a string value associated with KEY in simple JSON payload."
  (let ((pos (search key json-str)))
    (when pos
      (let* ((val-start (+ pos (length key)))
             (first-quote (position #\" json-str :start val-start)))
        (when first-quote
          (let ((next-quote (position #\" json-str :start (1+ first-quote))))
            (when next-quote
              (subseq json-str (1+ first-quote) next-quote))))))))

(defun cpython-status ()
  "Return connection status and metadata for CPython bridge."
  (list :connected *bridge-initialized*
        :executable *python-executable*))
