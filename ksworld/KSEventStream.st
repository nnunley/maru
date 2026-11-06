KSObject subclass: #KSEventStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects'!

!KSEventStream methodsFor: '*ksobjects-pushpull' stamp: 'yo 3/1/2013 23:55'!
ppContentsInto: newElem context: dictionary
	"This should only be called for the top level stream."
	| val |
	newElem attributeAt: #'__type__' put: (self at: #'__type__').
	newElem attributeAt: #'__code__' put: (self at: #'__code__').
	newElem attributeAt: #'__dormant__' put: (self at: #'__dormant__') printString.
"	(self at: #'__type__') = 'setter' ifFalse: [
		compiledCode := dictionary codeMapAt: (self at: #'__code__').
		newElem attributeAt: #'__compiledCode__' put: compiledCode]."
	(self at: #'__isBehavior__' ifAbsent: [Undefined]) asBoolean ifTrue: [
		newElem attributeAt: #'__isBehavior__' put: 'true'.
		val := self at: #'__currentValue__']
	ifFalse: [
		val := Undefined].
	val ~~ Undefined ifTrue: [
		newElem addElement: (newElem dictionaryKey: '__currentValue__' andValue: val
		Into: (PPElement head: #slot attributes: #()) context: dictionary)].
	newElem attributeAt: #'__homeObject__' put: ((dictionary lookup: (self at: #'__homeObject__')) attributeAt: #ref).! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:18'!
code = () ->
	return this.__code__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 3/1/2013 23:54'!
dormant = (aValue) ->
	this.__dormant__ = aValue! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 15:07'!
getKeys = () ->
	return this.__keys__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:42'!
homeObject = (anObject) ->
	this.__homeObject__ = anObject! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/7/2013 14:58'!
lastCheckTime = () ->
	return this.__lastCheckTime__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/7/2013 14:58'!
lastTime = () ->
	return this.__lastTime__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 21:38'!
lastValue = () ->
	return this.__lastValue__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:23'!
name = (aString) ->
	this.__name__ = aString! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 21:00'!
property = (aString) ->
	return this[aString]! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:43'!
sources = (aCollection) ->
	this.__sources__ = aCollection! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 21:38'!
subExpressions = () ->
	return this.__subExpressions__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 19:40'!
synched = () ->
	return this.__synched__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 19:40'!
synching = () ->
	return this.__synching__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:19'!
type = () ->
	return this.__type__! !

!KSEventStream methodsFor: 'accessing' stamp: 'yo 1/23/2013 15:24'!
visited = (aBoolean) ->
	this.__visited__ = aBoolean! !

!KSEventStream methodsFor: 'as yet unclassified' stamp: 'yo 3/9/2012 19:06'!
evalAt = function(time, space) {
	this.lastValue = this.__currentValue__;
	this.__currentValue__ = this.type == "timerE" ? time : this.ksPerform("updater", space);
	this.lastTime = time;
}! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/9/2013 15:45'!
M = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__a11__				= arguments[0]
	this.__a12__				= arguments[1]
	this.__a13__				= arguments[2]
	this.__a21__				= arguments[3]
	this.__a22__				= arguments[4]
	this.__a23__				= arguments[5]
	this.__updater__		= (space, evaluator) ->
		M(space.frpGet(this.__a11__),
			space.frpGet(this.__a12__),
			space.frpGet(this.__a13__),
			space.frpGet(this.__a21__),
			space.frpGet(this.__a22__),
			space.frpGet(this.__a23__))
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/7/2013 15:47'!
P = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__x__				= arguments[0]
	this.__y__				= arguments[1]
	this.__updater__		= (space, evaluator) -> P(space.frpGet(this.__x__), space.frpGet(this.__y__))
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/19/2012 09:58'!
collectE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__func__						= arguments[2]
	this.__initialValue__					= arguments[1]
	this.__behavior__					= arguments[0]
	this.__updater__ = (space, evaluator) ->
		(space.frpGet(this.__func__))(space.frpGet(this.__behavior__),
			if this.__currentValue__ === undefined
				space.frpGet(this.__initialValue__)
			else
				this.__currentValue__)
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 6/29/2012 14:11'!
collectionE = (selector, code, extraDep, collection, streamName) ->
	this.ksPerform2("setup", arguments)
	this.__argCollection__ = collection
	this.__streamName__ = streamName._asSymbol()
	this.found = nil
	this.updater = (space) ->
		if this.found
			var f = this.found
			this.found = null
			return space.frpGet(f)
		undefined
	this.__shouldEventEvaluate__ =  (space) ->
		var col = space.lookup(this.__argCollection__)
		var attr = space.lookup(this.__streamName__)
		for arg in col
			var base = space.lookup(arg)
			var s = base[attr]
			if s._isEventStream() && s.lastTime > (this.lastTime ? -1) || s !!== undefined && !!s._isEventStream() && s !!= this.lastValue
				this.found = s
				return true
		this.found = null
		false
	return this

//collection:: Ref to Collection|Collection
// resolved collection: [KSObject | Ref]
//streamName Stringy | Ref
// as Ref is involved in the latter, collection of refs should resolve to collection of KsObjects! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 8/22/2012 16:47'!
delayE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__pastValues__				= []
	this.__interval__					= arguments[1]
	this.__behavior__					= arguments[0]
	this.__updater__ = (space, evaluator) ->
		var val = space.frpGet(this.__behavior__)
		var lastTime = space.lookup(this.__behavior__).lastTime()
		if lastTime > this.lastTime()
			this.__pastValues__.push({value: val, time: lastTime})
		if this.__pastValues__.size() == 0
			return undefined
		var t = evaluator.__currentTime__ - space.frpGet(this.__interval__)
		while this.__pastValues__.size() > 1
			if this.__pastValues__[1].time >= t
				break
			this.__pastValues__.removeFirst()
		var v
		v = if this.__pastValues__[0].time < t
			this.__pastValues__.removeFirst().value
		else
			undefined
		return v

	this.__shouldEventTrigger__ = (space, time, evaluator) ->
		this.basicShouldEventTrigger(space, evaluator) || this.__pastValues__.size() > 0 && this.__pastValues__[0].time < (time - space.frpGet(this.__interval__))
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/23/2013 15:29'!
doE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__func__		= arguments[1]
	this.__behavior__	= arguments[0]
	this.__updater__	= (space, evaluator) ->
		var val = space.frpGet(this.__behavior__)
		if val === undefined then undefined else (space.frpGet(this.__func__))()
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/24/2013 13:13'!
exprE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__type__					=	#"exprE"
	this.__receiver__				=	arguments[0]
	this.__restArgs__				=	arguments.slice(1)
	this.__selector__				=	KSCompiler.squeakSelectorFor(selector)
	this.__updater__ = (space, evaluator) ->
		space.frpGet(this.__receiver__).ksPerform(this.__selector__, (space.frpGet(x) for x in this.__restArgs__))
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/26/2012 15:58'!
extract = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__object__				=	arguments[0]
	this.__eventName__		=	arguments[1]
	this.__eventTime__			=	0
	this.__realObject__			=	nil
	this.updater = (space, evaluator) ->
		var o = space.frpGet(this.__object__)
		var ev = o.extract(this.__eventClass__)
		if !!ev
			return undefined
		var kev = KSObject._newLUserEvent_from(ev, o)
		return kev
	this.__shouldEventTrigger__ =  (space, time, evaluator) ->
		var o = space.frpGet(this.object)
		if !!o
			return false
		if o !!== this.__realObject__
			this.__realObject__ = o
			this.__eventTime__ = 0
			return true
		var ev = o._extract_for(EventNameMap[space.frpGet(this.__eventName__)], this.eventTime)
		if !!ev
			return false
		this.__eventClass__ = ev._class()
		if !!ev.timeStamp()
			ev.timeStamp(evaluator.__currentTime__)
		this.__eventTime__ = ev.timeStamp()
		this.__currentValue__.newValue !!= ev.newValue()

	this.__lastTime__				=	0
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/26/2012 15:52'!
extractE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__object__				=	arguments[0]
	this.__eventName__		=	arguments[1]
	this.__eventTime__			=	0
	this.__realObject__			=	nil
	this.__updater__ = (space, evaluator) ->
		var o = space.frpGet(this.__object__)
		var ev = o.extract(EventNameMap[space.frpGet(this.__eventName__)])
		if !!ev
			return undefined
		this.eventTime = evaluator.__currentTime__
		var kev = KSObject._newLUserEvent_from(ev, o)
		return kev
	this.__shouldEventTrigger__ =  (space, time, evaluator) ->
		var o = space.frpGet(this.__object__)
		if !!o
			return false
		if o !!== this.__realObject__
			this.__realObject__ = o
			return true
		var ev = o.extract(EventNameMap[space.frpGet(this.__eventName__)])
		if !!ev
			this.__lastTime__ = -1 // ??? now conflicting with -1 used in ksSet:put:
			return false
		evaluator.__currentTime__ > this.__eventTime__
	this.__lastTime__				=	0
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/19/2012 10:02'!
frpAnd = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__c1__ = arguments[0]
	this.__c2__ = arguments[1]
	this.__updater__ = (space, evaluator) ->
		(space.frpGet(this.__c1__) && space.frpGet(this.__c2__)).asBoolean()
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/19/2012 10:03'!
frpIf = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__c__ = arguments[0]
	this.__t__ = arguments[1]
	this.__f__ = arguments[2]
	this.__updater__ = (space, evaluator) ->
		if space.frpGet(this.__c__) then space.frpGet(this.__t__) else space.frpGet(this.__f__)
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/19/2012 10:04'!
frpOr = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__c1__ = arguments[0]
	this.__c2__ = arguments[1]
	this.__updater__ = (space, evaluator) ->
		(space.frpGet(this.__c1__) || space.frpGet(this.__c2__)).asBoolean()
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/11/2012 23:50'!
funcE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.sources		= arguments[1].slice(0).push(extraDep)
	this.__body__		= arguments[0]
	this.updater		= (space, evaluator) -> this.body
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/25/2013 10:55'!
getE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__last__ = arguments[0]
	this.__base__ = arguments[1]
	this.__keys__ = arguments.slice(2)
	this.__updater__ = (space, evaluator) ->
		var v = this.findForGet(space)
		if v.currentValue() === undefined then undefined else (if this.__last__ then v.__lastValue__ else v.currentValue())
	this.__shouldEventTrigger__ = (space, time, evaluator) ->
		// okay, getE here has the equality check... why is it good?
		var v = this.findForGet(space)
		v.isEventStream() && v.currentValue() !!== undefined && v.currentValue() !!== this.__lastValue__
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 5/8/2012 15:41'!
getOptE = (selector, code, extraDep, base, key) ->
	this.ksPerform2("setup", arguments)
	this.base = base
	this.key = key
	if base._isEventStreamRef()
		this.__sources__._push(new KSEventStreamRef({ref: base._ref(), attr: key}))
	this.updater = (space) ->
		if space.frpGet(this.base).hasOwnProperty(space.frpGet(this.key))
			return space.frpGet(this.base)[space.frpGet(this.key)].currentValue()
		else
			return undefined
	this.__shouldEventEvaluate__ = (space) ->
		space.frpGet(this.base)[space.frpGet(this.key)].currentValue() !!= this.lastValue
	this.__shouldEventTrigger__ = (space, time) -> false
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/19/2012 10:06'!
lift = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__realSources__ = arguments.slice(1)
	this.__func__ = arguments[0]
	this.__updater__ = (space, evaluator) ->
		var values = (space.frpGet(x) for x in this.__realSources__)
		if values.contains(undefined)
			return undefined
		space.frpGet(this.__func__).valueWithEnoughArguments(values.asArray())
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/19/2012 10:06'!
mapE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__func__ = arguments[1]
	this.__behavior__ = arguments[0]
	this.__updater__ = (space, evaluator) ->
		var arg = space.frpGet(this.__behavior__)
		if arg === undefined
			return undefined
		(space.frpGet(this.__func__))(arg)
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/23/2013 19:21'!
mergeE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__origSources__ = this.__sources__.copy()
	this.__updater__ = (space, evaluator) ->
		this.mergeEUpdater(space, evaluator)

	this.__shouldEventTrigger__ = (space, time, evaluator) ->
		this.mergeEShouldEventTrigger(space, time, evaluator)

	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/23/2013 18:33'!
oneE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__initalValue__		= arguments[0]
	this.__updater__ 		= (space, evaluator) ->
		if this.__currentValue__ === undefined
			space.frpGet(this.__initalValue__)
		else
			undefined
	this.__shouldEventTrigger__	= (space, time, evaluator) ->
		this.__currentValue__ === undefined
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/11/2013 10:46'!
setter = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__updater__ 				= (space, evaluator) -> undefined
	this.__shouldEventTrigger__	= (space, time, evaluator) -> false
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/23/2013 14:13'!
setup = (selector, code, extraDep, arguments) ->
	this.__type__			=	selector
	this.__code__			=	code
	this.__sources__		=	(if extraDep then [extraDep] else this.dependenciesFrom(arguments)).asArray()
//	this.__sources__		=	this.dependenciesFrom(arguments)
	this.__currentValue__	= 	undefined
	this.__lastValue__		=	undefined
	this.setLastTime(0)
	this.__shouldEventTrigger__ = (space, time, evaluator) ->
		this.basicShouldEventTrigger(space, evaluator)
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/30/2012 11:44'!
solver = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__func__ = arguments[0]
//	this.__inputVars__ = arguments[1]
	this.__sources__ = (KSEventStreamRef.new().ref(x.asSymbol()) for x in arguments[1]).asArray()
	this.__outputVars__ = arguments[2]
	this.__output__ = {}
	this.__updater__ = (space, evaluator) ->
		var result = this.__func__.value()
		for arg in this.__outputVars__
			this.__output__[arg] = this.__homeObject__[arg].currentValue()
		result
	this.__shouldEventTrigger__ = (space, time, evaluator) ->
		for arg in this.__sources__
			if this.__homeObject__[arg.ref()].currentValue() !!== this.__output__[arg.ref()]
				return true
		false
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/23/2013 18:33'!
switchColE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__argCollection__ = arguments[0]
	this.__streamName__ = arguments[1].asSymbol()
	this.__found__ = nil
	this.__updater__ = (space, evaluator) ->
		if this.__found__
			var f = this.__found__
			this.__found__ = nil
			space.frpGet(f)
		else 
			undefined
	this.__shouldEventTrigger__ = (space, time, evaluator) ->
		this.switchColEShouldEventTrigger(space, time, evaluator)
	return this

//collection:: Ref to Collection|Collection
// resolved collection: [KSObject | Ref]
//streamName Stringy | Ref
// as Ref is involved in the latter, collection of refs should resolve to collection of KsObjects! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 8/22/2012 16:49'!
timerE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__interval__						= arguments[0]
	this.__updater__ = (space, evaluator) -> this.ceilTime(evaluator.__currentTime__)
	this.__shouldEventTrigger__	= (space, time, evaluator) ->
		(this.lastTime() + space.frpGet(this.__interval__) <= time)
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 8/22/2012 16:49'!
timerEDuration = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__interval__				= arguments[0]
	this.__duration__				= arguments[1]
	this.__start__					= null
	this.__done__					= false
	this.__updater__ = (space, evaluator) ->
		var dur = space.frpGet(this.__duration__)
		if this.__start__ == null
			this.__start__ = this.ceilTime(evaluator.__currentTime__)
		var val =  this.ceilTime(evaluator.__currentTime__) - this.__start__
		if val >= dur
			this.__done__ = true
			val = dur
		val
	this.__shouldEventTrigger__	= (space, time, evaluator) ->
		this.__start__ == null || !!this.__done__ ||
			((this.lastTime() + space.frpGet(this.__interval__) <= time) &&
				(this.__start__ + space.frpGet(this.__duration__) >= time))
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 1/23/2013 19:16'!
update = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__expr__				=	arguments[1]
	this.__initialValue__			=	arguments[0]
	this.__currentValue__		=	arguments[0]
	this.__synching__			=	true
	this.__lastValue__			=	arguments[0]
	this.__synched__			=	true
	this.__isBehavior__ 		=	true
	this.__updater__			=	(space, evaluator) -> space.frpGet(this.__expr__)
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 7/19/2012 10:11'!
updateE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__expr__				=	arguments[1]
	this.__updater__			=	(space, evaluator) -> space.frpGet(this.__expr__)
	this.__initialValue__			=	arguments[0]
	this.__currentValue__		=	arguments[0]
	this.__synching__			=	true
	this.__lastValue__			=	arguments[0]
	this.__synched__			=	true
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 8/22/2012 20:42'!
virtualE = (selector, code, extraDep, arguments) ->
	this.setup(selector, code, extraDep, arguments)
	this.__func__				=	arguments[0]
	return this! !

!KSEventStream methodsFor: 'combinators' stamp: 'yo 5/8/2012 10:07'!
zeroE = (selector, code, extraDep) ->
	this.ksPerform2("setup", arguments)
	this.type						= "zeroE"
	this.updater					= (space) -> undefined
	this.__shouldEventEvaluate__	= (space) -> false
	this.__shouldEventTrigger__	= (space) -> false
	return this! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 7/11/2012 14:43'!
addSubExpression = (id, expression) ->
	if !!this.__subExpressions__
		this.__subExpressions__ = []
	this.__subExpressions__.push(id)
	this[id] = expression! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 8/1/2012 14:52'!
basicSet = (val) ->
	this.__currentValue__ = val
	this.__lastTime__ = -1
//	this.sync()! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 7/11/2012 22:47'!
basicShouldEventEvaluate = (space, evaluator) ->
	if !!this.__eventSourcesCache__
		this.__eventSourcesCache__ = []
	else
		this.__eventSourcesCache__.reset()
	var eventSources = this.__eventSourcesCache__
	for x in this.__sources__
		var v = space.lookup(x)
		if v === undefined
			return false
		if v.isEventStream()
			eventSources.push(v)

	if eventSources.length == 0 && this.lastTime == 0
		return true
	for src in eventSources
		if !!src.lastTime
			return true
		if (this.type !!= "updateE" && src.synching && src.synched && src.lastTime >= this.lastTime) || src.lastTime > this.lastTime
			return true
	return false! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/24/2013 20:25'!
basicShouldEventTrigger = (space, evaluator) ->
	var doAnyway = false
	if !!this.__eventSourcesCache__
		this.__eventSourcesCache__ = []
		doAnyway = true
	var eventSources = this.__eventSourcesCache__
	if evaluator.__invalidated__ || doAnyway
		eventSources.reset()
		for x in this.__sources__
			var v = space.lookup(x)
			if v.isEventStream()
				eventSources.push(v)

	for src in eventSources
		if src.currentValue() === undefined
			return false
		if this.isEarlierThan(src)
			return true
	return false! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/11/2013 10:56'!
beBehavior = () ->
	this.__isBehavior__ = true
	return this! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 8/22/2012 14:47'!
beVirtual = (aFunction) ->
	this.__getter__ = aFunction! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 7/18/2012 11:46'!
ceilTime = (time) ->
	return (time / this.__interval__)._asInteger() * this.__interval__! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/25/2013 10:59'!
clearEvents = (aNumber) ->
	for v in this
		if v.isEventStream()
			v.clearEvents(aNumber)
	this.setLastTime(aNumber)! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 7/5/2012 11:01'!
currentValue = () ->
	return this.__currentValue__! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/7/2013 14:51'!
dependenciesFrom = (col) ->
	return (elem for elem in col when elem.isEventStreamRef())! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 2/27/2013 17:40'!
evalSubExpressionAt = (time, space, evaluator) ->
	var val = this.__updater__._value_value(space, evaluator)
	if val !!== undefined
		this.__lastValue__ = this.__currentValue__ = val
		this.setLastTime(time)
		return true
	return false! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/23/2013 10:50'!
finalizeTopLevelCreationWith = (collection) ->
	var top = this[this.__subExpressions__.pop()]
	var additionalCollection = collection ? []
	top.__subExpressions__ = this.__subExpressions__.asArray()
	for id in top.__subExpressions__
		top[id] = this[id]
	for elem in additionalCollection
		var hasIt = false
		for e in top.__sources__
			if e.isEventStreamRef() && e.ref() === elem.ref()
				hasIt = true
		if !!hasIt
			top.__sources__ = top.__sources__.copyWith(elem)
	return top! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/23/2013 10:53'!
findForGet = (space) ->
	var v = space.frpGet(this.__base__)
	var ind = 0
	var keys = this.__keys__
	while ind < keys.size() && v !!== undefined
		v = v[space.frpGet(keys[ind])]
		ind++
	return v! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/23/2013 19:45'!
isEarlierThan = (other) ->
	var otherTime = other.lastTime()
	return otherTime == -1 ||
		(other.synching() && other.synched() &&
			otherTime >= this.lastCheckTime()) ||
				otherTime > this.lastCheckTime()! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 7/11/2012 11:00'!
isEventStream = () ->
	return true! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 3/1/2013 22:07'!
isLayoutChangedDependents = () ->
	if this.type == #'getE' && this.getKeys().last() == #'layoutChanged'
		return true
	for e in this.__sources__
		var s = this[e.ref()]
		if s.isEventStream() && s.type() == #'getE' && s.getKeys().last() == #'layoutChanged'
			return true
	return false! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 8/1/2012 09:14'!
ksAt: key 
	^ self at: key ifAbsent: [
		self at: #'__homeObject__' ifPresent: [:proto | ^ proto ksAt: key ].
		Undefined]! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/7/2013 14:58'!
ksAt: key put: val
	^ self at: key put: val.! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/24/2013 13:13'!
maybeEvalAt = (time, evaluator) ->
	var changed = false
	for id in this.__subExpressions__
		var elem = this[id]
		if elem.shouldTrigger(this, time, evaluator)
			changed = elem.evalSubExpressionAt(time, this, evaluator) || changed

	if this.shouldTrigger(this, time, evaluator)
		var val = this.__updater__._value_value(this, evaluator)
		if this.__synching__
			this.__synched__ = false
		if val !!== undefined
			this.__lastValue__ = this.__currentValue__
			this.setLastTime(if this.__type__ === #"timerE" then val else time)
			this.__currentValue__ = val
			changed = true
		if time > this.__lastCheckTime__
			this.__lastCheckTime__ = time
	else
		if this.__synching__
			this.__synched__ = false
	return changed! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/24/2013 20:28'!
mergeEShouldEventTrigger = (space, time, evaluator) ->
	var doAnyway = false
	if !!this.__eventSourcesCache__
		this.__eventSourcesCache__ = []
		doAnyway = true
	var eventSources = this.__eventSourcesCache__

	if evaluator.__invalidated__ || doAnyway
		eventSources.reset()
		for x in this.__origSources__
			var v = space.lookup(x)
			if v.isEventStream()
				eventSources.push(v)

	for src in eventSources
		if  (src.currentValue() !!== undefined) && this.isEarlierThan(src)
			return true
	return false! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/23/2013 19:20'!
mergeEUpdater = (space, evaluator) ->
	for id in this.__origSources__
		var s =  space.lookup(id)
		if  (s.currentValue() !!== undefined) && s.isEventStream() && this.isEarlierThan(s)
			// timer may not be merged properly
			return space.frpGet(s)
	return undefined! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'ael 3/5/2013 16:12'!
set = (val) ->
	this.__currentValue__ = val
	this.setLastTime(this.ksCurrentTime())
	return val! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/18/2013 11:25'!
setLastTime = (aNumber) ->
	this.__lastTime__ = aNumber
	this.__lastCheckTime__ = aNumber! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 8/22/2012 15:35'!
setSetter = (aFunction) ->
	this! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 7/11/2012 22:46'!
shouldEvaluate = (space, evaluator) ->
	this.__shouldEventEvaluate__._value_value(space, evaluator)! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/7/2013 15:00'!
shouldTrigger = (space, time, evaluator) ->
	return this.__shouldEventTrigger__._value_value_value(space, time, evaluator)! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'ael 3/5/2013 16:12'!
startsWith = (initialValue) ->
	this.__currentValue__ = initialValue
	this.__isBehavior__ = true
	this.setLastTime(-1)
	this.sync()
	return this! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 2/4/2013 14:10'!
switchColEShouldEventTrigger = (space, time, evaluator) ->
	var col = space.lookup(this.__argCollection__)
	var attr = space.lookup(this.__streamName__)
	for arg in col
		var s = space.lookup(arg)[attr]
		if s.isEventStream() && this.isEarlierThan(s)
			this.__found__ = s
			return true
	this.__found__ = null
	return false! !

!KSEventStream methodsFor: 'evaluatioin' stamp: 'yo 1/22/2013 20:35'!
sync = () ->
	this.__synched__ = false
	var v = this.__currentValue__
	if v !!== undefined // && v !!= this.__lastValue__
		this.__lastValue__ = v
		this.__synched__ = true! !

!KSEventStream methodsFor: 'squeak compatibility' stamp: 'yo 1/23/2013 14:18'!
asExplorerString
	"Answer a useful representation of the receiver for display in an object explorer."
	^self currentValue printString, '    ', self code.! !

!KSEventStream class methodsFor: '*ksobjects-pushpull' stamp: 'yo 3/2/2013 00:07'!
ppCreateInstanceFromSexp: sexp ref: ref from: from to: to
	| inst val this cv |
	val := Undefined.
	cv := sexp keyValueNamed: '__currentValue__'.
	cv ifNotNil: [
		val := to readSlot: cv into: nil from: from to: to].
	this := to fromPPSexp: (from at: (sexp attributeAt: #'__homeObject__') asSymbol) from: from to: to.
	(sexp attributeAt: #'__type__') = 'setter' ifTrue: [
		inst := self of: val.
		inst at: #'__code__' put: (sexp attributeAt: #'__code__').
		inst setLastTime: -1.
		to at: ref put: inst]
	ifFalse: [
		inst := this evalSqueakString: (to codeForDefinition: '$$(', (sexp attributeAt: #'__code__'), ')').
		inst at: #'__code__' put: (sexp attributeAt: #'__code__').
		inst setLastTime: 0.
		to at: ref put: inst].
	(sexp attributeAt: #'__isBehavior__' ifAbsent: []) asBoolean ifTrue: [
		inst at: #'__isBehavior__' put: true.
		inst at: #'__currentValue__' put: val].
	inst sync.
	inst dormant: (sexp attributeAt: #'__dormant__' ifAbsent: ['']) = 'true'.
	^ inst.! !

!KSEventStream class methodsFor: 'instance creation' stamp: 'yo 2/27/2013 22:08'!
of: anObject
	| ev |
	ev := self new setter: #setter with: anObject ksString with: nil with: {anObject}.
	anObject ~~ KSObject undefined ifTrue: [
		ev at: #'__currentValue__' put: anObject.
		ev setLastTime: -1].
	ev at: #'_subExpressions__' put: #().
	ev sync.
	^ ev! !
