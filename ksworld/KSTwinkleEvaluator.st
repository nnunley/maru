KSObject subclass: #KSTwinkleEvaluator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSTwinkleEvaluator methodsFor: 'all' stamp: 'yo 9/6/2013 10:21'!
addStreamsFrom = (object) ->
	// Add all streams in object.  To support the priority sorting idea, the streams in "direct", rawEvents, layoutDep are put in different bins.
	var endNodes = this.endNodes
	var direct = object.__direct__ ? {}
	var rawEvents = object.__rawEvents__ ? {}
	var layoutDep = object.__layoutDep__ ? {}
	for k, v of object
		if v.isEventStream() && !!this.sources[v]
			if endNodes[v] !!== this.deletedNode
				endNodes[v] = v
			v.homeObject(object)
			if rawEvents.includes(v)
				this.rawEvents.push(v)
				v.visited(true)
			else
				if layoutDep.includes(v)
					this.layoutDep.push(v)
					v.visited(true)
				else
					var priority = direct[v] ? 0
					if priority > 0
						this.direct[priority-1].push(v)
						v.visited(true)
					else
						var sources = this.sources[v] = []
						v.visited(false)
						for srcStr in v.getSources()
							var srcElem = srcStr.findForGet(v)
							if srcElem.isEventStream()
								sources.push(srcElem)
								endNodes[srcElem] = this.deletedNode
						for srcRef in v.sources()
							var srcElem = v.lookupForSort(srcRef)
							var externalSource = !!(srcRef.isSubExpression())
							if srcElem.isEventStream() && externalSource
								sources.push(srcElem)
								endNodes[srcElem] = this.deletedNode! !

!KSTwinkleEvaluator methodsFor: 'all' stamp: 'yo 9/10/2013 19:04'!
evaluateAt: time
	"Assuming the sorted streams are in the result field, evaluate them in order.   Raw events has -1 as their timestamps so bring them to the current time first.  After evaluation, the lastValue and currentValue are synchronized."
	| changed s top twinkler |
	changed := false.
	self ksAt: #'__currentTime__' put: time.
	self ksCurrentTime: time.
	s := self at: #result.
	self ksAt: #'__invalidated__' put: (self ksAt: #'__wasInvalidated__').
	self ksAt: #'__wasInvalidated__' put: false.
	top := self ksAt: #'__topObject__'.
	(top asBoolean and: [(top ksAt: #worldState) asBoolean]) ifTrue: [
		twinkler := (top ksAt: #worldState) twinkler].

	twinkler asBoolean ifTrue: [twinkler clearOverlay].

	s do: [:elem |
		elem lastTime < 0 ifTrue: [
			elem setLastTime: time]].
	[
		s do: [:elem |
			changed := (elem maybeEvalAt: time with: self) or: [changed]].
	] on: KSTwinkleRequest do: [:ex |
		twinkler asBoolean ifTrue: [
			(top ksAt: #worldState) twinkler update: ex src to: ex dst].
		ex resume
	].
	s do: [:elem |
		elem sync].
	twinkler asBoolean ifTrue: [
		(top ksAt: #worldState) twinkler updateHandStreams.
		(top ksAt: #worldState) twinkler changed].
	^ changed.! !

!KSTwinkleEvaluator methodsFor: 'all' stamp: 'yo 9/6/2013 10:21'!
initialize = () ->
	super.initialize()
	this.deletedNode = null
	this.sources = {}
	this.endNodes = {}
	this.direct = [[], [], []]
	this.rawEvents = []
	this.layoutDep = []
	this.__wasInvalidated__ = true
	this.__invalidated__ = true
	return this! !

!KSTwinkleEvaluator methodsFor: 'all' stamp: 'yo 9/6/2013 10:21'!
justEvaluate = (aCollection, time) ->
	//Just evaluate the streams in aCollection.
	for elem in aCollection
		elem.maybeEvalAt(time, this)
	for elem in aCollection
		elem.sync()! !

!KSTwinkleEvaluator methodsFor: 'all' stamp: 'yo 9/10/2013 15:44'!
sort = () ->
	// Sort the streams.  RawEvents have the highest priorites, the direct dependencies of them are the next, and rest come afterwards.
	var result = this.result = new Array()
	result.addAll(this.rawEvents)
	for d in this.direct
		result.addAll(d)
	for e in this.endNodes
		if e !!== this.deletedNode
			this.visit(e, new Array())
	if this.__topObject__.worldState
		this.__topObject__.worldState.twinkler().createMap(this.__topObject__)
	return result! !

!KSTwinkleEvaluator methodsFor: 'all' stamp: 'yo 9/6/2013 10:21'!
sortAndEvaluateAt = (time) ->
	// Sort and evaluate streams. Set the sorter in topObject for caching.
	this.sort()
	this.__topObject__.__sorter__ = this
	this.__wasInvalidated__ = true
	this.evaluateAt(time)! !

!KSTwinkleEvaluator methodsFor: 'all' stamp: 'yo 9/6/2013 10:22'!
visit = (elem, col) ->
	// Starting from the "endNodes", recursively visit their sources.  col is used to detect circular dependency.
	if col.contains(elem)
		if !!elem.visited()
			this.result.push(elem)
			return
	if !!elem.visited()
		elem.visited(true)
		col.push(elem)
		for srcElem in this.sources[elem]
			this.visit(srcElem, col)
		col.pop()
		this.result.push(elem)! !
