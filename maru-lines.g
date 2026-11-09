# maru-lines.g -- Maru's source text read to the forms eval.c's reader makes, each list's first pair holding its span (a
# <source-span>, maru-lines.l) in its source, where eval.c's reader holds (path . line); path names the file and starts says
# where each of its lines starts.
<maru-lines> : <text-parser> (path starts)
blank		= [ \t\r\n] | ";" (![\n\r] .)* ;
_		= blank* ;
at		= -> (<text-parser>-position self) ;
hex		= [0-9A-Fa-f] ;
escape		= "\\" ( "a" -> 7 | "b" -> 8 | "f" -> 12 | "n" -> 10 | "r" -> 13 | "t" -> 9 | "v" -> 11
		       | "u" (hex hex hex hex) @$#16
		       | "x" (hex hex?) @$#16
		       | ([0-7] [0-7]? [0-7]?) @$#8
		       | . ) ;
char		= escape | . ;
string		= "\"" (!"\"" char)*:cs "\""			-> (maru-lines-string cs) ;
character	= "?" char ;
digits		= [0-9]+ ;
exponent	= "e" "-"? [0-9]* ;
number		= "0x" (hex*) @$#16
		| ("-"? digits ("." [0-9]* exponent? | exponent)) @$:s	-> (string->double s)
		| ("-"? digits) @$:s				-> (string->long s) ;
delimiter	= [ \t\r\n()[\]{}"'`,;] ;	# one class, not a dozen alternatives: every character of every symbol meets it
symbol		= (!delimiter .)+ @$:s				-> (string->symbol s) ;
items		= (form:f _ -> f)* ;
list		= at:s "(" _ items:fs ")" at:e			-> (maru-lines-list fs s e self.path self.starts)
		| at:s "[" _ items:fs "]" at:e			-> (maru-lines-list (cons 'bracket fs) s e self.path self.starts)
		| at:s "{" _ items:fs "}" at:e			-> (maru-lines-list (cons 'brace fs) s e self.path self.starts) ;
quoted		= "'" _ form:f					-> (list 'quote f)
		| "`" _ form:f					-> (list 'quasiquote f)
		| ",@" _ form:f					-> (list 'unquote-splicing f)
		| "," _ form:f					-> (list 'unquote f) ;
form		= list | quoted | string | character | number | symbol ;
file		= _ items:fs !.					-> fs ;
