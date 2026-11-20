# ledger.g -- check/ledger (ledger.l): each line an entry, the measure it moves (lines, erosion or verbosity), by how much,
# and why (an entry naming no measure is a lines entry, as check/lines wrote them); a blank line is no entry.  A line
# include: PATH brings in the ledger at PATH, anywhere and more than once: check/ledger includes check/lines and
# check/erosion, the two ledgers before they were one, kept as they were.
<ledger> : <text-parser> ()
gap		= [ \t]+ ;
metric		= "lines" -> 'lines | "erosion" -> 'erosion | "verbosity" -> 'verbosity ;
sign		= "-" -> -1 | "+" -> 1 | -> 1 ;
change		= sign:g ([0-9]+) @$:s				-> (* g (string->long s)) ;
reason		= (![\n] .)+ @$ ;
entry		= (metric:m gap -> m)?:m change:n (gap reason)?:r	-> (make <ledger-entry> metric: (if m (car m) 'lines) change: n reason: (car r)) ;
line		= [ \t]* ( "\n"						-> ()
			  | "include: " reason:p ("\n" | !.)			-> (cons 'include p)
			  | entry:e ("\n" | !.)				-> e ) ;
ledger		= line*:es !.					-> es ;
