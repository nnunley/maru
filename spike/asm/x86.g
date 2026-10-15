# Intel SDM opcode-table rows -> (MNEMONIC (operand-kind...) (opcode-token...))

<x86spec> : <text-parser> ()

blank	= [\t ] ;
eol	= "\n""\r"* | "\r""\n"* ;
comment	= "#" (!eol .)* ;
_	= blank* ;
__	= (blank | comment | eol)* ;
end	= ![A-Za-z0-9/+] _ ;
hex	= [0-9A-F] ;

opcode	= (hex hex) @$#16:b ( "+r" [bwd] end	-> `(+r ,b)
			    | end		-> b )
	| "/r" end				-> 'r
	| "/" [0-7] @$#:n end			-> `(/ ,n)
	| ("ib" | "iw" | "id" | "cb" | "cd" | "o32") @$$:x end	-> x ;

mnemonic = ([A-Z] [A-Z0-9]*) @$$:m _		-> m ;
kind	= ([A-Za-z0-9/]+) @$$:k _		-> k ;
kinds	= kind:a ("," _ kind)*:b		-> (cons a b)
	|					-> () ;

row	= opcode+:o mnemonic:m kinds:k eol __	-> (list m k o) ;
file	= __ row*:r !.				-> r ;
