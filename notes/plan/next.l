;;; ./eval notes/plan/next.l: replays the evidence as a chain of worlds, says what's done in the newest,
;;; and plans on from there.  The plan's answer starts with the evidence, the world chain's own history.
(require "john-eval.l")
(define plan     (john-read "notes/plan/tree-matching.john"))
(define evidence (john-read "notes/plan/evidence.john"))
(define reqs '(Selectors Source Lists Args Interleave Apply Memos Foreign Literals Calc Speed Suite))
(define answers
  (john-run (concat-list plan
			 (concat-list evidence
				      (concat-list (map (lambda (r) (list 'query (list 'send r 'done))) reqs)
						   (john-read-text "T satisfy ship."))))))
(let ((rs reqs) (as answers))
  (while rs
    (println (car rs) " " (or (car as) "?"))
    (set rs (cdr rs))
    (set as (cdr as)))
  (println "worlds of evidence: " (list-length evidence))
  (list-do l as (println l)))
