;;; arm64-spec.l - ARM64 Architecture Specification
;;;
;;; Defines ARM64 architecture using our specification language
;;; for grammar-driven assembler/disassembler generation

(require "arch-spec.l")

;; ARM64 Register Definitions
(define arm64-registers (list
  ;; 64-bit general purpose registers
  (new <arch-register> 'x0  0  64)
  (new <arch-register> 'x1  1  64)
  (new <arch-register> 'x2  2  64)
  (new <arch-register> 'x3  3  64)
  (new <arch-register> 'x4  4  64)
  (new <arch-register> 'x5  5  64)
  (new <arch-register> 'x6  6  64)
  (new <arch-register> 'x7  7  64)
  (new <arch-register> 'x8  8  64)
  (new <arch-register> 'x9  9  64)
  (new <arch-register> 'x10 10 64)
  (new <arch-register> 'x11 11 64)
  (new <arch-register> 'x12 12 64)
  (new <arch-register> 'x13 13 64)
  (new <arch-register> 'x14 14 64)
  (new <arch-register> 'x15 15 64)
  (new <arch-register> 'x16 16 64)
  (new <arch-register> 'x17 17 64)
  (new <arch-register> 'x18 18 64)
  (new <arch-register> 'x19 19 64)
  (new <arch-register> 'x20 20 64)
  (new <arch-register> 'x21 21 64)
  (new <arch-register> 'x22 22 64)
  (new <arch-register> 'x23 23 64)
  (new <arch-register> 'x24 24 64)
  (new <arch-register> 'x25 25 64)
  (new <arch-register> 'x26 26 64)
  (new <arch-register> 'x27 27 64)
  (new <arch-register> 'x28 28 64)
  (new <arch-register> 'x29 29 64)  ; Frame pointer
  (new <arch-register> 'x30 30 64)  ; Link register
  (new <arch-register> 'sp  31 64)  ; Stack pointer
  (new <arch-register> 'xzr 31 64)  ; Zero register

  ;; 32-bit general purpose registers (W registers)
  (new <arch-register> 'w0  0  32)
  (new <arch-register> 'w1  1  32)
  (new <arch-register> 'w2  2  32)
  (new <arch-register> 'w3  3  32)
  (new <arch-register> 'w4  4  32)
  (new <arch-register> 'w5  5  32)
  (new <arch-register> 'w6  6  32)
  (new <arch-register> 'w7  7  32)
  (new <arch-register> 'w8  8  32)
  (new <arch-register> 'w9  9  32)
  (new <arch-register> 'w10 10 32)
  (new <arch-register> 'w11 11 32)
  (new <arch-register> 'w12 12 32)
  (new <arch-register> 'w13 13 32)
  (new <arch-register> 'w14 14 32)
  (new <arch-register> 'w15 15 32)
  (new <arch-register> 'w16 16 32)
  (new <arch-register> 'w17 17 32)
  (new <arch-register> 'w18 18 32)
  (new <arch-register> 'w19 19 32)
  (new <arch-register> 'w20 20 32)
  (new <arch-register> 'w21 21 32)
  (new <arch-register> 'w22 22 32)
  (new <arch-register> 'w23 23 32)
  (new <arch-register> 'w24 24 32)
  (new <arch-register> 'w25 25 32)
  (new <arch-register> 'w26 26 32)
  (new <arch-register> 'w27 27 32)
  (new <arch-register> 'w28 28 32)
  (new <arch-register> 'w29 29 32)
  (new <arch-register> 'w30 30 32)
  (new <arch-register> 'wsp 31 32)
  (new <arch-register> 'wzr 31 32)))

;; ARM64 Instruction Definitions
(define arm64-instructions (list
  ;; Move instructions
  (new <arch-instruction> 'mov-reg-reg
       '(mov register register)
       '(ir-set %2 (ir-get %1))
       'arm64-mov-reg-reg)
  
  (new <arch-instruction> 'mov-imm-reg
       '(mov immediate register)
       '(ir-set %2 %1)
       'arm64-mov-imm-reg)
  
  ;; Arithmetic instructions
  (new <arch-instruction> 'add-reg-reg-reg
       '(add register register register)
       '(ir-set %3 (ir-add (ir-get %1) (ir-get %2)))
       'arm64-add-reg-reg-reg)
  
  (new <arch-instruction> 'add-imm-reg-reg  
       '(add immediate register register)
       '(ir-set %3 (ir-add (ir-get %2) %1))
       'arm64-add-imm-reg-reg)
  
  (new <arch-instruction> 'sub-reg-reg-reg
       '(sub register register register)
       '(ir-set %3 (ir-sub (ir-get %1) (ir-get %2)))
       'arm64-sub-reg-reg-reg)
  
  (new <arch-instruction> 'sub-imm-reg-reg
       '(sub immediate register register)
       '(ir-set %3 (ir-sub (ir-get %2) %1))
       'arm64-sub-imm-reg-reg)
  
  ;; Load/Store instructions
  (new <arch-instruction> 'ldr-reg-mem
       '(ldr register memory-ref)
       '(ir-set %1 (ir-load %2))
       'arm64-ldr-reg-mem)
  
  (new <arch-instruction> 'str-reg-mem
       '(str register memory-ref)
       '(ir-store %2 (ir-get %1))
       'arm64-str-reg-mem)
  
  ;; Compare instruction
  (new <arch-instruction> 'cmp-reg-reg
       '(cmp register register)
       '(ir-cmp (ir-get %1) (ir-get %2))
       'arm64-cmp-reg-reg)
  
  (new <arch-instruction> 'cmp-imm-reg
       '(cmp immediate register)
       '(ir-cmp %1 (ir-get %2))
       'arm64-cmp-imm-reg)
  
  ;; Branch instructions
  (new <arch-instruction> 'b-label
       '(b label)
       '(ir-branch %1)
       'arm64-b-label)
  
  (new <arch-instruction> 'ret
       '(ret)
       '(ir-return)
       'arm64-ret)))

;; ARM64 Addressing Modes
(define arm64-addressing-modes (list
  ;; Register indirect with immediate offset
  (new <arch-addressing-mode> 'reg-imm-offset
       '([ register # immediate ])
       '(ir-mem-ref (ir-add (ir-get %1) %2)))
  
  ;; Register indirect
  (new <arch-addressing-mode> 'reg-indirect
       '([ register ])
       '(ir-mem-ref (ir-get %1)))
  
  ;; Pre-indexed (ARM64 style: [register, #immediate]!)
  (new <arch-addressing-mode> 'pre-indexed
       '([ register , # immediate ] !)
       '(ir-mem-ref (ir-pre-inc %1 %2)))
  
  ;; Post-indexed (ARM64 style: [register], #immediate)  
  (new <arch-addressing-mode> 'post-indexed
       '([ register ] , # immediate)
       '(ir-mem-ref (ir-post-inc %1 %2)))))

;; Create the ARM64 architecture specification
(define arm64-architecture
  (new <architecture> 'arm64 arm64-registers arm64-instructions arm64-addressing-modes))

;; Test the ARM64 specification
(println "=== ARM64 Architecture Specification ===")
(println "Parsed architecture: " arm64-architecture)

(println "Registers: " (<architecture>-registers arm64-architecture))
(print "  Sample registers: ")
(let ((regs (<architecture>-registers arm64-architecture)))
  (print (car regs)) (print " ")
  (print (cadr regs)) (print " ") 
  (print (caddr regs)) (println))

(println "Instructions: " (<architecture>-instructions arm64-architecture))
(print "  Sample instructions: ")
(let ((insns (<architecture>-instructions arm64-architecture)))
  (print (car insns)) (print " ")
  (print (cadr insns)) (println))

(println "Addressing modes: " (<architecture>-addressing-modes arm64-architecture))

(println "\n=== ARM64 Architecture Specification Complete ===")