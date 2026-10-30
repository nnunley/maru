;;; Grammars that call and inherit from each other share one input stream.
;;; Each line prints what a parse returned; the check compares them.
{ <pb> : <parser> ()
  expr = "a" -> 'from-b ;
}
{ <pa> : <parser> ()
  expr  = "ab" -> 'from-a ;
  start = &pb-expr expr:x -> x ;
}
{ <cexpr> : <parser> ()
  prim = [0-9]:d -> (- d ?0) ;
  add  = add:a "+" prim:b -> `(+ ,a ,b)
       | prim ;
}
{ <lang> : <cexpr> ()
  prim  = [a-z]:c -> (list 'name (format "%c" c))
	| "(" cexpr-add:e ")" -> e ;
  start = add ;
}
(define-function try (grammar rule input) (dumpln (parse-stream grammar rule (string-stream input))))
(peg-enable-recursion)
(try <pa> $start "ab")			; a rule named like one in the grammar it calls
(try <cexpr> $add "1+2+3")		; a left-recursive rule as the entry point
(try <lang> $start "a+(1+2)+b")		; an inherited rule calling an override, and a foreign call
