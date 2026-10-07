;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Package Definitions Subsystem

(defpackage #:lys.config
  (:use #:cl)
  (:export #:*version*
           #:*runtime-mode*
           #:*max-macro-expansion-depth*
           #:*trace-expansions-p*
           #:*cpython-shared-library-path*
           #:*tree-sitter-library-path*
           #:runtime-mode-p
           #:set-runtime-mode
           #:valid-runtime-modes))

(defpackage #:lys.utils
  (:use #:cl)
  (:export #:lys-condition
           #:lys-error
           #:syntax-error
           #:macro-expansion-error
           #:expansion-cycle-detected
           #:expansion-depth-exceeded
           #:lowering-error
           #:cpython-bridge-error
           #:log-info
           #:log-warn
           #:log-error
           #:log-trace
           #:with-indent
           #:format-ast-node
           #:print-ast-tree
           #:make-unique-identifier))

(defpackage #:lys.ast.surface
  (:use #:cl)
  (:export #:ast-node
           #:ast-surface-node
           #:node-line
           #:node-column
           #:node-kind
           ;; Expressions
           #:ast-literal
           #:ast-literal-value
           #:ast-identifier
           #:ast-identifier-name
           #:ast-binary-op
           #:ast-binary-op-op
           #:ast-binary-op-left
           #:ast-binary-op-right
           #:ast-unary-op
           #:ast-unary-op-op
           #:ast-unary-op-operand
           #:ast-call
           #:ast-call-callee
           #:ast-call-args
           #:ast-call-kwargs
           #:ast-attribute
           #:ast-attribute-value
           #:ast-attribute-attr
           #:ast-subscript
           #:ast-subscript-value
           #:ast-subscript-slice
           ;; Statements
           #:ast-block
           #:ast-block-statements
           #:ast-assign
           #:ast-assign-target
           #:ast-assign-value
           #:ast-aug-assign
           #:ast-aug-assign-op
           #:ast-aug-assign-target
           #:ast-aug-assign-value
           #:ast-if
           #:ast-if-condition
           #:ast-if-then
           #:ast-if-else
           #:ast-while
           #:ast-while-condition
           #:ast-while-body
           #:ast-while-else
           #:ast-for
           #:ast-for-target
           #:ast-for-iterable
           #:ast-for-body
           #:ast-for-else
           #:ast-def
           #:ast-def-name
           #:ast-def-params
           #:ast-def-body
           #:ast-def-decorators
           #:ast-class
           #:ast-class-name
           #:ast-class-bases
           #:ast-class-body
           #:ast-return
           #:ast-return-value
           #:ast-try
           #:ast-try-body
           #:ast-try-handlers
           #:ast-try-else
           #:ast-try-finally
           #:ast-with
           #:ast-with-items
           #:ast-with-body
           ;; Constructors and helpers
           #:make-surface-node
           #:make-ast-literal
           #:make-ast-identifier
           #:make-ast-binary-op
           #:make-ast-unary-op
           #:make-ast-call
           #:make-ast-attribute
           #:make-ast-subscript
           #:make-ast-block
           #:make-ast-assign
           #:make-ast-aug-assign
           #:make-ast-if
           #:make-ast-while
           #:make-ast-for
           #:make-ast-def
           #:make-ast-class
           #:make-ast-return
           #:make-ast-try
           #:make-ast-with
           #:ast-node-p
           #:ast-literal-p
           #:ast-identifier-p
           #:ast-binary-op-p
           #:ast-unary-op-p
           #:ast-call-p
           #:ast-attribute-p
           #:ast-subscript-p
           #:ast-block-p
           #:ast-assign-p
           #:ast-aug-assign-p
           #:ast-if-p
           #:ast-while-p
           #:ast-for-p
           #:ast-def-p
           #:ast-class-p
           #:ast-return-p
           #:ast-try-p
           #:ast-with-p
           #:ast-children
           #:serialize-ast))

(defpackage #:lys.ast.canonical
  (:use #:cl)
  (:export #:ast-canonical-node
           #:c-node-kind
           #:c-literal
           #:c-literal-value
           #:c-identifier
           #:c-identifier-name
           #:c-binary-op
           #:c-binary-op-op
           #:c-binary-op-left
           #:c-binary-op-right
           #:c-unary-op
           #:c-unary-op-op
           #:c-unary-op-operand
           #:c-call
           #:c-call-callee
           #:c-call-args
           #:c-call-kwargs
           #:c-block
           #:c-block-statements
           #:c-assign
           #:c-assign-target
           #:c-assign-value
           #:c-if
           #:c-if-condition
           #:c-if-then
           #:c-if-else
           #:c-while
           #:c-while-condition
           #:c-while-body
           #:c-def
           #:c-def-name
           #:c-def-params
           #:c-def-body
           #:c-return
           #:c-return-value
           #:c-try-finally
           #:c-try-finally-try-body
           #:c-try-finally-finally-body
           #:make-c-literal
           #:make-c-identifier
           #:make-c-binary-op
           #:make-c-unary-op
           #:make-c-call
           #:make-c-block
           #:make-c-assign
           #:make-c-if
           #:make-c-while
           #:make-c-def
           #:make-c-return
           #:make-c-try-finally
           #:c-literal-p
           #:c-identifier-p
           #:c-binary-op-p
           #:c-unary-op-p
           #:c-call-p
           #:c-block-p
           #:c-assign-p
           #:c-if-p
           #:c-while-p
           #:c-def-p
           #:c-return-p
           #:c-try-finally-p
           #:canonical-node-p
           #:serialize-canonical-node))

(defpackage #:lys.reader
  (:use #:cl)
  (:export #:parse-surface-string
           #:parse-surface-sexpr
           #:tokenize-surface-string
           #:reader-syntax-error))

(defpackage #:lys.macros
  (:use #:cl)
  (:shadow #:macroexpand-1)
  (:export #:macro-definition
           #:make-macro-definition
           #:macro-definition-p
           #:macro-definition-name
           #:macro-definition-priority
           #:macro-definition-documentation
           #:macro-definition-expander
           #:macro-definition-version
           #:macro-name
           #:macro-priority
           #:macro-documentation
           #:macro-expander
           #:macro-version
           #:*global-macro-registry*
           #:register-macro
           #:lookup-macro
           #:unregister-macro
           #:list-macros
           #:clear-macros
           #:define-python-macro
           #:macroexpand-1
           #:macroexpand-all
           #:macroexpand-fixpoint
           #:*expansion-trace*
           #:trace-step
           #:make-trace-step
           #:trace-step-p
           #:trace-step-step-number
           #:trace-step-before
           #:trace-step-after
           #:trace-step-macro-name
           #:load-builtin-macros))

(defpackage #:lys.transform
  (:use #:cl)
  (:export #:desugar-ast
           #:desugar-for-to-while
           #:desugar-with-to-try-finally
           #:desugar-aug-assign))

(defpackage #:lys.semantics
  (:use #:cl)
  (:export #:semantic-context
           #:analyze-semantics
           #:resolve-scopes
           #:check-hygiene))

(defpackage #:lys.lowering
  (:use #:cl)
  (:export #:lower-canonical-ast
           #:lowered-ir
           #:make-lowered-ir
           #:lowered-ir-p
           #:lowered-ir-payload
           #:lowered-ir-type
           #:ir-type
           #:ir-payload))

(defpackage #:lys.bridge
  (:use #:cl)
  (:export #:initialize-cpython-bridge
           #:shutdown-cpython-bridge
           #:cpython-bridge-initialized-p
           #:eval-in-cpython
           #:cpython-eval-result
           #:make-cpython-eval-result
           #:cpython-eval-result-p
           #:cpython-eval-result-success
           #:cpython-eval-result-value-repr
           #:cpython-eval-result-stdout
           #:cpython-eval-result-stderr
           #:cpython-eval-result-error-type
           #:cpython-eval-result-error-message
           #:cpython-eval-result-traceback
           #:pyobject-handle
           #:make-pyobject-handle
           #:pyobject-handle-p
           #:pyobject-handle-pointer
           #:pyobject-handle-type-name
           #:pyobject-handle-ref-count
           #:pyobject-pointer
           #:cpython-status))

(defpackage #:lys.env
  (:use #:cl)
  (:export #:environment
           #:make-environment
           #:env-lookup
           #:env-bind
           #:env-push-frame
           #:env-pop-frame
           #:*global-environment*))

(defpackage #:lys.runtime
  (:use #:cl)
  (:export #:eval-surface-code
           #:eval-surface-ast
           #:pipeline-result
           #:make-pipeline-result
           #:pipeline-result-p
           #:pipeline-result-value
           #:pipeline-result-value-repr
           #:pipeline-result-surface-ast
           #:pipeline-result-expanded-ast
           #:pipeline-result-canonical-ast
           #:pipeline-result-expansion-trace
           #:pipeline-result-lowered-ir
           #:pipeline-result-stdout
           #:pipeline-result-stderr
           #:pipeline-result-success
           #:pipeline-result-diagnostics
           #:pipeline-result-error-info))

(defpackage #:lys.repl
  (:use #:cl)
  (:nicknames #:lys-python.repl)
  (:export #:start-repl
           #:repl-session
           #:repl-eval-line
           #:inspect-ast
           #:inspect-macro-expansion))

(defpackage #:lys.lsp
  (:use #:cl)
  (:export #:start-server
           #:handle-request
           #:compute-macro-diagnostics
           #:expand-macro-action))

(defpackage #:lys.extensions
  (:use #:cl)
  (:export #:sandbox-environment
           #:run-in-sandbox))

(defpackage #:lys.core
  (:use #:cl)
  (:export #:initialize-kernel
           #:shutdown-kernel
           #:reset-kernel-state
           #:kernel-status
           #:*kernel-initialized-p*))

(defpackage #:lys.cli
  (:use #:cl)
  (:export #:main))
