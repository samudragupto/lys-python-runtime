;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Unified Evaluation Pipeline

(in-package #:lys.runtime)

(defstruct pipeline-result
  "Encapsulates the end-to-end outcome of traversing the LYSPYTHON compilation pipeline."
  (value nil)
  (value-repr "None" :type string)
  (surface-ast nil)
  (expanded-ast nil)
  (canonical-ast nil)
  (expansion-trace nil :type list)
  (lowered-ir nil)
  (stdout "" :type string)
  (stderr "" :type string)
  (success t :type boolean)
  (diagnostics nil :type list)
  (error-info nil))

(defun eval-surface-ast (surface-ast &key (env lys.env:*global-environment*))
  "Execute SURFACE-AST through the full LYSPYTHON pipeline:
   Surface AST -> Macro Expansion -> Canonical AST -> Semantic Analysis -> Lowering -> CPython Evaluation."
  (unless lys.core:*kernel-initialized-p*
    (lys.core:initialize-kernel :mode lys.config:*runtime-mode*))

  (let ((lys.macros:*expansion-trace* nil)
        (result (make-pipeline-result :surface-ast surface-ast)))

    (handler-case
        (progn
          ;; Phase 1: Macro Expansion (Fixed-Point)
          (when (eq lys.config:*runtime-mode* :verbose)
            (lys.utils:log-trace "MACRO-EXPAND" "Initiating fixed-point macro expansion..."))

          (let ((expanded (lys.macros:macroexpand-fixpoint surface-ast env)))
            (setf (pipeline-result-expanded-ast result) expanded)
            (setf (pipeline-result-expansion-trace result) (reverse lys.macros:*expansion-trace*))

            ;; Phase 2: Desugaring & Normalization into Canonical AST
            (when (eq lys.config:*runtime-mode* :verbose)
              (lys.utils:log-trace "DESUGAR" "Lowering to Canonical AST..."))

            (let ((canonical (lys.transform:desugar-ast expanded)))
              (setf (pipeline-result-canonical-ast result) canonical)

              ;; Phase 3: Semantic Analysis and Scope Validation
              (when (eq lys.config:*runtime-mode* :verbose)
                (lys.utils:log-trace "SEMANTICS" "Analyzing scope bindings and hygiene..."))

              (multiple-value-bind (verified-ast diags) (lys.semantics:resolve-scopes canonical)
                (declare (ignore verified-ast))
                (setf (pipeline-result-diagnostics result) diags)

                ;; Phase 4: Lowering to CPython IR
                (when (eq lys.config:*runtime-mode* :verbose)
                  (lys.utils:log-trace "LOWER" "Generating CPython-callable representation..."))

                (let ((lowered (lys.lowering:lower-canonical-ast canonical)))
                  (setf (pipeline-result-lowered-ir result) lowered)

                  ;; Phase 5: Foreign Execution in CPython
                  (when (eq lys.config:*runtime-mode* :verbose)
                    (lys.utils:log-trace "CPYTHON-EXEC" "Dispatching to CPython execution bridge..."))

                  (let ((bridge-res (lys.bridge:eval-in-cpython lowered)))
                    (setf (pipeline-result-success result) (lys.bridge:cpython-eval-result-success bridge-res))
                    (setf (pipeline-result-value-repr result) (lys.bridge:cpython-eval-result-value-repr bridge-res))
                    (setf (pipeline-result-stdout result) (lys.bridge:cpython-eval-result-stdout bridge-res))
                    (setf (pipeline-result-stderr result) (lys.bridge:cpython-eval-result-stderr bridge-res))

                    (unless (pipeline-result-success result)
                      (setf (pipeline-result-error-info result)
                            (format nil "~A: ~A"
                                    (lys.bridge:cpython-eval-result-error-type bridge-res)
                                    (lys.bridge:cpython-eval-result-error-message bridge-res))))

                    result))))))
      (error (err)
        (setf (pipeline-result-success result) nil)
        (setf (pipeline-result-error-info result) (format nil "~A" err))
        result))))

(defun eval-surface-code (source-text &key (env lys.env:*global-environment*))
  "Ingest SOURCE-TEXT, parse to Surface AST, and evaluate through the pipeline."
  (let ((surface-ast (lys.reader:parse-surface-string source-text)))
    (if surface-ast
        (eval-surface-ast surface-ast :env env)
        (make-pipeline-result :success t :value-repr "None"))))
