#!./eval tpeg-repl.l
;;; A foreign rule p-r runs on an object of <p>, with the input lent, and hands back where it got to.  Run by
;;; tpeg-repl.l: the grammars are blocks, and the cases are input to check/tpeg-cases.l's rule.
(require "check/tpeg-run.l")
;; a foreign rule lends the input and takes it back; fields and memos stay apart
{
  <sa> : <source-parser> (seen)
  expr = -> (set self.seen 1) (.:x -> (list (quote from-a) x)) ;
}
;; calls sa's rule of the same name, on the same input, from inside a list pattern too
{
  <sb> : <source-parser> (seen)
  expr = .:x -> (list 'from-b x) ;
  lent = sa-expr:a expr:b -> (list a b) ;
  nested = `( sa-expr:a expr:b ) -> (list a b) ;
  field = sa-expr:a -> self.seen ;
}
(peg-enable-recursion)
(tpeg-read-file "check/tpeg-cases.l")
{ cases }
"the input comes back"	<sb> $lent '(1 2)	=> ((from-a 1) (from-b 2))
"inside a list pattern"	<sb> $nested '((1 2))	=> ((from-a 1) (from-b 2))
"a foreign failure"	<sb> $lent '(1)		=> fails
"fields are its own"	<sb> $field '(1)	=> ()
.
(finish "tpeg foreign")
