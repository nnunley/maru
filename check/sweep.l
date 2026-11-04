;;; ./eval check/sweep.l [SEEDS]: the generated laws on fresh seeds, more trials, and every evaluator: the search for new
;;; corner cases, where make check is a repeatable gate.  A failure names the seed; rerun it with MARU_LAW_SEED set.
;;; MARU_CHECK_JOBS says how many at once (default 4).
(require "check/temp.l")
(require "check/jobs.l")
(define jobs (let ((j (env-var "MARU_CHECK_JOBS"))) (if j (string->long j) 4)))
(define count (if *arguments* (string->long (car *arguments*)) 6))
(set *arguments* ())
(define evaluators '(("eval" . "./eval") ("eval2" . "./eval2 -b boot2.l") ("eval3" . "./eval3 -b boot2.l")))
(define laws '(("gc" "check/laws/gc-reference.l" "check/laws/gc.law" 40)
	       ("model" "check/laws/gc-model.l" "check/laws/gc-model.law" 300)
	       ("engine" "check/laws/engine.l" "check/laws/engine.law" 300)))
(define start (jobs-time))
(define dir (concat-strings check-tmp "/sweep"))
((subr "system" "s>i") (concat-strings "rm -rf " dir " && mkdir -p " dir))
(define entries ())
(for (i 0 count)
  (let ((seed (+ start (* i 1000))))
    (println "seed " seed)
    (list-do evaluator evaluators
      (list-do law laws
	(push entries
	      (cons (concat-strings (car law) "-" (car evaluator) "-" (long->string seed))
		    (concat-strings "MARU_LAW_SEED=" (long->string seed)
				    " MARU_LAW_TRIALS=" (long->string (cadddr law))
				    " exec " (cdr evaluator) " check/law.l " (cadr law) " " (caddr law))))))))
(define runs (list-length entries))
(define failed (run-jobs jobs dir (list-reverse! entries)))
(if failed
    (let ()
      (println "failed: " failed)
      (jobs-exit 1))
  (println "sweep passed: " count " seeds, " runs " runs"))
