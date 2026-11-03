;;; A list pattern matches inside an element, and all of it, and leaves things as they were if it fails.
(require "check/tpeg-run.l")
(load "build/tpeg-lists-source.g.l")

(expect "a node" (try <trees/source> $node '((add 1 2))) '((1 2)))
(expect "nested" (try <trees/source> $deep '((add 3 (mul 4)))) '((3 4)))
(expect "the whole list must match" (try <trees/source> $node '((add 1 2 3))) ())
(expect "a prefix leaves position at the start" (stays-at-start <trees/source> $node '((add 1 2 3))) 1)
(expect "an empty list" (try <trees/source> $empty '(())) '(none))
(expect "an atom has no contents" (try <trees/source> $node '(5)) ())
(expect "nothing to enter" (try <trees/source> $node ()) ())
(expect "into a string" (try <trees/source> $word '("abc")) '("abc"))
(expect "a literal 0" (try <trees/source> $zero '(0)) '(got-zero))
(expect "a string literal" (try <trees/source> $name '("plus")) '(got-string))
(expect "strings inside a list, with their own limits" (try <trees/source> $digits '("12" "345")) '(357))

;; failing in the second node puts the input back
(expect "backtracks" (try <trees/source> $two '((add 1 2) (bad))) ())
(expect "position back" (stays-at-start <trees/source> $two '((add 1 2) (bad))) 1)
(expect "both nodes" (reaches-end <trees/source> $two '((add 1 2) (add 3 4))) 1)
(expect "the next alternative after a failed pattern" (try <trees/source> $either '((a c))) '(a-any))

;; a list pattern can't be matched on text that isn't an element of a list
(expect "text has no nested lists" (try <trees/source> $node "add") ())
(finish "tpeg lists")
