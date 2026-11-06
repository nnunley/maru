KSUserEventHandler subclass: #KSCassowaryHandler
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'LCassowary-Demo'!

!KSCassowaryHandler methodsFor: 'all' stamp: 'yo 7/27/2012 14:42'!
setupBoxConstraints = () ->
	var whole= this.whole
	var boxVars = this.boxVars
	var solver = this.solver
	var box1 = whole.contents().first()
	var box2 = whole.contents().second()
	var mid = whole.contents().third()
	var line = whole.contents()._at(4)

	solver.addPointStays([
		P(boxVars[box1].x, boxVars[box1].y),
		P(boxVars[box2].x, boxVars[box2].y)])

	solver.addConstraint((boxVars[box1].x + boxVars[box2].x).cnEqual(boxVars[mid].x * 2.0))
	solver.addConstraint((boxVars[box1].y + boxVars[box2].y).cnEqual(boxVars[mid].y * 2.0))

	solver.addConstraint((boxVars[line].startX).cnEqual(boxVars[box1].x))
	solver.addConstraint((boxVars[line].startY).cnEqual(boxVars[box1].y))
	solver.addConstraint((boxVars[line].endX).cnEqual(boxVars[box2].x))
	solver.addConstraint((boxVars[line].endY).cnEqual(boxVars[box2].y))! !

!KSCassowaryHandler methodsFor: 'all' stamp: 'yo 10/5/2012 11:43'!
setupBoxVars = () ->
	this.boxVars = {}
	var boxVars = this.boxVars
	var whole = this.whole
	for i in [1...4]
		boxVars[whole.contents()._at(i)] = {}

	for i in [1...3]
		var box = whole.contents()._at(i)
		boxVars[box].x = ClVariable._newWith_name(50, box.name.currentValue().concat("-x"))
		boxVars[box].y = ClVariable._newWith_name(50, box.name.currentValue().concat("-y"))
		boxVars[box].center = P(boxVars[box].x, boxVars[box].y)

	box = whole.contents()._at(4)
	boxVars[box].startX = ClVariable._newWith_name(50, box.name.currentValue().concat("-startX"))
	boxVars[box].startY = ClVariable._newWith_name(50, box.name.currentValue().concat("-startY"))
	boxVars[box].start = P(boxVars[box].startX, boxVars[box].startY)

	boxVars[box].endX = ClVariable._newWith_name(50, box.name.currentValue().concat("-endX"))
	boxVars[box].endY = ClVariable._newWith_name(50, box.name.currentValue().concat("-endY"))
	boxVars[box].end = P(boxVars[box].endX, boxVars[box].endY)! !

!KSCassowaryHandler methodsFor: 'all' stamp: 'yo 3/1/2013 21:15'!
setupLayoutChangeUpdater = () ->
	this.lookMover = $$(switchColE(@whole.contents, "pointerMotion"))
	this.lookLayoutChange = $$(@lookMover.mapE((ev) ->
		var boxVars = this.boxVars
		var solver = this.solver
		var whole = this.whole
		var movingBox = ev.handler
		if !!this.whole.contents().includes(movingBox)
			return
		var varX = boxVars[movingBox].x
		var varY = boxVars[movingBox].y
		solver._addEditVar_strength(varX, ClStrength.medium())
		solver._addEditVar_strength(varY, ClStrength.medium())
		solver._beginEdit()
		solver._suggestValue_newValue(varX, movingBox.center().x())
		solver._suggestValue_newValue(varY, movingBox.center().y())
		solver.resolve()
		for i in [1...3]
			var box = whole.contents()._at(i)
			if box !!== movingBox
				this._setLocation_of_to(#"center", box, boxVars[box].center)
		box = whole._contents()._at(4)
		if box !!== movingBox
			this._setLine_from_to(box, boxVars[box].start, boxVars[box].end)
			solver.endEdit()))! !

!KSCassowaryHandler methodsFor: 'all' stamp: 'yo 7/27/2012 13:19'!
setupVariables = () ->
	this.solver = ClSimplexSolver.new()! !

!KSCassowaryHandler methodsFor: 'data manipulation' stamp: 'yo 9/27/2012 22:50'!
setLine: aBox from: fromPoint0 to: toPoint0
	| aShape fromPoint toPoint |
	fromPoint := fromPoint0 x value@fromPoint0 y value.
	toPoint := toPoint0 x value@toPoint0 y value.
	aShape := KSShape new elements: {(GeziraStrokedPath line: 0@0 to: toPoint - fromPoint) fill: aBox borderFill; stroke: (GeziraStroke width: 1)}.
	aShape computeBounds.
	(aShape extent = aBox extent and: [aBox topLeft =? (fromPoint - aShape offset)]) 
		ifTrue: [^ self].
	aBox shape: aShape.
	aBox topLeft: fromPoint - aShape offset.! !

!KSCassowaryHandler methodsFor: 'data manipulation' stamp: 'yo 9/27/2012 22:48'!
setLocation: locationSymbol of: aBox to: aValue
	"locationSymbol: #top, #bottom, #left, #right, or even #center (or whatever a Box understands."
	| value |
	aValue isPoint
		ifTrue: [value := aValue x value@aValue y value]
		ifFalse: [value := aValue value].
	aBox perform: (locationSymbol copyWith: $:) asSymbol with: value! !

!KSCassowaryHandler class methodsFor: 'as yet unclassified' stamp: 'yo 3/1/2013 20:23'!
example1
	"self example1 explore"
		| lWorld playfield box |
	lWorld := KSMorph new openInWorld.
	lWorld window add: (playfield := KSBox extent: 200@200 fill: Color white).
	1 to: 3 do: [:i |
		box := KSBox extent: 10@10 fill: Color random.
		box name: 'box' , i asString.
		playfield add: box.
		box center: 100@100.
		box attachGenericMoveHandler].
	box := KSBox extent: 10@10 fill: Color random.
		box name: 'line' , 1.
		playfield add: box.
		box center: 100@100.
	KSCassowaryHandler new installTo: playfield.
	playfield name: 'playfield'.
	^ (playfield at: #handler)
		setupVariables;
		setupBoxVars;
		setupBoxConstraints;
		setupLayoutChangeUpdater;
		yourself! !
