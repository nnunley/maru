# OMeta2's rules (Warth's OMeta for Squeak), as KSWorld's KScript2 compiler writes them in its grammar classes' methods,
# read to tpeg's own rule form, (NAME EXPRESSION PARAMETERS), so Maru's PEG runs them (ometa2.l):
#   anything .   empty (an empty sequence)   rule rule(arg, ...)   { ... } a list   ( ... ) a group   #sym 'string' $c a value
#   "tok" a token   < ... > the text matched   x:name   :name (anything:name)   &x ~x ?[test]   x* x+ x?   [expr]   -> [expr]
#   empty(x) pushes x back onto the input for the next term: folded into that term's application, whose arguments tpeg pushes
#   as cells ahead of its input (ometa2.l's ometa2-seq)
# A Smalltalk expression ([ ], ?[ ], -> [ ], a rule's argument) is kept as its source, (smalltalk "..."), for ometa2.l to read
# with squeak.g and run with the rule's bindings.

<ometa2> : <text-parser> ()

blank		= [ \t\r\n] ;
_		= (blank | "//" (!"\n" .)*)* ;
letter		= [A-Za-z_] ;
digit		= [0-9] ;
idchar		= letter | digit ;
name		= (letter idchar*) @ $:s					-> (string->symbol s) ;

# a Smalltalk expression in brackets, its own brackets, strings, comments and characters balanced
stchunk		= "'" ("''" | !"'" .)* "'" | "\"" (!"\"" .)* "\"" | "$" . | "[" stchunk* "]" | "(" stchunk* ")" | "{" stchunk* "}"
		| ![\]\)\}] . ;
stbody		= stchunk* @ $:s						-> s ;
stargs		= _ (!"," !")" stchunk)* @ $:a (_ "," _ (!"," !")" stchunk)* @ $)*:as	-> (cons a as) ;
action		= "[" stbody:s "]"						-> `(smalltalk ,s) ;

rule		= _ name:n (_ ":" name)*:ps _ "=" choice:c _ !.			-> `(,n ,c ,ps) ;
choice		= seq:s (_ "|" seq)*:ss						-> (if ss `(match-first ,s ,@ss) s) ;
seq		= (_ !"|" !"->" term)*:ts (_ "->" _ action:a -> a)?:r
										-> (ometa2-seq ts (car r)) ;
term		= "&" term:t							-> `(peek-for ,t)
		| "~" term:t							-> `(peek-not ,t)
		| "?" action:a							-> `(peek-expr (ometa2-true? ,a))
		| ":" name:n							-> `(assign-result ,n (match-any))
		| base:b ( "*" -> `(match-zero-more ,b) :b
			 | "+" -> `(match-one-more ,b) :b
			 | "?" !"[" -> `(match-zero-one ,b) :b
			 )* (":" name:n -> `(assign-result ,n ,b) :b)?		-> b ;
base		= "anything" !idchar						-> `(match-any)
		| "empty" _ "(" stargs:as ")"					-> `(ometa2-push ,@(map (lambda (a) `(smalltalk ,a)) as))
		| "empty" !idchar						-> `(match-all)
		| ("nil" | "true" | "false") @ $$:v !idchar			-> `(match-object ,(and (= v 'true) 't))	# Maru's t and ()
		| name:n "(" stargs:as ")"					-> `(match-rule ,n ,@(map (lambda (a) `(smalltalk ,a)) as))
		| name:n							-> `(match-rule ,n)
		| "{" choice:c _ "}"						-> `(match-list ,c)
		| "(" choice:c _ ")"						-> c
		| "#" ( "'" (!"'" .)* @ $:s "'" -> s | (idchar | ":")+ @ $:s -> s
		      | [-+*/\\<>=~@%|&?!,]+ @ $:s -> s ):s			-> `(match-object ,(string->symbol s))	# tpeg quotes the operand
		| "$" .:c							-> `(ometa2-char ,c)
		| "'" ("''" -> 39 | !"'" .)* $:s "'"				-> `(ometa2-exactly ,s)
		| "\"" (!"\"" .)* $:s "\""					-> `(match-rule token ,s)
		| "<" choice:c _ ">"						-> `(make-span ,c)
		| action:a							-> `(result-expr ,a) ;
