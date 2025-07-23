	.text
	.align 4
	.globl _return_42
_return_42:
	mov	x0, #42
	ret

	.align 4
	.globl _add_numbers
_add_numbers:
	mov	x0, #10
	mov	x1, #32
	add	x0, x0, x1
	ret

	.align 4
	.globl _main
_main:
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp
	
	bl	_add_numbers
	
	ldp	x29, x30, [sp], #16
	ret