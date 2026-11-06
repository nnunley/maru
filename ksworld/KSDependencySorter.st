KSObject subclass: #KSDependencySorter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects'!

!KSDependencySorter methodsFor: 'all' stamp: 'yo 7/3/2012 10:32'!
visit = (elem, col) ->
	if col._contains(elem)
		if !!elem.visited
			this.result._push(elem)
			return
	if !!elem.visited
		elem.visited = true
		col._push(elem)
		for sourceRef in elem.__sources__
			var srcElem = this.mapper.lookup(sourceRef)
			if srcElem._isEventStream()
				this.visit(srcElem, col)
		col._pop()
		this.result._push(elem)! !
