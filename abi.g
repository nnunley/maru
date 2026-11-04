# abi.spec: isa, a tab, what the row is, a tab, its registers
<abispec> : <text-parser> ()
eol	= "\n" ;
comment	= "#" (!eol .)* eol ;
blank	= " " | "\t" ;
word	= ([A-Za-z0-9]+) @$$ ;
regs	= (blank* word:w -> w)*:r -> r ;
row	= word:isa blank+ word:kind regs:r blank* eol -> (list isa kind r) ;
file	= (comment | row:r -> r)*:rows !. -> rows ;
