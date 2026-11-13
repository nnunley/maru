;; R-plan-heuristics, R-stale-ranks, R-lanes: every step a plan allows now, scored by its heuristics, its lane's first
(require "check/temp.l")
(require "recover.l")
(require "notes/plan/frontier.l")
(define ok 1)
(define-function expect (what good) (or good (let () (println "FAIL " what) (set ok ()))))
(define fixtures "check/plan/frontier")
(define-function steps (entries) (map (lambda (e) (list (car e) (cadr e) (caddr e))) entries))

(expect "lane alpha: alpha's steps, regressing, failing, aging, untried, then the other plans', by name"
	(equal (steps (lane-frontier fixtures "alpha" "aaa"))
	       '(("alpha" "T build R" 10000) ("alpha" "T build F" 1000) ("alpha" "T build A" 100) ("alpha" "T build U" 10)
		 ("beta" "T build B" 10))))
(expect "lane beta puts beta's first"
	(equal (car (steps (lane-frontier fixtures "beta" "aaa"))) '("beta" "T build B" 10)))
(expect "every answer about older code: still a frontier, each answered capability aging, ties in the plan's order"
	(equal (steps (lane-frontier fixtures "alpha" "zzz"))
	       '(("alpha" "T build A" 100) ("alpha" "T build F" 100) ("alpha" "T build R" 100) ("alpha" "T build U" 10)
		 ("beta" "T build B" 10) ("done" "T build D" 100))))
(expect "a plan all done gives no step"
	(not (plan-frontier fixtures "done" "aaa")))
(expect "a lane no plan has"
	(equal (try (let () (lane-frontier fixtures "nope" "aaa") "answered") (lambda (c) (plan-condition-text c)))
	       "E_UNKNOWN_LANE: nope (plans: alpha, beta, done)"))
(define lines (frontier-lines fixtures "alpha" "aaa"))
(expect "a plan's skipped lines are said first" (= "skipped 1 events about retired: gone (alpha)" (car lines)))
(expect "the next step, its plan and score" (= "next: alpha: T build R  score 10000" (cadr lines)))
(expect "then the rest" (= "then: alpha: T build F  score 1000" (caddr lines)))
(define done-dir (concat-string check-tmp "/done"))
((subr "system" "s>i") (concat-strings "rm -rf " done-dir " && mkdir -p " done-dir " && cp " fixtures "/done.* " done-dir "/"))
(expect "nothing left anywhere" (equal (frontier-lines done-dir "done" "aaa") '("nothing left to build")))
(expect "next.l with a lane no plan has fails, naming the plans"
	(= 0 ((subr "system" "s>i")
	      "./eval notes/plan/next.l --lane nope 2>&1 | grep -q 'E_UNKNOWN_LANE: nope (plans: ksworld, render, tree-matching)'")))
(if ok (println "plan frontier ok") (exit 1))
