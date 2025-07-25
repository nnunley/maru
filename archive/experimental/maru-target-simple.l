;;; Simple MARU_TARGET_ARCH Override Demo
;;; Shows environment variable override for cross-compilation

(require "osdefs.k")

;; Simulated MARU_TARGET_ARCH environment variable
(define *MARU_TARGET_ARCH* ())  ; Set to test different targets

;; Architecture detection with override
(define get-target-arch (lambda ()
  (if *MARU_TARGET_ARCH*
      *MARU_TARGET_ARCH*  ; Use override
      ;; Native detection from osdefs
      (cond
        ((defined? '__arm64__) 'arm64)
        ((defined? '__x86_64__) 'x86-64)
        ((defined? '__i386__) 'x86)
        (else 'unknown)))))

;; Simple cross-compilation demo
(define demo-cross-compilation (lambda (target)
  (println "=== Target: " target " ===")
  
  ;; Set target override
  (set *MARU_TARGET_ARCH* target)
  (let ((arch (get-target-arch)))
    (println "Selected architecture: " arch)
    
    ;; Generate platform-specific code
    (cond
      ((= arch 'arm64)
       (println "\t.text")
       (println "\t.align 4") 
       (println "\t.globl _test")
       (println "_test:")
       (println "\tmov\tx0, #42")
       (println "\tret"))
      
      ((= arch 'x86-64)
       (println "\t.text")
       (println "\t.globl test")
       (println "test:")
       (println "\tmov\t$42, %rax")
       (println "\tret"))
      
      ((= arch 'x86)
       (println "\t.text")
       (println "\t.globl test")
       (println "test:")
       (println "\tmov\t$42, %eax")
       (println "\tret"))
      
      (else
       (println "\t; Unsupported target: " arch)))
    
    (println)))

;; Test the system
(println "=== MARU_TARGET_ARCH Override Demo ===")
(println)

(println "Available targets:")
(println "  arm64   - ARM64/AArch64")
(println "  x86-64  - x86-64/AMD64")
(println "  x86     - x86/i386")
(println)

;; Native compilation (no override)
(println "--- Native Compilation ---")
(set *MARU_TARGET_ARCH* ())
(println "Native architecture: " (get-target-arch))
(println "Uses osdefs detection")
(println)

;; Cross-compilation examples
(demo-cross-compilation 'x86-64)
(demo-cross-compilation 'x86)  
(demo-cross-compilation 'arm64)

;; Show configuration differences
(println "=== Configuration Differences ===")

(define show-target-config (lambda (target)
  (set *MARU_TARGET_ARCH* target)
  (println target ":")
  (cond
    ((= target 'arm64)
     (println "  Pointer size: 8 bytes")
     (println "  Endianness: little")
     (println "  ABI: AAPCS64")
     (println "  Label prefix: _"))
    
    ((= target 'x86-64)
     (println "  Pointer size: 8 bytes")
     (println "  Endianness: little")  
     (println "  ABI: System V AMD64")
     (println "  Label prefix: (none)"))
    
    ((= target 'x86)
     (println "  Pointer size: 4 bytes")
     (println "  Endianness: little")
     (println "  ABI: cdecl/stdcall")
     (println "  Label prefix: (none)")))
  (println)))

(show-target-config 'arm64)
(show-target-config 'x86-64)
(show-target-config 'x86)

(println "=== Real Implementation Notes ===")
(println "In actual implementation:")
(println "  1. Use getenv(\"MARU_TARGET_ARCH\") for environment access")
(println "  2. Validate target against supported architectures")
(println "  3. Load target-specific osdefs or use cross-compilation specs")
(println "  4. Generate appropriate assembly syntax and calling conventions")
(println "  5. Handle endianness and alignment differences")
(println)
(println "Usage:")
(println "  export MARU_TARGET_ARCH=x86-64")
(println "  ./eval your-program.l")
(println "  # Generates x86-64 assembly instead of native")
(println)
(println "Benefits:")
(println "✓ Cross-compilation support")
(println "✓ Environment variable override")
(println "✓ Fallback to native osdefs")
(println "✓ Multiple target architectures")
(println "✓ Portable build system integration")