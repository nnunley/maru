;;; ./eval notes/plan/next.l: replays the evidence, says what's green, and asks John's planner what's next.
(require "john-eval.l")
(define plan     (john-read "notes/plan/tree-matching.john"))
(define evidence (john-read "notes/plan/evidence.john"))
(define reqs '(Selectors Source Lists Args Interleave Apply Memos Literals Calc Speed Suite))
;; the answers come back in the order they were asked
(define answers
  (john-run (concat-list plan (concat-list evidence (map (lambda (r) (list 'query (list 'send r 'green))) reqs)))))
(define green ())
(let ((rs reqs) (as answers))
  (while rs
    (println (car rs) " " (or (car as) "?"))
    (and (equal (car as) "yes") (push green (car rs)))
    (set rs (cdr rs))
    (set as (cdr as))))
;; The planner sees only real work: evidence decides what's done, and it can't mark anything done
;; by observing it, so the events and green are left out, and each make starts as the evidence says.
(define-function planning (form)
  (cond ((and (= (car form) 'action) (member? (caddr form) '(passed failed))) ())
	((and (= (car form) 'qualify) (= (caddr form) 'green)) ())
	((and (= (car form) 'make) (= (cadr form) 'Req) (member? (caddr form) green))
	 (list (list 'make 'Req (caddr form) (cadddr form) (car (cddddr form)) 'yes)))
	(else (list form))))
(define-function plan-forms (forms)
  (and forms (concat-list (planning (car forms)) (plan-forms (cdr forms)))))
(list-do l (john-run (concat-list (plan-forms plan) (john-read-text "T satisfy ship.")))
  (println l))
