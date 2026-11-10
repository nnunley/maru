# maru-token-forms.g -- the forms Maru's reader makes, read from maru-tokens.g's tokens (source-tokens.l): a tree grammar over
# the array of tokens, a comment between forms skipped, a list's dot as eval.c reads it; each list's opening and closing
# tokens are kept in ranges, by the list, where its text begins and ends.
<maru-token-forms> : <source-parser> (ranges)
forms		= form*:fs skip !.					-> fs ;
skip		= (.:t &-> (token-kind? t 'comment))* ;
items		= form*:xs skip						-> xs ;
form		= skip ( is_open:o items:xs is_close:c			-> (token-forms-range self o c (token-forms-list xs))
		       | is_bracket:o items:xs is_close:c		-> (token-forms-range self o c (cons 'bracket (token-forms-list xs)))
		       | is_brace:o items:xs is_close:c			-> (token-forms-range self o c (cons 'brace (token-forms-list xs)))
		       | is_prefix:q form:f				-> (list q f)
		       | is_atom:t					-> (token-forms-atom t) ) ;
is_open		= .:t &-> (token-kind? t 'open)	-> t ;
is_bracket	= .:t &-> (token-kind? t 'open-bracket)	-> t ;
is_brace	= .:t &-> (token-kind? t 'open-brace)	-> t ;
is_close	= .:t &-> (token-kind? t 'close)	-> t ;
is_prefix	= .:t &-> (memq (<token>-kind t) '(quote quasiquote unquote unquote-splicing)) -> (<token>-kind t) ;
is_atom		= .:t &-> (memq (<token>-kind t) '(symbol number string char)) -> t ;
