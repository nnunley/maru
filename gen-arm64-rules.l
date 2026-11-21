;;; gen-arm64-rules.l -- arm64.spec's rows as a tree grammar, written to standard output (make writes arm64-rules.g):
;;; an operand rule for each simple operand kind (asm-arm64.l's arm64-operand-rule, answering the kind's value), a
;;; rule for each row matching an instruction and answering (row . word) (arm64-row-result), a row whose kinds have no
;;; operand rule matched whole by its encoder (arm64-escape-result), and for each mnemonic two choices: its rows in
;;; file order, which is asm's first fit, and for each operand position a placeholder may take, the rows that give it a
;;; field, widest first and stable, which is asm-best-row's choice for an open placeholder.
;;;   ./eval gen-arm64-rules.l > arm64-rules.g
(require "asm-arm64.l")

(define operand-rules (identity-hash-table))	; name -> expression of v
(define-function text (x)	; x as Maru reads it back
  (cond ((pair? x)
	 (let ((parts "(") (first 1))
	   (while (pair? x)
	     (set parts (concat-string parts (concat-string (if first "" " ") (text (car x)))))
	     (set first ()) (set x (cdr x)))
	   (concat-string parts ")")))
	((= x ())	"()")
	((long? x)	(long->string x))
	((symbol? x)	(symbol->string x))
	(else		(error "gen-arm64-rules: can't write " x))))

;; info's pattern, its leaves named from n: (text . next n), or () if a kind in it has no operand rule
(define-function pattern (info n)
  (let ((c (car info)))
    (cond ((= c 'imm0)	(cons "imm0" n))
	  ((= c 'tag)
	   (let* ((a (pattern (caddr info) n)) (b (and a (pattern (cadddr info) (cdr a)))))
	     (and b (cons (concat-string "`( '" (concat-string (symbol->string (cadr info))
						    (concat-string " " (concat-string (car a) (concat-string " " (concat-string (car b) " )"))))))
			  (cdr b)))))
	  ((= c 'mreg)
	   (let* ((a (pattern (cadddr info) n)) (b (and a (pattern (car (cddddr info)) (cdr a)))) (rest ""))
	     (list-do x (caddr info) (set rest (concat-string rest (concat-string " '" (text x)))))
	     (and b (cons (concat-string "`( 'reg " (concat-string (car a) (concat-string " " (concat-string (car b) (concat-string rest " )")))))
			  (cdr b)))))
	  (else
	   (let ((r (arm64-operand-rule info)))
	     (and r (let () (hash-at-put operand-rules (car r) (cadr r))
		      (cons (concat-string (symbol->string (car r)) (concat-string ":a" (long->string n))) (+ n 1)))))))))

(define-function leaves (n) (let ((s "")) (for (i 0 n) (set s (concat-string s (concat-string " a" (long->string i))))) s))

(define rules ())	; (name . text), in order
(define-function rule (name body) (push rules (cons name body)))
(define by-mnemonic (identity-hash-table))	; mnemonic -> its rows' indices, in file order
(define mnemonics ())
(for (k 0 (array-length arm64-row-vector))
  (let* ((row (array-at arm64-row-vector k)) (name (concat-string "row" (long->string k)))
	 (n 0) (parts "") (ok 1))
    (list-do info (<arm64-plan>-infos (arm64-row-plan row))
      (let ((p (and ok (pattern info n))))
	(if p (let () (set parts (concat-string parts (concat-string " " (car p)))) (set n (cdr p))) (set ok ()))))
    (rule name (if ok
		   (concat-string "`( '" (concat-string (text (car row)) (concat-string parts
		     (concat-string " ) -> (arm64-row-result " (concat-string (long->string k) (concat-string " (list" (concat-string (leaves n) "))")))))))
		 (concat-string ".:i &-> (arm64-escape-result " (concat-string (long->string k) (concat-string " i self.pc) -> (arm64-escape-result "
		   (concat-string (long->string k) " i self.pc)"))))))
    (or (hash-at by-mnemonic (car row)) (push mnemonics (car row)))
    (hash-at-put by-mnemonic (car row) (concat-list (hash-at by-mnemonic (car row)) (list k)))))

(define-function row-names (ks) (let ((s "") (first 1)) (list-do k ks (set s (concat-string s (concat-string (if first "" " | ") (concat-string "row" (long->string k))))) (set first ())) s))
(define-function field-size (k position)	; the row's field size at position, as asm-best-row ranks it, or ()
  (let ((r (arm64-field-range (array-at arm64-row-vector k) position 0)))
    (and r (/ (- (cadr r) (car r)) (caddr r)))))
(define-function sorted-by-size (ks position)	; stable, widest first, rows with no field there left out
  (let ((out ()))
    (list-do k ks
      (let ((s (field-size k position)))
	(when s
	  (let ((before ()) (after out))
	    (while (and after (>= (cdar after) s)) (push before (car after)) (set after (cdr after)))
	    (set out (concat-list (list-reverse! before) (cons (cons k s) after)))))))
    (map car out)))
(list-do m (list-reverse! mnemonics)
  (let ((ks (hash-at by-mnemonic m)) (most 0))
    (rule (arm64-rule-name "mn" m) (row-names ks))
    (list-do k ks (set most (max most (list-length (cadr (array-at arm64-row-vector k))))))
    (for (p 0 most)
      (let ((open (sorted-by-size ks p)))
	(and open (rule (arm64-rule-name "open" (concat-string (symbol->string m) (long->string p))) (row-names open)))))))

(println "# arm64.spec's rows as a tree grammar: written by gen-arm64-rules.l, by make; don't edit.")
(println "<arm64-rules> : <source-parser> (pc)")
(hash-do operand-rules (lambda (name e) (println (symbol->string name) " = .:v &-> " (text e) " -> " (text e) " ;")))
(println "imm0 = .:v &-> (= v 0) ;")
(list-do r (list-reverse! rules) (println (car r) " = " (cdr r) " ;"))
