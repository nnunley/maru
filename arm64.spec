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
