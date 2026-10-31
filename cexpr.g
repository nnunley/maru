# -*- coke -*-

# Lexing and C's expressions, as Maru forms.  A language grammar inherits
# this one and overrides primary, suffix and expression.

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
identifier	= idpart:x _						-> x ;

keyword		= !idpart _ ;

xidentifier	= identifier ~"identifier" ;
xexpression	= expression ~"expression" ;

arglist		= expression?:a (","_ xexpression)*:b				-> `(,@a ,@b) ;

primary		= identifier
		| number
		| string
		| "("_ xexpression:e ")"_					-> e
		;

suffix		= primary:a ( "("_ arglist:b ")"_				-> `(,a ,@b) :a
			    )*							-> a
		;

unary		= suffix
		| "-"_ unary:a							-> `(- ,a)
		| "~"_ unary:a							-> `(~ ,a)
		| "!" !"=" _ unary:a						-> `(not ,a)
		;

factorop	= "*" -> '* | "/" -> '/ | "%" -> '% ;
factor		= factor:a factorop:o _ unary:b					-> `(,o ,a ,b)
		| unary
		;

termop		= "+" -> '+ | "-" -> '- ;
term		= term:a termop:o _ factor:b					-> `(,o ,a ,b)
		| factor
		;

shiftop		= "<<" -> '<< | ">>" -> '>> ;
shift		= shift:a shiftop:o _ term:b					-> `(,o ,a ,b)
		| term
		;

relop		= "<=" -> '<= | "<" -> '< | ">=" -> '>= | ">" -> '> ;
relation	= relation:a relop:o _ shift:b					-> `(,o ,a ,b)
		| shift
		;

equalop		= "==" -> '= | "!=" -> '!= ;
equality	= equality:a equalop:o _ relation:b				-> `(,o ,a ,b)
		| relation
		;

bitand		= bitand:a "&" !"&" _ equality:b				-> `(& ,a ,b)
		| equality
		;
bitxor		= bitxor:a "^"_ bitand:b					-> `(^ ,a ,b)
		| bitand
		;
bitor		= bitor:a "|" !"|" _ bitxor:b					-> `(| ,a ,b)
		| bitxor
		;
logand		= logand:a "&&"_ bitor:b					-> `(and ,a ,b)
		| bitor
		;
logor		= logor:a "||"_ logand:b					-> `(or ,a ,b)
		| logand
		;

conditional	= logor:c "?"_ xexpression:a ":" !"=" _ conditional:b		-> `(if ,c ,a ,b)
		| logor
		;

expression	= conditional ;
