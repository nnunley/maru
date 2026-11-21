;;; The encoder grammar (arm64-rules.g, written by gen-arm64-rules.l) answers as asm does, over check/asm-table.l's arm64
;;; stream: every row's samples, each number in turn a placeholder, and the refused instructions.  For each, the
;;; mnemonic's rule (or, with an open placeholder, the rule of the rows that give its position a field, widest first)
;;; answers the row asm-select chooses and its word, or fails where asm finds no row.  The last line is "asm grammar ok".
;;;   ./eval check/asm-grammar.l
(set *arguments* '("arm64"))
(load "check/asm-table.l")	; the stream, and asm_table's own arm64 checks
(load "arm64-rules.g.l")

(define-function word-of (bytes) (| (car bytes) (| (<< (cadr bytes) 8) (| (<< (caddr bytes) 16) (<< (cadddr bytes) 24)))))
(define-function grammar-answer (insn)	; (row . word), or ()
  (let* ((open (asm-open-placeholder insn))
	 (name (if open
		   (arm64-rule-name "open" (concat-string (symbol->string (car insn)) (long->string open)))
		 (arm64-rule-name "mn" (car insn))))
	 (selector (concat-symbol '$ name)))
    (and (defined? selector)
	 (let ((p (source-parser-for <arm64-rules> (list insn))))
	   (set (<arm64-rules>-pc p) start)
	   (and (source-parser-invoke-rule selector (eval selector) p) (<source-parser>-result p))))))
(define-function asm-answer (insn)	; (row . word) as asm chooses it, or ()
  (and (asm-rows-for (asm-isa 'arm64) (car insn))
       (let ((found (asm-select 'arm64 insn start (asm-candidate-rows 'arm64 insn))))
	 (and found (cons (car found) (word-of (cadr found)))))))

(define compared 0)
(define differ 0)
(define-function compare (insn)
  (let ((g (grammar-answer insn)) (a (asm-answer insn)))
    (set compared (+ compared 1))
    (or (if a (and g (= (car g) (car a)) (= (cdr g) (cdr a))) (not g))
	(let () (set differ (+ differ 1)) (and (< differ 20) (println "DIFFER " insn ": grammar " (and g (cdr g)) ", asm " (and a (cdr a))))))))
(list-do insn stream (compare insn))
(list-do insn isa-refused (compare insn))
(println "asm grammar arm64: " compared " instructions, " differ " answered differently")
(or (= 0 differ) (error "asm-grammar: " differ " instructions answered differently"))
(println "asm grammar ok")
