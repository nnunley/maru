;;; The candidate table against the full scan, over every row's sample instructions.
;;;
;;;   ./eval check/asm-table.l ISA            (ISA: arm64, x64 or x86)
;;;
;;; The instructions are asm-rows.l's samples, each with every number in turn
;;; replaced by a placeholder, plus the refused instructions.  For each one: the
;;; table path (asm-attempt) and the full scan (asm-attempt-scan) must answer
;;; alike, with the same bytes, reports or error, and a refusal leaves the
;;; buffer alone; every row that encodes the instruction must be among its
;;; candidates; and over the whole stream the table must try fewer rows.  The
;;; last line is "asm table ISA ok" only when all of that holds.

(require "asm-table.l")
(require "asm-arm64.l")
(require "asm-x86.l")
(load "check/asm-samples.l")

(define isa (string->symbol (next-argument)))
(define start 0x4000)
(define failures 0)
(define-function fail (what insn) (set failures (+ failures 1)) (println "FAIL " what " " insn))

(define isa-refused (cond ((= isa 'arm64) arm64-refused) ((= isa 'x64) x64-refused) (else x86-refused)))
(define isa-samples (if (= isa 'arm64) arm64-samples x86-samples))
(define isa-variants (if (= isa 'arm64) arm64-variants x86-variants))
(define isa-set-variant (if (= isa 'arm64) arm64-set-variant x86-set-variant))
(set x86-sample-mode isa)

;; As check/asm-rows.l: a rel or page operand is an absolute address from start.
(define-function absolute-at (x start)
  (cond ((not (pair? x))	x)
	((= 'rel (car x))	(+ start (cadr x)))
	((= 'page (car x))	(+ (& start -4096) (cadr x)))
	(else			(map (lambda (y) (absolute-at y start)) x))))

;; insn with each number among its operands in turn replaced by (reloc), (reloc 16) and (reloc 32).
(define-function placeholder-variants (insn)
  (let ((out ()) (p -1))
    (list-do op (cdr insn)
      (set p (+ p 1))
      (when (long? op)
	(list-do v '((reloc) (reloc 16) (reloc 32))
	  (set out (cons (asm-substitute insn p v) out)))))
    out))

(define stream ())
(list-do row (<asm-isa>-rows (asm-isa isa))
  (list-do variant (isa-variants row)
    (isa-set-variant variant)
    (let ((pos 0))
      (list-do sops (product (map (lambda (k) (set pos (+ pos 1)) (isa-samples row k pos)) (cadr row)))
	(let ((insn (cons (car row) (map (lambda (x) (absolute-at x start)) sops))))
	  (set stream (cons insn (concat-list (placeholder-variants insn) stream))))))))
(isa-set-variant ())
(set stream (list-reverse! stream))

;; The encoder, counted: the attempts below count the rows they try.
(define entry (asm-isa isa))
(define encode (<asm-isa>-encode entry))
(define counted 0)
(set (<asm-isa>-encode entry) (lambda (row insn pc) (set counted (+ counted 1)) (encode row insn pc)))

(define checked 0)
(define refusals 0)
(define table-encodes 0)
(define scan-encodes 0)

(define-function check-insn (insn)
  (let ((tb (asm-buffer start)) (sb (asm-buffer start)) (rt ()) (rs ()))
    (set counted 0)
    (set rt (asm-attempt isa tb insn))
    (set table-encodes (+ table-encodes counted))
    (set counted 0)
    (set rs (asm-attempt-scan isa sb insn))
    (set scan-encodes (+ scan-encodes counted))
    (set checked (+ checked 1))
    (or (equal rt rs) (fail "table and scan answer differently" insn))
    (or (equal (array->list (asm-buffer-bytes tb)) (array->list (asm-buffer-bytes sb))) (fail "bytes differ" insn))
    (when (and (pair? rt) (= 'error (car rt)))
      (set refusals (+ refusals 1))
      (or (= 0 (array-length (asm-buffer-bytes tb))) (fail "a refusal wrote bytes" insn)))
    ;; every row that encodes insn is among the candidates
    (let ((cands (asm-candidate-rows isa insn)))
      (list-do r (asm-rows-for (asm-isa isa) (car insn))
	(and (encode r insn start) (not (list-detect c cands (= c r)))
	     (fail "a row that encodes it is not a candidate" insn))))))

(list-do insn stream (check-insn insn))

;; The refused instructions are refused, by both paths.
(define refused-ok 0)
(list-do insn isa-refused
  (check-insn insn)
  (let ((r (asm-attempt isa (asm-buffer start) insn)))
    (if (and (pair? r) (= 'error (car r)))
	(set refused-ok (+ refused-ok 1))
      (fail "not refused" insn))))

(println "asm table " isa ": " checked " instructions, " refusals " refused, " refused-ok "/" (list-length isa-refused)
	 " of the required refusals, " table-encodes " encodes by the table, " scan-encodes " by the full scan, "
	 failures " failures")
(if (and (= 0 failures) (= refused-ok (list-length isa-refused)) (< table-encodes scan-encodes))
    (println "asm table " isa " ok"))
