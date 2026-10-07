;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Interactive Research REPL

(in-package #:lys.repl)

(defun %print-banner ()
  (format t "~&------------------------------------------------------------~%")
  (format t "LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL~%")
  (format t "Version: ~A  |  Host: Common Lisp  |  Target: CPython~%" lys.config:*version*)
  (format t "Type ':help' for commands, ':mode' to switch modes, ':quit' to exit.~%")
  (format t "------------------------------------------------------------~%~%")
  (force-output t))

(defun %print-help ()
  (format t "~&LYSPYTHON REPL Commands:~%")
  (format t "  :help                  - Display this help message~%")
  (format t "  :mode <name>           - Switch execution mode (:normal, :macro-trace, :ast-trace, :verbose, :research)~%")
  (format t "  :expand <form>         - Perform macro expansion without execution~%")
  (format t "  :inspect <form>        - Display step-by-step macro transformation diffs~%")
  (format t "  :ast <form>            - Inspect Surface and Canonical AST representations~%")
  (format t "  :macros                - List all registered macros, priorities, and versions~%")
  (format t "  :history               - Display recent command execution history~%")
  (format t "  :env                   - Inspect active namespace bindings~%")
  (format t "  :bridge                - Display CPython foreign bridge status~%")
  (format t "  :reset                 - Reset runtime kernel state~%")
  (format t "  :quit / :exit          - Exit the REPL session cleanly~%")
  (force-output t))

(defun start-repl (&key (mode :normal))
  "Launch the interactive LYSPYTHON research REPL."
  (unless lys.core:*kernel-initialized-p*
    (lys.core:initialize-kernel :mode mode))

  (%print-banner)

  (loop
    (format t "lys[~A]> " (string-downcase (symbol-name lys.config:*runtime-mode*)))
    (force-output t)
    (let ((line (read-line *standard-input* nil nil)))
      (unless line
        (format t "~%Exiting LYSPYTHON.~%")
        (return))

      (let ((trimmed (string-trim '(#\Space #\Tab #\Newline #\Return) line)))
        (cond
          ((zerop (length trimmed))
           nil)

          ;; Command: :quit / :exit
          ((or (string= trimmed ":quit") (string= trimmed ":exit"))
           (format t "Exiting LYSPYTHON REPL. Releasing foreign bridge resources.~%")
           (return))

          ;; Command: :help
          ((string= trimmed ":help")
           (%print-help))

          ;; Command: :mode
          ((and (>= (length trimmed) 5) (string= (subseq trimmed 0 5) ":mode"))
           (let* ((arg (string-trim " " (subseq trimmed 5)))
                  (new-mode (intern (string-upcase (string-trim ":" arg)) :keyword)))
             (handler-case
                 (progn
                   (lys.config:set-runtime-mode new-mode)
                   (format t "Runtime mode updated to: ~A~%" new-mode))
               (error (e)
                 (format t "Error: ~A~%" e)))))

          ;; Command: :expand
          ((and (>= (length trimmed) 7) (string= (subseq trimmed 0 7) ":expand"))
           (let* ((code (string-trim " " (subseq trimmed 7)))
                  (surface (lys.reader:parse-surface-string code))
                  (expanded (lys.macros:macroexpand-fixpoint surface)))
             (format t "Surface AST:~%  ~S~%~%" (lys.ast.surface:serialize-ast surface))
             (format t "Expanded AST:~%  ~S~%" (lys.ast.surface:serialize-ast expanded))))

          ;; Command: :inspect
          ((and (>= (length trimmed) 8) (string= (subseq trimmed 0 8) ":inspect"))
           (let ((code (string-trim " " (subseq trimmed 8))))
             (inspect-macro-expansion code)))

          ;; Command: :ast
          ((and (>= (length trimmed) 4) (string= (subseq trimmed 0 4) ":ast"))
           (let* ((code (string-trim " " (subseq trimmed 4)))
                  (surface (lys.reader:parse-surface-string code))
                  (canonical (lys.transform:desugar-ast (lys.macros:macroexpand-fixpoint surface))))
             (inspect-ast surface)
             (inspect-ast canonical)))

          ;; Command: :macros
          ((string= trimmed ":macros")
           (format t "~&Registered Python Semantic Macros:~%")
           (dolist (m (lys.macros:list-macros))
             (format t "  - ~A (priority ~A, v~A): ~A~%"
                     (lys.macros:macro-definition-name m)
                     (lys.macros:macro-definition-priority m)
                     (lys.macros:macro-definition-version m)
                     (lys.macros:macro-definition-documentation m))))

          ;; Command: :history
          ((string= trimmed ":history")
           (format t "~&REPL Command History:~%")
           (dolist (h (list-history 20))
             (format t "  [~A] ~A => ~A~%"
                     (history-entry-index h)
                     (history-entry-source h)
                     (history-entry-result-repr h))))

          ;; Command: :bridge
          ((string= trimmed ":bridge")
           (format t "~&Bridge Status: ~S~%" (lys.bridge:cpython-status)))

          ;; Command: :reset
          ((string= trimmed ":reset")
           (lys.core:reset-kernel-state)
           (format t "Kernel state reset to bootstrap configuration.~%"))

          ;; Standard Evaluation
          (t
           (%repl-evaluate trimmed))))))
  t)

(defun %repl-evaluate (source-text)
  "Evaluate SOURCE-TEXT and render formatted result according to *runtime-mode*."
  (let ((result (lys.runtime:eval-surface-code source-text)))
    (record-history-entry source-text
                          (lys.runtime:pipeline-result-success result)
                          (lys.runtime:pipeline-result-value-repr result))

    ;; In :macro-trace mode, display recorded expansion steps
    (when (or (eq lys.config:*runtime-mode* :macro-trace)
              (eq lys.config:*runtime-mode* :research))
      (let ((trace (lys.runtime:pipeline-result-expansion-trace result)))
        (when trace
          (format t "~&[Macro Expansion Trace: ~A step(s)]~%" (length trace))
          (dolist (step trace)
            (format t "  Step ~A (~A): ~S -> ~S~%"
                    (lys.macros:trace-step-step-number step)
                    (lys.macros:trace-step-macro-name step)
                    (lys.ast.surface:serialize-ast (lys.macros:trace-step-before step))
                    (lys.ast.surface:serialize-ast (lys.macros:trace-step-after step)))))))

    ;; In :ast-trace mode, display Surface and Canonical representations
    (when (or (eq lys.config:*runtime-mode* :ast-trace)
              (eq lys.config:*runtime-mode* :research))
      (format t "~&[Surface AST]   ~S~%"
              (lys.ast.surface:serialize-ast (lys.runtime:pipeline-result-surface-ast result)))
      (format t "[Canonical AST] ~S~%"
              (lys.ast.canonical:serialize-canonical-node (lys.runtime:pipeline-result-canonical-ast result))))

    ;; Print stdout if any
    (when (> (length (lys.runtime:pipeline-result-stdout result)) 0)
      (format t "~A" (lys.runtime:pipeline-result-stdout result)))

    ;; Print evaluation value or error
    (if (lys.runtime:pipeline-result-success result)
        (let ((val-repr (lys.runtime:pipeline-result-value-repr result)))
          (unless (or (string= val-repr "None") (string= val-repr ""))
            (format t "~A~%" val-repr)))
        (format t "Runtime Error: ~A~%" (lys.runtime:pipeline-result-error-info result))))
  (force-output t))
