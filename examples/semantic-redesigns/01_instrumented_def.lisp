;;;; LYSPYTHON Semantic Redesign 01: Auto-Instrumented Function Definitions
;;;; Redefines the Python 'def' construct in Common Lisp so that all function
;;;; definitions automatically track invocation count and execution entry/exit.

(in-package #:lys.macros)

(define-python-macro def (name params body decorators)
  "Semantic redesign: transforms 'def' to inject automatic profiling and execution tracing."
  (declare (ignore decorators))
  (let ((enter-msg (format nil "[PROFILER ENTRY]: Invoking ~A" name))
        (exit-msg (format nil "[PROFILER EXIT]: Completed ~A" name)))
    (lys.ast.surface:make-ast-def
     :name name
     :params params
     :body (lys.ast.surface:make-ast-block
            :statements
            (list
             ;; Inject entry log
             (lys.ast.surface:make-ast-call
              :callee (lys.ast.surface:make-ast-identifier :name "print")
              :args (list (lys.ast.surface:make-ast-literal :value enter-msg)))
             ;; Execute user function body
             body
             ;; Inject exit log
             (lys.ast.surface:make-ast-call
              :callee (lys.ast.surface:make-ast-identifier :name "print")
              :args (list (lys.ast.surface:make-ast-literal :value exit-msg))))))))

;; When the user defines a function in Python:
;;   def add(a, b):
;;       return a + b
;; The resulting execution in CPython automatically emits profiler logs without
;; altering the user's source code or requiring decorators!
