# check/source/symbols.g -- a tree grammar over a definition's tokens (check/source-tokens.l): how many are symbols
<source-symbols> : <source-parser> ()
count		= (symbol -> 1 | . -> 0)*:ns !.			-> (let ((n 0)) (list-do x ns (set n (+ n x))) n) ;
symbol		= .:t &-> (token-kind? t 'symbol) ;
