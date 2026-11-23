;;; A list pattern matches inside an element, and all of it, and leaves things as they were if it fails.
(require "check/tpeg-run.l")
(define counts ())	; the actions tl-count was called from, latest first
(define-function tl-count (what) (push counts what) what)
(define-form tl-wrap (template)	; an action form: it sees the template as written, when the grammar loads
  (or (and (pair? template) (= 'quasiquote (car template))) (error "tl-wrap: not given the template: " template))
  `(list 'wrapped ,template))
(load "build/tpeg-lists.g.l")
(expect "a quasiquoted action through the rule's action form" (try <trees> $wrapped '((w 1))) '((wrapped (got 1))))
(expect "any other action as written" (try <trees> $wrapped '(5)) '((plain 5)))

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

;; a choice of list patterns tries only the alternatives its head can match: each alternative tried tests its
;; literals (in-same), and one passed over tests none; the results are the full choice's
(define sames 0)
(define in-same-uncounted in-same)
(set in-same (lambda (a b) (set sames (+ sames 1)) (in-same-uncounted a b)))
(define-function picked (source) (set sames 0) (list (try <trees> $pick source) sames))
(expect "a head picks its alternatives" (picked '((c 1))) '(((c 1)) 2))
(expect "with those that have no literal" (picked '((x c))) '(((any-c x)) 1))
(expect "in their order" (picked '((c c))) '(((any-c c)) 1))
(expect "the last of many, after the one with no literal" (picked '((g))) '((g) 1))
(expect "a head none names" (picked '((h))) '(((other (h))) 0))
(expect "a head that isn't a symbol tries them all" (picked '(("a" 1))) '(((other ("a" 1))) 8))
(expect "a number for a head" (picked '((1 2))) '(((other (1 2))) 8))
(expect "nothing to enter" (picked '(5)) '(((other 5)) 0))
(set in-same in-same-uncounted)

;; a list of literals, elements and direct rules is walked as it is, entering no stream; an action runs once, only for
;; the alternative that matched; a string, a symbol or () where a list is expected answers as the stream path did
(define entered 0)
(define stream-of-uncounted source-parser-stream-of)
(set source-parser-stream-of (lambda (self v) (set entered (+ entered 1)) (stream-of-uncounted self v)))
(define-function entries (rule source) (set entered 0) (list (try <trees> rule source) entered))
(expect "a list walked, the source alone entered" (entries $node '((add 1 2))) '(((1 2)) 1))
(expect "a nested list pattern's outer list streamed, its inner walked" (entries $deep '((add 3 (mul 4)))) '(((3 4)) 2))
(expect "direct rules applied to their elements" (entries $regs '((r 1 2))) '((((v 1) (v 2))) 1))
(expect "an array is entered as a stream" (entries $node (list (list->array '(add 1 2)))) '(((1 2)) 2))
(set source-parser-stream-of stream-of-uncounted)
(set counts ())
(expect "the alternative that matched" (try <trees> $once '((k 1 2))) '(two))
(expect "its action alone, once" counts '(two))
(expect "a string where a list is expected" (try <trees> $pair '("pq")) ())
(expect "a symbol where a list is expected" (try <trees> $pair '(p)) ())
(expect "() where a list is expected" (try <trees> $pair '(())) ())
(expect "a dotted list, as the stream path reads it" (try <trees> $pair '((p . 1))) '(()))

;; a list pattern can't be matched on text that isn't an element of a list
(expect "text has no nested lists" (try <trees> $node "add") ())

;; a literal is compared by in-same, so a method on it governs a walked list as it does a stream (last: it changes how
;; every symbol compares)
(define-method in-same <symbol> (b) (or (= b 'any) (= self b)))
(expect "in-same decides a literal" (try <trees> $anything '((zz 1))) '(1))
(finish "tpeg lists")
