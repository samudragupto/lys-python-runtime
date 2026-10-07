(ql:quickload :lys-python)
(asdf:load-system "lys-python/tests")

(handler-bind ((error (lambda (c)
                        (format t "ERROR: ~A~%" c)
                        (sb-debug:print-backtrace :count 20)
                        (sb-ext:exit :code 1))))
  (lys.tests::test-macro-cycle-detection))
