;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: REPL Command History and Session Records

(in-package #:lys.repl)

(defstruct history-entry
  "Records a single evaluation transaction in the interactive REPL."
  (index 1 :type integer)
  (source "" :type string)
  (success t :type boolean)
  (result-repr "None" :type string)
  (timestamp 0 :type integer))

(defparameter *repl-history* nil
  "List of historic evaluation transactions in reverse chronological order.")

(defparameter *history-counter* 0
  "Monotonically increasing transaction counter.")

(defparameter *history-file* ".lys_history"
  "Default file path for saving persistent REPL command history.")

(defun record-history-entry (source success result-repr)
  "Append an evaluation transaction to the active REPL history."
  (incf *history-counter*)
  (let ((entry (make-history-entry
                :index *history-counter*
                :source source
                :success success
                :result-repr result-repr
                :timestamp (get-universal-time))))
    (push entry *repl-history*)
    entry))

(defun list-history (&optional (count 10))
  "Return up to COUNT most recent history entries in chronological order."
  (let ((recent (subseq *repl-history* 0 (min count (length *repl-history*)))))
    (nreverse recent)))

(defun clear-history ()
  "Clear the active in-memory REPL history."
  (setf *repl-history* nil)
  (setf *history-counter* 0)
  t)

(defun save-history-to-file (&optional (filepath *history-file*))
  "Persist REPL commands to FILEPATH."
  (with-open-file (out filepath :direction :output :if-exists :supersede :if-does-not-exist :create)
    (dolist (entry (reverse *repl-history*))
      (write-line (history-entry-source entry) out)))
  t)
