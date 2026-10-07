;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Built-in Python Semantic Macros

(in-package #:lys.macros)

(defun load-builtin-macros ()
  "Register the baseline suite of Common Lisp macros defining standard Python semantics."
  (lys.utils:log-info "Registering baseline semantic macros for Python constructs...")

  ;; Augmented Assignment Macro: desugars (aug-assign op target value) -> (assign target (binop op target value))
  (define-python-macro aug-assign (op target value)
    "Desugars augmented assignments (x += 1) into atomic binary operations (x = x + 1)."
    (lys.ast.surface:make-ast-assign
     :target target
     :value (lys.ast.surface:make-ast-binary-op
             :op op
             :left target
             :right value)))

  ;; For Loop Macro: desugars (for target iter body) -> iterator binding + while loop
  (define-python-macro for (target iterable body else-clause)
    "Desugars a Python for-in loop into iterator initialization and while iteration."
    (let ((iter-var (lys.utils:make-unique-identifier "iter_"))
          (val-var (lys.utils:make-unique-identifier "next_val_")))
      (declare (ignore else-clause))
      ;; (block
      ;;   (assign iter_var (call iter (iterable)))
      ;;   (while (call has_next (iter_var))
      ;;     (block
      ;;       (assign target (call next (iter_var)))
      ;;       body)))
      (lys.ast.surface:make-ast-block
       :statements
       (list
        (lys.ast.surface:make-ast-assign
         :target (lys.ast.surface:make-ast-identifier :name iter-var)
         :value (lys.ast.surface:make-ast-call
                 :callee (lys.ast.surface:make-ast-identifier :name "iter")
                 :args (list iterable)))
        (lys.ast.surface:make-ast-while
         :condition (lys.ast.surface:make-ast-call
                     :callee (lys.ast.surface:make-ast-identifier :name "__lys_has_next__")
                     :args (list (lys.ast.surface:make-ast-identifier :name iter-var)))
         :body (lys.ast.surface:make-ast-block
                :statements
                (list
                 (lys.ast.surface:make-ast-assign
                  :target target
                  :value (lys.ast.surface:make-ast-call
                          :callee (lys.ast.surface:make-ast-identifier :name "next")
                          :args (list (lys.ast.surface:make-ast-identifier :name iter-var))))
                 body)))))))

  ;; With Context Manager Macro: desugars (with (mgr) body) -> enter, try, exit
  (define-python-macro with (items body)
    "Desugars Python with statement into __enter__ and try-finally __exit__ calls."
    (let* ((mgr (first items))
           (mgr-var (lys.utils:make-unique-identifier "ctx_mgr_")))
      (lys.ast.surface:make-ast-block
       :statements
       (list
        (lys.ast.surface:make-ast-assign
         :target (lys.ast.surface:make-ast-identifier :name mgr-var)
         :value mgr)
        (lys.ast.surface:make-ast-call
         :callee (lys.ast.surface:make-ast-attribute
                  :value (lys.ast.surface:make-ast-identifier :name mgr-var)
                  :attr "__enter__")
         :args nil)
        (lys.ast.surface:make-ast-try
         :body body
         :finally (lys.ast.surface:make-ast-call
                   :callee (lys.ast.surface:make-ast-attribute
                            :value (lys.ast.surface:make-ast-identifier :name mgr-var)
                            :attr "__exit__")
                   :args (list (lys.ast.surface:make-ast-literal :value nil)
                               (lys.ast.surface:make-ast-literal :value nil)
                               (lys.ast.surface:make-ast-literal :value nil))))))))

  (lys.utils:log-info "Baseline Python semantic macros loaded successfully.")
  t)
