#!./eval tpeg-repl.l
;;; A grammar matches over any source, and a match's value doesn't decide its success.  Run by tpeg-repl.l, as
;;; test-pepsi.l is by repl.l: the grammars are blocks, and each case below is input to a rule whose action checks it.
;; peg's grammars too (parser.l), loaded first so try knows their parsers
(require "parser.l")
(require "peg-compile.l")
(require "peg.l")
(require "check/tpeg-run.l")
{
  <mini> : <source-parser> ()
  num = [0-9]+ @$#:n -> n ;
  sum = num:a "+" num:b -> (+ a b) ;
  any = . ;
  word = "abc" ;
}
;; on text, parameters stay arguments of a rule's method, as nile-grammar.g uses them
{
  <ta> : <text-parser> ()
  pair :a :b = "y" -> (list a b) ;
  callp = "x" {pair 1 2}:r -> r ;
}
(tpeg-read-file "check/tpeg-cases.l")
{ cases }
"text"				<mini> $sum "2+3"				=> 5
"a list of characters"		<mini> $sum '(?2 ?+ ?3)				=> 5
"a user's type"			<mini> $sum (new <countdown> (list ?2 ?+ ?3))	=> 5
"a string literal over a list"	<mini> $word '(?a ?b ?c)			=> "abc"
"failure on a list"		<mini> $sum '(?x)				=> fails
;; parse data is separate from parse state
"a nil element"			<mini> $any '(())				=> ()
"a zero element"		<mini> $any '(0)				=> 0
"the end isn't an element"	<mini> $any ()					=> fails
;; any grammar: a text parser's, and peg's
"a text grammar"		<ta> $callp "xy"				=> (1 2)
"a peg grammar"			<peg> $sexpression "(a b)"			=> (a b)
"a peg grammar's failure"	<peg> $sexpression ")"				=> fails
.
(and has-bytes (expect "binary" (try <mini> $sum (bytes-of "2+3")) '(5)))
(expect "parse-source" (parse-source <mini> $sum '(?2 ?+ ?3)) 5)
(finish "tpeg source")
