# A left-recursive rule, used as the entry rule by check/peg-lr.l.
<lr> : <text-parser> ()

prim	= [0-9]:d -> (- d ?0) ;
add	= add:a "+" prim:b -> `(+ ,a ,b)
	| prim ;
