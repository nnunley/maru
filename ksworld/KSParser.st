OMeta2 subclass: #KSParser
	instanceVariableNames: 'level'
	classVariableNames: 'CharEscapes Hex Keywords MoreKeywords'
	poolDictionaries: ''
	category: 'KScript'!

!KSParser methodsFor: 'accessing' stamp: 'yo 7/5/2012 10:15'!
get: v
	^ {#var. v asString. v}! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 1/8/2013 10:34'!
basicNl =
	exactly(Character cr)! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 1/8/2013 10:33'!
countSpaces =
	eol*
	[0]:n (spaceNoComment [n + 1]:n)* -> [n]! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 1/8/2013 16:14'!
endOfMethod =
	(``/*'' (~``*/'' char)* ``*/''
|	lineComment basicNl
|	char:x ?[x asciiValue <= 32]
)*! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 1/8/2013 10:14'!
eol =
	spaces nl! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 4/19/2012 17:50'!
indent :dummy = countSpaces:n ?[n >= level]! !

!KSParser methodsFor: 'offside rules' stamp: 'ael 2/21/2013 14:56'!
indented :r =
	[level]:oldLevel &countSpaces:level ?[level > oldLevel]
		apply(r):ans [oldLevel]:level -> [ans]
	| [oldLevel]:level ?[false]! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 4/19/2012 17:51'!
initialize
	super initialize.
	level := 0.! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 1/8/2013 10:49'!
lineComment =
	``//'' (~basicNl char)*! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 1/8/2013 10:31'!
nl =
	lineComment? basicNl! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 1/8/2013 10:56'!
optNewLine :dummy =
	eol*! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 1/8/2013 09:51'!
space = 
	``/*'' (~``*/'' char)* ``*/''
|	spaceNoComment! !

!KSParser methodsFor: 'offside rules' stamp: 'yo 4/19/2012 19:17'!
spaceNoComment = 
	char:x ?[x ~~ Character cr and: [x asciiValue <= 32]]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
addExpr =
	<addExpr:x	 ("+" | "-"):op	mulExpr:y>:src	-> [{#send. src withBlanksTrimmed. op asSymbol. x. y}]
|	mulExpr! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
alnum =
	letter | digit! !

!KSParser methodsFor: 'rules' stamp: 'yo 7/13/2012 10:11'!
andExpr =
	<andExpr:x	optNewLine(nil) "&&" optNewLine(nil) eqExpr:y>:src	-> [{#and. src withBlanksTrimmed. x. y}]
|	eqExpr! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/12/2012 15:29'!
argList =
	expr:first ("," optNewLine(nil) expr)*:rest			-> [rest addFirst: first; asArray]
|	empty								-> [#()]! !

!KSParser methodsFor: 'rules' stamp: 'yo 8/9/2012 15:51'!
atAccess =
	< "@" (name:n ~"(" [n] | "[" expr:e "]" [e]):f
		("." name:n ~"(" [n] | "[" expr:e "]" [e])*:l
			($' [true] | [false]):last >:src  [{#quotedVar. src. last. f}, l]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/12/2013 14:03'!
binding =
	< name:n "=" expr:v >:src		-> [{#decl. src withBlanksTrimmed. {#quote. n}. v}]
|	name:n							-> [{#decl. n asString. {#quote. n}}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/30/2013 15:09'!
eqExpr =
	< eqExpr:x	 ("===" | "!!==" | "==" | "!!=" | "~="):op	relExpr:y >:src	-> [{#send. src withBlanksTrimmed. op asSymbol. x. y}] 
|	relExpr! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
escapeChar =
	$\ char:c	-> [CharEscapes at: c]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
exponent =
	($e | $E) integer:i	-> ['e', i]
|	empty				-> ['e0']! !

!KSParser methodsFor: 'rules' stamp: 'yo 7/3/2012 13:44'!
expr =
	< orExpr:rhs "fby" expr:inc ("at" | "on") expr:tick >:src	->	[{#update. src withBlanksTrimmed. rhs. inc. tick}]
|	< orExpr:rhs "fby" expr:inc >:src					->	[{#update. src withBlanksTrimmed. rhs. inc. {#quote. nil}}]
|	spaces if
|	< orExpr:e	 "=" expr:rhs >:src						-> [{#set. src withBlanksTrimmed. e. rhs}]
|	< orExpr:e	 ("+=" | "-=" | "*="
					| "/=" | "%="):op [op allButLast]:op
						expr:rhs >:src					-> [{#set. src withBlanksTrimmed. e. {#send. src withBlanksTrimmed. op asSymbol. e deepCopy. rhs}}]
|	< orExpr:e "?=" expr:rhs >:src						-> [{#set. src withBlanksTrimmed. e. {#existential. src withBlanksTrimmed. e deepCopy. rhs}}]
|	< orExpr:e >:src									-> [e]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/11/2012 21:18'!
forLoop =
	< ``for''	name:x "in" range:r eol
		indented(#stmts):s>:src	-> [{#forRange. src. x. r. s}]
|	< ``for''	name:x "in" range:r "by" expr:b eol
		indented(#stmts):s>:src	-> [{#forRangeBy. src. x. r. s. b}]
|	< ``for''	name:x "in" expr:l eol
		indented(#stmts):s >:src	-> [{#forIn. src. x. l. s}]
|	< ``for''	name:key "," name:val "of" expr:l eol
		indented(#stmts):s >:src	-> [{#forOf. src. key. val. l. s}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 7/6/2012 10:52'!
formals =
	listOf(#name. ','):args			-> [args asArray]
|	empty							-> [#()]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
fractional =
	$. natural:n		-> ['.', n]
|	empty			-> ['']! !

!KSParser methodsFor: 'rules' stamp: 'ael 2/21/2013 14:55'!
func =
	< "(" formals:args ")" "->" (eol [true] | [false]):eol
		 (?[eol] indented(#stmts) | ?[eol not] stmt(nil):body [{#begin. ''. body}]):body >:src
		-> [{#func. src. args. #(). true. body}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 6/12/2012 14:31'!
hex =
	anything:c ?[Hex includesKey: c] -> [Hex at: c]! !

!KSParser methodsFor: 'rules' stamp: 'yo 6/12/2012 15:20'!
hexNumber =
	$0 $x [0]:val (hex:h [val * 16 + h]:val)+	-> [val]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/12/2012 16:21'!
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

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
integer =
	$- 				natural:n	-> ['-', n]
|	($+ | empty)	natural:n	-> [n]! !

!KSParser methodsFor: 'rules' stamp: 'ael 2/25/2013 15:36'!
isKScript = 
	name:n "=" "(" argList ")" -> [true]
	| [false]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:48'!
json =
	< "{" jsonBindings:ps "}" >:src			-> [{#json. src withBlanksTrimmed}, ps]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:49'!
jsonBinding =
	< jsonPropertyName:x ":" expr:v >:src		-> [{#jsonProp. src withBlanksTrimmed. x. v}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/12/2012 15:37'!
jsonBindings =
	< jsonBinding:p (","  optNewLine(nil) jsonBinding)*:ps	 >:src		-> [{p}, ps]
|	empty											-> [{}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/24/2013 11:36'!
jsonPropertyName =
	name:n -> [{#quote. n}]
|	literal! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/24/2013 12:11'!
literal =
	spaces (number | string | symbol)! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/8/2013 11:38'!
method =
	(space | nl)* < name:n "=" func:r >:src endOfMethod -> [{#methodDef. src. n. r}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
mulExpr =
	< mulExpr:x	( "*" | "/" | "%"):op	unary:y >:src	-> [{#send. src withBlanksTrimmed. op asSymbol. x. y}]
|	unary! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:49'!
name =
	spaces <(letter | $_ | $$) (alnum | $_ | $$)*>:str [str asSymbol]:n ?[(Keywords includes: n) not and: [(MoreKeywords includes: n) not]] -> [n]! !

!KSParser methodsFor: 'rules' stamp: 'ael 2/25/2013 14:35'!
nameAndArgsAndDiscardRest = 
	name:n "=" "(" listOf(#name. ','):args [self pos]:pos ")" -> [{n. args. pos}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
natural =
	digit+:ds	-> [String newFrom: ds]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
newline =
	exactly(Character cr)! !

!KSParser methodsFor: 'rules' stamp: 'yo 6/12/2012 15:20'!
number =
	hexNumber:h					-> [{#number. h}]
|	natural:i fractional:f exponent:e	-> [{#number. (i, f, e) asNumber}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/10/2012 23:01'!
oneStmt =
	stmt(nil)! !

!KSParser methodsFor: 'rules' stamp: 'yo 7/13/2012 10:10'!
orExpr =
	< orExpr:x	optNewLine(nil) "||"	optNewLine(nil) andExpr:y >:src		-> [{#or. src withBlanksTrimmed. x. y}]
|	< orExpr:x	"?"	andExpr:y >:src		-> [{#existential. src withBlanksTrimmed. x. y}]
|	andExpr! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/11/2012 09:10'!
postfix =
	< primExpr:p ("++" | "--"):op >:src	-> [{#post. src withBlanksTrimmed. op allButLast asSymbol. p}]
|	primExpr! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/24/2013 11:14'!
primExpr =
	< primExpr:p "[" expr:i "]" >:src								-> [{#get. src withBlanksTrimmed. p. i}]
|	< primExpr:p "." name:m "(" optNewLine(nil) argList:args ")" >:src			-> [{#send. src withBlanksTrimmed. m. p}, args]
|	< primExpr:p "." name:f >:src								-> [{#get. src withBlanksTrimmed. p. {#fieldName. f}}]
|	< primExpr:p "(" optNewLine(nil) argList:args ")" >:src						-> [{#call. src withBlanksTrimmed. p}, args]
|	primExprHd! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/30/2013 11:49'!
primExprHd =
	< "new" name:n "(" optNewLine(nil) argList:a ")" >:src	-> [{#new. src withBlanksTrimmed. self get: n}, a]
|	< "[" "]" >:src							-> [{#new. src withBlanksTrimmed. self get: #Array}]
|	< "[" optNewLine(nil) expr:x "]" >:src					-> [{#new. src withBlanksTrimmed. self get: #Array. x}]
|	< "[" optNewLine(nil) expr:first ("," optNewLine(nil) expr)+:rest "]" >:src	-> [{#new. src withBlanksTrimmed. self get: #Array. first}, rest]
|	< "delete" expr:n >:src	-> [{#delete. src withBlanksTrimmed. n}]
|	atAccess
|	name:n									-> [self get: n]
|	literal
|	func
|	< "(" expr:e optNewLine(nil) "for" name:n optNewLine(nil) "in" expr:list ("when" expr | [{#var. 'true'. #true}]):pred ")" >:src
											-> [{#comprehension. src. n. e. list. pred}]
|	< "(" name:n optNewLine(nil) "in" expr:list optNewLine(nil) "when" expr:pred ")" >:src
											-> [{#detect. src. n. list. pred}]
|	"(" expr:e ")"							-> [e]
|	json! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/10/2012 14:35'!
range =
	< "[" expr:b ".." expr:e "]" >:src		-> [{#rangeE. src withBlanksTrimmed. b. e}]
|	< "[" expr:b "..." expr:e "]" >:src		-> [{#rangeI. src withBlanksTrimmed. b. e}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/9/2012 19:37'!
relExpr =
	< relExpr:x	( ">=" | ">" | "<=" | "<"	 ):op	addExpr:y >:src	-> [{#send. src withBlanksTrimmed. op asSymbol. x. y}]
|	< relExpr:x	"instanceof"					addExpr:y >:src	-> [{#send. src withBlanksTrimmed. #'__hasInstance__'. y. x}]
|	addExpr! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/8/2013 16:14'!
start =
	stmts:s endOfMethod -> [s]! !

!KSParser methodsFor: 'rules' stamp: 'ael 2/21/2013 14:27'!
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
|	expr:e ";"? eol?											-> [e]! !

!KSParser methodsFor: 'rules' stamp: 'ael 2/21/2013 14:27'!
stmts =
	<(indent(nil) (stmt(nil)):m (eol | ) [m])*:m >:src -> [{#begin. ''}, m]! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/24/2013 12:12'!
string =
	( $' (escapeChar | ~$' char)*:cs $'
|	$" (escapeChar | ~$" char)*:cs $")	-> [{#string. String newFrom: cs}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 1/24/2013 12:31'!
symbol =
	$# string:cs -> [{#symbol. cs second}]! !

!KSParser methodsFor: 'rules' stamp: 'yo 4/12/2013 14:03'!
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

!KSParser methodsFor: 'rules' stamp: 'yo 4/12/2013 11:02'!
unary =
	< "--"	postfix:p >:src			-> [{#set. src withBlanksTrimmed. p. {#send. ''. #'-'. p. {#number. 1}}}]
|	< "++"	postfix:p >:src			-> [{#set. src withBlanksTrimmed. p. {#send. ''. #'+'. p. {#number. 1}}}]
|	< "-"	postfix:p >:src			-> [{#send. src withBlanksTrimmed. #'-'. {#number. 0}. p}]
|	< "+"	postfix:p >:src			-> [p]
|	< "!!"	unary:p >:src			-> [{#send. src withBlanksTrimmed. #'!!'. p}]
|			postfix! !

!KSParser class methodsFor: 'initialization' stamp: 'yo 9/5/2012 19:12'!
initialize
"
KSParser initialize
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
		Hex at: c put: i].
	(10 to: 15) with: ($A to: $F) do: [:i :c |
		Hex at: c put: i].

	MoreKeywords := IdentitySet newFrom: #(fby at).! !

!KSParser class methodsFor: 'testing syntax' stamp: 'ael 2/25/2013 15:18'!
isKScript: aStringOrText

	^ (KSParser matcherOn: aStringOrText asString readStream) apply: #isKScript! !
