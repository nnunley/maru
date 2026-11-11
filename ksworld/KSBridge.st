KSUserEventHandler subclass: #KSBridge
	instanceVariableNames: ''
	classVariableNames: 'Background FallSound PartsData ReleaseSound RiseSound TX2 Twitter'
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 13:54'!
addMassAt = (aPoint) ->
	var box = this.newMassAt(aPoint)
	box.noLayout = true
	this.masses.push(box)
	this.whole.add(box)
	return box! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 11:16'!
anchorShape
	| c |
	c := self classicColor.
	^ KSShape new elements: {
		(GeziraStrokedPath polyline: {27@18. 35@25. 35@59. 27@52}) fill: c; stroke: (GeziraStroke width: 2).
		(GeziraStrokedPath polyline: {27@25. 35@32}) fill: c; stroke: (GeziraStroke width: 2).
		(GeziraStrokedPath polyline: {27@32. 35@39}) fill: c; stroke: (GeziraStroke width: 2).
		(GeziraStrokedPath polyline: {27@39. 35@46}) fill: c; stroke: (GeziraStroke width: 2).
		(GeziraStrokedPath polyline: {27@46. 35@52}) fill: c; stroke: (GeziraStroke width: 2)}! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 16:15'!
beButtonToShowBridgeRules = (weight) ->
	delete weight.handler.downFunc2
	delete weight.handler.moveFunc2
	delete weight.handler.upFunc2
	delete weight.handler.doButtonDown
	delete weight.handler.doPointerMotion
	delete weight.handler.doButtonUp	
	delete weight.handler.sliderValue2D
	delete weight.handler.sliderValue

	weight.attachButtonHandler()
	weight.openRules = $$(@fire.mapE((x) ->
		weight.connections[0].naturalLength = 165
		this.putRuleContents(weight)
		var oldLeft = weight.left()
		weight.left(oldLeft - 100)
		weight.borderFill(Color.green())))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 14:37'!
bounce = (mass, bnds) ->
	var pos = mass.center()
	var v = mass.velocity
	if (pos.y() >= bnds._corner().y() && v.y() > 0)
		v = v * P(1, -0.7)
		if !!this.bounced
			this.bounced = this.streamOf(true)
	if (pos.x() < bnds._origin().x() && v.x() < 0) || (pos.x() >= bnds.corner().x() && v.x() > 0)
		v = v * P(-0.7, 1)
	mass.velocity = v! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 13:32'!
breakUp = () ->	
	for mass in this.masses
		mass.delete()
	this.masses.removeAll()

	// Make all beams independent
	for connector in this.connectors
		var c = connector
		this.masses.push(connector)
		c.updateLine = null
		c.detectDropped = null
		c.doButtonDown = null
		c.detectEndsDropped = null
		if c.start.isConnectorEnd || c.end.isConnectorEnd
			c.start.delete()
			c.end.delete()
		c.rot = this.random(-0.02, 0.02)
		c.velocity = P(0, this.random(-1.0, 0))

	// and then free labels from their target beams
	for label in this.labels
		label.target = null
		label.velocity = P(this.random(-1, 1), this.random(-5, 0))

	this.masses.addAll(this.labels)
	this.masses.addAll(this.buttons)
	this.masses.addAll(this.faces)
	this.toggleGravity(true)
	this.playFall = $$(@bounced.mapE((sound) ->
		this.playSound(FallSound)))	
	this.brokenUp = true

	this.whole.fill(Background.colorAt(P(10, 10)))
	this.whole.topContainer().hostingMorph().toggleOpenGL()

	this.setUpRaise()! !

!KSBridge methodsFor: 'fall' stamp: 'yo 7/5/2012 16:10'!
classicColor = () ->
	return Color.lightBlue()! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 11:11'!
clearBackground
	| display host |
	host := (self ksAt: #whole) topContainer hostingMorph.
	host isOpenGL ifFalse: [
		display := (self ksAt: #whole) topContainer hostingMorph instVarNamed: #surface.
		(self ksAt: #modernLook) == true
			ifFalse: [display fillWithColor: (TX2 colorAt: 10@10)]
			ifTrue: [(self ksAt: #raised) == true ifFalse: [
				display fillWithColor: (Background colorAt: 10@10)]]].! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 16:45'!
makeWeightTypeable = (weight) ->
	weight.borderFill(Color.gray())
	weight.fill(self.weightFill())
	weight.beLineEditor()
	weight.layout().inset(P(2, 16).corner(P(2, 2)))
	weight.layout().font  = KSFactory.default().defaultFont().face().withSize(22).fill(Color.white())
	weight.textContents("10t")
	weight.layOut()
	weight.attachShapeStretcher(P(16, 16))
	weight.stroke = $$(@keyStroke.mapE((x) ->
		weight.mass = weight.textContents().size() - 2))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 18:45'!
newCheckBox = (field, selector) ->
	var benignFill = Color.white().alpha(0.01)
	var c = KSBox._extent_fill(P(32, 32), benignFill)
	c.borderWidth(3)
	var check = KSFactory.default().graphicNamed("checkMark")
	check.scale(2.0)
	c.add(check)
	c.name('lkxCheck')
	c.beToggleButtonHandler(true)
	c.selectedFill = benignFill
	c.defaultFill = benignFill
	c.toggleCheck = $$(@selected.mapE((selected) ->
		check.visible.set(selected)
		field.ksPerform(selector, [selected])))
	return c! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 11:06'!
newLabelFor = (box) ->
	var label = KSBox._extent_fill(P(50, 10), Color.transparent())
//	label._layout()._font(LBox._defaultFont()._fill(Color.white()))
	label.pivotRatio(P(0.5, 0.5))
	this.class().new().installTo(label)
	label.rot = this.random(0.5, -0.5)
	label.target = box
	return label! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 18:13'!
newMassAt = (aPoint) ->
	var box = KSBox._extent_fill(P(12, 12), this.classicColor())
	box.attachDropAcceptor()
//	box.handler.beGenericMoveHandler()
	box.addConnection = (x) ->
		(box.connections ?= []).push(x)

	box.removeConnection = (x) ->
		var prev = box.connections.size()
		if box.connections
			box.connections._remove_ifAbsent(x, null)
		Transcript.show("prev: ").show(prev.asString()).show(" ").show(box.connections.size().asString()).cr()
	box.velocity = P(0.0, 0.0)
	box.center(aPoint)
	box.name("mass".concat(aPoint.asString()))
	return box! !

!KSBridge methodsFor: 'fall' stamp: 'yo 7/5/2012 16:14'!
notBreakUp = (selected) ->
	if !!selected
		this.triggerBreakUp()! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 10:45'!
putRuleContents = (weight) ->
	weight.borderFill(Color.gray())
	weight.fill(self.weightFill())
	weight.attachShapeStretcher(P(16, 16))
	var boldItalicFont = KSFont.defaultFont().withStyle(3).withSize(22).fill(Color.black())
	var boldFont = KSFont.defaultFont().withStyle(1).withSize(22).fill(Color.black())
	var normalFont = KSFont.defaultFont().withStyle(0).withSize(22).fill(Color.black())
	var subFont = KSFont.defaultFont().withStyle(2).withSize(16).fill(Color.black())

	var box = KSBox._extent_fill(P(340, 180), Color.white())
	box.topCenter(P(180, 14))
	weight.extent(P(360, 200))

	var c = this.newCheckBox(this, #"toggleGravity")
	c.name("gCheck")
	box.add(c)

	c = KSBox._extent_fill(P(0, 0), Color.white())
	c.beLineEditor()
	c.layout().font = normalFont
	c.name("gravity")
	c._addUnicodeText_withFonts("@1\\u2200 J | \\u2206v@2y@1(J) = -9.8 \\u2206t", [normalFont, subFont])
	box.add(c)

	var c = this.newCheckBox(this, #"toggleGravity")
	c.name("lkxCheck")
	box.add(c)

	c = KSBox._extent_fill(P(0, 0), Color.white())
	c.beLineEditor()
	c.layout().font = normalFont
	c.name("lkx")
	c.addTextContents("F")
	c.addTextContents(" = -k")
	c.addTextContents("x")
	c.first().beBold(true)
	c.last().beBold(true)
	box.add(c)

	var c = this.newCheckBox(this, #"notBreakUp")
	c.name("jointCheck")
	box.add(c)

	c = KSBox._extent_fill(P(0, 0), Color.white())
	c.beLineEditor()
	c.layout().font = normalFont
	c.name("joint")
	c.addTextContents([KSBox._withChar_inFont(0x2200, normalFont)], normalFont)
	c.add(KSBox.withShape(normalFont.glyphAt(" "[0])))
	c.addTextContents("J, B | B ", normalFont)
	c.addTextContents([KSBox._withChar_inFont(0x2208, normalFont)], normalFont)
	c.addTextContents(" J", normalFont)

	var s = KSBox._withChar_inFont("b"[0], subFont)
	s.shape(s.shape().copy())
	s.shape()._instVarNamed_put("hBearing", s.shape().hBearing() * P(1.2, 0.5))
	s.setPivotForGlyph()
	c.addTextContents([s], subFont)

	c.addTextContents(" ", normalFont)
	c.addTextContents([KSBox._withChar_inFont(0x2794, normalFont)], normalFont)
	c.addTextContents(" B", normalFont)

	var s = KSBox._withChar_inFont("p"[0], subFont)
	s.shape(s.shape().copy())
	s.shape()._instVarNamed_put("hBearing", s.shape().hBearing() * P(1.2, 0.5))
	s.setPivotForGlyph()
	c.addTextContents([s], subFont)
	c.addTextContents(" = J", normalFont)

	var s = KSBox._withChar_inFont("p"[0], subFont)
	s.shape(s.shape().copy())
	s.shape()._instVarNamed_put("hBearing", s.shape().offset() * P(1.2, 0.5))
	s.setPivotForGlyph()
	c.addTextContents([s], subFont)

	box.add(c)

	weight.add(box)
	this.ruleLayout(box)
	box.layOut()! !

!KSBridge methodsFor: 'fall' stamp: 'yo 7/5/2012 16:19'!
random = (xmin, xmax) ->
	if !!this.random
		this.random = Random._new()
	this.random._next() * (xmax-xmin) + xmin! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 14:40'!
repositionLabels = () ->
	for label in this.labels
		var target = label.handler.target
		if target
			label.texture(this._renderShortString_of(target.displacement.asString().truncateTo(4), label))
//			label.textContents(target.displacement.asString().truncateTo(4))
			label.leftCenter(target.center() + P(1, -6))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 10:47'!
ruleLayout: box
	| lay |
	lay := KSSimpleLayout new.
	box layout: lay.
	lay
		keep: #topLeft of: 'gCheck' to: 10@10;
		keep: #topLeft of: 'gravity' to: #topRight of: 'gCheck' offset: 20@0;
		keep: #topLeft of: 'lkxCheck' to: #bottomLeft of: 'gCheck' offset: 0@20;
		keep: #topLeft of: 'lkx' to: #topRight of: 'lkxCheck' offset: 20@0;
		keep: #topLeft of: 'jointCheck' to: #bottomLeft of: 'lkxCheck' offset: 0@20;
		keep: #topLeft of: 'joint' to: #topRight of: 'jointCheck' offset: 20@0! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 11:32'!
setUpAnchor = (pos, rot) ->
	var anchor = KSBox.withShape(this.anchorShape())
	anchor.center(pos)
	anchor.rotateBy(rot)
	this.anchors.push(anchor)
	this.whole.add(anchor)! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 15:48'!
setUpBalloonButton = () ->
	var balloonBox = this.balloonBox = KSFactory.default().graphicNamed("balloon")
	balloonBox.scale(0.2)
	balloonBox.attachButtonHandler()
	balloonBox.highlightEnabled = false
	balloonBox.raise = $$(@fire.mapE((x) ->
		this.startRaise()))
	balloonBox.topRight(this.whole.topRight() - P(40, -40))
	this.whole.addFirst(balloonBox)
	this.balloonDirection = P(-1, 0)
	this.balloonDestinations = [this.whole.topRight() - P(300, -60), this.whole.topRight() - P(40, -40)]
	this.balloonDestinationsCursor = 0
	this.ziggleBalloon = $$(@calmedTimer.mapE((x) ->
		this.lastDestinationSetTime ?= x
		if x - this.lastDestinationSetTime > 2000
			var pos = balloonBox.topRight()
			this.lastDestinationSetTime = x
			if pos.dist(this.balloonDestinations[this.balloonDestinationsCursor]) < 50
				this.balloonDestinationsCursor = (this.balloonDestinationsCursor + 1) % 2
			var diff = this.balloonDestinations[this.balloonDestinationsCursor] - pos
			this.balloonDirection = (diff / diff.r())._rotateBy_about(this.random(-Float.pi()/4, Float.pi()/4), P(0, 0))
		this.balloonBox.translateBy(this.balloonDirection * 4)))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 16:02'!
setUpButtons = () ->
	var specs = [
//		name,		position,    rot, velocity, action
		["gravity", P(930, 20), -0.02, P(0, -2.5),	(ev) ->
											this.toggleGravity(true)
											],
//		["flicker", null, -0.15, P(0, -1.0),	(ev) ->
//											this.toggleFlicker()],
		["modern",	null, -0.01, P(0, -1.5),		(ev) ->
													this.setupModernLook()],
//		["fall", 		null, 0.02, P(0, -2.0),		(ev) -> this.startFall()],
		["break",	null, 0.01, P(0, -2.0),		(ev) -> this.triggerBreakUp()],
		["raise",		"same", 0, 0, 		(ev) -> this.startRaise()]]

	this.buttons = []
	for spec in specs
		var button = KSFactory.default().newButton(spec[0])
		for b in button.contents()
			b.shape(b.shape().copy().copyFillElements())
		button.cornerRadius(4)
		button.pivotRatio(P(0.5, 0.5))
		button.fill(Color.gray(0.2))
		button.borderFill(this.classicColor())
		button.pressedFill = Color.white()
		for c in button.contents()
			c.fill(this.classicColor())
		this.whole.add(button)
		if spec[1]
			if spec[1] == "same"
				button.center(this.buttons.last().center())
			else
				button.topLeft(spec[1])
		else
			button.topLeft(this.buttons.last().bottomLeft() + P(0, 15))
		if spec[0] !!= "raise"
			this.buttons.push(button)
		button.handler.rot = spec[2]
		button.handler.velocity = spec[3]
		this[spec[0]] = button
		this["start".concat(spec[0])] = $$(@[spec[0]].fire.mapE(spec[4]))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 15:56'!
setUpLines = () ->
	var scale = 1.63
	var theCorner = this.class().points()[0]
	var theCenter = this.class().points()[10]
	var offset = P(((1024 - (theCenter.x() - theCorner.x()) * 2 * scale) / 2) - theCorner.x() * scale, 120)
	var points = this.points = (p * scale + offset for p in this.class().points())
	this.masses = []
	this.labels = []
	this.connectors = []
	this.weights = []
	this.anchors = []
	this.faces = []
	for p in points
		this.addMassAt(p) 
	for i in this.class().fixed()
		this.masses[i].fixed = true
	for pair in this.class().lines()
		var box = KSBox.new()
		box.name("connector".concat(pair[0].asString()).concat("-").concat(pair[1].asString()))
		box.borderWidth(3)
		box.naturalLength = points[pair[0]].dist(points[pair[1]])
		box.springConstant = box.naturalLength
		box.endFill = this.classicColor()
		box.borderFill(this.classicColor())
		if pair[0] == 9 && pair[1] == 10
			box.beConnectorHandler(null, null)
			box.needsTwoEndsConnected = true
			box.displacement = 0
			box.start.topLeft(P(300, 400))
			box.end.topLeft(P(370, 400))
			this.whole.addFirst(box.start)
			this.whole.addFirst(box.end)
		else
			if pair[0] == 20 && pair[1] == 19
				box.beConnectorHandler(null, null)
				box.needsTwoEndsConnected = true
				box.displacement = 0
				box.start.topLeft(P(640, 450))
				box.end.topLeft(P(710, 450))
				this.whole.addFirst(box.start)
				this.whole.addFirst(box.end)
			else
				box.beConnectorHandler(this.masses[pair[0]], this.masses[pair[1]])
		this.connectors.push(box)
//		box.isTimeBubble(true)
		this.whole.add(box)
		var label = this.newLabelFor(box)
		this.whole.addFirst(label)
		this.labels.push(label)
	this.setUpSimpleWeight(4, P(530, 420), true)
	this.setUpSimpleWeight(4, P(570, 450), false)
	this.setUpAnchor(points[0] + P(-12, -4), 0)
	this.setUpAnchor(points[5] + P(-12, 5), Float.pi() / -4)
	this.setUpAnchor(points[11] + P(12, -4), Float.pi())
	this.setUpAnchor(points[16] + P(8, 10), Float.pi() * -0.75)
	this.setUpButtons()
	this.startTimer()
	this.flickering = true
	this.recolorer = $$(@calmedTimer.mapE((x) ->
		for v in this.connectors
			var col = this.classicColor() * (if @flickering then this.random(0.5, 1.0) else 1.0)
			v.borderFill(col)
			v.forceUpdate = true
		for v in this.buttons
			var col = this.classicColor() * (if @flickering then this.random(0.5, 1.0) else 1)
			for c in v.contents()
				c.fill(col)
			col = this.classicColor() * (if @flickering then this.random(0.75, 1.0) else 1)
			v.borderFill(col)))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 16:37'!
setUpSimpleWeight = (w, pos, movable) ->
	var weight = this.weight = this.addMassAt(pos)
	weight.shape(this.weightShape())
	this.class().new().installTo(weight)
	weight.mass = w
	weight.attachDropAcceptor()
	if movable
		weight.attachGenericMoveHandler()
	this.weights.push(weight)

	var box = KSBox.new()
	box.borderWidth(3)
	box.naturalLength = 75
	box.springConstant = 50
	box.endFill = this.classicColor()
	box.fill = this.classicColor()
	box.beConnectorHandler(null, weight)
	box.start.topLeft(pos - P(0, 75))
	box.start.debug = true
	box.end.topLeft(pos)
	weight.center(pos)
	this.connectors.push(box)
	box.name("weight-connector")
	this.whole.add(box.start)
	this.whole.add(box)! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 14:25'!
setUpSolver = () ->
	if this.whole
		this.whole.fill(Color.transparent())
		this.stepper = $$(@timer.mapE((x) ->
			this.solve()))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 15:24'!
setupModernLook = () ->
	var buttonsPos = ([button, button.globalPointFor(button.extent()/2)] for button in this.buttons)
	var raisePos = this.raise.globalPointFor(this.raise.extent()/2)
	var scale = 1.0
	if !!this.modernLook
		this.modernLook = true
		this.clearBackground()
		this.whole.scaleBy(scale)
		for button in this.buttons
			button._delete()
//			button._scaleBy(1/scale)
//			for c in button._contents()
//				c._fill(Color._white())
//			button.borderFill(Color._white())
		this.buttons.removeAll()
		this.raise.delete()
		for anchor in this.anchors
			anchor._delete()
		for ind in [0 .. this.weights.size()]
			var weight = this.weights[ind]
			if ind !!= 1
				this.makeWeightTypeable(weight)
			else
				this.beButtonToShowBridgeRules(weight)
		for box in this.whole.contents()
			if box.pathFromTo
				box.ksAssign(#"pathFromTo", this.steel())
		for box in this.masses
			box.fill(this._steelFillFrom_to(P(0, 12), P(12, 5)))
		var f = KSBox.withTexture(KSFactory.default().yoshiki())
		f.scale(0.6)
		this.faces.push(f)
		f = KSBox.withTexture(KSFactory.default().bert())
		f.scale(0.6)
		this.faces.push(f)
		var firstFace = true
		for face in this.faces
			if firstFace
				var pos = P(40, 40)
				face.rot = 0.01
				firstFace = false
			this.whole.addLast(face)
			face.topLeft(pos)
			pos = pos + P(80, 0)
			face.rot ?= -0.02
			face.velocity = P(0, -1.5)

//		for box in this.labels
//			box._delete()
//		delete this.labels
//		for buttonPos in buttonsPos
//			buttonPos[0]._center(this.whole._localPointFor(buttonPos[1]))
//		this.raise.whole._center(this.whole._localPointFor(raisePos))

	this.setUpBalloonButton()
	this.recolorer = null! !

!KSBridge methodsFor: 'fall' stamp: 'yo 7/5/2012 16:29'!
showBridgeRules = (weight) ->
	weight.borderColor(Color._gray())
	weight.fill(self._weightFill())
	weight.handler.attachShapeStretcher(P(16, 16))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/4/2013 11:10'!
solve = () ->
	this.clearBackground()
	var bounceBounds = this.whole.localPointFor(P(0, 0)).corner(this.whole.localPointFor(this.whole.container().extent()))
	for i in [0..5]
		var newPoints = (null for x in this.masses)
		for pInd in [0 .. this.masses.size()]
			var mass = this.masses[pInd]
			var point = mass.center()
			var accel = P(0, 0)
			for box in mass.connections
				if !!(box.needsTwoEndsConnected && (box.start.isConnectorEnd || box.end.isConnectorEnd))
					var naturalLength = box.naturalLength
					var otherMass = if box.start == mass then box.end else box.start
					var otherPoint = this.whole.localPointFor(otherMass.globalPointFor(otherMass.extent()/2.0))
					var dist = point.dist(otherPoint)
					var dir = (otherPoint - point) / dist
					box.displacement = ((dist - naturalLength) * 100).asInteger()
					accel = accel + (dir * (dist - naturalLength) * (box.springConstant ? box.naturalLength) / 200.0)
			if !!mass.fixed
				if this.gravity then accel += (mass.mass ? 1 ) * P(0, 0.1)
				mass.velocity = (mass.velocity + accel) * 0.96
				this.bounce(mass, bounceBounds)
			newPoints[pInd] = point + mass.velocity
			if this.brokenUp
				mass.rotateBy(mass.rot ? 0.0)
		for ind in [0 .. this.masses.size()]
			this.masses[ind].center(newPoints[ind])
	if !!this.brokenUp
		this.repositionLabels()! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 11:45'!
split = (mass) ->
	while mass.connections.size() > 1
		var connector = mass.connections.pop()
		var other = if connector.start == mass then connector.end else connector.start
		other.handler.connections.remove(connector)
		var newMass1 = this.addMassAt(mass.center())
		var newMass2 = this.addMassAt(other.center())
		connector.eventHandler().setupConnector(newMass1, newMass2)
		//Transcript.klog(['masses:', (m.handler().connections._size() for m in this.masses)])! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 11:45'!
startFall = () ->
	for box in this.masses
		box.fixed = false! !

!KSBridge methodsFor: 'fall' stamp: 'yo 7/5/2012 16:31'!
startTimer = () ->
	this.timer = $$(timerE(20))
	this.calmedTimer = $$(timerE(100))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 11:45'!
steel = () ->
	(fromPoint, toPoint) ->
		var aShape = KSShape.new().elements([GeziraStrokedPath._line_to(P(0, 0), toPoint - fromPoint).stroke(GeziraStroke.round(6))].asArray())
		aShape.elements().first().fill(this._steelFillFrom_to(fromPoint, toPoint))
		aShape.computeBounds()! !

!KSBridge methodsFor: 'fall' stamp: 'yo 5/8/2012 12:27'!
steelFillFrom: fromPoint to: toPoint
	^ GeziraFill
		gradient: {
			0.0 ->  (Color r: 0.086 g: 0.109 b: 0.094).
			0.5 -> (Color r: 0.772 g: 0.847 b: 0.737).
			1.0 ->  (Color r: 0.086 g: 0.109 b: 0.094)}
		from: 0@0 to: toPoint - fromPoint! !

!KSBridge methodsFor: 'fall' stamp: 'yo 7/5/2012 16:32'!
toggleFlicker = () ->
	this.flickering = !!this.flickering! !

!KSBridge methodsFor: 'fall' stamp: 'yo 7/5/2012 16:40'!
toggleGravity = (selected) ->
	this.setUpSolver()
	this.gravity = selected! !

!KSBridge methodsFor: 'fall' stamp: 'yo 7/5/2012 16:32'!
triggerBreakUp = () ->	
	var delay = 0
	if ReleaseSound
		this.playSound(ReleaseSound)
		delay = 500
	this.breakDelay = $$(oneE(true).delayE(delay).mapE((x) ->
		this.breakUp()))! !

!KSBridge methodsFor: 'fall' stamp: 'yo 6/1/2012 10:01'!
weightFill
	^ GeziraFill
		gradient: {
			0.0 ->  (Color r: 0.086 g: 0.109 b: 0.094).
			0.25 -> (Color r: 0.772 g: 0.847 b: 0.737).
			1.0 ->  (Color r: 0.086 g: 0.109 b: 0.094)}
		from: 0@0 to: 15@10! !

!KSBridge methodsFor: 'fall' stamp: 'yo 9/3/2013 11:45'!
weightShape
	^ KSShape new elements: {
		(GeziraStrokedPath polygon: {0@32. 32@32. 24@8. 8@8}) fill: (self classicColor); stroke: (GeziraStroke width: 2).
		(GeziraFilledPath polygon: {0@32. 32@32. 24@8. 8@8}) fill: (Color gray: 0.2).
		(GeziraFilledPath polygon: {0@0. 0@32. 32@32. 32@0}) fill: Color transparent}! !

!KSBridge methodsFor: 'raise' stamp: 'yo 9/4/2013 14:54'!
activateLWorld
	| newInd origInd |
	([LesserphicMorph current] on: Error do: [nil]) ifNotNilDo: [:ll |
			ll active: true.
			ll comeToFront.
			origInd := (ll window first \ #DocEditor) docStack ouCardIndex.
			newInd := (ll window first \ #DocEditor) docStack wrapCardNumber: origInd + 1.
			newInd > origInd ifTrue: [
				 (ll window first \ #DocEditor) docStack nextPage].
			(ll window first \ #DocEditor) toggleFullScreen: false.
			(ll window first \ #DocEditor) scriptingArea isRunningScripts: true].
	(self at: #whole) hostingMorph delete
	ActiveWorld doOneCycleNow.! !

!KSBridge methodsFor: 'raise' stamp: 'yo 5/29/2012 16:45'!
deactivateLWorld
	([LesserphicMorph current] on: Error do: [nil]) ifNotNilDo: [:ll | ll active: false].! !

!KSBridge methodsFor: 'raise' stamp: 'yo 5/9/2012 10:28'!
drawBox: box at: aPoint radian: rot on: aCanvas
	| mat transCenter |
	mat := MatrixTransform2x3 withRadRotation: rot.
	transCenter := mat localPointToGlobal: box extent / 2.0.
	aCanvas transformBy: (mat offset: aPoint - transCenter) during: [:c |
		c limage: box texture rule: 34]! !

!KSBridge methodsFor: 'raise' stamp: 'yo 7/5/2012 16:33'!
playSound = (sound) ->
	sound.play()! !

!KSBridge methodsFor: 'raise' stamp: 'yo 9/4/2013 15:24'!
raise = () ->
	this.duration = 2000
	this.step = $$(@elapsed.mapE(@render))
	this.elapsed = $$(timerEDuration(20, 2000))

	this.playRise = $$(oneE(RiseSound).delayE(320).mapE((sound) ->
		this.playSound(sound)))	

	this.takeScreenShot = () ->
		if this.whole.topContainer().hostingMorph().isOpenGL()
			this.render(this.duration)
			this.whole.topContainer().hostingMorph().toggleOpenGL()

	this.render = (t) ->
		for rInd in [0 .. this.raisers.size()]
			var b = this.raisers[rInd]
			var val = this.func(t, @duration, b.startPosition, b.endPosition, b.startRotation, 0.0)
			b.rotation(val.rotation)
			b.center(val.position)
		if t == this.duration
			this.startScreenShot()
		return t

	for ind in [0 .. this.raisers.size()]
		var box = this.raisers[ind]
		var orig = this.masses[ind]
		box.visible.set(true)
		if orig
			box.startRotation = (orig.rotation() - Float.pi()) * 1.5
			box.startPosition = orig.globalPointFor(orig._extent()/2)
		else
			box.startRotation = (628.atRandom() / 100.0 - Float.pi()) * 1.5
			box.startPosition = P(this.random(0, this.whole.width()), this.whole.height() - this.random(0, 20))
		box.rotation(box.startRotation)
		box.center(box.startPosition)

	this.hiddenBox = KSBox._extent_fill(P(105, 105), Color.white().alpha(0.001))
	this.hiddenBox.attachButtonHandler()
	this.hiddenBox.highlightEnabled = false
	this.hiddenBox.activateLWorld = $$(@fire.mapE((x) ->
		this.activateLWorld()))
	this.whole.add(this.hiddenBox)
	this.hiddenBox.topLeft(this.whole.localPointFor(P(0, 0)))

	this.hiddenBox2 = KSBox._extent_fill(P(71, 16), Color.white().alpha(0.001))
	this.hiddenBox2.attachButtonHandler()
	this.hiddenBox2.highlightEnabled = false
	this.hiddenBox2.activateLWorld = $$(@fire.mapE((x) ->
		this.activateLWorld()))
	this.whole.add(this.hiddenBox2)
	this.hiddenBox2.topLeft(P(792, 80))! !

!KSBridge methodsFor: 'raise' stamp: 'yo 9/4/2013 15:46'!
readBoxesFrom = (arguments) ->
	this.raisers = []
	for e in arguments
		var box = KSBox._extent_fill(e.second().extent(), e.second())
		box.endPosition = e.first()
		box.noLayout = true
		box.visible.set(false)
		this.whole.addFirst(box)
		box.glRetainCache = true
		box.glCacheTexture(#'glTexture', box.shape(), #'drawOn:', #'drawingBounds', Matrix4x4.identity(), 1.5)
		this.raisers.push(box)! !

!KSBridge methodsFor: 'raise' stamp: 'yo 9/4/2013 15:18'!
setUpRaise  = () ->
	this.func = (et, tt, sp, ep, sr, er) ->
		var ay = (sp.y() - ep.y()) * 2.0 / (tt * tt)
		var px = ep.x() + (sp.x() - ep.x()) * (tt - et) / tt
		{position: P(px, ep.y() + (0.5 * ay * (tt - et) * (tt - et))), rotation: sr + (er - sr) * et / tt}! !

!KSBridge methodsFor: 'raise' stamp: 'yo 9/4/2013 15:27'!
startRaise = () ->
	if this.brokenUp
		for n in ["stopTimer", "startTime", "stepper", "elapsed"]
			this[n] = undefined
		this.raise.delete()
		if this.balloonBox
			this.balloonBox.delete()
		for m in this.masses
			m.delete()
		this.raise()! !

!KSBridge methodsFor: 'raise' stamp: 'yo 9/4/2013 15:06'!
startScreenShot = () ->
	this.scr = $$(oneE(true).doE(() -> this.takeScreenShot()))! !

!KSBridge methodsFor: 'string rendering' stamp: 'yo 9/3/2013 14:33'!
renderShortString: aString of: aBox
	| bb buf font pos |
	font := self at: #shortStringFont ifAbsentPut: [(TextStyle named: 'BitstreamVeraSansMono') fontAt: 2].
	buf := aBox at: #shortStringBuffer ifAbsentPut: [Form extent: ((font widthOf: $0)*4)@font height depth: 32].
	buf fillColor: Color transparent.
	bb := GrafPort toForm: buf.
	bb combinationRule: Form paint.
	bb installFont: font foregroundColor: (self classicColor) backgroundColor: Color transparent.
	pos := font displayString: aString on: bb from: 1 to: aString size at: 0@0 kern: 0 baselineY: font ascent.
	^ buf! !

!KSBridge class methodsFor: 'all' stamp: 'yo 6/4/2012 14:54'!
blueBackground
	^ (Form extent: 1024@768 depth: 32)
		fill: (0@0 corner: 1024@768) fillColor: self msSkyColor! !

!KSBridge class methodsFor: 'all' stamp: 'yo 9/3/2013 14:00'!
example1
"
KSBridge example1
"
	| ll |
	Smalltalk vmParameterAt: 6 put: 12000. "survivor count tenuring threshold (read-write)"
	ll := KSMorph new extent: 1024@768.
	ll window fill: Color transparent.
	ll window add: (KSBox extent: 1024@768 fill: (TX2 colorAt: 10@10)).
	KSBridge new installTo: ll window first.
	ll window first name: 'bridge'.
	ll window first handler deactivateLWorld.
	ll window first attachDropAcceptor.
	ll window first handler readBoxesFrom: PartsData.
	ll window first handler setUpLines.
"	ll window first beOpaqueToDamageRect.."
	ll openInWorld.
	^ ll window first handler.! !

!KSBridge class methodsFor: 'all' stamp: 'bf 5/2/2012 18:10'!
fixed
	^#(0 5 11 16)! !

!KSBridge class methodsFor: 'all' stamp: 'ael 6/14/2012 00:33'!
initialize
"
	KSBridge initialize
"
	Background := self blueBackground.
" the blueBackground is now MS-sky color"

	TX2 := self newTx2.
	FileDirectory default deleteFileNamed: 'frank-steel.sexp'.
	PartsData := nil.
	PartsData := self partsData sissReadObjects.
	ReleaseSound := self soundFromCachedUrl: 'http://tinlizzie.org/~aran/release.wav'.
	FallSound := self soundFromCachedUrl: 'http://tinlizzie.org/~aran/crash.wav'.
	RiseSound := self soundFromCachedUrl: 'http://tinlizzie.org/~aran/rise.wav'.! !

!KSBridge class methodsFor: 'all' stamp: 'yo 4/24/2012 15:27'!
lines

	| set |
	set := PluggableSet new.
	set equalBlock: [:a :b | a min = b min and: [a max = b max]].
	set hashBlock: [:a | a first hash + a second hash].

	self triangles do: [:tri |
		set add: {tri first-1. tri second-1}.
		set add: {tri second-1. tri third-1}.
		set add: {tri third-1. tri first-1}].
	^ set asArray.! !

!KSBridge class methodsFor: 'all' stamp: 'yo 6/4/2012 14:56'!
msSkyColor
	^ Color r: 0.207 g: 0.486 b: 0.807! !

!KSBridge class methodsFor: 'all' stamp: 'yo 6/1/2012 09:45'!
newTx2
	^ (Form extent: 1024@768 depth: 32) fillColor: (Color r: 0.2 g: 0.2 b: 0.2).! !

!KSBridge class methodsFor: 'all' stamp: 'yo 6/5/2012 10:22'!
partsData
	| urlString |
	urlString :=  'http://tinlizzie.org/~ohshima/frank-steel.sexp'.
	^ [SexpParser read: (FileStream readOnlyFileNamed: 'frank-steel.sexp')]
		on: FileDoesNotExistException do: [:ex |
			| data |
			data := HTTPSocket httpGet: urlString.
			FileStream newFileNamed: (urlString copyAfterLast: $/)
				do: [:file | file binary; nextPutAll: data binary contents].
			SexpParser read: data ascii reset]! !

!KSBridge class methodsFor: 'all' stamp: 'yo 4/24/2012 14:30'!
points
	^ {37@44. 99@44. 161@45. 222@45. 283@47. 37@205. 99@147. 160@109. 221@86. 282@73 .343@72. 649@44. 587@44. 525@45. 464@45. 403@47. 649@205. 587@147. 526@109. 465@86. 404@73}! !

!KSBridge class methodsFor: 'all' stamp: 'yo 9/3/2013 18:02'!
ruleWeightExample
"
KSBridge ruleWeightExample
"
	| jj weight |
	jj := KSMorph new openInWorld.
	jj window add: (weight := KSBox extent: 300@200 fill: Color white).
	KSBridge new putRuleContents: weight! !

!KSBridge class methodsFor: 'all' stamp: 'ael 6/13/2012 22:46'!
soundFromCachedUrl: urlString
	| fileString |
	fileString := urlString copyAfterLast: $/.
	^ [SampledSound fromWaveStream: (FileStream readOnlyFileNamed: fileString)]
		on: FileDoesNotExistException do: [:ex |
			| data |
			data := HTTPSocket httpGet: urlString.
			FileStream newFileNamed: fileString
				do: [:file | file binary; nextPutAll: data binary contents].
			SampledSound fromWaveStream: data]! !

!KSBridge class methodsFor: 'all' stamp: 'yo 4/24/2012 14:52'!
triangles
	^ {
		{1. 6. 7}.
		{1. 7. 2}.
		{2. 7. 8}.
		{2. 8. 3}.
		{3. 8. 9}.
		{3. 9. 4}.
		{4. 9. 10}.
		{4. 10. 5}.
		{5. 10. 11}.

		{12. 18. 17}.
		{12. 13. 18}.
		{13. 19. 18}.
		{13. 14. 19}.
		{14. 20. 19}.
		{14. 15. 20}.
		{15. 21. 20}.
		{15. 16. 21}.
		{16. 11. 21}.
	}! !

!KSBridge class methodsFor: 'all' stamp: 'yo 5/31/2012 15:22'!
twitter
	| urlString |
	urlString :=  'http://tinlizzie.org/~ohshima/twitter.png'.
	^ [Form fromFileNamed:  'twitter.png']
		on: FileDoesNotExistException do: [:ex |
			| data |
			data := HTTPSocket httpGet: urlString.
			FileStream newFileNamed: (urlString copyAfterLast: $/)
				do: [:file | file binary; nextPutAll: data binary contents; close].
			Form fromFileNamed:  'twitter.png']! !

!KSBridge class methodsFor: 'all' stamp: 'yo 5/31/2012 15:26'!
twitterBackground
	| f tw |
	f := Form extent: 1024@768 depth: 32.
	tw := self twitter.
	f fill: (0@0 corner: 1024@150) fillColor: (tw colorAt: 0@0).
	f fill: (0@150 corner: 1204@768) fillColor:  (tw colorAt: 0@(tw height -1)).
	tw displayOn: f at: 0@120.
	^ f! !

!KSBridge class methodsFor: 'all' stamp: 'yo 5/30/2012 13:39'!
tx2
	| f |
	f := Form extent: 1024@768 depth: 32.
	f fill: (0@0 corner: 1204@768) fillColor:  (Color r: 1.0 g: 0.831 b: 0.686).
	f fill: (123@0 corner: (1024-123@768)) fillColor:  (Color r: 0.2 g: 0.2 b: 0.2).
	f fill: (180@50 extent: 664@664) fillColor:  (Color r: 0.3 g: 0.3 b: 0.3).
	^ f! !
