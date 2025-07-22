;;; ir-arm64.l - ARM64-specific IR Extensions
;;;
;;; Extends the IR system with ARM64-specific instructions and machine code generation
;;; Comprehensive instruction set based on Maru's ARM64 requirements

(require "ir.k")
(require "record-case.l")

;; Define helper functions we need
(define-function expt (base exp)
  "Simple exponentiation function"
  (if (= exp 0) 1
    (if (= exp 1) base
      (* base (expt base (- exp 1))))))

;; Basic ARM64 constants we need
(define-constant _X0  0)  (define-constant _X1  1)  (define-constant _X2  2)  (define-constant _X3  3)
(define-constant _X29 29) (define-constant _X30 30) (define-constant _SP  31) (define-constant _XZR 31)

;; ARM64-specific IR instruction base class
(define-class <ir-arm64-insn> <ir-insn> (encoding))

;; ARM64 register type
(define-class <ir-arm64-register> <ir-variable> (arch-id bit-width reg-type))

(define-method do-print <ir-arm64-register> ()
  (print "<arm64-" self.reg-type " " self.name " id=" self.arch-id " bits=" self.bit-width ">"))

;; Data Movement Instructions

(define-class <ir-arm64-mov-imm-x> <ir-arm64-insn> (immediate dst-reg))
(define-class <ir-arm64-mov-imm-w> <ir-arm64-insn> (immediate dst-reg))
(define-class <ir-arm64-mov-x-x> <ir-arm64-insn> (src-reg dst-reg))
(define-class <ir-arm64-mov-w-w> <ir-arm64-insn> (src-reg dst-reg))

;; Arithmetic Instructions

(define-class <ir-arm64-add-x-x-x> <ir-arm64-insn> (dst-reg src1-reg src2-reg))
(define-class <ir-arm64-add-w-w-w> <ir-arm64-insn> (dst-reg src1-reg src2-reg))
(define-class <ir-arm64-add-x-x-imm> <ir-arm64-insn> (dst-reg src-reg immediate))
(define-class <ir-arm64-add-w-w-imm> <ir-arm64-insn> (dst-reg src-reg immediate))

(define-class <ir-arm64-sub-x-x-x> <ir-arm64-insn> (dst-reg src1-reg src2-reg))
(define-class <ir-arm64-sub-w-w-w> <ir-arm64-insn> (dst-reg src1-reg src2-reg))
(define-class <ir-arm64-sub-x-x-imm> <ir-arm64-insn> (dst-reg src-reg immediate))
(define-class <ir-arm64-sub-w-w-imm> <ir-arm64-insn> (dst-reg src-reg immediate))

;; Load/Store Instructions

(define-class <ir-arm64-ldr-x-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-ldr-w-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-str-x-mem> <ir-arm64-insn> (src-reg mem-ref))
(define-class <ir-arm64-str-w-mem> <ir-arm64-insn> (src-reg mem-ref))

(define-class <ir-arm64-ldrb-w-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-strb-w-mem> <ir-arm64-insn> (src-reg mem-ref))
(define-class <ir-arm64-ldrh-w-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-strh-w-mem> <ir-arm64-insn> (src-reg mem-ref))

(define-class <ir-arm64-ldp-x-x-mem> <ir-arm64-insn> (dst1-reg dst2-reg mem-ref))
(define-class <ir-arm64-stp-x-x-mem> <ir-arm64-insn> (src1-reg src2-reg mem-ref))

;; Compare Instructions

(define-class <ir-arm64-cmp-x-x> <ir-arm64-insn> (src1-reg src2-reg))
(define-class <ir-arm64-cmp-w-w> <ir-arm64-insn> (src1-reg src2-reg))
(define-class <ir-arm64-cmp-x-imm> <ir-arm64-insn> (src-reg immediate))
(define-class <ir-arm64-cmp-w-imm> <ir-arm64-insn> (src-reg immediate))

;; Branch Instructions

(define-class <ir-arm64-b-label> <ir-arm64-insn> (target-label))
(define-class <ir-arm64-beq-label> <ir-arm64-insn> (target-label))
(define-class <ir-arm64-bne-label> <ir-arm64-insn> (target-label))
(define-class <ir-arm64-blr-x> <ir-arm64-insn> (target-reg))
(define-class <ir-arm64-ret> <ir-arm64-insn> ())

;; Address Calculation

(define-class <ir-arm64-adrp-x-label> <ir-arm64-insn> (dst-reg target-label))

;; Conditional Set

(define-class <ir-arm64-cset-x-cond> <ir-arm64-insn> (dst-reg condition))
(define-class <ir-arm64-cset-w-cond> <ir-arm64-insn> (dst-reg condition))

;; Floating-point Instructions

(define-class <ir-arm64-ldr-d-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-str-d-mem> <ir-arm64-insn> (src-reg mem-ref))
(define-class <ir-arm64-ldr-s-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-str-s-mem> <ir-arm64-insn> (src-reg mem-ref))

;; Instruction Constructors

(define-function ir-arm64-mov-imm-x (imm dst)
  "Create ARM64 move immediate to X register"
  (new <ir-arm64-mov-imm-x> (list imm dst) () IR-VOID () imm dst))

(define-function ir-arm64-mov-imm-w (imm dst)
  "Create ARM64 move immediate to W register"
  (new <ir-arm64-mov-imm-w> (list imm dst) () IR-VOID () imm dst))

(define-function ir-arm64-mov-x-x (src dst)
  "Create ARM64 move X register to X register"
  (new <ir-arm64-mov-x-x> (list src dst) () IR-VOID () src dst))

(define-function ir-arm64-add-x-x-x (dst src1 src2)
  "Create ARM64 add X registers"
  (new <ir-arm64-add-x-x-x> (list dst src1 src2) () IR-VOID () dst src1 src2))

(define-function ir-arm64-ldr-x-mem (dst mem)
  "Create ARM64 load X register from memory"
  (new <ir-arm64-ldr-x-mem> (list dst mem) () IR-VOID () dst mem))

;; Helper Functions (defined early)

(define-function arm64-register-encoding (reg-symbol)
  "Get ARM64 register encoding from symbol"
  (cond
    ((or (= reg-symbol 'x0) (= reg-symbol 'w0)) 0)
    ((or (= reg-symbol 'x1) (= reg-symbol 'w1)) 1)
    ((or (= reg-symbol 'x2) (= reg-symbol 'w2)) 2)
    ((or (= reg-symbol 'x3) (= reg-symbol 'w3)) 3)
    ((or (= reg-symbol 'x4) (= reg-symbol 'w4)) 4)
    ((or (= reg-symbol 'x5) (= reg-symbol 'w5)) 5)
    ((or (= reg-symbol 'x29) (= reg-symbol 'w29)) 29)
    ((or (= reg-symbol 'x30) (= reg-symbol 'w30)) 30)
    ((or (= reg-symbol 'sp) (= reg-symbol 'xzr) (= reg-symbol 'wzr)) 31)
    (else (error "Unknown ARM64 register: " reg-symbol))))

(define-function arm64-encode-mov-imm (sf opc hw imm16 rd)
  "Encode ARM64 MOV immediate instruction"
  (| (| (| (| (<< sf 31) (<< opc 29)) (<< 0x25 23)) (<< hw 21)) (<< imm16 5)) rd))

(define-function arm64-encode-orr-reg (sf opc rm imm6 rn rd)
  "Encode ARM64 ORR register instruction"
  (| (| (| (| (| (<< sf 31) (<< opc 29)) (<< 0x0A 24)) (<< rm 16)) (<< imm6 10)) (<< rn 5)) rd))

(define-function arm64-encode-add-reg (sf op s shift rm imm6 rn rd)
  "Encode ARM64 ADD register instruction"
  (| (| (| (| (| (| (| (<< sf 31) (<< op 30)) (<< s 29)) (<< 0x0B 24)) (<< shift 22)) (<< rm 16)) (<< imm6 10)) (<< rn 5)) rd))

(define-function arm64-encode-ldr-imm (size opc imm12 rn rt)
  "Encode ARM64 LDR immediate instruction"
  (| (| (| (| (<< size 30) (<< opc 22)) (<< 0x39 24)) (<< imm12 10)) (<< rn 5)) rt))

;; Machine Code Generation Methods

(define-method ir-gen-machine-code <ir-arm64-mov-imm-x> ()
  "Generate ARM64 machine code for MOV immediate to X register"
  ;; MOV Xd, #imm16 - MOVZ instruction
  ;; 1101 0010 100 imm16 Rd
  (let ((rd (arm64-register-encoding self.dst-reg))
        (imm (self.immediate)))
    (arm64-encode-mov-imm 1 0x2 0 imm rd)))

(define-method ir-gen-machine-code <ir-arm64-mov-imm-w> ()
  "Generate ARM64 machine code for MOV immediate to W register"
  ;; MOV Wd, #imm16 - MOVZ instruction
  ;; 0101 0010 100 imm16 Rd
  (let ((rd (arm64-register-encoding self.dst-reg))
        (imm (self.immediate)))
    (arm64-encode-mov-imm 0 0x2 0 imm rd)))

(define-method ir-gen-machine-code <ir-arm64-mov-x-x> ()
  "Generate ARM64 machine code for MOV X register to X register"
  ;; MOV Xd, Xm (alias for ORR Xd, XZR, Xm)
  ;; 1010 1010 000 Rm 000000 11111 Rd
  (let ((rd (arm64-register-encoding self.dst-reg))
        (rm (arm64-register-encoding self.src-reg)))
    (arm64-encode-orr-reg 1 0 rm 0 31 rd)))

(define-method ir-gen-machine-code <ir-arm64-add-x-x-x> ()
  "Generate ARM64 machine code for ADD X registers"
  ;; ADD Xd, Xn, Xm
  ;; 1000 1011 000 Rm 000000 Rn Rd
  (let ((rd (arm64-register-encoding self.dst-reg))
        (rn (arm64-register-encoding self.src1-reg))
        (rm (arm64-register-encoding self.src2-reg)))
    (arm64-encode-add-reg 1 0 0 0 rm 0 rn rd)))

(define-method ir-gen-machine-code <ir-arm64-ldr-x-mem> ()
  "Generate ARM64 machine code for LDR X register from memory"
  ;; LDR Xt, [Xn, #imm] - unsigned immediate
  ;; 1111 1001 01 imm12 Rn Rt
  (let ((rt (arm64-register-encoding self.dst-reg))
        (mem-ref self.mem-ref))
    ;; For now, assume simple [Rn, #imm] addressing
    (if (ir-mem-ref-simple? mem-ref)
        (let ((rn (arm64-register-encoding (ir-mem-ref-base mem-ref)))
              (imm (ir-mem-ref-offset mem-ref)))
          (arm64-encode-ldr-imm 3 1 (/ imm 8) rn rt))
      (error "Complex addressing modes not yet implemented"))))

;; Assembly Generation Methods (for disassembly)

(define-method ir-gen-assembly <ir-arm64-mov-imm-x> ()
  "Generate ARM64 assembly for MOV immediate to X register"
  (print "mov " self.dst-reg ", #" self.immediate))

(define-method ir-gen-assembly <ir-arm64-mov-imm-w> ()
  "Generate ARM64 assembly for MOV immediate to W register"
  (print "mov " self.dst-reg ", #" self.immediate))

(define-method ir-gen-assembly <ir-arm64-mov-x-x> ()
  "Generate ARM64 assembly for MOV X register to X register"
  (print "mov " self.dst-reg ", " self.src-reg))

(define-method ir-gen-assembly <ir-arm64-add-x-x-x> ()
  "Generate ARM64 assembly for ADD X registers"
  (print "add " self.dst-reg ", " self.src1-reg ", " self.src2-reg))

(define-method ir-gen-assembly <ir-arm64-ldr-x-mem> ()
  "Generate ARM64 assembly for LDR X register from memory"
  (print "ldr " self.dst-reg ", " (ir-mem-ref-to-string self.mem-ref)))

;; Additional Helper Functions

;; Integration with existing IR system

(define-function ir-from-arm64-assembly-node (node)
  "Convert ARM64 assembly AST node to IR instruction"
  (cond
    ;; Handle (ir-set 'dst (ir-lit imm)) -> ARM64 MOV immediate
    ((and (pair? node) (= (car node) 'ir-set)
          (pair? (caddr node)) (= (car (caddr node)) 'ir-lit))
     (let ((dst (cadr (cadr node)))  ; 'dst from (quote dst)
           (imm (cadr (caddr node))))   ; immediate value
       (if (arm64-x-register? dst)
           (ir-arm64-mov-imm-x imm dst)
         (ir-arm64-mov-imm-w imm dst))))
    
    ;; Handle (ir-set 'dst (ir-get 'src)) -> ARM64 MOV register
    ((and (pair? node) (= (car node) 'ir-set)
          (pair? (caddr node)) (= (car (caddr node)) 'ir-get))
     (let ((dst (cadr (cadr node)))  ; 'dst from (quote dst)
           (src (cadr (cadr (caddr node)))))  ; 'src from (quote src)
       (if (and (arm64-x-register? dst) (arm64-x-register? src))
           (ir-arm64-mov-x-x src dst)
         (ir-arm64-mov-w-w src dst))))
    
    ;; Handle (ir-set 'dst (ir-add (ir-get 'src1) (ir-get 'src2))) -> ARM64 ADD
    ((and (pair? node) (= (car node) 'ir-set)
          (pair? (caddr node)) (= (car (caddr node)) 'ir-add))
     (let ((dst (cadr (cadr node)))
           (add-expr (caddr node)))
       (when (and (pair? (cadr add-expr)) (= (car (cadr add-expr)) 'ir-get)
                  (pair? (caddr add-expr)) (= (car (caddr add-expr)) 'ir-get))
         (let ((src1 (cadr (cadr (cadr add-expr))))
               (src2 (cadr (cadr (caddr add-expr)))))
           (ir-arm64-add-x-x-x dst src1 src2)))))
    
    ;; Handle (ir-set 'dst (ir-load mem-ref)) -> ARM64 LDR
    ((and (pair? node) (= (car node) 'ir-set)
          (pair? (caddr node)) (= (car (caddr node)) 'ir-load))
     (let ((dst (cadr (cadr node)))
           (mem-ref (cadr (caddr node))))
       (ir-arm64-ldr-x-mem dst mem-ref)))
    
    ;; Default: return node as-is
    (else node)))

(define-function arm64-x-register? (reg-symbol)
  "Check if register is an X register (64-bit)"
  (let ((reg-str (symbol->string reg-symbol)))
    (and (> (string-length reg-str) 0)
         (= (string-at reg-str 0) ?x))))

(define-function ir-mem-ref-simple? (mem-ref)
  "Check if memory reference is simple [Rn, #imm] form"
  ;; This is a placeholder - would need proper implementation
  #t)

(define-function ir-mem-ref-base (mem-ref)
  "Get base register from memory reference"
  ;; Placeholder implementation
  'x1)

(define-function ir-mem-ref-offset (mem-ref)
  "Get offset from memory reference"
  ;; Placeholder implementation
  0)

(define-function ir-mem-ref-to-string (mem-ref)
  "Convert memory reference to string representation"
  ;; Placeholder implementation
  "[x1]")

;; Test the ARM64 IR system
(println "=== Testing ARM64 IR System ===")

;; Test instruction creation
(let ((mov-imm (ir-arm64-mov-imm-x 42 'x0))
      (mov-reg (ir-arm64-mov-x-x 'x0 'x1))
      (add-reg (ir-arm64-add-x-x-x 'x2 'x0 'x1)))
  
  (println "Created ARM64 instructions:")
  (println "  " mov-imm)
  (println "  " mov-reg)
  (println "  " add-reg)
  
  (println "\nGenerated assembly:")
  (print "  ") (ir-gen-assembly mov-imm) (println)
  (print "  ") (ir-gen-assembly mov-reg) (println)
  (print "  ") (ir-gen-assembly add-reg) (println)
  
  (println "\nGenerated machine code:")
  (print "  mov-imm: ") (dump (ir-gen-machine-code mov-imm)) (println)
  (print "  mov-reg: ") (dump (ir-gen-machine-code mov-reg)) (println)
  (print "  add-reg: ") (dump (ir-gen-machine-code add-reg)) (println))

(println "\n=== ARM64 IR System Test Complete ===")