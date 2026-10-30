# -*- coke -*-

# irl for an older ir.k, whose call, struct and function-type constructors
# take their lists spliced.

<irgol> : <irl> ()

prefix		= "*"_ prefix:e							-> `(ir-get ,e)
		| "&"_ xidentifier:i						-> `(ir-addr ',i)
		| "struct" keyword xidentifier:a "("_ arglist:b ")"_		-> `(ir-struct ',a ,@b)
		| primary
		;

suffix		= prefix:a ( "("_ arglist:b ")"_				-> `(ir-call ,a ,b)		:a
### FIX ME --->		   | "."_ xidentifier:b					-> `(ir-get (ir-member ',b ,a))	:a
			   | "."_ xidentifier:b					-> `(ir-member ',b ,a)	:a
			   | "["_ xexpression:b "]"_				-> `(ir-get (ir-add ,a ,b))	:a
			   )*							-> a
		;

type		= primtype:a ( "*"_						-> `(ir-pointer-to ,a) :a
			     | "("_ typelist:b ")"_				-> `(ir-function-type ir ,a ,@b) :a
			     )*							-> a
		;

fndecl		= type:t identifier:i "("_ paramlist:p ")"_			-> `(ir-fun ',i (ir-function-type ir ,t ,@(param-list-types p))
										      ,@(param-list-decls p)) ;

definition	= "struct" keyword xidentifier:i "{"_ mdecl*:d "}"_ ";"_	-> `(ir-def-struct ir ',i ,@d)
		| "import" keyword decl:d ";"_					-> `(ir-put ir (ir-ext ',(cadr d) ,(car d)))
		| type:t identifier:i ( ":="_ xexpression:e ";"_		-> `(ir-put ir (ir-def ',i ,t ,e))
				      | "("_ paramlist:p ")"_ xstatement:e	-> `(ir-put ir (ir-fun ',i (ir-function-type ir ,t ,@(param-list-types p))
												       ,@(param-list-decls p)
												       ,e))
				      )
		| statement:s							-> `(ir-put ir ,s)
		;
