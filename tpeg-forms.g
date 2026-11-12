# tpeg-forms.g -- maru-forms.g's walk extended to grammars (erosion.l): a grammar's form, as a .g file reads (erosion-read-file)
# or a tpeg-repl.l block makes it, (grammar-define name parent fields rule...), (grammar-extend name rule...) or
# (grammar-eval (rule...) expression), and each rule (name body parameters annotations), a callable.  A rule's tree is
# tpeg's: each node a form, and a decision each repetition and each predicate, and in a choice (match-first) each
# alternative tried in turn after the first, those led by distinct literals tried at once, one lookup (forms-choice).  An action, a predicate's expression and a call's arguments are Maru, walked as maru-forms.g walks code; an
# object literal is data.  A rule's parameters and the names its matches bind are variables, for clone renaming.  Each
# rule's answer is kept (forms-rule), so its callable reuses the grammar's walk.
<tpeg-forms> : <maru-forms> ()
inner		= 'grammar-define . . params:f rule*:rs		-> (forms-sum (cons f rs))
		| 'grammar-extend . rule*:rs			-> (forms-sum rs)
		| 'grammar-eval rules:r node:e !.		-> (forms-sum (list r e))
		| {super inner} ;
rules		= &.:x &-> (pair? x) `( rule*:rs )		-> (forms-list self x (forms-sum rs))
		| nil						-> *forms-none* ;
rule		= &.:x &-> (pair? x) `( . node:b params:p .* )	-> (forms-rule self x (forms-sum (list b p))) ;
node		= &.:x &-> (pair? x) `( node_inner:r )		-> (forms-list self x r)
		| .						-> *forms-none* ;
node_inner	= 'match-first &(lead*:ks) node*:ns		-> (forms-choice ks ns)
		| ('match-zero-one | 'match-zero-more | 'match-one-more | 'peek-not | 'peek-for) node:n !.
								-> (forms-decide (list n))
		| 'peek-expr form:f !.				-> (forms-decide (list f))
		| 'result-expr form:f !.			-> (forms-sum (list f))
		| 'match-rule . form*:fs			-> (forms-sum fs)
		| ('match-rule-in | 'match-object | 'match-string | 'match-class) .*	-> (forms-sum ())
		| 'assign-result var node:n !.			-> (forms-sum (list n))
		| 'make-number . node:n !.			-> (forms-sum (list n))
		| 'match-require node:n . !.			-> (forms-sum (list n))
		| node*:ns					-> (forms-sum ns) ;
# the literals an alternative is led by, its keys in a lookup on the next element: a string's first character, an object, a list pattern's
# head (marked as a list's), through a sequence's first match, a binding or a conversion; a choice of literals is all of
# its alternatives' keys.  () if it's led by anything else.
lead		= &.:x &-> (pair? x) `( lead_inner:k )		-> k
		| .						-> () ;
lead_inner	= 'match-string .:s !.				-> (forms-string-keys s)
		| 'match-object .:d !.				-> (list (cons 'object d))
		| 'match-list lead:k !.				-> (forms-keys-in 'list k)
		| 'match-all lead:k .*				-> k
		| ('assign-result | 'make-number) . lead:k !.	-> k
		| ('make-span | 'make-string | 'make-symbol) lead:k !.	-> k
		| 'match-require lead:k . !.			-> k
		| 'match-first lead*:ks !.			-> (forms-keys-all ks)
		| .*						-> () ;
