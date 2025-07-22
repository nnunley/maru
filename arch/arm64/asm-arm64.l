;;; asm-arm64.l -- Complete ARM64 Assembly Support  
;;; Uses generic asm-grammar.l and follows asm-common.k import pattern

;; Load generic assembler grammar (same pattern as gen-asm-x86.k)
(load "grammars/core/asm-grammar.l")

;; Complete ARM64 assembler infrastructure

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

/*** VECTOR REGISTERS ***/
#define _V0             0
#define _V1             1
#define _V2             2
#define _V3             3
#define _V4             4
#define _V5             5
#define _V6             6
#define _V7             7
#define _V8             8
#define _V9             9
#define _V10           10
#define _V11           11
#define _V12           12
#define _V13           13
#define _V14           14
#define _V15           15
#define _V16           16
#define _V17           17
#define _V18           18
#define _V19           19
#define _V20           20
#define _V21           21
#define _V22           22
#define _V23           23
#define _V24           24
#define _V25           25
#define _V26           26
#define _V27           27
#define _V28           28
#define _V29           29
#define _V30           30
#define _V31           31

/*** ARM64 ENCODING UTILITIES ***/
#define _REG(R)         ((R) & 0x1f)
#define _IMM6(I)        ((I) & 0x3f)
#define _IMM12(I)       ((I) & 0xfff)
#define _IMM16(I)       ((I) & 0xffff)
#define _IMM19(I)       ((I) & 0x7ffff)
#define _IMM26(I)       ((I) & 0x3ffffff)

;; Shift types
#define _LSL            0
#define _LSR            1
#define _ASR            2
#define _ROR            3

;; Extend types
#define _UXTB           0
#define _UXTH           1
#define _UXTW           2
#define _UXTX           3
#define _SXTB           4
#define _SXTH           5
#define _SXTW           6
#define _SXTX           7

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

/*** ARITHMETIC AND LOGICAL OPERATIONS ***/

;; Move operations
#define MOVr(RD, RM)            _W(0, 0xaa0003e0 | (_REG(RD) << 0) | (_REG(RM) << 16))
#define MOVwr(RD, RM)           _W(0, 0x2a0003e0 | (_REG(RD) << 0) | (_REG(RM) << 16))
#define MOVi(RD, IMM)           _W(0, 0xd2800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5))
#define MOVwi(RD, IMM)          _W(0, 0x52800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5))
#define MOVKi(RD, IMM, SHIFT)   _W(0, 0xf2800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))
#define MOVNi(RD, IMM, SHIFT)   _W(0, 0x92800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))
#define MOVZi(RD, IMM, SHIFT)   _W(0, 0xd2800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))

;; Data Processing - Immediate
#define ADDi(RD, RN, IMM)       _W(0, 0x91000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define ADDwi(RD, RN, IMM)      _W(0, 0x11000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define ADDSi(RD, RN, IMM)      _W(0, 0xb1000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define ADDSwi(RD, RN, IMM)     _W(0, 0x31000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))

#define SUBi(RD, RN, IMM)       _W(0, 0xd1000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define SUBwi(RD, RN, IMM)      _W(0, 0x51000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define SUBSi(RD, RN, IMM)      _W(0, 0xf1000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define SUBSwi(RD, RN, IMM)     _W(0, 0x71000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))

;; Data Processing - Register  
#define ADDr(RD, RN, RM)        _W(0, 0x8b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ADDwr(RD, RN, RM)       _W(0, 0x0b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ADDSr(RD, RN, RM)       _W(0, 0xab000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ADDSwr(RD, RN, RM)      _W(0, 0x2b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

#define SUBr(RD, RN, RM)        _W(0, 0xcb000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define SUBwr(RD, RN, RM)       _W(0, 0x4b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define SUBSr(RD, RN, RM)       _W(0, 0xeb000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define SUBSwr(RD, RN, RM)      _W(0, 0x6b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Logical operations - Register
#define ANDr(RD, RN, RM)        _W(0, 0x8a000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ANDwr(RD, RN, RM)       _W(0, 0x0a000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ANDSr(RD, RN, RM)       _W(0, 0xea000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ANDSwr(RD, RN, RM)      _W(0, 0x6a000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

#define ORRr(RD, RN, RM)        _W(0, 0xaa000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ORRwr(RD, RN, RM)       _W(0, 0x2a000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

#define EORr(RD, RN, RM)        _W(0, 0xca000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define EORwr(RD, RN, RM)       _W(0, 0x4a000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Logical immediate operations
#define ANDi(RD, RN, IMM)       _W(0, 0x92000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))
#define ANDwi(RD, RN, IMM)      _W(0, 0x12000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))
#define ORRi(RD, RN, IMM)       _W(0, 0xb2000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))
#define ORRwi(RD, RN, IMM)      _W(0, 0x32000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))
#define EORi(RD, RN, IMM)       _W(0, 0xd2000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))
#define EORwi(RD, RN, IMM)      _W(0, 0x52000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))

/*** LOAD/STORE OPERATIONS ***/

;; Load/Store register - 64-bit and 32-bit variants
#define LDRi(RT, RN, IMM)       _W(0, 0xf9400000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/8)) << 10))
#define LDRwi(RT, RN, IMM)      _W(0, 0xb9400000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/4)) << 10))
#define LDRhi(RT, RN, IMM)      _W(0, 0x79400000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/2)) << 10))
#define LDRbi(RT, RN, IMM)      _W(0, 0x39400000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))

#define LDRr(RT, RN, RM)        _W(0, 0xf8600800 | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LDRwr(RT, RN, RM)       _W(0, 0xb8600800 | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LDRhr(RT, RN, RM)       _W(0, 0x78600800 | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LDRbr(RT, RN, RM)       _W(0, 0x38600800 | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

#define STRi(RT, RN, IMM)       _W(0, 0xf9000000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/8)) << 10))
#define STRwi(RT, RN, IMM)      _W(0, 0xb9000000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/4)) << 10))
#define STRhi(RT, RN, IMM)      _W(0, 0x79000000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/2)) << 10))
#define STRbi(RT, RN, IMM)      _W(0, 0x39000000 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))

#define STRr(RT, RN, RM)        _W(0, 0xf8200800 | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define STRwr(RT, RN, RM)       _W(0, 0xb8200800 | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define STRhr(RT, RN, RM)       _W(0, 0x78200800 | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define STRbr(RT, RN, RM)       _W(0, 0x38200800 | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Pre/Post-indexed addressing
#define LDRpre(RT, RN, IMM)     _W(0, 0xf8400c00 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((IMM & 0x1ff) << 12))
#define LDRpost(RT, RN, IMM)    _W(0, 0xf8400400 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((IMM & 0x1ff) << 12))
#define STRpre(RT, RN, IMM)     _W(0, 0xf8000c00 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((IMM & 0x1ff) << 12))
#define STRpost(RT, RN, IMM)    _W(0, 0xf8000400 | (_REG(RT) << 0) | (_REG(RN) << 5) | ((IMM & 0x1ff) << 12))

;; Load/Store Pair operations
#define LDPi(RT1, RT2, RN, IMM) _W(0, 0xa9400000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15))
#define LDPwi(RT1, RT2, RN, IMM) _W(0, 0x29400000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/4) & 0x7f) << 15))
#define STPi(RT1, RT2, RN, IMM) _W(0, 0xa9000000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15))
#define STPwi(RT1, RT2, RN, IMM) _W(0, 0x29000000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/4) & 0x7f) << 15))

;; Pre/Post-indexed pair addressing
#define STPpre(RT1, RT2, RN, IMM) _W(0, 0xa9800000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15))
#define STPwpre(RT1, RT2, RN, IMM) _W(0, 0x29800000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/4) & 0x7f) << 15))
#define LDPpost(RT1, RT2, RN, IMM) _W(0, 0xa8c00000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15))
#define LDPwpost(RT1, RT2, RN, IMM) _W(0, 0x28c00000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/4) & 0x7f) << 15))

/*** COMPARISON OPERATIONS ***/

;; Compare operations
#define CMPi(RN, IMM)           _W(0, 0xf100001f | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define CMPwi(RN, IMM)          _W(0, 0x7100001f | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define CMPr(RN, RM)            _W(0, 0xeb00001f | (_REG(RN) << 5) | (_REG(RM) << 16))
#define CMPwr(RN, RM)           _W(0, 0x6b00001f | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Compare negative operations
#define CMNi(RN, IMM)           _W(0, 0xb100001f | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define CMNwi(RN, IMM)          _W(0, 0x3100001f | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))
#define CMNr(RN, RM)            _W(0, 0xab00001f | (_REG(RN) << 5) | (_REG(RM) << 16))
#define CMNwr(RN, RM)           _W(0, 0x2b00001f | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Test operations  
#define TSTr(RN, RM)            _W(0, 0xea00001f | (_REG(RN) << 5) | (_REG(RM) << 16))
#define TSTwr(RN, RM)           _W(0, 0x6a00001f | (_REG(RN) << 5) | (_REG(RM) << 16))
#define TSTi(RN, IMM)           _W(0, 0xf200001f | (_REG(RN) << 5) | ((IMM) << 10))
#define TSTwi(RN, IMM)          _W(0, 0x7200001f | (_REG(RN) << 5) | ((IMM) << 10))

/*** BRANCH AND CONTROL OPERATIONS ***/

;; Unconditional branches
#define B(OFFSET)               _W(0, 0x14000000 | (_IMM26((OFFSET)/4)))
#define BL(OFFSET)              _W(0, 0x94000000 | (_IMM26((OFFSET)/4)))
#define BLR(RN)                 _W(0, 0xd63f0000 | (_REG(RN) << 5))
#define BR(RN)                  _W(0, 0xd61f0000 | (_REG(RN) << 5))
#define RET()                   _W(0, 0xd65f03c0)
#define RETr(RN)                _W(0, 0xd65f0000 | (_REG(RN) << 5))

;; Conditional branches
#define Bcc(COND, OFFSET)       _W(0, 0x54000000 | (COND) | ((_IMM19((OFFSET)/4)) << 5))
#define BEQ(OFFSET)             (Bcc(_EQ, OFFSET))
#define BNE(OFFSET)             (Bcc(_NE, OFFSET))
#define BCS(OFFSET)             (Bcc(_CS, OFFSET))
#define BCC(OFFSET)             (Bcc(_CC, OFFSET))
#define BMI(OFFSET)             (Bcc(_MI, OFFSET))
#define BPL(OFFSET)             (Bcc(_PL, OFFSET))
#define BVS(OFFSET)             (Bcc(_VS, OFFSET))
#define BVC(OFFSET)             (Bcc(_VC, OFFSET))
#define BHI(OFFSET)             (Bcc(_HI, OFFSET))
#define BLS(OFFSET)             (Bcc(_LS, OFFSET))
#define BGE(OFFSET)             (Bcc(_GE, OFFSET))
#define BLT(OFFSET)             (Bcc(_LT, OFFSET))
#define BGT(OFFSET)             (Bcc(_GT, OFFSET))
#define BLE(OFFSET)             (Bcc(_LE, OFFSET))

;; Branch aliases
#define BLO             BCC
#define BHS             BCS

;; Compare and branch
#define CBZ(RT, LABEL)          _W(0, 0xb4000000 | (_REG(RT) << 0) | ((_IMM19((LABEL)/4)) << 5))
#define CBZw(RT, LABEL)         _W(0, 0x34000000 | (_REG(RT) << 0) | ((_IMM19((LABEL)/4)) << 5))
#define CBNZ(RT, LABEL)         _W(0, 0xb5000000 | (_REG(RT) << 0) | ((_IMM19((LABEL)/4)) << 5))
#define CBNZw(RT, LABEL)        _W(0, 0x35000000 | (_REG(RT) << 0) | ((_IMM19((LABEL)/4)) << 5))

;; Test bit and branch
#define TBZ(RT, BIT, LABEL)     _W(0, 0x36000000 | (_REG(RT) << 0) | ((BIT & 0x1f) << 19) | ((_IMM19((LABEL)/4)) << 5))
#define TBNZ(RT, BIT, LABEL)    _W(0, 0x37000000 | (_REG(RT) << 0) | ((BIT & 0x1f) << 19) | ((_IMM19((LABEL)/4)) << 5))

/*** SHIFT AND BIT MANIPULATION ***/

;; Logical shift operations
#define LSL(RD, RN, RM)         _W(0, 0x9ac02000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LSLw(RD, RN, RM)        _W(0, 0x1ac02000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LSLi(RD, RN, IMM)       _W(0, 0xd3400000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16))
#define LSLwi(RD, RN, IMM)      _W(0, 0x53000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16))

#define LSR(RD, RN, RM)         _W(0, 0x9ac02400 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LSRw(RD, RN, RM)        _W(0, 0x1ac02400 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LSRi(RD, RN, IMM)       _W(0, 0xd3400000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16) | (1 << 22))
#define LSRwi(RD, RN, IMM)      _W(0, 0x53007c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16))

#define ASR(RD, RN, RM)         _W(0, 0x9ac02800 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ASRw(RD, RN, RM)        _W(0, 0x1ac02800 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ASRi(RD, RN, IMM)       _W(0, 0x9340fc00 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16))
#define ASRwi(RD, RN, IMM)      _W(0, 0x13007c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16))

#define ROR(RD, RN, RM)         _W(0, 0x9ac02c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define RORw(RD, RN, RM)        _W(0, 0x1ac02c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Bit field operations
#define BFM(RD, RN, IMMR, IMMS) _W(0, 0xb3000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))
#define BFMw(RD, RN, IMMR, IMMS) _W(0, 0x33000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))
#define UBFM(RD, RN, IMMR, IMMS) _W(0, 0xd3000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))
#define UBFMw(RD, RN, IMMR, IMMS) _W(0, 0x53000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))
#define SBFM(RD, RN, IMMR, IMMS) _W(0, 0x93000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))
#define SBFMw(RD, RN, IMMR, IMMS) _W(0, 0x13000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))

;; Extract operations
#define EXTR(RD, RN, RM, LSB)   _W(0, 0x93c00000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | ((_IMM6(LSB)) << 10))
#define EXTRw(RD, RN, RM, LSB)  _W(0, 0x13800000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | ((_IMM6(LSB)) << 10))

;; Bit reversal and counting
#define RBIT(RD, RN)            _W(0, 0xdac00000 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define RBITw(RD, RN)           _W(0, 0x5ac00000 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define REV(RD, RN)             _W(0, 0xdac00800 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define REVw(RD, RN)            _W(0, 0x5ac00800 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define REV16(RD, RN)           _W(0, 0xdac00400 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define REV16w(RD, RN)          _W(0, 0x5ac00400 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define REV32(RD, RN)           _W(0, 0xdac00800 | (_REG(RD) << 0) | (_REG(RN) << 5))

#define CLZ(RD, RN)             _W(0, 0xdac01000 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define CLZw(RD, RN)            _W(0, 0x5ac01000 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define CLS(RD, RN)             _W(0, 0xdac01400 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define CLSw(RD, RN)            _W(0, 0x5ac01400 | (_REG(RD) << 0) | (_REG(RN) << 5))

/*** MULTIPLY AND DIVIDE ***/

;; Multiply operations
#define MUL(RD, RN, RM)         _W(0, 0x9b007c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define MULw(RD, RN, RM)        _W(0, 0x1b007c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define MADD(RD, RN, RM, RA)    _W(0, 0x9b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | (_REG(RA) << 10))
#define MADDw(RD, RN, RM, RA)   _W(0, 0x1b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | (_REG(RA) << 10))
#define MSUB(RD, RN, RM, RA)    _W(0, 0x9b008000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | (_REG(RA) << 10))
#define MSUBw(RD, RN, RM, RA)   _W(0, 0x1b008000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | (_REG(RA) << 10))

;; High multiply operations
#define SMULH(RD, RN, RM)       _W(0, 0x9b407c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define UMULH(RD, RN, RM)       _W(0, 0x9bc07c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Divide operations
#define SDIV(RD, RN, RM)        _W(0, 0x9ac00c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define SDIVw(RD, RN, RM)       _W(0, 0x1ac00c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define UDIV(RD, RN, RM)        _W(0, 0x9ac00800 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define UDIVw(RD, RN, RM)       _W(0, 0x1ac00800 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

/*** SIGN AND ZERO EXTENSION ***/

;; Sign extension operations
#define SXTB(RD, RN)            _W(0, 0x93401c00 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define SXTBw(RD, RN)           _W(0, 0x13001c00 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define SXTH(RD, RN)            _W(0, 0x93403c00 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define SXTHw(RD, RN)           _W(0, 0x13003c00 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define SXTW(RD, RN)            _W(0, 0x93407c00 | (_REG(RD) << 0) | (_REG(RN) << 5))

;; Zero extension operations
#define UXTB(RD, RN)            _W(0, 0xd3401c00 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define UXTBw(RD, RN)           _W(0, 0x53001c00 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define UXTH(RD, RN)            _W(0, 0xd3403c00 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define UXTHw(RD, RN)           _W(0, 0x53003c00 | (_REG(RD) << 0) | (_REG(RN) << 5))

/*** CALLING CONVENTION HELPERS ***/

;; macOS ARM64 calling convention
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

;; Standard function prologue/epilogue macros
#define PROLOGUE()              (STPpre(FRAME_PTR, LINK_REG, STACK_PTR, -16), MOVr(FRAME_PTR, STACK_PTR))
#define EPILOGUE()              (LDPpost(FRAME_PTR, LINK_REG, STACK_PTR, 16), RET())

;; Stack frame management
#define ALLOC_STACK(SIZE)       SUBi(STACK_PTR, STACK_PTR, SIZE)
#define DEALLOC_STACK(SIZE)     ADDi(STACK_PTR, STACK_PTR, SIZE)

;; Register save/restore helpers
#define SAVE_REGS()             (STPpre(_X19, _X20, STACK_PTR, -16), STPpre(_X21, _X22, STACK_PTR, -16))
#define RESTORE_REGS()          (LDPpost(_X21, _X22, STACK_PTR, 16), LDPpost(_X19, _X20, STACK_PTR, 16))

/*** SYSTEM AND SPECIAL OPERATIONS ***/

;; Hint instructions
#define NOP()                   _W(0, 0xd503201f)
#define YIELD()                 _W(0, 0xd503203f)
#define WFE()                   _W(0, 0xd503205f)
#define WFI()                   _W(0, 0xd503207f)
#define SEV()                   _W(0, 0xd503209f)
#define SEVL()                  _W(0, 0xd50320bf)

;; Memory barrier instructions
#define DSB_SY()                _W(0, 0xd5033f9f)
#define DSB_LD()                _W(0, 0xd5033dbf)
#define DSB_ST()                _W(0, 0xd5033abf)
#define DMB_SY()                _W(0, 0xd5033bbf)
#define DMB_LD()                _W(0, 0xd50339bf)
#define DMB_ST()                _W(0, 0xd50338bf)
#define ISB()                   _W(0, 0xd5033fdf)

;; Exception generation
#define BRK(IMM)                _W(0, 0xd4200000 | ((_IMM16(IMM)) << 5))
#define HLT(IMM)                _W(0, 0xd4400000 | ((_IMM16(IMM)) << 5))
#define SVC(IMM)                _W(0, 0xd4000001 | ((_IMM16(IMM)) << 5))
#define HVC(IMM)                _W(0, 0xd4000002 | ((_IMM16(IMM)) << 5))
#define SMC(IMM)                _W(0, 0xd4000003 | ((_IMM16(IMM)) << 5))

;; Cache maintenance operations
#define IC_IALLUIS()            _W(0, 0xd50871ff)
#define IC_IALLU()              _W(0, 0xd508751f)
#define IC_IVAU(RT)             _W(0, 0xd5087520 | (_REG(RT) << 0))
#define DC_IVAC(RT)             _W(0, 0xd5087620 | (_REG(RT) << 0))
#define DC_ISW(RT)              _W(0, 0xd5087640 | (_REG(RT) << 0))
#define DC_CVAC(RT)             _W(0, 0xd50b7a20 | (_REG(RT) << 0))
#define DC_CSW(RT)              _W(0, 0xd50b7a40 | (_REG(RT) << 0))
#define DC_CVAU(RT)             _W(0, 0xd50b7b20 | (_REG(RT) << 0))
#define DC_CIVAC(RT)            _W(0, 0xd50b7e20 | (_REG(RT) << 0))
#define DC_CISW(RT)             _W(0, 0xd50b7e40 | (_REG(RT) << 0))

/*** ARM64 EXCLUSIVE ACCESS OPERATIONS ***/

;; Load/Store exclusive for atomic operations
#define LDXR(RT, RN)            _W(0, 0xc85f7c00 | (_REG(RT) << 0) | (_REG(RN) << 5))
#define LDXRw(RT, RN)           _W(0, 0x885f7c00 | (_REG(RT) << 0) | (_REG(RN) << 5))
#define LDXRh(RT, RN)           _W(0, 0x485f7c00 | (_REG(RT) << 0) | (_REG(RN) << 5))
#define LDXRb(RT, RN)           _W(0, 0x085f7c00 | (_REG(RT) << 0) | (_REG(RN) << 5))

#define STXR(RS, RT, RN)        _W(0, 0xc8007c00 | (_REG(RS) << 16) | (_REG(RT) << 0) | (_REG(RN) << 5))
#define STXRw(RS, RT, RN)       _W(0, 0x88007c00 | (_REG(RS) << 16) | (_REG(RT) << 0) | (_REG(RN) << 5))
#define STXRh(RS, RT, RN)       _W(0, 0x48007c00 | (_REG(RS) << 16) | (_REG(RT) << 0) | (_REG(RN) << 5))
#define STXRb(RS, RT, RN)       _W(0, 0x08007c00 | (_REG(RS) << 16) | (_REG(RT) << 0) | (_REG(RN) << 5))

;; Load/Store exclusive pair
#define LDXP(RT1, RT2, RN)      _W(0, 0xc87f0000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5))
#define LDXPw(RT1, RT2, RN)     _W(0, 0x887f0000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5))
#define STXP(RS, RT1, RT2, RN)  _W(0, 0xc8200000 | (_REG(RS) << 16) | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5))
#define STXPw(RS, RT1, RT2, RN) _W(0, 0x88200000 | (_REG(RS) << 16) | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5))

;; Acquire/Release exclusive
#define LDAXR(RT, RN)           _W(0, 0xc85ffc00 | (_REG(RT) << 0) | (_REG(RN) << 5))
#define LDAXRw(RT, RN)          _W(0, 0x885ffc00 | (_REG(RT) << 0) | (_REG(RN) << 5))
#define STLXR(RS, RT, RN)       _W(0, 0xc800fc00 | (_REG(RS) << 16) | (_REG(RT) << 0) | (_REG(RN) << 5))
#define STLXRw(RS, RT, RN)      _W(0, 0x8800fc00 | (_REG(RS) << 16) | (_REG(RT) << 0) | (_REG(RN) << 5))

/*** POINTER AUTHENTICATION (ARMv8.3-A) ***/

;; Pointer authentication with key A
#define PACIA(RD, RN)           _W(0, 0xdac10000 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define PACIB(RD, RN)           _W(0, 0xdac10400 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define PACDA(RD, RN)           _W(0, 0xdac10800 | (_REG(RD) << 0) | (_REG(RN) << 5))
#define PACDB(RD, RN)           _W(0, 0xdac10c00 | (_REG(RD) << 0) | (_REG(RN) << 5))

;; Pointer authentication using zero
#define PACIASP()               _W(0, 0xd503233f)
#define PACIBSP()               _W(0, 0xd503237f)
#define AUTIASP()               _W(0, 0xd50323bf)
#define AUTIBSP()               _W(0, 0xd50323ff)

/*** 64-BIT SPECIFIC ADDRESSING AND OPERATIONS ***/

;; Address generation for 64-bit pointers
#define ADRP(RD, OFFSET)        _W(0, 0x90000000 | (_REG(RD) << 0) | ((((OFFSET) >> 12) & 0x3) << 29) | (((((OFFSET) >> 12) >> 2) & 0x7ffff) << 5))
#define ADR(RD, OFFSET)         _W(0, 0x10000000 | (_REG(RD) << 0) | ((OFFSET & 0x3) << 29) | (((OFFSET >> 2) & 0x7ffff) << 5))

;; 64-bit immediate loading (for large constants)
#define MOVZ64(RD, IMM, SHIFT)  _W(0, 0xd2800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))
#define MOVN64(RD, IMM, SHIFT)  _W(0, 0x92800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))
#define MOVK64(RD, IMM, SHIFT)  _W(0, 0xf2800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))

;; 64-bit load literal
#define LDR_literal(RT, OFFSET) _W(0, 0x58000000 | (_REG(RT) << 0) | ((_IMM19((OFFSET)/4)) << 5))

/*** SIMD/FLOATING POINT BASIC OPERATIONS ***/

;; SIMD load/store
#define LDR_Q(VT, RN, IMM)      _W(0, 0x3dc00000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/16)) << 10))
#define LDR_D(VT, RN, IMM)      _W(0, 0xfd400000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/8)) << 10))
#define LDR_S(VT, RN, IMM)      _W(0, 0xbd400000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/4)) << 10))
#define LDR_H(VT, RN, IMM)      _W(0, 0x7d400000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/2)) << 10))
#define LDR_B(VT, RN, IMM)      _W(0, 0x3d400000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))

#define STR_Q(VT, RN, IMM)      _W(0, 0x3d800000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/16)) << 10))
#define STR_D(VT, RN, IMM)      _W(0, 0xfd000000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/8)) << 10))
#define STR_S(VT, RN, IMM)      _W(0, 0xbd000000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/4)) << 10))
#define STR_H(VT, RN, IMM)      _W(0, 0x7d000000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/2)) << 10))
#define STR_B(VT, RN, IMM)      _W(0, 0x3d000000 | (_REG(VT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))

;;; Complete ARM64 assembler infrastructure ready. Uses same pattern as gen-asm-x86.k:
;;; Generic grammar processes the architecture-specific #define statements.