# A generated program of puts, removes and gets (check/laws/hash.law), run on a table and its model alike.
# A key is made afresh each time it is named, so an identity table sees two mentions of str(1) as two keys.
<hash-ops> : <source-parser> ()
run	= `( 'seq op run ) | 'End ;
op	= `( 'put key:k .:v )		-> (ops-put k v)
	| `( 'remove key:k )		-> (ops-remove k)
	| `( 'get key:k )		-> (ops-get k)
	| `( 'grow .:n )		-> (ops-grow n)
	;
key	= 'Nil				-> ()
	| `( 'num .:n )			-> n
	| `( 'dbl .:n )			-> (ops-double n)	# tpeg's actions read no float literal
	| `( 'str .:n )			-> (concat-string "k" (long->string n))
	| `( 'sym .:n )			-> (string->symbol (concat-string "s" (long->string n)))
	| `( 'pair .:a .:b )		-> (cons a b)
	;
