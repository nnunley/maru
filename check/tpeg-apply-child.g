# An inherited rule reaches an override, and an override reaches its parent.
<childp> : <nullp> ()
one = -> '(ONE) ;
tail2 = {super tail2}:p -> (list 'child p) ;
