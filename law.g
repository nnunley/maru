# -*- coke -*-

# Law files: rules, facts, defaults and laws, over cexpr.g's expressions.
# A rule's names are logic variables, a set's or a let's are not; law-compile.l
# turns the raw forms here (law-pair, law-list, law-bind) into the items.

<law> : <cexpr> ()

# -- starts a comment at a line's start, or after a blank space when a blank or the line's end follows
dash		= &-> (law-dash? self) "--" (&. !eol .)* ;
gap		= (blank | eol | comment | dash)* ;
termop		= "+" -> '+ | "-" !"-" -> '- ;

equalop		= "==" -> '=
		| "=" !"=" !">" -> '=
		| "!=" -> '!=
		;
bitor		= bitxor ;			# | separates alternatives and list tails

xarg		= arg ~"value" ;
xgoal		= goal ~"goal" ;

arg		= pair | arg0 ;
arg0		= list | template | expression ;
pair		= identifier:a ":"_ arg:b					-> `(law-pair ,a ,b) ;
args		= arg:a (","_ arg)*:b						-> `(,a ,@b) ;
list		= "["_ elems?:e ( "|"_ arg )?:r "]"_				-> `(law-list ,(car e) ,@r) ;
elems		= elem:a (","_ elem)*:b						-> `(,a ,@b) ;
elem		= expression:a ".."_ expression:b				-> `(law-range ,a ,b)	# whole numbers a to b
		| arg ;

tpart		= "{{" | "}}" | "{" idpart "}" | !"`" !"{" !"}" !eol . ;
template	= idpart:l "`" tpart*@$:t "`"_					-> `(template ,l ,t) ;
primary		= template						# a claim compares templates
		| field							# r.name reads a record's field
		| list							# [a, b | t], a list in a claim
		| identifier
		| number
		| string
		| "("_ xexpression:e ")"_					-> e
		;
field		= idpart:a "." idpart:f _				-> `(law-field ,a ,(symbol->string f)) ;

goal		= identifier:n "("_ args?:a ")"_				-> `(,n ,@(car a))
		| identifier:v ":"_ arg:t "in" keyword arg:e			-> `(in ,v ,t ,e)
		;
goals		= goal:g (","_ goal)*:h						-> `(,g ,@h) ;
names		= xidentifier:a (","_ xidentifier)*:b				-> `(,a ,@b) ;
setting		= xidentifier:k "="_ number:n					-> (cons k n) ;

item		= "let"       keyword xidentifier:n "="_ xarg:v			-> `(let ,n ,v)
		| "set"       keyword xidentifier:n "="_ xidentifier:a ("|"_ xidentifier)*:b	-> `(set ,n (,a ,@b))
		| "under"     keyword "test" keyword ":"_ names:n		-> `(under-test ,@n)
		| "reference" keyword xidentifier:n "("_ names:p ")"_		-> `(reference ,n ,@p)
		| "rule"      keyword xidentifier:n ( "("_ names:q ")"_ -> q )?:p
		  ":"_ goals?:g "=>"_ xgoal:c					-> `(rule ,n ,(car p) ,c ,@(car g))
		| "fact"      keyword xgoal:g					-> `(fact ,g)
		| "facts"     keyword names:r "from" keyword xidentifier:f	-> `(facts ,r ,f)
		| "for"       keyword xidentifier:v "in" keyword arg0:a ("|"_ arg0)*:b ":"_ item:i	-> `(schema ,v (,a ,@b) ,i)
		| "defaults"  keyword setting:a (","_ setting)*:b		-> `(defaults ,a ,@b)
		| "law"       keyword xidentifier:n ":"_ "all" keyword bindings:b "."_ xexpression:c method:m classes?:k covers?:v
									-> `(law ,n ,b ,c ,(car m) ,(cadr m) ,(car k) ,(car v))
		| "law"       keyword xidentifier:n ":"_ "mutants" keyword "of" keyword xidentifier:r "by" keyword "exhaustion" keyword
		  ( "size" keyword number )?:s "."_ names:l			-> `(adequacy ,n ,r ,(car s) ,@l)
		;

bindings	= binding:a (","_ binding)*:b					-> `(,a ,@b) ;
binding		= "let" keyword xidentifier:n "="_ xarg:v			-> `(law-let ,n ,v)
		| names:n ":"_ domain:d						-> `(law-bind ,n ,d)
		| expression:e							-> `(law-bind () ,e)
		;
domain		= goal
		| idpart:g "."idpart:r _					-> `(law-grammar ,g ,r)
		| identifier
		;
method		= ( "by" keyword ( "test" keyword -> 'test | "exhaustion" keyword -> 'exhaustion ):m
		    ( "size" keyword number )?:s -> `(,m ,@s) )?:m		-> (car m) ;

classes		= "classify" keyword class:a (","_ class)*:b			-> `(,a ,@b) ;
class		= xidentifier:n "when" keyword xexpression:e			-> `(,n ,e) ;
covers		= "cover" keyword share:a (","_ share)*:b			-> `(,a ,@b) ;
share		= number:p "%"_ xidentifier:n					-> `(,p ,n) ;

entry		= item:i gap							-> i ;
program		= gap entry*:p (!. ~"item")					-> p ;
