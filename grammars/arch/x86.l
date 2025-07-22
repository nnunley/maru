;;; x86.l -- x86 Architecture Assembler
;;; Uses the generic assembler grammar to process x86-specific definitions
;;; Extracted from gen-asm-x86.k

;; Load the generic assembler grammar infrastructure
(load "grammars/core/assembler.l")

;; x86-specific assembler definitions start here
;; The generic grammar will process these #define statements

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

/*** REGISTERS ***/     /* [size,,number] */

#define _AL             0x10
#define _CL             0x11
#define _DL             0x12
#define _BL             0x13
#define _AH             0x14
#define _CH             0x15
#define _DH             0x16
#define _BH             0x17

#define _AX             0x20
#define _CX             0x21
#define _DX             0x22
#define _BX             0x23
#define _SP             0x24
#define _BP             0x25
#define _SI             0x26
#define _DI             0x27

#define _EAX            0x40
#define _ECX            0x41
#define _EDX            0x42
#define _EBX            0x43
#define _ESP            0x44
#define _EBP            0x45
#define _ESI            0x46
#define _EDI            0x47

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

/*** IMMEDIATES ***/

#define _u1P(I)         (((I) & 0xffffff00) == 0)
#define _u2P(I)         (((I) & 0xffff0000) == 0)
#define _s1P(I)         (((I) >= -128) && ((I) <= 127))
#define _s2P(I)         (((I) >= -32768) && ((I) <= 32767))

#define _s1(I)          (_s1P(I) ? (I) : ASMFAIL( "8-bit signed immediate required"))
#define _s2(I)          (_s2P(I) ? (I) : ASMFAIL("16-bit signed immediate required"))

#define _u1(I)          (_u1P(I) ? (I) : ASMFAIL( "8-bit unsigned immediate required"))
#define _u2(I)          (_u2P(I) ? (I) : ASMFAIL("16-bit unsigned immediate required"))

#define _d1(I)          (_s1P(I) ? (I) : ASMFAIL( "8-bit displacement out of range"))

/*** ASSEMBLER ***/

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
                         (((S)==8) ? _b11 : ASMFAIL("illegal scale: " #S))))))

/* memory subformats */

#define _r_D(   X,R, D      )           (_Mrm(X,_b00,_rN(R),_b101 )                              ,_L(X,D))
#define _r_0B(  X,R,   B    )           (_Mrm(X,_b00,_rN(R),_r4(B))                                      )
#define _r_0BIS(X,R,   B,I,S)           (_Mrm(X,_b00,_rN(R),_b100 ),_SIB(X,_SCL(S),_r4(I),_r4(B))        )
#define _r_0DIS(X,R, D,  I,S)           (_Mrm(X,_b00,_rN(R),_b100 ),_SIB(X,_SCL(S),_r4(I),    5 ),_L(X,D))

#define _r_1B(  X,R,   B,D  )           (_Mrm(X,_b01,_rN(R),_r4(B))                              ,_B(X,D))
#define _r_1BIS(X,R,   B,I,S,D)         (_Mrm(X,_b01,_rN(R),_b100 ),_SIB(X,_SCL(S),_r4(I),_r4(B)),_B(X,D))

#define _r_4B(  X,R,   B,D  )           (_Mrm(X,_b10,_rN(R),_r4(B))                              ,_L(X,D))
#define _r_4BIS(X,R,   B,I,S,D)         (_Mrm(X,_b10,_rN(R),_b100 ),_SIB(X,_SCL(S),_r4(I),_r4(B)),_L(X,D))

#define _r_R(   X,R,     M  )           (_Mrm(X,_b11,_rN(R),_rN(M))                                      )

/* immediate operands */

#define ADCir(RS, RD)                   (_B(0,0x15                    ), _L(0, RS                        )) ; rAX  
#define ADCir(RS, RD)                   (_B(0,0x81), _r_R(0,_b010,RD  ), _L(0, RS                        ))
#define ADCir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b010,RD  ), _B(0, RS                        ))

/* instruction generators - sample of common x86 instructions */

#define MOVir(RS, RD)                   (_B(0,0xb8+_r4(RD)           ), _L(0, RS                        ))
#define MOVrr(RS, RD)                   (_B(0,0x89), _r_R(0,     RS,RD)                                  )
#define MOVrm(RS, MD, MB, MI, MS)       (_B(0,0x89), _r_X(0,     RS,   MD,MB,MI,MS                      ))
#define MOVmr(MS, MD, MB, MI, RD)       (_B(0,0x8b), _r_X(0,     RD,   MD,MB,MI,MS                      ))

#define PUSHr(R)                        (_B(0,0x50+_r4(R)                                                ))
#define POPr(R)                         (_B(0,0x58+_r4(R)                                                ))

#define CALLm(MD, MB, MI, MS)           (_B(0,0xff), _r_X(0,_b010,     MD,MB,MI,MS                      ))
#define CALLr(R)                        (_B(0,0xff), _r_R(0,_b010,R                                     ))

#define RET()                           (_B(0,0xc3                                                       ))
#define RETi(IM)                        (_B(0,0xc2                    ), _W(0, IM                        ))

#define ADDir(RS, RD)                   (_B(0,0x05                    ), _L(0, RS                        )) ; rEAX
#define ADDir(RS, RD)                   (_B(0,0x81), _r_R(0,_b000,RD  ), _L(0, RS                        ))
#define ADDir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b000,RD  ), _B(0, RS                        ))
#define ADDrr(RS, RD)                   (_B(0,0x01), _r_R(0,     RS,RD)                                  )

#define SUBir(RS, RD)                   (_B(0,0x2d                    ), _L(0, RS                        )) ; rEAX
#define SUBir(RS, RD)                   (_B(0,0x81), _r_R(0,_b101,RD  ), _L(0, RS                        ))
#define SUBir1(RS, RD)                  (_B(0,0x83), _r_R(0,_b101,RD  ), _B(0, RS                        ))
#define SUBrr(RS, RD)                   (_B(0,0x29), _r_R(0,     RS,RD)                                  )

;;; NOTE: This is a representative sample of the x86 assembler infrastructure.
;;; The complete gen-asm-x86.k file contains many more instruction definitions.
;;; This demonstrates the pattern: load the generic grammar, then provide
;;; architecture-specific #define statements that the grammar processes.