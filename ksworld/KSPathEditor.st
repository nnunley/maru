KSUserEventHandler subclass: #KSPathEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/28/2013 00:11'!
addBezier = (ev) ->
	var newPoint = this.globalPointToEditPoint(ev.position)
	var pathArrays = this.pathBeingEdited().points()
	var firstPath = pathArrays.first()
	// for a straight line, GeziraPath class>>polygon: convention puts the control point at the end
	firstPath = firstPath.concat([firstPath.last(), newPoint, newPoint])
	pathArrays = [firstPath].concat(pathArrays._copyFrom_to(2, pathArrays.size()))
	// if the path was previously closed, make sure it's now open
	if @keepPathClosed
		this.keepPathClosed.set(false)
	this.update(pathArrays)
	this.setupPathHandles()! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/27/2013 21:12'!
closePath = () ->
	var oldPath = this.pathBeingEdited()
	if !!oldPath.isClosed()
		var newPath = oldPath.asClosedPath().stroke(oldPath.stroke())	// assumes single contour
		this.update(newPath.points())! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/23/2013 18:30'!
globalPointToEditPoint = (pt) ->
	var offset = this.target.globalPointFor(P(0, 0))
	var gridded = ((pt - offset).asFloatPoint() / @gridSize).rounded() * @gridSize
	return this.target.localPointFor(gridded + offset)! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 4/8/2013 14:37'!
installTo = (box) ->
	super.installTo(box)
	this.gridSize = 1
	this.keepPathClosed = this.eventStream()
	this.closeWatcher = $$(@keepPathClosed.mapE((close) ->
		var path = this.pathBeingEdited()
		if path
			if close
				this.closePath()
			this.setupPathHandles()))
	this.addWatcher = $$(@whole.doubleClick.mapE((ev) ->
		this.addBezier(ev)))! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/28/2013 00:19'!
makeHandle = (color, indices, segmentStarts) ->
	// each handle is given a record of the indices (pathIndex, pointIndex) of the point(s) it represents, and also of the starting point(s) of the segment(s) connected to it
	var p = KSBox.withShape(KSShape.new().elements([GeziraPath.oval(P(0, 0).corner(P(8, 8))).fill(color)]))
	p.indices = indices
	p.segmentStarts = segmentStarts
	p.attachGriddedMoveHandler(this.gridSize)
	p.theDownFunc = (downEvt) -> this.container().movingHandle.set(this)
	p.theUpFunc = (upEvt) -> this.container().movingHandle.set(nil)
	p.max = @whole.extent() * 2.0
	p.min = -(@whole.extent() * 2.0)
	p.bePathMover()
	return p! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/28/2013 10:00'!
openPathAt = (pathHandle) ->
	var path = this.pathBeingEdited()
	var closed = path.isClosed()

	if !!closed || pathHandle.isControlPoint
		return Beeper.primitiveBeep()
	if pathHandle.isEndPoint
		return

	var pathArrays = path.points()
	var pathIndex = 0			// fixed, for now
	var pathTriples = pathArrays[pathIndex]	// concatenated triples (start, end, control)
	var pathSize = pathTriples.size()

	var baseIndex = pathHandle.indices[0][1]	// first of the indices represents a start vertex, that we now want to be the start of the array
	var newTriples = []
	for i in [0 .. pathTriples.size()]
		newTriples.push(pathTriples[(baseIndex+i) % pathSize])
	pathTriples = newTriples

	if @keepPathClosed
		this.keepPathClosed.set(false)
	pathArrays = [pathTriples].concat(pathArrays._copyFrom_to(2, pathArrays.size()))
	this.update(pathArrays)
	this.setupPathHandles()! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/27/2013 17:20'!
pathBeingEdited = () ->
	var elems = this.target.shape().elements()
	return (if elems.size() >= 2 then elems.second() else undefined)! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 4/8/2013 14:25'!
setup = (targetBox, compositeBox) ->
	// prepare to be a path editor within a shape editor.
	// Later we'll be told the path to edit, by being pointed to a thumbnail box that contains it (see KSShapeEditor>>updateEditView).
	this.target = targetBox
	this.compositeBox = compositeBox

	this.checkMover = $$(switchColE(@whole.contents, "tell").mapE((obj) ->
		var ps = this.pathBeingEdited().points()
		for index in obj.indices
			ps[index.first()][index.second()] = this.target.localPointFor(@whole.globalPointFor(obj.center))
		this.update(ps)))

	this.whole.movingHandle = this.streamOf(nil)
	this.whole.highlightHandle = this.streamOf(nil)

	this.handleKeystrokeWatcher = $$(switchColE(@whole.contents, "keyStroke").mapE((ev) ->
		if ev.keyValue == 8		// delete
			this.tryToDeleteFrom(ev.handler)
		if ev.keyValue == 32		// space
			this.openPathAt(ev.handler)))

	this.movingHandleWatcher = $$(@whole.movingHandle.mapE((hOrNil) ->
		// if the mover of one end of an open path has been released, make sure keepPathClosed is consistent with new path state
		var moved = @movingHandleWatcher'	// can't depend on last state of movingHandle, because we might be in the time tick after it changed
		if !!hOrNil && moved && moved.isEndPoint && !!@keepPathClosed
			var path = this.pathBeingEdited()
			if path.isClosed() || path.snapClosedIfWithin(0.01)
				this.keepPathClosed.set(true)
				this.setupPathHandles()
		hOrNil))

	this.checkHighlight = $$(switchColE(@whole.contents, "highlight").mapE((obj) ->
		if !!@whole.movingHandle			// prevent changes as user drags over other movers
			var wantsHilite = obj.highlight
			for baseIndex in obj.requester.segmentStarts
				for offset in [0...2]
					var mover = (m in @whole.contents when m.indices.includes([baseIndex.first(), baseIndex.second()+offset]))
					if mover.highlighted !!== wantsHilite	// one mover can belong to many segments
						var shape = mover.shape()
						if wantsHilite
							shape.elements(shape.elements().concat([GeziraPath.oval(P(2, 2).corner(P(6, 6))).fill(Color.red().lighter())]))
						else
							shape.elements(shape.elements().allButLast())
						mover.shape(shape)
						mover.highlighted = wantsHilite
			this.whole.highlightHandle.set(if wantsHilite then obj.requester else nil)))! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/28/2013 11:17'!
setupPathHandles = () ->
	var element = @target.shape().elements().second()
	var paths = element.points()	// each path is an array with consecutive triples of points
	var setupAsClosed = element.isClosed() && @keepPathClosed
	this.gridSize = @compositeBox.bounds().extent().x() / @thumbBox.width()
	@whole.removeAll()
	var vertexHandles = []
	var controlHandles = []
	for i in [0..paths.size()]
		var firstTime = true
		var path = paths[i]
		for bStart in [0..path.size()] by 3				// triples of start, control, end
			// blue dot for most start points, but distinguish overall start of an open path
			var c = if firstTime && !!setupAsClosed then Color.yellow() else Color.blue()
			var p = this.makeHandle(c, [[i, bStart]], [[i, bStart]])
			// add indices of other points represented by this dot
			if firstTime
				if setupAsClosed
					p.indices.push([i, path.size() - 1])	// end of final segment
					p.segmentStarts.push([i, path.size() - 3])	// final segment
			else
				p.indices.push([i, bStart - 1])			// end of previous segment
				p.segmentStarts.push([i, bStart - 3])	// previous segment
			p.center(@whole.localPointFor(@target.globalPointFor(path[bStart])))
			vertexHandles.push(p)
			// green dot for the control point
			var p = this.makeHandle(Color.green(), [[i, bStart + 1]], [[i, bStart]])	// just one segment
			p.center(@whole.localPointFor(@target.globalPointFor(path[bStart + 1])))
			p.isControlPoint = true
			controlHandles.push(p)
			firstTime = false
	if !!setupAsClosed
		var pi = paths.size() - 1
		// blue dot for end of last segment
		var p = this.makeHandle(Color.blue(), [[pi, paths.last().size() - 1]], [[pi, paths.last().size() - 3]])
		p.center(@whole.localPointFor(@target.globalPointFor(paths.last().last())))
		vertexHandles.add(p)
		vertexHandles.first().isEndPoint = vertexHandles.last().isEndPoint = true

	for pp in vertexHandles.concat(controlHandles)	// control points are drawn underneath all line starts/ends
		@whole.add(pp)! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/27/2013 17:58'!
thumbBox = (box) ->
	this.thumbBox = box! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/28/2013 09:45'!
tryToDeleteFrom = (pathHandle) ->
	// deleting a start or end point (only found in an open path) deletes the first or last segment
	// deleting a segment join point within a path (open or closed) replaces the two joined segments with one, with its control point at the old end-point location
	// deleting a control point of a segment within a closed path opens it by removing that segment
	var path = this.pathBeingEdited()
	var pathArrays = path.points()
	var pathIndex = 0			// fixed, for now
	var pathTriples = pathArrays[pathIndex].asOrderedCollection()			// concatenated triples (start, end, control)
	var pathSize = pathTriples.size()					// used in many places
	var closed = path.isClosed()

	if pathSize < 6
		return Beeper.primitiveBeep()
		
	if pathHandle.isEndPoint
		if pathHandle.indices.includes([pathIndex, 0])	// first vertex
			pathTriples = pathTriples._copyFrom_to(4, pathSize)		// throw away first triple
		else
			pathTriples = pathTriples._copyFrom_to(1, pathSize - 3)	// throw away last triple
	else
		if pathHandle.isControlPoint					// remove one segment
			var baseIndex = pathHandle.indices[0][1]
			// we can remove any segment from a closed path, or first or last segment of an open one
			if !!(closed || baseIndex == 1 || baseIndex == pathSize - 2)
				return Beeper.primitiveBeep()			// removing would break the path into two
			var newTriples = []
			// new start is two beyond the control point, new end is two behind
			for wrapIndex in [baseIndex+2 .. baseIndex+pathSize-1]
				newTriples.push(pathTriples[wrapIndex % pathSize])
			pathTriples = newTriples
			closed = false								// not closed any more
		else
			// it's a non-end vertex: blend two segments into one
			baseIndex = pathHandle.indices[0][1]	// first of the indices represents a start point
			pathTriples[baseIndex+1] = pathTriples[baseIndex]		// move start location to nearest control point
			// if the previous vertex is at the end of the array, rotate right 3 places
			if baseIndex == 0
				for i in [1 ... 3]
					pathTriples.addFirst(pathTriples.removeLast())
				baseIndex = 3
			var allIndices = (0.to(pathSize - 1)).asOrderedCollection()
			for i in [baseIndex-2 ... baseIndex]			// remove the three points
				allIndices.remove(i)
			newTriples = []
			for i in allIndices
				newTriples.push(pathTriples[i])
			pathTriples = newTriples
			closed = closed && pathSize > 6			// if we're down to one segment, leave it open
	if closed !!= @keepPathClosed
		this.keepPathClosed.set(closed)
	pathArrays = [pathTriples].concat(pathArrays._copyFrom_to(2, pathArrays.size()))
	this.update(pathArrays)
	this.setupPathHandles()! !

!KSPathEditor methodsFor: 'all' stamp: 'ael 3/31/2013 21:36'!
update = (pathArrays) ->
	// Some path editing has happened.  Use the supplied pathArrays to re-form the element currently being edited.  Note that this element is shared as-is in the thumbBox and the composite.
	this.pathBeingEdited().points(pathArrays)
	@target.shape(@target.shape())
	@thumbBox.shape(@thumbBox.shape())
	@compositeBox.shape(@compositeBox.shape())! !
