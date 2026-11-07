;;; ./eval check/sweep.l [SEEDS]: the generated laws on fresh seeds, more trials, and every evaluator: the search for new
;;; corner cases, where make check is a repeatable gate.  A failure's run is named law-evaluator-seed; set MARU_LAW_SEED to that
;;; seed to rerun it (a REFUTED line's own seed= has the law's position in the file added).  The laws here are the collector's,
;;; the rule engine's and the Nile runtime's, not an instruction set's, so this keeps to this machine's own evaluators.
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
;; runtime.law's laws are all by exhaustion, so no seed changes them: they run once on each evaluator, through the driver
;; built here as check.l's nile_laws builds it, each run with a directory of its own for the driver's input and output
(define nile "$R/nile/runtimes/maru/")
(define runtime-bin (concat-strings dir "/law-runtime"))
(let ((files ""))
  (list-do f '("nile.k" "nile-sync.k" "nile-heap.k" "nile-deque.k" "nile-thread.k" "nile-process.k" "nile-kernel.k"
	       "nile-builtins.k")
    (set files (concat-strings files " " nile f)))
  (or (= 0 ((subr "system" "s>i")
	    (concat-strings "R=$PWD; cd " dir " && $R/nile/compilers/maru/nile-to-maru-compiler.sh text_layout"
			    " $R/nile/examples/text-layout.nl > /dev/null && cd $R"
			    " && ./eval compile-osdefs.l " nile "nile.osdefs > " dir "/nile.osdefs.c"
			    " && cc -o " dir "/nile.osdefs " dir "/nile.osdefs.c && " dir "/nile.osdefs > " dir "/nile.osdefs.k"
			    " && ./eval2 ir-gen-c.k maru.k " dir "/nile.osdefs.k" files " " dir "/text_layout.k " nile "test/reroute-kernels.k " nile
			    "test/law-runtime.k > " runtime-bin ".c && cc -pthread -fno-builtin -w -o " runtime-bin " " runtime-bin ".c")))
      (error "sweep: can't build " runtime-bin)))
(list-do evaluator evaluators
  (let ((own (concat-strings dir "/runtime-" (car evaluator) ".tmp")))
    (push entries
	  (cons (concat-strings "runtime-" (car evaluator))
		(concat-strings "mkdir -p " own " && exec env NILE_LAW_RUNTIME=" runtime-bin " NILE_LAW_TMP=" own " "
				(cdr evaluator) " check/law.l check/laws/runtime.l check/laws/runtime.law")))))
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
