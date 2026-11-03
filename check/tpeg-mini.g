# A grammar with nothing new, to run on every source.
<mini> : <text-parser> ()
num = [0-9]+ @$#:n -> n ;
sum = num:a "+" num:b -> (+ a b) ;
any = . ;
word = "abc" ;
