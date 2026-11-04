;;; The plan and its evidence, replayed to a chain of worlds; what's asked of them, read through John's own evaluator.
(require "john-eval.l")
(define plan-evidence (john-read "notes/plan/evidence.john"))
(john-run (concat-list (john-read "notes/plan/tree-matching.john") plan-evidence))
(define-function plan-ask (object message . args)
  (john-eval `(send ,object ,message ,@args) *john-world* ()))
(define-function plan-yes? (object message . args)
  (= 'yes (john-eval `(send ,object ,message ,@args) *john-world* ())))
