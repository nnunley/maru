;;; asm-x86.l -- Complete x86 Assembly Support
;;; Uses generic asm-grammar.l and follows asm-common.k import pattern

;; Load generic assembler grammar (same pattern as gen-asm-x86.k)
(load "grammars/core/asm-grammar.l")

;; Complete x86 assembler infrastructure extracted from gen-asm-x86.k

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

/*** COMPLETE x86 REGISTER DEFINITIONS ***/

;; 8-bit registers (low)
#define _AL             0x10
#define _CL             0x11
#define _DL             0x12
#define _BL             0x13
;; 8-bit registers (high)  
#define _AH             0x14
#define _CH             0x15
#define _DH             0x16
#define _BH             0x17

;; 16-bit registers
#define _AX             0x20
#define _CX             0x21
#define _DX             0x22
#define _BX             0x23
#define _SP             0x24
#define _BP             0x25
#define _SI             0x26
#define _DI             0x27

;; 32-bit registers
#define _EAX            0x40
#define _ECX            0x41
#define _EDX            0x42
#define _EBX            0x43
#define _ESP            0x44
#define _EBP            0x45
#define _ESI            0x46
#define _EDI            0x47

/*** REGISTER UTILITY MACROS ***/
#define _rS(R)          ((R)>>4)
#define _rN(R)          ((R)&0x7)

#define _r0P(R)         ((R)==0)
#define _rLP(R)         (((R)>=_AL)&&((R)<=_BL))
#define _rHP(R)         (((R)>=_AH)&&((R)<=_BH))
#define _r1P(R)         (_rS(R)==1)
#define _r2P(R)         (_rS(R)==2)
#define _r4P(R)         (_rS(R)==4)

#define _rL(R)          (_rLP(R) ? _rN(R) : ASMFAIL( "8-bit L register required"))
#define _rH(R)          (_rHP(R) ? _rN(R) : ASMFAIL( "8-bit H register required"))
#define _r1(R)          (_r1P(R) ? _rN(R) : ASMFAIL( "8-bit register required"))
#define _r2(R)          (_r2P(R) ? _rN(R) : ASMFAIL("16-bit register required"))
#define _r4(R)          (_r4P(R) ? _rN(R) : ASMFAIL("32-bit register required"))

#define _rAL(R)         (((R)==_AL)  ? _rN(R) : ASMFAIL( "AL register required"))
#define _rAX(R)         (((R)==_AX)  ? _rN(R) : ASMFAIL( "AX register required"))
#define _rEAX(R)        (((R)==_EAX) ? _rN(R) : ASMFAIL("EAX register required"))

/*** IMMEDIATE VALUE HANDLING ***/
#define _u1P(I)         (((I) & 0xffffff00) == 0)
#define _u2P(I)         (((I) & 0xffff0000) == 0)
#define _s1P(I)         (((I) >= -128) && ((I) <= 127))
#define _s2P(I)         (((I) >= -32768) && ((I) <= 32767))

#define _s1(I)          (_s1P(I) ? (I) : ASMFAIL( "8-bit signed immediate required"))
#define _s2(I)          (_s2P(I) ? (I) : ASMFAIL("16-bit signed immediate required"))
#define _u1(I)          (_u1P(I) ? (I) : ASMFAIL( "8-bit unsigned immediate required"))
#define _u2(I)          (_u2P(I) ? (I) : ASMFAIL("16-bit unsigned immediate required"))
#define _d1(I)          (_s1P(I) ? (I) : ASMFAIL( "8-bit displacement out of range"))

/*** ASSEMBLER ENCODING INFRASTRUCTURE ***/
#define _M(M)           (((M)>3) ? ASMFAIL("internal error: mod = " #M) : (M))
#define _r(R)           (((R)>7) ? ASMFAIL("internal error: reg = " #R) : (R))
#define _m(M)           (((M)>7) ? ASMFAIL("internal error: r/m = " #M) : (M))
#define _s(S)           (((S)>3) ? ASMFAIL("internal error: memory scale = " #S) : (S))
#define _i(I)           (((I)>7) ? ASMFAIL("internal error: memory index = " #I) : (I))
#define _b(B)           (((B)>7) ? ASMFAIL("internal error: memory base = "  #B) : (B))

#define _Mrm(X,Md,R,M)  _B(X,(_M(Md)<<6)|(_r(R)<<3)|_m(M))
#define _SIB(X,Sc,I, B) _B(X,(_s(Sc)<<6)|(_i(I)<<3)|_b(B))

#define _SCL(S)         ((((S)==1) ? _b00 : \
                         (((S)==2) ? _b01 : \
                         (((S)==4) ? _b10 : \
                         (((S)==8) ? _b11 : ASMFAIL("illegal scale: " #S)))))

/*** MEMORY ADDRESSING MODES ***/
#define _r_D(   X,R, D      )           (_Mrm(X,_b00,_rN(R),_b101 )                              ,_L(X,D))
#define _r_0B(  X,R,   B    )           (_Mrm(X,_b00,_rN(R),_r4(B))                                      )
#define _r_0BIS(X,R,   B,I,S)           (_Mrm(X,_b00,_rN(R),_b100 ),_SIB(X,_SCL(S),_r4(I),_r4(B))        )
#define _r_0DIS(X,R, D,  I,S)           (_Mrm(X,_b00,_rN(R),_b100 ),_SIB(X,_SCL(S),_r4(I),    5 ),_L(X,D))

#define _r_1B(  X,R,   B,D  )           (_Mrm(X,_b01,_rN(R),_r4(B))                              ,_B(X,D))
#define _r_1BIS(X,R,   B,I,S,D)         (_Mrm(X,_b01,_rN(R),_b100 ),_SIB(X,_SCL(S),_r4(I),_r4(B)),_B(X,D))

#define _r_4B(  X,R,   B,D  )           (_Mrm(X,_b10,_rN(R),_r4(B))                              ,_L(X,D))
#define _r_4BIS(X,R,   B,I,S,D)         (_Mrm(X,_b10,_rN(R),_b100 ),_SIB(X,_SCL(S),_r4(I),_r4(B)),_L(X,D))

#define _r_R(   X,R,     M  )           (_Mrm(X,_b11,_rN(R),_rN(M))                                      )

#define _r_X(   X,R,MD,MB,MI,MS         ) ( \
    (((MD) == 0) && ((MB) != _EBP) && ((MI) == _c0P) && ((MS) == _c1P)) ? (_r_0B  (X,R,MB          )) : \
    (((MD) == 0) && ((MB) == _EBP) && ((MI) == _c0P) && ((MS) == _c1P)) ? (_r_1B  (X,R,MB,0       )) : \
    (((MD) == 0) && ((MB) == _c0P) && ((MI) != _ESP) && ((MS) >= 1   )) ? (_r_0DIS(X,R,MD,  MI,MS )) : \
    (((MD) == 0) && ((MB) != _EBP) && ((MI) != _ESP) && ((MS) >= 1   )) ? (_r_0BIS(X,R,MB,MI,MS   )) : \
    (((_s1P(MD)) && ((MB) != _c0P) && ((MI) == _c0P) && ((MS) == _c1P)) ? (_r_1B  (X,R,MB,MD      )) : \
    (((_s1P(MD)) && ((MB) != _c0P) && ((MI) != _ESP) && ((MS) >= 1   )) ? (_r_1BIS(X,R,MB,MI,MS,MD)) : \
    (((MB) == _c0P) && ((MI) != _ESP) && ((MS) >= 1   )) ? (_r_0DIS(X,R,MD,  MI,MS )) : \
    (((MB) != _c0P) && ((MI) == _c0P) && ((MS) == _c1P)) ? (_r_4B  (X,R,MB,MD      )) : \
    (((MB) != _c0P) && ((MI) != _ESP) && ((MS) >= 1   )) ? (_r_4BIS(X,R,MB,MI,MS,MD)) : \
    (ASMFAIL("illegal x86 memory operand"))))))))))

/*** DATA TRANSFER OPERATIONS ***/

;; Move operations
#define MOVir(RS, RD)                   (_B(0,0xb8+_r4(RD)           ), _L(0, RS                        ))
#define MOVrr(RS, RD)                   (_B(0,0x89), _r_R(0,     RS,RD)                                  )
#define MOVrm(RS, MD, MB, MI, MS)       (_B(0,0x89), _r_X(0,     RS,   MD,MB,MI,MS                      ))
#define MOVmr(MS, MD, MB, MI, RD)       (_B(0,0x8b), _r_X(0,     RD,   MD,MB,MI,MS                      ))
#define MOV1ir(RS, RD)                  (_B(0,0xb0+_r1(RD)           ), _B(0, RS                        ))
#define MOV1rr(RS, RD)                  (_B(0,0x88), _r_R(0,     RS,RD)                                  )
#define MOV1rm(RS, MD, MB, MI, MS)      (_B(0,0x88), _r_X(0,     RS,   MD,MB,MI,MS                      ))
#define MOV1mr(MS, MD, MB, MI, RD)      (_B(0,0x8a), _r_X(0,     RD,   MD,MB,MI,MS                      ))
#define MOV2ir(RS, RD)                  (_wB(0,0xb8+_r2(RD)          ), _W(0, RS                        ))
#define MOV2rr(RS, RD)                  (_wB(0,0x89), _r_R(0,     RS,RD)                                 )
#define MOV2rm(RS, MD, MB, MI, MS)      (_wB(0,0x89), _r_X(0,     RS,   MD,MB,MI,MS                     ))
#define MOV2mr(MS, MD, MB, MI, RD)      (_wB(0,0x8b), _r_X(0,     RD,   MD,MB,MI,MS                     ))

;; Load effective address
#define LEAm(MD, MB, MI, MS, RD)        (_B(0,0x8d), _r_X(0,     RD,   MD,MB,MI,MS                      ))

/*** ARITHMETIC OPERATIONS ***/

;; Addition
#define ADDrr(RS, RD)                   (_B(0,0x01), _r_R(0,     RS,RD)                                  )
#define ADDir(RS, RD)                   (_B(0,0x05                    ), _L(0, RS                        )) /* rEAX */
#define ADDir(RS, RD)                   (_B(0,0x81), _r_R(0,_b000,RD  ), _L(0, RS                        ))
#define ADDir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b000,RD  ), _B(0, RS                        ))
#define ADD1rr(RS, RD)                  (_B(0,0x00), _r_R(0,     RS,RD)                                  )
#define ADD1ir(RS, RD)                  (_B(0,0x80), _r_R(0,_b000,RD  ), _B(0, RS                        ))
#define ADD2rr(RS, RD)                  (_wB(0,0x01), _r_R(0,     RS,RD)                                 )
#define ADD2ir(RS, RD)                  (_wB(0,0x81), _r_R(0,_b000,RD  ), _W(0, RS                       ))

;; Subtraction
#define SUBrr(RS, RD)                   (_B(0,0x29), _r_R(0,     RS,RD)                                  )
#define SUBir(RS, RD)                   (_B(0,0x2d                    ), _L(0, RS                        )) /* rEAX */
#define SUBir(RS, RD)                   (_B(0,0x81), _r_R(0,_b101,RD  ), _L(0, RS                        ))
#define SUBir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b101,RD  ), _B(0, RS                        ))
#define SUB1rr(RS, RD)                  (_B(0,0x28), _r_R(0,     RS,RD)                                  )
#define SUB1ir(RS, RD)                  (_B(0,0x80), _r_R(0,_b101,RD  ), _B(0, RS                        ))
#define SUB2rr(RS, RD)                  (_wB(0,0x29), _r_R(0,     RS,RD)                                 )
#define SUB2ir(RS, RD)                  (_wB(0,0x81), _r_R(0,_b101,RD  ), _W(0, RS                       ))

;; Multiplication 
#define MULr(RS)                        (_B(0,0xf7), _r_R(0,_b100,RS   )                                 )
#define MUL1r(RS)                       (_B(0,0xf6), _r_R(0,_b100,RS   )                                 )
#define IMULr(RS)                       (_B(0,0xf7), _r_R(0,_b101,RS   )                                 )
#define IMUL1r(RS)                      (_B(0,0xf6), _r_R(0,_b101,RS   )                                 )
#define IMULrr(RS, RD)                  (_B(0,0x0f), _B(0,0xaf), _r_R(0, RD,RS)                          )
#define IMULirr(IM, RS, RD)             (_B(0,0x69), _r_R(0,     RD,RS), _L(0, IM                       ))
#define IMULir1(IM, RS, RD)             (_B(0,0x6b), _r_R(0,     RD,RS), _B(0, IM                       ))

;; Division
#define DIVr(RS)                        (_B(0,0xf7), _r_R(0,_b110,RS   )                                 )
#define DIV1r(RS)                       (_B(0,0xf6), _r_R(0,_b110,RS   )                                 )
#define IDIVr(RS)                       (_B(0,0xf7), _r_R(0,_b111,RS   )                                 )
#define IDIV1r(RS)                      (_B(0,0xf6), _r_R(0,_b111,RS   )                                 )

;; Increment/Decrement
#define INCr(RD)                        (_B(0,0x40+_r4(RD)                                               ))
#define INC1r(RD)                       (_B(0,0xfe), _r_R(0,_b000,RD   )                                 )
#define INC2r(RD)                       (_wB(0,0xff), _r_R(0,_b000,RD  )                                 )
#define DECr(RD)                        (_B(0,0x48+_r4(RD)                                               ))
#define DEC1r(RD)                       (_B(0,0xfe), _r_R(0,_b001,RD   )                                 )
#define DEC2r(RD)                       (_wB(0,0xff), _r_R(0,_b001,RD  )                                 )

;; Negate
#define NEGr(RD)                        (_B(0,0xf7), _r_R(0,_b011,RD   )                                 )
#define NEG1r(RD)                       (_B(0,0xf6), _r_R(0,_b011,RD   )                                 )
#define NEG2r(RD)                       (_wB(0,0xf7), _r_R(0,_b011,RD  )                                 )

/*** LOGICAL OPERATIONS ***/

;; AND operations
#define ANDrr(RS, RD)                   (_B(0,0x21), _r_R(0,     RS,RD)                                  )
#define ANDir(RS, RD)                   (_B(0,0x25                    ), _L(0, RS                        )) /* rEAX */
#define ANDir(RS, RD)                   (_B(0,0x81), _r_R(0,_b100,RD  ), _L(0, RS                        ))
#define ANDir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b100,RD  ), _B(0, RS                        ))
#define AND1rr(RS, RD)                  (_B(0,0x20), _r_R(0,     RS,RD)                                  )
#define AND1ir(RS, RD)                  (_B(0,0x80), _r_R(0,_b100,RD  ), _B(0, RS                        ))
#define AND2rr(RS, RD)                  (_wB(0,0x21), _r_R(0,     RS,RD)                                 )
#define AND2ir(RS, RD)                  (_wB(0,0x81), _r_R(0,_b100,RD  ), _W(0, RS                       ))

;; OR operations
#define ORrr(RS, RD)                    (_B(0,0x09), _r_R(0,     RS,RD)                                  )
#define ORir(RS, RD)                    (_B(0,0x0d                    ), _L(0, RS                        )) /* rEAX */
#define ORir(RS, RD)                    (_B(0,0x81), _r_R(0,_b001,RD  ), _L(0, RS                        ))
#define ORir1(RS, RD)                   (_B(0,0x83), _r_R(0,_b001,RD  ), _B(0, RS                        ))
#define OR1rr(RS, RD)                   (_B(0,0x08), _r_R(0,     RS,RD)                                  )
#define OR1ir(RS, RD)                   (_B(0,0x80), _r_R(0,_b001,RD  ), _B(0, RS                        ))
#define OR2rr(RS, RD)                   (_wB(0,0x09), _r_R(0,     RS,RD)                                 )
#define OR2ir(RS, RD)                   (_wB(0,0x81), _r_R(0,_b001,RD  ), _W(0, RS                       ))

;; XOR operations
#define XORrr(RS, RD)                   (_B(0,0x31), _r_R(0,     RS,RD)                                  )
#define XORir(RS, RD)                   (_B(0,0x35                    ), _L(0, RS                        )) /* rEAX */
#define XORir(RS, RD)                   (_B(0,0x81), _r_R(0,_b110,RD  ), _L(0, RS                        ))
#define XORir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b110,RD  ), _B(0, RS                        ))
#define XOR1rr(RS, RD)                  (_B(0,0x30), _r_R(0,     RS,RD)                                  )
#define XOR1ir(RS, RD)                  (_B(0,0x80), _r_R(0,_b110,RD  ), _B(0, RS                        ))
#define XOR2rr(RS, RD)                  (_wB(0,0x31), _r_R(0,     RS,RD)                                 )
#define XOR2ir(RS, RD)                  (_wB(0,0x81), _r_R(0,_b110,RD  ), _W(0, RS                       ))

;; NOT operation
#define NOTr(RD)                        (_B(0,0xf7), _r_R(0,_b010,RD   )                                 )
#define NOT1r(RD)                       (_B(0,0xf6), _r_R(0,_b010,RD   )                                 )
#define NOT2r(RD)                       (_wB(0,0xf7), _r_R(0,_b010,RD  )                                 )

/*** COMPARISON OPERATIONS ***/

;; Compare operations
#define CMPrr(RS, RD)                   (_B(0,0x39), _r_R(0,     RS,RD)                                  )
#define CMPir(RS, RD)                   (_B(0,0x3d                    ), _L(0, RS                        )) /* rEAX */
#define CMPir(RS, RD)                   (_B(0,0x81), _r_R(0,_b111,RD  ), _L(0, RS                        ))
#define CMPir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b111,RD  ), _B(0, RS                        ))
#define CMP1rr(RS, RD)                  (_B(0,0x38), _r_R(0,     RS,RD)                                  )
#define CMP1ir(RS, RD)                  (_B(0,0x80), _r_R(0,_b111,RD  ), _B(0, RS                        ))
#define CMP2rr(RS, RD)                  (_wB(0,0x39), _r_R(0,     RS,RD)                                 )
#define CMP2ir(RS, RD)                  (_wB(0,0x81), _r_R(0,_b111,RD  ), _W(0, RS                       ))

;; Test operations
#define TESTrr(RS, RD)                  (_B(0,0x85), _r_R(0,     RS,RD)                                  )
#define TESTir(RS, RD)                  (_B(0,0xa9                    ), _L(0, RS                        )) /* rEAX */
#define TESTir(RS, RD)                  (_B(0,0xf7), _r_R(0,_b000,RD  ), _L(0, RS                        ))
#define TEST1rr(RS, RD)                 (_B(0,0x84), _r_R(0,     RS,RD)                                  )
#define TEST1ir(RS, RD)                 (_B(0,0xa8                    ), _B(0, RS                        )) /* rAL */
#define TEST1ir(RS, RD)                 (_B(0,0xf6), _r_R(0,_b000,RD  ), _B(0, RS                        ))
#define TEST2rr(RS, RD)                 (_wB(0,0x85), _r_R(0,     RS,RD)                                 )
#define TEST2ir(RS, RD)                 (_wB(0,0xf7), _r_R(0,_b000,RD  ), _W(0, RS                       ))

/*** SHIFT AND ROTATE OPERATIONS ***/

;; Shift left
#define SHL1r(RD)                       (_B(0,0xd1), _r_R(0,_b100,RD   )                                 )
#define SHLir(IM, RD)                   (_B(0,0xc1), _r_R(0,_b100,RD  ), _B(0, IM                       ))
#define SHLrr(RD)                       (_B(0,0xd3), _r_R(0,_b100,RD   )                                 )

;; Shift right
#define SHR1r(RD)                       (_B(0,0xd1), _r_R(0,_b101,RD   )                                 )
#define SHRir(IM, RD)                   (_B(0,0xc1), _r_R(0,_b101,RD  ), _B(0, IM                       ))
#define SHRrr(RD)                       (_B(0,0xd3), _r_R(0,_b101,RD   )                                 )

;; Arithmetic shift right
#define SAR1r(RD)                       (_B(0,0xd1), _r_R(0,_b111,RD   )                                 )
#define SARir(IM, RD)                   (_B(0,0xc1), _r_R(0,_b111,RD  ), _B(0, IM                       ))
#define SARrr(RD)                       (_B(0,0xd3), _r_R(0,_b111,RD   )                                 )

;; Rotate left
#define ROL1r(RD)                       (_B(0,0xd1), _r_R(0,_b000,RD   )                                 )
#define ROLir(IM, RD)                   (_B(0,0xc1), _r_R(0,_b000,RD  ), _B(0, IM                       ))
#define ROLrr(RD)                       (_B(0,0xd3), _r_R(0,_b000,RD   )                                 )

;; Rotate right
#define ROR1r(RD)                       (_B(0,0xd1), _r_R(0,_b001,RD   )                                 )
#define RORir(IM, RD)                   (_B(0,0xc1), _r_R(0,_b001,RD  ), _B(0, IM                       ))
#define RORrr(RD)                       (_B(0,0xd3), _r_R(0,_b001,RD   )                                 )

/*** STACK OPERATIONS ***/
#define PUSHr(R)                        (_B(0,0x50+_r4(R)                                               ))
#define PUSHir(IM)                      ((_s1P(IM)) ? _B(0,0x6a), _B(0,IM) : _B(0,0x68), _L(0,IM)      )
#define PUSHm(MD,MB,MI,MS)              (_B(0,0xff), _r_X(0,_b110,     MD,MB,MI,MS                      ))

#define POPr(R)                         (_B(0,0x58+_r4(R)                                               ))
#define POPm(MD,MB,MI,MS)               (_B(0,0x8f), _r_X(0,_b000,     MD,MB,MI,MS                      ))

/*** CONTROL FLOW OPERATIONS ***/

;; Unconditional jumps  
#define JMPr(R)                         (_B(0,0xff), _r_R(0,_b100,R                                     ))
#define JMPm(MD,MB,MI,MS)               (_B(0,0xff), _r_X(0,_b100,     MD,MB,MI,MS                      ))
#define JMPii(IM)                       (_B(0,0xe9                    ), _L(0, IM                        ))
#define JMPsi(IM)                       (_B(0,0xeb                    ), _B(0, _d1(IM)                   ))

;; Conditional jumps
#define JOsi(IM)                        (_B(0,0x70                    ), _B(0, _d1(IM)                   ))
#define JNOsi(IM)                       (_B(0,0x71                    ), _B(0, _d1(IM)                   ))
#define JBsi(IM)                        (_B(0,0x72                    ), _B(0, _d1(IM)                   ))
#define JNBsi(IM)                       (_B(0,0x73                    ), _B(0, _d1(IM)                   ))
#define JEsi(IM)                        (_B(0,0x74                    ), _B(0, _d1(IM)                   ))
#define JNEsi(IM)                       (_B(0,0x75                    ), _B(0, _d1(IM)                   ))
#define JBEsi(IM)                       (_B(0,0x76                    ), _B(0, _d1(IM)                   ))
#define JNBEsi(IM)                      (_B(0,0x77                    ), _B(0, _d1(IM)                   ))
#define JSsi(IM)                        (_B(0,0x78                    ), _B(0, _d1(IM)                   ))
#define JNSsi(IM)                       (_B(0,0x79                    ), _B(0, _d1(IM)                   ))
#define JPsi(IM)                        (_B(0,0x7a                    ), _B(0, _d1(IM)                   ))
#define JNPsi(IM)                       (_B(0,0x7b                    ), _B(0, _d1(IM)                   ))
#define JLsi(IM)                        (_B(0,0x7c                    ), _B(0, _d1(IM)                   ))
#define JNLsi(IM)                       (_B(0,0x7d                    ), _B(0, _d1(IM)                   ))
#define JLEsi(IM)                       (_B(0,0x7e                    ), _B(0, _d1(IM)                   ))
#define JNLEsi(IM)                      (_B(0,0x7f                    ), _B(0, _d1(IM)                   ))

;; 32-bit conditional jumps
#define JOii(IM)                        (_B(0,0x0f), _B(0,0x80        ), _L(0, IM                        ))
#define JNOii(IM)                       (_B(0,0x0f), _B(0,0x81        ), _L(0, IM                        ))
#define JBii(IM)                        (_B(0,0x0f), _B(0,0x82        ), _L(0, IM                        ))
#define JNBii(IM)                       (_B(0,0x0f), _B(0,0x83        ), _L(0, IM                        ))
#define JEii(IM)                        (_B(0,0x0f), _B(0,0x84        ), _L(0, IM                        ))
#define JNEii(IM)                       (_B(0,0x0f), _B(0,0x85        ), _L(0, IM                        ))
#define JBEii(IM)                       (_B(0,0x0f), _B(0,0x86        ), _L(0, IM                        ))
#define JNBEii(IM)                      (_B(0,0x0f), _B(0,0x87        ), _L(0, IM                        ))
#define JSii(IM)                        (_B(0,0x0f), _B(0,0x88        ), _L(0, IM                        ))
#define JNSii(IM)                       (_B(0,0x0f), _B(0,0x89        ), _L(0, IM                        ))
#define JPii(IM)                        (_B(0,0x0f), _B(0,0x8a        ), _L(0, IM                        ))
#define JNPii(IM)                       (_B(0,0x0f), _B(0,0x8b        ), _L(0, IM                        ))
#define JLii(IM)                        (_B(0,0x0f), _B(0,0x8c        ), _L(0, IM                        ))
#define JNLii(IM)                       (_B(0,0x0f), _B(0,0x8d        ), _L(0, IM                        ))
#define JLEii(IM)                       (_B(0,0x0f), _B(0,0x8e        ), _L(0, IM                        ))
#define JNLEii(IM)                      (_B(0,0x0f), _B(0,0x8f        ), _L(0, IM                        ))

;; Jump aliases
#define JCsi                            JBsi
#define JNCsi                           JNBsi
#define JZsi                            JEsi
#define JNZsi                           JNEsi
#define JAsi                            JNBEsi
#define JNAsi                           JBEsi
#define JAEsi                           JNBsi
#define JNAEsi                          JBsi
#define JGsi                            JNLEsi
#define JNGsi                           JLEsi
#define JGEsi                           JNLsi
#define JNGEsi                          JLsi
#define JPEsi                           JPsi
#define JPOsi                           JNPsi

;; Function calls and returns
#define CALLr(R)                        (_B(0,0xff), _r_R(0,_b010,R                                     ))
#define CALLm(MD,MB,MI,MS)              (_B(0,0xff), _r_X(0,_b010,     MD,MB,MI,MS                      ))
#define CALLii(IM)                      (_B(0,0xe8                    ), _L(0, IM                        ))

#define RET()                           (_B(0,0xc3                                                       ))
#define RETi(IM)                        (_B(0,0xc2                    ), _W(0, IM                        ))

/*** FLAGS AND MISCELLANEOUS ***/

;; Flag operations
#define CLC()                           (_B(0,0xf8                                                       ))
#define STC()                           (_B(0,0xf9                                                       ))
#define CMC()                           (_B(0,0xf5                                                       ))
#define CLD()                           (_B(0,0xfc                                                       ))
#define STD()                           (_B(0,0xfd                                                       ))
#define LAHF()                          (_B(0,0x9f                                                       ))
#define SAHF()                          (_B(0,0x9e                                                       ))
#define PUSHF()                         (_B(0,0x9c                                                       ))
#define POPF()                          (_B(0,0x9d                                                       ))

;; String operations
#define MOVSB()                         (_B(0,0xa4                                                       ))
#define MOVSW()                         (_wB(0,0xa5                                                      ))
#define MOVSL()                         (_B(0,0xa5                                                       ))
#define STOSB()                         (_B(0,0xaa                                                       ))
#define STOSW()                         (_wB(0,0xab                                                      ))
#define STOSL()                         (_B(0,0xab                                                       ))
#define LODSB()                         (_B(0,0xac                                                       ))
#define LODSW()                         (_wB(0,0xad                                                      ))
#define LODSL()                         (_B(0,0xad                                                       ))
#define SCASB()                         (_B(0,0xae                                                       ))
#define SCASW()                         (_wB(0,0xaf                                                      ))
#define SCASL()                         (_B(0,0xaf                                                       ))
#define CMPSB()                         (_B(0,0xa6                                                       ))
#define CMPSW()                         (_wB(0,0xa7                                                      ))
#define CMPSL()                         (_B(0,0xa7                                                       ))

;; String prefixes
#define REP()                           (_B(0,0xf3                                                       ))
#define REPZ()                          (_B(0,0xf3                                                       ))
#define REPNZ()                         (_B(0,0xf2                                                       ))

;; Misc operations
#define NOP()                           (_B(0,0x90                                                       ))
#define HLT()                           (_B(0,0xf4                                                       ))
#define INT3()                          (_B(0,0xcc                                                       ))
#define INTi(IM)                        (_B(0,0xcd                    ), _B(0, IM                        ))
#define CPUID()                         (_B(0,0x0f), _B(0,0xa2                                          ))
#define RDTSC()                         (_B(0,0x0f), _B(0,0x31                                          ))

;; Sign/zero extension
#define CBW()                           (_wB(0,0x98                                                      ))
#define CWD()                           (_wB(0,0x99                                                      ))
#define CWDE()                          (_B(0,0x98                                                       ))
#define CDQ()                           (_B(0,0x99                                                       ))
#define MOVSXr1r(RS, RD)                (_B(0,0x0f), _B(0,0xbe), _r_R(0, RD,RS)                         )
#define MOVSXr2r(RS, RD)                (_B(0,0x0f), _B(0,0xbf), _r_R(0, RD,RS)                         )
#define MOVZXr1r(RS, RD)                (_B(0,0x0f), _B(0,0xb6), _r_R(0, RD,RS)                         )
#define MOVZXr2r(RS, RD)                (_B(0,0x0f), _B(0,0xb7), _r_R(0, RD,RS)                         )

;;; Complete x86 assembler infrastructure ready. Uses same pattern as gen-asm-x86.k:
;;; Generic grammar processes the architecture-specific #define statements.