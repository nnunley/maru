;;; Smart Backend Selection System
;;; Integrates environment variable control with platform detection
;;; Usage: (load "backend-selection.l") at the end of emit.l

;; Access to environment variables
;; Note: This uses extern which must be available when emit.l is loaded
(define getenv (extern 'getenv))
(define-function env-var (name)
  (let ((result (getenv name)))
    (if result result ())))

;; Smart backend selection with environment override and platform defaults
(define-function select-emit-backend ()
  "Select emit backend based on environment or platform"
  (let ((env-backend (env-var "MARU_EMIT_BACKEND")))
    (cond
      ;; Environment variable override takes precedence
      (env-backend
        (cond
          ((string= env-backend "c")
           (println "; Using C backend (MARU_EMIT_BACKEND=c)")
           (use-c-backend))
          ((string= env-backend "arm64")
           (println "; Using ARM64 backend (MARU_EMIT_BACKEND=arm64)")
           (use-arm64-backend))
          ((string= env-backend "x86")
           (println "; Using x86 backend (MARU_EMIT_BACKEND=x86)")
           ;; x86 is the default assembly backend
           (set *emit-backend* 'asm)
           (set *c-backend-active* ())
           (set *arm64-backend-active* ())
           (if (defined? '*ir-backend-active*) (set *ir-backend-active* ())))
          ((string= env-backend "ir")
           (println "; Using IR backend (MARU_EMIT_BACKEND=ir)")
           (use-ir-backend))
          (else
           (println "; Warning: Unknown backend '" env-backend "', using platform default")
           (select-platform-default-backend))))
      
      ;; No environment override - use platform detection
      (else
        (select-platform-default-backend)))))

;; Platform-specific default backend selection using osdefs.k
(define-function select-platform-default-backend ()
  "Select default backend based on platform detection from osdefs.k"
  (cond
    ;; ARM64 platforms (Apple Silicon, etc.)
    ((or (defined? '__arm64__) (defined? '__aarch64__))
     (println "; Using ARM64 backend (platform: arm64/aarch64)")
     (use-arm64-backend))
    
    ;; x86-64 platforms
    ((defined? '__x86_64__)
     (println "; Using x86-64 assembly backend (platform: x86_64)")
     (set *emit-backend* 'asm)
     (set *c-backend-active* ())
     (set *arm64-backend-active* ())
     (if (defined? '*ir-backend-active*) (set *ir-backend-active* ())))
    
    ;; 32-bit x86
    ((defined? '__i386__)
     (println "; Using x86 assembly backend (platform: i386)")
     (set *emit-backend* 'asm)
     (set *c-backend-active* ())
     (set *arm64-backend-active* ())
     (if (defined? '*ir-backend-active*) (set *ir-backend-active* ())))
    
    ;; PowerPC 64-bit
    ((defined? '__powerpc64__)
     (println "; Warning: No PowerPC backend, using C backend")
     (use-c-backend))
    
    ;; RISC-V 64-bit
    ((defined? '__riscv64__)
     (println "; Warning: No RISC-V backend, using C backend")
     (use-c-backend))
    
    ;; MIPS
    ((or (defined? '__mips__) (defined? '__mips64__))
     (println "; Warning: No MIPS backend, using C backend")
     (use-c-backend))
    
    ;; Unknown platform - fallback to C
    (else
     (println "; Warning: Unknown platform, using C backend as fallback")
     (use-c-backend))))

;; Function to check if we need C backend for eval2.c generation
(define-function ensure-c-backend-for-eval2 ()
  "Ensure C backend is active when generating eval2.c"
  (let ((generating-eval2 (and (defined? '*arguments*)
                              (member "core/eval.l" *arguments*))))
    (if (and generating-eval2 (not *c-backend-active*))
        (let ()
          (println "; Forcing C backend for eval2.c generation")
          (use-c-backend)))))

;; Display current backend configuration
(define-function show-backend-config ()
  "Display current backend configuration"
  (println "; Backend Configuration:")
  (println ";   Active backend: " *emit-backend*)
  (println ";   C backend active: " (if *c-backend-active* "yes" "no"))
  (println ";   ARM64 backend active: " (if *arm64-backend-active* "yes" "no"))
  (if (defined? '*ir-backend-active*)
      (println ";   IR backend active: " (if *ir-backend-active* "yes" "no")))
  (println ";   Platform: " 
           (cond
             ((defined? '__arm64__) "arm64")
             ((defined? '__aarch64__) "aarch64")
             ((defined? '__x86_64__) "x86_64")
             ((defined? '__i386__) "i386")
             ((defined? '__powerpc64__) "powerpc64")
             ((defined? '__riscv64__) "riscv64")
             ((defined? '__mips64__) "mips64")
             ((defined? '__mips__) "mips")
             (else "unknown")))
  (println ";   MARU_EMIT_BACKEND: " (or (env-var "MARU_EMIT_BACKEND") "(not set)")))

;; Auto-select backend on load
(select-emit-backend)
(show-backend-config)

;; Export for use in emit.l
'backend-selection-loaded