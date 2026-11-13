;;; ./eval notes/plan/replay.l [write]: whether the plan's ledger (MARU_PLAN) holds every write its actions make now;
;;; with write, the ledger rewritten as they make them.  A ledger is read back, never evaluated, so a change to what an
;;; action writes reaches the worlds already recorded only through this (doc/evidence-plan.md).
(define replay-write (= "write" (car *arguments*)))
(set *arguments* ())
(require "notes/plan/plan-world.l")
(if (not replay-write)
    (let ((drift (plan-ledger-drift "notes/plan" plan-name)))
      (if drift (let () (println drift) (exit 1)) (println plan-evidence-file ": what the plan's actions write now")))
  (println plan-evidence-file ": rewritten, " (long->string (list-length (plan-replay-write "notes/plan" plan-name))) " lines"))
