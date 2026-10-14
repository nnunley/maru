;;; The generated x86 assembler (asm-x86.k) must encode as clang -target i386 does.

(define bytes ())
(define-function _B (X b) (set bytes (cons (& b 255) bytes)))
(define-function _W (X w) (_B X w) (_B X (>> w 8)))
(define-function _L (X l) (_W X l) (_W X (>> l 16)))
(define-function _D1 (X d) (_B X (- d (+ (list-length bytes) 1))))
(define-function _D4 (X d) (_L X (- d (+ (list-length bytes) 4))))
(load "asm-x86.k")

(MOVLir () 42 _EAX)  (ADDLrr () _ECX _EDX)  (PUSHLr () _EBX)  (MOVLmr () 8 _EBP _ESI 4 _EDI)
(INTi () 0x80)  (ADDLir () 1000 _ESP)  (CALLm () 0 0 0 0)  (RET ())
(MOVLmr () 0 _EBP 0 0 _EAX)  (MOVLmr () 0 _EBP _ESI 4 _EDI)	;; EBP base needs a disp8 even when 0
(list-do b (list-reverse! bytes) (print (format "%02x " b)))
