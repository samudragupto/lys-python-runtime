;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Command Line Interface Entry Point

(in-package #:lys.cli)

(defun print-usage ()
  (format t "~&LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL~%")
  (format t "Usage: lyspython [OPTIONS] [FILE]~%~%")
  (format t "Options:~%")
  (format t "  --help              Display this command line help~%")
  (format t "  --version           Display system version information~%")
  (format t "  --repl              Launch the interactive REPL (default)~%")
  (format t "  --mode <mode>       Execution mode (:normal, :macro-trace, :ast-trace, :verbose, :research)~%")
  (format t "  --eval <code>       Evaluate a surface Python snippet and print result~%")
  (format t "  --inspect <code>    Trace step-by-step macro expansion for snippet~%")
  (format t "  --file <path>       Execute source file through LYSPYTHON pipeline~%")
  (force-output t))

(defun main (&optional (argv (uiop:command-line-arguments)))
  "Main entry point for standalone CLI execution."
  (let ((mode :normal)
        (eval-code nil)
        (inspect-code nil)
        (file-path nil)
        (repl-requested t))

    ;; Argument Parsing Loop
    (loop while argv do
      (let ((arg (pop argv)))
        (cond
          ((string= arg "--help")
           (print-usage)
           (return-from main 0))
          ((string= arg "--version")
           (format t "LYSPYTHON v~A~%" lys.config:*version*)
           (return-from main 0))
          ((string= arg "--mode")
           (when argv
             (setf mode (intern (string-upcase (string-trim ":" (pop argv))) :keyword))))
          ((string= arg "--eval")
           (when argv
             (setf eval-code (pop argv))
             (setf repl-requested nil)))
          ((string= arg "--inspect")
           (when argv
             (setf inspect-code (pop argv))
             (setf repl-requested nil)))
          ((string= arg "--file")
           (when argv
             (setf file-path (pop argv))
             (setf repl-requested nil)))
          ((string= arg "--repl")
           (setf repl-requested t))
          ((and (> (length arg) 0) (char/= (char arg 0) #\-))
           (setf file-path arg)
           (setf repl-requested nil)))))

    ;; Initialize Kernel
    (lys.core:initialize-kernel :mode mode)

    ;; Execute Action
    (cond
      (eval-code
       (let ((res (lys.runtime:eval-surface-code eval-code)))
         (when (> (length (lys.runtime:pipeline-result-stdout res)) 0)
           (format t "~A" (lys.runtime:pipeline-result-stdout res)))
         (format t "~A~%" (lys.runtime:pipeline-result-value-repr res))
         (if (lys.runtime:pipeline-result-success res) 0 1)))

      (inspect-code
       (lys.repl:inspect-macro-expansion inspect-code)
       0)

      (file-path
       (if (uiop:file-exists-p file-path)
           (let* ((content (uiop:read-file-string file-path))
                  (res (lys.runtime:eval-surface-code content)))
             (when (> (length (lys.runtime:pipeline-result-stdout res)) 0)
               (format t "~A" (lys.runtime:pipeline-result-stdout res)))
             (unless (lys.runtime:pipeline-result-success res)
               (format *error-output* "Execution Error: ~A~%"
                       (lys.runtime:pipeline-result-error-info res)))
             (if (lys.runtime:pipeline-result-success res) 0 1))
           (progn
             (format *error-output* "File not found: ~A~%" file-path)
             1)))

      (repl-requested
       (lys.repl:start-repl :mode mode)
       0))))
