;;; A list pattern matches inside an element, and all of it, and leaves things as they were if it fails.
(require "check/tpeg-run.l")
(load "build/tpeg-lists.g.l")

(expect "a node" (try <trees> $node '((add 1 2))) '((1 2)))
(expect "nested" (try <trees> $deep '((add 3 (mul 4)))) '((3 4)))
(expect "the whole list must match" (try <trees> $node '((add 1 2 3))) ())
(expect "a prefix leaves position at the start" (stays-at-start <trees> $node '((add 1 2 3))) 1)
(expect "an empty list" (try <trees> $empty '(())) '(none))
(expect "an atom has no contents" (try <trees> $node '(5)) ())
(expect "nothing to enter" (try <trees> $node ()) ())
(expect "into a string" (try <trees> $word '("abc")) '("abc"))
(expect "a literal 0" (try <trees> $zero '(0)) '(got-zero))
(expect "a string literal" (try <trees> $name '("plus")) '(got-string))
(expect "strings inside a list, with their own limits" (try <trees> $digits '("12" "345")) '(357))

;; an array is entered as a list is: KScript's and Smalltalk's lists are Maru arrays
(expect "into an array" (try <trees> $node (list (list->array '(add 1 2)))) '((1 2)))
(expect "nested arrays" (try <trees> $deep (list (list->array (list 'add 3 (list->array '(mul 4)))))) '((3 4)))
(expect "the whole array must match" (try <trees> $node (list (list->array '(add 1 2 3)))) ())
(expect "an empty array" (try <trees> $empty (list (array 0))) '(none))

;; failing in the second node puts the input back
(expect "backtracks" (try <trees> $two '((add 1 2) (bad))) ())
(expect "position back" (stays-at-start <trees> $two '((add 1 2) (bad))) 1)
(expect "both nodes" (reaches-end <trees> $two '((add 1 2) (add 3 4))) 1)
(expect "the next alternative after a failed pattern" (try <trees> $either '((a c))) '(a-any))

;; a choice of list patterns enters the element only for alternatives its head can match: the source is entered once,
;; and then each alternative tried; the results are the full choice's
(define entered 0)
(define stream-of-uncounted source-parser-stream-of)
(set source-parser-stream-of (lambda (self v) (set entered (+ entered 1)) (stream-of-uncounted self v)))
(define-function picked (source) (set entered 0) (list (try <trees> $pick source) entered))
(expect "a head picks its alternatives" (picked '((c 1))) '(((c 1)) 3))
(expect "with those that have no literal" (picked '((x c))) '(((any-c x)) 2))
(expect "in their order" (picked '((c c))) '(((any-c c)) 2))
(expect "the last of many, after the one with no literal" (picked '((g))) '((g) 3))
(expect "a head none names" (picked '((h))) '(((other (h))) 2))
(expect "a head that isn't a symbol tries them all" (picked '(("a" 1))) '(((other ("a" 1))) 9))
(expect "a number for a head" (picked '((1 2))) '(((other (1 2))) 9))
(expect "nothing to enter" (picked '(5)) '(((other 5)) 1))
(set source-parser-stream-of stream-of-uncounted)

;; a list pattern can't be matched on text that isn't an element of a list
(expect "text has no nested lists" (try <trees> $node "add") ())
(finish "tpeg lists")
