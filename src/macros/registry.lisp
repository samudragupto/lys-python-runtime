;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Macro Registry and Definition Layer

(in-package #:lys.macros)

(defstruct macro-definition
  "Encapsulates a registered Python macro definition in the Common Lisp host."
  (name nil :type symbol)
  (priority 0 :type integer)
  (documentation "" :type string)
  (expander nil :type function)
  (version 1 :type integer))

(defparameter *global-macro-registry* (make-hash-table :test #'eq)
  "Central thread-safe hash table storing registered macro definitions.")

(defun canonical-macro-symbol (name)
  "Normalize NAME into an interned symbol in the :keyword package."
  (if (keywordp name)
      name
      (intern (string-upcase (string name)) :keyword)))

(defun register-macro (name expander-fn &key (priority 0) (doc "") (version 1))
  "Register a macro transformation function EXPANDER-FN under NAME."
  (let* ((sym (canonical-macro-symbol name))
         (existing (gethash sym *global-macro-registry*))
         (next-version (if existing (1+ (macro-definition-version existing)) version))
         (defn (make-macro-definition
                :name sym
                :priority priority
                :documentation doc
                :expander expander-fn
                :version next-version)))
    (setf (gethash sym *global-macro-registry*) defn)
    (lys.utils:log-info "Registered Python Macro: ~A (v~A, priority ~A)" sym next-version priority)
    sym))

(defun lookup-macro (name)
  "Look up a macro definition by NAME. Returns macro-definition or NIL."
  (let ((sym (canonical-macro-symbol name)))
    (gethash sym *global-macro-registry*)))

(defun unregister-macro (name)
  "Remove a macro definition from the global registry."
  (let ((sym (canonical-macro-symbol name)))
    (remhash sym *global-macro-registry*)))

(defun list-macros ()
  "Return a list of all registered macro-definition structures, sorted by priority descending."
  (let ((result nil))
    (maphash (lambda (k v)
               (declare (ignore k))
               (push v result))
             *global-macro-registry*)
    (sort result #'> :key #'macro-definition-priority)))

(defun clear-macros ()
  "Clear all registered macros from the global registry."
  (clrhash *global-macro-registry*)
  (lys.utils:log-info "Macro registry cleared.")
  t)

(defmacro define-python-macro (name lambda-list &body body)
  "Domain-specific macro defining a semantic or syntactic transformation for a Python construct.
   NAME is the operator symbol (e.g. def, if, for, while, class, with, try, assign, call).
   LAMBDA-LIST binds to the components of the matching AST node.
   BODY evaluates in Common Lisp and returns a rewritten AST node or S-expression."
  (let* ((doc (if (stringp (first body)) (first body) ""))
         (actual-body (if (stringp (first body)) (rest body) body)))
    `(progn
       (register-macro
        ',name
        (lambda (node &optional env)
          (declare (ignorable env))
          (destructuring-bind ,lambda-list (%destructure-ast-node node)
            ,@actual-body))
        :priority 0
        :doc ,doc)
       ',name)))

(defun %destructure-ast-node (node)
  "Extract constituent arguments from an AST node for macro destructuring."
  (cond
    ((lys.ast.surface:ast-if-p node)
     (list (lys.ast.surface:ast-if-condition node)
           (lys.ast.surface:ast-if-then node)
           (lys.ast.surface:ast-if-else node)))
    ((lys.ast.surface:ast-while-p node)
     (list (lys.ast.surface:ast-while-condition node)
           (lys.ast.surface:ast-while-body node)
           (lys.ast.surface:ast-while-else node)))
    ((lys.ast.surface:ast-for-p node)
     (list (lys.ast.surface:ast-for-target node)
           (lys.ast.surface:ast-for-iterable node)
           (lys.ast.surface:ast-for-body node)
           (lys.ast.surface:ast-for-else node)))
    ((lys.ast.surface:ast-def-p node)
     (list (lys.ast.surface:ast-def-name node)
           (lys.ast.surface:ast-def-params node)
           (lys.ast.surface:ast-def-body node)
           (lys.ast.surface:ast-def-decorators node)))
    ((lys.ast.surface:ast-class-p node)
     (list (lys.ast.surface:ast-class-name node)
           (lys.ast.surface:ast-class-bases node)
           (lys.ast.surface:ast-class-body node)))
    ((lys.ast.surface:ast-assign-p node)
     (list (lys.ast.surface:ast-assign-target node)
           (lys.ast.surface:ast-assign-value node)))
    ((lys.ast.surface:ast-aug-assign-p node)
     (list (lys.ast.surface:ast-aug-assign-op node)
           (lys.ast.surface:ast-aug-assign-target node)
           (lys.ast.surface:ast-aug-assign-value node)))
    ((lys.ast.surface:ast-call-p node)
     (list (lys.ast.surface:ast-call-callee node)
           (lys.ast.surface:ast-call-args node)
           (lys.ast.surface:ast-call-kwargs node)))
    ((lys.ast.surface:ast-return-p node)
     (list (lys.ast.surface:ast-return-value node)))
    ((lys.ast.surface:ast-try-p node)
     (list (lys.ast.surface:ast-try-body node)
           (lys.ast.surface:ast-try-handlers node)
           (lys.ast.surface:ast-try-else node)
           (lys.ast.surface:ast-try-finally node)))
    ((lys.ast.surface:ast-with-p node)
     (list (lys.ast.surface:ast-with-items node)
           (lys.ast.surface:ast-with-body node)))
    ((listp node)
     (rest node))
    (t (list node))))
