# A shape, as gc.law's rules generate it, built as the objects it describes.
<gc-shapes> : <source-parser> ()
build	= `( 'pair build:a build:b )	-> (cons a b)
	| `( 'arr build:a build:b )	-> (gc-array a b)
	| `( 'box build:a )		-> (new <gc-box> a)
	| `( 'text .:n )		-> (gc-text n)
	| .:n				-> n ;
