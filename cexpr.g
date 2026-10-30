# -*- coke -*-

# Lexing and binary operators for C-like languages.  A language grammar
# inherits this one and overrides primary, suffix and expression, and the
# operator rules to name its own nodes.

<cexpr> : <text-parser> ()

blank		= [\t ] ;
eol		= "\n""\r"* | "\r""\n"* ;
comment1	= "//" (&. !eol .)* ;
commentN	= "/*" (&. !"*/" (commentN | .))* "*/" ;
comment		= comment1 | commentN ;
_		= (blank   | eol | comment)* ;

oigit		= [0-7] ;
digit		= [0-9] ;
higit		= [0-9A-Za-z] ;
letter		= [A-Z_a-z] ;

uinteger	= "0x" higit+ $#16:x _						-> x
		| "0"  oigit+ $#8 :x _						-> x
		|      digit+ $#10:x _						-> x
		;
integer		= "-"uinteger:x							-> (- x)
		|    uinteger
		;

ufloat		= (digit+ "."digit+ ("e"digit+)?)@$:s _				-> (string->double s) ;
float		= "-"ufloat:x							-> (- x)
		|    ufloat
		;

number		= float | integer ;

char		= "\\"	( "t"					->  9
			| "n"					-> 10
			| "r"					-> 13
			| "x" (higit higit) @$#16
			| "u" (higit higit higit higit) @$#16
			| .
			)
		| . ;

string		= "\"" ("\"\""->34 | !"\"" char)* $:x "\"" _			-> x ;

idpart		= (letter (letter | digit)*) @ $$ ;
identifier	= idpart:x !":" _						-> x ;

keyword		= !idpart _ ;

xidentifier	= identifier ~"identifier" ;
xexpression	= expression ~"expression" ;

arglist		= expression?:a (","_ xexpression)*:b				-> `(,@a ,@b) ;

primary		= identifier:e							-> `(name ,e)
		| number:e							-> `(lit ,e)
		| string:e							-> `(lit ,e)
		| "("_ xexpression:e ")"_					-> e
		;

suffix		= primary ;

factorop	= "*" -> '* | "/" -> '/ | "%" -> '% ;

factor		= factor:a factorop:o _ suffix:b				-> `(,o ,a ,b)
		|			suffix
		;

termop		= "+" -> '+ | "-" -> '- ;

term		= term:a termop:o _ factor:b					-> `(,o ,a ,b)
		|		    factor
		;

relop		= "<=" -> '<= | "<" -> '< | "==" -> '== | "!=" -> '!= | ">=" -> '>= | ">" -> '> ;

relation	= term:a ( relop:o _ term:b					-> `(,o ,a ,b) :a
			 )?							-> a
		;

expression	= relation ;
