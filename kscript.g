# -*- coke -*-

# KScript, Ohshima's FRP and scripting language for KSWorld (VPRI TR-2012-001,
# Appendices I and II).  Inherits C's lexing and arithmetic from <cexpr> and
# adds indentation-structured blocks, closures, event streams (<-, fby, on,
# startsWith, when/then, @ref, lag '), comprehensions, and dictionary literals;
# and, as KSWorld's own methods (ksworld/*.st) write them, += and -=, #'symbols' (or #"symbols")
# and $$(expr) streams.

<kscript> : <cexpr> ()

hs		= [\t ]* ;
wb		= !(letter | digit) _ ;
prime		= ("'" | &-> (ks-utf8-prime self)) !(letter | digit | "'") _ ;

sglstring	= "'" (!"'" char)* $:x "'" _					-> x ;

reserved	= ( "if" | "then" | "else" | "for" | "in" | "by" | "when"
		  | "fby" | "startsWith" | "on" | "var" | "return"
		  | "delete" | "not" ) !(letter | digit) ;

ident		= !reserved idpart:x _						-> x ;
anyident	= idpart:x _							-> x ;

paramlist	= ident?:a ("," _ ident)*:b					-> `(,@a ,@b) ;
dictpair	= (anyident | string | sglstring):k (":" | "->") _ expr:v	-> (list k v) ;
dictpairs	= dictpair?:a (("," | ".") _ dictpair)*:b			-> `(,@a ,@b) ;

symbolname	= "'" (!"'" .)* $:x "'" _					-> (string->symbol x)
		| "\"" (!"\"" .)* $:x "\"" _					-> (string->symbol x) ;	# KSParser's symbol is $# string, either quote

primary		= "..." _							-> 'ellipsis
		| "#" symbolname:x						-> `(symbol ,x)	# #'wordWidth', a Squeak Symbol
		| "$$" "("_ expr:e ")"_						-> `(stream-expr ,e)	# a stream of an expression, as <- makes one
		| "@" anyident:x						-> `(stream-ref ,x)
		| ":" anyident:x						-> `(global ,x)
		| (-> (ks-indent self)):c "("_ paramlist:ps ")"_ "->"_
		  ( {suite c}:b							-> `(fn ,ps ,@b)
		  | stmt:s							-> `(fn ,ps ,s)
		  )
		| "("_ expr:a "to:"_ expr:b ")"_				-> `(range ,a ,b)
		| "("_ expr:e "for" wb ident:v "in" wb expr:col ("when" wb expr)?:w ")"_
										-> `(list-comp ,e ,v ,col ,(car w))
		| "("_ ident:v "in" wb expr:col ("when" wb expr)?:w ")"_
										-> `(detect-comp ,v ,col ,(car w))
		| "("_ expr:e ")"_						-> e
		| "["_ expr:a "..."_ expr:b "]"_				-> `(range ,a ,b)
		| "["_ expr:e "for" wb ident:v "in" wb expr:col ("when" wb expr)?:w "]"_
										-> `(list-comp ,e ,v ,col ,(car w))
		| "["_ arglist:a "]"_						-> `(list ,@a)
		| "{"_ dictpairs:p "}"_						-> `(dict ,@p)
		| number
		| string
		| sglstring
		| ident
		;

suffix		= primary:a ( "."_ anyident:m "("_ arglist:b ")"_		-> `(send ,a ,m ,@b) :a
			    | "."_ anyident:f					-> `(field ,a ,f) :a
			    | "["_ expr:i "]"_					-> `(index ,a ,i) :a
			    | "("_ arglist:b ")"_				-> `(call ,a ,@b) :a
			    | prime						-> `(lag ,a) :a
			    )*							-> a
		;

unary		= "not" wb unary:a						-> `(not ,a)
		| "!" !"=" _ unary:a						-> `(not ,a)
		| "-"_ unary:a							-> `(- ,a)
		| "~" !"=" _ unary:a						-> `(~ ,a)
		| suffix
		;

equalop		= "===" -> '= | "!==" -> '!= | "==" -> '= | "!=" -> '!= | "~=" -> '!= ;

coalesce	= logor:a ("?" !"="_ coalesce:b -> `(coalesce ,a ,b) :a)*	-> a ;

ifbranch :c	= {suite c}:b							-> `(begin ,@b)
		| stmt:s							-> s
		;

ifexpr		= (-> (ks-indent self)):c "if" wb expr:cond
		  ("then" wb)? {ifbranch c}:t
		  ("else" wb {ifbranch c})?:e					-> `(if ,cond ,t ,(car e))
		| coalesce
		;

whenexpr	= (-> (ks-indent self)):c "when" wb expr:trig (":"_ ident)?:v
		  "then" wb {ifbranch c}:body					-> `(when-stream ,trig ,(car v) ,body)
		| ifexpr
		;

fbyexpr		= whenexpr:a "fby" wb fbyexpr:b ("on" wb whenexpr)?:t		-> `(fby ,a ,b ,(car t))
		| whenexpr:a "startsWith" wb fbyexpr:b				-> `(fby ,b ,a ())
		| whenexpr
		;

assignop	= "<-" -> 'stream-def | ":=" -> 'assign | "?=" -> 'assign-or | "+=" -> 'assign-add | "-=" -> 'assign-sub
		| "=" !"=" -> 'assign ;

expr		= suffix:a assignop:o _ expr:b					-> `(,o ,a ,b)
		| fbyexpr
		;

expression	= expr ;

stmt		= "var" wb ident:v ((":=" | "=" !"=") _ expr)?:e		-> `(var ,v ,(car e))
		| (-> (ks-indent self)):c "for" wb ident:v "in" wb expr:col
		  ("by" wb expr)?:step {ifbranch c}:b				-> `(for-in ,v ,col ,(car step) ,b)
		| "delete" wb suffix:x						-> `(delete ,x)
		| "return" !idpart hs ( (eol | &")" | !.) _			-> '(return nil)
				      | _ expr:e				-> `(return ,e)
				      )
		| expr
		;

suite :c	= (&-> (> (ks-indent self) c) stmt)+ ;

program		= _ stmt*:s (!. ~"statement")					-> s ;
