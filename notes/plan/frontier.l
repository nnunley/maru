;;; The frontier: every step the plans allow now, each scored by its plan's heuristics, best first; a lane's plan first
;;; (doc/rfc/draft-ndn-maru-john-development-00.md, R-plan-heuristics, R-stale-ranks, R-lanes).
;;;
;;;   (plan-frontier dir name tree)   ((step-text . score) ...): what Team T may do to deliver, best first
;;;   (lane-frontier dir lane tree)   ((plan step-text score) ...): lane's plan first, then the others by name
;;;   (frontier-lines dir lane tree)  what next.l prints: skipped lines, then next: and then: lines, or nothing left
(require "notes/plan/plan-load.l")
(define *frontier-skipped* ())	; ((plan . ((name . count) ...)) ...) of the last lane-frontier

(define-function plan-frontier (dir name tree)
  (plan-load dir name tree)
  (and (john-object? 'T)
       (map (lambda (c) (cons (john-step-text (<john-world>-action (car c))) (cdr c)))
	    (john-choices 'T 'deliver))))

(define-function frontier-join (names)
  (let ((s "") (first 1))
    (list-do n names (set s (concat-strings s (if first "" ", ") n)) (set first ()))
    s))

;; a directory's plans, read once: an error naming them passes them as made here, since a try undoes what its body made
(define *frontier-plans* ())
(define-function frontier-plans (dir)
  (let ((e ()))
    (list-do p *frontier-plans* (and (= dir (car p)) (set e p)))
    (if e (cdr e) (let ((names (plan-names dir))) (push *frontier-plans* (cons dir names)) names))))
(define-function lane-frontier (dir lane tree)
  (let ((names (frontier-plans dir)) (out ()))
    (or (member? lane names)
	(let ((parts ()) (first 1))
	  (list-do n names (or first (push parts ", ")) (push parts n) (set first ()))
	  (apply error (concat-list (list "E_UNKNOWN_LANE: " lane " (plans: ") (concat-list (list-reverse! parts) (list ")"))))))
    (set *frontier-skipped* ())
    (list-do name (cons lane (let ((rest ())) (list-do n names (or (= n lane) (push rest n))) (list-reverse! rest)))
      (list-do e (plan-frontier dir name tree) (push out (list name (car e) (cdr e))))
      (and (john-skipped) (push *frontier-skipped* (cons name (john-skipped)))))
    (set *frontier-skipped* (list-reverse! *frontier-skipped*))
    (list-reverse! out)))

(define-function frontier-line (word e)
  (concat-strings word (car e) ": " (cadr e) "  score " (long->string (caddr e))))
(define-function frontier-lines (dir lane tree)
  (let ((entries (lane-frontier dir lane tree)) (out ()))
    (list-do p *frontier-skipped*
      (let ((n 0) (names ()))
	(list-do s (cdr p) (set n (+ n (cdr s))) (push names (symbol->string (car s))))
	(push out (concat-strings "skipped " (long->string n) " events about retired: " (frontier-join (list-reverse! names))
				  " (" (car p) ")"))))
    (if (not entries)
	(push out "nothing left to build")
      (push out (frontier-line "next: " (car entries)))
      (list-do e (cdr entries) (push out (frontier-line "then: " e))))
    (list-reverse! out)))
