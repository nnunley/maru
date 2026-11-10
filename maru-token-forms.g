# maru-token-forms.g -- the forms Maru's reader makes, read from maru-tokens.g's tokens (source-tokens.l): a tree grammar over
# the array of tokens, a comment between forms skipped, a list's dot as eval.c reads it.
<maru-token-forms> : <source-parser> ()
forms		= form*:fs skip !.					-> fs ;
skip		= (.:t &-> (token-kind? t 'comment))* ;
items		= form*:xs skip						-> xs ;
form		= skip ( is_open items:xs is_close			-> (token-forms-list xs)
		       | is_bracket items:xs is_close			-> (cons 'bracket (token-forms-list xs))
		       | is_brace items:xs is_close			-> (cons 'brace (token-forms-list xs))
		       | is_prefix:q form:f				-> (list q f)
		       | is_atom:t					-> (token-forms-atom t) ) ;
is_open		= .:t &-> (token-kind? t 'open) ;
is_bracket	= .:t &-> (token-kind? t 'open-bracket) ;
is_brace	= .:t &-> (token-kind? t 'open-brace) ;
is_close	= .:t &-> (token-kind? t 'close) ;
is_prefix	= .:t &-> (memq (<token>-kind t) '(quote quasiquote unquote unquote-splicing)) -> (<token>-kind t) ;
is_atom		= .:t &-> (memq (<token>-kind t) '(symbol number string char)) -> t ;
