;;; The plan and its evidence, replayed to a chain of worlds; what's asked of them, read through John's own evaluator.
;;; Now is the code as it stands, so what was recorded against other code doesn't count.
(require "john-eval.l")
(define system (subr "system" "s"))
(system "mkdir -p /tmp/maru-plan && notes/plan/tree-hash > /tmp/maru-plan/tree")
(define plan-tree
  (let ((text (contents-of-file-named "/tmp/maru-plan/tree")))
    (string-copy text 0 (- (string-length text) 1))))
(define plan-evidence (john-read "notes/plan/evidence.john"))
(john-run (concat-list (john-read "notes/plan/tree-matching.john")
		       (cons (list 'make 'Code 'Now plan-tree) plan-evidence)))
(define-function plan-ask (object message . args)
  (john-eval `(send ,object ,message ,@args) *john-world* ()))
(define-function plan-yes? (object message . args)
  (= 'yes (john-eval `(send ,object ,message ,@args) *john-world* ())))
