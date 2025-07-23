;;; OSdefs-Based Assembly Generation Demo
;;; Shows how osdefs evaluation drives platform-specific code generation

(require "osdefs.k")

;; Platform detection
(define detect-platform (lambda ()
  (println "=== Platform Detection from OSdefs ===")
  (println "Architecture:")
  (cond
    ((defined? '__arm64__) (println "  ARM64 detected"))
    ((defined? '__x86_64__) (println "  x86-64 detected"))
    ((defined? '__i386__) (println "  x86 detected"))
    (else (println "  Unknown architecture")))
  
  (println "Operating System:")
  (cond
    ((defined? '__APPLE__) (println "  macOS/Darwin"))
    ((defined? '__linux__) (println "  Linux"))
    ((defined? '__WIN32__) (println "  Windows"))
    (else (println "  Unknown OS")))
  
  (println "Data sizes:")
  (println "  int: " sizeof-int " bytes")
  (println "  long: " sizeof-long " bytes") 
  (println "  pointer: " sizeof-pointer " bytes")
  
  (println "Label prefix: '" __USER_LABEL_PREFIX__ "'")
  (println)))

;; Generate assembly based on osdefs
(define generate-platform-asm (lambda (name expr)
  (println "--- Generating " name " ---")
  
  ;; Platform-specific assembly
  (cond
    ((defined? '__arm64__)
     ;; ARM64 assembly
     (println "\t.text")
     (println "\t.align 4")
     (println "\t.globl " __USER_LABEL_PREFIX__ name)
     (println __USER_LABEL_PREFIX__ name ":")
     
     (cond
       ((long? expr)
        (println "\tmov\tx0, #" expr)
        (println "\tret"))
       
       ((and (pair? expr) (= (car expr) '+))
        (println "\tmov\tx0, #" (cadr expr))
        (println "\tmov\tx1, #" (caddr expr))
        (println "\tadd\tx0, x0, x1")
        (println "\tret"))
       
       (else
        (println "\t; Unsupported expression"))))
    
    ((defined? '__x86_64__)
     ;; x86-64 assembly
     (println "\t.text")
     (println "\t.globl " __USER_LABEL_PREFIX__ name)
     (println __USER_LABEL_PREFIX__ name ":")
     
     (cond
       ((long? expr)
        (println "\tmov\t$" expr ", %rax")
        (println "\tret"))
       
       ((and (pair? expr) (= (car expr) '+))
        (println "\tmov\t$" (cadr expr) ", %rax")
        (println "\tadd\t$" (caddr expr) ", %rax")
        (println "\tret"))
       
       (else
        (println "\t; Unsupported expression"))))
    
    (else
     (println "\t; Assembly generation not implemented for this platform")))
  
  (println)))

;; Demonstrate size-aware code generation
(define generate-size-aware-code (lambda ()
  (println "--- Size-Aware Code Generation ---")
  
  ;; Choose appropriate instructions based on sizes
  (let ((ptr-size sizeof-pointer)
        (long-size sizeof-long)
        (int-size sizeof-int))
    
    (println "; Pointer operations use " ptr-size "-byte values")
    (println "; Long operations use " long-size "-byte values")
    (println "; Int operations use " int-size "-byte values")
    (println)
    
    ;; Generate appropriate data directives
    (println "data_section:")
    (println "\tmy_int: " (if (= int-size 4) ".long" ".quad") " 42")
    (println "\tmy_ptr: " (if (= ptr-size 8) ".quad" ".long") " 0")
    (println "\tmy_long: " (if (= long-size 8) ".quad" ".long") " 123456789")
    (println))))

;; Show alignment requirements
(define show-alignment-requirements (lambda ()
  (println "--- Alignment Requirements ---")
  (println "Type alignments from osdefs:")
  (println "  char: " alignof-char " bytes")
  (println "  short: " alignof-short " bytes")
  (println "  int: " alignof-int " bytes")
  (println "  long: " alignof-long " bytes")
  (println "  pointer: " alignof-pointer " bytes")
  (println)
  
  ;; Generate aligned data section
  (println "aligned_data:")
  (println "\t.align " alignof-long)
  (println "\tlong_value: .quad 0")
  (println "\t.align " alignof-pointer)
  (println "\tptr_value: .quad 0")
  (println)))

;; Main demo
(detect-platform)

(generate-platform-asm "return_42" 42)
(generate-platform-asm "add_numbers" '(+ 10 32))

(generate-size-aware-code)
(show-alignment-requirements)

(println "=== OSdefs Integration Benefits ===")
(println "✓ Automatic platform detection")
(println "✓ Correct data sizes for target")
(println "✓ Proper alignment requirements")
(println "✓ Platform-specific assembly syntax")
(println "✓ Portable code generation")
(println)
(println "The assembly generator adapts to the target platform")
(println "based on osdefs evaluation results!")