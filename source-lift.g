# source-lift.g -- the definitions a file's forms make, read without running them (source.l's file-definitions): each
# definer's form answers a list of <definition>s (source-lift, in source.l), a (let () ...) the definitions in its body,
# anything else none.
<source-lift> : <source-parser> (path)
forms		= form*:ds					-> (source-lift-concat ds) ;
form		= &.:x `( definer:d )				-> (source-lift self d x)
		| `( 'let empty form*:ds )			-> (source-lift-concat ds)
		| .						-> () ;
definer		= 'define-function .:n .*			-> (cons 'function n)
		| 'define-form .:n .*				-> (cons 'form n)
		| 'define-selector .:n .*			-> (cons 'selector n)
		| 'define-method .:n .*				-> (cons 'method n)
		| 'define-apply .:n .*				-> (cons 'apply n)
		| ('define-structure | 'define-class) .:n .*	-> (cons 'type n)
		| ('define | 'set) .:n `( 'lambda .* )		-> (cons 'function n) ;
empty		= .:n &-> (not n) ;
