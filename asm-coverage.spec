# The instruction forms each instruction set needs so that every ir2
# operation on every IR type, and its packed counterpart, can be compiled.
#
#   ISA   CLASS   FORM
#
# FORM is written in the ISA's own row notation (the instruction column of
# arm64.spec or x86.spec); CLASS names what it serves.  check/asm-coverage.l
# asserts that every form here has a row.

# ---------------------------------------------------------------- arm64: integer arithmetic

arm64	add.i64		ADD Xd, Xn, Xm
arm64	add.i32		ADD Wd, Wn, Wm
arm64	add.imm64	ADD Xd|SP, Xn|SP, #imm12
arm64	add.imm32	ADD Wd|SP, Wn|SP, #imm12
arm64	sub.i64		SUB Xd, Xn, Xm
arm64	sub.i32		SUB Wd, Wn, Wm
arm64	sub.imm64	SUB Xd|SP, Xn|SP, #imm12
arm64	sub.imm32	SUB Wd|SP, Wn|SP, #imm12
arm64	mul.i64		MUL Xd, Xn, Xm
arm64	mul.i32		MUL Wd, Wn, Wm
arm64	mul.add64	MADD Xd, Xn, Xm, Xa
arm64	mul.add32	MADD Wd, Wn, Wm, Wa
arm64	div.s64		SDIV Xd, Xn, Xm
arm64	div.s32		SDIV Wd, Wn, Wm
arm64	div.u64		UDIV Xd, Xn, Xm
arm64	div.u32		UDIV Wd, Wn, Wm
arm64	mod.64		MSUB Xd, Xn, Xm, Xa
arm64	mod.32		MSUB Wd, Wn, Wm, Wa
arm64	neg.i64		NEG Xd, Xm
arm64	neg.i32		NEG Wd, Wm

# ---------------------------------------------------------------- arm64: bitwise and shifts

arm64	com.64		MVN Xd, Xm
arm64	com.32		MVN Wd, Wm
arm64	bitand.64	AND Xd, Xn, Xm
arm64	bitand.32	AND Wd, Wn, Wm
arm64	bitand.imm64	AND Xd|SP, Xn, #bimm64
arm64	bitand.imm32	AND Wd|SP, Wn, #bimm32
arm64	bitor.64	ORR Xd, Xn, Xm
arm64	bitor.32	ORR Wd, Wn, Wm
arm64	bitor.imm64	ORR Xd|SP, Xn, #bimm64
arm64	bitor.imm32	ORR Wd|SP, Wn, #bimm32
arm64	bitxor.64	EOR Xd, Xn, Xm
arm64	bitxor.32	EOR Wd, Wn, Wm
arm64	bitxor.imm64	EOR Xd|SP, Xn, #bimm64
arm64	bitxor.imm32	EOR Wd|SP, Wn, #bimm32
arm64	shl.64		LSLV Xd, Xn, Xm
arm64	shl.32		LSLV Wd, Wn, Wm
arm64	shr.u64		LSRV Xd, Xn, Xm
arm64	shr.u32		LSRV Wd, Wn, Wm
arm64	shr.s64		ASRV Xd, Xn, Xm
arm64	shr.s32		ASRV Wd, Wn, Wm
arm64	shl.imm64	LSL Xd, Xn, #lslimm64
arm64	shl.imm32	LSL Wd, Wn, #lslimm32
arm64	shr.imm.u64	LSR Xd, Xn, #immr
arm64	shr.imm.u32	LSR Wd, Wn, #immr
arm64	shr.imm.s64	ASR Xd, Xn, #immr
arm64	shr.imm.s32	ASR Wd, Wn, #immr

# ---------------------------------------------------------------- arm64: comparisons

arm64	cmp.64		CMP Xn, Xm
arm64	cmp.32		CMP Wn, Wm
arm64	cmp.imm64	CMP Xn|SP, #imm12
arm64	cmp.imm32	CMP Wn|SP, #imm12
arm64	cmp.value64	CSET Xd, invcond
arm64	cmp.value32	CSET Wd, invcond
arm64	select.64	CSEL Xd, Xn, Xm, cond
arm64	select.32	CSEL Wd, Wn, Wm, cond

# ---------------------------------------------------------------- arm64: casts and constants

arm64	cast.s8.32	SXTB Wd, Wn
arm64	cast.s8.64	SXTB Xd, Wn
arm64	cast.s16.32	SXTH Wd, Wn
arm64	cast.s16.64	SXTH Xd, Wn
arm64	cast.s32.64	SXTW Xd, Wn
arm64	cast.u8		UXTB Wd, Wn
arm64	cast.u16	UXTH Wd, Wn
arm64	move.64		MOV Xd, Xm
arm64	move.32		MOV Wd, Wm
arm64	lit.64		MOVZ Xd, #imm16, LSL #hw*16
arm64	lit.32		MOVZ Wd, #imm16, LSL #hw*16
arm64	lit.keep64	MOVK Xd, #imm16, LSL #hw*16
arm64	lit.keep32	MOVK Wd, #imm16, LSL #hw*16
arm64	lit.neg64	MOVN Xd, #imm16, LSL #hw*16
arm64	lit.neg32	MOVN Wd, #imm16, LSL #hw*16
arm64	addressof	ADR Xd, pc+simmhi:immlo*1
arm64	addressof.page	ADRP Xd, pcpage+simmhi:immlo*4096

# ---------------------------------------------------------------- arm64: loads and stores (indir, member)

arm64	load.64		LDR Xt, [Xn|SP, #imm12*8]
arm64	load.64		LDR Xt, [Xn|SP, #simm9]!
arm64	load.64		LDR Xt, [Xn|SP], #simm9
arm64	load.64		LDR Xt, [Xn|SP, Xm]
arm64	load.64		LDR Xt, [Xn|SP, Xm, LSL #3]
arm64	load.64		LDR Xt, pc+simm19*4
arm64	load.32		LDR Wt, [Xn|SP, #imm12*4]
arm64	load.32		LDR Wt, [Xn|SP, #simm9]!
arm64	load.32		LDR Wt, [Xn|SP], #simm9
arm64	load.32		LDR Wt, [Xn|SP, Xm]
arm64	load.32		LDR Wt, [Xn|SP, Xm, LSL #2]
arm64	load.u16	LDRH Wt, [Xn|SP, #imm12*2]
arm64	load.u16	LDRH Wt, [Xn|SP, Xm]
arm64	load.u8		LDRB Wt, [Xn|SP, #imm12]
arm64	load.u8		LDRB Wt, [Xn|SP, Xm]
arm64	load.s32	LDRSW Xt, [Xn|SP, #imm12*4]
arm64	load.s32	LDRSW Xt, [Xn|SP, Xm]
arm64	load.s16	LDRSH Xt, [Xn|SP, #imm12*2]
arm64	load.s16	LDRSH Wt, [Xn|SP, #imm12*2]
arm64	load.s8		LDRSB Xt, [Xn|SP, #imm12]
arm64	load.s8		LDRSB Wt, [Xn|SP, #imm12]
arm64	store.64	STR Xt, [Xn|SP, #imm12*8]
arm64	store.64	STR Xt, [Xn|SP, #simm9]!
arm64	store.64	STR Xt, [Xn|SP], #simm9
arm64	store.64	STR Xt, [Xn|SP, Xm]
arm64	store.64	STR Xt, [Xn|SP, Xm, LSL #3]
arm64	store.32	STR Wt, [Xn|SP, #imm12*4]
arm64	store.32	STR Wt, [Xn|SP, Xm]
arm64	store.16	STRH Wt, [Xn|SP, #imm12*2]
arm64	store.8		STRB Wt, [Xn|SP, #imm12]
arm64	store.pair	STP Xt, Xt2, [Xn|SP, #simm7*8]
arm64	store.pair	STP Xt, Xt2, [Xn|SP, #simm7*8]!
arm64	load.pair	LDP Xt, Xt2, [Xn|SP, #simm7*8]
arm64	load.pair	LDP Xt, Xt2, [Xn|SP], #simm7*8

# ---------------------------------------------------------------- arm64: control (if, while, call, return)

arm64	branch		B pc+simm26*4
arm64	branch.cond	B.EQ pc+simm19*4
arm64	branch.cond	B.NE pc+simm19*4
arm64	branch.cond	B.LT pc+simm19*4
arm64	branch.cond	B.LE pc+simm19*4
arm64	branch.cond	B.GT pc+simm19*4
arm64	branch.cond	B.GE pc+simm19*4
arm64	branch.cond	B.LO pc+simm19*4
arm64	branch.cond	B.LS pc+simm19*4
arm64	branch.cond	B.HI pc+simm19*4
arm64	branch.cond	B.HS pc+simm19*4
arm64	branch.zero	CBZ Xt, pc+simm19*4
arm64	branch.zero	CBZ Wt, pc+simm19*4
arm64	branch.zero	CBNZ Xt, pc+simm19*4
arm64	branch.zero	CBNZ Wt, pc+simm19*4
arm64	call		BL pc+simm26*4
arm64	call.indirect	BLR Xn
arm64	jump.indirect	BR Xn
arm64	return		RET
arm64	return		RET Xn

# ---------------------------------------------------------------- arm64: floating point (float, double)

arm64	add.f32		FADD Sd, Sn, Sm
arm64	add.f64		FADD Dd, Dn, Dm
arm64	sub.f32		FSUB Sd, Sn, Sm
arm64	sub.f64		FSUB Dd, Dn, Dm
arm64	mul.f32		FMUL Sd, Sn, Sm
arm64	mul.f64		FMUL Dd, Dn, Dm
arm64	div.f32		FDIV Sd, Sn, Sm
arm64	div.f64		FDIV Dd, Dn, Dm
arm64	neg.f32		FNEG Sd, Sn
arm64	neg.f64		FNEG Dd, Dn
arm64	abs.f32		FABS Sd, Sn
arm64	abs.f64		FABS Dd, Dn
arm64	sqrt.f32	FSQRT Sd, Sn
arm64	sqrt.f64	FSQRT Dd, Dn
arm64	min.f32		FMIN Sd, Sn, Sm
arm64	min.f64		FMIN Dd, Dn, Dm
arm64	max.f32		FMAX Sd, Sn, Sm
arm64	max.f64		FMAX Dd, Dn, Dm
arm64	cmp.f32		FCMP Sn, Sm
arm64	cmp.f64		FCMP Dn, Dm
arm64	select.f32	FCSEL Sd, Sn, Sm, cond
arm64	select.f64	FCSEL Dd, Dn, Dm, cond
arm64	move.f32	FMOV Sd, Sn
arm64	move.f64	FMOV Dd, Dn
arm64	move.f32.i32	FMOV Wd, Sn
arm64	move.i32.f32	FMOV Sd, Wn
arm64	move.f64.i64	FMOV Xd, Dn
arm64	move.i64.f64	FMOV Dd, Xn
arm64	lit.f32		FMOV Sd, #fimm8
arm64	lit.f64		FMOV Dd, #fimm8
arm64	cast.s32.f32	SCVTF Sd, Wn
arm64	cast.s64.f32	SCVTF Sd, Xn
arm64	cast.s32.f64	SCVTF Dd, Wn
arm64	cast.s64.f64	SCVTF Dd, Xn
arm64	cast.u32.f32	UCVTF Sd, Wn
arm64	cast.u64.f64	UCVTF Dd, Xn
arm64	cast.f32.s32	FCVTZS Wd, Sn
arm64	cast.f32.s64	FCVTZS Xd, Sn
arm64	cast.f64.s32	FCVTZS Wd, Dn
arm64	cast.f64.s64	FCVTZS Xd, Dn
arm64	cast.f32.u32	FCVTZU Wd, Sn
arm64	cast.f64.u64	FCVTZU Xd, Dn
arm64	cast.f32.f64	FCVT Dd, Sn
arm64	cast.f64.f32	FCVT Sd, Dn
arm64	load.f32	LDR St, [Xn|SP, #imm12*4]
arm64	load.f32	LDR St, [Xn|SP, Xm, LSL #2]
arm64	load.f64	LDR Dt, [Xn|SP, #imm12*8]
arm64	load.f64	LDR Dt, [Xn|SP, Xm, LSL #3]
arm64	store.f32	STR St, [Xn|SP, #imm12*4]
arm64	store.f64	STR Dt, [Xn|SP, #imm12*8]
arm64	store.pair.f64	STP Dt, Dt2, [Xn|SP, #simm7*8]
arm64	load.pair.f64	LDP Dt, Dt2, [Xn|SP, #simm7*8]
