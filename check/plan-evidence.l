;;; A law's verdict, from check/law.l's text to a value John holds, through the ledger's own language, and what the plan makes of it.
(require "john-eval.l")
(require "check/temp.l")
(define system (subr "system" "s>i"))
(define events-file (concat-string check-tmp "/plan-evidence.events"))
(system (concat-strings "./eval notes/plan/law-events.l abc check/laws/fixtures/report.txt > " events-file))
(define events (contents-of-file-named events-file))
(define-function expect (what ok) (or ok (let () (println "FAIL " what) (exit 1))))
(define evidence-set
  "set Evidence = untested | passed(tree) | failed(tree) | tested(tree, trials) | proved(tree, cases) | refuted(tree, counterexample) | starved(tree, met, drawn) | vacuous(tree) | inconclusive(tree, input).
create Code tree. make Code Now \"abc\".
create Law evidence.
make Law a_b untested. make Law c untested. make Law d untested. make Law e untested. make Law f untested. make Law g untested. make Law h untested. make Law never untested.
action Law observed Answer consequence its evidence = Answer.
group Good passed tested proved.
qualify Law holds if its evidence is Good and its evidence tree = Now tree.
")
(john-run (john-read-text (concat-string evidence-set events)))
(define-function ask (object message) (john-eval `(send ,object ,message) *john-world* ()))
(define-function holds? (law) (= 'yes (ask law 'holds)))
(expect "tested and proved hold" (and (holds? 'a_b) (holds? 'c)))
(expect "nothing else does"
	(not (or (holds? 'd) (holds? 'e) (holds? 'f) (holds? 'g) (holds? 'h) (holds? 'never))))
(expect "each verdict is its kind"
	(equal '(tested proved refuted starved vacuous inconclusive failed)
	       (map (lambda (l) (ask (ask l 'evidence) 'kind)) '(a_b c d e f g h))))
(expect "a count reads back as a number" (= 100 (ask (ask 'a_b 'evidence) 'trials)))
(expect "a counterexample with quotes reads back whole"
	(equal "x=\"p\\\"q\" y=3 seed=42" (ask (ask 'd 'evidence) 'counterexample)))
(expect "the counts of a starved law read back" (= 2000 (ask (ask 'e 'evidence) 'drawn)))
(expect "a verdict about other code doesn't hold"
	(let ()
	  (john-statement '(do a_b observed (variant tested (tree: "old") (trials: 5))))
	  (not (holds? 'a_b))))
(println "plan evidence ok")
