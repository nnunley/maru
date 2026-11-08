# erosion-ledger.g -- check/erosion's ledger (erosion.l): each line an entry, the metric it moves, by how much, per mille,
# and why; a blank line is no entry.
<erosion-ledger> : <text-parser> ()
gap		= [ \t]+ ;
metric		= "erosion" -> 'erosion | "verbosity" -> 'verbosity ;
sign		= "-" -> -1 | "+" -> 1 | -> 1 ;
change		= sign:g ([0-9]+) @$:s				-> (* g (string->long s)) ;
reason		= (![\n] .)+ @$ ;
entry		= metric:m gap change:n gap reason:r		-> (make <ledger-entry> metric: m change: n reason: r) ;
line		= [ \t]* ("\n" -> () | entry:e ("\n" | !.) -> e) ;
ledger		= line*:es !.					-> es ;
