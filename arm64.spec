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
