;;; asm-x86-bridge.l -- Bridge between new grammar-based assembler and IR layer
;;; Provides compatibility layer to allow IR generators to use new assembler

;; Load the new x86 assembler
(load "arch/x86/asm-x86.l")

;;; Helper to emit instructions with proper formatting
(define-function emit-x86-insn (gen insn)
  ;; The new assembler returns bytecode, but IR gen expects string output
  ;; This would need integration with the emit infrastructure
  insn)

;;; Bridge Functions - Map IR generator patterns to new assembler macros

;; Movement Instructions
(define-function X86_MOV_REG_REG (gen dst src)
  (emit-x86-insn gen (MOVrr dst src)))

(define-function X86_MOV_IMM_REG (gen imm dst)
  (emit-x86-insn gen (MOVir imm dst)))

(define-function X86_MOV_MEM_REG (gen mem dst)
  ;; Memory addressing would need proper translation
  (emit-x86-insn gen (MOVmr 0 mem 0 1 dst)))

(define-function X86_MOV_REG_MEM (gen src mem)
  (emit-x86-insn gen (MOVrm src 0 mem 0 1)))

;; Arithmetic Instructions
(define-function X86_ADD_REG_REG (gen dst src)
  (emit-x86-insn gen (ADDrr dst src)))

(define-function X86_SUB_REG_REG (gen dst src)
  (emit-x86-insn gen (SUBrr dst src)))

(define-function X86_ADD_IMM_REG (gen imm dst)
  (emit-x86-insn gen (ADDir imm dst)))

;; Stack Operations
(define-function X86_PUSH_REG (gen reg)
  (emit-x86-insn gen (PUSHr reg)))

(define-function X86_POP_REG (gen reg)
  (emit-x86-insn gen (POPr reg)))

(define-function X86_PUSH_IMM (gen imm)
  (emit-x86-insn gen (PUSHir imm)))

;; Call and Jump Instructions
(define-function X86_CALL_REG (gen reg)
  (emit-x86-insn gen (CALLr reg)))

(define-function X86_CALL_IMM (gen target)
  (emit-x86-insn gen (CALLii target)))

(define-function X86_JMP_REG (gen reg)
  (emit-x86-insn gen (JMPr reg)))

(define-function X86_RET (gen)
  (emit-x86-insn gen (RET)))

;; Comparison and Conditional Jumps
(define-function X86_CMP_REG_REG (gen dst src)
  (emit-x86-insn gen (CMPrr dst src)))

(define-function X86_JE (gen target)
  (emit-x86-insn gen (JE target)))

(define-function X86_JNE (gen target)
  (emit-x86-insn gen (JNE target)))

;; Logical Operations
(define-function X86_AND_REG_REG (gen dst src)
  (emit-x86-insn gen (ANDrr dst src)))

(define-function X86_OR_REG_REG (gen dst src)
  (emit-x86-insn gen (ORrr dst src)))

(define-function X86_XOR_REG_REG (gen dst src)
  (emit-x86-insn gen (XORrr dst src)))

;; Note: Full integration would require:
;; 1. Mapping the string-based emission to bytecode emission
;; 2. Handling complex addressing modes
;; 3. Register allocation coordination
;; 4. Label and relocation management

(provide 'asm-x86-bridge)