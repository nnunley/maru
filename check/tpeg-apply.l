;;; {apply x} calls a rule by name on this grammar; {super r} calls r as the parent defines it.
(require "check/tpeg-run.l")
(load "build/tpeg-apply.g.l")
(load "build/tpeg-apply-child.g.l")

(expect "by the node's head" (try <nullp> $trans '((add (one) (one)))) '((add (one) (one))))
(expect "an inherited rule reaches an override" (try <childp> $trans '((add (one) (one)))) '((add (ONE) (ONE))))
(expect "no such rule fails the match" (try <nullp> $trans '((nosuchrule))) ())
(expect "super" (try <childp> $tail2 "z") '((child parent)))
(expect "apply with an argument naming the rule" (try <nullp> $direct "z") '((by-name parent)))
(finish "tpeg apply")
