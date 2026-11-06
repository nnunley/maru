# What call by meaning reads from a model's reply.  A formula is x, whole numbers, + - * / with the usual precedence,
# unary minus and parentheses, read to (op a b) trees, left-associated; nothing else parses, so a formula can only
# compute.  A name is the first word of a reply, past numbering, quotes and emphasis.
<meaning> : <text-parser> ()
_		= [ \t]* ;
sum		= product:a (_ ("+" -> '+ | "-" -> '-):o product:b -> (list o b))*:r	-> (formula-left a r) ;
product		= unary:a (_ ("*" -> '* | "/" -> '/):o unary:b -> (list o b))*:r	-> (formula-left a r) ;
unary		= _ "-" unary:a			-> (list '- 0 a)
		| atom ;
atom		= _ "(" sum:s _ ")"		-> s
		| _ [0-9]+ @$#10:n		-> n
		| _ "x" ![A-Za-z0-9_]		-> 'x ;
formula		= _ "`"? sum:f _ "`"? _ ("\n" .*)? !.	-> f ;
name		= [ \t\r\n*`"'0-9.)]* ([A-Za-z_] [A-Za-z0-9_-]*) @$:s	-> s ;
