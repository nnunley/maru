KSObject subclass: #KSDependencyEvaluator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects'!

!KSDependencyEvaluator commentStamp: 'yo 3/14/2013 10:13' prior: 0!
A KSDependencyEvaluator provides the topological sort feature for dependency of streams.  Also provides entry points to evaluate the streams at given logical time.!

!KSDependencyEvaluator methodsFor: 'all' stamp: 'yo 3/28/2013 16:59'!
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

!KSDependencyEvaluator methodsFor: 'all' stamp: 'ael 3/26/2013 11:22'!
evaluateAt = (time) ->
	// Assuming the sorted streams are in the result field, evaluate them in order.   Raw events has -1 as their timestamps so bring them to the current time first.  After evaluation, the lastValue and currentValue are synchronized.
	var changed = false
	this.__currentTime__ = time
	this.ksCurrentTime(time)
	var s = this.result
	this.__invalidated__ = this.__wasInvalidated__
	this.__wasInvalidated__ = false
	for elem in s
		if elem.lastTime() < 0
			elem.setLastTime(time)
	for elem in s
		changed = elem.maybeEvalAt(time, this) || changed
	for elem in s
		elem.sync()
	return changed! !

!KSDependencyEvaluator methodsFor: 'all' stamp: 'yo 1/24/2013 20:39'!
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

!KSDependencyEvaluator methodsFor: 'all' stamp: 'yo 3/14/2013 10:02'!
justEvaluate = (aCollection, time) ->
	//Just evaluate the streams in aCollection.
	for elem in aCollection
		elem.maybeEvalAt(time, this)
	for elem in aCollection
		elem.sync()! !

!KSDependencyEvaluator methodsFor: 'all' stamp: 'yo 3/14/2013 10:03'!
sort = () ->
	// Sort the streams.  RawEvents have the highest priorites, the direct dependencies of them are the next, and rest come afterwards.
	var result = this.result = new Array()
	result.addAll(this.rawEvents)
	for d in this.direct
		result.addAll(d)
	for e in this.endNodes
		if e !!== this.deletedNode
			this.visit(e, new Array())
	return result! !

!KSDependencyEvaluator methodsFor: 'all' stamp: 'yo 3/14/2013 10:04'!
sortAndEvaluateAt = (time) ->
	// Sort and evaluate streams. Set the sorter in topObject for caching.
	this.sort()
	this.__topObject__.__sorter__ = this
	this.__wasInvalidated__ = true
	this.evaluateAt(time)! !

!KSDependencyEvaluator methodsFor: 'all' stamp: 'yo 3/14/2013 10:12'!
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
