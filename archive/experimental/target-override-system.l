;;; Target Architecture Override System
;;; Uses MARU_TARGET_ARCH environment variable to override native platform detection

(require "osdefs.k")

;; Environment variable access (simulated for demo)
(define getenv (extern 'getenv))

;; Target architecture override support
(define get-target-arch (lambda ()
  "Get target architecture, checking environment override first"
  (let ((env-target (getenv "MARU_TARGET_ARCH")))
    (if env-target
        ;; Parse environment variable
        (let ((target (string->symbol env-target)))
          (println "Using MARU_TARGET_ARCH override: " target)
          target)
        ;; Fall back to native detection from osdefs
        (let ((native (cond
                        ((defined? '__arm64__) 'arm64)
                        ((defined? '__aarch64__) 'arm64)
                        ((defined? '__x86_64__) 'x86-64)
                        ((defined? '__i386__) 'x86)
                        ((defined? '__powerpc64__) 'ppc64)
                        ((defined? '__powerpc__) 'ppc)
                        ((defined? '__mips64__) 'mips64)
                        ((defined? '__mips__) 'mips)
                        ((defined? '__sparc64__) 'sparc64)
                        ((defined? '__sparc__) 'sparc)
                        ((defined? '__riscv64__) 'riscv64)
                        ((defined? '__riscv__) 'riscv)
                        (else 'unknown))))
          (println "Using native architecture: " native)
          native))))

;; Cross-compilation target specifications
(define *target-specs*
  '((arm64
     (pointer-size . 8)
     (long-size . 8)
     (int-size . 4)
     (alignment . 8)
     (endian . little)
     (registers . ((return . "x0") (arg1 . "x0") (arg2 . "x1")))
     (instructions . arm64))
    
    (x86-64
     (pointer-size . 8)
     (long-size . 8)
     (int-size . 4)
     (alignment . 16)
     (endian . little)
     (registers . ((return . "rax") (arg1 . "rdi") (arg2 . "rsi")))
     (instructions . x86-64))
    
    (x86
     (pointer-size . 4)
     (long-size . 4)
     (int-size . 4)
     (alignment . 4)
     (endian . little)
     (registers . ((return . "eax") (arg1 . "eax") (arg2 . "edx")))
     (instructions . x86))
    
    (riscv64
     (pointer-size . 8)
     (long-size . 8)
     (int-size . 4)
     (alignment . 8)
     (endian . little)
     (registers . ((return . "a0") (arg1 . "a0") (arg2 . "a1")))
     (instructions . riscv))
    
    (ppc64
     (pointer-size . 8)
     (long-size . 8)
     (int-size . 4)
     (alignment . 8)
     (endian . big)
     (registers . ((return . "r3") (arg1 . "r3") (arg2 . "r4")))
     (instructions . powerpc))))

;; Get target specification
(define get-target-spec (lambda (arch)
  "Get target specification for architecture"
  (let ((spec (assq arch *target-specs*)))
    (if spec
        (cdr spec)
        (let ()
          (println "Warning: Unknown target architecture " arch)
          (println "Available targets: " (map car *target-specs*))
          ())))))

;; Resolve target configuration (environment override + osdefs fallback)
(define get-target-config (lambda ()
  "Get target configuration with environment override support"
  (let* ((target-arch (get-target-arch))
         (target-spec (get-target-spec target-arch))
         (native-sizes (if (and (not (getenv "MARU_TARGET_ARCH"))
                               (defined? 'sizeof-pointer))
                          ;; Use native osdefs when no override
                          `((pointer-size . ,sizeof-pointer)
                            (long-size . ,sizeof-long)
                            (int-size . ,sizeof-int))
                          ;; Use target spec for cross-compilation
                          (if target-spec
                              `((pointer-size . ,(cdr (assq 'pointer-size target-spec)))
                                (long-size . ,(cdr (assq 'long-size target-spec)))
                                (int-size . ,(cdr (assq 'int-size target-spec))))
                              '()))))
    
    ;; Combine target spec with size overrides
    `((architecture . ,target-arch)
      ,@native-sizes
      ,@(if target-spec target-spec '())))))

;; Generate assembly with target override support
(define generate-target-assembly (lambda (name expr)
  "Generate assembly for specified target architecture"
  (let* ((config (get-target-config))
         (arch (cdr (assq 'architecture config)))
         (ptr-size (cdr (assq 'pointer-size config)))
         (registers (cdr (assq 'registers config))))
    
    (println "--- Generating " name " for " arch " ---")
    (println "; Target: " arch)
    (println "; Pointer size: " ptr-size " bytes")
    (if (getenv "MARU_TARGET_ARCH")
        (println "; Cross-compiling (override active)")
        (println "; Native compilation"))
    (println)
    
    ;; Architecture-specific assembly generation
    (cond
      ((= arch 'arm64)
       (generate-arm64-assembly name expr registers))
      
      ((= arch 'x86-64)
       (generate-x86-64-assembly name expr registers))
      
      ((= arch 'x86)
       (generate-x86-assembly name expr registers))
      
      ((= arch 'riscv64)
       (generate-riscv-assembly name expr registers))
      
      ((= arch 'ppc64)
       (generate-ppc-assembly name expr registers))
      
      (else
       (println "; Assembly generation not implemented for " arch)))
    
    (println))))

;; Architecture-specific generators
(define generate-arm64-assembly (lambda (name expr registers)
  (let ((ret-reg (cdr (assq 'return registers))))
    (println "\t.text")
    (println "\t.align 4")
    (println "\t.globl _" name)
    (println "_" name ":")
    (cond
      ((long? expr)
       (println "\tmov\t" ret-reg ", #" expr))
      ((and (pair? expr) (= (car expr) '+))
       (println "\tmov\t" ret-reg ", #" (cadr expr))
       (println "\tadd\t" ret-reg ", " ret-reg ", #" (caddr expr))))
    (println "\tret"))))

(define generate-x86-64-assembly (lambda (name expr registers)
  (let ((ret-reg (cdr (assq 'return registers))))
    (println "\t.text")
    (println "\t.globl " name)
    (println name ":")
    (cond
      ((long? expr)
       (println "\tmov\t$" expr ", %" ret-reg))
      ((and (pair? expr) (= (car expr) '+))
       (println "\tmov\t$" (cadr expr) ", %" ret-reg)
       (println "\tadd\t$" (caddr expr) ", %" ret-reg)))
    (println "\tret"))))

(define generate-riscv-assembly (lambda (name expr registers)
  (let ((ret-reg (cdr (assq 'return registers))))
    (println "\t.text")
    (println "\t.globl " name)
    (println name ":")
    (cond
      ((long? expr)
       (println "\tli\t" ret-reg ", " expr))
      ((and (pair? expr) (= (car expr) '+))
       (println "\tli\t" ret-reg ", " (cadr expr))
       (println "\taddi\t" ret-reg ", " ret-reg ", " (caddr expr))))
    (println "\tret"))))

(define generate-ppc-assembly (lambda (name expr registers)
  (let ((ret-reg (cdr (assq 'return registers))))
    (println "\t.text")
    (println "\t.globl " name)
    (println name ":")
    (cond
      ((long? expr)
       (println "\tlis\t" ret-reg ", " expr "@ha")
       (println "\taddi\t" ret-reg ", " ret-reg ", " expr "@l"))
      ((and (pair? expr) (= (car expr) '+))
       (println "\tlis\t" ret-reg ", " (+ (cadr expr) (caddr expr)) "@ha")
       (println "\taddi\t" ret-reg ", " ret-reg ", " (+ (cadr expr) (caddr expr)) "@l")))
    (println "\tblr"))))

(define generate-x86-assembly (lambda (name expr registers)
  (let ((ret-reg (cdr (assq 'return registers))))
    (println "\t.text")
    (println "\t.globl " name)
    (println name ":")
    (cond
      ((long? expr)
       (println "\tmov\t$" expr ", %" ret-reg))
      ((and (pair? expr) (= (car expr) '+))
       (println "\tmov\t$" (cadr expr) ", %" ret-reg)
       (println "\tadd\t$" (caddr expr) ", %" ret-reg)))
    (println "\tret"))))

;; Demo the system
(println "=== Target Architecture Override System ===")
(println)

;; Show current configuration
(let ((config (get-target-config)))
  (println "Current target configuration:")
  (println "  Architecture: " (cdr (assq 'architecture config)))
  (println "  Pointer size: " (cdr (assq 'pointer-size config)) " bytes")
  (println "  Long size: " (cdr (assq 'long-size config)) " bytes")
  (println "  Int size: " (cdr (assq 'int-size config)) " bytes"))

(println)

;; Test native compilation
(generate-target-assembly "test_native" '(+ 20 22))

;; Simulate cross-compilation examples
(println "Cross-compilation examples:")
(println "(Set MARU_TARGET_ARCH=x86-64 for x86-64 cross-compilation)")
(println "(Set MARU_TARGET_ARCH=riscv64 for RISC-V cross-compilation)")
(println "(Set MARU_TARGET_ARCH=ppc64 for PowerPC cross-compilation)")

(println)
(println "=== Benefits of Target Override ===")
(println "✓ Environment variable override: MARU_TARGET_ARCH")
(println "✓ Cross-compilation support")
(println "✓ Multiple architecture targets")
(println "✓ Fallback to native osdefs")
(println "✓ Consistent interface for all platforms")