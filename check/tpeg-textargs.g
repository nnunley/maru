# On text, parameters stay arguments of a rule's method, as nile-grammar.g uses them.
<ta> : <text-parser> ()
pair :a :b = "y" -> (list a b) ;
callp = "x" {pair 1 2}:r -> r ;
