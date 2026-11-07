# Squeak's file-out (chunk) format, as ksworld/*.st holds KSWorld's classes: chunks end at a "!" ("!!" is a "!" inside
# one).  The class's definition chunk reads to (definition CLASS SUPERCLASS "IVARS"); "!CLASS methodsFor: 'CATEGORY'
# stamp: '...'!" (or "!CLASS class methodsFor: ...!", its class side) opens a section of methods, each a chunk, and an
# empty chunk ends it: (section CLASS CATEGORY SIDE METHOD...), SIDE instance or class, each method its source.  Any
# other chunk (a comment) reads to nothing.

<stfileout> : <text-parser> ()

blank		= [ \t\r\n] ;
chunk		= ("!!" -> 33 | !"!" .)* $:t "!"			-> t ;	# a doubled "!" (33) is one
name		= [A-Za-z0-9_]+ $:s					-> (string->symbol s) ;
quoted		= "'" ("''" | !"'" .)* $:s "'"				-> s ;
side		= blank+ "class" &blank					-> 'class
		|							-> 'instance ;
header		= blank* "!" name:c side:s blank+ "methodsFor:" blank* quoted:k (!"!" .)* "!"	-> (list c k s) ;
end		= blank* "!" ;
section		= header:h (!end chunk)*:ms end				-> `(section ,@h ,@ms) ;
definition	= blank* name:super blank+ ("subclass:" | "variableSubclass:" | "weakSubclass:") blank* "#" name:c
		  (!"instanceVariableNames:" !"!" .)* "instanceVariableNames:" blank* quoted:iv (!"!" .)* "!"
									-> `(definition ,c ,super ,iv) ;
other		= chunk							-> () ;
file		= (section | definition | other)*:xs blank*		-> xs ;
