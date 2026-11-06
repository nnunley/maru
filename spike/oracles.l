;;; THROWAWAY SPIKE.  Stronger oracles for the model strategy.  The goal says what's wanted; these say what a solution must also be.
;;; A model's plan has to pass them, so a strategy can hold it to more than the program's goal does.
(require "spike/john-model.l")
(define-function goal-holds? (w o g args)
  (let ((goal (john-goal-of o g)))
    (john-true? (john-eval (cadddr goal) w (john-bind (caddr goal) args (list (cons 'it o)))))))
(define-function plan-length (w start) (- (<john-world>-time w) (<john-world>-time start)))
;; a condition written in John: a qualification of the goal's object, read in the world the plan reached.  It may read the plan's
;; own history, with at time and did, which is more than a goal about the end state can ask
(define-function oracle-qualification (name)
  (lambda (w start o g args using)
    (and (not (john-true? (john-eval (list 'send o name) w ())))
	 (concat-strings "the plan reaches the goal, but " (john-text o) " " (symbol->string name) " doesn't hold at its end"))))
;; no shorter plan, by looking at every shorter one.  Too many to look at is no answer, and no answer is a refusal
(define *oracle-world-budget* 50000)
(define-function oracle-shortest-by-search ()
  (lambda (w start o g args using)
    (let ((n (plan-length w start)) (frontier (list start)) (depth 0) (found ()) (looked 0) (over ()))
      (while (and (< depth n) frontier (not found) (not over))
	(list-do x frontier (and (not found) (goal-holds? x o g args) (set found depth)))
	(or found
	    (let ((next ()))
	      (list-do x frontier
		(list-do c (john-expand x o g using ())
		  (push next c)
		  (set looked (+ looked 1))))
	      (and (> looked *oracle-world-budget*) (set over 1))
	      (set frontier next)
	      (set depth (+ depth 1)))))
      (cond
	(over (concat-strings "couldn't tell whether a plan shorter than " (long->string n) " moves exists"))
	(found (concat-strings "the plan works, but one of " (long->string found) " moves exists and yours has " (long->string n)))
	(else ())))))
;; no shorter plan, by the solver: each shorter length refuted with a checked DRAT proof.  Stronger than the search, as it scales and
;; its refutations are checked, though only for what the encoding covers
(define-function line-with (lines text) (let ((r ())) (list-do l lines (and (text-find l text 0) (set r l))) r))
(define-function oracle-shortest-by-sat ()
  (lambda (w start o g args using)
    (require "john-sat.l")
    (let ((n (plan-length w start)) (saved-out *john-out*) (result ()))
      (set *john-world* start)
      (set *john-out* ())
      (john-sat-satisfy o g args using ())
      (set result (line-with *john-out* "satisfied at time: "))
      (set *john-world* start)
      (set *john-out* saved-out)
      (if (not result)
	  "the solver couldn't say what the shortest plan is"
	(let ((k (- (string->long (string-from result 19 (string-length result))) (<john-world>-time start))))
	  (and (< k n)
	       (concat-strings "the plan works, but one of " (long->string k) " moves exists and yours has " (long->string n))))))))
;; a check written in Maru, on the world reached: the allocator's slot-by-slot test, which its goal doesn't ask
(define-function oracle-world-check (name check)
  (lambda (w start o g args using)
    (set *john-world* w)
    (let ((ok (check)))
      (set *john-world* start)
      (and (not ok) (concat-strings "the plan reaches the goal, but fails " name)))))
