;;; Assemble fib(n) with the table-driven A64 encoder and write it as words in
;;; __TEXT,__text for clang to link beside a C main; disassemble it with the same table.

(define *spike* (next-argument))
(define bytes ())
(define-function _B (X b)	(set bytes (cons b bytes)))
(define-function _PC (X)	(list-length bytes))
(load (concat-string *spike* "/arm64.l"))

(define labels ())
(define-function label (name)	(set labels (cons (cons name (_PC ())) labels)))
(define-function at (name)	(or (cdr (assq name labels)) (_PC ())))	;; unknown on pass 1

(define-function program ()
  (set bytes ())
  (label 'fib)					;; fib(n) = n < 2 ? n : fib(n-1) + fib(n-2)
  (a64 () 'CMP 'X0 2)
  (a64 () 'B.LT (at 'done))
  (a64 () 'STP 'X29 'X30 '(pre SP -32))
  (a64 () 'STP 'X19 'X20 '(off SP 16))
  (a64 () 'MOV 'X19 'X0)
  (a64 () 'SUB 'X0 'X19 1)
  (a64 () 'BL (at 'fib))
  (a64 () 'MOV 'X20 'X0)
  (a64 () 'SUB 'X0 'X19 2)
  (a64 () 'BL (at 'fib))
  (a64 () 'ADD 'X0 'X0 'X20)
  (a64 () 'LDP 'X19 'X20 '(off SP 16))
  (a64 () 'LDP 'X29 'X30 '(post SP 32))
  (label 'done)
  (a64 () 'RET)
  (label 'big)					;; big() = 0x123456789abcdef0, via MOVZ/MOVK
  (a64 () 'MOVZ 'X0 0xdef0 '(LSL 0))
  (a64 () 'MOVK 'X0 0x9abc '(LSL 16))
  (a64 () 'MOVK 'X0 0x5678 '(LSL 32))
  (a64 () 'MOVK 'X0 0x1234 '(LSL 48))
  (a64 () 'RET))

(program)
(program)					;; pass 2: every label is known

(define-function word-at (bs)	(| (car bs) (| (<< (cadr bs) 8) (| (<< (caddr bs) 16) (<< (cadddr bs) 24)))))
(let ((f (open (concat-string *spike* "/afib.s") "w"))
      (bs (list-reverse! bytes))
      (pc 0))
  (list-do s '(".text\n.p2align 2\n.globl _fib\n_fib:\n.globl _big\n_big = _fib + ") (string-do c s (putc c f)))
  (string-do c (long->string (at 'big)) (putc c f))
  (putc ?\n f)
  (while bs
    (let ((w (word-at bs)))
      (println (format "%4d" pc) "\t" (a64-decode w pc))
      (string-do c (format ".long 0x%08x\n" w) (putc c f))
      (set bs (cddddr bs))
      (set pc (+ pc 4))))
  (close f))
