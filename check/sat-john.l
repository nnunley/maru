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
(and ok (println "sat john ok"))
