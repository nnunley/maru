# ometaCalc-eval from the DBjr documents (notes/sources/grammars/dbjr-ometacalc-eval.ometa).
<calceval> : <source-parser> (env)
start :e = -> (set self.env e) calc ;
calc = `( ('"+" | '"-" | '"*" | '"/"):op calc:l calc:r ) -> (calc-apply op l r)
     | .:n &-> (calc-digits? n) -> (string->number-base n 10)
     | .:n &-> (calc-letters? n) -> (cdr (assq (string->symbol n) self.env)) ;
