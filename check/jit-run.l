;;; Code assembled into a code region and called through the C ABI.
;;;
;;;   ./eval2 -b boot2.l check/jit-run.l ISA
;;;
;;; Integer, float, double and pointer arguments and results; then a
;;; recursive fib that calls write(2) for each letter A..Z through an address
;;; it was given, which must print the alphabet and return fib(25) = 75025.
;;; Forward branches are placeholders patched once their label is placed.
;;; Prints "jit run ISA ok" when everything holds.

(define isa (string->symbol (next-argument)))

(require "osdefs.k")
(require "asm-table.l")
(require "asm-arm64.l")
(require "asm-x86.l")
(require "code-region.l")

(define failures 0)
(define-form expect (form value)
  `(let ((got ,form))
     (or (equal got ,value)
	 (let () (println "FAIL " ',form " => " got ", expected " ,value) (set failures (+ failures 1))))))

(define region (code-region-allocate 65536))

;; Assemble insns at the region's next address, resolving (label NAME) operands
;; and (at NAME) markers; install, and return the callable entry.
(define-function assemble (insns sig)
  (let ((b (asm-buffer (code-region-next region))) (labels ()) (fixups ()))
    (list-do insn insns
      (if (= 'at (car insn))
	  (set labels (cons (cons (cadr insn) (asm-buffer-pc b)) labels))
	(let* ((label (list-detect op (cdr insn) (and (pair? op) (= 'label (car op)))))
	       (reports (asm isa b (if label (map (lambda (op) (if (= op label) '(reloc) op)) insn) insn))))
	  (and label (set fixups (cons (cons (car reports) (cadr label)) fixups))))))
    (list-do f fixups (asm-patch isa b (car f) (cdr (assq (cdr f) labels))))
    (code-callable (code-region-install region b) sig)))

;; The 64-bit address in register r, as MOVZ and three MOVKs.
(define-function load-address (r address)
  (list (list 'MOVZ r (& address 0xffff) '(LSL 0))
	(list 'MOVK r (& (>> address 16) 0xffff) '(LSL 16))
	(list 'MOVK r (& (>> address 32) 0xffff) '(LSL 32))
	(list 'MOVK r (& (>> address 48) 0xffff) '(LSL 48))))

(define dlsym (subr "dlsym" "ps>p"))
(define-function concat-lists lists
  (if lists (concat-list (car lists) (apply concat-lists (cdr lists))) ()))

(when (= isa 'arm64)
  (expect ((assemble '((ADD W0 W0 W1) (RET)) "ii>i") 40 2) 42)
  (expect ((assemble '((FMUL S0 S0 S1) (RET)) "ff>f") 1.5 2.0) 3.0)
  (expect ((assemble '((FMUL D0 D0 D1) (RET)) "dd>d") 1.5 -4.0) -6.0)
  (expect ((assemble '((RET)) "p>p") 0x123456789a) 0x123456789a)
  (expect ((assemble
	    (concat-lists
	     '((STP X29 X30 (pre SP -32))
	       (ADD X29 SP 0)
	       (STP X19 X20 (off SP 16))
	       (MOV W19 W0)
	       (MOVZ W20 65 (LSL 0))
	       (at letter)
	       (STRB W20 (off SP 31))			; the letter, then write(1, &letter, 1)
	       (MOVZ W0 1 (LSL 0))
	       (ADD X1 SP 31)
	       (MOVZ X2 1 (LSL 0)))
	     (load-address 'X16 (dlsym RTLD_DEFAULT "write"))
	     '((BLR X16)
	       (ADD W20 W20 1)
	       (CMP W20 91)
	       (B.LT (label letter))
	       (MOVZ W20 10 (LSL 0))			; and a newline
	       (STRB W20 (off SP 31))
	       (MOVZ W0 1 (LSL 0))
	       (ADD X1 SP 31)
	       (MOVZ X2 1 (LSL 0)))
	     (load-address 'X16 (dlsym RTLD_DEFAULT "write"))
	     '((BLR X16)
	       (MOV W0 W19)
	       (BL (label fib))
	       (LDP X19 X20 (off SP 16))
	       (LDP X29 X30 (post SP 32))
	       (RET)
	       (at fib)					; fib(n): n < 2 ? n : fib(n-1) + fib(n-2)
	       (CMP W0 2)
	       (B.LT (label small))
	       (STP X29 X30 (pre SP -32))
	       (STP X19 X20 (off SP 16))
	       (MOV W19 W0)
	       (SUB W0 W19 1)
	       (BL (label fib))
	       (MOV W20 W0)
	       (SUB W0 W19 2)
	       (BL (label fib))
	       (ADD W0 W0 W20)
	       (LDP X19 X20 (off SP 16))
	       (LDP X29 X30 (post SP 32))
	       (at small)
	       (RET)))
	    "i>i")
	   25)
	  75025))

;; The same on x86-64, System V calling convention: EDI, ESI and XMM0, XMM1 in;
;; EAX or XMM0 out; the stack 16-byte aligned at each call.
(when (= isa 'x64)
  (expect ((assemble '((MOV EAX EDI) (ADD EAX ESI) (RET)) "ii>i") 40 2) 42)
  (expect ((assemble '((MULSS XMM0 XMM1) (RET)) "ff>f") 1.5 2.0) 3.0)
  (expect ((assemble '((MULSD XMM0 XMM1) (RET)) "dd>d") 1.5 -4.0) -6.0)
  (expect ((assemble '((MOV RAX RDI) (RET)) "p>p") 0x123456789a) 0x123456789a)
  (let ((write (dlsym RTLD_DEFAULT "write")))
    (expect ((assemble
	      (concat-lists
	       '((PUSH RBX) (PUSH R12) (PUSH R13)	; return address + 3 pushes: aligned
		 (SUB RSP 16)
		 (MOV EBX EDI)
		 (MOV R12D 65)
		 (at letter)
		 (MOV (m8 0 RSP () 1) R12B)		; the letter, then write(1, &letter, 1)
		 (MOV EDI 1)
		 (MOV RSI RSP)
		 (MOV EDX 1))
	       (list (list 'MOV 'RAX write))
	       '((CALL RAX)
		 (ADD R12D 1)
		 (CMP R12D 91)
		 (JL (label letter))
		 (MOV (m8 0 RSP () 1) 10)		; and a newline
		 (MOV EDI 1)
		 (MOV RSI RSP)
		 (MOV EDX 1))
	       (list (list 'MOV 'RAX write))
	       '((CALL RAX)
		 (MOV EDI EBX)
		 (CALL (label fib))
		 (ADD RSP 16)
		 (POP R13) (POP R12) (POP RBX)
		 (RET)
		 (at fib)				; fib(n): n < 2 ? n : fib(n-1) + fib(n-2)
		 (CMP EDI 2)
		 (JL (label small))
		 (PUSH RBX) (PUSH R12)
		 (MOV EBX EDI)
		 (SUB EDI 1)
		 (CALL (label fib))
		 (MOV R12D EAX)
		 (MOV EDI EBX)
		 (SUB EDI 2)
		 (CALL (label fib))
		 (ADD EAX R12D)
		 (POP R12) (POP RBX)
		 (RET)
		 (at small)
		 (MOV EAX EDI)
		 (RET)))
	      "i>i")
	     25)
	    75025)))

;; Four lanes at once: d[i] += a[i] * b[i] for float arrays.
(when (= isa 'arm64)
  (let ((fmla (assemble '((LD1 (V 0 4S) (off X0 0))
			  (LD1 (V 1 4S) (off X1 0))
			  (LD1 (V 2 4S) (off X2 0))
			  (FMLA (V 0 4S) (V 1 4S) (V 2 4S))
			  (ST1 (V 0 4S) (off X0 0))
			  (RET))
			"ppp>p"))
	(d ((subr "malloc" "l>p") 16)) (a ((subr "malloc" "l>p") 16)) (b ((subr "malloc" "l>p") 16)))
    (for (i 0 4) (set-float-at d i 1.0) (set-float-at a i (+ i 1.0)) (set-float-at b i 0.5))
    (fmla d a b)
    (expect (list (float-at d 0) (float-at d 1) (float-at d 2) (float-at d 3)) '(1.5 2.0 2.5 3.0))))

;; A buffer that runs past the region's end does not fit, and nothing is copied.
(let ((b (asm-buffer (- (+ (car region) (cadr region)) 2))))
  (asm isa b (if (= isa 'arm64) '(RET) '(ADD RAX R12)))	; 4 and 3 bytes: neither fits in 2
  (expect (code-region-fits? region b) ()))

(if (= 0 failures) (println "jit run " isa " ok"))
