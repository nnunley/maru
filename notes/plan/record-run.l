;;; ./eval notes/plan/record-run.l [RESULTS [DIR]]: what a check run answered, as worlds of each plan's chain
;;; (doc/rfc/draft-ndn-maru-john-development-00.md, R-run-records, R-ledger-dedupe, R-retired).
;;;
;;; RESULTS is the run's results file (check/results.l), the one check/parallel.l left if not given; DIR holds the plans,
;;; notes/plan if not given.  For each plan: its ledger less the lines of names retired MARU_RETIRE_AFTER commits ago
;;; (20), then each case the plan declares observed as the run answered it, a step of the plan, and WholeSuite passed if
;;; the run was complete and nothing failed; the ledger deduplicated.  MARU_RECORD=0 records nothing.
(define record-args *arguments*)
(set *arguments* ())
(require "check/temp.l")
(require "check/results.l")
(require "recover.l")
(require "notes/plan/plan-load.l")
(define probe-logs (concat-strings "/tmp/maru-plan/" (checkout-name) "/"))	; for plans that load probes.l, which
(define plan-tree ())	; names both; plan-tree is the results' tree
(define record-results (or (car record-args) (concat-string check-tmp "/results")))
(define record-dir (or (cadr record-args) "notes/plan"))
(define retire-after (let ((v (env-var "MARU_RETIRE_AFTER"))) (if v (string->long v) 20)))

;; how many commits on this branch since the first that retired name in path's plan; 0 if none has
(define-function retired-commits (path name)
  (let ((first (car (plan-file-lines-of-command
		     (concat-strings "git log --reverse --format=%H -S 'retired " (symbol->string name) ".' -- " path " 2>/dev/null")))))
    (if (and first (< 0 (string-length first)))
	(string->long (car (plan-file-lines-of-command (concat-strings "git rev-list --count " first "..HEAD"))))
      0)))
(define-function retired-old (path)	; the names retired at least retire-after commits ago
  (let ((out ())) (list-do n *john-retired* (and (<= retire-after (retired-commits path n)) (push out n))) out))
(define-function names-any? (form names)
  (let ((hit ()))
    (list-do x (if (= 'world (car form)) (concat-list (cadr form) (map car (caddr form))) (list (caddr form)))
      (and (member? x names) (set hit 1)))
    hit))

(define-function record-plan (name tree complete outcomes)
  (let ((plan (concat-strings record-dir "/" name ".john")) (ledger (plan-ledger-path record-dir name)))
    (john-run (john-read plan))
    (let ((old (retired-old plan)) (forms (plan-ledger-forms record-dir name)))
      (when old
	(let ((kept ())) (list-do f forms (or (names-any? f old) (push kept f))) (set kept (list-reverse! kept))
	  (or (equal kept forms) (plan-write-forms ledger kept)))))
    (plan-load record-dir name tree)
    (let ((from (<john-world>-time *john-world*)) (all-passed 1)
	  (answer (lambda (ok) (john-make-variant (if ok 'passed 'failed) (list (list 'tree: tree)) *john-world* ()))))
      (list-do o outcomes
	(or (cdr o) (set all-passed ()))
	(let ((c (string->symbol (car o))))
	  (and (john-object? c) (not (member? c *john-retired*)) (john-isa? (john-object-class c) 'Case)
	       (john-do c 'observed (list (answer (cdr o)))))))
      (and complete all-passed (john-object? 'WholeSuite) (john-do 'WholeSuite 'observed (list (answer 1))))
      (plan-append record-dir name from))))

(cond ((= "0" (env-var "MARU_RECORD")))
      ((not (= 0 ((subr "access" "si>i") record-results 4))) (println "no results: nothing recorded"))
      (else
       (let* ((r (results-read record-results)) (tree (car r)))
	 (set plan-tree tree)
	 (list-do name (plan-names record-dir)
	   (try-call (lambda () (record-plan name tree (cadr r) (caddr r)))
		      (lambda (c) (println "evidence for " name " not recorded: " (plan-condition-text c))))))))
