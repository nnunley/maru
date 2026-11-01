# A grammar whose rule check/tpeg-foreign-b.g calls, as fa-num.
<fa> : <text-parser> ()

num	= [0-9]+ @$#:n -> n ;
