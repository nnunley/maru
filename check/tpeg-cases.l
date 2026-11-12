#!./eval tpeg-repl.l
;;; A check's cases as input to a rule, read by tpeg-repl.l (tpeg-read-file) after the check's own grammars.  A case is
;;; what it shows, a grammar's rule over a source (Maru forms, evaluated), and what the rule answers or that it fails;
;;; the cases end at a line holding a dot.  Each case's action checks it.
(require "check/tpeg-run.l")	; try and expect, which the rule's action calls
{
  <cases> : <tpeg> ()
  answer = sspace "fails" space -> ()
	 | sexpression:v sspace -> (list v) ;
  case = sexpression:what sexpression:grammar sexpression:rule sexpression:source sspace "=>" answer:want
	   -> (expect what (try (eval grammar) (eval rule) (eval source)) want) ;
  cases = (sspace case)* sspace "." ;
}
