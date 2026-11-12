;;; The plan and its evidence, replayed to a chain of worlds; what's asked of them, read through John's own evaluator.
;;; Now is the code as it stands, so what was recorded against other code doesn't count.
(require "john-eval.l")
(require "check/temp.l")
(define probe-logs (concat-strings "/tmp/maru-plan/" (checkout-name) "/"))	; two checkouts mustn't read each other's reports
(require "spawn.l")
(define getpid (subr "getpid" ">i"))
;; what notes/plan/tree-hash says, or an error: without it no answer can be tied to any code
(define-function plan-tree-now ()
  (let* ((file (concat-strings probe-logs "tree-" (long->string (getpid))))
	 (status (and (= 0 (make-directory probe-logs)) (program-status '("notes/plan/tree-hash") () file)))
	 (text (if (exists? file) (contents-of-file-named file) "")))
    ((subr "unlink" "s>i") file)
    (or (and (= 0 status) (= 13 (string-length text))) (error "notes/plan/tree-hash gave no hash"))
    (string-copy text 0 12)))
(define plan-tree (plan-tree-now))
;; which plan: MARU_PLAN names notes/plan/NAME.john, tree-matching if unset; each keeps its evidence apart
(define plan-name (or (env-var "MARU_PLAN") "tree-matching"))
(define plan-evidence-file
  (if (= plan-name "tree-matching") "notes/plan/evidence.john" (concat-strings "notes/plan/" plan-name "-evidence.john")))
(or (= 0 ((subr "access" "si>i") plan-evidence-file 4)) (contents-to-file-named "" plan-evidence-file))	; as touch makes it
(define plan-evidence (john-read plan-evidence-file))
(john-run (concat-list (john-read (concat-strings "notes/plan/" plan-name ".john"))
		       (cons (list 'make 'Code 'Now plan-tree) plan-evidence)))
(define-function plan-ask (object message . args)
  (john-eval `(send ,object ,message ,@args) *john-world* ()))
(define-function plan-yes? (object message . args)
  (= 'yes (john-eval `(send ,object ,message ,@args) *john-world* ())))
