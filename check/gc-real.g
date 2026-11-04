# A generated program, compiled to a list of closures over real objects (check/laws/gc-model.l), so running it allocates
# only what its own operations do, not what parsing does.
<gc-real> : <source-parser> ()
run	= `( 'seq op:a run:b )		-> (cons a b)
	| 'End				-> () ;
op	= `( 'global .:s .:v )		-> (lambda () (real-global s v))
	| `( 'car .:s .:v )		-> (lambda () (set-car (real-cell s) v))
	| `( 'cdr .:s .:v )		-> (lambda () (set-cdr (real-cell s) v))
	| `( 'slot .:i .:v )		-> (lambda () (set-array-at real-array (% i 64) v))
	| `( 'char .:i .:v )		-> (lambda () (set-string-at real-text (% i 64) (+ ?a (% v 26))))
	| `( 'captured .:v )		-> (lambda () (real-captured v))
	| 'Collect			-> gc-collect
	| 'Churn			-> (lambda () (churn 200))
	| `( 'ended .:p )		-> (real-ended (real-compile p))
	| `( 'failed .:p )		-> (real-failed (real-compile p))
	| `( 'thrown .:p )		-> (real-thrown (real-compile p))
	;
