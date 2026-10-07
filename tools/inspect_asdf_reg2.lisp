(format t "USER-SOURCE-REGISTRY: ~S~%" (asdf/source-registry:user-source-registry))
(format t "SYSTEM-SOURCE-REGISTRY-DIRECTORY: ~S~%" (asdf/source-registry:system-source-registry-directory))
(format t "ENVIRONMENT-SOURCE-REGISTRY: ~S~%" (asdf/source-registry:environment-source-registry))
(sb-ext:exit :code 0)
