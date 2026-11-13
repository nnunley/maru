;;; ./eval check/parallel.l [--quick | NAME...]: every case of check/check.l, or those named, or all but the slowest, a few
;;; at a time, each in a process and a directory of its own.  MARU_CHECK_JOBS says how many at once (default 4: other work
;;; shares this machine).  The run fails if any case does, and each failure is named.
(require "check/temp.l")
(require "check/jobs.l")
(require "check/results.l")
(require "check/case-names.l")
(define jobs (let ((j (env-var "MARU_CHECK_JOBS"))) (if j (string->long j) 4)))

;; what --quick leaves out: the longest by far, as the slowest line reports them.  Everything runs before a merge.
(define slow-cases '("gc_laws" "gc_model" "asm_rows_x64" "asm_rows_x86" "asm_rows_arm64" "asm_table" "exe" "sat_john" "sat_proof" "recover" "lines"))
(define *requested* *arguments*)
(set *arguments* ())
(define known (case-names))
(define-function all-but-slow ()
  (let ((out ())) (list-do name known (or (member? name slow-cases) (push out name))) (list-reverse! out)))
(define names
  (if (and *requested* (= "--quick" (car *requested*)))
      (all-but-slow)
    (let ()
      (list-do name *requested*
	(or (member? name known) (let () (println "no check named: " name) (jobs-exit 1))))
      (or *requested* known))))

((subr "system" "s>i") (concat-strings "rm -rf " check-tmp " && mkdir -p " check-tmp))
(define tree-before (tree-hash-now))
(define failed
  (run-jobs jobs check-tmp
	    (map (lambda (name)
		   ;; the laws' expected lines assume their written trials and seeds
		   (cons name (concat-strings "unset MARU_LAW_SEED MARU_LAW_TRIALS; MARU_CHECK_TMP=" check-tmp "/" name
					      " exec ./eval check/check.l " name)))
		 names)))
;; what the evidence is made from: complete only when every case was asked for
(results-write check-tmp tree-before (tree-hash-now) (not *requested*) (list-reverse! *jobs-outcomes*))
;; and recorded in each plan's ledger (notes/plan/record-run.l, which MARU_RECORD=0 stops); a ledger that can't be written
;; is reported, and the run's outcome is the cases'
(or (= 0 ((subr "system" "s>i") "./eval notes/plan/record-run.l")) (println "evidence not recorded"))
(if failed
    (let ()
      (println "failed: " failed)
      (jobs-exit 1))
  (println "all checks passed"))
