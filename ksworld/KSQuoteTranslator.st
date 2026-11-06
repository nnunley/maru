OMeta2 subclass: #KSQuoteTranslator
	instanceVariableNames: 'id dependencies attributes'
	classVariableNames: 'Debug'
	poolDictionaries: ''
	category: 'KScript'!

!KSQuoteTranslator methodsFor: 'initialization' stamp: 'yo 7/31/2012 17:19'!
initialize
	super initialize.
	dependencies := OrderedCollection new.
	id := 0.! !

!KSQuoteTranslator methodsFor: 'initialization' stamp: 'yo 7/6/2012 10:58'!
nextId
	^ {#quote. ('tt', (id := id + 1) printString) asSymbol}! !

!KSQuoteTranslator methodsFor: 'initialization' stamp: 'yo 8/9/2012 11:09'!
start :dict =
	[attributes := dict]
	trans! !

!KSQuoteTranslator methodsFor: 'initialization' stamp: 'yo 8/9/2012 10:38'!
top
	^ #(#var 'pvtStrm' #pvtStrm)! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 8/10/2012 15:54'!
and :extraDep =
	anything:src build(extraDep):ll build(extraDep):rr [self nextId]:ident
		-> [{#quoted.
				ll second, rr second copyWith:
					{#send. ''. #addSubExpression. self top. ident.
						{#send. ''. #eventStream. self get: #this. {#quote. #frpAnd}. {#quote. src}. extraDep.
							{#new. ''. self get: #Array. ll third. rr third}}}.
				self ref: ident}]! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 10/16/2012 14:36'!
begin :extraDep =
	anything:src &(anything anything) [OMeta2Fail signal]
|	anything:src build(extraDep)! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 8/30/2012 16:03'!
build :extraDep =
	&anything:n [attributes at: n ifAbsent: [false halt]]:quoted
	(?[quoted or: [n first == #call]]
		{&(anything:sel ?[self respondsTo: sel]) anything:sel [self apply: sel withArgs: {extraDep}]:n} [n]
	|	trans:n 	-> [{#quoted. #(). n}]
	)! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 8/10/2012 15:54'!
call :extraDep =
	anything:src {#var anything anything:sel} build(extraDep)*:as [self nextId]:ident
		[{#quoted.
			((as collect: #second) inject: #() into: [:s :e | s, e]) copyWith:
				{#send. ''. #addSubExpression.
					self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. sel}. {#quote. src}. extraDep. {#new. ''. self get: #Array},  
							(as collect: #third)}}.
			self ref: ident}]! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 8/6/2012 18:15'!
func :extraDep =
	trans*:ts -> [{#quoted. #(). {#func}, ts}]
	
//	anything:src anything:args anything:temps anything:hasReturn
//	[self pushStreamVariables]
//	[self pushDependencies]
//	transFunc:body
//	[self popDependencies]
//	[streamVariables last size]:varCount
//	[self popStreamVariables]:streams
//	(?[varCount = 0]
//		[{#quoted. #(). {#func. src. args. temps. hasReturn. body}}]
//		[{#quoted. #(). {#func. src. args. temps. hasReturn. body}}])

// The right thing to do may be to make an event stream of function as described below, but the users of such are not ready to take them.  like mergeE and others, we need to make __realSources__ on the client side then we can feed this extra dependency

//[self nextId]:ident
//			-> [{#quoted.
//					#() copyWith:
//					{#send. ''. #addSubExpression.
//						self namespace. ident.
//						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. #funcE}. {#quote. src}. extraDep. body. streams}}.
//				self ref: ident.}])! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 10/16/2012 14:37'!
if :extraDep =
	anything:src build(extraDep):cc build(extraDep):tt build(extraDep):ff [self nextId]:ident
		-> [{#quoted.
				cc second, tt second, ff second copyWith:
					{#send. ''. #addSubExpression. self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. #frpIf}. {#quote. src}. extraDep.
							{#new. ''. self get: #Array. cc third. tt third. ff third}}}.
				self ref: ident}]! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 8/10/2012 15:54'!
or :extraDep =
	anything:src build(extraDep):ll build(extraDep):rr [self nextId]:ident
		-> [{#quoted.
				ll second, rr second copyWith:
					{#send. ''. #addSubExpression. self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. #frpOr}. {#quote. src}. extraDep.
							{#new. ''. self get: #Array. ll third. rr third}}}.
				self ref: ident}]! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 4/11/2013 16:25'!
quotedVar :extraDep =
	anything:src anything:prime [OrderedCollection new]:result (
	(symbol:b (&anything [false] | [true]):last
		(?[result isEmpty]
			[dependencies last add: b]
			[result add: {#quoted. #(). self perform: (prime & last ifTrue: [#refLast:] ifFalse: [#ref:]) with: {#quote. b}}]
		| [self nextId]:ident [result add: {#quoted. #(). {#quote. b}}])
	| build(extraDep):b
		[self nextId]:ident
		(&anything [false] | [true]):last
		(?[result isEmpty]
			[result add: {#quoted. b second. {#get. ''. {#var. 'this'. #this}. b third}}]
		| [result add: b]))+
		[(result size = 1 and: [result first second isEmpty]) ifTrue: [
			result first] ifFalse: [
			{#quoted. ((result collect: #second) inject: #() into: [:s :n | s, n]) copyWith:
				{#send. ''. #addSubExpression.
					self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. #getE}. {#quote. src}. extraDep. {#new. ''. self get: #Array. {#quote. prime & last}}, (result collect: #third)}}. self perform: (prime & last ifTrue: [#refLast:] ifFalse: [#ref:]) with: ident}]]
	)! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 8/10/2012 15:54'!
send :extraDep =
	anything:src anything:sel build(extraDep):r build(extraDep)*:as [self nextId]:ident
		-> [{#quoted.
				((as collect: #second) inject: r second into: [:s :e | s, e]) copyWith:
					{#send. ''. #addSubExpression.
						self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. sel}. {#quote. src}. extraDep. {#new. ''. self get: #Array. r third},
							(as collect: #third)}}.
				self ref: ident.}]! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 4/12/2013 13:59'!
trans =
	{#call anything:src {#var '$$' anything}
		[self pushDependencies]
		build({#quote. nil}):arg
		(&anything trans | [{#quote. nil}]):setter
		[self popDependencies]:deps
	}
		-> [{#begin. ''.
			{#decl. 'pvtStrm'. {#quote. #pvtStrm}.
				{#new. ''. {#var. KSProtoObject eventStreamClass name asString. KSProtoObject eventStreamClass name}}}},
			arg second,
			{{#send. ''. #finalizeTopLevelCreationWith. {#var. 'pvtStrm'. #pvtStrm}. deps}}]
|	{#quotedVar anything anything:prime [{#var. 'this'. #this}]:tree
		((symbol:b [{#fieldName. b}] | trans):b (&anything [false] | [true]):last
			[{#get. ''. tree. b}]:tree
			[prime & last
				ifFalse: [{#send. ''. #currentValue. tree}]
				ifTrue: [{#send. ''. #lastValue. tree}]]:tree)+}
				-> [tree]
|	~(anything:x ?[x isString or: [x isSymbol]]) {trans*:xs}				-> [xs asArray]
|	anything! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 10/1/2012 19:40'!
update :extraDep =
	anything:src
	[self pushDependencies]
	trans:init
	[self popDependencies]
	anything:inc
	(&{#quote nil} [false] | [true]):hasTick
	build({#quote. nil}):tick
	[hasTick ifTrue: [self pushDependencies]]
	empty(inc) build(tick third):inc
	[hasTick ifTrue: [self popDependencies]]  // this push and pop effectively remove the dependencies in the expr of update.
	[self nextId]:ident
		-> [{#quoted.
				(tick second, inc second) copyWith:
					{#send. ''. #addSubExpression.
						self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. #update}. {#quote. src}. extraDep. {#new. ''. self get: #Array. init. inc third. tick third}}}.
				self ref: ident}]! !

!KSQuoteTranslator methodsFor: 'rules' stamp: 'yo 4/11/2012 21:56'!
var :extraDep =
	anything:src anything:v
		-> [{#quoted. #(). {#var. src. v}}]! !

!KSQuoteTranslator methodsFor: 'support' stamp: 'yo 7/5/2012 10:16'!
get: v
	^ {#var. v asString. v}! !

!KSQuoteTranslator methodsFor: 'support' stamp: 'yo 4/12/2012 00:29'!
popDependencies
	^ {#new. ''. {#var. 'Array'. #Array}}, (dependencies removeLast collect: [:e | self ref: {#quote. e}]) asArray! !

!KSQuoteTranslator methodsFor: 'support' stamp: 'yo 4/12/2012 00:29'!
pushDependencies
	dependencies add: IdentitySet new.! !

!KSQuoteTranslator methodsFor: 'support' stamp: 'yo 8/1/2012 11:35'!
ref: ident
	^ {#send. ''. #ref. {#var. 'KSEventStreamRef'. #KSEventStreamRef}. ident}! !

!KSQuoteTranslator methodsFor: 'support' stamp: 'yo 8/1/2012 11:35'!
refLast: ident
	^ {#send. ''. #refLast. {#var. 'KSEventStreamRef'. #KSEventStreamRef}. ident}! !
