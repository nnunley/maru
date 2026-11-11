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
make Law a_b untested. make Law c untested. make Law d untested. make Law e untested. make Law f untested. make Law g untested. make Law h untested. make Law i untested. make Law j untested. make Law never untested.
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
(expect "classes after a count are optional, and a law short of its cover failed"
	(and (holds? 'i) (= 1000 (ask (ask 'i 'evidence) 'trials)) (not (holds? 'j)) (= 'failed (ask (ask 'j 'evidence) 'kind))))
(expect "a count reads back as a number" (= 100 (ask (ask 'a_b 'evidence) 'trials)))
(expect "a counterexample with quotes reads back whole"
	(equal "x=\"p\\\"q\" y=3 seed=42" (ask (ask 'd 'evidence) 'counterexample)))
(expect "the counts of a starved law read back" (= 2000 (ask (ask 'e 'evidence) 'drawn)))
(expect "a verdict about other code doesn't hold"
	(let ()
	  (john-statement '(do a_b observed (variant tested (tree: "old") (trials: 5))))
	  (not (holds? 'a_b))))
;; a plan and its ledger, read as plan-load reads them (notes/plan/plan-load.l): a check's state from its latest answer and,
;; for regressed, the answer before it
(require "recover.l")
(require "notes/plan/plan-load.l")
(require "check/case-names.l")
(define-function states (dir name tree)
  (plan-load dir name tree)
  (map (lambda (c) (map (lambda (q) (plan-ask c q)) '(holds failing regressed stale untested))) '(one other fixed bad none)))
;;                         holds failing regressed stale untested
(expect "on the tree the answers name: one and fixed hold, other regressed, bad failing, none untested"
	(equal (states "check/plan" "x" "aaa")
	       '((yes no no no no) (no yes yes no no) (yes no no no no) (no yes no no no) (no no no no yes))))
(expect "on a tree none names, every answered check is stale"
	(equal (states "check/plan" "x" "ccc")
	       '((no no no yes no) (no no no yes no) (no no no yes no) (no no no yes no) (no no no no yes))))
(define scratch (concat-string check-tmp "/plan-evidence-plans"))
(system (concat-strings "rm -rf " scratch " && mkdir -p " scratch " && cp check/plan/x.john " scratch "/"))
(define-function ledger (name lines)
  (let ((f ((subr "fopen" "ss>p") (concat-strings scratch "/" name ".answers") "w")))
    (list-do l lines ((subr "fputs" "sp>i") (concat-string l "\n") f))
    ((subr "fclose" "p>i") f)))
(define x-lines (plan-file-lines "check/plan/x.answers"))
(system (concat-strings "cp check/plan/x.john " scratch "/y.john"))
(ledger "y" (list-reverse! (plan-file-lines "check/plan/x.answers")))
(expect "the latest answer decides: in the other order, other is stale and fixed regressed"
	(equal (states scratch "y" "aaa")
	       '((yes no no no no) (no no no yes no) (no yes yes no no) (no yes no no no) (no no no no yes))))
(system (concat-strings "cp check/plan/x.john " scratch "/z.john"))
(ledger "z" (concat-list x-lines '("(world (gone observed (value passed (tree \"aaa\"))) ((gone evidence (value passed (tree \"aaa\")))))")))
(expect "a line naming a check the plan no longer has fails, naming the ledger and the line"
	(equal (try (let () (plan-load scratch "z" "aaa") "loaded") (lambda (c) (plan-condition-text c)))
	       (concat-string scratch "/z.answers: ledger 7: unknown object gone")))
(system (concat-strings "echo 'retired gone.' >> " scratch "/z.john"))
(expect "once the plan retires it, the line is skipped and the states are as before"
	(equal (states scratch "z" "aaa") (states "check/plan" "x" "aaa")))
;; every case a plan names is a case check/check.l has
(let ((known (case-names)))
  (list-do plan (plan-names "notes/plan")
    (list-do s (john-read (concat-strings "notes/plan/" plan ".john"))
      (and (= 'make (car s)) (= 'Case (cadr s))
	   (or (member? (symbol->string (caddr s)) known)
	       (expect (concat-strings "plan " plan " names no case " (symbol->string (caddr s))) ()))))))
(println "plan evidence ok")
