;;; One interface to every instruction set's rows.
;;;
;;;   (asm isa buffer insn)            encode insn at the buffer's end => reports
;;;   (asm-attempt isa buffer insn)    the same, or (error . message) leaving the buffer alone
;;;   (asm-forms isa mnemonic)         => ((kinds row) ...), the forms rows give the mnemonic
;;;   (asm-decode isa bytes pc)        => (insn . length) for a row-described instruction, or ()
;;;   (asm-patch isa buffer report v)  fill in a reported operand with its final value
;;;   (asm-patch-attempt ...)          the same, or (error . message) leaving the buffer alone
;;;   (asm-field-range isa row p pc)   => (lo hi step), the values operand p of row can take at pc
;;;   (asm-buffer origin)              a buffer whose first byte will be at address origin
;;;
;;; An instruction is (MNEMONIC operand...).  An operand, or the offset inside
;;; a memory operand, may be a placeholder: (reloc), or (reloc N) for an N-bit
;;; field.  Among the rows a placeholder fits, the one with the widest field is
;;; chosen.  A report, one per placeholder or branch-target operand, is
;;; (position offset row insn): the operand's index, the instruction's byte
;;; offset in the buffer, the row that encoded it, and the instruction.
;;;
;;; Each instruction set file registers itself with asm-register-isa, giving
;;; its rows (each a list whose first two elements are the mnemonic and the
;;; operand kinds), and three functions:
;;;   (encode row insn pc)          => (bytes . positions) or (); positions are the reported operands
;;;   (decode bytes pc)             => (insn . length) or ()
;;;   (field-range row position pc) => (lo hi step) or ()

(define *asm-isas* ())

(define-function asm-register-isa (name rows encode decode field-range)
  (set *asm-isas* (cons (list name rows encode decode field-range) *asm-isas*)))

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

(define-function asm-placeholder-in (op)
  (cond ((not (pair? op))		())
	((= 'reloc (car op))		op)
	(else				(or (asm-placeholder-in (car op)) (asm-placeholder-in (cdr op))))))

;; The index of the first operand holding a placeholder with no width, or ().
(define-function asm-open-placeholder (insn)
  (let ((i 0) (found ()))
    (list-do op (cdr insn)
      (and (not found) (asm-placeholder-in op) (not (cdr (asm-placeholder-in op))) (set found i))
      (set i (+ i 1)))
    found))

(define-function asm-field-range (isa row position pc)
  ((car (cddddr (asm-isa isa))) row position pc))

(define-function asm-attempt (isa buffer insn)
  (let* ((i (asm-isa isa))
	 (encode (caddr i))
	 (pc (asm-buffer-pc buffer))
	 (open (asm-open-placeholder insn))
	 (size -1)
	 (row ())
	 (out ()))
    ;; the first row that fits, or with an open placeholder the widest
    (list-do r (cadr i)
      (and (or open (not out)) (= (car insn) (car r))
	   (let ((o (encode r insn pc)))
	     (when o
	       (let ((n (if open (let ((range (asm-field-range isa r open pc))) (/ (- (cadr range) (car range)) (caddr range))) 0)))
		 (when (< size n) (set size n) (set out o) (set row r)))))))
    (if out
	(let ((offset (array-length (asm-buffer-bytes buffer))))
	  (list-do b (car out) (array-append (asm-buffer-bytes buffer) b))
	  (map (lambda (p) (list p offset row insn)) (cdr out)))
      (cons 'error (list "asm: no " isa " row for " insn "; forms: "
			 (map car (asm-forms isa (car insn))))))))

(define-function asm (isa buffer insn)
  (let ((r (asm-attempt isa buffer insn)))
    (if (and (pair? r) (= 'error (car r)))
	(apply error (cdr r))
      r)))

;; insn with value v in operand position p: in its placeholder if it has one.
(define-function asm-substitute (insn p v)
  (let ((replace (lambda (op) ())))
    (set replace (lambda (op) (cond ((not (pair? op)) op)
				    ((= 'reloc (car op)) v)
				    (else (cons (replace (car op)) (replace (cdr op)))))))
    (let ((i -1))
      (cons (car insn)
	    (map (lambda (op) (set i (+ i 1)) (if (= i p) (if (asm-placeholder-in op) (replace op) v) op))
		 (cdr insn))))))

(define-function asm-patch-attempt (isa buffer report value)
  (let* ((offset (cadr report))
	 (pc (+ (asm-buffer-origin buffer) offset))
	 (insn (asm-substitute (cadddr report) (car report) value))
	 (out ((caddr (asm-isa isa)) (caddr report) insn pc)))
    (if out
	(let ((k offset))
	  (list-do b (car out) (set-array-at (asm-buffer-bytes buffer) k b) (set k (+ k 1)))
	  buffer)
      (cons 'error (list "asm-patch: " value " does not fit operand " (car report) " of " (cadddr report))))))

(define-function asm-patch (isa buffer report value)
  (let ((r (asm-patch-attempt isa buffer report value)))
    (if (and (pair? r) (= 'error (car r)))
	(apply error (cdr r))
      r)))

(define-function asm-decode (isa bytes pc)
  ((cadddr (asm-isa isa)) bytes pc))
