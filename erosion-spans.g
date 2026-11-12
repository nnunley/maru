# erosion-spans.g -- where tpeg-repl.l --forms says a script's forms start: its lines ;tpeg-form start end among the script's
# own output (erosion.l's erosion-read-script).  A line answers its form's start, or () if it's the script's.
<erosion-spans> : <text-parser> ()
spans		= (&. line)*:ls					-> ls ;
line		= ";tpeg-form " number:s " " number "\n"?	-> s
		| (!"\n" .)* "\n"?				-> () ;
number		= [0-9]+ @$#:n					-> n ;
