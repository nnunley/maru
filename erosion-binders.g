# erosion-binders.g -- the variables a definition binds (parameters, lets, loop variables), which erosion.l renames when it
# looks for clones.
<erosion-binders> : <source-parser> ()
form		= `( 'quote .:x )				-> ()
		| `( 'lambda params:ps form*:fs )		-> (erosion-join ps fs)
		| `( ('define-function | 'define-form) .:n params:ps form*:fs )	-> (erosion-join ps fs)
		| `( 'define-method .:n .:t params:ps form*:fs )	-> (erosion-join ps fs)
		| `( ('let | 'let*) `( binding*:bs ) form*:fs )	-> (erosion-join (erosion-flat bs) fs)
		| `( 'for `( .:v form*:xs ) form*:fs )		-> (erosion-join (list v) (cons (erosion-flat xs) fs))
		| `( loop .:v form*:fs )			-> (erosion-join (list v) fs)
		| `( form*:fs )					-> (erosion-flat fs)
		| .						-> () ;
loop		= .:op &-> (member? op '(list-do array-do string-do alist-do lists-do namespace-do)) ;
params		= .:ps						-> (erosion-params ps) ;	# a dotted rest parameter too
binding		= `( .:v form*:fs )				-> (cons v (erosion-flat fs))
		| .:v &-> (symbol? v)				-> (list v) ;
