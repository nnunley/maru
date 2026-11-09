# erosion-binders.g -- the variables a definition binds (parameters, lets, loop variables), which erosion.l renames when it
# looks for clones; each is added to the parser's set as it's met, so nothing is copied up the tree.  A list is entered once
# and its kind chosen inside it, not entered again for each kind it might be.
<erosion-binders> : <source-parser> (vars)
form		= `( inner ) | . ;
inner		= 'quote .
		| 'lambda params form*
		| ('define-function | 'define-form) . params form*
		| 'define-method . . params form*
		| ('let | 'let*) `( binding* ) form*
		| 'for `( var form* ) form*
		| loop var form*
		| form* ;
loop		= .:op &-> (member? op '(list-do array-do string-do alist-do lists-do namespace-do)) ;
params		= .:ps						-> (erosion-bind-all self.vars (erosion-params ps)) ;	# a dotted rest too
var		= .:v						-> (erosion-bind-all self.vars (list v)) ;
binding		= `( var form* )
		| var ;
