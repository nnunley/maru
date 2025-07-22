;;; generate-asm-simple.l -- Simplest possible ARM64 assembly generation

;; Use shell commands to create assembly files
(system "cat > return42.s << 'EOF'
	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 11, 0
	.globl	_main
	.p2align	2
_main:
	mov	w0, #42
	ret
EOF")

(println "Generated return42.s")

(system "cat > add.s << 'EOF'
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
EOF")

(println "Generated add.s")

(println "\nCompiling assembly files...")
(system "clang -o return42 return42.s")
(system "clang -o add add.s")

(println "\nTesting executables:")
(system "./return42 ; echo Return value: $?")
(system "./add ; echo Return value: $?")