# Squeak's Smalltalk, read to KScript's trees (kscript.g's forms), so KSWorld's Smalltalk methods run where its KScript
# ones do.  After test-pepsi.l's Smalltalk grammar (unary, binary and keyword sends, blocks, assignment, temporaries,
# literals), with what a Squeak method adds: a pattern without brackets, ^, cascades, literal and brace arrays.
#   self -> this          an instance variable -> this.x (field this x)        ^ e -> (return e), out of the method
#   at: 1 put: x -> (send R _at_put 1 x), as KScript calls Smalltalk (this.contents._at(i))
# A block is (fn PARAMS BODY...); a ^ inside one returns from its method (method-return), as Squeak's does.

<squeak> : <text-parser> ()

blank		= [ \t\r\n] ;
comment		= "\"" (!"\"" .)* "\"" ;
_		= (blank | comment)* ;
digit		= [0-9] ;
letter		= [A-Za-z_] ;
binchar		= [-!%&*+,/<=>?@\\~|] ;

idpart		= (letter (letter | digit)*) @ $:s				-> s ;
identifier	= idpart:x !(":" !"=") _					-> (squeak-name self x) ;
keyword		= idpart:x ":" !"=" _						-> x ;
binsel		= (binchar+) @ $:s _						-> (string->symbol s) ;

number		= ("-"? digit+ ("r" [0-9A-Z]+)? ("." digit+)? ("e" "-"? digit+)?) @ $:s _	-> (squeak-number s) ;
string		= "'" ("''" -> 39 | !"'" .)* $:s "'" _				-> s ;
character	= "$" . $:c _							-> `(char ,(string-at c 0)) ;
symbol		= "#" ( (idpart ":")+ @ $:s _					-> `(symbol ,(string->symbol s))
		      | idpart:s _						-> `(symbol ,(string->symbol s))
		      | binsel:s						-> `(symbol ,s)
		      | string:s						-> `(symbol ,(string->symbol s))
		      ) ;
literal		= number | string | character | symbol
		| "#(" _ literalitem*:xs ")" _					-> `(list ,@xs)
		| "#[" _ number*:xs "]" _					-> `(list ,@xs) ;
literalitem	= literal | "(" _ literalitem*:xs ")" _ -> `(list ,@xs)
		| (idpart ":"*) @ $:s _						-> `(symbol ,(string->symbol s))
		| binsel:s							-> `(symbol ,s) ;

blockargs	= (":" _ idpart:a _ -> (string->symbol a))+:as "|" _		-> as
		|								-> () ;
block		= "[" _ blockargs:as temps:ts statements:ss "]" _		-> `(fn ,as ,@ts ,@ss) ;
temps		= "|" _ (idpart:t _ -> `(var ,(string->symbol t) nil))*:ts "|" _	-> ts
		|								-> () ;

primary		= literal | block | identifier
		| "{" _ (expression:e ("." _)* -> e)*:es "}" _			-> `(list ,@es)
		| "(" _ expression:e ")" _					-> e ;

unarysend	= primary:r (idpart:s !":" _ -> `(send ,r ,(string->symbol s) ):r)*	-> r ;
binarysend	= unarysend:r (binsel:s unarysend:a -> `(send ,r ,s ,a):r)*	-> r ;
keywordsend	= binarysend:r ( (keyword:k binarysend:a -> (cons k a))+:ps	-> (squeak-keyword-send r ps)
			       |						-> r ) ;
message		= (keyword:k binarysend:a -> (cons k a))+:ps			-> (cons 'keyword ps)
		| binsel:s unarysend:a						-> (list 'binary s a)
		| idpart:s !":" _						-> (list 'unary (string->symbol s)) ;
cascade		= keywordsend:first (";" _ message)+:rest			-> (squeak-cascade first rest)
		| keywordsend ;
assign		= ":=" _ | "_" &blank _ ;					# _ is older Squeak's arrow
expression	= identifier:v assign expression:e				-> (squeak-assign v e)
		| cascade ;
statement	= "^" _ expression:e						-> `(method-return ,e)
		| expression ;
statements	= statement?:s (("." _)+ statement)*:ss ("." _)*		-> `(,@s ,@ss) ;

pattern		= (keyword:k idpart:a _ -> (cons k (string->symbol a)))+:ps	-> (cons (squeak-selector (map car ps)) (map cdr ps))
		| binsel:s idpart:a _						-> (list s (string->symbol a))
		| idpart:s _							-> (list (string->symbol s)) ;
primitive	= "<" (!">" .)* ">" _ ;
method		= _ pattern:p primitive* temps:ts primitive* statements:ss !.	-> `(,(car p) (fn ,(cdr p) ,@ts ,@ss)) ;

# test-pepsi.l's own way of writing a library, as squeak-base.st writes the platform: "Name : Super (ivars)" defines a
# class, "Class pattern [ statements ]" (or "Class class pattern ...", its class side) a method, and "Class pattern
# { s-expression }" a primitive, Maru with self and the arguments bound.  Reads to (class NAME SUPER IVARS) and
# (method CLASS SIDE SELECTOR (fn PARAMS ...)) or (primitive CLASS SIDE SELECTOR PARAMS FORM).
sblank		= blank | ";" (!"\n" .)* ;
sspace		= sblank* ;
schar		= [-!#$%&*+./:<=>?@A-Z^_a-z|~0-9] ;
sexpr		= "(" sspace (sexpr:e sspace -> e)*:es ")"			-> es
		| "'" sexpr:e							-> (list 'quote e)
		| "\"" ("\\" . | !"\"" .)* @ $:s "\""				-> s
		| ("-"? digit+) @ $:s !schar					-> (string->long s)
		| (schar+) @ $:s						-> (string->symbol s) ;
libside		= "class" !letter _ !("[" | "{")				-> 'class	# Object class { ... } is a method named class
		|								-> 'instance ;
libdef		= idpart:c _ ":" _ (idpart:s _ -> (string->symbol s))?:s "(" _ (idpart:v _ -> (string->symbol v))*:vs ")" _
										-> `(class ,(string->symbol c) ,(car s) ,vs)
		| idpart:c _ libside:side pattern:p "[" _ temps:ts statements:ss "]" _
										-> `(method ,(string->symbol c) ,side ,(car p) (fn ,(cdr p) ,@ts ,@ss))
		| idpart:c _ libside:side pattern:p "{" sspace sexpr:e sspace "}" _
										-> `(primitive ,(string->symbol c) ,side ,(car p) ,(cdr p) ,e) ;
library		= _ libdef*:ds !.						-> ds ;
