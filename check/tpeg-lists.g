# List patterns and object literals (thesis section 2.4.3).
<trees> : <source-parser> ()
node = `( 'add .:x .:y ) -> (list x y) ;
deep = `( 'add .:x `( 'mul .:y ) ) -> (list x y) ;
empty = `( ) -> 'none ;
word = `( [a-z]+ @$:s ) -> s ;
zero = '0 -> 'got-zero ;
name = '"plus" -> 'got-string ;
two = node node ;
digits = `( [0-9]+ @$#:n ) `( [0-9]+ @$#:m ) -> (+ n m) ;
either = `( 'a 'b ) -> 'ab | `( 'a .* ) -> 'a-any ;
