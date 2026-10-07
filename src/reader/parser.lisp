;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Surface Parser and Ingestion

(in-package #:lys.reader)

(defun parse-surface-sexpr (form &key (line 1) (col 0) (column col))
  "Translate a homoiconic S-expression representation into Surface AST instances."
  (let ((col (or column col)))
    (cond
      ;; Null
      ((null form) nil)

    ;; Literal Numbers, Strings, Booleans
    ((numberp form)
     (lys.ast.surface:make-ast-literal :value form :line line :column col))
    ((stringp form)
     (lys.ast.surface:make-ast-literal :value form :line line :column col))
    ((eq form t)
     (lys.ast.surface:make-ast-literal :value t :line line :column col))
    ((eq form :none)
     (lys.ast.surface:make-ast-literal :value nil :line line :column col))

    ;; Symbol Identifiers
    ((symbolp form)
     (lys.ast.surface:make-ast-identifier :name (string-downcase (symbol-name form))
                                          :line line :column col))

    ;; Structured Forms
    ((listp form)
     (let ((head-sym (if (symbolp (first form))
                         (intern (string-upcase (symbol-name (first form))) :keyword)
                         nil)))
       (case head-sym
         ;; Explicit Tagged Forms
         (:literal
          (lys.ast.surface:make-ast-literal :value (second form) :line line :column col))
         (:id
          (lys.ast.surface:make-ast-identifier :name (string (second form)) :line line :column col))
         (:binop
          (lys.ast.surface:make-ast-binary-op
           :op (intern (string (second form)) :keyword)
           :left (parse-surface-sexpr (third form) :line line :column col)
           :right (parse-surface-sexpr (fourth form) :line line :column col)
           :line line :column col))
         (:unop
          (lys.ast.surface:make-ast-unary-op
           :op (intern (string (second form)) :keyword)
           :operand (parse-surface-sexpr (third form) :line line :column col)
           :line line :column col))
         (:call
          (lys.ast.surface:make-ast-call
           :callee (parse-surface-sexpr (second form) :line line :column col)
           :args (mapcar (lambda (arg) (parse-surface-sexpr arg :line line :column col))
                         (if (listp (third form)) (third form) (cddr form)))
           :line line :column col))
         ((:block :progn)
          (lys.ast.surface:make-ast-block
           :statements (mapcar (lambda (s) (parse-surface-sexpr s :line line :column col)) (rest form))
           :line line :column col))
         ((:assign :set)
          (lys.ast.surface:make-ast-assign
           :target (parse-surface-sexpr (second form) :line line :column col)
           :value (parse-surface-sexpr (third form) :line line :column col)
           :line line :column col))
         (:aug-assign
          (lys.ast.surface:make-ast-aug-assign
           :op (intern (string (second form)) :keyword)
           :target (parse-surface-sexpr (third form) :line line :column col)
           :value (parse-surface-sexpr (fourth form) :line line :column col)
           :line line :column col))
         (:if
          (lys.ast.surface:make-ast-if
           :condition (parse-surface-sexpr (second form) :line line :column col)
           :then (parse-surface-sexpr (third form) :line line :column col)
           :else (when (fourth form) (parse-surface-sexpr (fourth form) :line line :column col))
           :line line :column col))
         (:while
          (lys.ast.surface:make-ast-while
           :condition (parse-surface-sexpr (second form) :line line :column col)
           :body (parse-surface-sexpr (third form) :line line :column col)
           :else (when (fourth form) (parse-surface-sexpr (fourth form) :line line :column col))
           :line line :column col))
         (:for
          (lys.ast.surface:make-ast-for
           :target (parse-surface-sexpr (second form) :line line :column col)
           :iterable (parse-surface-sexpr (third form) :line line :column col)
           :body (parse-surface-sexpr (fourth form) :line line :column col)
           :else (when (fifth form) (parse-surface-sexpr (fifth form) :line line :column col))
           :line line :column col))
         ((:def :defun)
          (lys.ast.surface:make-ast-def
           :name (string-downcase (string (second form)))
           :params (mapcar (lambda (p) (string-downcase (string p))) (third form))
           :body (parse-surface-sexpr (fourth form) :line line :column col)
           :line line :column col))
         (:class
          (lys.ast.surface:make-ast-class
           :name (string-downcase (string (second form)))
           :bases (mapcar #'string (third form))
           :body (parse-surface-sexpr (fourth form) :line line :column col)
           :line line :column col))
         (:return
          (lys.ast.surface:make-ast-return
           :value (parse-surface-sexpr (second form) :line line :column col)
           :line line :column col))
         (:try
          (lys.ast.surface:make-ast-try
           :body (parse-surface-sexpr (second form) :line line :column col)
           :handlers (third form)
           :finally (when (fourth form) (parse-surface-sexpr (fourth form) :line line :column col))
           :line line :column col))
         (:with
          (lys.ast.surface:make-ast-with
           :items (mapcar (lambda (it) (parse-surface-sexpr it :line line :column col)) (second form))
           :body (parse-surface-sexpr (third form) :line line :column col)
           :line line :column col))

         ;; Infix operators without tag: (+ a b), (== a b)
         ((:+ :- :* :/ :% :== :!= :< :<= :> :>= :and :or)
          (lys.ast.surface:make-ast-binary-op
           :op head-sym
           :left (parse-surface-sexpr (second form) :line line :column col)
           :right (parse-surface-sexpr (third form) :line line :column col)
           :line line :column col))

         ;; Default: function invocation
         (t
          (lys.ast.surface:make-ast-call
           :callee (parse-surface-sexpr (first form) :line line :column col)
           :args (mapcar (lambda (arg) (parse-surface-sexpr arg :line line :column col)) (rest form))
           :line line :column col)))))
    (t
     (lys.ast.surface:make-ast-literal :value form :line line :column col)))))

(defun parse-surface-string (source-text)
  "Parse SOURCE-TEXT into a Surface AST hierarchy.
   Handles both S-expression surface notation and standard Python statements."
  (let ((trimmed (string-trim '(#\Space #\Tab #\Newline #\Return) source-text)))
    (cond
      ((zerop (length trimmed))
       nil)
      ;; S-expression notation: begins with '('
      ((char= (char trimmed 0) #\()
       (let ((form (read-from-string trimmed)))
         (parse-surface-sexpr form)))
      ;; Standard Python expression/statement line parsing
      (t
       (%parse-simple-python-line trimmed)))))

(defun %parse-simple-python-line (text)
  "Simple line parser for standard Python surface forms."
  ;; Assignment: e.g. "x = 42" or "x = 1 + 2"
  (let ((eq-pos (search " = " text)))
    (if eq-pos
        (let ((target-name (string-trim " " (subseq text 0 eq-pos)))
              (val-str (string-trim " " (subseq text (+ eq-pos 3)))))
          (lys.ast.surface:make-ast-assign
           :target (lys.ast.surface:make-ast-identifier :name target-name)
           :value (parse-surface-string val-str)))
        ;; Return statement: e.g. "return x + 1"
        (if (and (>= (length text) 6) (string= (subseq text 0 6) "return"))
            (let ((val-str (string-trim " " (subseq text 6))))
              (lys.ast.surface:make-ast-return
               :value (if (> (length val-str) 0) (parse-surface-string val-str) nil)))
            ;; Infix Binary Operators (e.g. "10 + 20", "x == y")
            (or
             (loop for (op-str op-sym) in '((" == " :==) (" != " :!=) (" <= " :<=) (" >= " :>=)
                                           (" + " :+) (" - " :-) (" * " :*) (" / " :/)
                                           (" < " :<) (" > " :>) (" and " :and) (" or " :or))
                   for pos = (search op-str text)
                   when pos
                     return (lys.ast.surface:make-ast-binary-op
                             :op op-sym
                             :left (parse-surface-string (string-trim " " (subseq text 0 pos)))
                             :right (parse-surface-string (string-trim " " (subseq text (+ pos (length op-str)))))))
             ;; Identifier or Literal or Call
             (let ((num (ignore-errors (parse-integer text))))
               (if num
                   (lys.ast.surface:make-ast-literal :value num)
                   (let ((flt (ignore-errors (read-from-string text))))
                     (if (numberp flt)
                         (lys.ast.surface:make-ast-literal :value flt)
                         (lys.ast.surface:make-ast-identifier :name text))))))))))
