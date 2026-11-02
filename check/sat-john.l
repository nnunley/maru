;;; JOHN planning by satisfiability (draft-ndn-maru-sat-00): cnf.l's gates agree with their
;;; truth tables through the solver; every property's sort is inferred (R-sorts), a conflict or
;;; an out-of-bound constant refused; what the encoding doesn't cover stops the planner
;;; (R-sat-unsupported).  "program TEXT" runs TEXT in a child.  Prints "sat john ok".
(require "john-eval.l")
(require "john-sat.l")

(define system (subr "system" "s>i"))
(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define-function has? (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (<= i n)))
(define-function child (text)
  (system "mkdir -p /tmp/maru-check")
  (system (concat-strings "./eval check/sat-john.l program '" text "' >/tmp/maru-check/sat-john.out 2>&1"))
  (contents-of-file-named "/tmp/maru-check/sat-john.out"))

;; a child: run TEXT and stop
(define-function run-child (text) (println (john-run (john-read-text text))) (exit 0))
(and *arguments* (let () (next-argument) (run-child (next-argument))))

;; a gate's output, solved with its inputs fixed: (value of the output under inputs)
(define-function gate-value (build inputs)	; build: (lambda (c ins) output-literal)
  (let* ((c (cnf-new)) (ins (map (lambda (x) (cnf-var c)) inputs)) (out (build c ins)))
    (list-do pair (map cons ins inputs) (cnf-assert c (if (cdr pair) (car pair) (cnf-not (car pair)))))
    (let ((r (sat-decide (cnf-nvars c) (cnf-clauses c))))
      (and (= 'sat (car r)) (if (< 0 out) (array-at (cdr r) out) (not (array-at (cdr r) (- out))))))))
(define-function bools (n) (if (= 0 n) (list ()) (let ((rest (bools (- n 1))) (out ())) (list-do r rest (push out (cons 1 r)) (push out (cons () r))) out)))
(define-function check-gate (name n build truth)
  (list-do ins (bools n) (expect (concat-strings name " " (format "%d" (list-length ins))) (= (not (gate-value build ins)) (not (apply truth ins))))))
(check-gate "and" 3 (lambda (c ins) (cnf-and c ins)) (lambda (a b d) (and a b d)))
(check-gate "or" 3 (lambda (c ins) (cnf-or c ins)) (lambda (a b d) (or a b d)))
(check-gate "xor" 2 (lambda (c ins) (cnf-xor c (car ins) (cadr ins))) (lambda (a b) (if a (not b) b)))
(check-gate "iff" 2 (lambda (c ins) (cnf-iff c (car ins) (cadr ins))) (lambda (a b) (if a b (not b))))
(check-gate "mux" 3 (lambda (c ins) (cnf-mux c (car ins) (cadr ins) (caddr ins))) (lambda (s a b) (if s a b)))
(check-gate "true" 1 (lambda (c ins) (cnf-true c)) (lambda (a) 1))
;; exactly one of four: satisfiable with each one alone, refuted with two
(let ((one (lambda (fixed)
	     (let* ((c (cnf-new)) (xs (map (lambda (i) (cnf-var c)) '(1 2 3 4))))
	       (cnf-exactly-one c xs)
	       (list-do i fixed (cnf-assert c (car (john-sat-nth xs i))))
	       (car (sat-decide (cnf-nvars c) (cnf-clauses c)))))))
  (expect "exactly one of four, with one chosen" (= 'sat (one '(2))))
  (expect "exactly one of four, with two chosen" (= 'unsat (one '(0 3)))))

;; sorts, from the x86 allocator's values: a Register or no is a name; lists nest
(john-run-sorts (john-read "check/john/x86-allocator.john"))
(let ((s (john-sorts)))
  (expect "next-right is a name" (equal 'name (cdr (assoc-sort s 'R1 'next-right))))
  (expect "allocations are a list of names" (equal '(list name) (cdr (assoc-sort s 'R1 'allocations))))
  (expect "live-ranges are lists of lists of numbers" (equal '(list (list number)) (cdr (assoc-sort s 'Va 'live-ranges))))
  (expect "length is a number" (equal 'number (cdr (assoc-sort s 'Va 'length)))))
(expect "a number and a list for one property is E_SORT"
	(has? (child "create C a. make C X 3. action C empty consequence it a = [ ]. goal C done try its a = 0. set-opt planner sat. X satisfy done.") "E_SORT"))
(expect "70000 in 16 bits is E_BOUND"
	(has? (child "create C a. make C X 70000. goal C done try its a = 0. set-opt planner sat. X satisfy done.") "E_BOUND: 70000 does not fit sat-width 16"))
(expect "two-player-game under planner sat is E_SAT_UNSUPPORTED"
	(has? (child "create P x. make P A 1. make P B 1. goal P done try its x = 1. set-opt two-player-game [ A, B ]. set-opt planner sat. A satisfy done.") "E_SAT_UNSUPPORTED: two-player-game"))
(expect "a time-reading expression under planner sat is E_SAT_UNSUPPORTED"
	(has? (child "create P x. make P A 1. goal P done try at time 0 its x = 1. set-opt planner sat. A satisfy done.") "E_SAT_UNSUPPORTED: at time"))
;; planning over names: the least length, replayed by the evaluator, the same as the search's
(define-function last (l) (if (cdr l) (last (cdr l)) (car l)))
(define-function no-satisfy (fs) (let ((out ())) (list-do f fs (or (= 'satisfy (car f)) (push out f))) (list-reverse! out)))
(define-function plan (fs opts goal) (john-run (concat-list (no-satisfy fs) (concat-list opts (list goal)))))
(define-function by-sat (fs goal) (plan fs '((set-opt planner sat)) goal))
(define-function time-line (out) (let ((r ())) (list-do l out (and (has? l "satisfied at time: ") (set r l))) r))
(define-function tries (out) (let ((n 0)) (list-do l out (and (has? l "trying ") (incr n))) n))
(define-function tried-in-order? (out)	; trying 0, 1, ... each line in turn
  (let ((k 0) (good 1))
    (list-do l out (and (has? l "trying ") (let () (or (= (string-copy l 0 (+ 15 (string-length (format "%d" k)))) (concat-strings "trying " (format "%d" k) " steps (")) (set good ())) (incr k))))
    good))
(define hanoi-win '(satisfy Hanoi win () () ()))
(let ((out (by-sat (john-read "check/john/hanoi2.john") hanoi-win)))
  (expect "Hanoi2 by sat at time 3" (equal "satisfied at time: 3" (time-line out)))
  (expect "Hanoi2 tries 0 to 3 steps" (and (= 4 (tries out)) (tried-in-order? out)))
  (expect "Hanoi2's last try satisfiable" (has? (car (john-sat-nth out 3)) "): satisfiable")))
(let ((out (by-sat (john-read "check/john/hanoi3.john") hanoi-win)))
  (expect "Hanoi3 by sat at time 7" (equal "satisfied at time: 7" (time-line out)))
  (expect "Hanoi3 tries 0 to 7 steps" (and (= 8 (tries out)) (tried-in-order? out))))
(define trap-text "create Square near blocked. create Robot position.
  make Square S 2 yes. make Square D 1 no. make Square M 2 no. make Square G 0 no. make Robot R S.
  rel-qualify Square:A next Square:B if (A = S and (B = D or B = M)) or (A = M and B = G).
  action Robot move Square consequence its position = Square and Square blocked = yes.
  rule Robot move is Square blocked = no. rule Robot move is its position next Square.
  goal Robot reach try its position = G. heuristic Robot reach 1 minimize its position near. ")
(define-function both-agree (what fs goal)	; the two planners' least lengths
  (let ((s (time-line (plan fs () goal))) (b (time-line (by-sat fs goal))))
    (expect (concat-strings what ": the search and sat agree (" (or s "none") ")") (and s (equal s b)))))
(both-agree "Hanoi2" (john-read "check/john/hanoi2.john") hanoi-win)
(both-agree "Hanoi3" (john-read "check/john/hanoi3.john") hanoi-win)
(both-agree "the trap breadth-first" (john-read-text trap-text) '(satisfy R reach () () ()))
(expect "the trap in 2" (equal "satisfied at time: 2" (time-line (by-sat (john-read-text trap-text) '(satisfy R reach () () ())))))
(both-agree "the maze" (john-read "check/john/maze.john") '(satisfy R reach () () ()))
(expect "the consistent Hanoi4 by sat at time 15"
	(equal "satisfied at time: 15" (time-line (by-sat (john-read "check/john/hanoi4-ours.john") hanoi-win))))
(let ((out (john-run (john-read-text "create C a. make C X 1. goal C done try its a = 1. set-opt planner sat. X satisfy done."))))
  (expect "a goal true now is satisfied at time 0" (equal (cdr out) '("satisfied at time: 0" "satisfied by: [  ]"))))
(let ((out (by-sat (concat-list (john-read "check/john/hanoi2.john") (john-read-text "goal Towers under try A supporter = Peg1 and B supporter = A."))
		   '(satisfy Hanoi under () () ()))))
  (expect "no plan reaches A on Peg1 under B" (equal (last out) "unsatisfiable within 16 steps (width 16, lists 16, unroll 16)"))
  (expect "each length 0 to 16 tried" (= 17 (tries out))))
(let ((l (last (plan (john-read "check/john/hanoi3.john") '((set-opt planner sat) (set-opt sat-conflicts 1)) hanoi-win))))
  (expect "a conflict limit of 1 leaves Hanoi3 unknown"
	  (and (= "unknown at " (string-copy l 0 11)) (has? l " steps (conflict limit 1)"))))
;; the bit-vector gates on every pair of 4-bit numbers: inputs known, the gates fold to the answer
(define-function bv-value (c bits)	; known bits as a number, or ()
  (let ((n 0) (p 1) (last ()) (ok 1))
    (list-do b bits (cond ((= b (cnf-true c)) (set n (+ n p)) (set last 1)) ((= b (- (cnf-true c))) (set last ())) (else (set ok ()))) (set p (* p 2)))
    (and ok (if last (- n p) n))))
(let ((c (cnf-new)) (good 1))
  (for (a -8 8)
    (for (b -8 8)
      (let ((x (cnf-bv-const c a 4)) (y (cnf-bv-const c b 4)))
	(list-do op (list (list cnf-bv-add +) (list cnf-bv-sub -) (list cnf-bv-mul *) (list cnf-bv-div /))
	  (let* ((r ((car op) c x y)) (exact (if (and (= (cadr op) /) (= b 0)) () ((cadr op) a b))) (fits (and exact (<= -8 exact) (< exact 8))))
	    (or (if fits (and (= (cdr r) (- (cnf-true c))) (= exact (bv-value c (car r)))) (= (cdr r) (cnf-true c)))
		(let () (set good ()) (println "FAIL bits " a " " b " -> " (bv-value c (car r)))))))
	(or (and (= (cnf-bv-lt c x y) (if (< a b) (cnf-true c) (- (cnf-true c)))) (= (cnf-bv-eq c x y) (if (= a b) (cnf-true c) (- (cnf-true c)))))
	    (set good ())))))
  (expect "add, sub, mul, div, lt, eq on every pair of 4-bit numbers, an overflow or a zero divisor flagged" good))
;; numbers: two's complement circuits, a step whose result doesn't fit impossible
(expect "the maze by sat in 6" (equal "satisfied at time: 6" (time-line (by-sat (john-read "check/john/maze.john") '(satisfy R reach () () ())))))
(define nim "create Game pile turn. create Player opponent. make Player White Black. make Player Black White.
  action Player take1 consequence G pile = G pile - 1 and G turn = its opponent.
  rule Player take1 is G turn = it. rule Player take1 is G pile >= 1.
  action Player take2 consequence G pile = G pile - 2 and G turn = its opponent.
  rule Player take2 is G turn = it. rule Player take2 is G pile >= 2.
  goal Player win try G pile = 0 and G turn = its opponent. ")
(both-agree "Nim from 3" (john-read-text (concat-string nim "make Game G 3 White.")) '(satisfy White win () () ()))
(both-agree "Nim from 4" (john-read-text (concat-string nim "make Game G 4 White.")) '(satisfy White win () () ()))
(expect "Nim from 4 by sat at 3" (equal "satisfied at time: 3" (time-line (by-sat (john-read-text (concat-string nim "make Game G 4 White.")) '(satisfy White win () () ())))))
(define counter "create C n. make C X 32760. action C up consequence it n = its n + 10. goal C done try its n > 32767. ")
(expect "an add past sat-width is an impossible step, never a wrap"
	(equal "unsatisfiable within 16 steps (width 16, lists 16, unroll 16)" (last (by-sat (john-read-text counter) '(satisfy X done () () ())))))
(expect "the same add under sat-width 17"
	(equal "satisfied at time: 1" (time-line (plan (john-read-text counter) '((set-opt planner sat) (set-opt sat-width 17)) '(satisfy X done () () ())))))
(expect "division by zero is an impossible step"
	(has? (last (by-sat (john-read-text "create C n d f. make C X 4 0 no. action C bump consequence it n = its n + 1.
				  action C cut consequence it n = its n / its d and it f = yes. goal C done try its f = yes. ")
			    '(satisfy X done () () ())))
	      "unsatisfiable within 16 steps"))
(and ok (println "sat john ok"))
