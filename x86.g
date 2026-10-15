# Intel SDM opcode-table rows -> (MNEMONIC (kind...) (opcode-token...) valid64 valid32)
#
# Columns are separated by tabs: opcode, instruction, then the SDM's "64-bit
# mode" and "Compat/Leg mode" columns (V valid, I invalid, NE not encodable).
# Within a column, spaces separate tokens.

<x86spec> : <text-parser> ()

sp	= " "* ;
col	= "\t"+ ;
eol	= "\n""\r"* | "\r""\n"* ;
comment	= "#" (!eol .)* ;
__	= ([\t ] | comment | eol)* ;
end	= ![A-Za-z0-9/+.] sp ;
hex	= [0-9A-F] ;

opcode	= "REX.W" sp "+" sp					-> `rexw
	| "REX" sp "+" sp					-> `rex
	| (hex hex) @$#16:b ( "+r" [bwdo] end			-> `(+r ,b)
			    | end				-> b )
	| "/r" end						-> `r
	| "/" [0-7] @$#:n end					-> `(/ ,n)
	| ("ib" | "iw" | "id" | "io" | "cb" | "cd" | "o32" | "u") @$$:x end	-> x ;

mnemonic = ([A-Z] [A-Z0-9]*) @$$:m sp				-> m ;
kind	= ([A-Za-z0-9/]+) @$$:k sp				-> k ;
kinds	= kind:a ("," sp kind)*:b				-> (cons a b)
	|							-> () ;
valid	= ("NE" | "V" | "I") @$$:v sp				-> v ;

row	= opcode+:o col mnemonic:m kinds:k col valid:a valid:b eol __	-> (list m k o a b) ;
file	= __ row*:r !.						-> r ;
form	= sp mnemonic:m kinds:k !.				-> (list m k) ;
