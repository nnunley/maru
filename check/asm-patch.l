;;; Placeholders and patching.
;;;
;;;   ./eval check/asm-patch.l ISA
;;;
;;; For every row operand a placeholder can stand for, encode with (reloc) in
;;; its place, then asm-patch it with the field's lowest, highest and a middle
;;; value: the bytes must equal what the same row encodes for that value
;;; directly.  (A patch never changes an instruction's length, so a shorter row
;;; the value would otherwise choose is not the comparison.)
;;; One step past either end, and a value off the field's scale, must be
;;; refused, leaving the buffer as it was.  Prints "asm patch ISA ok".

(define isa (string->symbol (next-argument)))

(require "asm-table.l")
(require "asm-arm64.l")
(require "asm-x86.l")
(load "check/asm-samples.l")
(set x86-sample-mode isa)

(define failures 0)
(define cases 0)
(define-function fail args (apply println (cons "FAIL " args)) (set failures (+ failures 1)))

(define-function nth (l i)		(while (< 0 i) (set l (cdr l)) (set i (- i 1))) (car l))
(define-function with (l i v)		(if (= 0 i) (cons v (cdr l)) (cons (car l) (with (cdr l) (- i 1) v))))

(define-function copy-buffer (b)
  (let ((c (asm-buffer (asm-buffer-origin b))) (bytes (asm-buffer-bytes b)))
    (for (i 0 (array-length bytes)) (array-append (asm-buffer-bytes c) (array-at bytes i)))
    c))

(define-function same-bytes? (a b)	(equal (array->list (asm-buffer-bytes a)) (array->list (asm-buffer-bytes b))))

;; An operand holding a placeholder where kind k has a patchable field, or ():
;; immediates and branch targets, and on x64 a RIP-relative memory operand.
(define-function x86-placeholder (k sample)
  (let ((c (x86-kind k)))
    (cond ((memq (car c) '(imm rel))					'(reloc))
	  ((and (= isa 'x64) (memq (car c) '(rm xm mem)))		(list (x86-mem-tag (cadr c)) '(reloc) 'RIP () 1))
	  ((and (= isa 'x64) (= 'm (car c)))				(list 'm '(reloc) 'RIP () 1))
	  (else								()))))

(define-function arm64-placeholder (k sample)
  (cond
    ((memq (car k) '(imm simm pcrel pcpage))	(and (not (= 'imm0 (cadr k))) '(reloc)))
    ((memq (car k) '(off pre post))		(and (memq (car (caddr k)) '(imm simm))
						     (not (= 'imm0 (cadr (caddr k))))
						     (list (car k) (cadr sample) '(reloc))))
    (else					())))

;; Operands as encodable values: sampled targets made absolute at pc.
(define-function absolute (op pc)
  (cond ((not (pair? op))	op)
	((= 'rel (car op))	(+ pc (cadr op)))
	((= 'page (car op))	(+ (& pc -4096) (cadr op)))
	(else			(map (lambda (x) (absolute x pc)) op))))

(define placeholder	(if (= isa 'arm64) arm64-placeholder x86-placeholder))
(define samples-of	(if (= isa 'arm64) arm64-samples x86-samples))

;; Each instruction follows a NOP, so patching must find it after offset 0.
(define pc 0x40008)
(define-function started () (let ((b (asm-buffer pc))) (asm isa b '(NOP)) b))
(define at (asm-buffer-pc (started)))	; where each instruction starts, after the NOP

(list-do row (cadr (asm-isa isa))
  (let ((kinds (cadr row)) (pos 0))
    (let ((samples (map (lambda (k) (set pos (+ pos 1)) (absolute (car (samples-of row k pos)) at)) kinds)))
      (for (p 0 (list-length kinds))
	(let ((hole (placeholder (nth kinds p) (nth samples p))))
	  (when hole
	    (let* ((insn (cons (car row) (with samples p hole)))
		   (b (started))
		   (report (list-detect r (asm isa b insn) (= p (car r)))))
	      (if (not report)
		  (fail "no report for operand " p " of " insn)
		(let* ((r (asm-field-range isa (caddr report) p at (cadddr report)))
		       (lo (car r)) (hi (cadr r)) (step (caddr r))
		       (mid (+ lo (* step (/ (/ (- hi lo) step) 2)))))
		  (list-do v (list lo hi mid)
		    (set cases (+ cases 1))
		    (let ((patched (copy-buffer b)) (direct (started)))
		      (asm-patch isa patched report v)
		      		      (let ((row-bytes ((caddr (asm-isa isa)) (caddr report) (asm-substitute insn p v) at)))
			(list-do x (car row-bytes) (array-append (asm-buffer-bytes direct) x)))
		      (or (same-bytes? patched direct) (fail insn " patched with " v " differs from encoding it directly"))))
		  		  (list-do v (concat-list (if (< hi (+ hi step)) (list (+ hi step)) ())	; a full 64-bit field has no "past"
					  (concat-list (if (< (- lo step) lo) (list (- lo step)) ())
						       (if (< 1 step) (list (+ lo 1)) ())))
		    (set cases (+ cases 1))
		    (let* ((patched (copy-buffer b)) (out (asm-patch-attempt isa patched report v)))
		      (or (and (pair? out) (= 'error (car out)) (same-bytes? patched b))
			  (fail insn " patched with " v " was not refused")))))))))))))

(println "asm patch " isa ": " cases " cases, " failures " failures")
(if (= 0 failures) (println "asm patch " isa " ok"))
