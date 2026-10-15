;;; Assemble a program with the table-driven x86 encoder into a multiboot image
;;; (a.out kludge: no ELF, no linker) for qemu-system-i386 -kernel.
;;; It writes A..Z to COM1 via a called function, then exits through isa-debug-exit.

(define *spike* (next-argument))
(define bytes ())
(define origin 0x100000)
(define-function _B (X b)	(set bytes (cons (& b 255) bytes)))
(define-function _PC (X)	(+ origin (list-length bytes)))
(load (concat-string *spike* "/x86.l"))

(define labels ())
(define-function label (name)	(set labels (cons (cons name (_PC ())) labels)))
(define-function at (name)	(or (cdr (assq name labels)) (_PC ())))	;; unknown on pass 1

(define-function program ()
  (set bytes ())
  ;; multiboot header: magic, flags (a.out kludge), checksum, header/load/end/bss/entry
  (list-do w (list 0x1BADB002 0x10000 (- 0 (+ 0x1BADB002 0x10000)) origin origin 0 0 (at 'main))
    (list-do b (le w 4) (_B () b)))
  (label 'putc)					;; putc(c): c at [ESP+4] -> COM1
  (x86 () 'MOV 'EAX '(m32 4 ESP () 1))
  (x86 () 'MOV 'EDX 0x3F8)
  (x86 () 'OUT 'DX 'AL)
  (x86 () 'RET)
  (label 'main)
  (x86 () 'MOV 'ESP 0x90000)
  (x86 () 'MOV 'EBX 0x41)
  (label 'loop)
  (x86 () 'PUSH 'EBX)
  (x86 () 'CALL (at 'putc))
  (x86 () 'ADD 'ESP 4)
  (x86 () 'INC 'EBX)
  (x86 () 'CMP 'EBX 0x5B)
  (x86 () 'JNE (at 'loop))
  (x86 () 'PUSH 10)
  (x86 () 'CALL (at 'putc))
  (x86 () 'POP 'EAX)
  (x86 () 'CMP 'EAX 10)
  (x86 () 'JE (at 'ok))				;; forward: resolved on pass 2
  (x86 () 'MOV 'AL 0x7F)
  (x86 () 'OUT 0xF4 'AL)
  (label 'ok)
  (x86 () 'MOV 'AL 0x21)			;; qemu exits with (0x21 << 1) | 1 = 67
  (x86 () 'OUT 0xF4 'AL)
  (x86 () 'HLT))

(program)
(program)					;; pass 2: every label is known

(define image (list-reverse! bytes))
(let ((f (open (concat-string *spike* "/kernel.bin") "w" -1)))
  (list-do b image (putb b f))
  (close f))
(let ((p (+ origin 32)) (bs (list-tail image 32)))	;; disassemble with the same table
  (while bs
    (let ((r (x86-decode bs p)))
      (println (format "%x" p) "\t" (car r))
      (set p (+ p (- (list-length bs) (list-length (cdr r)))))
      (set bs (cdr r)))))
