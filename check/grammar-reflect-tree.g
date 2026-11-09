# A tree grammar with a parameterised rule: tpeg rewrites a parameter as a match on the input when it compiles the rule.
<reflect-tree> : <source-parser> ()
take :n		= .:x -> (list n x) ;
