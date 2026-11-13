;;; What John objects can ask of the system.  Each message below is a Maru selector John's objects answer, as
;;; john-eval.l's own builtins are, and the question goes to grammars and programs defined outside the plan.
;;; Only notes/plan/observe.l sends them: the plan's rules read `evidence`, so replaying it or planning never runs one.
;;; Each answers an Evidence value about this code.

(define fork	(subr "fork" ">i"))
(define alarm	(subr "alarm" "i>i"))
(define execl	(subr "execl" "ss.>i"))	; two fixed arguments, the rest variadic
(define waitpid	(subr "waitpid" "ipi>i"))
(define _exit	(subr "_exit" "i"))
(define probe-status (subr "malloc" "l>p"))
(set probe-status (probe-status 8))

;; Run cmd under sh, for at most secs seconds, its output in the log called name; true if it exits 0.
(define-function probe-run (name secs cmd)
  (let ((pid (fork)))
    (when (= 0 pid)
      (alarm secs)
      (execl "/bin/sh" "sh" "-c" (concat-strings "exec </dev/null >" probe-logs name ".log 2>&1; " cmd) 0)
      (_exit 127))
    (and (= pid (waitpid pid probe-status 0))
	 (= 0 (byte-at probe-status 0))
	 (= 0 (byte-at probe-status 1)))))

(define-function probe-evidence (ok)
  (john-make-variant (if ok 'passed 'failed) (list (list 'tree: plan-tree)) *john-world* ()))
(define-function probe-prop (object property) (john-lookup *john-world* object property))
(define-function probe-join (strings)
  (let ((s "")) (list-do x strings (set s (concat-strings s " '" x "'"))) s))

;;; ---- cases in check/check.l.  A run stops at its first failure, so what it didn't show runs alone.

(define *shown-cases* ())
(define *cases-ran* ())
(define-function probe-lines (text)
  (let ((out ()) (start 0) (n (string-length text)))
    (for (i 0 n)
      (when (= ?\n (string-at text i))
	(push out (string-copy text start (- i start)))
	(set start (+ i 1))))
    out))
(define-function probe-collect-shown (name)	; a case that passed printed PASS and its name
  (list-do line (probe-lines (contents-of-file-named (concat-strings probe-logs name ".log")))
    (push *shown-cases* line)))
(define-function probe-case-shown? (case)
  (member? (concat-strings "PASS " (symbol->string case)) *shown-cases*))

(define-john-builtin case-passes john-case-passes)
(define-method john-case-passes <symbol> ()
  (or *cases-ran*
      (let ((names ""))
	(set *cases-ran* 1)
	(list-do c (john-instances 'Case) (set names (concat-strings names " " (symbol->string c))))
	(probe-run "cases" 1800 (concat-strings "MARU_RECORD=0 make check CHECKS='" names "'"))
	(probe-collect-shown "cases")))
  (probe-evidence (or (probe-case-shown? self)
		      (let ((name (symbol->string self)))
			(probe-run name 600 (concat-strings "MARU_RECORD=0 make check CHECKS='" name "'"))))))

;;; ---- a command whose exit status is the answer; what a test suite shows counts for the cases it ran

(define-john-builtin command-succeeds john-command-succeeds)
(define-method john-command-succeeds <symbol> ()
  (let* ((name (symbol->string self)) (ok (probe-run name 1800 (probe-prop self 'command))))
    (probe-collect-shown name)
    (set *cases-ran* 1)	; if a case isn't shown it runs alone
    (probe-evidence ok)))

;;; ---- a grammar: on every evaluator it compiles in process, with what it inherits, and reads its language to the end

(define-function probe-grammar-files (grammar)
  (let ((files ()))
    (list-do parent (probe-prop grammar 'inherits)
      (set files (concat-list files (probe-grammar-files parent))))
    (concat-list files (list (probe-prop grammar 'file)))))

(define-john-builtin compiles-and-reads john-compiles-and-reads)
(define-method john-compiles-and-reads <symbol> ()
  (let ((arguments (concat-strings (probe-join (list (probe-prop self 'host)))
				   (probe-join (probe-grammar-files self)) " --"
				   (probe-join (cons (probe-prop self 'class) (cons (probe-prop self 'rule) (probe-prop self 'samples))))))
	(name (symbol->string self))
	(ok 1))
    (list-do evaluator '("./eval" "./eval2 -b boot2.l" "./eval3 -b boot2.l")
      (and ok (set ok (probe-run name 300 (concat-strings "nice " evaluator " notes/plan/live-grammar.l" arguments)))))
    (probe-evidence ok)))

;;; ---- a law: one run of its file answers for all of them; check/law.l's text is read by a command, law-events.l

(define *law-runs* ())	; (file . events)
(define-function probe-law-run (file)
  (let ((found ())) (list-do r *law-runs* (and (equal file (car r)) (set found r))) found))
(define-function probe-law-events (file support)
  (if (probe-law-run file)
      (cdr (probe-law-run file))
    (let* ((name (concat-strings "law-" (long->string (list-length *law-runs*))))
	   (report (concat-strings probe-logs name ".log"))
	   (events (concat-strings probe-logs name ".events")))
      (probe-run name 1800 (concat-strings "nice ./eval check/law.l " support " " file))
      (probe-run (concat-string name "-events") 60
		 (concat-strings "./eval notes/plan/law-events.l " plan-tree " " report " > " events))
      (let ((read (john-read-text (contents-of-file-named events))))
	(push *law-runs* (cons file read))
	read))))
(define-john-builtin law-verdict john-law-verdict)
(define-method john-law-verdict <symbol> ()
  (let ((answer (probe-evidence ())))
    (list-do e (probe-law-events (probe-prop self 'file) (probe-prop self 'support))
      (and (= self (cadr e)) (set answer (john-eval (cadddr e) *john-world* ()))))
    answer))
