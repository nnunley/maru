;;; ./eval check/parallel.l [--quick | NAME...]: every case of check/check.l, or those named, or all but the slowest, a few
;;; at a time, each in a process and a directory of its own.  MARU_CHECK_JOBS says how many at once (default 4: other work
;;; shares this machine).  The run fails if any case does, and each failure is named.
(require "check/temp.l")
(require "check/jobs.l")
(define jobs (let ((j (env-var "MARU_CHECK_JOBS"))) (if j (string->long j) 4)))

;; the names of the cases, read from where they're written, in order
(define-function case-names ()
  (let* ((text (contents-of-file-named "check/check.l"))
	 (marker "(check \"")
	 (m (string-length marker))
	 (n (string-length text))
	 (names ())
	 (i 0))
    (while (< i (- n m))
      (if (and (or (= i 0) (= ?\n (string-at text (- i 1))))
	       (= marker (string-copy text i m)))
	  (let ((end (+ i m)))
	    (while (not (= ?\" (string-at text end))) (set end (+ end 1)))
	    (push names (string-copy text (+ i m) (- end (+ i m))))
	    (set i end))
	(set i (+ i 1))))
    (list-reverse! names)))

;; what --quick leaves out: the longest by far, as the slowest line reports them.  Everything runs before a merge.
(define slow-cases '("gc_laws" "gc_model" "asm_rows_x64" "asm_rows_x86" "asm_rows_arm64" "exe" "sat_john" "sat_proof" "recover" "lines"))
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
(define failed
  (run-jobs jobs check-tmp
	    (map (lambda (name)
		   (cons name (concat-strings "MARU_CHECK_TMP=" check-tmp "/" name " exec ./eval check/check.l " name)))
		 names)))
(if failed
    (let ()
      (println "failed: " failed)
      (jobs-exit 1))
  (println "all checks passed"))
