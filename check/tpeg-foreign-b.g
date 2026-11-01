# Calls check/tpeg-foreign-a.g's num on its own input, as fa-num.
<fb> : <text-parser> ()

sum	= fa-num:a "+" fa-num:b -> (+ a b) ;
