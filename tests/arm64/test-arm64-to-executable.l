;;; test-arm64-to-executable.l -- Generate and compile ARM64 assembly

;; Write assembly to file
(define-function write-arm64-assembly (filename)
  (let ((port (output-stream-open filename)))
    
    ;; macOS ARM64 assembly directives
    (println port "	.section	__TEXT,__text,regular,pure_instructions")
    (println port "	.build_version macos, 11, 0")
    (println port "	.globl	_main")
    (println port "	.p2align	2")
    (println port "_main:")
    
    ;; Function prologue
    (println port "	stp	x29, x30, [sp, #-16]!")
    (println port "	mov	x29, sp")
    
    ;; Return 42
    (println port "	mov	w0, #42")
    
    ;; Function epilogue
    (println port "	ldp	x29, x30, [sp], #16")
    (println port "	ret")
    
    (output-stream-close port)
    (println "Generated: " filename)))

;; Write a more complex example
(define-function write-add-function (filename)
  (let ((port (output-stream-open filename)))
    
    (println port "	.section	__TEXT,__text,regular,pure_instructions")
    (println port "	.build_version macos, 11, 0")
    (println port "")
    
    ;; Add function
    (println port "	.globl	_add")
    (println port "	.p2align	2")
    (println port "_add:")
    (println port "	add	w0, w0, w1")
    (println port "	ret")
    (println port "")
    
    ;; Main function that calls add
    (println port "	.globl	_main")
    (println port "	.p2align	2") 
    (println port "_main:")
    (println port "	stp	x29, x30, [sp, #-16]!")
    (println port "	mov	x29, sp")
    (println port "")
    (println port "	mov	w0, #5")
    (println port "	mov	w1, #7")
    (println port "	bl	_add")
    (println port "")
    (println port "	ldp	x29, x30, [sp], #16")
    (println port "	ret")
    
    (output-stream-close port)
    (println "Generated: " filename)))

;; Generate the assembly files
(println "=== Generating ARM64 Assembly Files ===")
(write-arm64-assembly "return42.s")
(write-add-function "add_example.s")

(println "\n=== To compile these files ===")
(println "clang -o return42 return42.s")
(println "clang -o add_example add_example.s")
(println "\n=== To run ===")
(println "./return42 ; echo $?    # Should print 42")
(println "./add_example ; echo $? # Should print 12")

;; Let's also generate assembly that prints Hello World
(define-function write-hello-world (filename)
  (let ((port (output-stream-open filename)))
    
    (println port "	.section	__TEXT,__text,regular,pure_instructions")
    (println port "	.build_version macos, 11, 0")
    (println port "")
    
    ;; Main function
    (println port "	.globl	_main")
    (println port "	.p2align	2")
    (println port "_main:")
    (println port "	stp	x29, x30, [sp, #-16]!")
    (println port "	mov	x29, sp")
    (println port "")
    
    ;; write(1, message, length)
    (println port "	mov	x0, #1			; stdout")
    (println port "	adrp	x1, message@PAGE")
    (println port "	add	x1, x1, message@PAGEOFF")
    (println port "	mov	x2, #14			; length")
    (println port "	mov	x16, #4			; write syscall")
    (println port "	svc	#0")
    (println port "")
    
    ;; Return 0
    (println port "	mov	w0, #0")
    (println port "	ldp	x29, x30, [sp], #16")
    (println port "	ret")
    (println port "")
    
    ;; Data section
    (println port "	.section	__TEXT,__cstring,cstring_literals")
    (println port "message:")
    (println port "	.asciz	\"Hello, ARM64!\\n\"")
    
    (output-stream-close port)
    (println "Generated: " filename)))

(println "\n=== Generating Hello World ===")
(write-hello-world "hello_arm64.s")
(println "\nclang -o hello_arm64 hello_arm64.s")
(println "./hello_arm64    # Should print: Hello, ARM64!")