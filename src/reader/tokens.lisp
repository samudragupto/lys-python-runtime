;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Lexical Tokens and Tokenization

(in-package #:lys.reader)

(defstruct token
  "Represents a lexical token emitted by the surface scanner."
  (type :generic :type symbol)
  (value nil)
  (line 1 :type integer)
  (column 0 :type integer))

(defun whitespace-char-p (ch)
  "Predicate checking if CH is a non-newline whitespace character."
  (and ch (member ch '(#\Space #\Tab) :test #'char=)))

(defun digit-char-p* (ch)
  "Predicate checking if CH is an ASCII numeric digit."
  (and ch (char<= #\0 ch #\9)))

(defun identifier-start-p (ch)
  "Predicate checking if CH can begin a Python identifier."
  (and ch (or (alpha-char-p ch) (char= ch #\_))))

(defun identifier-part-p (ch)
  "Predicate checking if CH can continue a Python identifier."
  (and ch (or (alphanumericp ch) (char= ch #\_))))

(defun tokenize-surface-string (source-text)
  "Tokenize SOURCE-TEXT into a list of token structures."
  (let ((tokens nil)
        (len (length source-text))
        (pos 0)
        (line 1)
        (col 0))
    (flet ((peek ()
             (if (< pos len) (char source-text pos) nil))
           (advance ()
             (let ((ch (if (< pos len) (char source-text pos) nil)))
               (when ch
                 (incf pos)
                 (if (char= ch #\Newline)
                     (progn (incf line) (setf col 0))
                     (incf col)))
               ch)))
      (loop while (< pos len) do
        (let ((ch (peek)))
          (cond
            ;; Whitespace
            ((whitespace-char-p ch)
             (advance))
            ;; Newline
            ((char= ch #\Newline)
             (push (make-token :type :newline :value "\n" :line line :column col) tokens)
             (advance))
            ;; S-Expression open/close
            ((char= ch #\()
             (push (make-token :type :lparen :value "(" :line line :column col) tokens)
             (advance))
            ((char= ch #\))
             (push (make-token :type :rparen :value ")" :line line :column col) tokens)
             (advance))
            ((char= ch #\:)
             (push (make-token :type :colon :value ":" :line line :column col) tokens)
             (advance))
            ((char= ch #\,)
             (push (make-token :type :comma :value "," :line line :column col) tokens)
             (advance))
            ;; Number Literal
            ((digit-char-p* ch)
             (let ((start-col col)
                   (buf (make-string-output-stream)))
               (loop while (and (peek) (or (digit-char-p* (peek)) (char= (peek) #\.))) do
                 (write-char (advance) buf))
               (let* ((str (get-output-stream-string buf))
                      (val (if (find #\. str)
                               (read-from-string str)
                               (parse-integer str))))
                 (push (make-token :type :number :value val :line line :column start-col) tokens))))
            ;; String Literal
            ((or (char= ch #\") (char= ch #\'))
             (let ((quote-ch (advance))
                   (start-col col)
                   (buf (make-string-output-stream)))
               (loop while (and (peek) (char/= (peek) quote-ch)) do
                 (if (char= (peek) #\\)
                     (progn (advance) (when (peek) (write-char (advance) buf)))
                     (write-char (advance) buf)))
               (when (peek) (advance)) ; consume closing quote
               (push (make-token :type :string :value (get-output-stream-string buf) :line line :column start-col) tokens)))
            ;; Operator or Punctuation
            ((member ch '(#\+ #\- #\* #\/ #\= #\< #\>) :test #'char=)
             (let ((op-ch (advance)))
               (if (and (peek) (char= (peek) #\=))
                   (let ((next-ch (advance)))
                     (push (make-token :type :operator :value (format nil "~A~A" op-ch next-ch) :line line :column col) tokens))
                   (push (make-token :type :operator :value (string op-ch) :line line :column col) tokens))))
            ;; Identifier or Keyword
            ((identifier-start-p ch)
             (let ((start-col col)
                   (buf (make-string-output-stream)))
               (loop while (and (peek) (identifier-part-p (peek))) do
                 (write-char (advance) buf))
               (let* ((name (get-output-stream-string buf))
                      (tok-type (cond
                                  ((string= name "def") :def)
                                  ((string= name "if") :if)
                                  ((string= name "else") :else)
                                  ((string= name "elif") :elif)
                                  ((string= name "while") :while)
                                  ((string= name "for") :for)
                                  ((string= name "in") :in)
                                  ((string= name "return") :return)
                                  ((string= name "True") :boolean)
                                  ((string= name "False") :boolean)
                                  ((string= name "None") :none)
                                  (t :identifier))))
                 (push (make-token :type tok-type :value name :line line :column start-col) tokens))))
            ;; Skip comments (# ...)
            ((char= ch #\#)
             (loop while (and (peek) (char/= (peek) #\Newline)) do (advance)))
            (t
             (advance))))))
    (nreverse tokens)))
