;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Macro Expansion Inspector & AST Diff Visualizer

(in-package #:lys.repl)

(defun inspect-ast (node &optional (stream *standard-output*))
  "Inspect and print detailed internal structure of an AST node."
  (format stream "~&=== AST Node Inspection ===~%")
  (if (null node)
      (format stream "  <NIL AST Node>~%")
      (progn
        (format stream "  Type: ~A~%" (type-of node))
        (format stream "  Serialized Representation:~%    ~S~%"
                (if (lys.ast.surface:ast-node-p node)
                    (lys.ast.surface:serialize-ast node)
                    (if (lys.ast.canonical:canonical-node-p node)
                        (lys.ast.canonical:serialize-canonical-node node)
                        node)))
        (when (lys.ast.surface:ast-node-p node)
          (format stream "  Children Count: ~A~%" (length (lys.ast.surface:ast-children node))))))
  (format stream "===========================~%")
  (force-output stream))

(defun inspect-macro-expansion (source-text &optional (stream *standard-output*))
  "Trace and display the full macro expansion pipeline for SOURCE-TEXT.
   Renders: Source -> Surface AST -> Intermediate Expansion Steps -> Canonical AST -> Lowered Form."
  (format stream "~&=== LYSPYTHON Macro Expansion Inspector ===~%")
  (format stream "Source Input: ~A~%~%" source-text)

  (let* ((surface (lys.reader:parse-surface-string source-text)))
    (format stream "[Stage 1: Surface AST]~%")
    (format stream "  ~S~%~%" (lys.ast.surface:serialize-ast surface))

    (let ((lys.macros:*expansion-trace* nil))
      (let ((expanded (lys.macros:macroexpand-fixpoint surface)))
        (format stream "[Stage 2: Macro Transformations Recorded: ~A step(s)]~%"
                (length lys.macros:*expansion-trace*))

        (if (null lys.macros:*expansion-trace*)
            (format stream "  (No macro transformations triggered; irreducible form)~%~%")
            (dolist (step (reverse lys.macros:*expansion-trace*))
              (format stream "  Step ~A [Macro: ~A]:~%"
                      (lys.macros:trace-step-step-number step)
                      (lys.macros:trace-step-macro-name step))
              (format stream "    Before: ~S~%"
                      (lys.ast.surface:serialize-ast (lys.macros:trace-step-before step)))
              (format stream "    After:  ~S~%~%"
                      (lys.ast.surface:serialize-ast (lys.macros:trace-step-after step)))))

        (format stream "[Stage 3: Canonical Desugared AST]~%")
        (let ((canonical (lys.transform:desugar-ast expanded)))
          (format stream "  ~S~%~%" (lys.ast.canonical:serialize-canonical-node canonical))

          (format stream "[Stage 4: Lowered CPython Representation]~%")
          (let ((lowered (lys.lowering:lower-canonical-ast canonical)))
            (format stream "~A~%" (lys.lowering:lowered-ir-payload lowered)))))))
  (format stream "===========================================~%")
  (force-output stream))
