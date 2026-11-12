#!./eval tpeg-repl.l
;;; A list pattern matches inside an element, and all of it, and leaves things as they were if it fails.  Run by
;;; tpeg-repl.l: the grammar is a block, and the cases are input to check/tpeg-cases.l's rule.
(require "check/tpeg-run.l")
;; list patterns and object literals (thesis section 2.4.3)
{
  <trees> : <source-parser> ()
  node = `( 'add .:x .:y ) -> (list x y) ;
  deep = `( 'add .:x `( 'mul .:y ) ) -> (list x y) ;
  empty = `( ) -> 'none ;
  word = `( [a-z]+ @$:s ) -> s ;
  zero = '0 -> 'got-zero ;
  name = '"plus" -> 'got-string ;
  two = node node ;
  digits = `( [0-9]+ @$#:n ) `( [0-9]+ @$#:m ) -> (+ n m) ;
  either = `( 'a 'b ) -> 'ab | `( 'a .* ) -> 'a-any ;
}
(tpeg-read-file "check/tpeg-cases.l")
{ cases }
"a node"			<trees> $node '((add 1 2))		=> (1 2)
"nested"			<trees> $deep '((add 3 (mul 4)))	=> (3 4)
"the whole list must match"	<trees> $node '((add 1 2 3))		=> fails
"an empty list"			<trees> $empty '(())			=> none
"an atom has no contents"	<trees> $node '(5)			=> fails
"nothing to enter"		<trees> $node ()			=> fails
"into a string"			<trees> $word '("abc")			=> "abc"
"a literal 0"			<trees> $zero '(0)			=> got-zero
"a string literal"		<trees> $name '("plus")			=> got-string
"strings inside a list, with their own limits"
				<trees> $digits '("12" "345")		=> 357
;; an array is entered as a list is: KScript's and Smalltalk's lists are Maru arrays
"into an array"			<trees> $node (list (list->array '(add 1 2)))	=> (1 2)
"nested arrays"			<trees> $deep (list (list->array (list 'add 3 (list->array '(mul 4)))))
										=> (3 4)
"the whole array must match"	<trees> $node (list (list->array '(add 1 2 3)))	=> fails
"an empty array"		<trees> $empty (list (array 0))			=> none
;; failing in the second node puts the input back
"backtracks"			<trees> $two '((add 1 2) (bad))		=> fails
"the next alternative after a failed pattern"
				<trees> $either '((a c))		=> a-any
;; a list pattern can't be matched on text that isn't an element of a list
"text has no nested lists"	<trees> $node "add"			=> fails
.
(expect "a prefix leaves position at the start" (stays-at-start <trees> $node '((add 1 2 3))) 1)
(expect "position back" (stays-at-start <trees> $two '((add 1 2) (bad))) 1)
(expect "both nodes" (reaches-end <trees> $two '((add 1 2) (add 3 4))) 1)
(finish "tpeg lists")
