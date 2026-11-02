;;; Every UNSAT answer carries a DRAT proof, which drat-check.irl verifies against the
;;; formula it reads itself; a proof that doesn't show the formula UNSAT is rejected
;;; (draft-ndn-maru-sat-00 [R-drat] [R-checker] [R-checker-rejects] [R-formats-grammars]).
;;; Prints "sat proof ok".
(require "sat.l")

(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define dir "/tmp/maru-check")
((subr "system" "s>i") (concat-strings "mkdir -p " dir))
(define-function write-file (path text)
  (let ((f ((subr "fopen" "ss>p") path "w"))) ((subr "fputs" "sp>i") text f) ((subr "fclose" "p>i") f)))
(define drat-check (sat-fn "drat_check" "ss>l"))
(define drat-failed-line (sat-fn "drat_failed_line" ">l"))
(define-function check-proof (clauses n proof)	; drat_check over a formula and a proof's text
  (sat-write-dimacs (concat-string dir "/proof-test.cnf") n clauses)
  (write-file (concat-string dir "/proof-test.drat") proof)
  (drat-check (concat-string dir "/proof-test.cnf") (concat-string dir "/proof-test.drat")))

;; three pigeons in two holes: UNSAT, its proof checked by sat-decide and readable afterwards
(define pigeons
  (let ((p (lambda (i h) (+ (* 2 (- i 1)) h))) (cs ()))
    (for (i 1 4) (push cs (list (p i 1) (p i 2))))
    (for (h 1 3) (for (i 1 4) (for (j (+ i 1) 4) (push cs (list (- (p i h)) (- (p j h)))))))
    cs))
(let ((r (sat-decide 6 pigeons)))
  (expect "3 pigeons in 2 holes is UNSAT, its proof accepted" (= 'unsat (car r)))
  (expect "the proof is a file" (and (cdr r) (< 0 (string-length (contents-of-file-named (cdr r))))))
  (let* ((text (contents-of-file-named (cdr r)))
	 (n (string-length text)))
    (expect "the real proof checks again" (= 1 (check-proof pigeons 6 text)))
    ;; the final 0 dropped: the empty clause is never derived
    (expect "a proof without its final 0 is rejected" (= 0 (check-proof pigeons 6 (string-copy text 0 (- n 2)))))))
(expect "an empty proof is rejected" (= 0 (check-proof pigeons 6 "")))
;; a formula holding the empty clause: its proof is just 0
(expect "the empty clause's proof is 0" (= 'unsat (car (sat-decide 1 '((1) ())))))
(expect "0 alone refutes a formula with the empty clause" (= 1 (check-proof '((1) ()) 1 "0\n")))
;; -1 follows from (1 2) neither by unit propagation nor as a resolution asymmetric tautology
(expect "a lemma that doesn't follow is rejected" (= 0 (check-proof '((1 2)) 2 "-1 0\n-2 0\n0\n")))
(expect "at its line" (= 1 (drat-failed-line)))
;; deleting the clause the refutation needs leaves nothing to derive the empty clause from
(expect "a proof that deletes what it needs is rejected" (= 0 (check-proof '((1) (-1)) 1 "d 1 0\n0\n")))
(expect "and with it kept, accepted" (= 1 (check-proof '((1) (-1)) 1 "0\n")))
;; RAT: a clause over a fresh variable follows
(expect "a RAT addition is accepted" (= 1 (check-proof '((1) (-1)) 1 "2 0\n0\n")))
;; a proof dir that is a symbolic link is refused
((subr "system" "s>i") (concat-strings "rm -rf " dir "/proof-link " dir "/proof-real && mkdir " dir "/proof-real && ln -s " dir "/proof-real " dir "/proof-link"))
(expect "a symbolic link as the proof dir is refused" (not (sat-proof-dir-usable? (concat-string dir "/proof-link"))))
(expect "a real dir is used" (sat-proof-dir-usable? (concat-string dir "/proof-real")))
(and ok (println "sat proof ok"))
