# -*- coke -*-

# irl's statements, types and definitions, as Maru forms.  compile-irl.l
# expands irl-let and irl-struct, places top-level statements in main, and
# prints the program for maru.k.

<irl> : <cexpr> ()

xtype		= type       ~"type" ;
xstatement	= statement  ~"statement" ;

primary		= "false" keyword						-> 0
		| "true"  keyword						-> 1
		| identifier
		| number
		| string
		| "("_ xexpression:e ")"_					-> e
		;

prefix		= "*"_ prefix:e							-> `(indir ,e)
		| "&"_ xidentifier:i						-> `(addressof ,i)
		| "struct" keyword xidentifier:a "("_ arglist:b ")"_		-> `(irl-struct ,a ,@b)
		| primary
		;

suffix		= prefix:a ( "("_ arglist:b ")"_				-> `(,a ,@b)		:a
			   | "."_ xidentifier:b					-> `(member ,a ,b)	:a
			   | "["_ xexpression:b "]"_				-> `(indir ,a ,b)	:a
			   )*							-> a
		;

expression	= suffix:l ":="_ xexpression:r					-> (irl-assign l r)
		| conditional
		;

sequence	=  "{"_ statement*:s "}"_					-> `(let () ,@s)
		| "begin" keyword statement*:s "end" keyword			-> `(let () ,@s)
		;

mainclause	= sequence
		|   "if"     keyword xexpression:a
		    "then"   keyword xstatement:b
		  ( "else"   keyword xstatement )? :c					-> `(if ,a ,b ,@c)
		|   "while"  keyword xexpression:e "do" keyword xstatement:s		-> `(while ,e ,s)
		|   "return" keyword xexpression:e ";"_					-> `(return ,e)
		|   "let"    keyword xtype:t xidentifier:i ":="_ xexpression:e ";"_	-> `(irl-let (,i ,@t) ,e)
		|   "for"    keyword type?:t xidentifier:i ":="_ xexpression:a
                  ( "step"   keyword xexpression )?:b
		    "until"  keyword xexpression:c "do" keyword xstatement:s	-> (let ((t (or (car t) '(int))))
											     `(let (((,i ,@t) ,a) ((_s ,@t) ,(or (car b) 1)) ((__ ,@t) ,c))
												(while (<= ,i __) ,s (set ,i (+ ,i _s)))))
		| expression:e ";"_						-> e
		;

statement	= mainclause:s ( "where" keyword xtype:t xidentifier:i
				 ":="_ xexpression:e ";"_			-> `(let (((,i ,@t) ,e)) ,s) :s
			       )?
			       ( "finally" keyword xstatement:f			-> `(let () ,s ,f) :s
			       )?						-> s
		;

primtype	= "void"   keyword						-> '(void)
		| "char"   keyword						-> '(char)
		| "short"  keyword						-> '(short)
		| "int"	   keyword						-> '(int)
		| "long"   keyword						-> '(long)
		| "float"  keyword						-> '(float)
		| "double" keyword						-> '(double)
		| "struct" keyword xidentifier:i				-> `(struct ,i)
		| "("_ type:t ")"_						-> t
		;

param		= type | "..."_							-> irl-varargs ;

typelist	= (param:a (","_ param)*:b -> (concat-list a (irl-concat b)))?:l	-> (if l (car l) irl-varargs) ;

type		= primtype:a ( "*"_						-> `(,@a *)		:a
			     | "("_ typelist:b ")"_				-> `((,@a ,@b))		:a
			     )*							-> a
		;

idlist		= xidentifier:i (","_ xidentifier)*:j				-> `(,i ,@j) ;

mdecl		= type:t idlist:i ";"_						-> (map (lambda (n) `(,n ,@t)) i) ;

decl		= type:t identifier:i						-> `(,i ,@t) ;

paramlist	= decl?:p (","_ decl)*:q					-> `(,@p ,@q) ;

definition	= "struct" keyword xidentifier:i "{"_ mdecl*:d "}"_ ";"_	-> `(define-struct ,i ,(irl-concat d))
		| "import" keyword decl:d ";"_					-> `(define ,d (extern ,(car d)))
		| type:t identifier:i ( ":="_ xexpression:e ";"_		-> `(define (,i ,@t) ,e)
				      | "("_ paramlist:p ")"_ xstatement:e	-> `(define-function ,i ,t ,p ,e)
				      )
		| statement
		;

program		= _ definition*:p (!. ~"definition or expression")		-> p ;
