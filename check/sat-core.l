;;; sat.irl's CDCL solver behind the IPASIR interface: satisfiable and unsatisfiable formulas,
;;; incremental clauses, assumptions and the ones a refutation used, and every model checked
;;; against the clauses in Maru (draft-ndn-maru-sat-00 [R-ipasir] [R-cdcl] [R-model-checked]).
;;; Prints "sat core ok".
(require "sat.l")

(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define-function value (vals v) (array-at vals v))

(let ((r (sat-decide 2 '((1 2) (-1 2) (1 -2)))))
  (expect "(1 2) (-1 2) (1 -2) is SAT" (= 'sat (car r)))
  (expect "with 1 and 2 true" (and (value (cdr r) 1) (value (cdr r) 2))))
(expect "(1) (-1) is UNSAT" (= 'unsat (car (sat-decide 1 '((1) (-1))))))
(let ((r (sat-decide 3 ())))
  (expect "the empty formula over 3 variables is SAT" (= 'sat (car r)))
  (expect "and every variable has a value" (= 4 (array-length (cdr r)))))

;; one solver, clauses added between solves
(let ((s (sat-init)))
  (sat-add-clause s '(1 2))
  (expect "(1 2) alone is SAT" (= 10 (sat-solve s)))
  (sat-add-clause s '(-1))
  (expect "then with (-1), still SAT" (= 10 (sat-solve s)))
  (expect "2 must be true" (= 2 (sat-val s 2)))
  (sat-add-clause s '(-2))
  (expect "and with (-2), UNSAT" (= 20 (sat-solve s)))
  (sat-release s))

;; assumptions hold for one solve; the failed ones are the ones the refutation used
(let ((s (sat-init)))
  (sat-add-clause s '(1 2))
  (sat-assume s -1) (sat-assume s -2)
  (expect "(1 2) assuming -1 and -2 is UNSAT" (= 20 (sat-solve s)))
  (expect "both assumptions failed" (and (= 1 (sat-failed s -1)) (= 1 (sat-failed s -2))))
  (expect "the next solve, without them, is SAT" (= 10 (sat-solve s)))
  (sat-assume s 1)
  (expect "assuming 1 is SAT" (= 10 (sat-solve s)))
  (expect "and 1 is true" (= 1 (sat-val s 1)))
  (sat-release s))

;; a harder formula: three pigeons can't sit in two holes, whatever order the search tries
(let ((p (lambda (i h) (+ (* 2 (- i 1)) h))) (cs ()))
  (for (i 1 4) (push cs (list (p i 1) (p i 2))))
  (for (h 1 3) (for (i 1 4) (for (j (+ i 1) 4) (push cs (list (- (p i h)) (- (p j h)))))))
  (expect "three pigeons in two holes is UNSAT" (= 'unsat (car (sat-decide 6 cs)))))

;; the model check catches a model that falsifies a clause
(let* ((clauses '((1 2) (-1 2))) (r (sat-decide 2 clauses)) (vals (cdr r)))
  (expect "the model holds" (sat-model-holds? clauses vals))
  (set-array-at vals 2 (not (array-at vals 2)))
  (expect "a corrupted model is caught" (not (sat-model-holds? clauses vals))))
(and ok (println "sat core ok"))
