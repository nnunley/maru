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
# a choice of list patterns tries only those whose first element is a literal the element's head is, and those with
# none, in their order: a head that isn't a symbol tries them all
pick = `( 'a .:x ) -> (list 'a x) | `( 'b .:x ) -> (list 'b x) | `( .:h 'c ) -> (list 'any-c h) | `( 'c .:x ) -> (list 'c x)
     | `( 'd ) -> 'd | `( 'e ) -> 'e | `( 'f ) -> 'f | `( 'g ) -> 'g | .:o -> (list 'other o) ;
