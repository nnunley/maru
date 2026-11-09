# A grammar to reflect on: annotated rules (one hyphenated), a parameter, a field; a child (grammar-reflect-child.g) overrides
# one rule and adds another and a field.
<reflect-base> : <text-parser> (a)
@token digit	= [0-9] ;
@decision @left-recursive
pick		= "a" -> 1 | "b" -> 2 ;
pair :x		= digit:d -> (cons x d) ;
