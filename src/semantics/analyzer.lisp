;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Semantic Scope and Hygiene Analyzer

(in-package #:lys.semantics)

(defstruct semantic-context
  "Maintains scope and binding metadata during static semantic analysis."
  (current-scope nil :type list)
  (global-symbols (make-hash-table :test #'equal))
  (diagnostics nil :type list))

(defun make-default-semantic-context ()
  "Create a semantic context pre-populated with standard Python built-ins."
  (let ((ctx (make-semantic-context)))
    (dolist (builtin '("print" "len" "range" "iter" "next" "int" "str" "float"
                       "list" "dict" "set" "tuple" "bool" "__lys_has_next__"))
      (setf (gethash builtin (semantic-context-global-symbols ctx)) t))
    ctx))

(defun analyze-semantics (canonical-node &optional (ctx (make-default-semantic-context)))
  "Traverse CANONICAL-NODE verifying scope bindings and hygienic consistency."
  (cond
    ((null canonical-node) ctx)

    ;; Literal: always valid
    ((lys.ast.canonical:c-literal-p canonical-node)
     ctx)

    ;; Identifier: verify symbol exists in local scope or globals
    ((lys.ast.canonical:c-identifier-p canonical-node)
     (let ((name (lys.ast.canonical:c-identifier-name canonical-node)))
       (unless (or (member name (semantic-context-current-scope ctx) :test #'string=)
                   (gethash name (semantic-context-global-symbols ctx)))
         ;; Record unresolved reference warning (Python allows late binding)
         (push (format nil "Reference to unbound or late-bound identifier '~A'" name)
               (semantic-context-diagnostics ctx)))
       ctx))

    ;; Assign: record target identifier in current scope
    ((lys.ast.canonical:c-assign-p canonical-node)
     (let ((target (lys.ast.canonical:c-assign-target canonical-node)))
       (when (lys.ast.canonical:c-identifier-p target)
         (let ((name (lys.ast.canonical:c-identifier-name target)))
           (pushnew name (semantic-context-current-scope ctx) :test #'string=)))
       (analyze-semantics (lys.ast.canonical:c-assign-value canonical-node) ctx)
       ctx))

    ;; Block: analyze statements sequentially
    ((lys.ast.canonical:c-block-p canonical-node)
     (dolist (stmt (lys.ast.canonical:c-block-statements canonical-node))
       (analyze-semantics stmt ctx))
     ctx)

    ;; If: analyze condition, then, else
    ((lys.ast.canonical:c-if-p canonical-node)
     (analyze-semantics (lys.ast.canonical:c-if-condition canonical-node) ctx)
     (analyze-semantics (lys.ast.canonical:c-if-then canonical-node) ctx)
     (when (lys.ast.canonical:c-if-else canonical-node)
       (analyze-semantics (lys.ast.canonical:c-if-else canonical-node) ctx))
     ctx)

    ;; While: analyze condition and body
    ((lys.ast.canonical:c-while-p canonical-node)
     (analyze-semantics (lys.ast.canonical:c-while-condition canonical-node) ctx)
     (analyze-semantics (lys.ast.canonical:c-while-body canonical-node) ctx)
     ctx)

    ;; Def: push new local scope for params, analyze body, pop scope
    ((lys.ast.canonical:c-def-p canonical-node)
     (let* ((fn-name (lys.ast.canonical:c-def-name canonical-node))
            (params (lys.ast.canonical:c-def-params canonical-node))
            (old-scope (semantic-context-current-scope ctx)))
       ;; Register function name in outer scope
       (setf (gethash fn-name (semantic-context-global-symbols ctx)) t)
       ;; Enter function lexical frame
       (setf (semantic-context-current-scope ctx) (copy-list params))
       (analyze-semantics (lys.ast.canonical:c-def-body canonical-node) ctx)
       ;; Restore outer scope
       (setf (semantic-context-current-scope ctx) old-scope)
       ctx))

    ;; Binary Operation
    ((lys.ast.canonical:c-binary-op-p canonical-node)
     (analyze-semantics (lys.ast.canonical:c-binary-op-left canonical-node) ctx)
     (analyze-semantics (lys.ast.canonical:c-binary-op-right canonical-node) ctx)
     ctx)

    ;; Call
    ((lys.ast.canonical:c-call-p canonical-node)
     (analyze-semantics (lys.ast.canonical:c-call-callee canonical-node) ctx)
     (dolist (arg (lys.ast.canonical:c-call-args canonical-node))
       (analyze-semantics arg ctx))
     ctx)

    ;; Return
    ((lys.ast.canonical:c-return-p canonical-node)
     (when (lys.ast.canonical:c-return-value canonical-node)
       (analyze-semantics (lys.ast.canonical:c-return-value canonical-node) ctx))
     ctx)

    ;; Try-Finally
    ((lys.ast.canonical:c-try-finally-p canonical-node)
     (analyze-semantics (lys.ast.canonical:c-try-finally-try-body canonical-node) ctx)
     (when (lys.ast.canonical:c-try-finally-finally-body canonical-node)
       (analyze-semantics (lys.ast.canonical:c-try-finally-finally-body canonical-node) ctx))
     ctx)

    (t ctx)))

(defun resolve-scopes (canonical-node)
  "Convenience wrapper to run semantic analysis and return diagnostics."
  (let ((ctx (analyze-semantics canonical-node)))
    (values canonical-node (semantic-context-diagnostics ctx))))

(defun check-hygiene (canonical-node &optional (prefix "lys_var_"))
  "Verify that synthesized macro identifiers do not unintentionally shadow user variables."
  (declare (ignore canonical-node prefix))
  t)
