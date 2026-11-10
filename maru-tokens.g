# maru-tokens.g -- Maru's source text divided as eval.c's reader divides it (source-tokens.l), each token a <token> of its
# kind, text and place.  It inherits tpeg's lexical rules where they agree with eval.c (blank, eol, scomment, digit, higit)
# and has its own where Maru's reader differs: a symbol is any run of letters (eval.c's table: , and ? among them, past its
# first), a number may be a double, and a character escape follows eval.c's readChar.  Rules answer values, nothing kept
# by actions; the value rules read a string's or character's value from its text.
<maru-tokens> : <tpeg> ()
at		= -> (<text-parser>-position self) ;
gap		= blank | eol ;
tokens		= (gap* token:t -> t)*:ts gap* !.			-> ts ;
token		= at:s kind:k at:e					-> (maru-token self k s e) ;
kind		= "("							-> 'open
		| "["							-> 'open-bracket
		| "{"							-> 'open-brace
		| [)\]}]						-> 'close
		| scomment						-> 'comment
		| "\"" (!"\"" escaped)* "\""				-> 'string
		| "?" escaped						-> 'char
		| "'"							-> 'quote
		| "`"							-> 'quasiquote
		| ",@"							-> 'unquote-splicing
		| ","							-> 'unquote
		| number						-> 'number
		| symbol						-> 'symbol ;
delimiter	= [ \t\n\r()[\]{}"'`;] ;
symbol		= !digit !"?" !"," (!delimiter .)+ ;
exponent	= "e" "-"? digit* ;
number		= "-"? digit+ ("." digit* exponent? | exponent)
		| digit "x" higit*
		| "-"? digit+ ;
escaped		= "\\" ( "a" -> 7 | "b" -> 8 | "f" -> 12 | "n" -> 10 | "r" -> 13 | "t" -> 9 | "v" -> 11
			| "u" (higit higit higit higit) @$#16
			| "x" (higit higit?) @$#16
			| ([0-7] [0-7]? [0-7]?) @$#8
			| . )
		| . ;
string_value	= "\"" (!"\"" escaped)*:cs "\""				-> (list->string cs) ;
char_value	= "?" escaped:c						-> c ;
