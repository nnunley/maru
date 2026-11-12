#!./eval tpeg-repl.l
;;; Run by tpeg-repl.l, as test-pepsi.l is by repl.l: code and grammars interleave on one stream. A block's rules
;;; enrich the running grammar, and a block's expression takes the input until it stops matching.
(define *said* ())
{
  blank = [ \t\n\r] ;
  _ = blank* ;
  word = [a-z]+ $:w _ -> w ;
}
{ _ ("say" _ word:w ";" _ -> (push *said* w))* "." }
say hello;
say world;
.
(or (equal *said* '("world" "hello")) (error "FAIL the first block: " *said*))

;; a later block enriches the grammar: word is overridden, and _ stays
{
  word = [A-Z]+ $:w _ -> w ;
}
{ _ ("say" _ word:w ";" _ -> (push *said* w))* "." }
say AGAIN;
.
(or (equal (car *said*) "AGAIN") (error "FAIL the enriched block: " *said*))

;; with no terminator, the block hands back the input where it stops matching, here at the next form
{ _ ("say" _ word:w ";" _ -> (push *said* w))* }
say NOW;
(or (equal (car *said*) "NOW") (error "FAIL handing back: " *said*))

;; and code goes on being read as code
(define *after* (+ 1 2))
(or (= *after* 3) (error "FAIL code after a block"))
(println "tpeg interleave ok")
