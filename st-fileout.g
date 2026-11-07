# Squeak's file-out (chunk) format, as ksworld/*.st holds KSWorld's classes: chunks end at a "!" ("!!" is a "!" inside
# one); "!CLASS methodsFor: 'CATEGORY' stamp: '...'!" opens a section of methods, each a chunk, and an empty chunk ends
# it.  A section reads to (section CLASS CATEGORY METHOD...), each method its source; any other chunk (the class
# definition, a comment) to nothing.

<stfileout> : <text-parser> ()

blank		= [ \t\r\n] ;
chunk		= ("!!" -> 33 | !"!" .)* $:t "!"			-> t ;	# a doubled "!" (33) is one
name		= [A-Za-z0-9_]+ $:s					-> (string->symbol s) ;
quoted		= "'" ("''" | !"'" .)* $:s "'"				-> s ;
header		= blank* "!" name:c blank+ "methodsFor:" blank* quoted:k (!"!" .)* "!"	-> (cons c k) ;
end		= blank* "!" ;
section		= header:h (!end chunk)*:ms end				-> `(section ,(car h) ,(cdr h) ,@ms) ;
other		= chunk							-> () ;
file		= (section | other)*:xs blank*				-> xs ;
