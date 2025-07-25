;;; ir-arch.l - Architecture-specific IR extensions
;;;
;;; Extends the IR system with architecture-specific instructions
;;; and machine code generation capabilities

(require "ir.k")
(require "arch-spec.l")

;; Architecture-specific IR instruction base class
(define-class <ir-arch-insn> <ir-insn> (architecture encoding))

;; Architecture-specific register type
(define-class <ir-register> <ir-variable> (arch-id bit-width))

(define-method do-print <ir-register> ()
  (print "<" (type-name-of self) " " self.name " id=" self.arch-id " bits=" self.bit-width ">"))

;; Architecture-specific instruction classes for x86

(define-class <ir-x86-mov-reg-reg> <ir-arch-insn> (src-reg dst-reg))
(define-class <ir-x86-mov-imm-reg> <ir-arch-insn> (immediate dst-reg))

;; Instruction constructors
(define-function ir-x86-mov-reg-reg (src dst)
  "Create x86 register-to-register move instruction"
  (new <ir-x86-mov-reg-reg> 
       (list src dst)          ; parameters
       ()                      ; operands
       IR-VOID                 ; type
       'x86-64                 ; architecture
       ()                      ; encoding (to be filled)
       src                     ; src-reg
       dst))                   ; dst-reg

(define-function ir-x86-mov-imm-reg (imm dst)
  "Create x86 immediate-to-register move instruction"
  (new <ir-x86-mov-imm-reg>
       (list imm dst)          ; parameters
       ()                      ; operands
       IR-VOID                 ; type
       'x86-64                 ; architecture
       ()                      ; encoding (to be filled)
       imm                     ; immediate
       dst))                   ; dst-reg

;; Machine code generation methods

(define-method ir-gen-machine-code <ir-x86-mov-reg-reg> ()
  "Generate x86 machine code for register-to-register move"
  ;; MOV r/m64, r64 = REX.W + 89 /r
  ;; For now, just return a placeholder
  (list 0x48 0x89 0xc0))  ; mov %rax, %rax as example

(define-method ir-gen-machine-code <ir-x86-mov-imm-reg> ()
  "Generate x86 machine code for immediate-to-register move"
  ;; MOV r64, imm64 = REX.W + B8+ rd io
  ;; For now, just return a placeholder
  (list 0x48 0xb8 0x2a 0x00 0x00 0x00 0x00 0x00 0x00 0x00))  ; mov $42, %rax

;; Assembly generation methods (for disassembly)

(define-method ir-gen-assembly <ir-x86-mov-reg-reg> ()
  "Generate x86 assembly for register-to-register move"
  (print "mov %" (symbol->string self.src-reg) ", %" (symbol->string self.dst-reg)))

(define-method ir-gen-assembly <ir-x86-mov-imm-reg> ()
  "Generate x86 assembly for immediate-to-register move"
  (print "mov $" self.immediate ", %" (symbol->string self.dst-reg)))

;; Integration with existing IR system

(define-function ir-from-assembly-node (node)
  "Convert assembly AST node to IR instruction"
  (cond
    ;; Handle (ir-set 'dst (ir-get 'src)) -> x86 mov reg,reg
    ((and (pair? node) (= (car node) 'ir-set)
          (pair? (caddr node)) (= (car (caddr node)) 'ir-get))
     (let ((dst (cadr (cadr node)))  ; 'dst from (quote dst)
           (src (cadr (cadr (caddr node)))))  ; 'src from (quote src)
       (ir-x86-mov-reg-reg src dst)))
    
    ;; Handle (ir-set 'dst (ir-lit imm)) -> x86 mov imm,reg
    ((and (pair? node) (= (car node) 'ir-set)
          (pair? (caddr node)) (= (car (caddr node)) 'ir-lit))
     (let ((dst (cadr (cadr node)))  ; 'dst from (quote dst)
           (imm (cadr (caddr node))))   ; immediate value
       (ir-x86-mov-imm-reg imm dst)))
    
    ;; Default: return node as-is
    (else node)))

;; Architecture registry

(define *architectures* ())

(define-function register-architecture (arch-spec)
  "Register an architecture specification"
  (let ((name (<architecture>-name arch-spec)))
    (set *architectures* (cons (cons name arch-spec) *architectures*))
    arch-spec))

(define-function get-architecture (name)
  "Get architecture specification by name"
  (cdr (assq name *architectures*)))

;; x86-64 register definitions
(define-function define-x86-registers ()
  "Define x86-64 registers"
  (let ((x86-regs ()))
    (push x86-regs (new <ir-register> 'rax IR-INT64 0 64))
    (push x86-regs (new <ir-register> 'rbx IR-INT64 3 64))
    (push x86-regs (new <ir-register> 'rcx IR-INT64 1 64))
    (push x86-regs (new <ir-register> 'rdx IR-INT64 2 64))
    x86-regs))

;; Test the architecture IR system
(println "=== Testing Architecture IR System ===")

;; Test instruction creation
(let ((mov-reg (ir-x86-mov-reg-reg 'rax 'rbx))
      (mov-imm (ir-x86-mov-imm-reg 42 'rcx)))
  
  (println "Created instructions:")
  (println "  " mov-reg)
  (println "  " mov-imm)
  
  (println "\nGenerated machine code:")
  (print "  mov-reg: ") (dump (ir-gen-machine-code mov-reg)) (println)
  (print "  mov-imm: ") (dump (ir-gen-machine-code mov-imm)) (println)
  
  (println "\nGenerated assembly:")
  (print "  ") (ir-gen-assembly mov-reg) (println)
  (print "  ") (ir-gen-assembly mov-imm) (println))

;; Test AST conversion
(println "\nTesting AST conversion:")
(let ((ast1 '(ir-set 'rbx (ir-get 'rax)))
      (ast2 '(ir-set 'rcx (ir-lit 42))))
  
  (println "AST: " ast1)
  (println "IR:  " (ir-from-assembly-node ast1))
  
  (println "AST: " ast2)
  (println "IR:  " (ir-from-assembly-node ast2)))

(println "\n=== Architecture IR System Test Complete ===")