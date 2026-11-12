;;; One interface to every instruction set's rows.
;;;
;;;   (asm isa buffer insn)            encode insn at the buffer's end => reports
;;;   (asm-attempt isa buffer insn)    the same, or (error . message) leaving the buffer alone
;;;   (asm-attempt-scan isa buffer insn)  the same, trying every row of the mnemonic (for checks)
;;;   (asm-forms isa mnemonic)         => ((kinds row) ...), the forms rows give the mnemonic
;;;   (asm-decode isa bytes pc)        => (insn . length) for a row-described instruction, or ()
;;;   (asm-patch isa buffer report v)  fill in a reported operand with its final value
;;;   (asm-patch-attempt ...)          the same, or (error . message) leaving the buffer alone
;;;   (asm-field-range isa row p pc)   => (lo hi step), the values operand p of row can take at pc
;;;   (asm-parse-form isa text)        => (mnemonic kinds) for a form in the ISA's row notation, or ()
;;;   (asm-buffer origin)              a buffer whose first byte will be at address origin
;;;   (asm-candidate-rows isa insn)    the rows that may encode insn, in file order (see below)
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
;;; operand kinds), and four functions:
;;;   (encode row insn pc)          => (bytes . positions) or (); positions are the reported operands
;;;   (decode bytes pc)             => (insn . length) or ()
;;;   (field-range row position pc) => (lo hi step) or ()
;;;   (parse-form text)             => (mnemonic kinds) or ()
;;; and, optionally, the classifier of the candidate table: (shape accepts fixed-width).
;;;
;;; The candidate table.  An operand's shape is what it is, not its value: a
;;; register, a memory operand's form, a number.  (shape op) gives it, or () for
;;; an operand the classifier does not know.  (accepts kind shape) says whether
;;; a row's operand kind may take that shape.  Both are conservative: a kind
;;; whose test depends on the value (does an immediate fit?) accepts every
;;; number, so every row that encodes an instruction is among its candidates.
;;; The candidates for a mnemonic and its shapes are the rows whose kinds all
;;; accept those shapes, in file order, built on first use and kept.  The
;;; shortest (or widest, with an open placeholder) fitting candidate is chosen as
;;; the full scan chooses; when no candidate fits, the full scan runs.  An ISA
;;; whose instructions all have one length takes the first fitting row when
;;; there is no open placeholder: no later row is shorter, or replaces it.

(define *asm-isas* ())

;; Each ISA is (name rows encode decode field-range parse-form by-mnemonic table),
;; by-mnemonic an alist from mnemonic to its rows in file order, and table () or
;; (shape accepts fixed-width cache): cache is a list whose car is an alist from
;; (mnemonic . shapes) to candidate rows.
(define-function asm-register-isa (name rows encode decode field-range parse-form . classifier)
  (let ((by ()))
    (list-do r rows
      (let ((e (assq (car r) by)))
	(if e (set-cdr e (cons r (cdr e))) (set by (cons (list (car r) r) by)))))
    (list-do e by (set-cdr e (list-reverse! (cdr e))))
    (set *asm-isas* (cons (list name rows encode decode field-range parse-form by
				(if classifier (list (car classifier) (cadr classifier) (caddr classifier) (list ())) ()))
			  *asm-isas*))))

(define-function asm-rows-for (i mnemonic)	(cdr (assq mnemonic (car (cdr (cddddr (cdr i)))))))
(define-function asm-isa-table (i)		(cadr (cdr (cddddr (cdr i)))))

(define-function asm-isa (isa)
  (or (assq isa *asm-isas*) (error "asm: unknown instruction set " isa)))

(define-function asm-buffer (origin)	(cons origin (array)))
(define-function asm-buffer-origin (b)	(car b))
(define-function asm-buffer-bytes (b)	(cdr b))
(define-function asm-buffer-pc (b)	(+ (car b) (array-length (cdr b))))

(define-function asm-forms (isa mnemonic)
  (map (lambda (row) (list (cadr row) row)) (asm-rows-for (asm-isa isa) mnemonic)))

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

(define-function asm-field-range (isa row position pc . insn)	; insn: lengths of PC-relative fields
  ((car (cddddr (asm-isa isa))) row position pc (car insn)))

(define-function asm-data (buffer insn)	; (data byte...), bytes 0..255, emitted as given
  (if (list-detect b (cdr insn) (not (and (long? b) (<= 0 b) (<= b 255))))
      (cons 'error (list "asm: data bytes are 0..255: " insn))
    (list-do b (cdr insn) (array-append (asm-buffer-bytes buffer) b))))

(define-function asm-isa-fixed-width? (i)	(let ((table (asm-isa-table i))) (and table (caddr table))))

;; The best fitting row of rows for insn at pc: (row . (bytes . positions)), or ().
;; Of the rows that fit, the shortest (the first among equals), or with an open
;; placeholder the one with the widest field; a row whose field has no range of
;; its own does not take an open placeholder.  A fixed-width ISA with no open
;; placeholder stops at the first fit.
(define-function asm-best-row (isa rows pc insn open)
  (let* ((i (asm-isa isa))
	 (encode (caddr i))
	 (fixed (and (not open) (asm-isa-fixed-width? i)))
	 (size -1)
	 (row ())
	 (out ()))
    (while (and rows (not (and fixed out)))
      (let* ((r (car rows)) (o (encode r insn pc)))
	(when o
	  (let* ((range (and open (asm-field-range isa r open pc insn)))
		 (n (cond ((not open) (- 0 (list-length (car o))))
			  (range (/ (- (cadr range) (car range)) (caddr range))))))
	    (when (and n (or (not out) (< size n))) (set size n) (set out o) (set row r)))))
      (set rows (cdr rows)))
    (and out (cons row out))))

;; The row chosen for insn: from its candidates, else from every row of its mnemonic.
(define-function asm-select (isa insn pc rows)
  (let* ((open (asm-open-placeholder insn))
	 (found (asm-best-row isa rows pc insn open)))
    (if (or found (= rows (asm-rows-for (asm-isa isa) (car insn))))
	found
      (asm-best-row isa (asm-rows-for (asm-isa isa) (car insn)) pc insn open))))

;; Writes the chosen row's bytes at the buffer's end, or the refusal.
(define-function asm-place (isa buffer insn found)
  (if found
      (let ((offset (array-length (asm-buffer-bytes buffer))) (out (cdr found)))
	(list-do b (car out) (array-append (asm-buffer-bytes buffer) b))
	(map (lambda (p) (list p offset (car found) insn)) (cdr out)))
    (cons 'error (list "asm: no " isa " row for " insn "; forms: "
		       (map car (asm-forms isa (car insn)))))))

;;; ---------------------------------------------------------------- candidates

;; Whether every kind of row takes its shape: the counts agree, and each accepts.
(define-function asm-row-accepts? (accepts row shapes)
  (let ((kinds (cadr row)) (ok (= (list-length (cadr row)) (list-length shapes))))
    (list-do k kinds
      (and ok (not (accepts k (car shapes))) (set ok ()))
      (set shapes (cdr shapes)))
    ok))

(define-function asm-build-candidates (i table mnemonic shapes)
  (let ((accepts (cadr table)) (out ()))
    (list-do r (asm-rows-for i mnemonic)
      (and (asm-row-accepts? accepts r shapes) (set out (cons r out))))
    (list-reverse! out)))

;; The cache's bucket for mnemonic is (mnemonic (shapes . rows) ...): found by identity, then by shapes.
(define-function asm-cached-rows (i table mnemonic shapes)
  (let* ((cache (cadddr table))
	 (bucket (or (assq mnemonic (car cache))
		     (let ((b (list mnemonic))) (set-car cache (cons b (car cache))) b)))
	 (hit (list-detect e (cdr bucket) (equal (car e) shapes))))
    (if hit
	(cdr hit)
      (let ((rows (asm-build-candidates i table mnemonic shapes)))
	(set-cdr bucket (cons (cons shapes rows) (cdr bucket)))
	rows))))

;; The shapes of ops under shape, or 'unknown when one has none.
(define-function asm-shapes (shape ops)
  (if (not ops)
      ()
    (let ((s (shape (car ops))) (rest (asm-shapes shape (cdr ops))))
      (if (or (not s) (= 'unknown rest)) 'unknown (cons s rest)))))

;; The rows that may encode insn, in file order: every row of its mnemonic when
;; the ISA has no classifier, or the mnemonic's candidates for its shapes.
(define-function asm-candidate-rows (isa insn)
  (let* ((i (asm-isa isa))
	 (table (asm-isa-table i))
	 (shapes (if table (asm-shapes (car table) (cdr insn)) 'unknown)))
    (if (= 'unknown shapes)
	(asm-rows-for i (car insn))
      (asm-cached-rows i table (car insn) shapes))))

(define-function asm-attempt (isa buffer insn)
  (if (= 'data (car insn))
      (asm-data buffer insn)
    (asm-place isa buffer insn (asm-select isa insn (asm-buffer-pc buffer) (asm-candidate-rows isa insn)))))

(define-function asm-attempt-scan (isa buffer insn)
  (if (= 'data (car insn))
      (asm-data buffer insn)
    (asm-place isa buffer insn (asm-select isa insn (asm-buffer-pc buffer) (asm-rows-for (asm-isa isa) (car insn))))))

(define-function asm (isa buffer insn)
  (let ((r (asm-attempt isa buffer insn)))
    (if (and (pair? r) (= 'error (car r)))
	(apply error (cdr r))
      r)))

(define-function asm-substitute (insn p v)	; insn with value v in operand position p: in its placeholder if it has one.
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
	 	 (encode (caddr (asm-isa isa)))
	 (out (encode (caddr report) insn pc))
	 (was (encode (caddr report) (cadddr report) pc)))
    (if (and out (= (list-length (car out)) (list-length (car was))))	; never a different length
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

(define-function asm-parse-form (isa text)
  ((cadr (cddddr (asm-isa isa))) text))

