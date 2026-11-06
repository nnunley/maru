IdentityDictionary subclass: #KSNewEventStream
	instanceVariableNames: 'currentValue type updater code shouldEventTrigger lastValue lastCheckTime lastTime homeObject version visited subExpressions eventSourcesCache sources getSources isBehavior dormant origSources m p func initialValue behavior pastValues interval receiver restArgs selector c1 c2 cTest tClause fClause last base keys argCollection streamName found duration start done expr name'
	classVariableNames: 'Twinkle'
	poolDictionaries: ''
	category: 'KSObjects'!

!KSNewEventStream methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/6/2013 11:43'!
ppContentsInto: newElem context: dictionary
	"This should only be called for the top level stream."
	| val |
	newElem attributeAt: #'__type__' put: type.
	newElem attributeAt: #'__code__' put: code.
	newElem attributeAt: #'__dormant__' put: dormant printString.
	newElem attributeAt: #'__version__' put: version printString.
"	(self at: #'__type__') = 'setter' ifFalse: [
		compiledCode := dictionary codeMapAt: (self at: #'__code__').
		newElem attributeAt: #'__compiledCode__' put: compiledCode]."
	isBehavior ifTrue: [
		newElem attributeAt: #'__isBehavior__' put: 'true'.
		val := currentValue]
	ifFalse: [
		val := KSObject undefined].
	val ~~ KSObject undefined ifTrue: [
		newElem addElement: (newElem dictionaryKey: '__currentValue__' andValue: val
		Into: (PPElement head: #slot attributes: #()) context: dictionary)].
	newElem attributeAt: #'__homeObject__' put: ((dictionary lookup: homeObject) attributeAt: #ref).! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:18'!
code
	^ code! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'tk 2/27/2013 15:25'!
dormant
	^ dormant! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'tk 2/27/2013 15:25'!
dormant: aBoolean 
	dormant := aBoolean! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 15:07'!
getKeys
	^ keys! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:30'!
homeObject: anObject
	homeObject := anObject.! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 11:00'!
lastCheckTime
	^ lastCheckTime! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 23:21'!
lastTime
	^ lastTime! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 20:25'!
lastValue
	^ lastValue! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 15:23'!
name: aString
	name := aString! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:30'!
sources
	^ sources! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:42'!
sources: aCollection
	sources := aCollection.! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:19'!
type
	^ type! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:35'!
visited
	^ visited! !

!KSNewEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:35'!
visited: aBoolean
	visited := aBoolean! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 9/10/2013 19:25'!
argCollection
	^ argCollection! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 1/23/2013 19:30'!
code: aString
	code := aString! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 1/23/2013 19:28'!
currentValue: anObject
	currentValue := anObject.! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 9/9/2013 11:15'!
eventSourcesCache
	^ eventSourcesCache! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 3/28/2013 16:49'!
getSources
	^ getSources! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 3/28/2013 16:43'!
getSources: aCollection
	getSources := aCollection! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 9/9/2013 13:42'!
homeObject
	^ homeObject! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 1/23/2013 23:21'!
isBehavior: aBoolean
	isBehavior := aBoolean! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 9/10/2013 17:42'!
name
	^ name! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 9/10/2013 19:34'!
streamName
	^ streamName! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 1/23/2013 13:59'!
subExpressions: aCollection
	subExpressions := aCollection.! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 9/6/2013 16:21'!
version
	^ version! !

!KSNewEventStream methodsFor: 'accessing- private' stamp: 'yo 9/6/2013 11:28'!
version: aNumber
	version := aNumber! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 10:32'!
M: sel with: c with: extraDep with: arguments
	"Set up a Matrix2x3 combinator".
	self setup: sel with: c with: extraDep with: arguments.
	m := (arguments copyFrom: 1 to: 6) asArray.
	updater := [:space :evaluator |
		(m collect: [:e | space frpGet: e]) asMatrixTransform2x3].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 9/10/2013 11:51'!
P: sel with: c with: extraDep with: arguments
	"Set up a Point combinator".
	self setup: sel with: c with: extraDep with: arguments.
	p := Array with: arguments first with: arguments second.
	updater := [:space :evaluator |
		(space frpGet: p first)@(space frpGet: p second)].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 10:45'!
collectE: sel with: c with: extraDep with: arguments
	"Set up a collectE combinator.  The arguments for the function argument is (new, old).".
	self setup: sel with: c with: extraDep with: arguments.
	func := arguments third.
	initialValue := arguments second.
	behavior := arguments first.
	updater := [:space :evaluator |
		(space frpGet: func)
			value: (space frpGet: behavior)
			value: (currentValue == KSObject undefined
				ifTrue: [space frpGet: initialValue]
				ifFalse: [currentValue])]
.! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 10:46'!
delayE: sel with: c with: extraDep with: arguments
	"Set up a delayE combinator.".
	self setup: sel with: c with: extraDep with: arguments.
	pastValues := OrderedCollection new.
	interval := arguments second.
	behavior := arguments first.
	updater := [:space :evaluator |
		self delayEUpdater: space with: evaluator].
	shouldEventTrigger := [:space :time :evaluator |
		(self basicShouldEventTrigger: space with: evaluator)
			or: [pastValues size > 0 and: [(pastValues first at: #time) < (time - (space frpGet: interval))]]]! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 10:54'!
doE: sel with: c with: extraDep with: arguments
	"Set up a doE combinator.  The argument is a nullary function to be evaluated.".
	self setup: sel with: c with: extraDep with: arguments.
	func := arguments second.
	behavior := arguments first.
	updater := [:space :evaluator |
		(space frpGet: behavior) == KSObject undefined
			ifTrue: [KSObject undefined] ifFalse: [(space frpGet: func) value]]! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 10:57'!
exprE: sel with: c with: extraDep with: arguments
	"Set up a generic expression (a message sending) combinator."
	self setup: sel with: c with: extraDep with: arguments.
	type := #exprE.
	receiver := arguments first.
	restArgs := arguments copyFrom: 2 to: arguments size.
	selector := KSCompiler squeakSelectorFor: sel.
	updater := [:space :evaluator |
		(space frpGet: receiver) ksPerform: selector with: (restArgs collect: [:x | space frpGet: x])].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 10:57'!
frpAnd: sel with: c with: extraDep with: arguments
	"Set up a combinator for &&."
	self setup: sel with: c with: extraDep with: arguments.
	c1 := arguments first.
	c2 := arguments second.
	updater := [:space :evaluator |
		(space frpGet: c1) asBoolean & (space frpGet: c2)asBoolean].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 10:57'!
frpIf: sel with: c with: extraDep with: arguments
	"Set up a combinator for if then else.."
	self setup: sel with: c with: extraDep with: arguments.
	cTest := arguments first.
	tClause := arguments second.
	fClause := arguments third.
	updater := [:space :evaluator |
		(space frpGet: cTest) asBoolean ifTrue: [space frpGet: tClause] ifFalse: [space frpGet: fClause]].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:01'!
frpOr: sel with: c with: extraDep with: arguments
	"Set up a combinator for ||."
	self setup: sel with: c with: extraDep with: arguments.
	c1 := arguments first.
	c2 := arguments second.
	updater := [:space :evaluator |
		(space frpGet: c1) asBoolean | (space frpGet: c2) asBoolean].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:07'!
getE: sel with: c with: extraDep with: arguments
	"Set up a combinator for field access. It could be a long chain of field names."
	self setup: sel with: c with: extraDep with: arguments.
	last := arguments first.
	base := arguments second.
	keys := arguments copyFrom: 3 to: arguments size.
	updater := [:space :evaluator |
		| v |
		v := self findForGet: space.
		v currentValue == KSObject undefined
			ifTrue: [KSObject undefined]
			ifFalse: [last ifTrue: [v lastValue] ifFalse: [v currentValue]]].
	shouldEventTrigger := [:space :time :evaluator |
		| v |
		v := self findForGet: space.
		v isEventStream and: [v currentValue ~~ KSObject undefined and: [v currentValue ~~ lastValue]]].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:08'!
mapE: sel with: c with: extraDep with: arguments
	"Set up a mapE combinator."
	self setup: sel with: c with: extraDep with: arguments.
	func := arguments second.
	behavior := arguments first.
	updater := [:space :evaluator |
		| arg |
		arg := space frpGet: behavior.
		arg == KSObject undefined
			ifTrue: [KSObject undefined] ifFalse: [(space frpGet: func) value: arg]]! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:12'!
mergeE: sel with: c with: extraDep with: arguments
	"Set up a mergeE combinator."
	self setup: sel with: c with: extraDep with: arguments.
	origSources := sources copy.
	updater := [:space :evaluator |
		self mergeEUpdater: space with: evaluator].
	shouldEventTrigger := [:space :t :evaluator |
		self mergeEShouldEventTrigger: space with: t with: evaluator].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:12'!
oneE: sel with: c with: extraDep with: arguments
	"Set up a oneE combinator."
	self setup: sel with: c with: extraDep with: arguments.
	initialValue := arguments first.
	updater := [:space :evaluator |
		currentValue == KSObject undefined ifTrue: [
			space frpGet: initialValue]
		ifFalse: [
			KSObject undefined]].
	shouldEventTrigger := [:space :time :evaluator |
		currentValue == KSObject undefined].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:12'!
setter: sel with: c with: extraDep with: arguments
	"Set up a simple value stream."
	self setup: sel with: c with: extraDep with: arguments.
	updater := [:space :evaluator | KSObject undefined].
	shouldEventTrigger := [:space :time :evaluator | false].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:13'!
setup: sel with: c with: extraDep with: arguments
	"Common code for setting up streams."
	type := sel.
	code := c.
	sources := (extraDep ifNotNil: [{extraDep}] ifNil: [self dependenciesFrom: arguments]) asArray.
	currentValue := KSObject undefined.
	lastValue := KSObject undefined.
	self setLastTime: 0.
	shouldEventTrigger := [:space :time :evaluator |
		self basicShouldEventTrigger: space with: evaluator].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 4/17/2013 00:58'!
singleton: sel with: c with: extraDep with: arguments
	"Set up a simple value stream."
	self setup: sel with: c with: extraDep with: arguments.
	behavior := arguments first.
	updater := [:space :evaluator | space frpGet: behavior].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:13'!
switchColE: sel with: c with: extraDep with: arguments
	"Set up a switchColE combinator.  It takes a collection and a stream name and does merge them."
	self setup: sel with: c with: extraDep with: arguments.
	argCollection := arguments first.
	streamName := arguments second asSymbol.
	found := nil.
	updater := [:space :evaluator |
		| f |
		f := found.
		found := nil.
		space frpGet: f].
	shouldEventTrigger := [:space :time :evaluator |
		self switchColEShouldEventTrigger: space with: time with: evaluator].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:20'!
timerE: sel with: c with: extraDep with: arguments
	"Set up a timerE combinator."
	self setup: sel with: c with: extraDep with: arguments.
	interval := arguments first.
	updater := [:space :evaluator |
		self ceilTime: (evaluator at: #'__currentTime__')].
	shouldEventTrigger := [:space :time :evaluator |
		dormant ~~ true and: [(lastTime + (space frpGet: interval)) <= time]].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 3/14/2013 11:24'!
timerEDuration: sel with: c with: extraDep with: arguments
	"Set up a timerEDuration combinator.  It is similar to timerE, but it stops after the duration expires and the values are [0... duration]."
	self setup: sel with: c with: extraDep with: arguments.
	interval := arguments first.
	duration := arguments second.
	start := nil.
	done := false.
	updater := [:space :evaluator |
		| dur val |
		dur := space frpGet: duration.
		start == nil ifTrue: [
			start := self ceilTime: (evaluator at: #'__currentTime__')].
		val := self ceilTime: (evaluator at: #'__currentTime__') - start.
		val >= dur ifTrue: [
			done := true.
			val := dur].
		val].
	shouldEventTrigger := [:space :time :evaluator |
		dormant ~~ true and: [
			start == nil or: [done not or: [
				(lastTime + (space frpGet: interval)) <= time and: [
					(start + (space frpGet: duration)) >= time]]]]].! !

!KSNewEventStream methodsFor: 'combinators' stamp: 'yo 9/6/2013 12:54'!
update: sel with: c with: extraDep with: arguments
	"Set up a updating combinator.  Which is used for self-referencing expression."
	self setup: sel with: c with: extraDep with: arguments.
	expr			:= arguments second.
	initialValue		:= arguments first.
	currentValue 	:= arguments first.
	lastValue		:= arguments first.
	isBehavior		:= true.
	updater 		:= [:space :evaluator | space frpGet: expr].! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 14:03'!
addSubExpression: id with: expression
	subExpressions ifNil: [subExpressions := OrderedCollection new].
	subExpressions add: id.
	self at: id put: expression.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 9/9/2013 13:33'!
basicShouldEventTrigger: space with: evaluator
	| doAnyway |
	doAnyway := false.
	eventSourcesCache ifNil: [
		eventSourcesCache := OrderedCollection new.
		doAnyway := true].
	((evaluator at: #'__invalidated__') or: [doAnyway]) ifTrue: [
		eventSourcesCache reset.
		sources do: [:src |
			| v |
			v := space lookup: src.
			(v == KSObject undefined or: [v isEventStream]) ifTrue: [eventSourcesCache add: v]]].
	eventSourcesCache do: [:src |
		src == KSObject undefined ifTrue: [^ false].
		src currentValue == KSObject undefined ifTrue: [^ false].
		(self isEarlierThan: src) ifTrue: [
			Twinkle ifTrue: [
				self twinkleFrom: src].
				^ true]].
	^ false.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 23:22'!
beBehavior
	isBehavior := true.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 10:30'!
ceilTime: t
	^ (t / interval) asInteger * interval! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/25/2013 11:00'!
clearEvents: aNumber
	self do: [:v |
		v isEventStream ifTrue: [v clearEvents: aNumber]].
	self setLastTime: aNumber.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 10:30'!
currentValue
	^ currentValue! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 22:44'!
delayEFind: t
	[pastValues size > 1] whileTrue: [
		(pastValues second at: #time) >= t ifTrue: [^ self].
		pastValues removeFirst].! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 22:45'!
delayEUpdater: space with: evaluator
	| val t lastT |
	val := space frpGet: behavior.
	lastT := (space lookup: behavior) lastTime.
	lastT > lastTime ifTrue: [
		pastValues add: ({#value -> val. #time -> lastT} as: KSObject)].
	pastValues size = 0 ifTrue: [^ KSObject undefined].
	t := (evaluator at: #'__currentTime__') - (space frpGet: interval).
	self delayEFind: t.
	^ (pastValues first at: #time) < t ifTrue: [pastValues removeFirst at: #value] ifFalse: [KSObject undefined]! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 4/3/2013 14:28'!
dependenciesFrom: aCollection
	^ aCollection select: [:elem | elem isEventStreamRef and: [elem last ~~ true]]! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 2/27/2013 17:40'!
evalSubExpressionAt: t with: space with: evaluator
	| val |
	val := updater value: space value: evaluator.
	val ~~ KSObject undefined ifTrue: [
		lastValue := currentValue := val.
		self setLastTime: t.
		^ true].
	^ false.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 9/6/2013 11:28'!
finalizeToSingletonStream2: aValue with: anObject
	^ (self finalizeToSingletonStream: aValue with: anObject) version: 2.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 4/17/2013 00:50'!
finalizeToSingletonStream: aValue with: anObject
	(aValue isEventStreamRef and: [aValue last ~~ true]) ifTrue: [
		self addSubExpression: #tt1 with: (anObject eventStream: #singleton with: aValue ref asString with: nil with: {aValue}).
		^ self finalizeTopLevelCreationWith: {aValue}
	].
	^ self of: aValue.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 9/6/2013 11:27'!
finalizeTopLevelCreationWith2: aCollection
	^ (self finalizeTopLevelCreationWith: aCollection) version: 2.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 4/3/2013 14:37'!
finalizeTopLevelCreationWith: aCollection
	| top additionalCollection col |
	top := self at: subExpressions pop.
	additionalCollection := aCollection ifNil: [OrderedCollection new].
	top subExpressions: (col := subExpressions asArray).
	col do: [: id |
		top at: id put: (self at: id)].
	additionalCollection do: [:elem |
		| hasIt |
		hasIt := false.
		top sources do: [:e |
			(e isEventStreamRef and: [e ref == elem ref and: [e last == elem last]]) ifTrue: [
				hasIt := true]].
		hasIt ifFalse: [
			elem last == true ifFalse: [top sources: (top sources copyWith: elem)]]].
	top type == #getE ifTrue: [
		top getSources: (Array with: top).
		^ top].
	top getSources: (col collect: [:id | top at: id] thenSelect: [:s | s type == #getE]).
	^ top! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 10:56'!
findForGet: space
	| v ind |
	v := space frpGet: base.
	ind := 1.
	[ind <= keys size and: [v ~~ KSObject undefined]] whileTrue: [
		v := v ksAt: (space frpGet: (keys at: ind)).
		ind := ind + 1].
	^ v! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 19:47'!
frpGet: n
	| v |
	v := self lookup: n.
	last := n isEventStreamRef and: [n last].
	(v isEventStream and: [last == true]) ifTrue: [
		^ v lastValue].
	^ v currentValue.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 9/6/2013 10:33'!
isEarlierThan: other
	| otherTime |
	otherTime := other lastTime.
	^ otherTime = -1 or: [
		otherTime > lastCheckTime]! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 10:59'!
isEventStream
	^ true! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 3/1/2013 22:04'!
isLayoutChangedDependents
	(type == #getE and: [keys last == #layoutChanged]) ifTrue: [^ true].
	sources do: [:e |
		| s |
		s := self ksAt: e ref.
		(s isEventStream and: [s type == #getE and: [s getKeys last == #layoutChanged]]) ifTrue: [^ true]].
	^ false.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 11:00'!
ksAt: key 
	^ self at: key ifAbsent: [
		homeObject ifNotNil: [^ homeObject ksAt: key ].
		KSObject undefined]! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 11:00'!
ksAt: key put: val
	^ self at: key put: val.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 14:53'!
lookup: n
	n isEventStreamRef ifTrue: [
		| v |
		v := self ksAt: n ref.
		(v isEventStream and: [v type == #getE]) ifTrue: [
			^ v findForGet: self]
		ifFalse: [^ v]].
	^ n! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 3/28/2013 16:02'!
lookupForSort: n
	"look up the actual stream for given EventStreamRef."
	n isEventStreamRef ifTrue: [
		^ self ksAt: n ref]
	ifFalse: [^ n].! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 9/6/2013 10:32'!
maybeEvalAt: t with: evaluator
	| changed |
	changed := false.
	subExpressions do: [:id |
		| elem |
		elem := self ksAt: id.
		(elem shouldTrigger: self with: t with: evaluator) ifTrue: [
			changed := (elem evalSubExpressionAt: t with: self with: evaluator) or: [changed]]].
	(self shouldTrigger: self with: t with: evaluator) ifTrue: [
		| val |
		val := updater value: self value: evaluator.
		val ~~ KSObject undefined ifTrue: [
			lastValue := currentValue.
			self setLastTime: (type == #timerE ifTrue: [val] ifFalse: [t]).
			currentValue := val.
			changed := true].
		t > lastCheckTime ifTrue: [
			lastCheckTime := t]].
	^ changed.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/24/2013 20:25'!
mergeEShouldEventTrigger: space with: t with: evaluator
	| doAnyway |
	doAnyway := false.
	eventSourcesCache ifNil: [
		eventSourcesCache := OrderedCollection new.
		doAnyway := true].

	((evaluator at: #'__invalidated__') or: [doAnyway]) ifTrue: [
		eventSourcesCache reset.
		origSources do: [:src |
			| v |
			v := space lookup: src.
			v isEventStream ifTrue: [
				eventSourcesCache add: v]]].

	eventSourcesCache do: [:src |
		(src currentValue ~~ KSObject undefined and: [self isEarlierThan: src])
			ifTrue: [^ true]].
	^ false! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 19:23'!
mergeEUpdater: space with: evaluator
	origSources do: [:id |
		| s |
		s := space lookup: id.
		(s currentValue ~~ KSObject undefined
			and: [s isEventStream and: [self isEarlierThan: s]]) ifTrue: [
				^ space frpGet: s]].
	^ KSObject undefined.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 2/27/2013 18:28'!
set: val
	currentValue := val.
	self setLastTime: self ksCurrentTime.
	^ val.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 11:19'!
setLastTime: aNumber 
	lastTime := aNumber.
	lastCheckTime := aNumber.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'ael 3/26/2013 11:23'!
setPropagatingLater: val
	currentValue := val.
	self setLastTime: -2.
	^ val.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/23/2013 11:20'!
shouldTrigger: space with: time with: evaluator 
	^ shouldEventTrigger
		value: space
		value: time
		value: evaluator! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 1/29/2013 19:21'!
startsWith: initialValue 
	currentValue := initialValue.
	isBehavior := true.
	self setLastTime: -1.
	self sync.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 9/10/2013 19:15'!
switchColEShouldEventTrigger: space with: t with: evaluator
	| attr col |
	col := space lookup: argCollection.
	attr := space lookup: streamName.
	col do: [:arg |
		| s |
		s := (space lookup: arg) ksAt: attr.
		(s isEventStream and: [self isEarlierThan: s]) ifTrue: [
			found := s.
			Twinkle ifTrue: [
				self twinkleFrom: s].
			^ true]].
	found := nil.
	^ false.! !

!KSNewEventStream methodsFor: 'evaluation' stamp: 'yo 9/6/2013 10:46'!
sync
	(currentValue ~~ KSObject undefined) ifTrue: [
		lastValue := currentValue]! !

!KSNewEventStream methodsFor: 'explorer' stamp: 'yo 1/23/2013 19:25'!
asExplorerString
	^self currentValue printString, '    ', self code.! !

!KSNewEventStream methodsFor: 'explorer' stamp: 'ael 2/28/2013 23:55'!
explorerContents
	| ivDict keyDict topLevel |
	topLevel := OrderedCollection new.
	topLevel add: (ObjectExplorerWrapper with: currentValue name: #currentValue model: self).
	ivDict := IdentityDictionary new.
	self class allInstVarNames withIndexDo: [:each :index |
		ivDict at: each asSymbol put: (self instVarAt: index)
		].
	topLevel add: (ObjectExplorerWrapper with: ivDict name: #'(vars)' model: self).

	keyDict := IdentityDictionary new.
	self keys do: [ :key |
		keyDict at: (key printString contractTo: 32) put: (self at: key)
		].
	keyDict ifNotEmpty: [
		topLevel add: (ObjectExplorerWrapper with: keyDict name: #'(keys)' model: self).
		].
	
	^topLevel! !

!KSNewEventStream methodsFor: 'explorer' stamp: 'ael 1/24/2013 17:03'!
hasContentsInExplorer
	^true! !

!KSNewEventStream methodsFor: 'initialization' stamp: 'yo 9/6/2013 10:32'!
initialize
	super initialize.
	isBehavior := false.
	currentValue := lastValue := KSObject undefined.! !

!KSNewEventStream methodsFor: 'initialization' stamp: 'yo 9/6/2013 12:09'!
of: anObject
	self setter: #setter with: anObject ksString with: nil with: {anObject}.
	anObject ~~ KSObject undefined ifTrue: [
		self currentValue: anObject.
		self setLastTime: -1].
	self subExpressions: #().
	self getSources: #().
	self sync.! !

!KSNewEventStream methodsFor: 'printing' stamp: 'yo 1/23/2013 20:08'!
printOn: aStream
	aStream nextPutAll: 'KSEventStream(';
		nextPutAll: type;
		nextPutAll: ': ';
		nextPutAll: code;
		nextPutAll: ')'! !

!KSNewEventStream methodsFor: 'testing' stamp: 'yo 3/14/2013 10:31'!
= other
	"Make sure to use the simple equality."
	^ other == self! !

!KSNewEventStream methodsFor: 'twinkling' stamp: 'yo 9/10/2013 11:17'!
twinkleFrom: src
	(KSTwinkleRequest src: src dst: self) signal! !

!KSNewEventStream methodsFor: 'unit testing' stamp: 'yo 3/26/2013 18:34'!
property: aSymbol
	^ self instVarNamed: (aSymbol asString copyWithout: $_)! !

!KSNewEventStream class methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/6/2013 15:46'!
ppCreateInstanceFromSexp: sexp ref: ref from: from to: to
	| inst val this cv version |
	val := KSObject undefined.
	cv := sexp keyValueNamed: '__currentValue__'.
	version := sexp attributeAt: #'__version__' ifAbsent: [nil].
	cv ifNotNil: [
		val := to readSlot: cv into: nil from: from to: to].
	this := to fromPPSexp: (from at: (sexp attributeAt: #'__homeObject__') asSymbol) from: from to: to.
	(sexp attributeAt: #'__type__') = 'setter' ifTrue: [
		inst := self of: val.
		inst code: (sexp attributeAt: #'__code__').
		inst setLastTime: -1.
		to at: ref put: inst]
	ifFalse: [
		version = 2 ifTrue: [
			inst := this evalSqueakString: (to codeForDefinition2: (sexp attributeAt: #'__code__')).
		] ifFalse: [
			((sexp attributeAt: #'__code__') includesSubString: 'heading1') ifTrue: ["self halt"].
			inst := this evalSqueakString: (to codeForDefinition: '$$(', (sexp attributeAt: #'__code__'), ')').
		].
		inst version: version.
		inst code: (sexp attributeAt: #'__code__').
		inst setLastTime: 0.
		to at: ref put: inst].
	(sexp attributeAt: #'__isBehavior__' ifAbsent: []) asBoolean ifTrue: [
		inst isBehavior: true.
		inst currentValue: val].
	inst sync.
	inst dormant: (sexp attributeAt: #'__dormant__' ifAbsent: ['']) = 'true'.
	^ inst.! !

!KSNewEventStream class methodsFor: 'instance creation' stamp: 'yo 1/23/2013 15:00'!
new
	^ super new initialize; yourself! !

!KSNewEventStream class methodsFor: 'instance creation' stamp: 'yo 4/17/2013 00:46'!
of: anObject
	^ self new of: anObject.! !

!KSNewEventStream class methodsFor: 'squeak interface' stamp: 'yo 1/23/2013 14:58'!
inspectorClass
	^ Inspector! !

!KSNewEventStream class methodsFor: 'twinkling' stamp: 'yo 9/9/2013 10:51'!
initialize
"
	self initialize
"
	super initialize.
	Twinkle := false.! !

!KSNewEventStream class methodsFor: 'twinkling' stamp: 'yo 9/9/2013 10:01'!
twinkle
	Twinkle := true! !

!KSNewEventStream class methodsFor: 'twinkling' stamp: 'yo 9/10/2013 10:55'!
twinkling
	^ Twinkle! !

!KSNewEventStream class methodsFor: 'twinkling' stamp: 'yo 9/9/2013 10:01'!
unTwinkle
	Twinkle := false! !
