OMeta2 subclass: #KSQuoteTranslator2
	instanceVariableNames: 'id dependencies attributes'
	classVariableNames: 'Debug'
	poolDictionaries: ''
	category: 'KScript'!

!KSQuoteTranslator2 methodsFor: 'initialization' stamp: 'yo 4/11/2013 16:34'!
initialize
	super initialize.
	dependencies := OrderedCollection new.
	id := 0.! !

!KSQuoteTranslator2 methodsFor: 'initialization' stamp: 'yo 4/11/2013 16:35'!
nextId
	^ {#quote. ('tt', (id := id + 1) printString) asSymbol}! !

!KSQuoteTranslator2 methodsFor: 'initialization' stamp: 'yo 4/11/2013 16:35'!
top
	^ #(#var 'pvtStrm' #pvtStrm)! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:21'!
and :extraDep =
	anything:src build(extraDep):ll build(extraDep):rr [self nextId]:ident
		-> [{#quoted.
				ll second, rr second copyWith:
					{#send. ''. #addSubExpression. self top. ident.
						{#send. ''. #eventStream. self get: #this. {#quote. #frpAnd}. {#quote. src}. extraDep.
							{#new. ''. self get: #Array. ll third. rr third}}}.
				self ref: ident}]! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:21'!
begin :extraDep =
	anything:src &(anything anything) [OMeta2Fail signal]
|	anything:src build(extraDep)! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:21'!
build :extraDep =
	&anything:n [attributes at: n ifAbsent: [false]]:quoted
	(?[quoted or: [n first == #call]]
		{&(anything:sel ?[self respondsTo: sel]) anything:sel [self apply: sel withArgs: {extraDep}]:n} [n]
	|	trans:n 	-> [{#quoted. #(). n}]
	)! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:22'!
call :extraDep =
	anything:src {#var anything anything:sel} build(extraDep)*:as [self nextId]:ident
		[{#quoted.
			((as collect: #second) inject: #() into: [:s :e | s, e]) copyWith:
				{#send. ''. #addSubExpression.
					self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. sel}. {#quote. src}. extraDep. {#new. ''. self get: #Array},  
							(as collect: #third)}}.
			self ref: ident}]! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:57'!
fby :extraDep =
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

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 20:24'!
fieldRef :extraDep =
	anything:src anything:prime [OrderedCollection new]:result (
	({#fieldName symbol:b} (&anything [false] | [true]):last
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

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:53'!
func :extraDep =
	trans*:ts -> [{#quoted. #(). {#func}, ts}]! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:53'!
if :extraDep =
	anything:src build(extraDep):cc build(extraDep):tt build(extraDep):ff [self nextId]:ident
		-> [{#quoted.
				cc second, tt second, ff second copyWith:
					{#send. ''. #addSubExpression. self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. #frpIf}. {#quote. src}. extraDep.
							{#new. ''. self get: #Array. cc third. tt third. ff third}}}.
				self ref: ident}]! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:53'!
or :extraDep =
	anything:src build(extraDep):ll build(extraDep):rr [self nextId]:ident
		-> [{#quoted.
				ll second, rr second copyWith:
					{#send. ''. #addSubExpression. self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. #frpOr}. {#quote. src}. extraDep.
							{#new. ''. self get: #Array. ll third. rr third}}}.
				self ref: ident}]! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:54'!
send :extraDep =
	anything:src anything:sel build(extraDep):r build(extraDep)*:as [self nextId]:ident
		-> [{#quoted.
				((as collect: #second) inject: r second into: [:s :e | s, e]) copyWith:
					{#send. ''. #addSubExpression.
						self top. ident.
						{#send. ''. #eventStream. {#var. 'this'. #this}. {#quote. sel}. {#quote. src}. extraDep. {#new. ''. self get: #Array. r third},
							(as collect: #third)}}.
				self ref: ident.}]! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 16:38'!
start :dict =
	[attributes := dict]
	trans! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 9/6/2013 12:11'!
trans =
	{#call anything:src {#var '$$' anything}
		[self pushDependencies]
		build({#quote. nil}):arg
		[self popDependencies]:deps
	}
		-> [{#begin. ''.
			{#decl. 'pvtStrm'. {#quote. #pvtStrm}.
				{#new. ''. {#var. KSProtoObject eventStreamClass name asString. KSProtoObject eventStreamClass name}}}},
			arg second,
			(arg second size > 0 ifTrue: [
				{{#send. ''. #finalizeTopLevelCreationWith2. {#var. 'pvtStrm'. #pvtStrm}. deps}}]
			ifFalse: [
				{{#send. ''. #finalizeToSingletonStream2. {#var. 'pvtStrm'. #pvtStrm}. arg third. {#var. 'this'. #this}}}])]
|	~(anything:x ?[x isString or: [x isSymbol]]) {trans*:xs}				-> [xs asArray]
|	anything! !

!KSQuoteTranslator2 methodsFor: 'rules' stamp: 'yo 4/11/2013 19:54'!
var :extraDep =
	anything:src anything:v
		-> [{#quoted. #(). {#var. src. v}}]! !

!KSQuoteTranslator2 methodsFor: 'support' stamp: 'yo 4/12/2013 10:49'!
get: v
	^ {#var. v asString. v}! !

!KSQuoteTranslator2 methodsFor: 'support' stamp: 'yo 4/11/2013 16:30'!
popDependencies
	^ {#new. ''. {#var. 'Array'. #Array}}, (dependencies removeLast collect: [:e | self ref: {#quote. e}]) asArray! !

!KSQuoteTranslator2 methodsFor: 'support' stamp: 'yo 4/11/2013 16:30'!
pushDependencies
	dependencies add: IdentitySet new.! !

!KSQuoteTranslator2 methodsFor: 'support' stamp: 'yo 4/11/2013 16:32'!
ref: ident
	^ {#send. ''. #ref. {#var. 'KSEventStreamRef'. #KSEventStreamRef}. ident}! !

!KSQuoteTranslator2 methodsFor: 'support' stamp: 'yo 4/11/2013 16:33'!
refLast: ident
	^ {#send. ''. #refLast. {#var. 'KSEventStreamRef'. #KSEventStreamRef}. ident}! !
