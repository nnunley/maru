#!./eval tpeg-repl.l
;;; tpeg reads hexadecimal in actions, as peg.g does, and set-list-source copies sources as parser.l's does.  Run by
;;; tpeg-repl.l: the grammar is a block, and the cases are input to check/tpeg-cases.l's rule.
(require "check/tpeg-run.l")
{
  <lit> : <text-parser> ()
  hexv = -> 0x10 ;
  hexn = -> -0x10 ;
  upper = -> 0xFF ;
  plain = -> 16 ;
}
(tpeg-read-file "check/tpeg-cases.l")
{ cases }
"hex"		<lit> $hexv ""	=> 16
"negative hex"	<lit> $hexn ""	=> -16
"upper case"	<lit> $upper ""	=> 255
"decimal still"	<lit> $plain ""	=> 16
.
(let* ((from (list 'a 'b)) (to (list 'c 'd)))
  (set (<pair>-source from) 'first)
  (set (<pair>-source (cdr from)) 'second)
  (set-list-source to from)
  (expect "first source" (<pair>-source to) 'first)
  (expect "second source" (<pair>-source (cdr to)) 'second))
(finish "tpeg literals")
