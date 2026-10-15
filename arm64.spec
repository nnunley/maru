# A64 instructions as the Arm ARM draws them: the encoding diagram from bit 31
# down to bit 0, then the assembler syntax.  Literal bits are 0/1; a field is
# its diagram name, Rx and immN having widths 5 and N, any other name:width.
# Operands name the fields they fill: #imm12*8 is a byte offset encoded as
# imm12 times 8, #simm7 is imm7 sign-extended, pc+simm26*4 is a branch target.
# The first row whose operands match is the one that encodes or decodes, so
# aliases (CMP, MOV, MUL) come before what they alias.

1 1 1 100010 0 imm12 Rn 11111		CMP Xn|SP, #imm12
1 1 1 01011 00 0 Rm 000000 Rn 11111	CMP Xn, Xm
0 1 1 01011 00 0 Rm 000000 Rn 11111	CMP Wn, Wm
1 01 01010 00 0 Rm 000000 11111 Rd	MOV Xd, Xm
0 01 01010 00 0 Rm 000000 11111 Rd	MOV Wd, Wm
1 00 11011 000 Rm 0 11111 Rn Rd		MUL Xd, Xn, Xm

1 0 0 100010 0 imm12 Rn Rd		ADD Xd|SP, Xn|SP, #imm12
0 0 0 100010 0 imm12 Rn Rd		ADD Wd|SP, Wn|SP, #imm12
1 0 0 01011 00 0 Rm 000000 Rn Rd	ADD Xd, Xn, Xm
0 0 0 01011 00 0 Rm 000000 Rn Rd	ADD Wd, Wn, Wm
1 1 0 100010 0 imm12 Rn Rd		SUB Xd|SP, Xn|SP, #imm12
1 1 0 01011 00 0 Rm 000000 Rn Rd	SUB Xd, Xn, Xm
1 00 11011 000 Rm 0 Ra Rn Rd		MADD Xd, Xn, Xm, Xa

1 10 100101 hw:2 imm16 Rd		MOVZ Xd, #imm16, LSL #hw*16
1 11 100101 hw:2 imm16 Rd		MOVK Xd, #imm16, LSL #hw*16

11 111 0 01 01 imm12 Rn Rt		LDR Xt, [Xn|SP, #imm12*8]
11 111 0 01 00 imm12 Rn Rt		STR Xt, [Xn|SP, #imm12*8]
10 111 0 01 01 imm12 Rn Rt		LDR Wt, [Xn|SP, #imm12*4]
00 111 0 01 01 imm12 Rn Rt		LDRB Wt, [Xn|SP, #imm12]
10 101 0 010 0 imm7 Rt2 Rn Rt		STP Xt, Xt2, [Xn|SP, #simm7*8]
10 101 0 011 0 imm7 Rt2 Rn Rt		STP Xt, Xt2, [Xn|SP, #simm7*8]!
10 101 0 010 1 imm7 Rt2 Rn Rt		LDP Xt, Xt2, [Xn|SP, #simm7*8]
10 101 0 001 1 imm7 Rt2 Rn Rt		LDP Xt, Xt2, [Xn|SP], #simm7*8

0 00101 imm26				B pc+simm26*4
1 00101 imm26				BL pc+simm26*4
1 011010 0 imm19 Rt			CBZ Xt, pc+simm19*4
1 011010 1 imm19 Rt			CBNZ Xt, pc+simm19*4
1101011 0 0 01 11111 0000 0 0 Rn 00000	BLR Xn
1101011 0 0 10 11111 0000 0 0 11110 00000	RET
1101010100 0 00 011 0010 0000 000 11111	NOP

# Conditional branches, compare-and-branch, test-and-branch, PC-relative
# addresses and literal loads: every field a placeholder can stand for.
0101010 0 imm19 0 0000		B.EQ pc+simm19*4
0101010 0 imm19 0 0001		B.NE pc+simm19*4
0101010 0 imm19 0 0010		B.HS pc+simm19*4
0101010 0 imm19 0 0011		B.LO pc+simm19*4
0101010 0 imm19 0 0100		B.MI pc+simm19*4
0101010 0 imm19 0 0101		B.PL pc+simm19*4
0101010 0 imm19 0 0110		B.VS pc+simm19*4
0101010 0 imm19 0 0111		B.VC pc+simm19*4
0101010 0 imm19 0 1000		B.HI pc+simm19*4
0101010 0 imm19 0 1001		B.LS pc+simm19*4
0101010 0 imm19 0 1010		B.GE pc+simm19*4
0101010 0 imm19 0 1011		B.LT pc+simm19*4
0101010 0 imm19 0 1100		B.GT pc+simm19*4
0101010 0 imm19 0 1101		B.LE pc+simm19*4
0 011010 0 imm19 Rt		CBZ Wt, pc+simm19*4
0 011010 1 imm19 Rt		CBNZ Wt, pc+simm19*4
b5:1 011011 0 b40:5 imm14 Rt	TBZ Xt, #b5:b40, pc+simm14*4
b5:1 011011 1 b40:5 imm14 Rt	TBNZ Xt, #b5:b40, pc+simm14*4
0 immlo:2 10000 immhi:19 Rd	ADR Xd, pc+simmhi:immlo*1
1 immlo:2 10000 immhi:19 Rd	ADRP Xd, pcpage+simmhi:immlo*4096
01 011 0 00 imm19 Rt		LDR Xt, pc+simm19*4
00 011 0 00 imm19 Rt		LDR Wt, pc+simm19*4

# Integer arithmetic (32-bit forms, divide, multiply-subtract, negate).
0 1 0 01011 00 0 Rm 000000 Rn Rd	SUB Wd, Wn, Wm
0 1 0 100010 0 imm12 Rn Rd		SUB Wd|SP, Wn|SP, #imm12
0 00 11011 000 Rm 0 11111 Rn Rd		MUL Wd, Wn, Wm
0 00 11011 000 Rm 0 Ra Rn Rd		MADD Wd, Wn, Wm, Wa
1 00 11011 000 Rm 1 Ra Rn Rd		MSUB Xd, Xn, Xm, Xa
0 00 11011 000 Rm 1 Ra Rn Rd		MSUB Wd, Wn, Wm, Wa
1 0 0 11010110 Rm 00001 1 Rn Rd		SDIV Xd, Xn, Xm
0 0 0 11010110 Rm 00001 1 Rn Rd		SDIV Wd, Wn, Wm
1 0 0 11010110 Rm 00001 0 Rn Rd		UDIV Xd, Xn, Xm
0 0 0 11010110 Rm 00001 0 Rn Rd		UDIV Wd, Wn, Wm
1 1 0 01011 00 0 Rm 000000 11111 Rd	NEG Xd, Xm
0 1 0 01011 00 0 Rm 000000 11111 Rd	NEG Wd, Wm

# Bitwise operations and shifts.  LSR and ASR by an immediate are UBFM/SBFM
# with imms all ones; LSL by an immediate computes immr and imms from the shift.
1 01 01010 00 1 Rm 000000 11111 Rd	MVN Xd, Xm
0 01 01010 00 1 Rm 000000 11111 Rd	MVN Wd, Wm
1 00 01010 00 0 Rm 000000 Rn Rd		AND Xd, Xn, Xm
0 00 01010 00 0 Rm 000000 Rn Rd		AND Wd, Wn, Wm
1 01 01010 00 0 Rm 000000 Rn Rd		ORR Xd, Xn, Xm
0 01 01010 00 0 Rm 000000 Rn Rd		ORR Wd, Wn, Wm
1 10 01010 00 0 Rm 000000 Rn Rd		EOR Xd, Xn, Xm
0 10 01010 00 0 Rm 000000 Rn Rd		EOR Wd, Wn, Wm
1 00 100100 n:1 immr:6 imms:6 Rn Rd	AND Xd|SP, Xn, #bimm64
0 00 100100 0 immr:6 imms:6 Rn Rd	AND Wd|SP, Wn, #bimm32
1 01 100100 n:1 immr:6 imms:6 Rn Rd	ORR Xd|SP, Xn, #bimm64
0 01 100100 0 immr:6 imms:6 Rn Rd	ORR Wd|SP, Wn, #bimm32
1 10 100100 n:1 immr:6 imms:6 Rn Rd	EOR Xd|SP, Xn, #bimm64
0 10 100100 0 immr:6 imms:6 Rn Rd	EOR Wd|SP, Wn, #bimm32
1 0 0 11010110 Rm 0010 00 Rn Rd		LSLV Xd, Xn, Xm
0 0 0 11010110 Rm 0010 00 Rn Rd		LSLV Wd, Wn, Wm
1 0 0 11010110 Rm 0010 01 Rn Rd		LSRV Xd, Xn, Xm
0 0 0 11010110 Rm 0010 01 Rn Rd		LSRV Wd, Wn, Wm
1 0 0 11010110 Rm 0010 10 Rn Rd		ASRV Xd, Xn, Xm
0 0 0 11010110 Rm 0010 10 Rn Rd		ASRV Wd, Wn, Wm
1 10 100110 1 immr:6 111111 Rn Rd	LSR Xd, Xn, #immr
0 10 100110 0 0 immr:5 011111 Rn Rd	LSR Wd, Wn, #immr
1 00 100110 1 immr:6 111111 Rn Rd	ASR Xd, Xn, #immr
0 00 100110 0 0 immr:5 011111 Rn Rd	ASR Wd, Wn, #immr

# Sign and zero extension: SBFM/UBFM with fixed immr and imms.
0 00 100110 0 000000 000111 Rn Rd	SXTB Wd, Wn
1 00 100110 1 000000 000111 Rn Rd	SXTB Xd, Wn
0 00 100110 0 000000 001111 Rn Rd	SXTH Wd, Wn
1 00 100110 1 000000 001111 Rn Rd	SXTH Xd, Wn
1 00 100110 1 000000 011111 Rn Rd	SXTW Xd, Wn
0 10 100110 0 000000 000111 Rn Rd	UXTB Wd, Wn
0 10 100110 0 000000 001111 Rn Rd	UXTH Wd, Wn
1 10 100110 1 immr:6 imms:6 Rn Rd	LSL Xd, Xn, #lslimm64
0 10 100110 0 immr:6 imms:6 Rn Rd	LSL Wd, Wn, #lslimm32

# Comparisons and conditional selects.
0 1 1 100010 0 imm12 Rn 11111		CMP Wn|SP, #imm12
1 0 0 11010100 11111 cond:4 0 1 11111 Rd	CSET Xd, invcond
0 0 0 11010100 11111 cond:4 0 1 11111 Rd	CSET Wd, invcond
1 0 0 11010100 Rm cond:4 0 0 Rn Rd	CSEL Xd, Xn, Xm, cond
0 0 0 11010100 Rm cond:4 0 0 Rn Rd	CSEL Wd, Wn, Wm, cond

# Wide moves (32-bit forms shift by 0 or 16 only).
0 10 100101 0 hw:1 imm16 Rd		MOVZ Wd, #imm16, LSL #hw*16
0 11 100101 0 hw:1 imm16 Rd		MOVK Wd, #imm16, LSL #hw*16
1 00 100101 hw:2 imm16 Rd		MOVN Xd, #imm16, LSL #hw*16
0 00 100101 0 hw:1 imm16 Rd		MOVN Wd, #imm16, LSL #hw*16

# Loads and stores: pre- and post-index (simm9), register offset, and the
# narrow and sign-extending widths.
11 111 0 00 01 0 imm9 11 Rn Rt		LDR Xt, [Xn|SP, #simm9]!
11 111 0 00 01 0 imm9 01 Rn Rt		LDR Xt, [Xn|SP], #simm9
11 111 0 00 01 1 Rm 011 0 10 Rn Rt	LDR Xt, [Xn|SP, Xm]
11 111 0 00 01 1 Rm 011 1 10 Rn Rt	LDR Xt, [Xn|SP, Xm, LSL #3]
10 111 0 00 01 0 imm9 11 Rn Rt		LDR Wt, [Xn|SP, #simm9]!
10 111 0 00 01 0 imm9 01 Rn Rt		LDR Wt, [Xn|SP], #simm9
10 111 0 00 01 1 Rm 011 0 10 Rn Rt	LDR Wt, [Xn|SP, Xm]
10 111 0 00 01 1 Rm 011 1 10 Rn Rt	LDR Wt, [Xn|SP, Xm, LSL #2]
01 111 0 01 01 imm12 Rn Rt		LDRH Wt, [Xn|SP, #imm12*2]
01 111 0 00 01 1 Rm 011 0 10 Rn Rt	LDRH Wt, [Xn|SP, Xm]
00 111 0 00 01 1 Rm 011 0 10 Rn Rt	LDRB Wt, [Xn|SP, Xm]
10 111 0 01 10 imm12 Rn Rt		LDRSW Xt, [Xn|SP, #imm12*4]
10 111 0 00 10 1 Rm 011 0 10 Rn Rt	LDRSW Xt, [Xn|SP, Xm]
01 111 0 01 10 imm12 Rn Rt		LDRSH Xt, [Xn|SP, #imm12*2]
01 111 0 01 11 imm12 Rn Rt		LDRSH Wt, [Xn|SP, #imm12*2]
00 111 0 01 10 imm12 Rn Rt		LDRSB Xt, [Xn|SP, #imm12]
00 111 0 01 11 imm12 Rn Rt		LDRSB Wt, [Xn|SP, #imm12]
11 111 0 00 00 0 imm9 11 Rn Rt		STR Xt, [Xn|SP, #simm9]!
11 111 0 00 00 0 imm9 01 Rn Rt		STR Xt, [Xn|SP], #simm9
11 111 0 00 00 1 Rm 011 0 10 Rn Rt	STR Xt, [Xn|SP, Xm]
11 111 0 00 00 1 Rm 011 1 10 Rn Rt	STR Xt, [Xn|SP, Xm, LSL #3]
10 111 0 01 00 imm12 Rn Rt		STR Wt, [Xn|SP, #imm12*4]
10 111 0 00 00 1 Rm 011 0 10 Rn Rt	STR Wt, [Xn|SP, Xm]
01 111 0 01 00 imm12 Rn Rt		STRH Wt, [Xn|SP, #imm12*2]
00 111 0 01 00 imm12 Rn Rt		STRB Wt, [Xn|SP, #imm12]

# Indirect jumps and returns through a register.
1101011 0 0 00 11111 0000 0 0 Rn 00000	BR Xn
1101011 0 0 10 11111 0000 0 0 Rn 00000	RET Xn

# Floating point: type 00 is single (S), 01 double (D).
00011110 00 1 Rm 0010 10 Rn Rd		FADD Sd, Sn, Sm
00011110 01 1 Rm 0010 10 Rn Rd		FADD Dd, Dn, Dm
00011110 00 1 Rm 0011 10 Rn Rd		FSUB Sd, Sn, Sm
00011110 01 1 Rm 0011 10 Rn Rd		FSUB Dd, Dn, Dm
00011110 00 1 Rm 0000 10 Rn Rd		FMUL Sd, Sn, Sm
00011110 01 1 Rm 0000 10 Rn Rd		FMUL Dd, Dn, Dm
00011110 00 1 Rm 0001 10 Rn Rd		FDIV Sd, Sn, Sm
00011110 01 1 Rm 0001 10 Rn Rd		FDIV Dd, Dn, Dm
00011110 00 1 Rm 0101 10 Rn Rd		FMIN Sd, Sn, Sm
00011110 01 1 Rm 0101 10 Rn Rd		FMIN Dd, Dn, Dm
00011110 00 1 Rm 0100 10 Rn Rd		FMAX Sd, Sn, Sm
00011110 01 1 Rm 0100 10 Rn Rd		FMAX Dd, Dn, Dm
00011110 00 1 000000 10000 Rn Rd	FMOV Sd, Sn
00011110 01 1 000000 10000 Rn Rd	FMOV Dd, Dn
00011110 00 1 000001 10000 Rn Rd	FABS Sd, Sn
00011110 01 1 000001 10000 Rn Rd	FABS Dd, Dn
00011110 00 1 000010 10000 Rn Rd	FNEG Sd, Sn
00011110 01 1 000010 10000 Rn Rd	FNEG Dd, Dn
00011110 00 1 000011 10000 Rn Rd	FSQRT Sd, Sn
00011110 01 1 000011 10000 Rn Rd	FSQRT Dd, Dn
00011110 00 1 000101 10000 Rn Rd	FCVT Dd, Sn
00011110 01 1 000100 10000 Rn Rd	FCVT Sd, Dn
00011110 00 1 Rm 00 1000 Rn 00000	FCMP Sn, Sm
00011110 01 1 Rm 00 1000 Rn 00000	FCMP Dn, Dm
00011110 00 1 Rm cond:4 11 Rn Rd	FCSEL Sd, Sn, Sm, cond
00011110 01 1 Rm cond:4 11 Rn Rd	FCSEL Dd, Dn, Dm, cond
00011110 00 1 imm8 100 00000 Rd		FMOV Sd, #fimm8
00011110 01 1 imm8 100 00000 Rd		FMOV Dd, #fimm8
0 00 11110 00 1 00 110 000000 Rn Rd	FMOV Wd, Sn
0 00 11110 00 1 00 111 000000 Rn Rd	FMOV Sd, Wn
1 00 11110 01 1 00 110 000000 Rn Rd	FMOV Xd, Dn
1 00 11110 01 1 00 111 000000 Rn Rd	FMOV Dd, Xn
0 00 11110 00 1 00 010 000000 Rn Rd	SCVTF Sd, Wn
1 00 11110 00 1 00 010 000000 Rn Rd	SCVTF Sd, Xn
0 00 11110 01 1 00 010 000000 Rn Rd	SCVTF Dd, Wn
1 00 11110 01 1 00 010 000000 Rn Rd	SCVTF Dd, Xn
0 00 11110 00 1 00 011 000000 Rn Rd	UCVTF Sd, Wn
1 00 11110 01 1 00 011 000000 Rn Rd	UCVTF Dd, Xn
1 00 11110 00 1 00 011 000000 Rn Rd	UCVTF Sd, Xn
0 00 11110 01 1 00 011 000000 Rn Rd	UCVTF Dd, Wn
0 00 11110 00 1 11 000 000000 Rn Rd	FCVTZS Wd, Sn
1 00 11110 00 1 11 000 000000 Rn Rd	FCVTZS Xd, Sn
0 00 11110 01 1 11 000 000000 Rn Rd	FCVTZS Wd, Dn
1 00 11110 01 1 11 000 000000 Rn Rd	FCVTZS Xd, Dn
0 00 11110 00 1 11 001 000000 Rn Rd	FCVTZU Wd, Sn
1 00 11110 01 1 11 001 000000 Rn Rd	FCVTZU Xd, Dn
1 00 11110 00 1 11 001 000000 Rn Rd	FCVTZU Xd, Sn
0 00 11110 01 1 11 001 000000 Rn Rd	FCVTZU Wd, Dn
10 111 1 01 01 imm12 Rn Rt		LDR St, [Xn|SP, #imm12*4]
10 111 1 00 01 1 Rm 011 1 10 Rn Rt	LDR St, [Xn|SP, Xm, LSL #2]
11 111 1 01 01 imm12 Rn Rt		LDR Dt, [Xn|SP, #imm12*8]
11 111 1 00 01 1 Rm 011 1 10 Rn Rt	LDR Dt, [Xn|SP, Xm, LSL #3]
10 111 1 01 00 imm12 Rn Rt		STR St, [Xn|SP, #imm12*4]
11 111 1 01 00 imm12 Rn Rt		STR Dt, [Xn|SP, #imm12*8]
01 101 1 010 0 imm7 Rt2 Rn Rt		STP Dt, Dt2, [Xn|SP, #simm7*8]
01 101 1 010 1 imm7 Rt2 Rn Rt		LDP Dt, Dt2, [Xn|SP, #simm7*8]

# ---------------------------------------------------------------- Advanced SIMD (NEON)
# Vd.T is a vector register with arrangement T (8B 16B 4H 8H 2S 4S 1D 2D), the
# same for every operand that names T; T sets the row's q, size or sz fields
# (or comes from immh), and T=... lists the arrangements the row allows
# (default: all but 1D, or 2S 4S 2D where the row has sz).  Vn.S[#index] is a
# lane.  Data: (V 3 4S) is V3.4S, (V 3 S 1) is V3.S[1].

# Three registers, same arrangement: integer.
0 q:1 0 01110 size:2 1 Rm 10000 1 Rn Rd		ADD Vd.T, Vn.T, Vm.T
0 q:1 1 01110 size:2 1 Rm 10000 1 Rn Rd		SUB Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 1 Rm 10011 1 Rn Rd		MUL Vd.T, Vn.T, Vm.T T=8B|16B|4H|8H|2S|4S
0 q:1 1 01110 size:2 1 Rm 10001 1 Rn Rd		CMEQ Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 1 Rm 00110 1 Rn Rd		CMGT Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 1 Rm 00111 1 Rn Rd		CMGE Vd.T, Vn.T, Vm.T
0 q:1 1 01110 size:2 1 Rm 00110 1 Rn Rd		CMHI Vd.T, Vn.T, Vm.T
0 q:1 1 01110 size:2 1 Rm 00111 1 Rn Rd		CMHS Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 1 Rm 01100 1 Rn Rd		SMAX Vd.T, Vn.T, Vm.T T=8B|16B|4H|8H|2S|4S
0 q:1 0 01110 size:2 1 Rm 01101 1 Rn Rd		SMIN Vd.T, Vn.T, Vm.T T=8B|16B|4H|8H|2S|4S
0 q:1 1 01110 size:2 1 Rm 01100 1 Rn Rd		UMAX Vd.T, Vn.T, Vm.T T=8B|16B|4H|8H|2S|4S
0 q:1 1 01110 size:2 1 Rm 01101 1 Rn Rd		UMIN Vd.T, Vn.T, Vm.T T=8B|16B|4H|8H|2S|4S
0 q:1 0 01110 size:2 1 Rm 01000 1 Rn Rd		SSHL Vd.T, Vn.T, Vm.T
0 q:1 1 01110 size:2 1 Rm 01000 1 Rn Rd		USHL Vd.T, Vn.T, Vm.T
0 q:1 0 01110 00 1 Rm 00011 1 Rn Rd		AND Vd.T, Vn.T, Vm.T T=8B|16B
0 q:1 0 01110 01 1 Rm 00011 1 Rn Rd		BIC Vd.T, Vn.T, Vm.T T=8B|16B
0 q:1 0 01110 10 1 Rm 00011 1 Rn Rd		ORR Vd.T, Vn.T, Vm.T T=8B|16B
0 q:1 1 01110 00 1 Rm 00011 1 Rn Rd		EOR Vd.T, Vn.T, Vm.T T=8B|16B
0 q:1 1 01110 00 10000 00101 10 Rn Rd		NOT Vd.T, Vn.T T=8B|16B
0 q:1 1 01110 size:2 10000 01011 10 Rn Rd	NEG Vd.T, Vn.T

# Shifts by an immediate: immh:immb is esize + shift (SHL) or 2*esize - shift.
0 q:1 0 011110 immh:4 immb:3 01010 1 Rn Rd	SHL Vd.T, Vn.T, #vshl
0 q:1 0 011110 immh:4 immb:3 00000 1 Rn Rd	SSHR Vd.T, Vn.T, #vshr
0 q:1 1 011110 immh:4 immb:3 00000 1 Rn Rd	USHR Vd.T, Vn.T, #vshr

# Floating point (2S 4S 2D).
0 q:1 0 01110 0 sz:1 1 Rm 11010 1 Rn Rd		FADD Vd.T, Vn.T, Vm.T
0 q:1 0 01110 1 sz:1 1 Rm 11010 1 Rn Rd		FSUB Vd.T, Vn.T, Vm.T
0 q:1 1 01110 0 sz:1 1 Rm 11011 1 Rn Rd		FMUL Vd.T, Vn.T, Vm.T
0 q:1 1 01110 0 sz:1 1 Rm 11111 1 Rn Rd		FDIV Vd.T, Vn.T, Vm.T
0 q:1 0 01110 0 sz:1 1 Rm 11001 1 Rn Rd		FMLA Vd.T, Vn.T, Vm.T
0 q:1 0 01110 0 sz:1 1 Rm 11110 1 Rn Rd		FMAX Vd.T, Vn.T, Vm.T
0 q:1 0 01110 1 sz:1 1 Rm 11110 1 Rn Rd		FMIN Vd.T, Vn.T, Vm.T
0 q:1 0 01110 0 sz:1 1 Rm 11100 1 Rn Rd		FCMEQ Vd.T, Vn.T, Vm.T
0 q:1 1 01110 0 sz:1 1 Rm 11100 1 Rn Rd		FCMGE Vd.T, Vn.T, Vm.T
0 q:1 1 01110 1 sz:1 1 Rm 11100 1 Rn Rd		FCMGT Vd.T, Vn.T, Vm.T
0 q:1 1 01110 0 sz:1 1 Rm 11010 1 Rn Rd		FADDP Vd.T, Vn.T, Vm.T
0 q:1 1 01110 1 sz:1 10000 01111 10 Rn Rd	FNEG Vd.T, Vn.T
0 q:1 0 01110 1 sz:1 10000 01111 10 Rn Rd	FABS Vd.T, Vn.T
0 q:1 1 01110 1 sz:1 10000 11111 10 Rn Rd	FSQRT Vd.T, Vn.T
0 q:1 0 01110 0 sz:1 10000 11101 10 Rn Rd	SCVTF Vd.T, Vn.T
0 q:1 1 01110 0 sz:1 10000 11101 10 Rn Rd	UCVTF Vd.T, Vn.T
0 q:1 0 01110 1 sz:1 10000 11011 10 Rn Rd	FCVTZS Vd.T, Vn.T
0 q:1 1 01110 1 sz:1 10000 11011 10 Rn Rd	FCVTZU Vd.T, Vn.T

# Broadcast, insert, extract: the element size is fixed per row.
0 q:1 0 01110000 00001 0 0001 1 Rn Rd		DUP Vd.T, Wn T=8B|16B
0 q:1 0 01110000 00010 0 0001 1 Rn Rd		DUP Vd.T, Wn T=4H|8H
0 q:1 0 01110000 00100 0 0001 1 Rn Rd		DUP Vd.T, Wn T=2S|4S
0 q:1 0 01110000 01000 0 0001 1 Rn Rd		DUP Vd.T, Xn T=2D
0 q:1 0 01110000 index:2 100 0 0000 1 Rn Rd	DUP Vd.T, Vn.S[#index] T=2S|4S
0 q:1 0 01110000 index:1 1000 0 0000 1 Rn Rd	DUP Vd.T, Vn.D[#index] T=2D
0 1 0 01110000 index:4 1 0 0011 1 Rn Rd		INS Vd.B[#index], Wn
0 1 0 01110000 index:3 10 0 0011 1 Rn Rd		INS Vd.H[#index], Wn
0 1 0 01110000 index:2 100 0 0011 1 Rn Rd	INS Vd.S[#index], Wn
0 1 0 01110000 index:1 1000 0 0011 1 Rn Rd	INS Vd.D[#index], Xn
0 0 0 01110000 index:4 1 0 0111 1 Rn Rd		UMOV Wd, Vn.B[#index]
0 0 0 01110000 index:3 10 0 0111 1 Rn Rd		UMOV Wd, Vn.H[#index]
0 0 0 01110000 index:2 100 0 0111 1 Rn Rd	UMOV Wd, Vn.S[#index]
0 1 0 01110000 index:1 1000 0 0111 1 Rn Rd	UMOV Xd, Vn.D[#index]
0 1 0 01110000 index:4 1 0 0101 1 Rn Rd		SMOV Xd, Vn.B[#index]
0 1 0 01110000 index:3 10 0 0101 1 Rn Rd		SMOV Xd, Vn.H[#index]
0 1 0 01110000 index:2 100 0 0101 1 Rn Rd	SMOV Xd, Vn.S[#index]

# Shuffles and permutes.
0 0 101110 00 0 Rm 0 0 imm4:3 0 Rn Rd		EXT Vd.T, Vn.T, Vm.T, #imm4 T=8B
0 1 101110 00 0 Rm 0 imm4 0 Rn Rd		EXT Vd.T, Vn.T, Vm.T, #imm4 T=16B
0 q:1 0 01110 size:2 0 Rm 0 011 10 Rn Rd	ZIP1 Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 0 Rm 0 111 10 Rn Rd	ZIP2 Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 0 Rm 0 001 10 Rn Rd	UZP1 Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 0 Rm 0 101 10 Rn Rd	UZP2 Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 0 Rm 0 010 10 Rn Rd	TRN1 Vd.T, Vn.T, Vm.T
0 q:1 0 01110 size:2 0 Rm 0 110 10 Rn Rd	TRN2 Vd.T, Vn.T, Vm.T
0 q:1 001110 000 Rm 0 00 0 00 Rn Rd		TBL Vd.T, {Vn.16B}, Vm.T T=8B|16B

# Reductions.
0 q:1 0 01110 size:2 11000 11011 10 Rn Rd	ADDV Bd, Vn.T T=8B|16B
0 q:1 0 01110 size:2 11000 11011 10 Rn Rd	ADDV Hd, Vn.T T=4H|8H
0 1 0 01110 10 11000 11011 10 Rn Rd		ADDV Sd, Vn.4S
0 1 1 01110 0 0 11000 01111 10 Rn Rd		FMAXV Sd, Vn.4S
0 1 1 01110 1 0 11000 01111 10 Rn Rd		FMINV Sd, Vn.4S

# Vector loads and stores.
0 q:1 0011000 1 000000 0111 size:2 Rn Rt	LD1 {Vt.T}, [Xn|SP] T=8B|16B|4H|8H|2S|4S|1D|2D
0 q:1 0011000 0 000000 0111 size:2 Rn Rt	ST1 {Vt.T}, [Xn|SP] T=8B|16B|4H|8H|2S|4S|1D|2D
00 111 1 01 11 imm12 Rn Rt			LDR Qt, [Xn|SP, #imm12*16]
00 111 1 01 10 imm12 Rn Rt			STR Qt, [Xn|SP, #imm12*16]
