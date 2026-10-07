(format t "XDG-CONFIG-HOME: ~S~%" (uiop:xdg-config-home))
(format t "XDG-DATA-HOME: ~S~%" (uiop:xdg-data-home))
(format t "XDG-CONFIG-DIRS: ~S~%" (uiop:xdg-config-dirs))
(sb-ext:exit :code 0)
