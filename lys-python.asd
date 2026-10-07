;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; System Definition File (ASDF)

(asdf:defsystem "lys-python"
  :version "0.1.0"
  :author "LYSPYTHON Contributors <research@lyspython.org>"
  :maintainer "LYSPYTHON Core Architecture Group"
  :license "Apache-2.0"
  :description "A Lisp-Macro-Defined Python Runtime and Interactive REPL"
  :long-description
  "LYSPYTHON establishes Common Lisp as an active meta-language definition layer
   governing Python semantics. Surface Python constructs are ingested into a
   Surface AST, expanded and transformed via Common Lisp macros, desugared into
   a Canonical AST, and lowered for execution on CPython via foreign C-API bindings."
  :homepage "https://github.com/samudragupto/lys-python-runtime"
  :bug-tracker "https://github.com/samudragupto/lys-python-runtime/issues"
  :source-control (:git "https://github.com/samudragupto/lys-python-runtime.git")
  :depends-on (#:cffi
               #:alexandria
               #:uiop)
  :serial t
  :components
  ((:module "src"
    :components
    ((:module "core"
      :serial t
      :components ((:file "packages")
                   (:file "kernel")))
     (:module "config"
      :components ((:file "config")))
     (:module "utils"
      :serial t
      :components ((:file "errors")
                   (:file "logging")))
     (:module "ast"
      :serial t
      :components ((:file "surface")
                   (:file "canonical")))
     (:module "reader"
      :serial t
      :components ((:file "tokens")
                   (:file "parser")))
     (:module "macros"
      :serial t
      :components ((:file "registry")
                   (:file "engine")
                   (:file "builtin")))
     (:module "transform"
      :components ((:file "desugar")))
     (:module "semantics"
      :components ((:file "analyzer")))
     (:module "lowering"
      :components ((:file "lower")))
     (:module "bridge"
      :components ((:file "cpython")))
     (:module "env"
      :components ((:file "namespaces")))
     (:module "runtime"
      :components ((:file "eval")))
     (:module "repl"
      :serial t
      :components ((:file "history")
                   (:file "inspector")
                   (:file "core")))
     (:module "cli"
      :components ((:file "main")))
     (:module "lsp"
      :components ((:file "foundation")))
     (:module "extensions"
      :components ((:file "sandbox"))))))
  :in-order-to ((asdf:test-op (asdf:test-op "lys-python/tests"))))

(asdf:defsystem "lys-python/tests"
  :version "0.1.0"
  :author "LYSPYTHON Contributors"
  :license "Apache-2.0"
  :description "Automated test suite for LYSPYTHON"
  :depends-on (#:lys-python)
  :serial t
  :components
  ((:module "tests"
    :serial t
    :components ((:file "packages")
                 (:module "unit"
                  :serial t
                  :components ((:file "test_ast")
                               (:file "test_macro_engine")
                               (:file "test_desugar")))
                 (:module "integration"
                  :components ((:file "test_pipeline")))
                 (:module "research"
                  :components ((:file "test_semantic_inversion")))
                 (:file "run_tests"))))
  :perform (asdf:test-op (op c)
             (uiop:symbol-call :lys.tests :run-all-tests)))
