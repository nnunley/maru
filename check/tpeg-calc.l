#!./eval tpeg-repl.l
;;; The DBjr documents' calculator: left recursion over text to a tree, then an evaluator over the tree.  Run by
;;; tpeg-repl.l: the grammars are blocks, and the cases are input to check/tpeg-cases.l's rule.
(require "check/tpeg-run.l")
(define-function calc-apply (op l r)
  (cond ((= op "+") (+ l r)) ((= op "-") (- l r)) ((= op "*") (* l r)) (else (/ l r))))
(define-function calc-digits? (n) (and (string? n) (<= ?0 (string-at n 0)) (<= (string-at n 0) ?9)))
(define-function calc-letters? (n) (and (string? n) (not (calc-digits? n))))
;; ometaCalc-parse from the DBjr documents (notes/sources/grammars/dbjr-ometacalc-parse.ometa)
{
  <calc> : <text-parser> ()
  start = addExpr:e spaces -> e ;
  addExpr = addExpr:x ("+" | "-"):op mulExpr:y -> (list op x y)
	  | mulExpr ;
  mulExpr = mulExpr:x ("*" | "/"):op primExpr:y -> (list op x y)
	  | primExpr ;
  primExpr = spaces "(" addExpr:x spaces ")" -> x
	   | number
	   | identifier ;
  number = spaces [0-9]+ $:n -> n ;
  identifier = spaces ([a-zA-Z] [a-zA-Z0-9]*) @$:n -> n ;
  spaces = [ \t]* ;
}
;; ometaCalc-eval from the DBjr documents (notes/sources/grammars/dbjr-ometacalc-eval.ometa)
{
  <calceval> : <source-parser> (env)
  start :e = -> (set self.env e) calc ;
  calc = `( ('"+" | '"-" | '"*" | '"/"):op calc:l calc:r ) -> (calc-apply op l r)
       | .:n &-> (calc-digits? n) -> (string->number-base n 10)
       | .:n &-> (calc-letters? n) -> (cdr (assq (string->symbol n) self.env)) ;
}
(peg-enable-recursion)
(tpeg-read-file "check/tpeg-cases.l")
{ cases }
"a tree, left-associated"	<calc> $start "a+b*2"	=> ("+" "a" ("*" "b" "2"))
"left to right"			<calc> $start "1-2-3"	=> ("-" ("-" "1" "2") "3")
.
(define env '((a . 5) (b . 10)))
(define-function run-calc (text)
  (let ((p (source-parser-for <calceval> (list (parse-string <calc> $start text)))))
    (and (source-parser-invoke-args 'start $start p env)
	 (<source-parser>-result p))))
(expect "evaluated" (run-calc "a+b*2") 25)
(expect "parentheses" (run-calc "(a+b)*2") 30)
(expect "an unknown name" (run-calc "z") ())
(finish "tpeg calc")
