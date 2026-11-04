;;; ./eval notes/plan/record.l [full]: asks the checks in the plan, appends what they answered about this code, and shows the plan.
(define full-record (and *arguments* (= "full" (car *arguments*))))
(set *arguments* ())
(require "notes/plan/plan-world.l")
;; the answers are written together, and only if the code they were asked about is still the code
(define answers ())
(list-do check (john-instances 'Check)
  (when (or full-record (plan-yes? check 'routine))
    (let ((answer (plan-ask check 'observe)))
      (push answers (cons check answer))
      (println (if (= answer 'yes) "PASS " "FAIL ") check
	       (if (= answer 'yes) "" (concat-strings " (" probe-logs (symbol->string check) ".log)"))))))
(or (= plan-tree (plan-tree-now))
    (error "the code changed during this run, so none of its answers are recorded"))
(list-do a (list-reverse! answers)
  (system (concat-strings "echo '" (symbol->string (car a)) " do " (if (= (cdr a) 'yes) "passed" "failed")
			  " \"" plan-tree "\".' >> notes/plan/evidence.john")))
(system "./eval notes/plan/next.l")
