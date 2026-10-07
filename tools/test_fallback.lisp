;; Test Section 4 fallback
(format t "Testing direct load of lyspython.asd...~%")
(load #p"C:/Users/user/Desktop/lys-python-runtime/lyspython.asd")

(format t "Probing system-source-file after load: ~S~%"
        (asdf:system-source-file :lys-python))

(format t "Loading dependencies and compiling system via asdf:load-system...~%")
(asdf:load-system :lys-python)

(format t "FIND-PACKAGE LYS-PYTHON.REPL: ~S~%" (find-package :lys-python.repl))
(format t "SUCCESS!~%")
(sb-ext:exit :code 0)
