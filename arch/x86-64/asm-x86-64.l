;;; asm-x86-64.l -- Complete x86-64 Assembly Support
;;; Uses generic asm-grammar.l and follows asm-common.k import pattern

;; Load generic assembler grammar (same pattern as gen-asm-x86.k)
(load "grammars/core/asm-grammar.l")

;; Complete x86-64 assembler infrastructure

/*** BINARY CONSTANTS ***/
#define _b00            0
#define _b01            1
#define _b10            2
#define _b11            3
        
#define _b000           0
#define _b001           1
#define _b010           2
#define _b011           3
#define _b100           4
#define _b101           5
#define _b110           6
#define _b111           7

/*** COMPLETE x86-64 REGISTER DEFINITIONS ***/

;; 8-bit registers (low byte)
#define _AL             0x10
#define _CL             0x11
#define _DL             0x12
#define _BL             0x13
#define _SPL            0x14  /* x86-64 only */
#define _BPL            0x15  /* x86-64 only */
#define _SIL            0x16  /* x86-64 only */
#define _DIL            0x17  /* x86-64 only */
#define _R8B            0x18  /* x86-64 only */
#define _R9B            0x19  /* x86-64 only */
#define _R10B           0x1a  /* x86-64 only */
#define _R11B           0x1b  /* x86-64 only */
#define _R12B           0x1c  /* x86-64 only */
#define _R13B           0x1d  /* x86-64 only */
#define _R14B           0x1e  /* x86-64 only */
#define _R15B           0x1f  /* x86-64 only */

;; 8-bit registers (high byte) - not available with REX prefix
#define _AH             0x24
#define _CH             0x25
#define _DH             0x26
#define _BH             0x27

;; 16-bit registers
#define _AX             0x30
#define _CX             0x31
#define _DX             0x32
#define _BX             0x33
#define _SP             0x34
#define _BP             0x35
#define _SI             0x36
#define _DI             0x37
#define _R8W            0x38  /* x86-64 only */
#define _R9W            0x39  /* x86-64 only */
#define _R10W           0x3a  /* x86-64 only */
#define _R11W           0x3b  /* x86-64 only */
#define _R12W           0x3c  /* x86-64 only */
#define _R13W           0x3d  /* x86-64 only */
#define _R14W           0x3e  /* x86-64 only */
#define _R15W           0x3f  /* x86-64 only */

;; 32-bit registers
#define _EAX            0x40
#define _ECX            0x41
#define _EDX            0x42
#define _EBX            0x43
#define _ESP            0x44
#define _EBP            0x45
#define _ESI            0x46
#define _EDI            0x47
#define _R8D            0x48  /* x86-64 only */
#define _R9D            0x49  /* x86-64 only */
#define _R10D           0x4a  /* x86-64 only */
#define _R11D           0x4b  /* x86-64 only */
#define _R12D           0x4c  /* x86-64 only */
#define _R13D           0x4d  /* x86-64 only */
#define _R14D           0x4e  /* x86-64 only */
#define _R15D           0x4f  /* x86-64 only */

;; 64-bit registers (x86-64 only)
#define _RAX            0x80
#define _RCX            0x81
#define _RDX            0x82
#define _RBX            0x83
#define _RSP            0x84
#define _RBP            0x85
#define _RSI            0x86
#define _RDI            0x87
#define _R8             0x88
#define _R9             0x89
#define _R10            0x8a
#define _R11            0x8b
#define _R12            0x8c
#define _R13            0x8d
#define _R14            0x8e
#define _R15            0x8f

/*** REGISTER UTILITY MACROS ***/
#define _rS(R)          ((R)>>4)
#define _rN(R)          ((R)&0x7)
#define _rR(R)          ((R)&0xf)  /* Extended register number */

#define _r0P(R)         ((R)==0)
#define _rLP(R)         (((R)>=_AL)&&((R)<=_DIL))
#define _rHP(R)         (((R)>=_AH)&&((R)<=_BH))
#define _r1P(R)         (_rS(R)==1)
#define _r2P(R)         (_rS(R)==2)
#define _r3P(R)         (_rS(R)==3)
#define _r4P(R)         (_rS(R)==4)
#define _r8P(R)         (_rS(R)==8)

#define _rL(R)          (_rLP(R) ? _rN(R) : ASMFAIL( "8-bit register required"))
#define _rH(R)          (_rHP(R) ? _rN(R) : ASMFAIL( "8-bit H register required"))
#define _r1(R)          (_r1P(R) ? _rN(R) : ASMFAIL( "8-bit register required"))
#define _r2(R)          (_r2P(R) ? _rN(R) : ASMFAIL("16-bit register required"))
#define _r3(R)          (_r3P(R) ? _rN(R) : ASMFAIL("16-bit register required"))
#define _r4(R)          (_r4P(R) ? _rN(R) : ASMFAIL("32-bit register required"))
#define _r8(R)          (_r8P(R) ? _rR(R) : ASMFAIL("64-bit register required"))

#define _rRAX(R)        (((R)==_RAX) ? _rR(R) : ASMFAIL("RAX register required"))

/*** IMMEDIATE VALUE HANDLING ***/
#define _u1P(I)         (((I) & 0xffffff00) == 0)
#define _u2P(I)         (((I) & 0xffff0000) == 0)
#define _u4P(I)         (((unsigned long long)(I) & 0xffffffff00000000ULL) == 0)
#define _s1P(I)         (((I) >= -128) && ((I) <= 127))
#define _s2P(I)         (((I) >= -32768) && ((I) <= 32767))
#define _s4P(I)         (((I) >= -2147483648LL) && ((I) <= 2147483647LL))

#define _s1(I)          (_s1P(I) ? (I) : ASMFAIL( "8-bit signed immediate required"))
#define _s2(I)          (_s2P(I) ? (I) : ASMFAIL("16-bit signed immediate required"))
#define _s4(I)          (_s4P(I) ? (I) : ASMFAIL("32-bit signed immediate required"))
#define _u1(I)          (_u1P(I) ? (I) : ASMFAIL( "8-bit unsigned immediate required"))
#define _u2(I)          (_u2P(I) ? (I) : ASMFAIL("16-bit unsigned immediate required"))
#define _u4(I)          (_u4P(I) ? (I) : ASMFAIL("32-bit unsigned immediate required"))
#define _d1(I)          (_s1P(I) ? (I) : ASMFAIL( "8-bit displacement out of range"))
#define _d4(I)          (_s4P(I) ? (I) : ASMFAIL("32-bit displacement out of range"))

/*** REX PREFIX SUPPORT ***/
#define _REX_W          0x48  /* 64-bit operand size */
#define _REX_R          0x44  /* Extension of ModR/M reg field */
#define _REX_X          0x42  /* Extension of SIB index field */
#define _REX_B          0x41  /* Extension of ModR/M r/m field or SIB base field */

#define _REX(W,R,X,B)   (0x40 | ((W)?8:0) | ((R)?4:0) | ((X)?2:0) | ((B)?1:0))
#define _REX_REQUIRED(R) ((R) >= 8)

/*** ASSEMBLER ENCODING INFRASTRUCTURE ***/
#define _M(M)           (((M)>3) ? ASMFAIL("internal error: mod = " #M) : (M))
#define _r(R)           (((R)>15) ? ASMFAIL("internal error: reg = " #R) : ((R)&7))
#define _m(M)           (((M)>15) ? ASMFAIL("internal error: r/m = " #M) : ((M)&7))
#define _s(S)           (((S)>3) ? ASMFAIL("internal error: memory scale = " #S) : (S))
#define _i(I)           (((I)>15) ? ASMFAIL("internal error: memory index = " #I) : ((I)&7))
#define _b(B)           (((B)>15) ? ASMFAIL("internal error: memory base = "  #B) : ((B)&7))

#define _Mrm(X,Md,R,M)  _B(X,(_M(Md)<<6)|(_r(R)<<3)|_m(M))
#define _SIB(X,Sc,I, B) _B(X,(_s(Sc)<<6)|(_i(I)<<3)|_b(B))

#define _SCL(S)         ((((S)==1) ? _b00 : \
                         (((S)==2) ? _b01 : \
                         (((S)==4) ? _b10 : \
                         (((S)==8) ? _b11 : ASMFAIL("illegal scale: " #S)))))

/*** MEMORY ADDRESSING MODES ***/
#define _r_D(   X,R, D      )           (_Mrm(X,_b00,_r(R),_b101 )                              ,_L(X,D))
#define _r_0B(  X,R,   B    )           (_Mrm(X,_b00,_r(R),_b(B))                                      )
#define _r_0BIS(X,R,   B,I,S)           (_Mrm(X,_b00,_r(R),_b100 ),_SIB(X,_SCL(S),_i(I),_b(B))        )
#define _r_0DIS(X,R, D,  I,S)           (_Mrm(X,_b00,_r(R),_b100 ),_SIB(X,_SCL(S),_i(I),    5 ),_L(X,D))

#define _r_1B(  X,R,   B,D  )           (_Mrm(X,_b01,_r(R),_b(B))                              ,_B(X,D))
#define _r_1BIS(X,R,   B,I,S,D)         (_Mrm(X,_b01,_r(R),_b100 ),_SIB(X,_SCL(S),_i(I),_b(B)),_B(X,D))

#define _r_4B(  X,R,   B,D  )           (_Mrm(X,_b10,_r(R),_b(B))                              ,_L(X,D))
#define _r_4BIS(X,R,   B,I,S,D)         (_Mrm(X,_b10,_r(R),_b100 ),_SIB(X,_SCL(S),_i(I),_b(B)),_L(X,D))

#define _r_R(   X,R,     M  )           (_Mrm(X,_b11,_r(R),_r(M))                                      )

/*** 64-BIT DATA TRANSFER OPERATIONS ***/

;; 64-bit Move operations
#define MOViq(RS, RD)                   (_B(0,_REX_W), _B(0,0xb8+_r8(RD)        ), _Q(0, RS                        ))
#define MOVrq(RS, RD)                   (_B(0,_REX_W), _B(0,0x89), _r_R(0,     RS,RD)                               )
#define MOVmq(MS, MD, MB, MI, RD)       (_B(0,_REX_W), _B(0,0x8b), _r_X(0,     RD,   MD,MB,MI,MS                   ))

;; 32-bit operations (auto-zero upper 32 bits in x86-64)
#define MOVir(RS, RD)                   (_B(0,0xb8+_r4(RD)           ), _L(0, RS                        ))
#define MOVrr(RS, RD)                   (_B(0,0x89), _r_R(0,     RS,RD)                                  )
#define MOVrm(RS, MD, MB, MI, MS)       (_B(0,0x89), _r_X(0,     RS,   MD,MB,MI,MS                      ))
#define MOVmr(MS, MD, MB, MI, RD)       (_B(0,0x8b), _r_X(0,     RD,   MD,MB,MI,MS                      ))

;; 16-bit operations
#define MOV2ir(RS, RD)                  (_wB(0,0xb8+_r2(RD)          ), _W(0, RS                        ))
#define MOV2rr(RS, RD)                  (_wB(0,0x89), _r_R(0,     RS,RD)                                 )
#define MOV2rm(RS, MD, MB, MI, MS)      (_wB(0,0x89), _r_X(0,     RS,   MD,MB,MI,MS                     ))
#define MOV2mr(MS, MD, MB, MI, RD)      (_wB(0,0x8b), _r_X(0,     RD,   MD,MB,MI,MS                     ))

;; 8-bit operations
#define MOV1ir(RS, RD)                  (_B(0,0xb0+_r1(RD)           ), _B(0, RS                        ))
#define MOV1rr(RS, RD)                  (_B(0,0x88), _r_R(0,     RS,RD)                                  )
#define MOV1rm(RS, MD, MB, MI, MS)      (_B(0,0x88), _r_X(0,     RS,   MD,MB,MI,MS                      ))
#define MOV1mr(MS, MD, MB, MI, RD)      (_B(0,0x8a), _r_X(0,     RD,   MD,MB,MI,MS                      ))

;; Load effective address (64-bit)
#define LEAq(MD, MB, MI, MS, RD)        (_B(0,_REX_W), _B(0,0x8d), _r_X(0,     RD,   MD,MB,MI,MS                   ))
#define LEAr(MD, MB, MI, MS, RD)        (_B(0,0x8d), _r_X(0,     RD,   MD,MB,MI,MS                      ))

/*** 64-BIT ARITHMETIC OPERATIONS ***/

;; 64-bit Addition
#define ADDqr(RS, RD)                   (_B(0,_REX_W), _B(0,0x01), _r_R(0,     RS,RD)                               )
#define ADDqi(RS, RD)                   (_B(0,_REX_W), _B(0,0x81), _r_R(0,_b000,RD  ), _L(0, RS                     ))
#define ADDq1(RS, RD)                   (_B(0,_REX_W), _B(0,0x83), _r_R(0,_b000,RD  ), _B(0, RS                     ))

;; 32-bit Addition (clears upper 32 bits)
#define ADDrr(RS, RD)                   (_B(0,0x01), _r_R(0,     RS,RD)                                  )
#define ADDir(RS, RD)                   (_B(0,0x81), _r_R(0,_b000,RD  ), _L(0, RS                        ))
#define ADDir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b000,RD  ), _B(0, RS                        ))

;; 64-bit Subtraction
#define SUBqr(RS, RD)                   (_B(0,_REX_W), _B(0,0x29), _r_R(0,     RS,RD)                               )
#define SUBqi(RS, RD)                   (_B(0,_REX_W), _B(0,0x81), _r_R(0,_b101,RD  ), _L(0, RS                     ))
#define SUBq1(RS, RD)                   (_B(0,_REX_W), _B(0,0x83), _r_R(0,_b101,RD  ), _B(0, RS                     ))

;; 32-bit Subtraction
#define SUBrr(RS, RD)                   (_B(0,0x29), _r_R(0,     RS,RD)                                  )
#define SUBir(RS, RD)                   (_B(0,0x81), _r_R(0,_b101,RD  ), _L(0, RS                        ))
#define SUBir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b101,RD  ), _B(0, RS                        ))

;; 64-bit Multiplication
#define IMULqr(RS, RD)                  (_B(0,_REX_W), _B(0,0x0f), _B(0,0xaf), _r_R(0, RD,RS)                       )
#define IMULqi(IM, RS, RD)              (_B(0,_REX_W), _B(0,0x69), _r_R(0,     RD,RS), _L(0, IM                    ))
#define IMULq1(IM, RS, RD)              (_B(0,_REX_W), _B(0,0x6b), _r_R(0,     RD,RS), _B(0, IM                    ))

;; 32-bit Multiplication
#define IMULrr(RS, RD)                  (_B(0,0x0f), _B(0,0xaf), _r_R(0, RD,RS)                          )
#define IMULirr(IM, RS, RD)             (_B(0,0x69), _r_R(0,     RD,RS), _L(0, IM                       ))
#define IMULir1(IM, RS, RD)             (_B(0,0x6b), _r_R(0,     RD,RS), _B(0, IM                       ))

;; 64-bit Division
#define IDIVqr(RS)                      (_B(0,_REX_W), _B(0,0xf7), _r_R(0,_b111,RS   )                              )
#define DIVqr(RS)                       (_B(0,_REX_W), _B(0,0xf7), _r_R(0,_b110,RS   )                              )

;; 32-bit Division
#define IDIVr(RS)                       (_B(0,0xf7), _r_R(0,_b111,RS   )                                 )
#define DIVr(RS)                        (_B(0,0xf7), _r_R(0,_b110,RS   )                                 )

;; 64-bit Increment/Decrement
#define INCq(RD)                        (_B(0,_REX_W), _B(0,0xff), _r_R(0,_b000,RD   )                              )
#define DECq(RD)                        (_B(0,_REX_W), _B(0,0xff), _r_R(0,_b001,RD   )                              )

;; 32-bit Increment/Decrement
#define INCr(RD)                        (_B(0,0x40+_r4(RD)                                               ))
#define DECr(RD)                        (_B(0,0x48+_r4(RD)                                               ))

;; 64-bit Negate
#define NEGq(RD)                        (_B(0,_REX_W), _B(0,0xf7), _r_R(0,_b011,RD   )                              )
#define NEGr(RD)                        (_B(0,0xf7), _r_R(0,_b011,RD   )                                 )

/*** 64-BIT LOGICAL OPERATIONS ***/

;; 64-bit AND operations
#define ANDqr(RS, RD)                   (_B(0,_REX_W), _B(0,0x21), _r_R(0,     RS,RD)                               )
#define ANDqi(RS, RD)                   (_B(0,_REX_W), _B(0,0x81), _r_R(0,_b100,RD  ), _L(0, RS                     ))
#define ANDq1(RS, RD)                   (_B(0,_REX_W), _B(0,0x83), _r_R(0,_b100,RD  ), _B(0, RS                     ))

;; 32-bit AND operations  
#define ANDrr(RS, RD)                   (_B(0,0x21), _r_R(0,     RS,RD)                                  )
#define ANDir(RS, RD)                   (_B(0,0x81), _r_R(0,_b100,RD  ), _L(0, RS                        ))
#define ANDir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b100,RD  ), _B(0, RS                        ))

;; 64-bit OR operations
#define ORqr(RS, RD)                    (_B(0,_REX_W), _B(0,0x09), _r_R(0,     RS,RD)                               )
#define ORqi(RS, RD)                    (_B(0,_REX_W), _B(0,0x81), _r_R(0,_b001,RD  ), _L(0, RS                     ))
#define ORq1(RS, RD)                    (_B(0,_REX_W), _B(0,0x83), _r_R(0,_b001,RD  ), _B(0, RS                     ))

;; 32-bit OR operations
#define ORrr(RS, RD)                    (_B(0,0x09), _r_R(0,     RS,RD)                                  )
#define ORir(RS, RD)                    (_B(0,0x81), _r_R(0,_b001,RD  ), _L(0, RS                        ))
#define ORir1(RS, RD)                   (_B(0,0x83), _r_R(0,_b001,RD  ), _B(0, RS                        ))

;; 64-bit XOR operations
#define XORqr(RS, RD)                   (_B(0,_REX_W), _B(0,0x31), _r_R(0,     RS,RD)                               )
#define XORqi(RS, RD)                   (_B(0,_REX_W), _B(0,0x81), _r_R(0,_b110,RD  ), _L(0, RS                     ))
#define XORq1(RS, RD)                   (_B(0,_REX_W), _B(0,0x83), _r_R(0,_b110,RD  ), _B(0, RS                     ))

;; 32-bit XOR operations
#define XORrr(RS, RD)                   (_B(0,0x31), _r_R(0,     RS,RD)                                  )
#define XORir(RS, RD)                   (_B(0,0x81), _r_R(0,_b110,RD  ), _L(0, RS                        ))
#define XORir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b110,RD  ), _B(0, RS                        ))

;; 64-bit NOT operation
#define NOTq(RD)                        (_B(0,_REX_W), _B(0,0xf7), _r_R(0,_b010,RD   )                              )
#define NOTr(RD)                        (_B(0,0xf7), _r_R(0,_b010,RD   )                                 )

/*** 64-BIT COMPARISON OPERATIONS ***/

;; 64-bit Compare operations
#define CMPqr(RS, RD)                   (_B(0,_REX_W), _B(0,0x39), _r_R(0,     RS,RD)                               )
#define CMPqi(RS, RD)                   (_B(0,_REX_W), _B(0,0x81), _r_R(0,_b111,RD  ), _L(0, RS                     ))
#define CMPq1(RS, RD)                   (_B(0,_REX_W), _B(0,0x83), _r_R(0,_b111,RD  ), _B(0, RS                     ))

;; 32-bit Compare operations
#define CMPrr(RS, RD)                   (_B(0,0x39), _r_R(0,     RS,RD)                                  )
#define CMPir(RS, RD)                   (_B(0,0x81), _r_R(0,_b111,RD  ), _L(0, RS                        ))
#define CMPir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b111,RD  ), _B(0, RS                        ))

;; 64-bit Test operations
#define TESTqr(RS, RD)                  (_B(0,_REX_W), _B(0,0x85), _r_R(0,     RS,RD)                               )
#define TESTqi(RS, RD)                  (_B(0,_REX_W), _B(0,0xf7), _r_R(0,_b000,RD  ), _L(0, RS                     ))

;; 32-bit Test operations
#define TESTrr(RS, RD)                  (_B(0,0x85), _r_R(0,     RS,RD)                                  )
#define TESTir(RS, RD)                  (_B(0,0xf7), _r_R(0,_b000,RD  ), _L(0, RS                        ))

/*** 64-BIT SHIFT AND ROTATE OPERATIONS ***/

;; 64-bit Shift left
#define SHLq1(RD)                       (_B(0,_REX_W), _B(0,0xd1), _r_R(0,_b100,RD   )                              )
#define SHLqi(IM, RD)                   (_B(0,_REX_W), _B(0,0xc1), _r_R(0,_b100,RD  ), _B(0, IM                    ))
#define SHLqr(RD)                       (_B(0,_REX_W), _B(0,0xd3), _r_R(0,_b100,RD   )                              )

;; 32-bit Shift left
#define SHL1r(RD)                       (_B(0,0xd1), _r_R(0,_b100,RD   )                                 )
#define SHLir(IM, RD)                   (_B(0,0xc1), _r_R(0,_b100,RD  ), _B(0, IM                       ))
#define SHLrr(RD)                       (_B(0,0xd3), _r_R(0,_b100,RD   )                                 )

;; 64-bit Shift right
#define SHRq1(RD)                       (_B(0,_REX_W), _B(0,0xd1), _r_R(0,_b101,RD   )                              )
#define SHRqi(IM, RD)                   (_B(0,_REX_W), _B(0,0xc1), _r_R(0,_b101,RD  ), _B(0, IM                    ))
#define SHRqr(RD)                       (_B(0,_REX_W), _B(0,0xd3), _r_R(0,_b101,RD   )                              )

;; 32-bit Shift right
#define SHR1r(RD)                       (_B(0,0xd1), _r_R(0,_b101,RD   )                                 )
#define SHRir(IM, RD)                   (_B(0,0xc1), _r_R(0,_b101,RD  ), _B(0, IM                       ))
#define SHRrr(RD)                       (_B(0,0xd3), _r_R(0,_b101,RD   )                                 )

;; 64-bit Arithmetic shift right
#define SARq1(RD)                       (_B(0,_REX_W), _B(0,0xd1), _r_R(0,_b111,RD   )                              )
#define SARqi(IM, RD)                   (_B(0,_REX_W), _B(0,0xc1), _r_R(0,_b111,RD  ), _B(0, IM                    ))
#define SARqr(RD)                       (_B(0,_REX_W), _B(0,0xd3), _r_R(0,_b111,RD   )                              )

;; 32-bit Arithmetic shift right
#define SAR1r(RD)                       (_B(0,0xd1), _r_R(0,_b111,RD   )                                 )
#define SARir(IM, RD)                   (_B(0,0xc1), _r_R(0,_b111,RD  ), _B(0, IM                       ))
#define SARrr(RD)                       (_B(0,0xd3), _r_R(0,_b111,RD   )                                 )

/*** STACK OPERATIONS ***/

;; 64-bit Push/Pop (default in x86-64)
#define PUSHq(R)                        (_B(0,0x50+_r8(R)                                               ))
#define POPq(R)                         (_B(0,0x58+_r8(R)                                               ))
#define PUSHqi(IM)                      ((_s1P(IM)) ? _B(0,0x6a), _B(0,IM) : _B(0,0x68), _L(0,IM)      )

;; 32-bit compatibility
#define PUSHr(R)                        PUSHq(R)
#define POPr(R)                         POPq(R)
#define PUSHir(IM)                      PUSHqi(IM)

/*** CONTROL FLOW OPERATIONS ***/

;; Unconditional jumps (RIP-relative in x86-64)
#define JMPq(R)                         (_B(0,0xff), _r_R(0,_b100,R                                     ))
#define JMPii(IM)                       (_B(0,0xe9                    ), _L(0, IM                        ))
#define JMPsi(IM)                       (_B(0,0xeb                    ), _B(0, _d1(IM)                   ))

;; Function calls (RIP-relative in x86-64)
#define CALLq(R)                        (_B(0,0xff), _r_R(0,_b010,R                                     ))
#define CALLii(IM)                      (_B(0,0xe8                    ), _L(0, IM                        ))

;; Returns
#define RET()                           (_B(0,0xc3                                                       ))
#define RETi(IM)                        (_B(0,0xc2                    ), _W(0, IM                        ))

;; Conditional jumps (same as 32-bit)
#define JEsi(IM)                        (_B(0,0x74                    ), _B(0, _d1(IM)                   ))
#define JNEsi(IM)                       (_B(0,0x75                    ), _B(0, _d1(IM)                   ))
#define JLsi(IM)                        (_B(0,0x7c                    ), _B(0, _d1(IM)                   ))
#define JLEsi(IM)                       (_B(0,0x7e                    ), _B(0, _d1(IM)                   ))
#define JGsi(IM)                        (_B(0,0x7f                    ), _B(0, _d1(IM)                   ))
#define JGEsi(IM)                       (_B(0,0x7d                    ), _B(0, _d1(IM)                   ))
#define JBsi(IM)                        (_B(0,0x72                    ), _B(0, _d1(IM)                   ))
#define JBEsi(IM)                       (_B(0,0x76                    ), _B(0, _d1(IM)                   ))
#define JAsi(IM)                        (_B(0,0x77                    ), _B(0, _d1(IM)                   ))
#define JAEsi(IM)                       (_B(0,0x73                    ), _B(0, _d1(IM)                   ))

;; 32-bit conditional jumps
#define JEii(IM)                        (_B(0,0x0f), _B(0,0x84        ), _L(0, IM                        ))
#define JNEii(IM)                       (_B(0,0x0f), _B(0,0x85        ), _L(0, IM                        ))
#define JLii(IM)                        (_B(0,0x0f), _B(0,0x8c        ), _L(0, IM                        ))
#define JLEii(IM)                       (_B(0,0x0f), _B(0,0x8e        ), _L(0, IM                        ))
#define JGii(IM)                        (_B(0,0x0f), _B(0,0x8f        ), _L(0, IM                        ))
#define JGEii(IM)                       (_B(0,0x0f), _B(0,0x8d        ), _L(0, IM                        ))

/*** x86-64 SPECIFIC OPERATIONS ***/

;; 64-bit sign extension
#define CDQE()                          (_B(0,_REX_W), _B(0,0x98                                         ))
#define CQO()                           (_B(0,_REX_W), _B(0,0x99                                         ))

;; Move with sign/zero extension to 64-bit
#define MOVSXqr1(RS, RD)                (_B(0,_REX_W), _B(0,0x0f), _B(0,0xbe), _r_R(0, RD,RS)          )
#define MOVSXqr2(RS, RD)                (_B(0,_REX_W), _B(0,0x0f), _B(0,0xbf), _r_R(0, RD,RS)          )
#define MOVSXqr4(RS, RD)                (_B(0,_REX_W), _B(0,0x63), _r_R(0, RD,RS)                       )

#define MOVZXqr1(RS, RD)                (_B(0,_REX_W), _B(0,0x0f), _B(0,0xb6), _r_R(0, RD,RS)          )
#define MOVZXqr2(RS, RD)                (_B(0,_REX_W), _B(0,0x0f), _B(0,0xb7), _r_R(0, RD,RS)          )
;; Note: 32->64 zero extension is automatic in x86-64

;; Conditional move (64-bit)
#define CMOVEqr(RS, RD)                 (_B(0,_REX_W), _B(0,0x0f), _B(0,0x44), _r_R(0, RD,RS)          )
#define CMOVNEqr(RS, RD)                (_B(0,_REX_W), _B(0,0x0f), _B(0,0x45), _r_R(0, RD,RS)          )
#define CMOVLqr(RS, RD)                 (_B(0,_REX_W), _B(0,0x0f), _B(0,0x4c), _r_R(0, RD,RS)          )
#define CMOVLEqr(RS, RD)                (_B(0,_REX_W), _B(0,0x0f), _B(0,0x4e), _r_R(0, RD,RS)          )
#define CMOVGqr(RS, RD)                 (_B(0,_REX_W), _B(0,0x0f), _B(0,0x4f), _r_R(0, RD,RS)          )
#define CMOVGEqr(RS, RD)                (_B(0,_REX_W), _B(0,0x0f), _B(0,0x4d), _r_R(0, RD,RS)          )

;; 32-bit conditional move (clears upper 32 bits)
#define CMOVEr(RS, RD)                  (_B(0,0x0f), _B(0,0x44), _r_R(0, RD,RS)                         )
#define CMOVNEr(RS, RD)                 (_B(0,0x0f), _B(0,0x45), _r_R(0, RD,RS)                         )
#define CMOVLr(RS, RD)                  (_B(0,0x0f), _B(0,0x4c), _r_R(0, RD,RS)                         )
#define CMOVLEr(RS, RD)                 (_B(0,0x0f), _B(0,0x4e), _r_R(0, RD,RS)                         )
#define CMOVGr(RS, RD)                  (_B(0,0x0f), _B(0,0x4f), _r_R(0, RD,RS)                         )
#define CMOVGEr(RS, RD)                 (_B(0,0x0f), _B(0,0x4d), _r_R(0, RD,RS)                         )

/*** FLAGS AND MISCELLANEOUS ***/

;; Flag operations (same as 32-bit)
#define CLC()                           (_B(0,0xf8                                                       ))
#define STC()                           (_B(0,0xf9                                                       ))
#define CMC()                           (_B(0,0xf5                                                       ))
#define CLD()                           (_B(0,0xfc                                                       ))
#define STD()                           (_B(0,0xfd                                                       ))
#define LAHF()                          (_B(0,0x9f                                                       ))
#define SAHF()                          (_B(0,0x9e                                                       ))

;; 64-bit stack operations
#define PUSHFQ()                        (_B(0,0x9c                                                       ))
#define POPFQ()                         (_B(0,0x9d                                                       ))

;; Misc operations
#define NOP()                           (_B(0,0x90                                                       ))
#define HLT()                           (_B(0,0xf4                                                       ))
#define INT3()                          (_B(0,0xcc                                                       ))
#define INTi(IM)                        (_B(0,0xcd                    ), _B(0, IM                        ))

;; x86-64 specific system instructions
#define SYSCALL()                       (_B(0,0x0f), _B(0,0x05                                          ))
#define SYSRET()                        (_B(0,0x0f), _B(0,0x07                                          ))
#define SWAPGS()                        (_B(0,0x0f), _B(0,0x01), _B(0,0xf8                              ))

;; CPU identification
#define CPUID()                         (_B(0,0x0f), _B(0,0xa2                                          ))
#define RDTSC()                         (_B(0,0x0f), _B(0,0x31                                          ))
#define RDTSCP()                        (_B(0,0x0f), _B(0,0x01), _B(0,0xf9                              ))

;;; Complete x86-64 assembler infrastructure ready. Uses same pattern as gen-asm-x86.k:
;;; Generic grammar processes the architecture-specific #define statements.