;;; OSdefs-Based Assembly Generation System
;;; Uses osdefs evaluation results to generate platform-specific assembly

;; Load osdefs for current platform
(require "osdefs.k")

;; Platform detection based on osdefs
(define *target-platform* 
  (cond
    ((defined? '__arm64__) 'arm64)
    ((defined? '__x86_64__) 'x86-64)
    ((defined? '__i386__) 'x86)
    (else 'unknown)))

(define *pointer-size* (if (defined? 'sizeof-pointer) sizeof-pointer 8))
(define *long-size* (if (defined? 'sizeof-long) sizeof-long 8))
(define *int-size* (if (defined? 'sizeof-int) sizeof-int 4))

(define *label-prefix* 
  (if (defined? '__USER_LABEL_PREFIX__) __USER_LABEL_PREFIX__ ""))

(define *is-little-endian* 
  (if (defined? '__LITTLE_ENDIAN__) 1 ()))

;; Platform-specific register names
(define *register-map*
  (cond
    ((= *target-platform* 'arm64)
     '((return-value . "x0")
       (arg1 . "x0") (arg2 . "x1") (arg3 . "x2") (arg4 . "x3")
       (temp1 . "x9") (temp2 . "x10")
       (frame-pointer . "x29")
       (link-register . "x30")
       (stack-pointer . "sp")))
    
    ((= *target-platform* 'x86-64)
     '((return-value . "rax")
       (arg1 . "rdi") (arg2 . "rsi") (arg3 . "rdx") (arg4 . "rcx")
       (temp1 . "r10") (temp2 . "r11")
       (frame-pointer . "rbp")
       (stack-pointer . "rsp")))
    
    ((= *target-platform* 'x86)
     '((return-value . "eax")
       (arg1 . "eax") (arg2 . "edx") (arg3 . "ecx")
       (temp1 . "ebx") (temp2 . "esi")
       (frame-pointer . "ebp")
       (stack-pointer . "esp")))
    
    (else '())))

;; Platform-specific instruction generation
(define gen-function-prologue (lambda (name)
  "Generate function prologue based on platform"
  (println "\t.text")
  (cond
    ((= *target-platform* 'arm64)
     (println "\t.align 4")
     (println "\t.globl " *label-prefix* name)
     (println *label-prefix* name ":")
     ;; ARM64 function prologue
     (println "\tstp\tx29, x30, [sp, #-16]!")
     (println "\tmov\tx29, sp"))
    
    ((or (= *target-platform* 'x86-64) (= *target-platform* 'x86))
     (println "\t.align 16")
     (println "\t.globl " *label-prefix* name)
     (println *label-prefix* name ":")
     ;; x86 function prologue
     (println "\tpush\t" (cdr (assq 'frame-pointer *register-map*)))
     (println "\tmov\t" (cdr (assq 'frame-pointer *register-map*)) ", " 
              (cdr (assq 'stack-pointer *register-map*))))
    
    (else
     (println "; Unknown platform prologue for " name)))))

(define gen-function-epilogue (lambda ()
  "Generate function epilogue based on platform"
  (cond
    ((= *target-platform* 'arm64)
     (println "\tldp\tx29, x30, [sp], #16")
     (println "\tret"))
    
    ((or (= *target-platform* 'x86-64) (= *target-platform* 'x86))
     (println "\tpop\t" (cdr (assq 'frame-pointer *register-map*)))
     (println "\tret"))
    
    (else
     (println "; Unknown platform epilogue")))))

(define gen-load-immediate (lambda (value reg)
  "Generate immediate load based on platform and value size"
  (cond
    ((= *target-platform* 'arm64)
     (cond
       ((and (>= value 0) (< value 65536))
        (println "\tmov\t" reg ", #" value))
       ((< value 0)
        (println "\tmov\t" reg ", #" (+ value 65536))
        (println "\tmovk\t" reg ", #0xffff, lsl #16"))
       (else
        (println "\tmov\t" reg ", #" (& value 65535))
        (println "\tmovk\t" reg ", #" (>> value 16) ", lsl #16"))))
    
    ((= *target-platform* 'x86-64)
     (println "\tmov\t" reg ", " value))
    
    ((= *target-platform* 'x86)
     (println "\tmov\t" reg ", " value))
    
    (else
     (println "; Load immediate " value " to " reg)))))

(define gen-add (lambda (dest src1 src2)
  "Generate addition based on platform"
  (cond
    ((= *target-platform* 'arm64)
     (println "\tadd\t" dest ", " src1 ", " src2))
    
    ((or (= *target-platform* 'x86-64) (= *target-platform* 'x86))
     (if (not (= dest src1))
         (println "\tmov\t" dest ", " src1))
     (println "\tadd\t" dest ", " src2))
    
    (else
     (println "; Add " src1 " + " src2 " -> " dest)))))

;; High-level code generation using osdefs
(define generate-asm-function (lambda (name body)
  "Generate complete assembly function using osdefs information"
  (println "; Generated for " *target-platform* " platform")
  (println "; Pointer size: " *pointer-size* " bytes")
  (println "; Long size: " *long-size* " bytes")
  (println "; Label prefix: '" *label-prefix* "'")
  (println "; Endianness: " (if *is-little-endian* "little" "big"))
  (println)
  
  (gen-function-prologue name)
  
  ;; Generate body
  (body)
  
  (gen-function-epilogue)
  (println)))

;; Example: Generate a simple function
(define test-osdefs-asm (lambda ()
  (println "=== OSdefs-Based Assembly Generation Test ===")
  (println)
  
  ;; Generate add function: int add(int a, int b) { return a + b; }
  (generate-asm-function "add"
    (lambda ()
      (let ((arg1-reg (cdr (assq 'arg1 *register-map*)))
            (arg2-reg (cdr (assq 'arg2 *register-map*)))
            (ret-reg (cdr (assq 'return-value *register-map*))))
        (gen-add ret-reg arg1-reg arg2-reg))))
  
  ;; Generate constant function: long get_pointer_size() { return sizeof(void*); }
  (generate-asm-function "get_pointer_size"
    (lambda ()
      (let ((ret-reg (cdr (assq 'return-value *register-map*))))
        (gen-load-immediate *pointer-size* ret-reg))))
  
  ;; Generate platform check function
  (generate-asm-function "get_platform_id"
    (lambda ()
      (let ((ret-reg (cdr (assq 'return-value *register-map*)))
            (platform-id (cond
                          ((= *target-platform* 'arm64) 1)
                          ((= *target-platform* 'x86-64) 2)
                          ((= *target-platform* 'x86) 3)
                          (else 0))))
        (gen-load-immediate platform-id ret-reg))))))

(test-osdefs-asm)