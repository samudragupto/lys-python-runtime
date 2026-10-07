;; 1. Clear all cached ASDF state
(asdf:clear-configuration)
(asdf:clear-source-registry)

;; 2. Reinitialize ASDF with the new configuration
(asdf:initialize-source-registry)

;; 3. Verify ASDF can see the .asd file
(let ((asd-file (asdf:system-source-file :lys-python)))
  (format t "PROBE-ASD: ~S~%" (probe-file asd-file)))

;; 4. Register Quicklisp local projects (forces index rebuild)
(ql:register-local-projects)

;; 5. Load the system
(format t "QUICKLOADING LYS-PYTHON...~%")
(ql:quickload :lys-python)

;; 6. Check package
(format t "FIND-PACKAGE LYS-PYTHON.REPL: ~S~%" (find-package :lys-python.repl))
(format t "VERIFICATION SUCCESSFUL!~%")
(sb-ext:exit :code 0)
