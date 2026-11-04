# The same program, on a model with nothing to undo: a state is a value, and a failed body's is thrown away.
<gc-model> : <source-parser> ()
run	= `( 'seq op run ) | 'End ;
op	= `( 'global .:s .:v )		-> (model-put (list 'g (% s 3)) v)
	| `( 'car .:s .:v )		-> (model-put (list 'car (% s 4)) v)
	| `( 'cdr .:s .:v )		-> (model-put (list 'cdr (% s 4)) v)
	| `( 'slot .:i .:v )		-> (model-array (% i 64) v)
	| `( 'char .:i .:v )		-> (model-char (% i 64) (+ ?a (% v 26)))
	| `( 'captured .:v )		-> (model-put 'captured v)
	| 'Collect			-> ()
	| 'Churn			-> ()
	| `( 'ended .:p )		-> (model-run p)
	| `( 'failed .:p )		-> (model-discard p)
	| `( 'thrown .:p )		-> (model-discard p)
	;
