;;; One interface to every instruction set's rows.
;;;
;;;   (asm isa buffer insn)            encode insn at the buffer's end => reports
;;;   (asm-attempt isa buffer insn)    the same, or (error . message) leaving the buffer alone
;;;   (asm-forms isa mnemonic)         => ((kinds row) ...), the forms rows give the mnemonic
;;;   (asm-decode isa bytes pc)        => (insn . length) for a row-described instruction, or ()
;;;   (asm-buffer origin)              a buffer whose first byte will be at address origin
;;;
;;; An instruction is (MNEMONIC operand...).  A report, one per branch-target
;;; operand, is (position offset row): the operand's index, the instruction's
;;; byte offset in the buffer, and the row that encoded it.
;;;
;;; Each instruction set file registers itself with asm-register-isa, giving
;;; its rows (each a list whose first two elements are the mnemonic and the
;;; operand kinds), and two functions:
;;;   (encode row insn pc)   => (bytes . positions) or (); positions are the reported operands
;;;   (decode bytes pc)      => (insn . length) or ()

(define *asm-isas* ())

(define-function asm-register-isa (name rows encode decode)
  (set *asm-isas* (cons (list name rows encode decode) *asm-isas*)))

(define-function asm-isa (isa)
  (or (assq isa *asm-isas*) (error "asm: unknown instruction set " isa)))

(define-function asm-buffer (origin)	(cons origin (array)))
(define-function asm-buffer-origin (b)	(car b))
(define-function asm-buffer-bytes (b)	(cdr b))
(define-function asm-buffer-pc (b)	(+ (car b) (array-length (cdr b))))

(define-function asm-forms (isa mnemonic)
  (let ((out ()))
    (list-do row (cadr (asm-isa isa))
      (and (= mnemonic (car row)) (set out (cons (list (cadr row) row) out))))
    (list-reverse! out)))

(define-function asm-attempt (isa buffer insn)
  (let* ((i (asm-isa isa))
	 (encode (caddr i))
	 (pc (asm-buffer-pc buffer))
	 (rows (cadr i))
	 (row ())
	 (out ()))
    (while (and rows (not out))
      (and (= (car insn) (caar rows)) (set out (encode (car rows) insn pc)) (set row (car rows)))
      (set rows (cdr rows)))
    (if out
	(let ((offset (array-length (asm-buffer-bytes buffer))))
	  (list-do b (car out) (array-append (asm-buffer-bytes buffer) b))
	  (map (lambda (p) (list p offset row)) (cdr out)))
      (cons 'error (list "asm: no " isa " row for " insn "; forms: "
			 (map car (asm-forms isa (car insn))))))))

(define-function asm (isa buffer insn)
  (let ((r (asm-attempt isa buffer insn)))
    (if (and (pair? r) (= 'error (car r)))
	(apply error (cdr r))
      r)))

(define-function asm-decode (isa bytes pc)
  ((cadddr (asm-isa isa)) bytes pc))
