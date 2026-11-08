# erosion-complexity.g -- a callable's cyclomatic complexity (McCabe), read from its form as a tree: one for each decision,
# which erosion.l's table names, each cond clause but an else, and each and or or operand past the first.
<erosion-complexity> : <source-parser> ()
form		= `( 'quote .:x )				-> 0
		| `( 'quasiquote template:t )			-> t	# the code it makes isn't the callable's
		| `( 'cond clause*:cs )				-> (erosion-sum cs)
		| `( ('and | 'or) form:a form*:fs )		-> (+ (list-length fs) (+ a (erosion-sum fs)))
		| `( decision form*:fs )			-> (+ 1 (erosion-sum fs))
		| `( form*:fs )					-> (erosion-sum fs)
		| .						-> 0 ;
decision	= .:op &-> (erosion-decision? op) ;
clause		= `( 'else form*:fs )				-> (erosion-sum fs)
		| `( form*:fs )					-> (+ 1 (erosion-sum fs))
		| form ;
template	= `( ('unquote | 'unquote-splicing) form:f )	-> f	# an unquoted part is
		| `( template*:ts )				-> (erosion-sum ts)
		| .						-> 0 ;
