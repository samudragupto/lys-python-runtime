;;;; LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
;;;; Subsystem: Runtime Kernel and Global State Coordination

(in-package #:lys.core)

(defparameter *kernel-initialized-p* nil
  "Boolean indicating whether the LYSPYTHON runtime kernel is actively initialized.")

(defparameter *kernel-start-time* nil
  "Timestamp recording when the active kernel instance was initialized.")

(defun initialize-kernel (&key (mode :normal) (load-builtins t))
  "Bootstrap and initialize the LYSPYTHON runtime kernel.
   1. Configures runtime execution mode.
   2. Clears and initializes the macro registry.
   3. Loads built-in Python semantic macros.
   4. Establishes the global execution environment.
   5. Connects to CPython foreign bridge."
  (when *kernel-initialized-p*
    (lys.utils:log-warn "Kernel is already initialized. Performing re-initialization.")
    (shutdown-kernel))

  (lys.utils:log-info "Bootstrapping LYSPYTHON Kernel v~A [Mode: ~A]..."
                      lys.config:*version*
                      mode)

  (lys.config:set-runtime-mode mode)
  (setf *kernel-start-time* (get-universal-time))

  ;; Initialize Macro Registry
  (when load-builtins
    (lys.utils:log-info "Loading built-in Python semantic macros...")
    (lys.macros:load-builtin-macros))

  ;; Initialize Global Execution Environment
  (setf lys.env:*global-environment* (lys.env:make-environment))

  ;; Initialize CPython Foreign Bridge
  (handler-case
      (progn
        (lys.utils:log-info "Establishing CPython foreign bridge...")
        (lys.bridge:initialize-cpython-bridge))
    (error (err)
      (lys.utils:log-warn "CPython CFFI bridge initialization deferred: ~A" err)))

  (setf *kernel-initialized-p* t)
  (lys.utils:log-info "LYSPYTHON Kernel initialized successfully.")
  t)

(defun shutdown-kernel ()
  "Cleanly shut down the LYSPYTHON runtime kernel, releasing foreign resources."
  (when *kernel-initialized-p*
    (lys.utils:log-info "Shutting down LYSPYTHON Kernel...")
    (handler-case
        (lys.bridge:shutdown-cpython-bridge)
      (error (err)
        (lys.utils:log-warn "Error during CPython bridge shutdown: ~A" err)))
    (setf *kernel-initialized-p* nil)
    (setf *kernel-start-time* nil)
    (lys.utils:log-info "Kernel shutdown complete.")
    t))

(defun reset-kernel-state ()
  "Reset all kernel registries, environments, and caches to clean bootstrap state."
  (lys.utils:log-info "Resetting LYSPYTHON kernel state...")
  (shutdown-kernel)
  (initialize-kernel :mode lys.config:*runtime-mode* :load-builtins t))

(defun kernel-status ()
  "Return an association list describing the health and status of the kernel."
  (list :initialized *kernel-initialized-p*
        :version lys.config:*version*
        :runtime-mode lys.config:*runtime-mode*
        :uptime-seconds (if *kernel-start-time*
                            (- (get-universal-time) *kernel-start-time*)
                            0)
        :macros-registered (length (lys.macros:list-macros))
        :bridge-connected (lys.bridge:cpython-bridge-initialized-p)))
