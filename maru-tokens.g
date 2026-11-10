# maru-tokens.g -- Maru's source text as eval.c's reader divides it, into tokens (source-tokens.l): each a <token> with its
# kind, text, place and line, appended to the parser's tokens as it's matched.  A newline moves line on; a comment is a token.
<maru-tokens> : <text-parser> (tokens line)
at		= -> (<text-parser>-position self) ;
newline		= ("\n" "\r"* | "\r" "\n"*)				-> (set self.line (+ self.line 1)) ;
space		= [ \t]+ | newline ;
escape		= "\\" ("u" . . . . | "x" [0-9A-Fa-f]? [0-9A-Fa-f]? | [0-7] [0-7]? [0-7]? | .) ;
char		= escape | . ;
digits		= [0-9]+ ;
number		= "-"? digits ("." [0-9]* ("e" "-"? [0-9]*)? | "e" "-"? [0-9]*)
		| [0-9] "x" [0-9A-Fa-f]*
		| "-"? digits ;
delimiter	= [ \t\n\r()[\]{}"'`;] ;
symbol		= ![0-9?,] (!delimiter .)+ ;
token		= at:s ( "("					-> 'open
		       | "[" -> 'open-bracket | "{" -> 'open-brace
		       | (")" | "]" | "}")			-> 'close
		       | ";" (![\n\r] .)*			-> 'comment
		       | "\"" (!"\"" char)* "\""		-> 'string
		       | "?" char				-> 'char
		       | "'"					-> 'quote
		       | "`"					-> 'quasiquote
		       | ",@"					-> 'unquote-splicing
		       | ","					-> 'unquote
		       | number					-> 'number
		       | symbol					-> 'symbol
		       ):k					-> (maru-token self k s) ;
tokens		= (space | token)* !. ;
