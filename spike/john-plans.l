;;; THROWAWAY SPIKE.  A plan is hypothetical until it's published: its moves become shared events, and the chain runs them like anyone
;;; else's.  A merge may leave a move impossible (John says so and runs on, the same on every replica) or the goal untrue.  Then the goal's owner
;;; asks for a plan from where things now stand.  Only the owner replans: one owner per goal, and no vote.
(require "spike/oracles.l")
(define-function plan-steps (w start)		; (actor action args...), first move first
  (let ((out ()))
    (while (!= w start)
      (push out (<john-world>-action w))
      (set w (<john-world>-parent w)))
    out))
(define-function step-event-text (st)		; A move Peg2 becomes A do move Peg2.
  (let ((s (concat-strings (john-text (car st)) " do " (john-text (cadr st)))))
    (list-do v (cddr st) (set s (concat-strings s " " (john-text v))))
    (concat-string s ".")))
(define-function chain-publish (c steps)
  (list-do st steps (replica-event (<chain>-replica c) (step-event-text st)))
  (chain-refresh c))
(define-function last-pair (l) (while (cdr l) (set l (cdr l))) l)
(define-function chain-end (c)			; the world the chain ends in
  (let ((a (<chain>-applied c)))
    (if a (cdr (car (last-pair a))) (<chain>-base c))))

;; the owner's loop: answers 'holds, or 'no-plan.  A plan the model found is published only after replay on the chain's real end
(define *pursue-rounds* 3)
(define-function chain-pursue (c o g args using)
  (let ((rounds 0) (state ()))
    (while (not state)
      (chain-refresh c)
      (cond
	((goal-holds? *john-world* o g args) (set state 'holds))
	((>= rounds *pursue-rounds*) (set state 'no-plan))
	(else
	 (set rounds (+ rounds 1))
	 (let* ((start *john-world*) (w (model-plan o g args using)))
	   (if w
	       (chain-publish c (plan-steps w start))
	     (set state 'no-plan))))))
    state))
