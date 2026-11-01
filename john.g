# -*- coke -*-

# JOHN, Samimi's planning language (VPRI RN-2008-003, M-2009-001, M-2009-008), as
# reconstructed in ~/pkm/wiki/synthesis/john-language-reconstruction.md.  Each
# statement reads to one form; john.l holds the helpers the actions call and the
# relations declared so far (a name is an infix relation only once declared, G6).

<john> : <cexpr> ()

comment		= ";" (&. !eol .)* ;
idpart		= (letter (letter | digit | "-" &letter)*) @ $$ ;
wb		= !(letter | digit | "-") _ ;
reserved	= ( "if" | "is" | "try" | "using" | "use" | "by" | "do" | "consequence" | "establish"
		  | "dynamically" | "maximize" | "minimize" | "and" | "or" | "not" | "for" | "every"
		  | "any" | "some" | "select" | "all" | "one-from" | "satisfy" | "the" ) !(letter | digit | "-") ;
name		= !reserved idpart:x !":" _					-> x ;
kw		= idpart:x ":" _						-> (john-kw x) ;
rel		= name:n &-> (john-relation? n)					-> n ;
class		= name:n &-> (john-class? n)					-> n ;
end		= ("." | "?") _ ;

# expressions, loosest first
expr		= expr:a "or" wb conj:b						-> `(or ,a ,b)
		| conj ;
conj		= conj:a "and" wb neg:b						-> `(and ,a ,b)
		| neg ;
neg		= "not" wb neg:a						-> `(not ,a)
		| compare ;
cmpop		= "<=" -> '<= | ">=" -> '>= | "<" -> '< | ">" -> '> | "=" -> '= ;
compare		= arith:a cmpop:o _ arith:b					-> `(,o ,a ,b)
		| arith:a rel:r arith:b						-> `(rel ,r ,a ,b)
		| arith ;
arop		= "+" -> '+ | "-" -> '- | "*" -> '* | "/" -> '/ ;
arith		= arith:a arop:o _ chain:b					-> `(,o ,a ,b)
		| chain ;
kwpart		= kw:k primary:a						-> (cons k a) ;
chain		= chain:r kwpart+:ps						-> `(send ,r ,(john-selector ps) ,@(map cdr ps))
		| chain:r !rel name:n						-> `(send ,r ,n)
		| prefix
		| primary ;
quant		= "every" wb -> 'every | "any" wb -> 'any ;
pair		= name:v name:p							-> (list v p) ;
prefix		= "for" wb "some" wb class:c "do" wb compare:p			-> `(any (all ,c) ,p)	# ours: for any all C
		| "for" wb "some" wb chain:l "do" wb compare:p			-> `(any ,l ,p)
		| "for" wb quant:q chain:l "do" wb compare:p			-> `(,q ,l ,p)
		| "select" wb "all" wb name:c "by" wb expr:p			-> `(select ,c ,p)
		| "all" wb pair*:ps name:c					-> `(all ,c ,@ps)
		| "one-from" wb chain:s						-> `(one-from ,s) ;
exprs		= expr:a ("," _ expr)*:b					-> `(,a ,@b) ;
primary		= number
		| string
		| "[" _ exprs?:e "]" _						-> `(list ,@(car e))
		| "(" _ expr:e ")" _						-> e
		| "its" wb							-> 'it
		| "the" wb name
		| name ;

# statements
typed		= "*" _ name:t name:p						-> `(* ,t ,p)
		| name:t name:p							-> `(- ,t ,p) ;
tvar		= idpart:t ":" _ name:v						-> (list t v) ;
aparam		= tvar
		| name:t							-> (list t t) ;
kwparam		= kw:k name:p							-> (cons k p) ;
head		= kwparam+:ps							-> (cons (john-selector ps) (map cdr ps))
		| name:n							-> (list n) ;
qbody		= ("if" | "is") wb expr:e					-> `(if ,e)
		| expr:v ("if" wb expr)?:g					-> `(value ,v ,@g) ;
effect		= chain:t "=" _ arith:v ("if" wb compare)?:g			-> (john-effect t v g) ;
effects		= effect:a ("and" wb effect)*:b					-> `(,a ,@b) ;
method		= "maximize" wb -> 'maximize | "minimize" wb -> 'minimize ;
makebody	= "make" wb name:c primary:o primary*:v				-> `(make ,c ,o ,@v) ;

statement	= "start-world" wb name:n end					-> `(start-world ,n)
		| "end-world" wb end						-> '(end-world)
		| "group" wb name:g name+:cs end				-> (john-class g `(group ,g ,@cs))
		| "create" wb idpart:c ":" _ typed:a ("," _ typed)*:b end	-> (john-class c `(create ,c typed ,a ,@b))
		| "create" wb name:c name*:ps end				-> (john-class c `(create ,c ,@ps))
		| makebody:m end						-> m
		| "qualify" wb name:c head:h qbody:b end			-> `(qualify ,c ,(car h) ,(cdr h) ,b)
		| "rel-qualify" wb ("not" wb -> 'not)?:n tvar:a name:r tvar:b "if" wb expr:e end
										-> (john-relation r `(rel-qualify ,(car n) ,a ,r ,b ,e))
		| "action" wb name:c name:a aparam*:ps "consequence" wb effects:es end
										-> `(action ,c ,a ,ps ,@es)
		| "rule" wb name:c name:a ("is" wb)? expr:e end			-> `(rule ,c ,a ,e)
		| "goal-optimization" wb name:c name:g "use" wb name+:as "if" wb expr:e end
										-> `(goal-optimization ,c ,g ,as ,e)
		| "action-optimization" wb name:c name:a ("dynamically" wb -> 'dynamically)?:d "establish" wb expr:e end
										-> `(action-optimization ,c ,a ,(car d) ,e)
		| "heuristic" wb name:c name:g number:w method:m expr:e end	-> `(heuristic ,c ,g ,w ,m ,e)
		| "goal" wb name:c name:g name*:ps "try" wb expr:e end		-> `(goal ,c ,g ,ps ,e)
		| "set-opt" wb name:n primary:v end				-> `(set-opt ,n ,v)
		| "for" wb !quant !("some" wb) expr:l "do" wb (makebody | expr):b end	-> `(for ,l ,b)
		| "at" wb "time" wb primary:t expr:e end			-> `(at-time ,t ,e)
		| "is" wb expr:e end						-> `(is ,e)
		| primary:o "satisfy" wb name:g primary*:as ("using" wb name+)?:u ("by" wb primary)?:b end
										-> `(satisfy ,o ,g ,as ,(car u) ,(car b))
		| name:r "do" wb name:a primary*:as end				-> `(do ,r ,a ,@as)
		| expr:e end							-> `(query ,e) ;

program		= _ statement*:s (!. ~"statement")				-> s ;
