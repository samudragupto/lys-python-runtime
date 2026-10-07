;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: AST Normalization and Canonical Desugaring

(in-package #:lys.transform)

(defun desugar-ast (node)
  "Lower and normalize a fully expanded Surface AST node into a Canonical AST node."
  (cond
    ((null node) nil)

    ;; Literal
    ((lys.ast.surface:ast-literal-p node)
     (lys.ast.canonical:make-c-literal
      :value (lys.ast.surface:ast-literal-value node)
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Identifier
    ((lys.ast.surface:ast-identifier-p node)
     (lys.ast.canonical:make-c-identifier
      :name (lys.ast.surface:ast-identifier-name node)
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Binary Operation
    ((lys.ast.surface:ast-binary-op-p node)
     (lys.ast.canonical:make-c-binary-op
      :op (lys.ast.surface:ast-binary-op-op node)
      :left (desugar-ast (lys.ast.surface:ast-binary-op-left node))
      :right (desugar-ast (lys.ast.surface:ast-binary-op-right node))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Unary Operation
    ((lys.ast.surface:ast-unary-op-p node)
     (lys.ast.canonical:make-c-unary-op
      :op (lys.ast.surface:ast-unary-op-op node)
      :operand (desugar-ast (lys.ast.surface:ast-unary-op-operand node))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Call
    ((lys.ast.surface:ast-call-p node)
     (lys.ast.canonical:make-c-call
      :callee (desugar-ast (lys.ast.surface:ast-call-callee node))
      :args (mapcar #'desugar-ast (lys.ast.surface:ast-call-args node))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Block
    ((lys.ast.surface:ast-block-p node)
     (lys.ast.canonical:make-c-block
      :statements (mapcar #'desugar-ast (lys.ast.surface:ast-block-statements node))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Assign
    ((lys.ast.surface:ast-assign-p node)
     (lys.ast.canonical:make-c-assign
      :target (desugar-ast (lys.ast.surface:ast-assign-target node))
      :value (desugar-ast (lys.ast.surface:ast-assign-value node))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; If
    ((lys.ast.surface:ast-if-p node)
     (lys.ast.canonical:make-c-if
      :condition (desugar-ast (lys.ast.surface:ast-if-condition node))
      :then (desugar-ast (lys.ast.surface:ast-if-then node))
      :else (when (lys.ast.surface:ast-if-else node)
              (desugar-ast (lys.ast.surface:ast-if-else node)))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; While
    ((lys.ast.surface:ast-while-p node)
     (lys.ast.canonical:make-c-while
      :condition (desugar-ast (lys.ast.surface:ast-while-condition node))
      :body (desugar-ast (lys.ast.surface:ast-while-body node))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Def
    ((lys.ast.surface:ast-def-p node)
     (lys.ast.canonical:make-c-def
      :name (lys.ast.surface:ast-def-name node)
      :params (lys.ast.surface:ast-def-params node)
      :body (desugar-ast (lys.ast.surface:ast-def-body node))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Return
    ((lys.ast.surface:ast-return-p node)
     (lys.ast.canonical:make-c-return
      :value (when (lys.ast.surface:ast-return-value node)
               (desugar-ast (lys.ast.surface:ast-return-value node)))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Try -> Canonical Try-Finally
    ((lys.ast.surface:ast-try-p node)
     (lys.ast.canonical:make-c-try-finally
      :try-body (desugar-ast (lys.ast.surface:ast-try-body node))
      :finally-body (when (lys.ast.surface:ast-try-finally node)
                      (desugar-ast (lys.ast.surface:ast-try-finally node)))
      :line (lys.ast.surface:node-line node)
      :column (lys.ast.surface:node-column node)))

    ;; Already Canonical
    ((lys.ast.canonical:canonical-node-p node)
     node)

    (t
     (error 'lys.utils:lowering-error
            :message (format nil "Unable to desugar unrecognized AST node: ~A" node)))))
