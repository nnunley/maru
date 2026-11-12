#!./eval tpeg-repl.l
;;; What a grammar can't do stops its definition, saying why.  Run by tpeg-repl.l: each case is what the error must say
;;; and a grammar block, read by tpeg's own grammar rule and defined in a world (recover.l) that the error undoes.
(require "recover.l")		; before tpeg-run.l, whose try is a function, not recover.l's form
(require "check/tpeg-run.l")
(define-function message-of (condition)		; an error's words, run together
  (let ((s ""))
    (list-do x (cdr condition)
      (set s (concat-string s (cond ((string? x) x) ((symbol? x) (symbol->string x)) (else "")))))
    s))
(define-function says? (text word)
  (let ((i 0) (n (- (string-length text) (string-length word))) (found ()))
    (while (and (not found) (<= i n))
      (and (= word (string-copy text i (string-length word))) (set found 1))
      (incr i))
    found))
(define-function refusal (definition word)	; what defining the grammar does
  (try-call (lambda () (eval definition) 'defined)
	    (lambda (condition) (if (says? (message-of condition) word) 'refused (message-of condition)))))
{
  <refusals> : <tpeg> ()
  refusal = sexpression:word sspace lbrace grammar:g rbrace
	      -> (expect word (refusal g word) 'refused) ;
  refusals = (sspace refusal)* sspace "." ;
}
{ refusals }
"needs a grammar on <source-parser>"	{ <r3> : <text-parser> () start = `( . ) ; }
"needs a grammar on <source-parser>"	{ <r4> : <text-parser> () start = 'x ; }
"needs a grammar on <source-parser>"	{ <r5> : <text-parser> () start = {apply x} ; }
"needs a grammar on <source-parser>"	{ <r6> : <text-parser> () start = {super x} ; }
"reserved"				{ <r7> : <source-parser> () apply = . ; }
"left-recursive"			{ <r8> : <source-parser> () lr :a = lr "x" | . ; }
.
(finish "tpeg text_refuses")
