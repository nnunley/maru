;;; ./eval notes/plan/erosion-hotspots.l: erosion-run.l --hotspots over the files the erosion case measures, for the
;;; plans' Erosion measure: every callable over CC 10, with its mass (doc/evidence-plan.md).
(require "notes/plan/plan-load.l")
(require "check/erosion-unread.l")
(define measured ())
(list-do f (plan-file-lines-of-command "check/erosion-files") (or (member? f erosion-unread) (push measured f)))
(set *arguments* (concat-list (cons "--hotspots" (cons "--unread" erosion-unread)) (cons "--" (list-reverse! measured))))
(load "erosion-run.l")
