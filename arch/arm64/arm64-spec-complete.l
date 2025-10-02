;;; arm64-spec-complete.l - Comprehensive ARM64 Architecture Specification
;;;
;;; Defines ARM64 architecture with instruction set needed for Maru compiler
;;; Based on existing asm-arm64.k instruction definitions

(require "arch-spec.l")

;; ARM64 Register Definitions (same as before)
(define arm64-registers (list
  ;; 64-bit general purpose registers
  (new <arch-register> 'x0  0  64) (new <arch-register> 'x1  1  64)
  (new <arch-register> 'x2  2  64) (new <arch-register> 'x3  3  64)
  (new <arch-register> 'x4  4  64) (new <arch-register> 'x5  5  64)
  (new <arch-register> 'x6  6  64) (new <arch-register> 'x7  7  64)
  (new <arch-register> 'x8  8  64) (new <arch-register> 'x9  9  64)
  (new <arch-register> 'x10 10 64) (new <arch-register> 'x11 11 64)
  (new <arch-register> 'x12 12 64) (new <arch-register> 'x13 13 64)
  (new <arch-register> 'x14 14 64) (new <arch-register> 'x15 15 64)
  (new <arch-register> 'x16 16 64) (new <arch-register> 'x17 17 64)
  (new <arch-register> 'x18 18 64) (new <arch-register> 'x19 19 64)
  (new <arch-register> 'x20 20 64) (new <arch-register> 'x21 21 64)
  (new <arch-register> 'x22 22 64) (new <arch-register> 'x23 23 64)
  (new <arch-register> 'x24 24 64) (new <arch-register> 'x25 25 64)
  (new <arch-register> 'x26 26 64) (new <arch-register> 'x27 27 64)
  (new <arch-register> 'x28 28 64) (new <arch-register> 'x29 29 64)
  (new <arch-register> 'x30 30 64) (new <arch-register> 'sp  31 64)
  (new <arch-register> 'xzr 31 64)

  ;; 32-bit general purpose registers
  (new <arch-register> 'w0  0  32) (new <arch-register> 'w1  1  32)
  (new <arch-register> 'w2  2  32) (new <arch-register> 'w3  3  32)
  (new <arch-register> 'w4  4  32) (new <arch-register> 'w5  5  32)
  (new <arch-register> 'w6  6  32) (new <arch-register> 'w7  7  32)
  (new <arch-register> 'w8  8  32) (new <arch-register> 'w9  9  32)
  (new <arch-register> 'w10 10 32) (new <arch-register> 'w11 11 32)
  (new <arch-register> 'w12 12 32) (new <arch-register> 'w13 13 32)
  (new <arch-register> 'w14 14 32) (new <arch-register> 'w15 15 32)
  (new <arch-register> 'w16 16 32) (new <arch-register> 'w17 17 32)
  (new <arch-register> 'w18 18 32) (new <arch-register> 'w19 19 32)
  (new <arch-register> 'w20 20 32) (new <arch-register> 'w21 21 32)
  (new <arch-register> 'w22 22 32) (new <arch-register> 'w23 23 32)
  (new <arch-register> 'w24 24 32) (new <arch-register> 'w25 25 32)
  (new <arch-register> 'w26 26 32) (new <arch-register> 'w27 27 32)
  (new <arch-register> 'w28 28 32) (new <arch-register> 'w29 29 32)
  (new <arch-register> 'w30 30 32) (new <arch-register> 'wsp 31 32)
  (new <arch-register> 'wzr 31 32)

  ;; Floating-point registers
  (new <arch-register> 'd0  0  64) (new <arch-register> 'd1  1  64)
  (new <arch-register> 'd2  2  64) (new <arch-register> 'd3  3  64)
  (new <arch-register> 'd4  4  64) (new <arch-register> 'd5  5  64)
  (new <arch-register> 'd6  6  64) (new <arch-register> 'd7  7  64)
  (new <arch-register> 's0  0  32) (new <arch-register> 's1  1  32)
  (new <arch-register> 's2  2  32) (new <arch-register> 's3  3  32)
  (new <arch-register> 's4  4  32) (new <arch-register> 's5  5  32)
  (new <arch-register> 's6  6  32) (new <arch-register> 's7  7  32)))

;; Comprehensive ARM64 Instructions (based on actual Maru usage)
(define arm64-instructions (list
  ;; Data Movement Instructions
  (new <arch-instruction> 'mov-imm-x
       '(mov immediate x-register)
       '(ir-set %2 %1)
       'arm64-mov-imm-x)
  
  (new <arch-instruction> 'mov-imm-w
       '(mov immediate w-register)
       '(ir-set %2 %1)
       'arm64-mov-imm-w)
  
  (new <arch-instruction> 'mov-x-x
       '(mov x-register x-register)
       '(ir-set %2 (ir-get %1))
       'arm64-mov-x-x)
  
  (new <arch-instruction> 'mov-w-w
       '(mov w-register w-register)
       '(ir-set %2 (ir-get %1))
       'arm64-mov-w-w)

  ;; Arithmetic Instructions
  (new <arch-instruction> 'add-x-x-x
       '(add x-register x-register x-register)
       '(ir-set %1 (ir-add (ir-get %2) (ir-get %3)))
       'arm64-add-x-x-x)
  
  (new <arch-instruction> 'add-w-w-w
       '(add w-register w-register w-register)
       '(ir-set %1 (ir-add (ir-get %2) (ir-get %3)))
       'arm64-add-w-w-w)
  
  (new <arch-instruction> 'add-x-x-imm
       '(add x-register x-register immediate)
       '(ir-set %1 (ir-add (ir-get %2) %3))
       'arm64-add-x-x-imm)
  
  (new <arch-instruction> 'sub-x-x-x
       '(sub x-register x-register x-register)
       '(ir-set %1 (ir-sub (ir-get %2) (ir-get %3)))
       'arm64-sub-x-x-x)
  
  (new <arch-instruction> 'sub-w-w-w
       '(sub w-register w-register w-register)
       '(ir-set %1 (ir-sub (ir-get %2) (ir-get %3)))
       'arm64-sub-w-w-w)

  ;; Load/Store Instructions
  (new <arch-instruction> 'ldr-x-mem
       '(ldr x-register memory-ref)
       '(ir-set %1 (ir-load %2))
       'arm64-ldr-x-mem)
  
  (new <arch-instruction> 'ldr-w-mem
       '(ldr w-register memory-ref)
       '(ir-set %1 (ir-load %2))
       'arm64-ldr-w-mem)
  
  (new <arch-instruction> 'str-x-mem
       '(str x-register memory-ref)
       '(ir-store %2 (ir-get %1))
       'arm64-str-x-mem)
  
  (new <arch-instruction> 'str-w-mem
       '(str w-register memory-ref)
       '(ir-store %2 (ir-get %1))
       'arm64-str-w-mem)
  
  ;; Load/Store Byte
  (new <arch-instruction> 'ldrb-w-mem
       '(ldrb w-register memory-ref)
       '(ir-set %1 (ir-load-byte %2))
       'arm64-ldrb-w-mem)
  
  (new <arch-instruction> 'strb-w-mem
       '(strb w-register memory-ref)
       '(ir-store-byte %2 (ir-get %1))
       'arm64-strb-w-mem)
  
  ;; Load/Store Halfword
  (new <arch-instruction> 'ldrh-w-mem
       '(ldrh w-register memory-ref)
       '(ir-set %1 (ir-load-half %2))
       'arm64-ldrh-w-mem)
  
  (new <arch-instruction> 'strh-w-mem
       '(strh w-register memory-ref)
       '(ir-store-half %2 (ir-get %1))
       'arm64-strh-w-mem)
  
  ;; Load/Store Pair
  (new <arch-instruction> 'ldp-x-x-mem
       '(ldp x-register x-register memory-ref)
       '(ir-load-pair %3 %1 %2)
       'arm64-ldp-x-x-mem)
  
  (new <arch-instruction> 'stp-x-x-mem
       '(stp x-register x-register memory-ref)
       '(ir-store-pair %3 %1 %2)
       'arm64-stp-x-x-mem)

  ;; Compare Instructions
  (new <arch-instruction> 'cmp-x-x
       '(cmp x-register x-register)
       '(ir-cmp (ir-get %1) (ir-get %2))
       'arm64-cmp-x-x)
  
  (new <arch-instruction> 'cmp-w-w
       '(cmp w-register w-register)
       '(ir-cmp (ir-get %1) (ir-get %2))
       'arm64-cmp-w-w)
  
  (new <arch-instruction> 'cmp-x-imm
       '(cmp x-register immediate)
       '(ir-cmp (ir-get %1) %2)
       'arm64-cmp-x-imm)
  
  (new <arch-instruction> 'cmp-w-imm
       '(cmp w-register immediate)
       '(ir-cmp (ir-get %1) %2)
       'arm64-cmp-w-imm)

  ;; Branch Instructions
  (new <arch-instruction> 'b-label
       '(b label)
       '(ir-branch %1)
       'arm64-b-label)
  
  (new <arch-instruction> 'bl-label
       '(bl label)
       '(ir-call %1)
       'arm64-bl-label)
  
  (new <arch-instruction> 'beq-label
       '(beq label)
       '(ir-branch-eq %1)
       'arm64-beq-label)
  
  (new <arch-instruction> 'bne-label
       '(bne label)
       '(ir-branch-ne %1)
       'arm64-bne-label)
  
  (new <arch-instruction> 'blr-x
       '(blr x-register)
       '(ir-call-reg %1)
       'arm64-blr-x)
  
  (new <arch-instruction> 'ret
       '(ret)
       '(ir-return)
       'arm64-ret)

  ;; Address Calculation
  (new <arch-instruction> 'adrp-x-label
       '(adrp x-register label)
       '(ir-set %1 (ir-page-addr %2))
       'arm64-adrp-x-label)

  ;; Conditional Set
  (new <arch-instruction> 'cset-x-cond
       '(cset x-register condition)
       '(ir-set %1 (ir-condition %2))
       'arm64-cset-x-cond)
  
  (new <arch-instruction> 'cset-w-cond
       '(cset w-register condition)
       '(ir-set %1 (ir-condition %2))
       'arm64-cset-w-cond)

  ;; Floating-point Instructions
  (new <arch-instruction> 'ldr-d-mem
       '(ldr d-register memory-ref)
       '(ir-set %1 (ir-load-fp64 %2))
       'arm64-ldr-d-mem)
  
  (new <arch-instruction> 'str-d-mem
       '(str d-register memory-ref)
       '(ir-store-fp64 %2 (ir-get %1))
       'arm64-str-d-mem)
  
  (new <arch-instruction> 'ldr-s-mem
       '(ldr s-register memory-ref)
       '(ir-set %1 (ir-load-fp32 %2))
       'arm64-ldr-s-mem)
  
  (new <arch-instruction> 'str-s-mem
       '(str s-register memory-ref)
       '(ir-store-fp32 %2 (ir-get %1))
       'arm64-str-s-mem)))

;; ARM64 Addressing Modes (enhanced)
(define arm64-addressing-modes (list
  ;; [register, #immediate] - with offset
  (new <arch-addressing-mode> 'reg-imm-offset
       '([ register , # immediate ])
       '(ir-mem-ref (ir-add (ir-get %1) %2)))
  
  ;; [register] - register indirect
  (new <arch-addressing-mode> 'reg-indirect
       '([ register ])
       '(ir-mem-ref (ir-get %1)))
  
  ;; [register, #immediate]! - pre-indexed
  (new <arch-addressing-mode> 'pre-indexed
       '([ register , # immediate ] !)
       '(ir-mem-ref (ir-pre-inc %1 %2)))
  
  ;; [register], #immediate - post-indexed
  (new <arch-addressing-mode> 'post-indexed
       '([ register ] , # immediate)
       '(ir-mem-ref (ir-post-inc %1 %2)))
  
  ;; [register, register] - register + register
  (new <arch-addressing-mode> 'reg-reg-offset
       '([ register , register ])
       '(ir-mem-ref (ir-add (ir-get %1) (ir-get %2))))))

;; Create comprehensive ARM64 architecture
(define arm64-architecture-complete
  (new <architecture> 'arm64 arm64-registers arm64-instructions arm64-addressing-modes))

;; Test the comprehensive specification
(println "=== Comprehensive ARM64 Architecture Specification ===")
(println "Architecture: " arm64-architecture-complete)
(println "Register count: " (list-length (<architecture>-registers arm64-architecture-complete)))
(println "Instruction count: " (list-length (<architecture>-instructions arm64-architecture-complete)))
(println "Addressing mode count: " (list-length (<architecture>-addressing-modes arm64-architecture-complete)))

(println "\nSample instruction set:")
(let ((insns (<architecture>-instructions arm64-architecture-complete))
      (count 0))
  (list-do insn insns
    (when (< count 10)
      (println "  " (<arch-instruction>-name insn) 
               " syntax: " (<arch-instruction>-syntax insn))
      (set count (+ count 1)))))

(println "\n=== Comprehensive ARM64 Specification Complete ===")