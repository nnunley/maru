# ometaCalc-parse from the DBjr documents (notes/sources/grammars/dbjr-ometacalc-parse.ometa).
<calc> : <text-parser> ()
start = addExpr:e spaces -> e ;
addExpr = addExpr:x ("+" | "-"):op mulExpr:y -> (list op x y)
	| mulExpr ;
mulExpr = mulExpr:x ("*" | "/"):op primExpr:y -> (list op x y)
	| primExpr ;
primExpr = spaces "(" addExpr:x spaces ")" -> x
	| number
	| identifier ;
number = spaces [0-9]+ $:n -> n ;
identifier = spaces ([a-zA-Z] [a-zA-Z0-9]*) @$:n -> n ;
spaces = [ \t]* ;
