# erosion-verbose.g -- Maru's verbose patterns, verbosity's rules (erosion.l), each named for what it flags.
<erosion-verbose> : <source-parser> ()
flag		= `( 'if .:c `( 'quote 't ) nil? )		-> 'if-t-nil
		| `( 'if .:c nil `( 'quote 't ) )		-> 'if-nil-t
		| `( 'let nil .:x )				-> 'empty-let
		| `( 'not `( 'not .:x ) )			-> 'not-not
		| `( 'cond `( .:c .:x ) `( 'else .:y ) )	-> 'one-cond
		| `( '= .:x nil )				-> 'eq-nil
		| `( '= nil .:x )				-> 'eq-nil
		| .						-> () ;	# nothing to flag
nil		= .:n &-> (not n) ;
