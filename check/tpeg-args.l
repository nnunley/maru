#!./eval tpeg-repl.l
;;; A call's arguments are elements its rule reads from the input, first argument first, and a rule that leaves one
;;; unread is an error: it mustn't reach the caller's input as data.  Run by tpeg-repl.l: the grammar is a block, and
;;; the cases are input to check/tpeg-cases.l's rule.
(require "recover.l")		; before tpeg-run.l, whose try is a function, not recover.l's form
(require "check/tpeg-run.l")
;; arguments on the input: a parameter is a pattern over what the caller pushed
{
  <argp> : <source-parser> ()
  pair :a :b = "y" -> (list a b) ;
  callp = "x" {pair 1 2}:r -> r ;
  picky = 'yes "y" -> 'matched ;
  askp = {picky 'yes}:r -> r ;
  askn = {picky 'no}:r -> r ;
  nilarg = .:a -> (list 'got a) ;
  calln = {nilarg ()}:r -> r ;
  zeroarg = .:a -> (list 'got a) ;
  callz = {zeroarg 0}:r -> r ;
  inner :c = "z" -> c ;
  outer :c = {inner c}:r -> (list 'outer r) ;
  nest = {outer 7}:r -> r ;
  fallback = {picky 'no} | "y" -> 'second ;
  overlist = `( {pair 1 2}:r ) -> r ;
  readsone = .:a -> a ;
  leaves = {readsone 1 2} ;
  readsnone = -> (quote nothing) ;
  leavesall = {readsnone 1} ;
}
(tpeg-read-file "check/tpeg-cases.l")
{ cases }
"parameters"				<argp> $callp "xy"		=> (1 2)
"an argument matched by a pattern"	<argp> $askp "y"		=> matched
"an argument that doesn't match"	<argp> $askn "y"		=> fails
"a nil argument"			<argp> $calln ""		=> (got ())
"a zero argument"			<argp> $callz ""		=> (got 0)
"passed along"				<argp> $nest "z"		=> (outer 7)
"no cell left behind"			<argp> $fallback "y"		=> second
"on a list source"			<argp> $overlist '((?y))	=> (1 2)
.
(expect "position after that failure" (stays-at-start <argp> $askn "y") 1)
;; an argument left unread stops the match with an error that says so
(define-function unread-error (rule)
  (try-call (lambda () (try <argp> rule '(9)) 'no-error)
	    (lambda (condition) (and (member? " left an argument unread" condition) 'unread))))
(expect "one of two arguments left unread" (unread-error $leaves) 'unread)
(expect "an argument never read" (unread-error $leavesall) 'unread)
(finish "tpeg args")
