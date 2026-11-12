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
(define evaluators '(("eval" "./eval") ("eval2" "./eval2" "-b" "boot2.l") ("eval3" "./eval3" "-b" "boot2.l")))
(define laws '(("gc" "check/laws/gc-reference.l" "check/laws/gc.law" 40)
	       ("model" "check/laws/gc-model.l" "check/laws/gc-model.law" 300)
	       ("engine" "check/laws/engine.l" "check/laws/engine.law" 300)))
(define start (jobs-time))
(define dir (concat-strings check-tmp "/sweep"))
(command-status (make <command> argv: (list "rm" "-rf" dir)))
(command-status (make <command> argv: (list "mkdir" "-p" dir)))
(define entries ())
;; runtime.law's laws are all by exhaustion, so no seed changes them: they run once on each evaluator, through the driver
;; built here as check.l's nile_laws builds it, each run with a directory of its own for the driver's input and output
(define root ((subr "getcwd" "pl>s") ((subr "malloc" "l>p") 4096) 4096))
(define nile (concat-strings root "/nile/runtimes/maru/"))
(define runtime-bin (concat-strings dir "/law-runtime"))
(define-function sweep-step (argv . fields)	; argv run to its end, or the sweep stops: out, then dir, if given
  (let ((a argv) (o (car fields)) (d (cadr fields)))
    (or (= 0 (command-status (make <command> argv: a out: o dir: d))) (error "sweep: can't build " runtime-bin ": " argv))))
(let ((files (map (lambda (f) (concat-strings nile f))
		  '("nile.k" "nile-sync.k" "nile-heap.k" "nile-deque.k" "nile-thread.k" "nile-process.k" "nile-kernel.k" "nile-builtins.k"))))
  (sweep-step (list (concat-strings root "/nile/compilers/maru/nile-to-maru-compiler.sh") "text_layout"
		    (concat-strings root "/nile/examples/text-layout.nl"))
	      "/dev/null" dir)
  (sweep-step (list "./eval" "compile-osdefs.l" (concat-strings nile "nile.osdefs")) (concat-strings dir "/nile.osdefs.c"))
  (sweep-step (list "cc" "-o" (concat-strings dir "/nile.osdefs") (concat-strings dir "/nile.osdefs.c")))
  (sweep-step (list (concat-strings dir "/nile.osdefs")) (concat-strings dir "/nile.osdefs.k"))
  (sweep-step (concat-list (concat-list (list "./eval2" "ir-gen-c.k" "maru.k" (concat-strings dir "/nile.osdefs.k")) files)
			   (list (concat-strings dir "/text_layout.k") (concat-strings nile "test/reroute-kernels.k")
				 (concat-strings nile "test/law-runtime.k")))
	      (concat-strings runtime-bin ".c"))
  (sweep-step (list "cc" "-pthread" "-fno-builtin" "-w" "-o" runtime-bin (concat-strings runtime-bin ".c"))))
(list-do evaluator evaluators
  (let ((own (concat-strings dir "/runtime-" (car evaluator) ".tmp")))
    (command-status (make <command> argv: (list "mkdir" "-p" own)))
    (push entries
	  (cons (concat-strings "runtime-" (car evaluator))
		(let ((a (concat-list (cdr evaluator) '("check/law.l" "check/laws/runtime.l" "check/laws/runtime.law")))
		      (e (list (cons "NILE_LAW_RUNTIME" runtime-bin) (cons "NILE_LAW_TMP" own))))
		  (make <command> argv: a env: e))))))
(for (i 0 count)
  (let ((seed (+ start (* i 1000))))
    (println "seed " seed)
    (list-do evaluator evaluators
      (list-do law laws
	(push entries
	      (cons (concat-strings (car law) "-" (car evaluator) "-" (long->string seed))
		    (let ((a (concat-list (cdr evaluator) (list "check/law.l" (cadr law) (caddr law))))
			  (e (list (cons "MARU_LAW_SEED" (long->string seed)) (cons "MARU_LAW_TRIALS" (long->string (cadddr law))))))
		      (make <command> argv: a env: e))))))))
(define runs (list-length entries))
(define failed (run-jobs jobs dir (list-reverse! entries)))
(if failed
    (let ()
      (println "failed: " failed)
      (jobs-exit 1))
  (println "sweep passed: " count " seeds, " runs " runs"))
