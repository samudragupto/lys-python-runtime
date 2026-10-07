(format t "USER-REGISTRY-DIRECTORY: ~S~%" (asdf/source-registry:user-source-registry-directory))
(format t "DEFAULT-USER-SOURCE-REGISTRY: ~S~%" (asdf/source-registry:default-user-source-registry))
(format t "SYS-REGISTRY: ~S~%" (asdf/source-registry:system-source-registry))
(sb-ext:exit :code 0)
