;;; Every row's sample encodings against clang's, and back through the decoder.
;;;
;;;   ./eval check/asm-rows.l ISA TMPDIR
;;;
;;; For each row, operands are sampled in every position; the instructions are
;;; written in clang's syntax to TMPDIR/ISA.s, assembled, and clang's bytes
;;; (read with objdump -s) compared with ours.  Each instruction is also
;;; decoded and re-encoded, and must give the same bytes.  Instructions the
;;; rows must refuse are tried with asm-attempt.  The last line is
;;; "asm rows ISA ok" only when everything holds.

(define system (subr "system" "s"))
(define isa (string->symbol (next-argument)))
(define tmp (next-argument))

(require "asm-table.l")
(require "asm-arm64.l")
(load "check/asm-samples.l")

(define-function out (f . strs)	(list-do x strs (string-do c x (putc c f))))

(define-function arm64-skip? (row ops)	; constrained unpredictable: LDP with Rt == Rt2
  (and (= 'LDP (car row)) (= (car ops) (cadr ops))))

(define arm64-refused
  '((ADD X0 X1 4096)		; imm12 out of range
    (ADD X0 X1 -1)		; negative value for an unsigned field
    (ADD XZR X1 1)		; register 31 is SP in this form, not XZR
        (ADD X0 W1 3)		; no form mixes X and W this way
    (AND X0 X1 5)		; 0b101 is not a rotated run of ones: no logical immediate
    (AND X0 X1 0)		; nor are all zeros
    (AND W0 W1 -1)		; nor all ones
    (FMOV S0 0.1)		; not +/-(16+m)/16 * 2^n
    (LSL X0 X1 64)		; shift out of range
    (CSET X0 AL)		; AL and NV have no inverse
    (LDR X0 (off X1 4))		; offset not a multiple of 8
    (FADD S0 S1 D2)))		; mixed precision

(define isa-rows		(cadr (asm-isa isa)))
(define isa-samples		arm64-samples)
(define isa-text		arm64-text)
(define isa-skip?		arm64-skip?)
(define isa-refused		arm64-refused)
(define isa-clang		"-target arm64-apple-macos")
(define isa-section		"__text")

;;; ---------------------------------------------------------------- driver

(define s (open (concat-strings tmp "/" (symbol->string isa) ".s") "w"))
(define buffer (asm-buffer 0))
(define lines (array))			; text of each instruction, by index
(define starts (array))			; its offset in buffer
(define n 0)
(define roundtrip 0)
(define aliased 0)
(define refused 0)

(define-function slice (bytes from to)
  (let ((a (array))) (for (i from to) (array-append a (array-at bytes i))) a))

(list-do row isa-rows
  (let ((pos 0))
    (list-do sops (product (map (lambda (k) (set pos (+ pos 1)) (isa-samples row k pos)) (cadr row)))
      (unless (isa-skip? row sops)
	(let* ((start (asm-buffer-pc buffer))
	       (ops (map (lambda (x) (cond ((and (pair? x) (= 'rel (car x)))	(+ start (cadr x)))
					   ((and (pair? x) (= 'page (car x)))	(+ (& start -4096) (cadr x)))
					   (else				x)))
			  sops))
	       (line (symbol->string (car row)))
	       (first 1))
	  (list-do x sops (set line (concat-strings line (if first " " ", ") (isa-text x n))) (set first ()))
	  (asm isa buffer (cons (car row) ops))
	  (out s "L" (long->string n) ": " line "\n")
	  (array-append lines line)
	  (array-append starts start)
	  ;; decode and re-encode: the same bytes
	  (let* ((bytes (slice (asm-buffer-bytes buffer) start (asm-buffer-pc buffer)))
		 (back (asm-decode isa bytes start))
		 (again (asm-buffer start)))
	    (if (not back)
		(let () (set roundtrip (+ roundtrip 1)) (println "UNDECODED " line))
	      (asm isa again (car back))
	      (cond
		((not (equal (array->list bytes) (array->list (asm-buffer-bytes again))))
		 (set roundtrip (+ roundtrip 1)) (println "ROUNDTRIP " line " -> " (car back)))
		((not (equal (car back) (cons (car row) ops)))
		 (set aliased (+ aliased 1))))))
	  (set n (+ n 1)))))))
(close s)

;; Instructions that must be refused, and must leave the buffer alone.
(list-do insn isa-refused
  (let ((pc (asm-buffer-pc buffer)) (r (asm-attempt isa buffer insn)))
    (if (and (pair? r) (= 'error (car r)) (= pc (asm-buffer-pc buffer)))
	(set refused (+ refused 1))
      (println "NOT REFUSED " insn))))

;; clang's bytes, from objdump -s's hex dump of the text section.
(define base (concat-strings tmp "/" (symbol->string isa)))
(system (concat-strings "/usr/bin/clang " isa-clang " -c " base ".s -o " base ".o && "
			"/usr/bin/objdump -s -j " isa-section " " base ".o > " base ".dump"))

(define-function hex-digit (c)
  (cond ((and (<= ?0 c) (<= c ?9)) (- c ?0)) ((and (<= ?a c) (<= c ?f)) (+ 10 (- c ?a))) (else ())))

(define clang (array))
(let ((text (contents-of-file-named (concat-string base ".dump"))) (i 0) (len 0) (col 0) (dump ()))
  (set len (string-length text))
  ;; data lines start with a space then the offset; the hex groups follow, then two spaces and ASCII
  (while (< i len)
    (let ((j i))
      (while (and (< j len) (!= ?\n (string-at text j))) (set j (+ j 1)))
      (when (and (< (+ i 1) j) (= 32 (string-at text i)) (hex-digit (string-at text (+ i 1))))
	(let ((k (+ i 1)))
	  (while (and (< k j) (!= 32 (string-at text k))) (set k (+ k 1)))	; skip the offset
	  (set k (+ k 1))
	  (while (and (< (+ k 1) j) (hex-digit (string-at text k)) (hex-digit (string-at text (+ k 1))))
	    (array-append clang (+ (* 16 (hex-digit (string-at text k))) (hex-digit (string-at text (+ k 1)))))
	    (set k (+ k 2))
	    (and (< k j) (= 32 (string-at text k)) (< (+ k 1) j) (hex-digit (string-at text (+ k 1))) (set k (+ k 1))))))
      (set i (+ j 1)))))

(define differ 0)
(let ((ours (asm-buffer-bytes buffer)))
  (for (m 0 n)
    (let* ((from (array-at starts m))
	   (to (if (< (+ m 1) n) (array-at starts (+ m 1)) (array-length ours))))
      (for (i from to)
	(unless (and (< i (array-length clang)) (= (array-at ours i) (array-at clang i)))
	  (set differ (+ differ 1))
	  (println "DIFF " (array-at lines m))
	  (set i to)))))
  (or (= (array-length ours) (array-length clang))
      (let () (set differ (+ differ 1)) (println "LENGTH ours " (array-length ours) " clang " (array-length clang)))))

(println "asm rows " isa ": " n " instructions, " differ " differ, " roundtrip " round-trip failures, "
	 aliased " decoded as an alias, " refused "/" (list-length isa-refused) " refused")
(if (and (= 0 differ) (= 0 roundtrip) (= refused (list-length isa-refused)))
    (println "asm rows " isa " ok"))
