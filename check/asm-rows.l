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

(define-function product (ls)
  (if ls
      (let ((out ()))
	(list-do x (car ls) (list-do rest (product (cdr ls)) (set out (cons (cons x rest) out))))
	out)
    (list ())))

(define-function out (f . strs)	(list-do x strs (string-do c x (putc c f))))

;;; ---------------------------------------------------------------- arm64

(define-function reg-sym (p i)	(string->symbol (concat-string p (long->string i))))

(define-function arm64-width (row name)
  (cdr (list-detect f (caddr row) (and (pair? f) (= name (car f))))))

;; Sample operands for kind k of row, using register number pos where a register goes.
(define-function arm64-samples (row k pos)
  (let ((c (car k)))
    (cond
      ((= c 'reg)	(let ((x (= ?X (string-at (symbol->string (cadr k)) 0))))
			  (list (reg-sym (if x "X" "W") pos)
				(if (caddr k) (if x 'SP 'WSP) (if x 'XZR 'WZR)))))
      ((= c 'imm)	(if (= 'imm0 (cadr k)) '(0)
			  (map (lambda (q) (* q (caddr k))) (list 7 (- (<< 1 (arm64-width row (cadr k))) 1)))))
      ((= c 'simm)	(let ((w (arm64-width row (cadr k))))
			  (map (lambda (q) (* q (caddr k))) (list -2 (- (<< 1 (- w 1)) 1) (- (<< 1 (- w 1)))))))
      ((= c 'pcrel)	(map (lambda (d) (list 'rel d)) (list 8 -8 (* 4 (- (<< 1 (- (arm64-width row (cadr k)) 1)) 1)))))
      ((= c 'lsl)	'((LSL 0) (LSL 16) (LSL 48)))
      (else		(let ((out ()))
			  (list-do b (arm64-samples row (cadr k) 9)
			    (list-do i (arm64-samples row (caddr k) 0) (set out (cons (list c b i) out))))
			  out)))))

;; clang's syntax for one operand; label is this instruction's label number.
(define-function arm64-text (op label)
  (cond
    ((symbol? op)		(symbol->string op))
    ((long? op)			(concat-string "#" (long->string op)))
    ((= 'LSL (car op))		(concat-string "LSL #" (long->string (cadr op))))
    ((= 'rel (car op))		(concat-strings "L" (long->string label) (if (< (cadr op) 0) " - " " + ")
					(long->string (if (< (cadr op) 0) (- 0 (cadr op)) (cadr op)))))
    ((= 'off (car op))		(concat-strings "[" (arm64-text (cadr op) label) ", " (arm64-text (caddr op) label) "]"))
    ((= 'pre (car op))		(concat-strings "[" (arm64-text (cadr op) label) ", " (arm64-text (caddr op) label) "]!"))
    ((= 'post (car op))		(concat-strings "[" (arm64-text (cadr op) label) "], " (arm64-text (caddr op) label)))))

(define-function arm64-skip? (row ops)	; constrained unpredictable: LDP with Rt == Rt2
  (and (= 'LDP (car row)) (= (car ops) (cadr ops))))

(define arm64-refused
  '((ADD X0 X1 4096)		; imm12 out of range
    (ADD X0 X1 -1)		; negative value for an unsigned field
    (ADD XZR X1 1)		; register 31 is SP in this form, not XZR
    (ADD X0 W1 3)))		; no form mixes X and W this way

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
	       (ops (map (lambda (x) (if (and (pair? x) (= 'rel (car x))) (+ start (cadr x)) x)) sops))
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
