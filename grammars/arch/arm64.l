;;; arm64.l -- ARM64 Architecture Assembler
;;; Uses the generic assembler grammar to process ARM64-specific definitions
;;; Consolidates scattered ARM64 work into unified architecture

;; Load the generic assembler grammar infrastructure
(load "grammars/core/assembler.l")

;; ARM64-specific assembler definitions start here
;; The generic grammar will process these #define statements

/*** ARM64 REGISTER DEFINITIONS ***/

;; 64-bit general purpose registers (X0-X30, XZR, SP)
#define _X0             0
#define _X1             1
#define _X2             2
#define _X3             3
#define _X4             4
#define _X5             5
#define _X6             6
#define _X7             7
#define _X8             8
#define _X9             9
#define _X10           10
#define _X11           11
#define _X12           12
#define _X13           13
#define _X14           14
#define _X15           15
#define _X16           16
#define _X17           17
#define _X18           18
#define _X19           19
#define _X20           20
#define _X21           21
#define _X22           22
#define _X23           23
#define _X24           24
#define _X25           25
#define _X26           26
#define _X27           27
#define _X28           28
#define _X29           29  /* Frame pointer */
#define _X30           30  /* Link register */
#define _XZR           31  /* Zero register */
#define _SP            31  /* Stack pointer (context-dependent with XZR) */

;; 32-bit general purpose registers (W0-W30, WZR, WSP)
#define _W0             0
#define _W1             1
#define _W2             2
#define _W3             3
#define _W4             4
#define _W5             5
#define _W6             6
#define _W7             7
#define _W8             8
#define _W9             9
#define _W10           10
#define _W11           11
#define _W12           12
#define _W13           13
#define _W14           14
#define _W15           15
#define _W16           16
#define _W17           17
#define _W18           18
#define _W19           19
#define _W20           20
#define _W21           21
#define _W22           22
#define _W23           23
#define _W24           24
#define _W25           25
#define _W26           26
#define _W27           27
#define _W28           28
#define _W29           29
#define _W30           30
#define _WZR           31
#define _WSP           31

/*** ARM64 INSTRUCTION ENCODING HELPERS ***/

#define _REG(R)         ((R) & 0x1f)
#define _IMM12(I)       ((I) & 0xfff)
#define _IMM16(I)       ((I) & 0xffff)
#define _IMM19(I)       ((I) & 0x7ffff)
#define _IMM26(I)       ((I) & 0x3ffffff)

;; Condition codes
#define _EQ             0x0
#define _NE             0x1
#define _CS             0x2  /* Carry set */
#define _CC             0x3  /* Carry clear */
#define _MI             0x4  /* Minus */
#define _PL             0x5  /* Plus */
#define _VS             0x6  /* Overflow set */
#define _VC             0x7  /* Overflow clear */
#define _HI             0x8  /* Higher */
#define _LS             0x9  /* Lower or same */
#define _GE             0xa  /* Greater or equal */
#define _LT             0xb  /* Less than */
#define _GT             0xc  /* Greater than */
#define _LE             0xd  /* Less or equal */
#define _AL             0xe  /* Always */

/*** ARM64 INSTRUCTION GENERATORS ***/

;; Data Processing - Immediate
#define MOVi(RD, IMM)           (_W(0, 0x52800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5)))
#define MOVwi(RD, IMM)          (_W(0, 0x12800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5)))

#define ADDi(RD, RN, IMM)       (_W(0, 0x91000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10)))
#define ADDwi(RD, RN, IMM)      (_W(0, 0x11000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10)))

#define SUBi(RD, RN, IMM)       (_W(0, 0xd1000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10)))
#define SUBwi(RD, RN, IMM)      (_W(0, 0x51000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10)))

;; Data Processing - Register  
#define MOVr(RD, RM)            (_W(0, 0xaa0003e0 | (_REG(RD) << 0) | (_REG(RM) << 16)))
#define MOVwr(RD, RM)           (_W(0, 0x2a0003e0 | (_REG(RD) << 0) | (_REG(RM) << 16)))

#define ADDr(RD, RN, RM)        (_W(0, 0x8b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16)))
#define ADDwr(RD, RN, RM)       (_W(0, 0x0b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16)))

#define SUBr(RD, RN, RM)        (_W(0, 0xcb000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16)))
#define SUBwr(RD, RN, RM)       (_W(0, 0x4b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16)))

;; Load/Store
#define LDRi(RT, RN, IMM)       (_W(0, 0xf9400000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/8)) << 10)))
#define LDRwi(RT, RN, IMM)      (_W(0, 0xb9400000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/4)) << 10)))

#define STRi(RT, RN, IMM)       (_W(0, 0xf9000000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/8)) << 10)))
#define STRwi(RT, RN, IMM)      (_W(0, 0xb9000000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/4)) << 10)))

;; Load/Store Pair
#define LDPi(RT1, RT2, RN, IMM) (_W(0, 0xa9400000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15)))
#define STPi(RT1, RT2, RN, IMM) (_W(0, 0xa9000000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15)))

;; Pre/Post-indexed addressing
#define STPpre(RT1, RT2, RN, IMM) (_W(0, 0xa9800000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15)))
#define LDPpost(RT1, RT2, RN, IMM) (_W(0, 0xa8c00000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15)))

;; Compare
#define CMPi(RN, IMM)           (_W(0, 0xf100001f | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10)))
#define CMPwi(RN, IMM)          (_W(0, 0x7100001f | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10)))
#define CMPr(RN, RM)            (_W(0, 0xeb00001f | (_REG(RN) << 5) | (_REG(RM) << 16)))
#define CMPwr(RN, RM)           (_W(0, 0x6b00001f | (_REG(RN) << 5) | (_REG(RM) << 16)))

;; Branches
#define B(OFFSET)               (_W(0, 0x14000000 | (_IMM26((OFFSET)/4))))
#define BL(OFFSET)              (_W(0, 0x94000000 | (_IMM26((OFFSET)/4))))
#define BLR(RN)                 (_W(0, 0xd63f0000 | (_REG(RN) << 5)))
#define BR(RN)                  (_W(0, 0xd61f0000 | (_REG(RN) << 5)))
#define RET()                   (_W(0, 0xd65f03c0))
#define RETr(RN)                (_W(0, 0xd65f0000 | (_REG(RN) << 5)))

;; Conditional branches
#define Bcc(COND, OFFSET)       (_W(0, 0x54000000 | (COND) | ((_IMM19((OFFSET)/4)) << 5)))
#define BEQ(OFFSET)             (Bcc(_EQ, OFFSET))
#define BNE(OFFSET)             (Bcc(_NE, OFFSET))
#define BGE(OFFSET)             (Bcc(_GE, OFFSET))
#define BLT(OFFSET)             (Bcc(_LT, OFFSET))
#define BGT(OFFSET)             (Bcc(_GT, OFFSET))
#define BLE(OFFSET)             (Bcc(_LE, OFFSET))

/*** ARM64 FUNCTION CALL CONVENTIONS ***/

;; macOS ARM64 calling convention helpers
#define ARG0                    _X0
#define ARG1                    _X1
#define ARG2                    _X2
#define ARG3                    _X3
#define ARG4                    _X4
#define ARG5                    _X5
#define ARG6                    _X6
#define ARG7                    _X7

#define RET_REG                 _X0
#define FRAME_PTR               _X29
#define LINK_REG                _X30
#define STACK_PTR               _SP

;; Standard function prologue/epilogue
#define PROLOGUE()              (STPpre(FRAME_PTR, LINK_REG, STACK_PTR, -16), MOVr(FRAME_PTR, STACK_PTR))
#define EPILOGUE()              (LDPpost(FRAME_PTR, LINK_REG, STACK_PTR, 16), RET())

;;; ARM64 assembler infrastructure is now ready.
;;; This consolidates the scattered ARM64 work into a unified architecture
;;; that follows the same pattern as x86: generic grammar + arch-specific definitions.