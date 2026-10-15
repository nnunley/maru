# Arm ARM encoding-diagram rows -> (MNEMONIC (operand...) (field...))

<arm64spec> : <text-parser> ()

blank	= [\t ] ;
eol	= "\n""\r"* | "\r""\n"* ;
comment	= "#" (!eol .)* ;
_	= blank* ;
__	= (blank | comment | eol)* ;

field	= [01]+ @$:b _						-> b
	| ("R" [a-z] [a-z0-9]* | [a-z] [a-z0-9]*) @$$:n
	  ( ":" [0-9]+ @$#:w _ -> (list n w) | _ -> (list n) ) ;

mnemonic = ([A-Z]+ ("." [A-Z]+)?) @$$:m _			-> m ;

scale	= "*" [0-9]+ @$#:n					-> n
	|							-> 1 ;
fref	= ([a-z] [a-z0-9]* (":" [a-z] [a-z0-9]*)*) @$$:f scale:n _	-> (list f n) ;
imm	= "#" ( "bimm" [0-9]+ @$#:w _				-> `(bimm ,w)
	      | "lslimm" [0-9]+ @$#:w _				-> `(lslimm ,w)
	      | "fimm8" _						-> `(fimm imm8)
	      | "s" fref:f						-> `(simm ,@f)
	      | fref:f						-> `(imm ,@f) ) ;
reg	= ([XWSDQBH] [a-z] [a-z0-9]*) @$$:r ( "|SP" _ -> `(reg ,r SP) | _ -> `(reg ,r) ) ;
ext	= "," _ [A-Z]+ @$$:e _ ( "#" [0-9]+ @$#:n _ -> n | -> 0 ):a	-> (list e a) ;
mem	= "[" _ reg:b "," _ reg:x ext?:e "]" _			-> `(mreg ,b ,x ,@(car e))
	| "[" _ reg:b ( "," _ imm:i -> i | -> '(imm imm0 1) ):i "]" _
	  ( "!" _ -> `(pre ,b ,i) | "," _ imm:j -> `(post ,b ,j) | -> `(off ,b ,i) ) ;
operand	= mem | reg | imm
	| "pc+s" fref:f						-> `(pcrel ,@f)
	| "pcpage+s" fref:f					-> `(pcpage ,@f)
		| "LSL" _ "#" fref:f					-> `(lsl ,@f)
	| "invcond" _						-> `(invcond cond)
	| "cond" _						-> `(cond cond) ;
operands = operand:a ("," _ operand)*:b				-> (cons a b)
	|							-> () ;

row	= field+:f mnemonic:m operands:o eol __			-> (list m o f) ;
file	= __ row*:r !.						-> r ;
form	= _ mnemonic:m operands:o !.				-> (list m o) ;
