# IA-32 instructions, as the Intel SDM vol. 2 opcode tables write them:
# opcode column, then instruction column.  The first row whose operands
# match is the one that encodes, so shorter forms come first.

00 /r		ADD r/m8, r8
01 /r		ADD r/m16, r16
01 /r		ADD r/m32, r32
02 /r		ADD r8, r/m8
03 /r		ADD r16, r/m16
03 /r		ADD r32, r/m32
83 /0 ib	ADD r/m16, imm8
83 /0 ib	ADD r/m32, imm8
04 ib		ADD AL, imm8
05 iw		ADD AX, imm16
05 id		ADD EAX, imm32
80 /0 ib	ADD r/m8, imm8
81 /0 iw	ADD r/m16, imm16
81 /0 id	ADD r/m32, imm32

29 /r		SUB r/m32, r32
2B /r		SUB r32, r/m32
83 /5 ib	SUB r/m32, imm8
2D id		SUB EAX, imm32
81 /5 id	SUB r/m32, imm32

31 /r		XOR r/m32, r32
33 /r		XOR r32, r/m32
83 /6 ib	XOR r/m32, imm8
81 /6 id	XOR r/m32, imm32

39 /r		CMP r/m32, r32
3B /r		CMP r32, r/m32
83 /7 ib	CMP r/m32, imm8
3D id		CMP EAX, imm32
81 /7 id	CMP r/m32, imm32

85 /r		TEST r/m32, r32
F7 /0 id	TEST r/m32, imm32

88 /r		MOV r/m8, r8
89 /r		MOV r/m16, r16
89 /r		MOV r/m32, r32
8A /r		MOV r8, r/m8
8B /r		MOV r32, r/m32
B0+rb ib	MOV r8, imm8
B8+rd id	MOV r32, imm32
C7 /0 id	MOV r/m32, imm32

0F B6 /r	MOVZX r32, r/m8
8D /r		LEA r32, m
0F AF /r	IMUL r32, r/m32
F7 /3		NEG r/m32
F7 /2		NOT r/m32
C1 /4 ib	SHL r/m32, imm8
40+rd		INC r32
48+rd		DEC r32

50+rd		PUSH r32
o32 6A ib	PUSH imm8
o32 68 id	PUSH imm32
FF /6		PUSH r/m32
58+rd		POP r32

EB cb		JMP rel8
E9 cd		JMP rel32
74 cb		JE rel8
75 cb		JNE rel8
0F 84 cd	JE rel32
0F 85 cd	JNE rel32
E8 cd		CALL rel32
FF /2		CALL r/m32
C3		RET
C2 iw		RET imm16
C9		LEAVE
CD ib		INT imm8
E6 ib		OUT imm8, AL
EE		OUT DX, AL
90		NOP
F4		HLT
