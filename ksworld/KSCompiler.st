OMeta2 subclass: #KSCompiler
	instanceVariableNames: 'class contextLevel numTemps id'
	classVariableNames: 'BuiltInOps Debug'
	poolDictionaries: ''
	category: 'KScript'!

!KSCompiler methodsFor: 'initialization' stamp: 'yo 7/6/2012 00:13'!
initialize

	super initialize.
	contextLevel := 0.
	numTemps := 0.
	id := 0.! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:55'!
and =
	anything compile:x compile:y 		-> [{'('. x. ' asBoolean and: ['. y. '])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:33'!
array =
	anything compile*:xs 		-> [self array: xs]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/10/2012 10:04'!
begin =
	anything compile*:xs	-> [self begin: xs withBlocking: true]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:33'!
break =
	anything				-> ['KSBreak signal']! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:33'!
call =
	anything:src compile:f compile*:as		-> [self call: f arguments: as]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:55'!
compile =
	{anything:sel [self apply: sel]:ret} -> [ret]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:55'!
compileCase :expr :shouldEval =
	{#default anything compile:x}			-> [{x. '. '}]
|	{#case anything compile:e compile:x}	-> [{'('. expr. ' == '. e. ') ifTrue: ['. shouldEval. ' := true]. '.
										shouldEval. ' ifTrue: ['. x. ']. '}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/18/2013 10:53'!
compileForClass :cls =
	[cls]:class
	{anything:sel [self apply: sel]:ret} -> [ret]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/11/2012 18:37'!
comprehension =
	anything anything:v compile:e compile:list compile:pred [self makeTemp]:temp
		-> [{'(true ifTrue: [|'. temp. ' | '. temp. ' := OrderedCollection new. '. list. ' do: [:'. v. ' | '. pred. ' ifTrue: ['. temp. ' add: ('. e. ')]].'. temp. '])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/18/2012 11:13'!
decl =
	anything {#quote anything:n} compile:v			-> [{n asString. ' := '. v}]
|	anything {#quote anything:n}					-> [{n asString. ' := KSObject undefined'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/24/2013 12:27'!
delete =
	anything {#get anything compile:c {#fieldName anything:n}} -> [{'('. c. ' removeKey: '. n printString. ' ifAbsent: [])'}]
|	anything {#get anything compile:c compile:n} -> [{'('. c. ' removeKey: '. n. ' asKSKey'. ' ifAbsent: [])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/17/2012 10:27'!
detect =
	anything anything:v compile:list compile:pred
		-> [{'('. list. ' detect: [:'. v. ' | '. pred. '] ifNone: [])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:40'!
doWhile =
	anything compile:s compile:c		-> [{'([['. s. '. '. c. '] whileTrue] on: KSBreak do: [])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/11/2013 21:53'!
eval =
	anything {(anything:x [x, ' '])*:ts} compile*:xs	-> [{'| '. ts asArray. ' squeakCtxt0 | squeakCtxt0 := thisContext. '. xs asArray}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/11/2013 23:25'!
eval2 =
	anything {(anything:x [x, ' '])*:ts} compile*:xs	-> [{'| '. ts asArray. ' | '. xs asArray}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/11/2012 15:50'!
existential =
	anything:src compile:l compile:r	-> [{'('. l. ' ifNotExist: ['. r. '])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/24/2013 11:26'!
fieldName =
	anything:x	-> [x printString]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/11/2013 21:34'!
fieldRef =
	anything anything:prime ['self']:result
	(compile:next (&anything [false] | [true]):last
		[{'('. result. ' ksAt: '. next. ' asKSKey)'. last & prime ifTrue: [' lastValue'] ifFalse: [' currentValue']}]:result)+
	[result]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 8/14/2013 20:14'!
fieldSet =
	{#fieldRef anything anything:prime
	['self']:result
	((&{#fieldName anything} [true] | [false]):isSymbol compile:next (&anything [false] | [true]):last
		[last ifFalse: [
			{'('. result. ' ksAt: '. next. isSymbol ifTrue: [''] ifFalse: [' asKSKey']. ') currentValue'}]
		ifTrue: [result]]:result)+
	} compile:v
	[{'('. result. ' ksAssign: '. next. ' with: ('. v. '))'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/10/2012 10:17'!
forIn =
	anything anything:v compile:l
		anything:s KSBreakFinder.hasBreak(s):hasBreak compile(s):s	
		-> [hasBreak
				ifTrue: [{'(['. l. ' do: [:'. v. ' |'. s. ']] on: KSBreak do: [])'}]
				ifFalse: [{'('. l. ' do: [:'. v. ' |'. s. '])'}]]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/10/2012 10:22'!
forOf =
	anything anything:k anything:v compile:l
		anything:s KSBreakFinder.hasBreak(s):hasBreak compile(s):s
		-> [hasBreak
				ifTrue: [{'(['. l. ' keysAndValuesDo: [:'. k. ' :'. v. ' |'. s. ']] on: KSBreak do: [])'}]
				ifFalse: [{'('. l. ' keysAndValuesDo: [:'. k. ' :'. v. ' |'. s. '])'}]]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/10/2012 10:17'!
forRange =
	anything anything:v {#rangeE anything compile:b compile:e}
		anything:s KSBreakFinder.hasBreak(s):hasBreak compile(s):s	
		-> [hasBreak
				ifTrue: [{'([('. b. ') to: ('. e. ' - 1)  do: [:'. v. ' |'. s. ']] on: KSBreak do: [])'}]
				ifFalse: [{'(('. b. ') to: ('. e. ' - 1)  do: [:'. v. ' |'. s. '])'}]]
|	anything anything:v {#rangeI anything compile:b compile:e}
		anything:s KSBreakFinder.hasBreak(s):hasBreak compile(s):s	
		-> [hasBreak
				ifTrue: [{'([('. b. ') to: ('. e. ')  do: [:'. v. ' |'. s. ']] on: KSBreak do: [])'}]
				ifFalse: [{'(('. b. ') to: ('. e. ')  do: [:'. v. ' |'. s. '])'}]]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/10/2012 10:17'!
forRangeBy =
	anything anything:v {#rangeE anything compile:b compile:e}
		anything:s KSBreakFinder.hasBreak(s):hasBreak compile(s):s
		compile:incr
		-> [hasBreak
				ifTrue: [{'([('. b. ') to: ('. e. ' - 1) by: ('. incr. ') do: [:'. v. ' |'. s. ']] on: KSBreak do: [])'}]
				ifFalse: [{'(('. b. ') to: ('. e. ' - 1) by: ('. incr. ') do: [:'. v. ' |'. s. '])'}]]
|	anything anything:v {#rangeI anything compile:b compile:e} 	
		anything:s KSBreakFinder.hasBreak(s):hasBreak compile(s):s
	compile:incr
		-> [hasBreak
				ifTrue: [{'([('. b. ') to: ('. e. ') by: ('. incr. ') do: [:'. v. ' |'. s. ']] on: KSBreak do: [])'}]
				ifFalse: [{'(('. b. ') to: ('. e. ') by: ('. incr. ') do: [:'. v. ' |'. s. '])'}]]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/21/2013 22:35'!
func =
	anything:src anything:args anything:tmps anything:hasReturn
	[self pushContext]:squeakCtxt
	[self this]:this
	({#begin anything {#begin anything compile*:bs}}
	| {#begin anything compile*:bs})
	[Array streamContents: [:strm | bs do: [:x | strm nextPut: x] separatedBy: [strm nextPut: '. ']]]:body
	[self popContext]		 -> [self function: body arguments: args tmps: tmps squeakContext: (hasReturn ifTrue: [squeakCtxt]) source: src this: this]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/24/2013 11:21'!
get =
	anything compile:c {#fieldName anything:n}					-> [{'('. c. ' ksAt: '. n printString. ')'}]
|	anything compile:c compile:n								-> [{'('. c. ' ksAt: '. n. ' asKSKey)'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 2/7/2013 21:14'!
if =
	anything:src compile:c compile:t compile:f		-> [{'('. c. ' asBoolean ifTrue: ['. t. ']'. ' ifFalse: ['. f. '])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:56'!
json =
	anything:src compile*:as		-> [self json: as]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:56'!
jsonProp =
	anything:src compile:x compile:v		-> [{x . ' -> '. v}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/6/2012 00:05'!
methodDef =
	anything:src
	anything:methodName
	[self pushContext]
	{#func anything:src anything:args anything:tmps anything:hasReturn
		({#begin anything {#begin anything compile*:bs}}
		| {#begin anything compile*:bs})}
	[Array streamContents: [:strm | bs do: [:x | strm nextPut: x] separatedBy: [strm nextPut: '. ']]]:body
	[self popContext]	 -> [self methodDef: body of: methodName arguments: args tmps: tmps]

//	[body first ~= #begin ifTrue: [self halt]]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 14:30'!
methodReturn =
	anything (compile | ['self']):x			-> [{' ^ '. x}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 3/9/2012 10:59'!
new =
	anything compile:cls compile*:as	-> [{'('. cls. ' ksNew: {'. Array streamContents: [:strm | as do: [:a | strm nextPut: a] separatedBy: [strm nextPut: '. ']]. '})'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/24/2013 11:45'!
number =
	anything:x	-> [x printString]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:56'!
or =
	anything compile:x compile:y 		-> [{'('. x. ' asBoolean or: ['. y. '])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 3/5/2012 10:52'!
post =
	anything anything:m anything:x
	empty(x) compile:cx
	[self makeTemp]:t
		empty({#set. ''. x. {#send. ''. m.
						{#squote. t}.
					{#quote. 1}}}) compile:u		-> [{'(true ifTrue: [ |'. t. ' | '. t. ' := '. cx. '. '. u. '. '. t. '])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/24/2013 12:08'!
quote =
	anything:x	-> [x printString]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/5/2012 23:50'!
return =
	anything compile:x				-> [{self squeakContext. ' return: '. x}]
|	anything						-> [{self squeakContext. ' return: KSObject undefined'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/10/2012 10:05'!
sbegin =
	anything compile*:xs	-> [self begin: xs withBlocking: false]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:56'!
send =
	anything anything:m compile:r compile*:as		-> [self send: m receiver: r arguments: as]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/11/2013 21:53'!
set =
	anything {#get anything compile:c {#fieldName anything:n}} compile:v			-> [{'('. c. ' ksAt: '. n printString. ' put: '. v. ')'}]
|	anything {#get anything compile:c compile:n} compile:v			-> [{'('. c. ' ksAt: '. n. ' asKSKey put: '. v. ')'}]
|	anything fieldSet
|	anything tempSet
|	anything compile:c compile:n compile:v							-> [{'('. c. ' ksAt: '. n. ' asKSKey put: '. v. ')'}]
|	anything compile:n compile:v									-> [{'('. n asString. ' := '. v. ')'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/12/2013 10:39'!
sets =
	anything fieldSet
|	anything compile:n compile:v									-> [{'('. n asString. ' := '. v. ')'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:57'!
squote =
	anything:x	-> [x]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/24/2013 12:11'!
string =
	anything:x	-> [x printString]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 3/2/2012 10:57'!
subclass =
	anything:src anything:superCls anything:cls compile*:ms	-> [ms]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 3/6/2012 10:18'!
switch =

	anything
	[self makeTemp]:expr [self makeTemp]:shouldEval
	compile:e compileCase(expr. shouldEval)*:cs
								-> [{'([| '. expr. ' '. shouldEval. ' | '. expr. ' := '. e. '. '. shouldEval. ' := false. ['. cs. '] on: KSBreak do: []] value)'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/24/2013 12:31'!
symbol =
	anything:x	-> [x asSymbol printString]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/11/2013 22:02'!
temp =
		#this			-> [contextLevel <= 1 ifTrue: ['self'] ifFalse: [self this]]
	|	#undefined		-> ['KSObject undefined']
	|	#null			-> ['nil']
	|	#Array			-> ['OrderedCollection']
	|	anything:x		-> [x asString]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/12/2013 10:07'!
tempRef =
	&(anything anything anything+:s [s size]:size)
	(?[size = 1]
		anything anything:prime {#fieldName temp:result} [result]
	|
		anything anything:prime {#fieldName temp:result}
			((&{#fieldName anything} [true] | [false]):isSymbol compile:next (&anything [false] | [true]):last
		[{'('. result. ' ksAt: '. next. isSymbol ifTrue: [''] ifFalse: [' asKSKey']. ') '. last&prime ifTrue: ['lastValue'] ifFalse: ['currentValue']}]:result)+
	[result]
	)! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 8/14/2013 20:15'!
tempSet =
	&{#tempRef anything anything anything+:s [s size]:size}
	(?[size = 1]
		{#tempRef anything anything:prime {#fieldName temp:result}} compile:v [{'('. result. ' := '. v. ')'}]
	|
		{#tempRef anything anything:prime {#fieldName temp:result}
			((&{#fieldName anything} [true] | [false]):isSymbol compile:next (&anything [false] | [true]):last
		[last ifFalse: [
			{'('. result. ' ksAt: '. next. isSymbol ifTrue: [''] ifFalse: [' asKSKey']. ') currentValue'}]
		ifTrue: [result]]:result)+
	} compile:v
	[{'('. result. ' ksAssign: '. next. ' with: ('. v. '))'}]
	)! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:57'!
throw =
	anything compile:x			-> [{'((KSThrow new value: '. x. ') signal)'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/19/2012 14:36'!
try =
	anything compile:x anything:e compile:c compile:f
	[self makeTemp]:throw
										-> [{'([['. x. '] on: Error do: [:'. throw. ' | '. e. ' := '. throw. ' perform: (('. throw. ' isMemberOf: KSThrow) ifTrue: [#value] ifFalse: [#yourself]).'. c. ']] ensure: ['. f. '])'}]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 1/21/2013 23:49'!
var =
	anything (
		#this			-> [contextLevel <= 1 ifTrue: ['self'] ifFalse: [self this]]
	|	#undefined		-> ['KSObject undefined']
	|	#null			-> ['nil']
	|	#Array			-> ['OrderedCollection']
	|	anything:x		-> [x asString]
)! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/11/2013 20:29'!
varRef =
	//	In the production pipeline, a 'varRef' is converted to tempRef or fieldRef, but for testing purpose, this rule is provided.
	anything anything:last ['self']:result
	(compile:next [{'('. result. ' ksAt: '. next. ' asKSKey) currentValue'}]:result)+
	[result]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 4/4/2013 14:22'!
varRefSet =
	// In the production pipeline, a 'varRef' is converted to tempRef or fieldVar, but for testing purpose, this rule is provided.
	anything anything:last ['self']:result
	(compile:next (&anything [false] | [true]):last 
		(?[last] [{result. ' ksAt: '. next. ' asKSKey'}]
		| [{'('. result. ' ksAt: '. next. ' asKSKey) currentValue'}]):result)+
	[result]! !

!KSCompiler methodsFor: 'rules' stamp: 'yo 7/3/2012 10:57'!
while =
	anything compile:c anything:s
		KSBreakFinder.hasBreak(s):hasBreak empty(s) compile:s
			-> [hasBreak
					ifTrue: [{'([['. c. ' asBoolean] whileTrue: ['. s. ']] on: KSBreak do: [])'}]
					ifFalse: [{'(['. c. ' asBoolean] whileTrue: ['. s. '])'}]]! !

!KSCompiler methodsFor: 'support' stamp: 'yo 7/3/2012 10:33'!
array: xs
	^ {'{'. Array streamContents: [:strm | xs do: [:x | strm nextPut: x] separatedBy: [strm nextPut: '. ']]. '}'}.! !

!KSCompiler methodsFor: 'support' stamp: 'yo 7/10/2012 10:06'!
begin: xs withBlocking: aBoolean
	xs size = 0 ifTrue: [^ #()].
	xs size = 1 ifTrue: [^ xs first].
	^ (aBoolean ifTrue: [{'(true ifTrue: ['}] ifFalse: [{}]), (Array streamContents: [:strm | xs do: [:x | strm nextPut: x] separatedBy: [strm nextPut: '. ']]), (aBoolean ifTrue: [{'])'}] ifFalse: [{}])! !

!KSCompiler methodsFor: 'support' stamp: 'yo 1/9/2013 15:43'!
call: f arguments: as
	(f = #P or: [f = #Point]) ifTrue: [^ {'(('. as first. ')@('. as second. '))'}].
	(f = #M or: [f = #Matrix]) ifTrue: [
		^ Array streamContents: [:strm |
			strm nextPut: '({'.
			as do: [:a | strm nextPut: a] separatedBy: [strm nextPut: '. '].
			strm nextPut: '} asMatrixTransform2x3)']].
	^{'('.f. ' valueWithEnoughArguments: {'. (Array streamContents: [:strm | as do: [:x | strm nextPut: x] separatedBy: [strm nextPut: '. ']]). '})'}! !

!KSCompiler methodsFor: 'support' stamp: 'yo 2/29/2012 11:34'!
debug
	(#(true) includes: Debug) ifTrue: [self halt].! !

!KSCompiler methodsFor: 'support' stamp: 'yo 1/21/2013 23:42'!
function: body arguments: as tmps: ts squeakContext: squeakCtxt source: src this: this
	| initializer funArgs |
	initializer :=
		 {(Array streamContents: [:strm |
			strm nextPut: ' | '.
			ts do: [:t | strm nextPut: t; nextPut: ' '].
			squeakCtxt ifNotNil: [strm nextPut: squeakCtxt].
			strm nextPut: ' |\' withCRs]).
		squeakCtxt ifNotNil: [squeakCtxt, ' := thisContext.\' withCRs] ifNil: ['']}.
	funArgs := (({this}, as) inject: '' into: [:s :a | s, ' :', a]), ' |\' withCRs.
	^ {'(KSClosure closure: (['. funArgs. initializer. body. ']) source: '. (src withBlanksTrimmed copyWith: Character cr) printString. ' this: self)'}! !

!KSCompiler methodsFor: 'support' stamp: 'yo 2/29/2012 15:36'!
json: as

	^ {'({'. Array streamContents: [:strm | as do: [:a | strm nextPut: a] separatedBy: [strm nextPut: '. ']]. '} as: KSObject)'}! !

!KSCompiler methodsFor: 'support' stamp: 'yo 1/21/2013 21:07'!
makeTemp
	^ 'ksTemp', (numTemps := numTemps + 1) printString! !

!KSCompiler methodsFor: 'support' stamp: 'yo 1/18/2013 10:56'!
methodDef: body of: m arguments: as tmps: ts
	| pattern initializer sqSel |
	sqSel := BuiltInOps at: m asSymbol ifAbsent: [].
	sqSel ifNotNil: [
		initializer := Array streamContents: [:strm |
				strm nextPut: ' | '.
				ts do: [:t | strm nextPut: t asString; nextPut: ' '].
				strm nextPut: ' |\' withCRs]].
		pattern := sqSel. ' '. (as size = 0 ifTrue: [#()] ifFalse: [as first]), '\' withCRs.

	pattern ifNil: [
		as size = 0 ifTrue: [
			pattern := m copyWith: Character cr]
		ifFalse: [
			pattern := String streamContents: [:strm |
				strm
					nextPutAll: m;
					nextPut: $:.
				as do: [:a |
					a == as first ifFalse: [
						strm nextPutAll: ' with:'].
					strm
						space;
						nextPutAll: a].
				strm cr]].
		initializer :=
			 {Array streamContents: [:strm |
				strm nextPut: ' | '.
				ts do: [:t | strm nextPut: t asString; nextPut: ' '].
				strm nextPut: '|\' withCRs]}].
	^ Compiler format: (OMeta2Flattener match: {pattern. initializer. body} with: #flatten) in: (class ifNil: [Smalltalk at: #KSObject ifAbsent: [Object]]) notifying: nil! !

!KSCompiler methodsFor: 'support' stamp: 'yo 2/29/2012 11:34'!
nextId

	^ ('tt', (id := id + 1) printString) asSymbol.! !

!KSCompiler methodsFor: 'support' stamp: 'yo 7/6/2012 00:10'!
popContext
	contextLevel := contextLevel - 1.! !

!KSCompiler methodsFor: 'support' stamp: 'yo 7/6/2012 00:16'!
pushContext
	contextLevel := contextLevel + 1.
	^ self squeakContext! !

!KSCompiler methodsFor: 'support' stamp: 'yo 7/5/2012 10:00'!
send: m receiver: r arguments: as
"
	rec._abc_def(a1, a2)
		=> rec abc: a1 def: a2
		(underscores are significant.  Mostly to espace to Smalltalk.)

	rec._abc()
		=> rec abc
		(underscores are significant.  Mostly to espace to Smalltalk.)

	rec * b
		=> rec * b

	rec.abc()
		=> rec abc

	rec.abc(a1)
		=> rec abc: a1

	rec.abc(a1, a2)
		=> rec abc: a1 with: a2

"
	| sqSel |
	(m beginsWith: '_') ifTrue: [
	| keywords |
		as size = 0 ifTrue: [
			keywords := m allButFirst.
			^ {r. ' '. m allButFirst}].
		keywords := (m copyReplaceAll: '_' with: ' ') substrings collect: [:e | e copyWith: $:].
		keywords size ~= as size ifTrue: [self error: 'argument count for ', m, ' does not match'].
		^ {'('. r. ' '. (Array streamContents: [:strm |
					keywords with: as do: [:k :a |
						strm nextPut: k;
							nextPut: ' (';
							nextPut: a;
							nextPut: ') ']]). ')'}].

	sqSel := BuiltInOps at: m asSymbol ifAbsent: [].
	sqSel ifNotNil: [
		^ {'('. r. ' '. sqSel. ' '. (as size = 0 ifTrue: [#()] ifFalse: [as first]). ')'}].

	as size = 0 ifTrue: [
		^{'('. r. ' '. m. ')'}].

	^{'('. r. ' '. (m copyWith: $:). as first. (Array streamContents: [:strm | as allButFirst do: [:a | strm nextPut: ' with: '. strm nextPut: a]]). ')'}.! !

!KSCompiler methodsFor: 'support' stamp: 'yo 1/21/2013 21:08'!
squeakContext
	^ 'squeakCtxt', contextLevel printString! !

!KSCompiler methodsFor: 'support' stamp: 'yo 1/21/2013 22:35'!
this
	^ 'this', contextLevel printString! !

!KSCompiler class methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 14:15'!
squeakSelectorFor: aString
"See the comment in #send:receiver:arguments: (and make sure they are in sync)"
	| sqSel |
	((aString at: 1) =  $_) ifTrue: [
		(aString occurrencesOf: $_) = 1 ifTrue: [
			^ aString allButFirst].
		^ ((aString copyReplaceAll: '_' with: ':') allButFirst copyWith: $:) asSymbol].

	sqSel := BuiltInOps at: aString asSymbol ifAbsent: [].
	sqSel ifNotNil: [^ sqSel asSymbol].

	^ aString asSymbol! !

!KSCompiler class methodsFor: 'initialization' stamp: 'yo 3/23/2012 12:44'!
builtInOps

	^ BuiltInOps! !

!KSCompiler class methodsFor: 'initialization' stamp: 'yo 1/30/2013 15:07'!
initialize

	BuiltInOps := IdentityDictionary newFrom: {
		#'!!' -> 'ksNot'.
		#'+' -> '+'.
		#'-' -> '-'.
		#'*' -> '*'.
		#'/' -> '/'.
		#'%' -> '\\'. 
		#'==' -> '='. 
		#'!!=' -> '~='. 
		#'===' -> '=='. 
		#'~=' -> '=?'. 
		#'!!==' -> '~~'. 
		#'<=' -> '<='. 
		#'<' -> '<'. 
		#'>' -> '>'. 
		#'>=' -> '>='.

		#'&&' -> '&'.
		#'||' -> '|'.
	}! !
