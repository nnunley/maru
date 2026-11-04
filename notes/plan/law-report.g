# What check/law.l prints, law by law: its line for each law, as the kind and fields of an Evidence value.
<lawreport> : <text-parser> ()
eol		= "\n" ;
rest		= (!eol .)* $ ;
number		= [0-9]+ $:d					-> (string->long d) ;
name		= [a-zA-Z0-9_-]+ $:s				-> (string->symbol s) ;
verdict		= "TESTED " number:n eol			-> `(tested (trials: ,n))
		| "PROVED " number:n eol			-> `(proved (cases: ,n))
		| "REFUTED " rest:r eol				-> `(refuted (counterexample: ,r))
		| "STARVED " number:m " of " number:n eol	-> `(starved (met: ,m) (drawn: ,n))
		| "VACUOUS" eol					-> '(vacuous)
		| "INCONCLUSIVE " rest:r eol			-> `(inconclusive (input: ,r))
		| rest eol					-> '(failed) ;
line		= "law " name:n ": " verdict:v			-> (cons n v)
		| rest eol					-> () ;
report		= line*:ls					-> ls ;
