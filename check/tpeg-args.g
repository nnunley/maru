# Arguments on the input: a parameter is a pattern over what the caller pushed.
<argp> : <source-parser> ()
pair :a :b = "y" -> (list a b) ;
callp = "x" {pair 1 2}:r -> r ;
picky = 'yes "y" -> 'matched ;
askp = {picky 'yes}:r -> r ;
askn = {picky 'no}:r -> r ;
nilarg = .:a -> (list 'got a) ;
calln = {nilarg ()}:r -> r ;
zeroarg = .:a -> (list 'got a) ;
callz = {zeroarg 0}:r -> r ;
inner :c = "z" -> c ;
outer :c = {inner c}:r -> (list 'outer r) ;
nest = {outer 7}:r -> r ;
fallback = {picky 'no} | "y" -> 'second ;
overlist = `( {pair 1 2}:r ) -> r ;
readsone = .:a -> a ;
leaves = {readsone 1 2} ;
readsnone = -> (quote nothing) ;
leavesall = {readsnone 1} ;
