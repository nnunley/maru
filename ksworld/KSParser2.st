OMeta2 subclass: #KSParser2
	instanceVariableNames: 'level contextStack scopes'
	classVariableNames: 'CharEscapes Hex Keywords MoreKeywords'
	poolDictionaries: ''
	category: 'KScript'!

!KSParser2 methodsFor: 'accessing' stamp: 'yo 3/13/2013 17:59'!
get: v
	^ {#var. v asString. v}! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
basicNl =
	exactly(Character cr)! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
countSpaces =
	eol*
	[0]:n (spaceNoComment [n + 1]:n)* -> [n]! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
endOfMethod =
	(``/*'' (~``*/'' char)* ``*/''
|	lineComment basicNl
|	char:x ?[x asciiValue <= 32]
)*! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
eol =
	spaces nl! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
indent :dummy = countSpaces:n ?[n >= level]! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
indented :r =
	[level]:oldLevel &countSpaces:level ?[level > oldLevel]
		apply(r):ans [oldLevel]:level -> [ans]
	| [oldLevel]:level ?[false]! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
initialize
	super initialize.
	level := 0.! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
lineComment =
	``//'' (~basicNl char)*! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
nl =
	lineComment? basicNl! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
optNewLine :dummy =
	eol*! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
space = 
	``/*'' (~``*/'' char)* ``*/''
|	spaceNoComment! !

!KSParser2 methodsFor: 'offside rules' stamp: 'yo 3/13/2013 17:59'!
spaceNoComment = 
	char:x ?[x ~~ Character cr and: [x asciiValue <= 32]]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 10:21'!
addExpr =
	<addExpr:x	 ("+" | "-"):op mulExpr:y>:src
		-> [{#send. src withBlanksTrimmed. op asSymbol. x. y}]
|	mulExpr! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 10:21'!
alnum =
	letter | digit! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 10:21'!
andExpr =
	<andExpr:x	optNewLine(nil) "&&" optNewLine(nil) eqExpr:y>:src
		-> [{#and. src withBlanksTrimmed. x. y}]
|	eqExpr! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 10:26'!
argList =
	expr:first ("," optNewLine(nil) expr)*:rest	-> [rest addFirst: first; asArray]
|	empty										-> [#()]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 4/12/2013 14:02'!
binding =
	< name:n ":=" expr:v >:src		-> [{#decl. src withBlanksTrimmed. {#quote. n}. v}]
|	name:n							-> [{#decl. n asString. {#quote. n}}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
eqExpr =
	< eqExpr:x	 ("===" | "!!==" | "==" | "!!=" | "~="):op	relExpr:y >:src	-> [{#send. src withBlanksTrimmed. op asSymbol. x. y}] 
|	relExpr! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
escapeChar =
	$\ char:c	-> [CharEscapes at: c]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 10:42'!
exponent =
	($e | $E) integer:i	-> ['e', i]
|	empty				-> ['e0']! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 4/16/2013 22:34'!
expr =
	spaces if
|	< fieldAccess:f	 "<-" strExpr:rhs >:src			-> [{#sets. src withBlanksTrimmed. f. {#call. rhs second. self get: #'$$'. rhs}}]
|	< ":" name:n ":=" expr:rhs >:src					-> [{#set. src withBlanksTrimmed. {#globalVar. ':', n. n}. rhs}]
|	< fieldAccess:e	 ":=" expr:rhs >:src					-> [{#set. src withBlanksTrimmed. e. rhs}]
|	< orExpr:e >:src								-> [e]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 9/6/2013 12:04'!
fieldAccess = 
	< (name:n ~"(" [{#fieldName. n}] | "[" expr:e "]" [e]):f
		("." name:n ~"(" [{#fieldName. n}] | "[" expr:e "]" [e])*:l
			($' [true] | [false]):last >:src
		-> [(f = {#fieldName. #this} and: [l size > 0]) ifTrue: [
				{#varRef. src. last}, l]
			ifFalse: [
				{#varRef. src. last. f}, l]]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
forLoop =
	< ``for''	name:x "in" range:r eol
		indented(#stmts):s>:src	-> [{#forRange. src. x. r. s}]
|	< ``for''	name:x "in" range:r "by" expr:b eol
		indented(#stmts):s>:src	-> [{#forRangeBy. src. x. r. s. b}]
|	< ``for''	name:x "in" expr:l eol
		indented(#stmts):s >:src	-> [{#forIn. src. x. l. s}]
|	< ``for''	name:key "," name:val "of" expr:l eol
		indented(#stmts):s >:src	-> [{#forOf. src. key. val. l. s}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
formals =
	listOf(#name. ','):args			-> [args asArray]
|	empty							-> [#()]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
fractional =
	$. natural:n		-> ['.', n]
|	empty			-> ['']! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 4/12/2013 14:37'!
func =
	< "(" formals:args ")" "->" (eol [true] | [false]):eol
		 (?[eol] indented(#stmts) | ?[eol not] stmt(nil):body [{#begin. ''. body}]):body >:src
		-> [{#func. src. args. #(). false. body}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
hex =
	anything:c ?[Hex includesKey: c] -> [Hex at: c]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
hexNumber =
	$0 $x [0]:val (hex:h [val * 16 + h]:val)+	-> [val]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
if =
	<(
		"if" expr:c "then" expr:t "else" expr:f
	|	"if" expr:c "then" expr:t [{#var. 'nil'. #nil}]:f
	|	``if'' expr:c eol
			indented(#stmts):t indent(nil)
		``else'' eol
			indented(#stmts):f
	|	``if'' expr:c eol
			indented(#stmts):t [{#var. 'nil'. #nil}]:f
	)>:src											-> [{#if. src. c. t. f}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
integer =
	$- 				natural:n	-> ['-', n]
|	($+ | empty)	natural:n	-> [n]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 4/12/2013 13:33'!
isKScript2 = 
	name:n ":=" "(" argList ")" -> [true]
	| [false]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:03'!
json =
	< "{" jsonBindings:ps "}" >:src			-> [{#json. src withBlanksTrimmed}, ps]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
jsonBinding =
	< jsonPropertyName:x ":" expr:v >:src		-> [{#jsonProp. src withBlanksTrimmed. x. v}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:03'!
jsonBindings =
	< jsonBinding:p (","  optNewLine(nil) jsonBinding)*:ps	 >:src		-> [{p}, ps]
|	empty											-> [{}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
jsonPropertyName =
	name:n -> [{#quote. n}]
|	literal! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
literal =
	spaces (number | string | symbol)! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:03'!
method =
	(space | nl)* < name:n ":=" func:r >:src endOfMethod -> [{#methodDef. src. n. r}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:03'!
mulExpr =
	< mulExpr:x	( "*" | "/" | "%"):op	unary:y >:src	-> [{#send. src withBlanksTrimmed. op asSymbol. x. y}]
|	unary! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:05'!
name =
	spaces <(letter | $_ | $$) (alnum | $_ | $$)*>:str [str asSymbol]:n ?[(Keywords includes: n) not and: [(MoreKeywords includes: n) not]] -> [n]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
nameAndArgsAndDiscardRest = 
	name:n "=" "(" listOf(#name. ','):args [self pos]:pos ")" -> [{n. args. pos}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
natural =
	digit+:ds	-> [String newFrom: ds]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
newline =
	exactly(Character cr)! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:09'!
number =
	hexNumber:h					-> [{#number. h}]
|	natural:i fractional:f exponent:e	-> [{#number. (i, f, e) asNumber}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
oneStmt =
	stmt(nil)! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:09'!
orExpr =
	< orExpr:x	optNewLine(nil) "||"	optNewLine(nil) andExpr:y >:src		-> [{#or. src withBlanksTrimmed. x. y}]
|	< orExpr:x	"?"	andExpr:y >:src		-> [{#existential. src withBlanksTrimmed. x. y}]
|	andExpr! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:09'!
postfix =
	< primExpr:p ("++" | "--"):op >:src	-> [{#post. src withBlanksTrimmed. op allButLast asSymbol. p}]
|	primExpr! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
primExpr =
	< primExpr:p "[" expr:i "]" >:src								-> [{#get. src withBlanksTrimmed. p. i}]
|	< primExpr:p "." name:m "(" optNewLine(nil) argList:args ")" >:src			-> [{#send. src withBlanksTrimmed. m. p}, args]
|	< primExpr:p "." name:f >:src								-> [{#get. src withBlanksTrimmed. p. {#fieldName. f}}]
|	< primExpr:p "(" optNewLine(nil) argList:args ")" >:src						-> [{#call. src withBlanksTrimmed. p}, args]
|	primExprHd! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 4/10/2013 15:37'!
primExprHd =
	< "new" name:n "(" optNewLine(nil) argList:a ")" >:src	-> [{#new. src withBlanksTrimmed. self get: n}, a]
|	< "[" "]" >:src							-> [{#new. src withBlanksTrimmed. self get: #Array}]
|	< "[" optNewLine(nil) expr:x "]" >:src					-> [{#new. src withBlanksTrimmed. self get: #Array. x}]
|	< "[" optNewLine(nil) expr:first ("," optNewLine(nil) expr)+:rest "]" >:src	-> [{#new. src withBlanksTrimmed. self get: #Array. first}, rest]
|	< "delete" expr:n >:src	-> [{#delete. src withBlanksTrimmed. n}]
|	< name:p "(" optNewLine(nil) argList:args ")" >:src						-> [{#call. src withBlanksTrimmed. self get: p}, args]
|	fieldAccess
|	":" name:n			-> [{#globalVar. ':', n. n asSymbol}]
|	literal
|	func
|	< "(" expr:e optNewLine(nil) "for" name:n optNewLine(nil) "in" expr:list ("when" expr | [{#var. 'true'. #true}]):pred ")" >:src
											-> [{#comprehension. src. n. e. list. pred}]
|	< "(" name:n optNewLine(nil) "in" expr:list optNewLine(nil) "when" expr:pred ")" >:src
											-> [{#detect. src. n. list. pred}]
|	"(" expr:e ")"							-> [e]
|	json! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:12'!
range =
	< "[" expr:b ".." expr:e "]" >:src		-> [{#rangeE. src withBlanksTrimmed. b. e}]
|	< "[" expr:b "..." expr:e "]" >:src		-> [{#rangeI. src withBlanksTrimmed. b. e}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 4/10/2013 14:47'!
relExpr =
	< relExpr:x	( ">=" | ">" | "<=" | ("<"	~``-'' ['<']) ):op	addExpr:y >:src	-> [{#send. src withBlanksTrimmed. op asSymbol. x. y}]
|	< relExpr:x	"instanceof"					addExpr:y >:src	-> [{#send. src withBlanksTrimmed. #'__hasInstance__'. y. x}]
|	addExpr! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
start =
	stmts:s endOfMethod -> [s]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:14'!
stmt :dummy =
	< ``var'' binding:first ("," binding)*:rest >:src eol		-> [{#begin. src withBlanksTrimmed. first}, rest]
|	if
|	< ``while'' expr:c eol
		indented(#stmts):s >:src						-> [{#while. src. c. s}]
|	forLoop
|	< ``break''>:src eol									-> [{#break. src}]
|	< ``throw'' expr:x	>:src eol						-> [{#throw. src. x}]
|	tryCatchFinally
|	< ``return'' expr:e >:src  eol							-> [{#return. src . e}]
|	< ``return'' >:src eol									-> [{#return. src}]
|	expr:e eol?											-> [e]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
stmts =
	<(indent(nil) (stmt(nil)):m (eol | ) [m])*:m >:src -> [{#begin. ''}, m]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 9/5/2013 22:03'!
strExpr =
	< orExpr:init "fby" orExpr:e "on" orExpr:t >:src
		-> [{#fby. src withBlanksTrimmed. init. e. t}]
|	< orExpr:init "fby" orExpr:e >:src
		-> [{#fby. src withBlanksTrimmed. init. e. {#quote. nil}}]
|	< "when" orExpr:t ":" name:n "then" orExpr:e >:src
		-> [{#call. src withBlanksTrimmed. self get: #'$$'. {#send. ''. self get: #mapE. t. {#func. ''. {n}. #(). false. e}}}]
|	< "when" orExpr:t "then" orExpr:e >:src
		-> [{#call. src withBlanksTrimmed. self get: #'$$'. {#send. ''. self get: #doE. t. {#func. ''. {}. #(). false. e}}}]
|	orExpr! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
string =
	( $' (escapeChar | ~$' char)*:cs $'
|	$" (escapeChar | ~$" char)*:cs $")	-> [{#string. String newFrom: cs}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/13/2013 17:59'!
symbol =
	$# string:cs -> [{#symbol. cs second}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 4/12/2013 14:02'!
tryCatchFinally =
	< ``try'' eol
		indented(#stmts):t
	indent(nil)
		( ``catch'' name:e eol
			indented(#stmts):c
		(indent(nil) "finally" eol
				indented(#stmts)
			| empty -> [{#quote. nil}] ):f
		| ['tryTemp']:e	[{#quote. nil}]:c	"finally" eol
				indented(#stmts):f
		) >:src										-> [{#begin. ''. {#decl. e asString. {#quote. e asSymbol}}. {#try. src. t. e. c. f}}]! !

!KSParser2 methodsFor: 'rules' stamp: 'yo 3/29/2013 11:14'!
unary =
	< "--"	postfix:p >:src			-> [{#set. src withBlanksTrimmed. p. {#send. ''. #'-'. p. {#quote. 1}}}]
|	< "++"	postfix:p >:src			-> [{#set. src withBlanksTrimmed. p. {#send. ''. #'+'. p. {#quote. 1}}}]
|	< "-"	postfix:p >:src			-> [{#send. src withBlanksTrimmed. #'-'. {#quote. 0}. p}]
|	< "+"	postfix:p >:src			-> [p]
|	< "!!"	unary:p >:src			-> [{#send. src withBlanksTrimmed. #'!!'. p}]
|			postfix! !

!KSParser2 class methodsFor: 'initialization' stamp: 'yo 3/29/2013 09:40'!
initialize
"
KSParser2 initialize
"

	Keywords := IdentitySet newFrom: #().
	CharEscapes := IdentityDictionary new.
	0 to: 255 do: [:a |
		| c |
		c := a asCharacter.
		CharEscapes at: c put: c.
	].
	CharEscapes at: $\ put: $\.
	CharEscapes at: $n put: Character lf.
	CharEscapes at: $r put: Character cr.
	CharEscapes at: $t put: Character tab.
	CharEscapes at: $" put: $".
	CharEscapes at: $' put: $'.

	Hex := IdentityDictionary new.
	(0 to: 9) with: ($0 to: $9) do: [:i :c |
		Hex at: c put: i].
	(10 to: 15) with: ($a to: $f) do: [:i :c |
		Hex at: c put: i.
		Hex at: c asUppercase put: i].
	MoreKeywords := IdentitySet newFrom: #(fby on).! !

!KSParser2 class methodsFor: 'testing syntax' stamp: 'yo 4/12/2013 13:33'!
isKScript2: aStringOrText
	^ (KSParser2 matcherOn: aStringOrText asString readStream) apply: #isKScript2! !
