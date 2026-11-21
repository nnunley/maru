;;; The specialiser keeps every row a site's representative would have found: for each template the lowering grammars
;;; and helpers expand, the rows it keeps include asm-candidate-rows for the instruction with each hole's representative
;;; (X0, W0, 0, D0 or S0, the memory shape given, EQ), but for those that can't encode it (the candidate table's shapes
;;; are wider than a row: a register-offset row for an (off …) operand).  A row dropped wrongly changes the bytes
;;; whenever a later kept row also fits; one kept besides is harmless, since every row that encodes an instruction is
;;; among asm's candidates.  The
;;; templates it hands back to the site's encoder are counted.  The last line is "kept rows ok".
;;;   ./eval2 check/arm64-kept-rows.l
(define records ())
(define *arm64-sites-recorder*	; a label site's label position too: only rows giving it a field take a placeholder
  (lambda (mnemonic specs kept fallback label) (push records (list mnemonic specs kept fallback label))))
(define-function considered? (row r)	; asm-best-row skips a row with no field at an open placeholder's position
  (let ((at (car (cddddr r)))) (or (not at) (arm64-field-range row at 0))))
(require "native.l")
(define missing 0)
(define fallbacks 0)
(define wide 0)
(list-do r records
  (if (cadddr r)
      (set fallbacks (+ fallbacks 1))
    (let* ((specs (cadr r))
	   (insn (cons (car r) (map (lambda (s) (if (arm64-site-variable? s) (arm64-site-representative s) (arm64-site-literal s))) specs))))
      (list-do row (asm-candidate-rows 'arm64 insn)
	(cond ((memq row (caddr r)))
	      ((not (considered? row r)))
	      ((arm64-encode-row row (cdr insn) 0)	; it takes the instruction: dropping it can change the bytes
	       (set missing (+ missing 1)) (println "DROPPED " (car row) " " (cadr row) " for " insn))
	      (else (set wide (+ wide 1))))))))	; the candidate table's shapes take more than the row can encode
(println "kept rows: " (list-length records) " templates, " fallbacks " handed to the site's encoder, " missing
	 " rows dropped that take the instruction, " wide " candidates that can't (register-offset forms for an offset)")
(or (= 0 missing) (error "arm64-kept-rows: " missing " rows dropped"))
(println "kept rows ok")
