# maru-forms.g -- one walk over a form as Maru's reader made it (erosion.l), each list entered once and decided by its head.
# A list answers (cc forms flag): its cyclomatic complexity (McCabe: one for each decision, each cond clause but an else,
# each and or or operand past the first, though clauses testing one variable against distinct constants are one lookup), how many forms it holds (pairs outside quoted data, itself among them), and the
# verbose pattern it matches, if any (forms-list records that in the parser's flags, by the list).  () is NIL, an atom
# (McCarthy's atom[NIL], Maru's pair?), so a form is a pair; input.l lets a list pattern enter () as an empty list, hence
# each pair? test.  A pattern ends with !., the list's end, so a longer list goes on to the general alternatives.  Quoted
# data is no form and no code; a quasiquote, unquote or unquote-splicing is the reader's syntax, so it's no form either,
# though the lists under it are.  A template's decisions belong to the code it makes, an unquoted part's to the callable.
# The variables the form binds (parameters, lets, loop variables) are added to binders as they're met, for erosion.l's
# clone renaming.
<maru-forms> : <source-parser> (binders flags)
form		= &.:x &-> (pair? x) `( inner:r )		-> (forms-list self x r)
		| .						-> *forms-none* ;
inner		= 'quote .					-> 'data
		| 'quasiquote template:t			-> (forms-reader t)
		| ('unquote | 'unquote-splicing) form:f		-> (forms-reader f)
		| 'if form:c `( 'quote 't ) nil? !.		-> (forms-flag 'if-t-nil (forms-decide (list c)))
		| 'if form:c nil `( 'quote 't ) !.		-> (forms-flag 'if-nil-t (forms-decide (list c)))
		| 'let nil form:x !.				-> (forms-flag 'empty-let x)
		| 'not `( 'not form:x ) !.			-> (forms-flag 'not-not (forms-one x))
		| 'cond `( form:c form:x ) `( 'else form:y ) !.
								-> (forms-flag 'one-cond (forms-clauses (list (forms-one (forms-decide (list c x))) (forms-one y))))
		| '= form:x nil !.				-> (forms-flag 'eq-nil x)
		| '= nil form:x !.				-> (forms-flag 'eq-nil x)
		| 'cond &(test*:ks) clause*:cs			-> (forms-cond ks cs)
		| ('and | 'or) form:a form*:fs			-> (forms-operands (cons a fs))
		| 'lambda params:p form*:fs			-> (forms-sum (cons p fs))
		| ('define-function | 'define-form) . params:p form*:fs	-> (forms-sum (cons p fs))
		| 'define-method . . params:p form*:fs		-> (forms-sum (cons p fs))
		| ('let | 'let*) bindings:b form*:fs		-> (forms-sum (cons b fs))
		| 'for `( var form*:fs ) form*:gs		-> (forms-decide (cons (forms-one (forms-sum fs)) gs))
		| loop var form*:fs				-> (forms-decide fs)
		| decision form*:fs				-> (forms-decide fs)
		| form*:fs					-> (forms-sum fs) ;
nil		= .:n &-> (not n) ;
decision	= .:op &-> (erosion-decision? op) ;
loop		= .:op &-> (memq op '(list-do array-do string-do alist-do lists-do namespace-do)) ;
params		= .:ps						-> (forms-params self ps) ;	# a dotted rest too
var		= .:v						-> (forms-bind self v) ;
bindings	= &.:x &-> (pair? x) `( binding*:bs )	-> (forms-one (forms-sum bs))
		| nil						-> *forms-none* ;
binding		= `( var form*:fs )				-> (forms-one (forms-sum fs))
		| var						-> *forms-none* ;
clause		= `( 'else form*:fs )				-> (forms-one (forms-sum fs))
		| `( form*:fs )					-> (forms-one (forms-decide fs))
		| form ;
template	= &.:x &-> (pair? x) `( template_inner:r )			-> (forms-list self x r)
		| .						-> *forms-none* ;
template_inner	= 'quote .					-> 'data
		| ('unquote | 'unquote-splicing) form:f		-> (forms-reader f)
		| template*:ts					-> (forms-template ts) ;
# a cond clause's test as a lookup key: (= v k) or (= k v), k a constant, answers (v . k); an else answers else
test		= `( 'else .* )					-> 'else
		| `( `( '= .:a .:b !. ) .* )			-> (forms-test-key a b)
		| .						-> () ;
