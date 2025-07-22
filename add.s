	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 11, 0
	.globl	_add
	.p2align	2
_add:
	add	w0, w0, w1
	ret

	.globl	_main
	.p2align	2
_main:
	mov	w0, #5
	mov	w1, #7
	bl	_add
	ret
