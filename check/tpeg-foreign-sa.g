# A foreign rule lends the input and takes it back; fields and memos stay apart.
<sa> : <source-parser> (seen)
expr = -> (set self.seen 1) (.:x -> (list (quote from-a) x)) ;
