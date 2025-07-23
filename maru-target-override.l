;;; MARU_TARGET_ARCH Override System
;;; Demonstrates environment variable override for target architecture

(require "osdefs.k")

;; Simulated environment variable (in real implementation, would use getenv)
;; Set this to test different targets
(define *MARU_TARGET_ARCH* ())  ; Set to 'x86-64, 'riscv64, etc. for testing

;; Target architecture detection with override
(define get-target-architecture (lambda ()
  "Get target architecture with MARU_TARGET_ARCH override support"
  (if *MARU_TARGET_ARCH*
      ;; Use override if set
      (let ()
        (println "MARU_TARGET_ARCH override: " *MARU_TARGET_ARCH*)
        *MARU_TARGET_ARCH*)
      ;; Fall back to native detection from osdefs
      (let ((native (cond
                      ((defined? '__arm64__) 'arm64)
                      ((defined? '__aarch64__) 'arm64)
                      ((defined? '__x86_64__) 'x86-64)
                      ((defined? '__i386__) 'x86)
                      ((defined? '__powerpc64__) 'ppc64)
                      ((defined? '__riscv64__) 'riscv64)
                      (else 'unknown))))
        (println "Native architecture from osdefs: " native)
        native))))

;; Cross-compilation target database
(define *cross-targets*
  '((arm64 
     (pointer-size . 8) (long-size . 8) (int-size . 4)
     (endian . little) (alignment . 8)
     (asm-syntax . "arm64") (label-prefix . "_"))
    
    (x86-64
     (pointer-size . 8) (long-size . 8) (int-size . 4)
     (endian . little) (alignment . 16)
     (asm-syntax . "x86-att") (label-prefix . ""))
    
    (x86
     (pointer-size . 4) (long-size . 4) (int-size . 4)
     (endian . little) (alignment . 4)
     (asm-syntax . "x86-att") (label-prefix . ""))
    
    (riscv64
     (pointer-size . 8) (long-size . 8) (int-size . 4)
     (endian . little) (alignment . 8)
     (asm-syntax . "riscv") (label-prefix . ""))
    
    (ppc64
     (pointer-size . 8) (long-size . 8) (int-size . 4)
     (endian . big) (alignment . 8)
     (asm-syntax . "powerpc") (label-prefix . ""))))

;; Get configuration for target
(define get-target-config (lambda (arch)
  "Get target configuration, using osdefs for native or specs for cross"
  (if *MARU_TARGET_ARCH*
      ;; Cross-compilation: use target specs
      (let ((spec (assq arch *cross-targets*)))
        (if spec
            (cdr spec)
            (let ()
              (println "Error: Unknown target " arch)
              (println "Available: " (map car *cross-targets*))
              ())))
      ;; Native compilation: use osdefs
      `((pointer-size . ,sizeof-pointer)
        (long-size . ,sizeof-long)
        (int-size . ,sizeof-int)
        (label-prefix . ,__USER_LABEL_PREFIX__)
        (asm-syntax . "native")))))

;; Generate assembly for target
(define generate-for-target (lambda (name expr)
  "Generate assembly code for current target"
  (let* ((arch (get-target-architecture))
         (config (get-target-config arch))
         (ptr-size (cdr (assq 'pointer-size config)))
         (syntax (cdr (assq 'asm-syntax config)))
         (prefix (cdr (assq 'label-prefix config))))
    
    (println "=== Generating " name " ===")
    (println "Target: " arch)
    (println "Pointer size: " ptr-size " bytes")
    (println "Assembly syntax: " syntax)
    (println "Label prefix: '" prefix "'")
    (println)
    
    ;; Generate platform-specific assembly
    (cond
      ((= arch 'arm64)
       (println "\t.text")
       (println "\t.align 4")
       (println "\t.globl " prefix name)
       (println prefix name ":")
       (generate-arm64-code expr)
       (println "\tret"))
      
      ((= arch 'x86-64)
       (println "\t.text")
       (println "\t.globl " prefix name)
       (println prefix name ":")
       (generate-x86-64-code expr)
       (println "\tret"))
      
      ((= arch 'riscv64)
       (println "\t.text")
       (println "\t.globl " prefix name)
       (println prefix name ":")
       (generate-riscv-code expr)
       (println "\tret"))
      
      ((= arch 'ppc64)
       (println "\t.text")
       (println "\t.globl " prefix name)
       (println prefix name ":")
       (generate-ppc-code expr)
       (println "\tblr"))
      
      (else
       (println "\t; Assembly generation not supported for " arch)))
    
    (println))))

;; Architecture-specific code generators
(define generate-arm64-code (lambda (expr)
  (cond
    ((long? expr)
     (println "\tmov\tx0, #" expr))
    ((and (pair? expr) (= (car expr) '+))
     (println "\tmov\tx0, #" (cadr expr))
     (println "\tadd\tx0, x0, #" (caddr expr))))))

(define generate-x86-64-code (lambda (expr)
  (cond
    ((long? expr)
     (println "\tmov\t$" expr ", %rax"))
    ((and (pair? expr) (= (car expr) '+))
     (println "\tmov\t$" (cadr expr) ", %rax")
     (println "\tadd\t$" (caddr expr) ", %rax")))))

(define generate-riscv-code (lambda (expr)
  (cond
    ((long? expr)
     (println "\tli\ta0, " expr))
    ((and (pair? expr) (= (car expr) '+))
     (println "\tli\ta0, " (cadr expr))
     (println "\taddi\ta0, a0, " (caddr expr))))))

(define generate-ppc-code (lambda (expr)
  (cond
    ((long? expr)
     (println "\tlis\tr3, " expr "@ha")
     (println "\taddi\tr3, r3, " expr "@l"))
    ((and (pair? expr) (= (car expr) '+))
     (let ((result (+ (cadr expr) (caddr expr))))
       (println "\tlis\tr3, " result "@ha")
       (println "\taddi\tr3, r3, " result "@l"))))))

;; Demonstration
(println "=== MARU_TARGET_ARCH Override System Demo ===")
(println)

;; Test 1: Native compilation
(println "--- Test 1: Native Compilation ---")
(set *MARU_TARGET_ARCH* ())
(generate-for-target "native_test" 42)

;; Test 2: Cross-compilation to x86-64
(println "--- Test 2: Cross-compilation to x86-64 ---")
(set *MARU_TARGET_ARCH* 'x86-64)
(generate-for-target "x86_64_test" '(+ 15 27))

;; Test 3: Cross-compilation to RISC-V
(println "--- Test 3: Cross-compilation to RISC-V ---")
(set *MARU_TARGET_ARCH* 'riscv64)
(generate-for-target "riscv_test" 100)

;; Test 4: Cross-compilation to PowerPC
(println "--- Test 4: Cross-compilation to PowerPC ---")
(set *MARU_TARGET_ARCH* 'ppc64)
(generate-for-target "ppc_test" '(+ 30 12))

(println)
(println "=== Usage ===")
(println "In real implementation:")
(println "  export MARU_TARGET_ARCH=x86-64    # Cross-compile to x86-64")
(println "  export MARU_TARGET_ARCH=riscv64   # Cross-compile to RISC-V")
(println "  export MARU_TARGET_ARCH=arm64     # Cross-compile to ARM64")
(println "  unset MARU_TARGET_ARCH            # Use native target")
(println)
(println "Benefits:")
(println "✓ Environment variable override")
(println "✓ Cross-compilation support")
(println "✓ Fallback to native osdefs")
(println "✓ Multiple target architectures")
(println "✓ Consistent assembly generation")