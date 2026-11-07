# A generated program of puts, removes and gets (check/laws/hash.law), run on a table and its model alike.
# A key is made afresh each time it is named, so an identity table sees two mentions of str(1) as two keys; kept(n) is
# one object however often it is named.
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
	| `( 'pair key:a key:b )		-> (cons a b)
	| `( 'deep .:n )		-> (ops-deep n)
	| `( 'neg .:n )			-> (- 0 n)
	| `( 'big .:n )			-> (+ 9007199254740992 n)	# 2^53 and past, where a double rounds
	| `( 'bigdbl .:n )		-> (ops-double (+ 9007199254740992 n))
	| `( 'half .:n )		-> (ops-half n)
	| `( 'kept .:n )		-> (ops-kept n)		# the same object each time it is named
	| 'Min				-> (ops-min)
	;
