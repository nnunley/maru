# x86 instructions as the Intel SDM vol. 2 opcode tables write them: opcode,
# instruction, then whether the row is valid in 64-bit mode and in
# compatibility/legacy (32-bit) mode.  Columns are separated by tabs.
#
# The first row whose operands match encodes, so shorter forms come first:
# sign-extended imm8 before the accumulator forms before imm32.  Marker u in
# the opcode column makes the row's immediate unsigned; o32 sets a 32-bit
# operand size where no operand shows one.  REX.W, and the REX prefix needed
# for registers R8-R15, XMM8-XMM15 and SPL, BPL, SIL, DIL, follow the SDM.


# Arithmetic and logic: ADD OR AND SUB XOR CMP
00 /r			ADD r/m8, r8			V V
01 /r			ADD r/m16, r16			V V
01 /r			ADD r/m32, r32			V V
REX.W + 01 /r		ADD r/m64, r64			V NE
02 /r			ADD r8, r/m8			V V
03 /r			ADD r16, r/m16			V V
03 /r			ADD r32, r/m32			V V
REX.W + 03 /r		ADD r64, r/m64			V NE
04 ib			ADD AL, imm8			V V
80 /0 ib		ADD r/m8, imm8			V V
83 /0 ib		ADD r/m16, imm8			V V
83 /0 ib		ADD r/m32, imm8			V V
REX.W + 83 /0 ib	ADD r/m64, imm8			V NE
05 iw			ADD AX, imm16			V V
05 id			ADD EAX, imm32			V V
REX.W + 05 id		ADD RAX, imm32			V NE
81 /0 iw		ADD r/m16, imm16		V V
81 /0 id		ADD r/m32, imm32		V V
REX.W + 81 /0 id	ADD r/m64, imm32		V NE
08 /r			OR r/m8, r8			V V
09 /r			OR r/m16, r16			V V
09 /r			OR r/m32, r32			V V
REX.W + 09 /r		OR r/m64, r64			V NE
0A /r			OR r8, r/m8			V V
0B /r			OR r16, r/m16			V V
0B /r			OR r32, r/m32			V V
REX.W + 0B /r		OR r64, r/m64			V NE
0C ib			OR AL, imm8			V V
80 /1 ib		OR r/m8, imm8			V V
83 /1 ib		OR r/m16, imm8			V V
83 /1 ib		OR r/m32, imm8			V V
REX.W + 83 /1 ib	OR r/m64, imm8			V NE
0D iw			OR AX, imm16			V V
0D id			OR EAX, imm32			V V
REX.W + 0D id		OR RAX, imm32			V NE
81 /1 iw		OR r/m16, imm16			V V
81 /1 id		OR r/m32, imm32			V V
REX.W + 81 /1 id	OR r/m64, imm32			V NE
20 /r			AND r/m8, r8			V V
21 /r			AND r/m16, r16			V V
21 /r			AND r/m32, r32			V V
REX.W + 21 /r		AND r/m64, r64			V NE
22 /r			AND r8, r/m8			V V
23 /r			AND r16, r/m16			V V
23 /r			AND r32, r/m32			V V
REX.W + 23 /r		AND r64, r/m64			V NE
24 ib			AND AL, imm8			V V
80 /4 ib		AND r/m8, imm8			V V
83 /4 ib		AND r/m16, imm8			V V
83 /4 ib		AND r/m32, imm8			V V
REX.W + 83 /4 ib	AND r/m64, imm8			V NE
25 iw			AND AX, imm16			V V
25 id			AND EAX, imm32			V V
REX.W + 25 id		AND RAX, imm32			V NE
81 /4 iw		AND r/m16, imm16		V V
81 /4 id		AND r/m32, imm32		V V
REX.W + 81 /4 id	AND r/m64, imm32		V NE
28 /r			SUB r/m8, r8			V V
29 /r			SUB r/m16, r16			V V
29 /r			SUB r/m32, r32			V V
REX.W + 29 /r		SUB r/m64, r64			V NE
2A /r			SUB r8, r/m8			V V
2B /r			SUB r16, r/m16			V V
2B /r			SUB r32, r/m32			V V
REX.W + 2B /r		SUB r64, r/m64			V NE
2C ib			SUB AL, imm8			V V
80 /5 ib		SUB r/m8, imm8			V V
83 /5 ib		SUB r/m16, imm8			V V
83 /5 ib		SUB r/m32, imm8			V V
REX.W + 83 /5 ib	SUB r/m64, imm8			V NE
2D iw			SUB AX, imm16			V V
2D id			SUB EAX, imm32			V V
REX.W + 2D id		SUB RAX, imm32			V NE
81 /5 iw		SUB r/m16, imm16		V V
81 /5 id		SUB r/m32, imm32		V V
REX.W + 81 /5 id	SUB r/m64, imm32		V NE
30 /r			XOR r/m8, r8			V V
31 /r			XOR r/m16, r16			V V
31 /r			XOR r/m32, r32			V V
REX.W + 31 /r		XOR r/m64, r64			V NE
32 /r			XOR r8, r/m8			V V
33 /r			XOR r16, r/m16			V V
33 /r			XOR r32, r/m32			V V
REX.W + 33 /r		XOR r64, r/m64			V NE
34 ib			XOR AL, imm8			V V
80 /6 ib		XOR r/m8, imm8			V V
83 /6 ib		XOR r/m16, imm8			V V
83 /6 ib		XOR r/m32, imm8			V V
REX.W + 83 /6 ib	XOR r/m64, imm8			V NE
35 iw			XOR AX, imm16			V V
35 id			XOR EAX, imm32			V V
REX.W + 35 id		XOR RAX, imm32			V NE
81 /6 iw		XOR r/m16, imm16		V V
81 /6 id		XOR r/m32, imm32		V V
REX.W + 81 /6 id	XOR r/m64, imm32		V NE
38 /r			CMP r/m8, r8			V V
39 /r			CMP r/m16, r16			V V
39 /r			CMP r/m32, r32			V V
REX.W + 39 /r		CMP r/m64, r64			V NE
3A /r			CMP r8, r/m8			V V
3B /r			CMP r16, r/m16			V V
3B /r			CMP r32, r/m32			V V
REX.W + 3B /r		CMP r64, r/m64			V NE
3C ib			CMP AL, imm8			V V
80 /7 ib		CMP r/m8, imm8			V V
83 /7 ib		CMP r/m16, imm8			V V
83 /7 ib		CMP r/m32, imm8			V V
REX.W + 83 /7 ib	CMP r/m64, imm8			V NE
3D iw			CMP AX, imm16			V V
3D id			CMP EAX, imm32			V V
REX.W + 3D id		CMP RAX, imm32			V NE
81 /7 iw		CMP r/m16, imm16		V V
81 /7 id		CMP r/m32, imm32		V V
REX.W + 81 /7 id	CMP r/m64, imm32		V NE

# TEST
84 /r			TEST r/m8, r8			V V
85 /r			TEST r/m16, r16			V V
85 /r			TEST r/m32, r32			V V
REX.W + 85 /r		TEST r/m64, r64			V NE
A8 ib			TEST AL, imm8			V V
A9 iw			TEST AX, imm16			V V
A9 id			TEST EAX, imm32			V V
REX.W + A9 id		TEST RAX, imm32			V NE
F6 /0 ib		TEST r/m8, imm8			V V
F7 /0 iw		TEST r/m16, imm16		V V
F7 /0 id		TEST r/m32, imm32		V V
REX.W + F7 /0 id	TEST r/m64, imm32		V NE

# Moves
88 /r			MOV r/m8, r8			V V
89 /r			MOV r/m16, r16			V V
89 /r			MOV r/m32, r32			V V
REX.W + 89 /r		MOV r/m64, r64			V NE
8A /r			MOV r8, r/m8			V V
8B /r			MOV r16, r/m16			V V
8B /r			MOV r32, r/m32			V V
REX.W + 8B /r		MOV r64, r/m64			V NE
B0+rb ib		MOV r8, imm8			V V
B8+rw iw		MOV r16, imm16			V V
B8+rd id		MOV r32, imm32			V V
C6 /0 ib		MOV r/m8, imm8			V V
C7 /0 iw		MOV r/m16, imm16		V V
C7 /0 id		MOV r/m32, imm32		V V
REX.W + C7 /0 id	MOV r/m64, imm32		V NE
REX.W + B8+rd io	MOV r64, imm64			V NE
8D /r			LEA r32, m			V V
REX.W + 8D /r		LEA r64, m			V NE
0F B6 /r		MOVZX r32, r/m8			V V
0F B7 /r		MOVZX r32, r/m16		V V
REX.W + 0F B6 /r	MOVZX r64, r/m8			V NE
REX.W + 0F B7 /r	MOVZX r64, r/m16		V NE
0F BE /r		MOVSX r32, r/m8			V V
0F BF /r		MOVSX r32, r/m16		V V
REX.W + 0F BE /r	MOVSX r64, r/m8			V NE
REX.W + 0F BF /r	MOVSX r64, r/m16		V NE
REX.W + 63 /r		MOVSXD r64, r/m32		V NE

# Multiply, divide, negate, complement
0F AF /r		IMUL r32, r/m32			V V
REX.W + 0F AF /r	IMUL r64, r/m64			V NE
6B /r ib		IMUL r32, r/m32, imm8		V V
REX.W + 6B /r ib	IMUL r64, r/m64, imm8		V NE
69 /r id		IMUL r32, r/m32, imm32		V V
REX.W + 69 /r id	IMUL r64, r/m64, imm32		V NE
F6 /2			NOT r/m8			V V
F7 /2			NOT r/m16			V V
F7 /2			NOT r/m32			V V
REX.W + F7 /2		NOT r/m64			V NE
F6 /3			NEG r/m8			V V
F7 /3			NEG r/m16			V V
F7 /3			NEG r/m32			V V
REX.W + F7 /3		NEG r/m64			V NE
F6 /6			DIV r/m8			V V
F7 /6			DIV r/m16			V V
F7 /6			DIV r/m32			V V
REX.W + F7 /6		DIV r/m64			V NE
F6 /7			IDIV r/m8			V V
F7 /7			IDIV r/m16			V V
F7 /7			IDIV r/m32			V V
REX.W + F7 /7		IDIV r/m64			V NE
99			CDQ				V V
REX.W + 99		CQO				V NE

# Shifts: by 1, by an unsigned imm8 count, by CL
D0 /4			SHL r/m8, 1			V V
D1 /4			SHL r/m16, 1			V V
D1 /4			SHL r/m32, 1			V V
REX.W + D1 /4		SHL r/m64, 1			V NE
C0 /4 ib u		SHL r/m8, imm8			V V
C1 /4 ib u		SHL r/m16, imm8			V V
C1 /4 ib u		SHL r/m32, imm8			V V
REX.W + C1 /4 ib u	SHL r/m64, imm8			V NE
D2 /4			SHL r/m8, CL			V V
D3 /4			SHL r/m16, CL			V V
D3 /4			SHL r/m32, CL			V V
REX.W + D3 /4		SHL r/m64, CL			V NE
D0 /5			SHR r/m8, 1			V V
D1 /5			SHR r/m16, 1			V V
D1 /5			SHR r/m32, 1			V V
REX.W + D1 /5		SHR r/m64, 1			V NE
C0 /5 ib u		SHR r/m8, imm8			V V
C1 /5 ib u		SHR r/m16, imm8			V V
C1 /5 ib u		SHR r/m32, imm8			V V
REX.W + C1 /5 ib u	SHR r/m64, imm8			V NE
D2 /5			SHR r/m8, CL			V V
D3 /5			SHR r/m16, CL			V V
D3 /5			SHR r/m32, CL			V V
REX.W + D3 /5		SHR r/m64, CL			V NE
D0 /7			SAR r/m8, 1			V V
D1 /7			SAR r/m16, 1			V V
D1 /7			SAR r/m32, 1			V V
REX.W + D1 /7		SAR r/m64, 1			V NE
C0 /7 ib u		SAR r/m8, imm8			V V
C1 /7 ib u		SAR r/m16, imm8			V V
C1 /7 ib u		SAR r/m32, imm8			V V
REX.W + C1 /7 ib u	SAR r/m64, imm8			V NE
D2 /7			SAR r/m8, CL			V V
D3 /7			SAR r/m16, CL			V V
D3 /7			SAR r/m32, CL			V V
REX.W + D3 /7		SAR r/m64, CL			V NE

# Conditions: SETcc, then Jcc short and near
0F 90 /0		SETO r/m8			V V
0F 91 /0		SETNO r/m8			V V
0F 92 /0		SETB r/m8			V V
0F 93 /0		SETAE r/m8			V V
0F 94 /0		SETE r/m8			V V
0F 95 /0		SETNE r/m8			V V
0F 96 /0		SETBE r/m8			V V
0F 97 /0		SETA r/m8			V V
0F 98 /0		SETS r/m8			V V
0F 99 /0		SETNS r/m8			V V
0F 9A /0		SETP r/m8			V V
0F 9B /0		SETNP r/m8			V V
0F 9C /0		SETL r/m8			V V
0F 9D /0		SETGE r/m8			V V
0F 9E /0		SETLE r/m8			V V
0F 9F /0		SETG r/m8			V V
70 cb			JO rel8				V V
71 cb			JNO rel8			V V
72 cb			JB rel8				V V
73 cb			JAE rel8			V V
74 cb			JE rel8				V V
75 cb			JNE rel8			V V
76 cb			JBE rel8			V V
77 cb			JA rel8				V V
78 cb			JS rel8				V V
79 cb			JNS rel8			V V
7A cb			JP rel8				V V
7B cb			JNP rel8			V V
7C cb			JL rel8				V V
7D cb			JGE rel8			V V
7E cb			JLE rel8			V V
7F cb			JG rel8				V V
0F 80 cd		JO rel32			V V
0F 81 cd		JNO rel32			V V
0F 82 cd		JB rel32			V V
0F 83 cd		JAE rel32			V V
0F 84 cd		JE rel32			V V
0F 85 cd		JNE rel32			V V
0F 86 cd		JBE rel32			V V
0F 87 cd		JA rel32			V V
0F 88 cd		JS rel32			V V
0F 89 cd		JNS rel32			V V
0F 8A cd		JP rel32			V V
0F 8B cd		JNP rel32			V V
0F 8C cd		JL rel32			V V
0F 8D cd		JGE rel32			V V
0F 8E cd		JLE rel32			V V
0F 8F cd		JG rel32			V V

# Jumps, calls, returns, the stack
EB cb			JMP rel8			V V
E9 cd			JMP rel32			V V
FF /4			JMP r/m64			V NE
FF /4			JMP r/m32			NE V
E8 cd			CALL rel32			V V
FF /2			CALL r/m64			V NE
FF /2			CALL r/m32			NE V
C3			RET				V V
C2 iw u			RET imm16			V V
50+rd			PUSH r64			V NE
50+rd			PUSH r32			NE V
58+rd			POP r64				V NE
58+rd			POP r32				NE V
6A ib o32		PUSH imm8			V V
68 id o32		PUSH imm32			V V
FF /0			INC r/m32			V V
FF /1			DEC r/m32			V V
40+rd			INC r32				NE V
48+rd			DEC r32				NE V
C9			LEAVE				V V
90			NOP				V V
F4			HLT				V V
CD ib u			INT imm8			V V
E6 ib u			OUT imm8, AL			V V

# SSE scalar: float in the low lane of an XMM register
F3 0F 58 /r		ADDSS xmm, xmm/m32		V V
F2 0F 58 /r		ADDSD xmm, xmm/m64		V V
F3 0F 59 /r		MULSS xmm, xmm/m32		V V
F2 0F 59 /r		MULSD xmm, xmm/m64		V V
F3 0F 5C /r		SUBSS xmm, xmm/m32		V V
F2 0F 5C /r		SUBSD xmm, xmm/m64		V V
F3 0F 5D /r		MINSS xmm, xmm/m32		V V
F2 0F 5D /r		MINSD xmm, xmm/m64		V V
F3 0F 5E /r		DIVSS xmm, xmm/m32		V V
F2 0F 5E /r		DIVSD xmm, xmm/m64		V V
F3 0F 5F /r		MAXSS xmm, xmm/m32		V V
F2 0F 5F /r		MAXSD xmm, xmm/m64		V V
F3 0F 51 /r		SQRTSS xmm, xmm/m32		V V
F2 0F 51 /r		SQRTSD xmm, xmm/m64		V V
F3 0F 10 /r		MOVSS xmm, xmm/m32		V V
F3 0F 11 /r		MOVSS xmm/m32, xmm		V V
F2 0F 10 /r		MOVSD xmm, xmm/m64		V V
F2 0F 11 /r		MOVSD xmm/m64, xmm		V V
0F 2E /r		UCOMISS xmm, xmm/m32		V V
66 0F 2E /r		UCOMISD xmm, xmm/m64		V V
F3 0F 2A /r		CVTSI2SS xmm, r/m32		V V
F3 REX.W + 0F 2A /r	CVTSI2SS xmm, r/m64		V NE
F2 0F 2A /r		CVTSI2SD xmm, r/m32		V V
F2 REX.W + 0F 2A /r	CVTSI2SD xmm, r/m64		V NE
F3 0F 2C /r		CVTTSS2SI r32, xmm/m32		V V
F3 REX.W + 0F 2C /r	CVTTSS2SI r64, xmm/m32		V NE
F2 0F 2C /r		CVTTSD2SI r32, xmm/m64		V V
F2 REX.W + 0F 2C /r	CVTTSD2SI r64, xmm/m64		V NE
F3 0F 5A /r		CVTSS2SD xmm, xmm/m32		V V
F2 0F 5A /r		CVTSD2SS xmm, xmm/m64		V V
66 0F 6E /r		MOVD xmm, r/m32			V V
66 0F 7E /r		MOVD r/m32, xmm			V V
F3 0F 7E /r		MOVQ xmm, xmm/m64		V V
66 0F D6 /r		MOVQ xmm/m64, xmm		V V
66 REX.W + 0F 6E /r	MOVQ xmm, r/m64			V NE
66 REX.W + 0F 7E /r	MOVQ r/m64, xmm			V NE
0F 54 /r		ANDPS xmm, xmm/m128		V V
0F 55 /r		ANDNPS xmm, xmm/m128		V V
0F 56 /r		ORPS xmm, xmm/m128		V V
0F 57 /r		XORPS xmm, xmm/m128		V V


# SSE packed floating point (4 x float as PS, 2 x double as PD)
0F 58 /r		ADDPS xmm, xmm/m128		V V
66 0F 58 /r		ADDPD xmm, xmm/m128		V V
0F 59 /r		MULPS xmm, xmm/m128		V V
66 0F 59 /r		MULPD xmm, xmm/m128		V V
0F 5C /r		SUBPS xmm, xmm/m128		V V
66 0F 5C /r		SUBPD xmm, xmm/m128		V V
0F 5D /r		MINPS xmm, xmm/m128		V V
66 0F 5D /r		MINPD xmm, xmm/m128		V V
0F 5E /r		DIVPS xmm, xmm/m128		V V
66 0F 5E /r		DIVPD xmm, xmm/m128		V V
0F 5F /r		MAXPS xmm, xmm/m128		V V
66 0F 5F /r		MAXPD xmm, xmm/m128		V V
0F 51 /r		SQRTPS xmm, xmm/m128		V V
66 0F 51 /r		SQRTPD xmm, xmm/m128		V V
66 0F 54 /r		ANDPD xmm, xmm/m128		V V
66 0F 55 /r		ANDNPD xmm, xmm/m128		V V
66 0F 56 /r		ORPD xmm, xmm/m128		V V
66 0F 57 /r		XORPD xmm, xmm/m128		V V
0F C2 /r ib u		CMPPS xmm, xmm/m128, imm8	V V
66 0F C2 /r ib u	CMPPD xmm, xmm/m128, imm8	V V
F2 0F 7C /r		HADDPS xmm, xmm/m128		V V
66 0F 7C /r		HADDPD xmm, xmm/m128		V V
66 0F 3A 40 /r ib u	DPPS xmm, xmm/m128, imm8	V V

# SSE packed integer
66 0F FC /r		PADDB xmm, xmm/m128		V V
66 0F FD /r		PADDW xmm, xmm/m128		V V
66 0F FE /r		PADDD xmm, xmm/m128		V V
66 0F D4 /r		PADDQ xmm, xmm/m128		V V
66 0F F8 /r		PSUBB xmm, xmm/m128		V V
66 0F F9 /r		PSUBW xmm, xmm/m128		V V
66 0F FA /r		PSUBD xmm, xmm/m128		V V
66 0F FB /r		PSUBQ xmm, xmm/m128		V V
66 0F D5 /r		PMULLW xmm, xmm/m128		V V
66 0F 74 /r		PCMPEQB xmm, xmm/m128		V V
66 0F 75 /r		PCMPEQW xmm, xmm/m128		V V
66 0F 76 /r		PCMPEQD xmm, xmm/m128		V V
66 0F 64 /r		PCMPGTB xmm, xmm/m128		V V
66 0F 65 /r		PCMPGTW xmm, xmm/m128		V V
66 0F 66 /r		PCMPGTD xmm, xmm/m128		V V
66 0F DB /r		PAND xmm, xmm/m128		V V
66 0F DF /r		PANDN xmm, xmm/m128		V V
66 0F EB /r		POR xmm, xmm/m128		V V
66 0F EF /r		PXOR xmm, xmm/m128		V V
66 0F 62 /r		PUNPCKLDQ xmm, xmm/m128		V V
66 0F 6A /r		PUNPCKHDQ xmm, xmm/m128		V V
66 0F 6C /r		PUNPCKLQDQ xmm, xmm/m128	V V
66 0F 6D /r		PUNPCKHQDQ xmm, xmm/m128	V V
66 0F 38 00 /r		PSHUFB xmm, xmm/m128		V V
66 0F 38 01 /r		PHADDW xmm, xmm/m128		V V
66 0F 38 02 /r		PHADDD xmm, xmm/m128		V V
66 0F 38 29 /r		PCMPEQQ xmm, xmm/m128		V V
66 0F 38 37 /r		PCMPGTQ xmm, xmm/m128		V V
66 0F 38 38 /r		PMINSB xmm, xmm/m128		V V
66 0F 38 39 /r		PMINSD xmm, xmm/m128		V V
66 0F 38 3A /r		PMINUW xmm, xmm/m128		V V
66 0F 38 3B /r		PMINUD xmm, xmm/m128		V V
66 0F 38 3C /r		PMAXSB xmm, xmm/m128		V V
66 0F 38 3D /r		PMAXSD xmm, xmm/m128		V V
66 0F 38 3E /r		PMAXUW xmm, xmm/m128		V V
66 0F 38 3F /r		PMAXUD xmm, xmm/m128		V V
66 0F 38 40 /r		PMULLD xmm, xmm/m128		V V

# SSE shifts: by an immediate count (the register in ModRM.rm), by a count in an XMM register
66 0F 71 /6 ib u	PSLLW xmm, imm8			V V
66 0F 72 /6 ib u	PSLLD xmm, imm8			V V
66 0F 73 /6 ib u	PSLLQ xmm, imm8			V V
66 0F 71 /2 ib u	PSRLW xmm, imm8			V V
66 0F 72 /2 ib u	PSRLD xmm, imm8			V V
66 0F 73 /2 ib u	PSRLQ xmm, imm8			V V
66 0F 71 /4 ib u	PSRAW xmm, imm8			V V
66 0F 72 /4 ib u	PSRAD xmm, imm8			V V
66 0F F1 /r		PSLLW xmm, xmm/m128		V V
66 0F F2 /r		PSLLD xmm, xmm/m128		V V
66 0F F3 /r		PSLLQ xmm, xmm/m128		V V
66 0F D1 /r		PSRLW xmm, xmm/m128		V V
66 0F D2 /r		PSRLD xmm, xmm/m128		V V
66 0F D3 /r		PSRLQ xmm, xmm/m128		V V
66 0F E1 /r		PSRAW xmm, xmm/m128		V V
66 0F E2 /r		PSRAD xmm, xmm/m128		V V

# SSE conversions
0F 5B /r		CVTDQ2PS xmm, xmm/m128		V V
F3 0F 5B /r		CVTTPS2DQ xmm, xmm/m128		V V
0F 5A /r		CVTPS2PD xmm, xmm/m64		V V
66 0F 5A /r		CVTPD2PS xmm, xmm/m128		V V
F3 0F E6 /r		CVTDQ2PD xmm, xmm/m64		V V
66 0F E6 /r		CVTTPD2DQ xmm, xmm/m128		V V

# SSE moves, shuffles, lanes
0F 28 /r		MOVAPS xmm, xmm/m128		V V
0F 29 /r		MOVAPS xmm/m128, xmm		V V
0F 10 /r		MOVUPS xmm, xmm/m128		V V
0F 11 /r		MOVUPS xmm/m128, xmm		V V
66 0F 28 /r		MOVAPD xmm, xmm/m128		V V
66 0F 29 /r		MOVAPD xmm/m128, xmm		V V
66 0F 6F /r		MOVDQA xmm, xmm/m128		V V
66 0F 7F /r		MOVDQA xmm/m128, xmm		V V
F3 0F 6F /r		MOVDQU xmm, xmm/m128		V V
F3 0F 7F /r		MOVDQU xmm/m128, xmm		V V
0F C6 /r ib u		SHUFPS xmm, xmm/m128, imm8	V V
66 0F C6 /r ib u	SHUFPD xmm, xmm/m128, imm8	V V
66 0F 70 /r ib u	PSHUFD xmm, xmm/m128, imm8	V V
0F 14 /r		UNPCKLPS xmm, xmm/m128		V V
0F 15 /r		UNPCKHPS xmm, xmm/m128		V V
66 0F 14 /r		UNPCKLPD xmm, xmm/m128		V V
66 0F 15 /r		UNPCKHPD xmm, xmm/m128		V V
66 0F 3A 22 /r ib u	PINSRD xmm, r/m32, imm8		V V
66 REX.W + 0F 3A 22 /r ib u	PINSRQ xmm, r/m64, imm8		V NE
66 0F 3A 16 /r ib u	PEXTRD r/m32, xmm, imm8		V V
66 REX.W + 0F 3A 16 /r ib u	PEXTRQ r/m64, xmm, imm8		V NE
66 0F 3A 21 /r ib u	INSERTPS xmm, xmm/m32, imm8	V V
66 0F 3A 17 /r ib u	EXTRACTPS r/m32, xmm, imm8	V V
66 0F 3A 0C /r ib u	BLENDPS xmm, xmm/m128, imm8	V V
66 0F 38 14 /r		BLENDVPS xmm, xmm/m128, XMM0	V V
0F 50 /r		MOVMSKPS r32, xmm		V V
