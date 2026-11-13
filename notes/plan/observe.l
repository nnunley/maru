;;; ./eval notes/plan/observe.l [full]: asks the plan's checks, each answer a step of the plan (Check observed Answer),
;;; and appends the steps to its ledger, all of them or, if the code changed under them, none: that's an error.  A case
;;; whose answer for this code the ledger already holds (make check records them) isn't asked again.  What it's doing
;;; goes to stderr.
(define full-record (and *arguments* (= "full" (car *arguments*))))
(or (not *arguments*) full-record (error "the one argument is full, not " (car *arguments*)))
(set *arguments* ())
(require "notes/plan/plan-world.l")
(define write (subr "write" "isl>l"))
(define-function progress (text) (write 2 text (string-length text)))
(require "notes/plan/event-text.l")
(define-method event-text <symbol> () (symbol->string self))
(define-method event-text <john-variant> ()
  (let ((s (concat-string (symbol->string self.kind) "(")) (first 1))
    (list-do f self.fields
      (set s (concat-strings s (if first "" ", ") (symbol->string (car f)) ": " (event-text (cdr f))))
      (set first ()))
    (concat-string s ")")))
(define-function plan-answer (check)	; only Evidence goes in the ledger
  (let ((answer (plan-ask check 'observe)))
    (or (= <john-variant> (type-of answer))
	(error check " answered " (john-text answer) ", which isn't Evidence"))
    answer))
(define from (<john-world>-time *john-world*))
(define-function answered-now? (check)	; a case make check has answered about this code
  (let* ((e (plan-ask check 'evidence)) (tree (and (= <john-variant> (type-of e)) (assq 'tree (<john-variant>-fields e)))))
    (and (john-isa? (john-object-class check) 'Case) tree (= plan-tree (cdr tree)))))
(list-do check (john-instances 'Check)
  (when (and (or full-record (plan-yes? check 'routine)) (not (answered-now? check)))
    (let ((answer (plan-answer check)))
      (progress (concat-strings (symbol->string check) ": " (event-text answer) "\n"))
      (john-do check 'observed (list answer)))))
(or (= plan-tree (plan-tree-now))
    (error "the code changed during this run, so none of its answers are recorded"))
(plan-append "notes/plan" plan-name from)
(println plan-evidence-file ": " (long->string (- (<john-world>-time *john-world*) from)) " answers recorded")
