;;; arm64-complete.l -- Complete ARM64 Assembler with Pattern Reduction
;;; Consolidates all ARM64 work and uses pattern families for systematic organization

;; Load the enhanced assembler grammar with pattern reduction
(load "grammars/core/assembler-enhanced.l")

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

/*** ARM64 INSTRUCTION PATTERN FAMILIES ***/

;; Data Processing - Immediate Family
#define DEFINE_ARM64_IMM_FAMILY(NAME, BASE_OPCODE) \
  NAME##i(RD, RN, IMM)        _W(0, BASE_OPCODE | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10)) \
  NAME##wi(RD, RN, IMM)       _W(0, (BASE_OPCODE & 0x7f000000) | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10))

;; Data Processing - Register Family
#define DEFINE_ARM64_REG_FAMILY(NAME, BASE_OPCODE) \
  NAME##r(RD, RN, RM)         _W(0, BASE_OPCODE | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16)) \
  NAME##wr(RD, RN, RM)        _W(0, (BASE_OPCODE & 0x7f000000) | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Data Processing - Shifted Register Family
#define DEFINE_ARM64_SHIFT_FAMILY(NAME, BASE_OPCODE) \
  NAME##sr(RD, RN, RM, SHIFT, AMT) _W(0, BASE_OPCODE | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | ((SHIFT) << 22) | ((_IMM6(AMT)) << 10))

;; Load/Store Family
#define DEFINE_ARM64_LDST_FAMILY(NAME, BASE_OPCODE) \
  NAME##i(RT, RN, IMM)        _W(0, BASE_OPCODE | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/8)) << 10)) \
  NAME##wi(RT, RN, IMM)       _W(0, (BASE_OPCODE & 0x7f000000) | (_REG(RT) << 0) | (_REG(RN) << 5) | ((_IMM12(IMM/4)) << 10)) \
  NAME##r(RT, RN, RM)         _W(0, (BASE_OPCODE | 0x00200800) | (_REG(RT) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16)) \
  NAME##pre(RT, RN, IMM)      _W(0, (BASE_OPCODE | 0x00000c00) | (_REG(RT) << 0) | (_REG(RN) << 5) | ((IMM & 0x1ff) << 12)) \
  NAME##post(RT, RN, IMM)     _W(0, (BASE_OPCODE | 0x00000400) | (_REG(RT) << 0) | (_REG(RN) << 5) | ((IMM & 0x1ff) << 12))

;; Compare Family  
#define DEFINE_ARM64_CMP_FAMILY(NAME, BASE_OPCODE) \
  NAME##i(RN, IMM)            _W(0, (BASE_OPCODE | 0x0000001f) | (_REG(RN) << 5) | ((_IMM12(IMM)) << 10)) \
  NAME##r(RN, RM)             _W(0, (BASE_OPCODE | 0x0000001f) | (_REG(RN) << 5) | (_REG(RM) << 16))

;; Branch Family
#define DEFINE_ARM64_BRANCH_FAMILY(NAME, CONDITION_CODE) \
  NAME(OFFSET)                _W(0, 0x54000000 | (CONDITION_CODE) | ((_IMM19((OFFSET)/4)) << 5))

/*** ARITHMETIC AND LOGICAL OPERATIONS ***/

;; Move operations
#define MOVr(RD, RM)            _W(0, 0xaa0003e0 | (_REG(RD) << 0) | (_REG(RM) << 16))
#define MOVwr(RD, RM)           _W(0, 0x2a0003e0 | (_REG(RD) << 0) | (_REG(RM) << 16))
#define MOVi(RD, IMM)           _W(0, 0xd2800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5))
#define MOVwi(RD, IMM)          _W(0, 0x52800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5))
#define MOVKi(RD, IMM, SHIFT)   _W(0, 0xf2800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))
#define MOVNi(RD, IMM, SHIFT)   _W(0, 0x92800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))
#define MOVZi(RD, IMM, SHIFT)   _W(0, 0xd2800000 | (_REG(RD) << 0) | ((_IMM16(IMM)) << 5) | (((SHIFT)/16) << 21))

// Arithmetic families using the pattern system
DEFINE_ARM64_IMM_FAMILY(ADD, 0x91000000)
DEFINE_ARM64_REG_FAMILY(ADD, 0x8b000000)
DEFINE_ARM64_SHIFT_FAMILY(ADD, 0x8b000000)

DEFINE_ARM64_IMM_FAMILY(SUB, 0xd1000000)  
DEFINE_ARM64_REG_FAMILY(SUB, 0xcb000000)
DEFINE_ARM64_SHIFT_FAMILY(SUB, 0xcb000000)

DEFINE_ARM64_REG_FAMILY(AND, 0x8a000000)
DEFINE_ARM64_REG_FAMILY(ORR, 0xaa000000) 
DEFINE_ARM64_REG_FAMILY(EOR, 0xca000000)

// Logical immediate operations
#define ANDi(RD, RN, IMM)       _W(0, 0x92000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))
#define ORRi(RD, RN, IMM)       _W(0, 0xb2000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))
#define EORi(RD, RN, IMM)       _W(0, 0xd2000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((IMM) << 10))

/*** LOAD/STORE OPERATIONS ***/
DEFINE_ARM64_LDST_FAMILY(LDR, 0xf9400000)
DEFINE_ARM64_LDST_FAMILY(STR, 0xf9000000)

;; Load/Store Pair operations
#define LDPi(RT1, RT2, RN, IMM) _W(0, 0xa9400000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15))
#define STPi(RT1, RT2, RN, IMM) _W(0, 0xa9000000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15))

;; Pre/Post-indexed addressing
#define STPpre(RT1, RT2, RN, IMM) _W(0, 0xa9800000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15))
#define LDPpost(RT1, RT2, RN, IMM) _W(0, 0xa8c00000 | (_REG(RT1) << 0) | (_REG(RT2) << 10) | (_REG(RN) << 5) | ((((IMM)/8) & 0x7f) << 15))

/*** COMPARISON OPERATIONS ***/
DEFINE_ARM64_CMP_FAMILY(CMP, 0xeb000000)
DEFINE_ARM64_CMP_FAMILY(CMN, 0xab000000)

;; Test operations  
#define TSTr(RN, RM)            _W(0, 0xea00001f | (_REG(RN) << 5) | (_REG(RM) << 16))
#define TSTi(RN, IMM)           _W(0, 0xf200001f | (_REG(RN) << 5) | ((IMM) << 10))

/*** BRANCH AND CONTROL OPERATIONS ***/

;; Unconditional branches
#define B(OFFSET)               _W(0, 0x14000000 | (_IMM26((OFFSET)/4)))
#define BL(OFFSET)              _W(0, 0x94000000 | (_IMM26((OFFSET)/4)))
#define BLR(RN)                 _W(0, 0xd63f0000 | (_REG(RN) << 5))
#define BR(RN)                  _W(0, 0xd61f0000 | (_REG(RN) << 5))
#define RET()                   _W(0, 0xd65f03c0)
#define RETr(RN)                _W(0, 0xd65f0000 | (_REG(RN) << 5))

;; Conditional branches using pattern families
DEFINE_ARM64_BRANCH_FAMILY(BEQ, _EQ)
DEFINE_ARM64_BRANCH_FAMILY(BNE, _NE)
DEFINE_ARM64_BRANCH_FAMILY(BCS, _CS)
DEFINE_ARM64_BRANCH_FAMILY(BCC, _CC)
DEFINE_ARM64_BRANCH_FAMILY(BMI, _MI)
DEFINE_ARM64_BRANCH_FAMILY(BPL, _PL)
DEFINE_ARM64_BRANCH_FAMILY(BVS, _VS)
DEFINE_ARM64_BRANCH_FAMILY(BVC, _VC)
DEFINE_ARM64_BRANCH_FAMILY(BHI, _HI)
DEFINE_ARM64_BRANCH_FAMILY(BLS, _LS)
DEFINE_ARM64_BRANCH_FAMILY(BGE, _GE)
DEFINE_ARM64_BRANCH_FAMILY(BLT, _LT)
DEFINE_ARM64_BRANCH_FAMILY(BGT, _GT)
DEFINE_ARM64_BRANCH_FAMILY(BLE, _LE)

;; Branch aliases
#define BLO             BCC
#define BHS             BCS

;; Compare and branch
#define CBZ(RT, LABEL)          _W(0, 0xb4000000 | (_REG(RT) << 0) | ((_IMM19((LABEL)/4)) << 5))
#define CBNZ(RT, LABEL)         _W(0, 0xb5000000 | (_REG(RT) << 0) | ((_IMM19((LABEL)/4)) << 5))
#define TBZ(RT, BIT, LABEL)     _W(0, 0x36000000 | (_REG(RT) << 0) | ((BIT & 0x1f) << 19) | ((_IMM19((LABEL)/4)) << 5))
#define TBNZ(RT, BIT, LABEL)    _W(0, 0x37000000 | (_REG(RT) << 0) | ((BIT & 0x1f) << 19) | ((_IMM19((LABEL)/4)) << 5))

/*** SHIFT AND BIT MANIPULATION ***/
#define LSL(RD, RN, RM)         _W(0, 0x9ac02000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LSLi(RD, RN, IMM)       _W(0, 0xd3400000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16))
#define LSR(RD, RN, RM)         _W(0, 0x9ac02400 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define LSRi(RD, RN, IMM)       _W(0, 0xd3400000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16) | (1 << 22))
#define ASR(RD, RN, RM)         _W(0, 0x9ac02800 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define ASRi(RD, RN, IMM)       _W(0, 0x9340fc00 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMM)) << 16))

;; Bit field operations
#define BFM(RD, RN, IMMR, IMMS) _W(0, 0xb3000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))
#define UBFM(RD, RN, IMMR, IMMS) _W(0, 0xd3000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))
#define SBFM(RD, RN, IMMR, IMMS) _W(0, 0x93000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | ((_IMM6(IMMR)) << 16) | ((_IMM6(IMMS)) << 10))

/*** MULTIPLY AND DIVIDE ***/
#define MUL(RD, RN, RM)         _W(0, 0x9b007c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define MADD(RD, RN, RM, RA)    _W(0, 0x9b000000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | (_REG(RA) << 10))
#define MSUB(RD, RN, RM, RA)    _W(0, 0x9b008000 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16) | (_REG(RA) << 10))
#define SMULH(RD, RN, RM)       _W(0, 0x9b407c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define UMULH(RD, RN, RM)       _W(0, 0x9bc07c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

#define SDIV(RD, RN, RM)        _W(0, 0x9ac00c00 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))
#define UDIV(RD, RN, RM)        _W(0, 0x9ac00800 | (_REG(RD) << 0) | (_REG(RN) << 5) | (_REG(RM) << 16))

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

/*** SYSTEM AND SPECIAL OPERATIONS ***/
#define NOP()                   _W(0, 0xd503201f)
#define YIELD()                 _W(0, 0xd503203f)
#define WFE()                   _W(0, 0xd503205f)
#define WFI()                   _W(0, 0xd503207f)
#define SEV()                   _W(0, 0xd503209f)
#define SEVL()                  _W(0, 0xd50320bf)

#define DSB_SY()                _W(0, 0xd5033f9f)
#define DSB_LD()                _W(0, 0xd5033dbf)
#define DSB_ST()                _W(0, 0xd5033abf)
#define DMB_SY()                _W(0, 0xd5033bbf)
#define DMB_LD()                _W(0, 0xd50339bf)
#define DMB_ST()                _W(0, 0xd50338bf)
#define ISB()                   _W(0, 0xd5033fdf)

;;; This complete ARM64 assembler provides comprehensive instruction coverage
;;; using pattern families to eliminate repetition while maintaining full
;;; architectural support for Apple Silicon and ARM64 development.