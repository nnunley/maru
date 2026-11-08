# erosion-lines.g -- which of a file's lines hold code (erosion.l): t for one that does, () for one that's blank or only a
# comment.
<erosion-lines> : <text-parser> ()
space		= [ \t\r] ;
comment		= ";" (![\n] .)* ;
end		= "\n" | !. ;
line		= space* comment? "\n"				-> ()
		| space* comment !.				-> ()
		| (![\n] .)+ end				-> 't ;
lines		= line*:ls !.					-> ls ;
