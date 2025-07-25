;;; test-mach-o-arm64.l -- ARM64 Mach-O executable generator

(require "buffer.k")

(define code (buffer-new 4096))
(define phased 1)
(define $% 0)
(define $$ 0) 
(define $ 0)

(define-selector _B  (gen value) (buffer-write code value) (incr $))
(define-selector _W  (gen value) (_B gen (& 255 value))   (_B gen (& 255   (>> value 8))))
(define-selector _L  (gen value) (_W gen (& 65535 value)) (_W gen (& 65535 (>> value 16))))
(define-selector _Q  (gen value) (_L gen (& 0xffffffff value)) (_L gen (>> value 32)))

;; Load our ARM64 assembler
(load "arch/arm64/asm-arm64.l")

(define-function define-label (name value)
  (or (= (eval name) value)
      (let ()
        (eval (list 'set name value))
        (set phased 1))))

(define-function .org (addr)        (set $$ (set $ (eval addr))))
(define-form     .equ (name expr)   (define-label name (eval expr)) ())
(define-function .byte bytes        (list-do byte bytes (_B () (eval byte))))
(define-function .long longs        (list-do long longs (_L () (eval long))))
(define-function .quad quads        (list-do quad quads (_Q () (eval quad))))
(define-function .ascii strings     (list-do string strings (string-do char string (_B () char))))
(define-function .align (n)         (while (!= 0 (& (- n 1) $)) (_B () 0)))

(define-function assemble (program)
  (list-do insn program
    (cond
      ((symbol? insn)       (eval (list 'define insn 0)))
      ((= '.equ (car insn)) (eval (list 'define (cadr insn) 0)))))
  (set phased 1)
  (while phased
    (set phased ())
    (buffer-reset code)
    (set $$ (set $ (buffer-address code)))
    (list-do insn program
      (cond
        ((symbol? insn)     (define-label insn $))
        ((pair? insn)       (eval insn))
        (else               (error "unknown instruction: " insn))))))

;; ARM64 Mach-O executable
(assemble '(
    (.org   0x100000000)            ; Default load address for arm64
    
    ; Mach-O header (64-bit)
    (.long  0xfeedfacf)             ; MH_MAGIC_64
    (.long  0x0100000c)             ; CPU_TYPE_ARM64
    (.long  0x00000000)             ; CPU_SUBTYPE_ARM64_ALL
    (.long  2)                      ; MH_EXECUTE
    (.long  3)                      ; ncmds
    (.long  (- cmd_end mach_header_end)) ; sizeofcmds
    (.long  0x00200085)             ; MH_PIE | MH_DYLDLINK | MH_NOUNDEFS | MH_TWOLEVEL
    (.long  0)                      ; reserved
mach_header_end

    ; LC_SEGMENT_64 __PAGEZERO
cmd0 (.long  0x19)                  ; LC_SEGMENT_64
    (.long  72)                     ; cmdsize
    (.ascii "__PAGEZERO")
    (.byte  0 0 0 0 0 0)            ; pad to 16
    (.quad  0)                      ; vmaddr
    (.quad  0x100000000)            ; vmsize
    (.quad  0)                      ; fileoff
    (.quad  0)                      ; filesize  
    (.long  0)                      ; maxprot
    (.long  0)                      ; initprot
    (.long  0)                      ; nsects
    (.long  0)                      ; flags

    ; LC_SEGMENT_64 __TEXT
cmd1 (.long  0x19)                  ; LC_SEGMENT_64
    (.long  152)                    ; cmdsize
    (.ascii "__TEXT")
    (.byte  0 0 0 0 0 0 0 0 0 0)    ; pad to 16
    (.quad  0x100000000)            ; vmaddr
    (.quad  0x4000)                 ; vmsize
    (.quad  0)                      ; fileoff
    (.quad  filesize)               ; filesize
    (.long  7)                      ; maxprot (rwx)
    (.long  5)                      ; initprot (r-x)
    (.long  1)                      ; nsects
    (.long  0)                      ; flags
    
    ; __text section
    (.ascii "__text")               ; sectname
    (.byte  0 0 0 0 0 0 0 0 0 0)    ; pad to 16
    (.ascii "__TEXT")               ; segname
    (.byte  0 0 0 0 0 0 0 0 0 0)    ; pad to 16
    (.quad  start)                  ; addr
    (.quad  (- code_end start))     ; size
    (.long  (- start $$))           ; offset
    (.long  2)                      ; align (2^2 = 4)
    (.long  0)                      ; reloff
    (.long  0)                      ; nreloc
    (.long  0x80000400)             ; S_REGULAR | S_ATTR_PURE_INSTRUCTIONS | S_ATTR_SOME_INSTRUCTIONS
    (.long  0)                      ; reserved1
    (.long  0)                      ; reserved2
    (.long  0)                      ; reserved3

    ; LC_UNIXTHREAD
cmd2 (.long  0x05)                  ; LC_UNIXTHREAD  
    (.long  288)                    ; cmdsize
    (.long  6)                      ; ARM_THREAD_STATE64
    (.long  68)                     ; ARM_THREAD_STATE64_COUNT (272/4)
    ; Thread state: x0-x28 (29 registers)
    (.quad  0 0 0 0 0 0 0 0)       ; x0-x7
    (.quad  0 0 0 0 0 0 0 0)       ; x8-x15
    (.quad  0 0 0 0 0 0 0 0)       ; x16-x23
    (.quad  0 0 0 0 0)              ; x24-x28
    ; fp (x29), lr (x30), sp, pc
    (.quad  0)                      ; fp
    (.quad  0)                      ; lr  
    (.quad  0x100008000)            ; sp (stack)
    (.quad  start)                  ; pc (entry point)
    (.long  0)                      ; cpsr
    (.long  0)                      ; pad
cmd_end

    (.align 4)
start
    ; ARM64 code - write "Hello, ARM64!\n"
    (MOVi   _X0 1 ())               ; stdout = 1
    (ADRr   _X1 msg ())             ; address of message
    (MOVi   _X2 msglen ())          ; length
    (MOVi   _X16 4 ())              ; write syscall
    (SVC    0 ())                   ; system call
    
    ; exit(0)
    (MOVi   _X0 0 ())               ; status = 0
    (MOVi   _X16 1 ())              ; exit syscall
    (SVC    0 ())                   ; system call

msg (.ascii "Hello, ARM64!\n")
    (.equ   msglen (- $ msg))
code_end
    (.equ   filesize (- $ $$))
))

(buffer-save code "a.out")
(println "Generated ARM64 Mach-O executable: a.out")
(println "Size: " (buffer-size code) " bytes")