# JSON (RFC 8259) to Maru values: an object is (object (key . value) ...) in order, an array a list, a string a
# string (a \u escape as UTF-8), a whole number a long, any other number a double, and true, false and null symbols.
<json> : <text-parser> ()
_		= [ \t\r\n]* ;
hex4		= ([0-9A-Fa-f] [0-9A-Fa-f] [0-9A-Fa-f] [0-9A-Fa-f]) @$#16 ;
char		= "\\" ( "\"" -> 34 | "\\" -> 92 | "/" -> 47 | "b" -> 8 | "f" -> 12
		       | "n" -> 10 | "r" -> 13 | "t" -> 9
		       | "u" hex4:u -> (cons 'u u) )
		| !"\"" !"\\" . ;
string		= "\"" char*:cs "\"" _				-> (json-text cs) ;
digits		= [0-9]+ ;
number		= ("-"? digits ("." digits)? [eE] [-+]? digits | "-"? digits "." digits) @$:s _	-> (string->double s)
		| ("-"? digits) @$:s _				-> (string->long s) ;
pair		= string:k ":" _ value:v			-> (cons k v) ;
object		= "{" _ (pair:p ("," _ pair)*:ps -> (cons p ps) | -> ()):m "}" _	-> (cons 'object m) ;
array		= "[" _ (value:v ("," _ value)*:vs -> (cons v vs) | -> ()):m "]" _	-> m ;
value		= string | number | object | array
		| "true" _ -> 'true | "false" _ -> 'false | "null" _ -> 'null ;
document	= _ value:v !. -> v ;
