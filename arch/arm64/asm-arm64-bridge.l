;;; asm-arm64-bridge.l -- Bridge between new grammar-based assembler and IR layer
;;; Provides compatibility functions to allow IR generators to use new assembler

;; Load the new ARM64 assembler
(load "arch/arm64/asm-arm64.l")

;;; Bridge Functions - Map old IR function names to new assembler macros

;; The IR generator expects these function signatures:
;; ARM64_ADD_X (X Rd Rn Rm) - Add 64-bit registers
;; ARM64_SUB_X_IMM (X Rd Rn imm) - Subtract immediate from 64-bit register
;; etc.

;; Data Processing Instructions
(define-function ARM64_ADD_X (X Rd Rn Rm)
  (ADDr Rd Rn Rm X))

(define-function ARM64_ADD_X_IMM (X Rd Rn imm)
  (ADDi Rd Rn imm X))

(define-function ARM64_SUB_X (X Rd Rn Rm)
  (SUBr Rd Rn Rm X))

(define-function ARM64_SUB_X_IMM (X Rd Rn imm)
  (SUBi Rd Rn imm X))

(define-function ARM64_ADD_W (X Rd Rn Rm)
  (ADDwr Rd Rn Rm X))

(define-function ARM64_SUB_W (X Rd Rn Rm)
  (SUBwr Rd Rn Rm X))

;; Load/Store Instructions
(define-function ARM64_LDR_X (X Rt Rn imm)
  (LDRi Rt Rn imm X))

(define-function ARM64_STR_X (X Rt Rn imm)
  (STRi Rt Rn imm X))

(define-function ARM64_LDR_W (X Rt Rn imm)
  (LDRwi Rt Rn imm X))

(define-function ARM64_STR_W (X Rt Rn imm)
  (STRwi Rt Rn imm X))

;; Stack Operations (Load/Store Pair)
(define-function ARM64_STP_X (X Rt1 Rt2 Rn imm)
  (STPi Rt1 Rt2 Rn imm X))

(define-function ARM64_LDP_X (X Rt1 Rt2 Rn imm)
  (LDPi Rt1 Rt2 Rn imm X))

(define-function ARM64_STP_X_PRE (X Rt1 Rt2 Rn imm)
  (STPpre Rt1 Rt2 Rn imm X))

(define-function ARM64_LDP_X_POST (X Rt1 Rt2 Rn imm)
  (LDPpost Rt1 Rt2 Rn imm X))

;; Move Instructions
(define-function ARM64_MOV_X (X Rd Rm)
  (MOVr Rd Rm X))

(define-function ARM64_MOV_IMM (X Rd imm)
  (MOVi Rd imm X))

(define-function ARM64_MOVZ (X Rd imm shift)
  (MOVZi Rd imm shift X))

(define-function ARM64_MOVK (X Rd imm shift)
  (MOVKi Rd imm shift X))

;; Comparison Instructions
(define-function ARM64_CMP_X (X Rn Rm)
  (CMPr Rn Rm X))

(define-function ARM64_CMP_X_IMM (X Rn imm)
  (CMPi Rn imm X))

;; Branch Instructions
(define-function ARM64_B (X offset)
  (B offset X))

(define-function ARM64_BL (X offset)
  (BL offset X))

(define-function ARM64_BR (X Rn)
  (BR Rn X))

(define-function ARM64_BLR (X Rn)
  (BLR Rn X))

(define-function ARM64_RET (X)
  (RET X))

;; Conditional Branches
(define-function ARM64_BEQ (X offset)
  (BEQ offset X))

(define-function ARM64_BNE (X offset)
  (BNE offset X))

(define-function ARM64_BLT (X offset)
  (BLT offset X))

(define-function ARM64_BGT (X offset)
  (BGT offset X))

(define-function ARM64_BLE (X offset)
  (BLE offset X))

(define-function ARM64_BGE (X offset)
  (BGE offset X))

;; Logical Operations
(define-function ARM64_AND_X (X Rd Rn Rm)
  (ANDr Rd Rn Rm X))

(define-function ARM64_ORR_X (X Rd Rn Rm)
  (ORRr Rd Rn Rm X))

(define-function ARM64_EOR_X (X Rd Rn Rm)
  (EORr Rd Rn Rm X))

;; Shift Operations
(define-function ARM64_LSL (X Rd Rn Rm)
  (LSL Rd Rn Rm X))

(define-function ARM64_LSR (X Rd Rn Rm)
  (LSR Rd Rn Rm X))

(define-function ARM64_ASR (X Rd Rn Rm)
  (ASR Rd Rn Rm X))

;; Multiply Operations
(define-function ARM64_MUL (X Rd Rn Rm)
  (MUL Rd Rn Rm X))

(define-function ARM64_SDIV (X Rd Rn Rm)
  (SDIV Rd Rn Rm X))

(define-function ARM64_UDIV (X Rd Rn Rm)
  (UDIV Rd Rn Rm X))

;; System Instructions
(define-function ARM64_NOP (X)
  (NOP X))

;; Convenience Macros for Common Patterns
(define-function ARM64_PROLOGUE (X framesize)
  (PROLOGUE X))

(define-function ARM64_EPILOGUE (X)
  (EPILOGUE X))

;;; Export the bridge for use by IR generators
(provide 'asm-arm64-bridge)