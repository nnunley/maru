# Calls sa's rule of the same name, on the same input, from inside a list pattern too.
<sb> : <source-parser> (seen)
expr = .:x -> (list 'from-b x) ;
lent = sa-expr:a expr:b -> (list a b) ;
nested = `( sa-expr:a expr:b ) -> (list a b) ;
field = sa-expr:a -> self.seen ;
