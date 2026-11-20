# ledger.g -- check/ledger (ledger.l): each line an entry, the measure it moves (lines, erosion or verbosity), by how much,
# and why (an entry naming no measure is a lines entry, as check/lines wrote them).  A line that starts with whitespace
# continues the one before it, as Python's indentation does; a line of whitespace only is blank.  A line
# include: PATH [SUMMARY [@ ID]] brings in the ledger at PATH: SUMMARY its sums (lines 68429, erosion 388), ID its git
# blob id when the summary was written.  check/ledger includes check/lines and check/erosion, the two ledgers before they
# were one, kept as they were.
<ledger> : <text-parser> ()
space		= [ \t] ;
fold		= "\n" space+ &(!space ![\n] .) ;			# a continuation: a newline, indentation, then text
gap		= (space | fold)+ ;
text		= (![\n] .)+ @$ ;
long_text	= text:t (fold text:u -> u)*:us				-> (ledger-join t us) ;
token		= (![ \t\n] .)+ @$ ;
metric		= "lines" -> 'lines | "erosion" -> 'erosion | "verbosity" -> 'verbosity ;
sign		= "-" -> -1 | "+" -> 1 | -> 1 ;
change		= sign:g ([0-9]+) @$:s					-> (* g (string->long s)) ;
entry		= (metric:m gap -> m)?:m change:n (gap long_text)?:r	-> (make <ledger-entry> metric: (if m (car m) 'lines) change: n reason: (car r)) ;
item		= metric:m gap change:n					-> (cons m n) ;
summary		= item:i ("," gap? item)*:is				-> (cons i is) ;
include		= "include: " token:p
		  (gap summary:s (gap "@" gap? token)?:f -> (cons s (car f)))?:sf	-> (list 'include p (car (car sf)) (cdr (car sf))) ;
eol		= space* ("\n" | !.) ;
line		= space* "\n"						-> ()
		| space+ !.						-> ()
		| include:x eol						-> x
		| entry:e eol						-> e ;
ledger		= line*:es !.						-> es ;
