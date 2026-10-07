;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Unit Test: Macro Registry and Expansion Engine

(in-package #:lys.tests)

(defun test-macro-registration-and-lookup ()
  "Verify macro registration, priority ordering, and lookup."
  (lys.macros:clear-macros)
  (assert (null (lys.macros:lookup-macro :custom-test-op)))

  (lys.macros:register-macro :custom-test-op
                             (lambda (node &optional env)
                               (declare (ignore env))
                               (first (lys.ast.surface:ast-children node)))
                             :priority 10
                             :doc "Test macro")

  (let ((defn (lys.macros:lookup-macro :custom-test-op)))
    (assert (not (null defn)))
    (assert (eq (lys.macros:macro-definition-name defn) :CUSTOM-TEST-OP))
    (assert (= (lys.macros:macro-definition-priority defn) 10))
    (assert (string= (lys.macros:macro-definition-documentation defn) "Test macro"))))

(defun test-macro-expansion-and-trace ()
  "Verify single-step expansion, fixed-point expansion, and trace collection."
  (lys.macros:clear-macros)

  ;; Define a test macro: (aug-assign op target val) -> (assign target (binop op target val))
  (lys.macros:define-python-macro aug-assign (op target val)
    "Test aug-assign rewrite"
    (lys.ast.surface:make-ast-assign
     :target target
     :value (lys.ast.surface:make-ast-binary-op :op op :left target :right val)))

  (let* ((target (lys.ast.surface:make-ast-identifier :name "n"))
         (val (lys.ast.surface:make-ast-literal :value 1))
         (aug-node (lys.ast.surface:make-ast-aug-assign :op :+ :target target :value val)))

    ;; Single-step expansion
    (multiple-value-bind (expanded expanded-p) (lys.macros:macroexpand-1 aug-node)
      (assert expanded-p)
      (assert (lys.ast.surface:ast-assign-p expanded))
      (assert (lys.ast.surface:ast-binary-op-p (lys.ast.surface:ast-assign-value expanded))))

    ;; Fixed-point expansion
    (let ((lys.macros:*expansion-trace* nil))
      (let ((fp (lys.macros:macroexpand-fixpoint aug-node)))
        (assert (lys.ast.surface:ast-assign-p fp))
        (assert (>= (length lys.macros:*expansion-trace*) 1))))))

(defun test-macro-cycle-detection ()
  "Verify that cyclical macro expansions signal expansion-cycle-detected condition."
  (lys.macros:clear-macros)

  ;; Define an intentionally cyclical macro: A -> B -> A
  (lys.macros:define-python-macro cycle-a (child)
    "Cycle A"
    (list :cycle-b child))

  (lys.macros:define-python-macro cycle-b (child)
    "Cycle B"
    (list :cycle-a child))

  (let ((cycle-node (list :cycle-a (lys.ast.surface:make-ast-literal :value 0)))
        (signaled nil))
    (handler-case
        (lys.macros:macroexpand-fixpoint cycle-node)
      (lys.utils:expansion-cycle-detected ()
        (setf signaled t))
      (lys.utils:expansion-depth-exceeded ()
        (setf signaled t)))
    (assert signaled)))
