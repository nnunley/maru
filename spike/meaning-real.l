;;; THROWAWAY SPIKE.  Call by meaning with the real model.  Public text only.  Each run is in a child, since John ends a run that finds nothing.
(require "spike/meaning.l")
(define world "
create Converter spec factor.
make Converter C7 \"converts minutes to seconds\" 100.
make Converter C2 \"multiplies a count of minutes by sixty, giving seconds\" 60.
make Converter C9 \"turns kilograms into grams\" 1000.
qualify Converter convert: N is it factor * N.
qualify Converter minutes-to-seconds if it convert: 2 = 120 and it convert: 5 = 300.
")
(define fork (subr "fork" ">i"))  (define waitpid (subr "waitpid" "ipi>i"))  (define quit (subr "_exit" "i"))
(define status ((subr "malloc" "l>p") 8))
(define-function run (label statements)
  (let ((pid (fork)))
    (if (= 0 pid)
	(let ()
	  (set *john-replica* (replica-new 'a))
	  (let ((out (john-run (concat-list (john-read-text world) (john-read-text statements)))))
	    (println "--- " label ": " *llm-calls* " calls")
	    (list-do l out (println "  " l))
	    (list-do op (<replica>-ops *john-replica*)
	      (println "  asked, answered: " (op-value op))))
	  (quit 0))
      (waitpid pid status 0))))
(run "find, where the best-named spec lies" "\"converts minutes to seconds\" find-passing: \"minutes-to-seconds\".")
(run "adapt: Fahrenheit" "\"Fahrenheit from Celsius\" adapt: [ [ 100, 212 ], [ 0, 32 ], [ 40, 104 ], [ -40, -40 ] ]. 25 apply-adapter: \"Fahrenheit from Celsius\".")
(run "adapt: whole hours from seconds" "\"whole hours from a count of seconds\" adapt: [ [ 3600, 1 ], [ 7199, 1 ], [ 0, 0 ], [ 36000, 10 ] ]. 86399 apply-adapter: \"whole hours from a count of seconds\".")
(run "adapt: the paper's wall-clock seconds" "\"the seconds hand of a wall clock, from Unix time\" adapt: [ [ 1394916307, 7 ], [ 60, 0 ], [ 61, 1 ], [ 119, 59 ] ].")
