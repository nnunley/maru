# An HTTP/1.x response that succeeded: the body after a 200's headers.  Anything else doesn't match.
<httpreply> : <text-parser> ()
eol	= "\r\n" ;
line	= (!eol .)* eol ;
reply	= "HTTP/1." [01] " 200" line (!eol line)* eol .*:b	-> (list->string b) ;
