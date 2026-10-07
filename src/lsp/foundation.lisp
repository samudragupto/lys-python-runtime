;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Language Server Protocol (LSP) Foundations

(in-package #:lys.lsp)

(defstruct lsp-document
  "Maintains document buffer text and version for language server sessions."
  (uri "" :type string)
  (version 1 :type integer)
  (content "" :type string)
  (parsed-ast nil))

(defparameter *open-documents* (make-hash-table :test #'equal)
  "Active document cache mapped by URI.")

(defun compute-macro-diagnostics (document-content)
  "Analyze DOCUMENT-CONTENT through macro expansion and return compiler diagnostics."
  (let ((diagnostics nil))
    (handler-case
        (let* ((surface (lys.reader:parse-surface-string document-content)))
          (when surface
            (let ((expanded (lys.macros:macroexpand-fixpoint surface)))
              (let ((canonical (lys.transform:desugar-ast expanded)))
                (multiple-value-bind (verified diags) (lys.semantics:resolve-scopes canonical)
                  (declare (ignore verified))
                  (dolist (d diags)
                    (push (list :range (list :line 0 :character 0)
                                :severity 2
                                :message d
                                :source "LYSPYTHON-Semantics")
                          diagnostics)))))))
      (lys.utils:macro-expansion-error (err)
        (push (list :range (list :line 0 :character 0)
                    :severity 1
                    :message (format nil "Macro Expansion Failure: ~A" err)
                    :source "LYSPYTHON-MacroEngine")
              diagnostics))
      (error (err)
        (push (list :range (list :line 0 :character 0)
                    :severity 1
                    :message (format nil "Syntax/Compilation Error: ~A" err)
                    :source "LYSPYTHON-Compiler")
              diagnostics)))
    diagnostics))

(defun expand-macro-action (source-snippet)
  "Generate a code-action payload providing inline macro expansion for SOURCE-SNIPPET."
  (let* ((surface (lys.reader:parse-surface-string source-snippet))
         (expanded (lys.macros:macroexpand-fixpoint surface))
         (canonical (lys.transform:desugar-ast expanded))
         (lowered (lys.lowering:lower-canonical-ast canonical)))
    (list :title "Expand LYSPYTHON Macro"
          :kind "refactor.rewrite"
          :replacement (lys.lowering:lowered-ir-payload lowered))))

(defun handle-request (method params)
  "Dispatch LSP JSON-RPC requests to appropriate handler."
  (cond
    ((string= method "initialize")
     (list :capabilities
           (list :hoverProvider t
                 :codeActionProvider t
                 :definitionProvider t)))
    ((string= method "textDocument/didOpen")
     (let ((uri (getf params :uri))
           (text (getf params :text)))
       (setf (gethash uri *open-documents*)
             (make-lsp-document :uri uri :content text))
       (list :diagnostics (compute-macro-diagnostics text))))
    (t
     nil)))

(defun start-server ()
  "Start headless LSP server listening on standard I/O streams."
  (lys.utils:log-info "LYSPYTHON LSP Server initialized on stdio.")
  t)
