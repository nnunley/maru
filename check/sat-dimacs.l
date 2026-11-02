;;; dimacs.irl reads DIMACS CNF, rejecting a malformed file by the number of its first bad
;;; line (draft-ndn-maru-sat-00 [R-dimacs]).  Prints "sat dimacs ok".
(require "sat.l")
(require "sat-gen.l")

(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define system (subr "system" "s"))
(define dir "/tmp/maru-check")
(system (concat-strings "mkdir -p " dir))
(define-function write-file (path text)
  (let ((f ((subr "fopen" "ss>p") path "w"))) ((subr "fputs" "sp>i") text f) ((subr "fclose" "p>i") f)))

(define dimacs-check (sat-fn "dimacs_check" "s>l"))
(define-function check-text (text)
  (write-file (concat-string dir "/sat-dimacs.cnf") text)
  (dimacs-check (concat-string dir "/sat-dimacs.cnf")))

(list-do row '(("p cnf 3 2\n1 -2 0\n2 3 0\n" 0)
	       ("c hi\np cnf 1 1\n1 0\n" 0)
	       ("p cnf 1 1\n0\n" 0)				; the empty clause is a clause
	       ("p cnf 8 3\n9 0\n1 0\n2 0\n" 2)			; a literal above V
	       ("p cnf 2 2\n1 0\n" 2)				; fewer clauses than C
	       ("p cnf 2 1\n1 x 0\n" 2)
	       ("1 0\n" 1)					; no header
	       ("p cnf 2 1\n1 1 0\n" 2)				; a repeated literal
	       ("p cnf 2 1\n1 0\n2 0\n" 3)			; more clauses than C
	       ("p cnf 99999999999 1\n1 0\n" 1))		; too large to allocate
  (let ((got (check-text (car row))))
    (expect (concat-strings (car row) " -> " (format "%d" got)) (= got (cadr row)))))

;; sat-write-dimacs round-trips through dimacs_load
(let ((path (concat-string dir "/sat-dimacs-rt.cnf")) (clauses '((1 -2) (2 3) (-3) ())))
  (sat-write-dimacs path 3 clauses)
  (let ((f ((sat-fn "dimacs_load" "s>p") path)) (back ()))
    (expect "the written file loads" (not (= 0 f)))
    (or (= 0 f)
	(let ((n ((sat-fn "dimacs_count" "p>l") f)))
	  (expect "3 variables" (= 3 ((sat-fn "dimacs_vars" "p>l") f)))
	  (for (i 0 n)
	    (let ((p ((sat-fn "dimacs_clause" "pl>p") f i)) (c ()) (j 0))
	      (while (not (= 0 (long-at p j))) (push c (long-at p j)) (set j (+ j 1)))
	      (push back (list-reverse! c))))
	  (expect "the clauses come back" (equal (list-reverse! back) clauses))
	  ((sat-fn "dimacs_free" "p") f)))))
;; generated formulas, each answer known by construction (R-generated-instances): every UNSAT
;; proof is checked by sat-decide, every model against the clauses
(for (n 2 8)
  (let ((f (sat-pigeonhole n)))
    (expect (concat-strings (format "%d" (+ n 1)) " pigeons in " (format "%d" n) " holes is UNSAT") (= 'unsat (car (sat-decide (car f) (cdr f)))))))
(define-function queens-placed? (n vals)	; n queens, no two on a row, column or diagonal
  (let ((qs ()) (good 1))
    (for (r 0 n) (for (c 0 n) (and (array-at vals (+ (+ 1 (* r n)) c)) (push qs (cons r c)))))
    (or (= n (list-length qs)) (set good ()))
    (list-do a qs (list-do b qs (or (= a b)
				   (let ((dr (- (car a) (car b))) (dc (- (cdr a) (cdr b))))
				     (and (or (= 0 dr) (= 0 dc) (= dr dc) (= dr (- dc))) (set good ()))))))
    good))
(for (n 1 9)
  (let* ((f (sat-queens n)) (r (sat-decide (car f) (cdr f))))
    (if (or (= n 2) (= n 3))
	(expect (concat-strings (format "%d" n) "-queens is UNSAT") (= 'unsat (car r)))
      (expect (concat-strings (format "%d" n) "-queens is SAT, its queens apart") (and (= 'sat (car r)) (queens-placed? n (cdr r)))))))
(list-do ratio '(30 40 426 50)	; clauses per variable, times 10 (4.26 is 3-SAT's threshold)
  (for (seed 1 5)
    (let ((f (sat-planted 50 ratio seed)))
      (expect (concat-strings "planted 3-SAT, ratio " (format "%d" ratio) "/10, seed " (format "%d" seed) " is SAT")
	      (= 'sat (car (sat-decide (car f) (cdr f))))))))
;; sat-decide drops a tautology and a repeated literal before solving (Review Focus 4)
(let ((r (sat-decide 3 '((1 -1) (2 2 3) (-2)))))
  (expect "a tautology and a repeat are cleaned" (and (= 'sat (car r)) (array-at (cdr r) 3) (not (array-at (cdr r) 2)))))
(and ok (println "sat dimacs ok"))
