# Memos and left recursion on a source that isn't text.
<mt> : <source-parser> (count)
sum = sum:a 'plus .:b -> (+ a b) | .:n -> n ;
counted = -> (set self.count (+ 1 (or self.count 0))) `( 'x ) ;
twice = &counted counted ;
same = `( counted2 ) `( counted2 ) ;
counted2 = -> (set self.count (+ 1 (or self.count 0))) 'x ;
