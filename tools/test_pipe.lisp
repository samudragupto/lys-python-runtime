(let* ((python-exe "python")
       (bridge-path (merge-pathnames "src/bridge/python_bridge.py" (truename ".")))
       (code-str (format nil "if (1 == 1):~%    42~%else:~%    0"))
       (cmd (list python-exe (namestring bridge-path) "--eval")))
  (format t "Testing stdin pipe...~%")
  (multiple-value-bind (out err code)
      (uiop:run-program cmd
                        :input (make-string-input-stream code-str)
                        :output :string
                        :error-output :string
                        :ignore-error-status t)
    (format t "OUT: ~A~%" out)
    (format t "ERR: ~A~%" err)
    (format t "CODE: ~A~%" code)))
(sb-ext:exit :code 0)
