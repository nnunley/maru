;; ARM64 Assembler - Instruction Encoding and Register Definitions
;; Based on the ARM Architecture Reference Manual for A-profile architecture

;; ARM64 Register Encodings
;; X0-X30: 64-bit general purpose registers
;; W0-W30: 32-bit views of X0-X30
;; SP: Stack pointer
;; XZR/WZR: Zero register

(define-constant _X0  0)   (define-constant _W0  0)
(define-constant _X1  1)   (define-constant _W1  1)
(define-constant _X2  2)   (define-constant _W2  2)
(define-constant _X3  3)   (define-constant _W3  3)
(define-constant _X4  4)   (define-constant _W4  4)
(define-constant _X5  5)   (define-constant _W5  5)
(define-constant _X6  6)   (define-constant _W6  6)
(define-constant _X7  7)   (define-constant _W7  7)
(define-constant _X8  8)   (define-constant _W8  8)
(define-constant _X9  9)   (define-constant _W9  9)
(define-constant _X10 10)  (define-constant _W10 10)
(define-constant _X11 11)  (define-constant _W11 11)
(define-constant _X12 12)  (define-constant _W12 12)
(define-constant _X13 13)  (define-constant _W13 13)
(define-constant _X14 14)  (define-constant _W14 14)
(define-constant _X15 15)  (define-constant _W15 15)
(define-constant _X16 16)  (define-constant _W16 16)
(define-constant _X17 17)  (define-constant _W17 17)
(define-constant _X18 18)  (define-constant _W18 18)
(define-constant _X19 19)  (define-constant _W19 19)
(define-constant _X20 20)  (define-constant _W20 20)
(define-constant _X21 21)  (define-constant _W21 21)
(define-constant _X22 22)  (define-constant _W22 22)
(define-constant _X23 23)  (define-constant _W23 23)
(define-constant _X24 24)  (define-constant _W24 24)
(define-constant _X25 25)  (define-constant _W25 25)
(define-constant _X26 26)  (define-constant _W26 26)
(define-constant _X27 27)  (define-constant _W27 27)
(define-constant _X28 28)  (define-constant _W28 28)
(define-constant _X29 29)  (define-constant _W29 29)  ; Frame pointer
(define-constant _X30 30)  (define-constant _W30 30)  ; Link register
(define-constant _SP  31)  (define-constant _WSP 31)  ; Stack pointer
(define-constant _XZR 31)  (define-constant _WZR 31)  ; Zero register

;; Floating-point registers
(define-constant _S0  0)   (define-constant _D0  0)
(define-constant _S1  1)   (define-constant _D1  1)
(define-constant _S2  2)   (define-constant _D2  2)
(define-constant _S3  3)   (define-constant _D3  3)
(define-constant _S4  4)   (define-constant _D4  4)
(define-constant _S5  5)   (define-constant _D5  5)
(define-constant _S6  6)   (define-constant _D6  6)
(define-constant _S7  7)   (define-constant _D7  7)
(define-constant _S8  8)   (define-constant _D8  8)
(define-constant _S9  9)   (define-constant _D9  9)
(define-constant _S10 10)  (define-constant _D10 10)
(define-constant _S11 11)  (define-constant _D11 11)
(define-constant _S12 12)  (define-constant _D12 12)
(define-constant _S13 13)  (define-constant _D13 13)
(define-constant _S14 14)  (define-constant _D14 14)
(define-constant _S15 15)  (define-constant _D15 15)
(define-constant _S16 16)  (define-constant _D16 16)
(define-constant _S17 17)  (define-constant _D17 17)
(define-constant _S18 18)  (define-constant _D18 18)
(define-constant _S19 19)  (define-constant _D19 19)
(define-constant _S20 20)  (define-constant _D20 20)
(define-constant _S21 21)  (define-constant _D21 21)
(define-constant _S22 22)  (define-constant _D22 22)
(define-constant _S23 23)  (define-constant _D23 23)
(define-constant _S24 24)  (define-constant _D24 24)
(define-constant _S25 25)  (define-constant _D25 25)
(define-constant _S26 26)  (define-constant _D26 26)
(define-constant _S27 27)  (define-constant _D27 27)
(define-constant _S28 28)  (define-constant _D28 28)
(define-constant _S29 29)  (define-constant _D29 29)
(define-constant _S30 30)  (define-constant _D30 30)
(define-constant _S31 31)  (define-constant _D31 31)

;; Helper functions for register validation and encoding
(define-function _rX (R) (and (>= R 0) (<= R 31) R))
(define-function _rW (R) (and (>= R 0) (<= R 31) R))
(define-function _rS (R) (and (>= R 0) (<= R 31) R))
(define-function _rD (R) (and (>= R 0) (<= R 31) R))

;; Immediate value validation
(define-function _imm12 (I) (and (>= I 0) (< I 4096) I))
(define-function _imm16 (I) (and (>= I 0) (< I 65536) I))
(define-function _imm26 (I) (and (>= I -33554432) (< I 33554432) I))  ; 2^25 = 33554432

;; ARM64 instruction encoding helpers
(define-function _arm64-encode (sf op S opcode Rm option imm3 Rn Rt)
  (| (| (| (| (| (| (| (| (<< sf 31) (<< op 30)) (<< S 29)) (<< opcode 21)) (<< Rm 16)) (<< option 13)) (<< imm3 10)) (<< Rn 5)) Rt))

;; Data processing instructions
(define-function _ARM64_ADD_IMM (sf op S sh imm12 Rn Rd)
  (| (| (| (| (| (| (<< sf 31) (<< op 30)) (<< S 29)) (<< 0x11 24)) (<< sh 22)) (<< imm12 10)) (<< Rn 5)) Rd))

(define-function _ARM64_ADD_REG (sf op S shift Rm imm6 Rn Rd)
  (| (| (| (| (| (| (| (<< sf 31) (<< op 30)) (<< S 29)) (<< 0x0B 24)) (<< shift 22)) (<< Rm 16)) (<< imm6 10)) (<< Rn 5)) Rd))

(define-function _ARM64_SUB_IMM (sf op S sh imm12 Rn Rd)
  (| (| (| (| (| (| (<< sf 31) (<< op 30)) (<< S 29)) (<< 0x51 24)) (<< sh 22)) (<< imm12 10)) (<< Rn 5)) Rd))

(define-function _ARM64_SUB_REG (sf op S shift Rm imm6 Rn Rd)
  (| (| (| (| (| (| (| (<< sf 31) (<< op 30)) (<< S 29)) (<< 0x4B 24)) (<< shift 22)) (<< Rm 16)) (<< imm6 10)) (<< Rn 5)) Rd))

;; Load/Store instructions
(define-function _ARM64_LDR_IMM (size opc imm12 Rn Rt)
  (| (| (| (| (<< size 30) (<< opc 22)) (<< 0x39 24)) (<< imm12 10)) (<< Rn 5)) Rt))

(define-function _ARM64_STR_IMM (size opc imm12 Rn Rt)
  (| (| (| (| (<< size 30) (<< opc 22)) (<< 0x39 24)) (<< imm12 10)) (<< Rn 5)) Rt))

(define-function _ARM64_LDP (opc L imm7 Rt2 Rn Rt)
  (| (| (| (| (| (<< opc 30) (<< 0x14 25)) (<< L 22)) (<< imm7 15)) (<< Rt2 10)) (<< Rn 5)) Rt))

(define-function _ARM64_STP (opc L imm7 Rt2 Rn Rt)
  (| (| (| (| (| (<< opc 30) (<< 0x14 25)) (<< L 22)) (<< imm7 15)) (<< Rt2 10)) (<< Rn 5)) Rt))

;; Move instructions
(define-function _ARM64_MOV_IMM (sf opc hw imm16 Rd)
  (| (| (| (| (<< sf 31) (<< opc 29)) (<< 0x25 23)) (<< hw 21)) (<< imm16 5)) Rd))

;; Compare instructions
(define-function _ARM64_CMP_IMM (sf op S sh imm12 Rn)
  (| (| (| (| (| (<< sf 31) (<< op 30)) (<< S 29)) (<< 0x51 24)) (<< sh 22)) (<< imm12 10)) (<< Rn 5)) 31))

(define-function _ARM64_CMP_REG (sf op S shift Rm imm6 Rn)
  (| (| (| (| (| (| (<< sf 31) (<< op 30)) (<< S 29)) (<< 0x4B 24)) (<< shift 22)) (<< Rm 16)) (<< imm6 10)) (<< Rn 5)) 31))

;; Branch instructions
(define-function _ARM64_B (op imm26)
  (| (| (<< op 31) (<< 0x5 26)) (<< imm26 0)))

(define-function _ARM64_BR (op opc op2 op3 Rn op4)
  (| (| (| (| (| (<< op 31) (<< opc 21)) (<< op2 16)) (<< op3 10)) (<< Rn 5)) op4))

(define-function _ARM64_BLR (Rn)
  (_ARM64_BR 1 0x1F 0 0 Rn 0))

;; Branch and Link instruction
(define-function _ARM64_BL (imm26)
  (| (| (<< 1 31) (<< 0x5 26)) (<< imm26 0)))

;; Conditional branch
(define-function _ARM64_BCOND (o1 imm19 o0 cond)
  (| (| (| (<< o1 24) (<< 0x2A 25)) (<< imm19 5)) (<< o0 4)) cond))

;; Instruction emitters - these emit 32-bit ARM64 instructions
(define-function ARM64_ADD_W (X Rd Rn Rm)
  (_L X (_ARM64_ADD_REG 0 0 0 0 (_rW Rm) 0 (_rW Rn) (_rW Rd))))

(define-function ARM64_ADD_X (X Rd Rn Rm)
  (_L X (_ARM64_ADD_REG 1 0 0 0 (_rX Rm) 0 (_rX Rn) (_rX Rd))))

(define-function ARM64_SUB_W (X Rd Rn Rm)
  (_L X (_ARM64_SUB_REG 0 1 0 0 (_rW Rm) 0 (_rW Rn) (_rW Rd))))

(define-function ARM64_SUB_X (X Rd Rn Rm)
  (_L X (_ARM64_SUB_REG 1 1 0 0 (_rX Rm) 0 (_rX Rn) (_rX Rd))))

(define-function ARM64_MOV_W_IMM (X Rd imm)
  (_L X (_ARM64_MOV_IMM 0 0x2 0 (_imm16 imm) (_rW Rd))))

(define-function ARM64_MOV_X_IMM (X Rd imm)
  (_L X (_ARM64_MOV_IMM 1 0x2 0 (_imm16 imm) (_rX Rd))))

(define-function ARM64_LDR_W_IMM (X Rt Rn imm)
  (_L X (_ARM64_LDR_IMM 0x2 0x1 (_imm12 (/ imm 4)) (_rX Rn) (_rW Rt))))

(define-function ARM64_LDR_X_IMM (X Rt Rn imm)
  (_L X (_ARM64_LDR_IMM 0x3 0x1 (_imm12 (/ imm 8)) (_rX Rn) (_rX Rt))))

(define-function ARM64_STR_W_IMM (X Rt Rn imm)
  (_L X (_ARM64_STR_IMM 0x2 0x0 (_imm12 (/ imm 4)) (_rX Rn) (_rW Rt))))

(define-function ARM64_STR_X_IMM (X Rt Rn imm)
  (_L X (_ARM64_STR_IMM 0x3 0x0 (_imm12 (/ imm 8)) (_rX Rn) (_rX Rt))))

(define-function ARM64_STP_X (X Rt1 Rt2 Rn imm)
  (_L X (_ARM64_STP 0x2 0x0 (/ imm 8) (_rX Rt2) (_rX Rn) (_rX Rt1))))

(define-function ARM64_LDP_X (X Rt1 Rt2 Rn imm)
  (_L X (_ARM64_LDP 0x2 0x1 (/ imm 8) (_rX Rt2) (_rX Rn) (_rX Rt1))))

(define-function ARM64_CMP_W_IMM (X Rn imm)
  (_L X (_ARM64_CMP_IMM 0 1 1 0 (_imm12 imm) (_rW Rn))))

(define-function ARM64_CMP_X_IMM (X Rn imm)
  (_L X (_ARM64_CMP_IMM 1 1 1 0 (_imm12 imm) (_rX Rn))))

(define-function ARM64_CMP_W_REG (X Rn Rm)
  (_L X (_ARM64_CMP_REG 0 1 1 0 (_rW Rm) 0 (_rW Rn))))

(define-function ARM64_CMP_X_REG (X Rn Rm)
  (_L X (_ARM64_CMP_REG 1 1 1 0 (_rX Rm) 0 (_rX Rn))))

(define-function ARM64_B (X imm26)
  (_L X (_ARM64_B 0 (_imm26 imm26))))

(define-function ARM64_BL (X imm26)
  (_L X (_ARM64_BL (_imm26 imm26))))

(define-function ARM64_BLR (X Rn)
  (_L X (_ARM64_BLR (_rX Rn))))

(define-function ARM64_RET (X)
  (_L X (_ARM64_BR 1 0x1F 0 2 _X30 0)))

;; Conditional branches
(define-function ARM64_BEQ (X imm19)
  (_L X (_ARM64_BCOND 0 imm19 0 0x0)))

(define-function ARM64_BNE (X imm19)
  (_L X (_ARM64_BCOND 0 imm19 0 0x1)))

;; High-level instruction macros
(define-function ARM64_PROLOGUE (X framesize)
  (ARM64_STP_X X _X29 _X30 _SP -16)  ; Pre-index: stp x29, x30, [sp, #-16]!
  (ARM64_ADD_X X _X29 _SP _XZR)      ; mov x29, sp
  (and (> framesize 16)
       (ARM64_SUB_X_IMM X _SP _SP (- framesize 16))))

(define-function ARM64_EPILOGUE (X)
  (ARM64_ADD_X X _SP _X29 _XZR)      ; mov sp, x29
  (ARM64_LDP_X X _X29 _X30 _SP 16)   ; Post-index: ldp x29, x30, [sp], #16
  (ARM64_RET X))

;; Floating-point load/store
(define-function ARM64_LDR_S_IMM (X Rt Rn imm)
  (_L X (_ARM64_LDR_IMM 0x2 0x1 (_imm12 (/ imm 4)) (_rX Rn) (_rS Rt))))

(define-function ARM64_LDR_D_IMM (X Rt Rn imm)
  (_L X (_ARM64_LDR_IMM 0x3 0x1 (_imm12 (/ imm 8)) (_rX Rn) (_rD Rt))))

(define-function ARM64_STR_S_IMM (X Rt Rn imm)
  (_L X (_ARM64_STR_IMM 0x2 0x0 (_imm12 (/ imm 4)) (_rX Rn) (_rS Rt))))

(define-function ARM64_STR_D_IMM (X Rt Rn imm)
  (_L X (_ARM64_STR_IMM 0x3 0x0 (_imm12 (/ imm 8)) (_rX Rn) (_rD Rt))))

;; ADRP/ADD for loading addresses
(define-function ARM64_ADRP (X Rd imm21)
  (_L X (| (| (<< 1 31) (<< (& imm21 0x3) 29)) (<< 0x10 24)) (<< (>> imm21 2) 5)) Rd))

(define-function ARM64_ADD_X_IMM (X Rd Rn imm)
  (_L X (_ARM64_ADD_IMM 1 0 0 0 (_imm12 imm) (_rX Rn) (_rX Rd))))

;; Conditional set instructions
(define-function ARM64_CSET_W (X Rd cond)
  (_L X (| (| (<< 0x1A 24) (<< 0x1 21)) (<< (^ cond 1) 12)) (<< 0x1F 5)) (<< 0x1F 16)) Rd))

(define-function ARM64_CSET_X (X Rd cond)
  (_L X (| (| (| (<< 1 31) (<< 0x1A 24)) (<< 0x1 21)) (<< (^ cond 1) 12)) (<< 0x1F 5)) (<< 0x1F 16)) Rd))

;; Load/store byte and halfword
(define-function ARM64_LDRB_IMM (X Rt Rn imm)
  (_L X (_ARM64_LDR_IMM 0x0 0x1 (_imm12 imm) (_rX Rn) (_rW Rt))))

(define-function ARM64_STRB_IMM (X Rt Rn imm)
  (_L X (_ARM64_STR_IMM 0x0 0x0 (_imm12 imm) (_rX Rn) (_rW Rt))))

(define-function ARM64_LDRH_IMM (X Rt Rn imm)
  (_L X (_ARM64_LDR_IMM 0x1 0x1 (_imm12 (/ imm 2)) (_rX Rn) (_rW Rt))))

(define-function ARM64_STRH_IMM (X Rt Rn imm)
  (_L X (_ARM64_STR_IMM 0x1 0x0 (_imm12 (/ imm 2)) (_rX Rn) (_rW Rt))))

;; Condition codes for conditional instructions
(define-constant _CC_EQ 0x0)  ; Equal
(define-constant _CC_NE 0x1)  ; Not equal
(define-constant _CC_CS 0x2)  ; Carry set
(define-constant _CC_CC 0x3)  ; Carry clear
(define-constant _CC_MI 0x4)  ; Minus/negative
(define-constant _CC_PL 0x5)  ; Plus/positive
(define-constant _CC_VS 0x6)  ; Overflow set
(define-constant _CC_VC 0x7)  ; Overflow clear
(define-constant _CC_HI 0x8)  ; Higher (unsigned)
(define-constant _CC_LS 0x9)  ; Lower or same (unsigned)
(define-constant _CC_GE 0xA)  ; Greater or equal (signed)
(define-constant _CC_LT 0xB)  ; Less than (signed)
(define-constant _CC_GT 0xC)  ; Greater than (signed)
(define-constant _CC_LE 0xD)  ; Less or equal (signed)
(define-constant _CC_AL 0xE)  ; Always
(define-constant _CC_NV 0xF)  ; Never