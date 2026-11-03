# Warth's trans: a node's head picks the rule, by name.
<nullp> : <text-parser> ()
trans = `( .:t {apply t}:a ) -> a ;
add = trans:x trans:y -> `(add ,x ,y) ;
one = -> '(one) ;
tail2 = "z" -> 'parent ;
named :n = {apply n}:r -> (list 'by-name r) ;
direct = {named 'tail2}:r -> r ;
