;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Condition and Error Hierarchy

(in-package #:lys.utils)

(define-condition lys-condition (condition)
  ((message :initarg :message :reader condition-message :initform "LYSPYTHON runtime condition"))
  (:report (lambda (condition stream)
             (format stream "[LYSPYTHON]: ~A" (condition-message condition)))))

(define-condition lys-error (error lys-condition)
  ()
  (:report (lambda (condition stream)
             (format stream "[LYSPYTHON ERROR]: ~A" (condition-message condition)))))

(define-condition syntax-error (lys-error)
  ((line :initarg :line :reader syntax-error-line :initform nil)
   (column :initarg :column :reader syntax-error-column :initform nil)
   (source-snippet :initarg :source-snippet :reader syntax-error-snippet :initform nil))
  (:report (lambda (condition stream)
             (format stream "[LYSPYTHON SYNTAX ERROR] at line ~A, col ~A: ~A~@[~%Snippet: ~A~]"
                     (syntax-error-line condition)
                     (syntax-error-column condition)
                     (condition-message condition)
                     (syntax-error-snippet condition)))))

(define-condition macro-expansion-error (lys-error)
  ((macro-name :initarg :macro-name :reader error-macro-name :initform nil)
   (ast-node :initarg :ast-node :reader error-ast-node :initform nil))
  (:report (lambda (condition stream)
             (format stream "[LYSPYTHON MACRO ERROR] in macro ~A: ~A"
                     (error-macro-name condition)
                     (condition-message condition)))))

(define-condition expansion-depth-exceeded (macro-expansion-error)
  ((depth :initarg :depth :reader exceeded-depth :initform nil))
  (:report (lambda (condition stream)
             (format stream "[LYSPYTHON RECURSION ERROR] Maximum macro expansion depth (~A) exceeded in macro ~A."
                     (exceeded-depth condition)
                     (error-macro-name condition)))))

(define-condition expansion-cycle-detected (macro-expansion-error)
  ((cycle-node :initarg :cycle-node :reader cycle-node :initform nil))
  (:report (lambda (condition stream)
             (format stream "[LYSPYTHON CYCLE DETECTED] Cyclical macro rewrite encountered in macro ~A."
                     (error-macro-name condition)))))

(define-condition lowering-error (lys-error)
  ((canonical-node :initarg :canonical-node :reader lowering-node :initform nil))
  (:report (lambda (condition stream)
             (format stream "[LYSPYTHON LOWERING ERROR]: ~A" (condition-message condition)))))

(define-condition cpython-bridge-error (lys-error)
  ((python-exception-type :initarg :python-type :reader cpython-error-type :initform nil)
   (traceback :initarg :traceback :reader cpython-traceback :initform nil))
  (:report (lambda (condition stream)
             (format stream "[CPYTHON EXCEPTION ~A]: ~A~@[~%Traceback:~%~A~]"
                     (cpython-error-type condition)
                     (condition-message condition)
                     (cpython-traceback condition)))))
