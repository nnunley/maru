# The instruction forms each instruction set needs so that every ir2
# operation on every IR type, and its packed counterpart, can be compiled.
#
#   ISA   CLASS   FORM
#
# FORM is written in the ISA's own row notation (the instruction column of
# arm64.spec or x86.spec).  CLASSES, comma-separated, name the ir2 operations
# and types it serves: OP.TYPE, or cast.FROM.TO, where a type is s8 u8 s16 u16
# s32 u32 s64 u64 f32 f64 or a group: i32 (any value held in a 32-bit
# register), i64 (s64 u64), s32 (s8 s16 s32), u32 (u8 u16 u32).
# check/asm-coverage.l asserts that every form has a row, and that every
# operation ir2.k declares, on every type it allows, is named by some class.

# ---------------------------------------------------------------- arm64: integer arithmetic

arm64	add.i64	ADD Xd, Xn, Xm
arm64	add.i32	ADD Wd, Wn, Wm
arm64	add.i64	ADD Xd|SP, Xn|SP, #imm12
arm64	add.i32	ADD Wd|SP, Wn|SP, #imm12
arm64	sub.i64	SUB Xd, Xn, Xm
arm64	sub.i32	SUB Wd, Wn, Wm
arm64	sub.i64	SUB Xd|SP, Xn|SP, #imm12
arm64	sub.i32	SUB Wd|SP, Wn|SP, #imm12
arm64	mul.i64	MUL Xd, Xn, Xm
arm64	mul.i32	MUL Wd, Wn, Wm
arm64	mul.i64	MADD Xd, Xn, Xm, Xa
arm64	mul.i32	MADD Wd, Wn, Wm, Wa
arm64	div.s64,mod.s64	SDIV Xd, Xn, Xm
arm64	div.s32,mod.s32	SDIV Wd, Wn, Wm
arm64	div.u64,mod.u64	UDIV Xd, Xn, Xm
arm64	div.u32,mod.u32	UDIV Wd, Wn, Wm
arm64	mod.i64	MSUB Xd, Xn, Xm, Xa
arm64	mod.i32	MSUB Wd, Wn, Wm, Wa
arm64	neg.i64	NEG Xd, Xm
arm64	neg.i32	NEG Wd, Wm

# ---------------------------------------------------------------- arm64: bitwise and shifts

arm64	com.i64	MVN Xd, Xm
arm64	com.i32	MVN Wd, Wm
arm64	bitand.i64	AND Xd, Xn, Xm
arm64	bitand.i32	AND Wd, Wn, Wm
arm64	bitand.i64	AND Xd|SP, Xn, #bimm64
arm64	bitand.i32	AND Wd|SP, Wn, #bimm32
arm64	bitor.i64	ORR Xd, Xn, Xm
arm64	bitor.i32	ORR Wd, Wn, Wm
arm64	bitor.i64	ORR Xd|SP, Xn, #bimm64
arm64	bitor.i32	ORR Wd|SP, Wn, #bimm32
arm64	bitxor.i64	EOR Xd, Xn, Xm
arm64	bitxor.i32	EOR Wd, Wn, Wm
arm64	bitxor.i64	EOR Xd|SP, Xn, #bimm64
arm64	bitxor.i32	EOR Wd|SP, Wn, #bimm32
arm64	shl.i64	LSLV Xd, Xn, Xm
arm64	shl.i32	LSLV Wd, Wn, Wm
arm64	shr.u64	LSRV Xd, Xn, Xm
arm64	shr.u32	LSRV Wd, Wn, Wm
arm64	shr.s64	ASRV Xd, Xn, Xm
arm64	shr.s32	ASRV Wd, Wn, Wm
arm64	shl.i64	LSL Xd, Xn, #lslimm64
arm64	shl.i32	LSL Wd, Wn, #lslimm32
arm64	shr.u64	LSR Xd, Xn, #immr
arm64	shr.u32	LSR Wd, Wn, #immr
arm64	shr.s64	ASR Xd, Xn, #immr
arm64	shr.s32	ASR Wd, Wn, #immr

# ---------------------------------------------------------------- arm64: comparisons

arm64	eq.i64,ne.i64,lt.i64,le.i64,ge.i64,gt.i64	CMP Xn, Xm
arm64	eq.i32,ne.i32,lt.i32,le.i32,ge.i32,gt.i32	CMP Wn, Wm
arm64	eq.i64,ne.i64,lt.i64,le.i64,ge.i64,gt.i64,not.i64	CMP Xn|SP, #imm12
arm64	eq.i32,ne.i32,lt.i32,le.i32,ge.i32,gt.i32,not.i32	CMP Wn|SP, #imm12
arm64	eq.i64,ne.i64,lt.i64,le.i64,ge.i64,gt.i64,not.i64	CSET Xd, invcond
arm64	eq.i32,ne.i32,lt.i32,le.i32,ge.i32,gt.i32,not.i32	CSET Wd, invcond
arm64	select.i64	CSEL Xd, Xn, Xm, cond
arm64	select.i32	CSEL Wd, Wn, Wm, cond

# ---------------------------------------------------------------- arm64: casts and constants

arm64	cast.s8.s32	SXTB Wd, Wn
arm64	cast.s8.s64	SXTB Xd, Wn
arm64	cast.s16.s32	SXTH Wd, Wn
arm64	cast.s16.s64	SXTH Xd, Wn
arm64	cast.s32.s64	SXTW Xd, Wn
arm64	cast.u8.u32,cast.u8.u64	UXTB Wd, Wn
arm64	cast.u16.u32,cast.u16.u64	UXTH Wd, Wn
arm64	move.i64	MOV Xd, Xm
arm64	move.i32,cast.u32.u64	MOV Wd, Wm
arm64	lit.i64	MOVZ Xd, #imm16, LSL #hw*16
arm64	lit.i32	MOVZ Wd, #imm16, LSL #hw*16
arm64	lit.i64	MOVK Xd, #imm16, LSL #hw*16
arm64	lit.i32	MOVK Wd, #imm16, LSL #hw*16
arm64	lit.i64	MOVN Xd, #imm16, LSL #hw*16
arm64	lit.i32	MOVN Wd, #imm16, LSL #hw*16
arm64	addressof	ADR Xd, pc+simmhi:immlo*1
arm64	addressof	ADRP Xd, pcpage+simmhi:immlo*4096

# ---------------------------------------------------------------- arm64: loads and stores (indir, member)

arm64	load.i64	LDR Xt, [Xn|SP, #imm12*8]
arm64	load.i64	LDR Xt, [Xn|SP, #simm9]!
arm64	load.i64	LDR Xt, [Xn|SP], #simm9
arm64	load.i64	LDR Xt, [Xn|SP, Xm]
arm64	load.i64	LDR Xt, [Xn|SP, Xm, LSL #3]
arm64	load.i64	LDR Xt, pc+simm19*4
arm64	load.s32,load.u32	LDR Wt, [Xn|SP, #imm12*4]
arm64	load.s32,load.u32	LDR Wt, [Xn|SP, #simm9]!
arm64	load.s32,load.u32	LDR Wt, [Xn|SP], #simm9
arm64	load.s32,load.u32	LDR Wt, [Xn|SP, Xm]
arm64	load.s32,load.u32	LDR Wt, [Xn|SP, Xm, LSL #2]
arm64	load.u16	LDRH Wt, [Xn|SP, #imm12*2]
arm64	load.u16	LDRH Wt, [Xn|SP, Xm]
arm64	load.u8	LDRB Wt, [Xn|SP, #imm12]
arm64	load.u8	LDRB Wt, [Xn|SP, Xm]
arm64	load.s32,cast.s32.s64	LDRSW Xt, [Xn|SP, #imm12*4]
arm64	load.s32,cast.s32.s64	LDRSW Xt, [Xn|SP, Xm]
arm64	load.s16	LDRSH Xt, [Xn|SP, #imm12*2]
arm64	load.s16	LDRSH Wt, [Xn|SP, #imm12*2]
arm64	load.s8	LDRSB Xt, [Xn|SP, #imm12]
arm64	load.s8	LDRSB Wt, [Xn|SP, #imm12]
arm64	store.i64	STR Xt, [Xn|SP, #imm12*8]
arm64	store.i64	STR Xt, [Xn|SP, #simm9]!
arm64	store.i64	STR Xt, [Xn|SP], #simm9
arm64	store.i64	STR Xt, [Xn|SP, Xm]
arm64	store.i64	STR Xt, [Xn|SP, Xm, LSL #3]
arm64	store.s32,store.u32	STR Wt, [Xn|SP, #imm12*4]
arm64	store.s32,store.u32	STR Wt, [Xn|SP, Xm]
arm64	store.s16,store.u16	STRH Wt, [Xn|SP, #imm12*2]
arm64	store.s8,store.u8	STRB Wt, [Xn|SP, #imm12]
arm64	store.pair	STP Xt, Xt2, [Xn|SP, #simm7*8]
arm64	store.pair	STP Xt, Xt2, [Xn|SP, #simm7*8]!
arm64	load.pair	LDP Xt, Xt2, [Xn|SP, #simm7*8]
arm64	load.pair	LDP Xt, Xt2, [Xn|SP], #simm7*8

# ---------------------------------------------------------------- arm64: control (if, while, call, return)

arm64	branch	B pc+simm26*4
arm64	branch	B.EQ pc+simm19*4
arm64	branch	B.NE pc+simm19*4
arm64	branch	B.LT pc+simm19*4
arm64	branch	B.LE pc+simm19*4
arm64	branch	B.GT pc+simm19*4
arm64	branch	B.GE pc+simm19*4
arm64	branch	B.LO pc+simm19*4
arm64	branch	B.LS pc+simm19*4
arm64	branch	B.HI pc+simm19*4
arm64	branch	B.HS pc+simm19*4
arm64	branch,eq.i64	CBZ Xt, pc+simm19*4
arm64	branch,eq.i32	CBZ Wt, pc+simm19*4
arm64	branch,ne.i64	CBNZ Xt, pc+simm19*4
arm64	branch,ne.i32	CBNZ Wt, pc+simm19*4
arm64	call,mod.f32,mod.f64	BL pc+simm26*4
arm64	call.indirect	BLR Xn
arm64	branch	BR Xn
arm64	return	RET
arm64	return	RET Xn

# ---------------------------------------------------------------- arm64: floating point (float, double)

arm64	add.f32	FADD Sd, Sn, Sm
arm64	add.f64	FADD Dd, Dn, Dm
arm64	sub.f32	FSUB Sd, Sn, Sm
arm64	sub.f64	FSUB Dd, Dn, Dm
arm64	mul.f32	FMUL Sd, Sn, Sm
arm64	mul.f64	FMUL Dd, Dn, Dm
arm64	div.f32	FDIV Sd, Sn, Sm
arm64	div.f64	FDIV Dd, Dn, Dm
arm64	neg.f32	FNEG Sd, Sn
arm64	neg.f64	FNEG Dd, Dn
arm64	abs.f32	FABS Sd, Sn
arm64	abs.f64	FABS Dd, Dn
arm64	sqrt.f32	FSQRT Sd, Sn
arm64	sqrt.f64	FSQRT Dd, Dn
arm64	min.f32	FMIN Sd, Sn, Sm
arm64	min.f64	FMIN Dd, Dn, Dm
arm64	max.f32	FMAX Sd, Sn, Sm
arm64	max.f64	FMAX Dd, Dn, Dm
arm64	eq.f32,ne.f32,lt.f32,le.f32,ge.f32,gt.f32	FCMP Sn, Sm
arm64	eq.f64,ne.f64,lt.f64,le.f64,ge.f64,gt.f64	FCMP Dn, Dm
arm64	select.f32	FCSEL Sd, Sn, Sm, cond
arm64	select.f64	FCSEL Dd, Dn, Dm, cond
arm64	move.f32	FMOV Sd, Sn
arm64	move.f64	FMOV Dd, Dn
arm64	move.f32.i32	FMOV Wd, Sn
arm64	move.i32.f32	FMOV Sd, Wn
arm64	move.f64.i64	FMOV Xd, Dn
arm64	move.i64.f64	FMOV Dd, Xn
arm64	lit.f32	FMOV Sd, #fimm8
arm64	lit.f64	FMOV Dd, #fimm8
arm64	cast.s32.f32	SCVTF Sd, Wn
arm64	cast.s64.f32	SCVTF Sd, Xn
arm64	cast.s32.f64	SCVTF Dd, Wn
arm64	cast.s64.f64	SCVTF Dd, Xn
arm64	cast.u32.f32	UCVTF Sd, Wn
arm64	cast.u64.f32	UCVTF Sd, Xn
arm64	cast.u32.f64	UCVTF Dd, Wn
arm64	cast.u64.f64	UCVTF Dd, Xn
arm64	cast.f32.s32	FCVTZS Wd, Sn
arm64	cast.f32.s64	FCVTZS Xd, Sn
arm64	cast.f64.s32	FCVTZS Wd, Dn
arm64	cast.f64.s64	FCVTZS Xd, Dn
arm64	cast.f32.u32	FCVTZU Wd, Sn
arm64	cast.f32.u64	FCVTZU Xd, Sn
arm64	cast.f64.u32	FCVTZU Wd, Dn
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

# ---------------------------------------------------------------- arm64: Advanced SIMD (NEON)
# Classes vOP.TYPE are the packed counterparts of ir2's operations.

arm64	vadd.int		ADD Vd.T, Vn.T, Vm.T
arm64	vsub.int		SUB Vd.T, Vn.T, Vm.T
arm64	vmul.int		MUL Vd.T, Vn.T, Vm.T
arm64	vneg.int		NEG Vd.T, Vn.T
arm64	vbitand			AND Vd.T, Vn.T, Vm.T
arm64	vbitor			ORR Vd.T, Vn.T, Vm.T
arm64	vbitxor			EOR Vd.T, Vn.T, Vm.T
arm64	vbitandnot		BIC Vd.T, Vn.T, Vm.T
arm64	vcom			NOT Vd.T, Vn.T
arm64	vshl.int		SSHL Vd.T, Vn.T, Vm.T
arm64	vshl.int		USHL Vd.T, Vn.T, Vm.T
arm64	vshl.imm		SHL Vd.T, Vn.T, #vshl
arm64	vshr.imm.s		SSHR Vd.T, Vn.T, #vshr
arm64	vshr.imm.u		USHR Vd.T, Vn.T, #vshr
arm64	veq.int			CMEQ Vd.T, Vn.T, Vm.T
arm64	vgt.s			CMGT Vd.T, Vn.T, Vm.T
arm64	vge.s			CMGE Vd.T, Vn.T, Vm.T
arm64	vgt.u			CMHI Vd.T, Vn.T, Vm.T
arm64	vge.u			CMHS Vd.T, Vn.T, Vm.T
arm64	vmin.s			SMIN Vd.T, Vn.T, Vm.T
arm64	vmax.s			SMAX Vd.T, Vn.T, Vm.T
arm64	vmin.u			UMIN Vd.T, Vn.T, Vm.T
arm64	vmax.u			UMAX Vd.T, Vn.T, Vm.T
arm64	vadd.float		FADD Vd.T, Vn.T, Vm.T
arm64	vsub.float		FSUB Vd.T, Vn.T, Vm.T
arm64	vmul.float		FMUL Vd.T, Vn.T, Vm.T
arm64	vdiv.float		FDIV Vd.T, Vn.T, Vm.T
arm64	vfma.float		FMLA Vd.T, Vn.T, Vm.T
arm64	vmin.float		FMIN Vd.T, Vn.T, Vm.T
arm64	vmax.float		FMAX Vd.T, Vn.T, Vm.T
arm64	vneg.float		FNEG Vd.T, Vn.T
arm64	vabs.float		FABS Vd.T, Vn.T
arm64	vsqrt.float		FSQRT Vd.T, Vn.T
arm64	veq.float		FCMEQ Vd.T, Vn.T, Vm.T
arm64	vgt.float		FCMGT Vd.T, Vn.T, Vm.T
arm64	vge.float		FCMGE Vd.T, Vn.T, Vm.T
arm64	vcast.s.float		SCVTF Vd.T, Vn.T
arm64	vcast.u.float		UCVTF Vd.T, Vn.T
arm64	vcast.float.s		FCVTZS Vd.T, Vn.T
arm64	vcast.float.u		FCVTZU Vd.T, Vn.T
arm64	vbroadcast		DUP Vd.T, Wn
arm64	vbroadcast		DUP Vd.T, Xn
arm64	vbroadcast		DUP Vd.T, Vn.S[#index]
arm64	vbroadcast		DUP Vd.T, Vn.D[#index]
arm64	vinsert			INS Vd.B[#index], Wn
arm64	vinsert			INS Vd.H[#index], Wn
arm64	vinsert			INS Vd.S[#index], Wn
arm64	vinsert			INS Vd.D[#index], Xn
arm64	vextract		UMOV Wd, Vn.B[#index]
arm64	vextract		UMOV Wd, Vn.H[#index]
arm64	vextract		UMOV Wd, Vn.S[#index]
arm64	vextract		UMOV Xd, Vn.D[#index]
arm64	vextract.s		SMOV Xd, Vn.B[#index]
arm64	vextract.s		SMOV Xd, Vn.H[#index]
arm64	vextract.s		SMOV Xd, Vn.S[#index]
arm64	vshuffle		EXT Vd.T, Vn.T, Vm.T, #imm4
arm64	vshuffle		ZIP1 Vd.T, Vn.T, Vm.T
arm64	vshuffle		ZIP2 Vd.T, Vn.T, Vm.T
arm64	vshuffle		UZP1 Vd.T, Vn.T, Vm.T
arm64	vshuffle		UZP2 Vd.T, Vn.T, Vm.T
arm64	vshuffle		TRN1 Vd.T, Vn.T, Vm.T
arm64	vshuffle		TRN2 Vd.T, Vn.T, Vm.T
arm64	vpermute		TBL Vd.T, {Vn.16B}, Vm.T
arm64	vreduce.add		ADDV Bd, Vn.T
arm64	vreduce.add		ADDV Hd, Vn.T
arm64	vreduce.add		ADDV Sd, Vn.4S
arm64	vreduce.add.float	FADDP Vd.T, Vn.T, Vm.T
arm64	vreduce.max.float	FMAXV Sd, Vn.4S
arm64	vreduce.min.float	FMINV Sd, Vn.4S
arm64	vload			LD1 {Vt.T}, [Xn|SP]
arm64	vstore			ST1 {Vt.T}, [Xn|SP]
arm64	vload			LDR Qt, [Xn|SP, #imm12*16]
arm64	vstore			STR Qt, [Xn|SP, #imm12*16]
