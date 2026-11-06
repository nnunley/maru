# A formula's value at x: whole numbers, / dropping the fraction.  Dividing by zero doesn't match, so it has no value.
<formulavalue> : <source-parser> (x)
value :x	= -> (set self.x x) term ;
term		= `( '+ term:a term:b )			-> (+ a b)
		| `( '- term:a term:b )			-> (- a b)
		| `( '* term:a term:b )			-> (* a b)
		| `( '/ term:a term:b &-> (!= b 0) )	-> (/ a b)
		| 'x					-> self.x
		| .:n &-> (long? n)			-> n ;
