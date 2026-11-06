KSObject subclass: #KSUserEventHandler
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects'!

!KSUserEventHandler methodsFor: 'box-compatibility' stamp: 'yo 7/5/2012 15:21'!
deaf = (arguments) ->
	var whole = this.whole
	if whole
		for x in arguments
			whole._unsubscribe_for(this, EventNameMap[x.asSymbol()])! !

!KSUserEventHandler methodsFor: 'box-compatibility' stamp: 'yo 7/5/2012 15:22'!
listen = (arguments) ->
	var whole = this.whole
	if whole
		for x in arguments
			whole._on_to(EventNameMap[x.asSymbol()], this)! !

!KSUserEventHandler methodsFor: 'color picker' stamp: 'yo 7/5/2012 15:12'!
alphaHatchFor = (c) ->
	var f = this.getHatch().deepCopy()
	var g = GeziraCanvas.on(f)
	g._fill(GeziraFill._gradient_from_to([
		Association._key_value(0, Color.transparent()),
			Association._key_value(1, c)],
		P(0.5, 8.5),
		P(0.5, 264.5)))
	g.draw((P(0, 8).corner(f.boundingBox().bottomRight() - P(0, 8))).asGeziraPath())
	this.alpha.whole.fill(f.asGeziraFill())! !

!KSUserEventHandler methodsFor: 'color picker' stamp: 'yo 7/5/2012 15:13'!
calculateShadeForHue = (h) ->
	var f = Form._extent_depth(P(256, 256), 32)
	var canvas = GeziraCanvas.on(f)
	canvas.fill(GeziraFill._gradient_from_to([
		Association._key_value(0, Color.white()),
			Association._key_value(1, Color._h_s_v(h, 1.0, 1.0))],
		P(0.5, 0.5), P(255.5, 0.5)))
	canvas.draw(f.boundingBox().asGeziraPath())
	canvas.fill(GeziraFill._gradient_from_to([
		Association._key_value(0, Color.transparent()),
			Association._key_value(1, Color.black())],
		P(0.5, 0.5), P(0.5, 255.5)))
	canvas.draw(f.boundingBox().asGeziraPath())
	this.sv.whole.fill(f.asGeziraFill())! !

!KSUserEventHandler methodsFor: 'connectors' stamp: 'yo 7/13/2012 05:38'!
beConnectorHandler = (start, end) ->
	this.setupConnector = (s, e) ->
		this.start = s ? this.makeConnectorEnd()
		this.end = e ? this.makeConnectorEnd()
		this.ends = [this.start.handler(), this.end.handler()]
		for x in this.ends
			if x.addConnection
				x.addConnection(this.whole)
	this.setupConnector(start, end)

	this.markerStart = "round"
	this.markerEnd = "round"
	this.width = 2
	this.fill = Color.lightBlue()
	this.pathFromTo = (fromPoint, toPoint) ->
		this._defaultPathFrom_to(fromPoint, toPoint)

	this.updateLine = $$(mergeE(
		mergeE(extract(@start, "extent"), extract(@start, "transformation")),
		mergeE(extract(@end, "extent"), extract(@end, "transformation")),
		@fill,
		@width,
		@pathFromTo,
		switchColE(@ends, "trackHand")).mapE((x) -> this.updateConnector()))

	this.detectEndsDropped = $$(switchColE(@ends, "droppedInto").mapE((x) ->
		var ind = if x.box == this.start then 0 else 1
		if ind == 0
			this.start = x.target
		else
			this.end = x.target
		var oldPos = x.box.globalPointFor(x.box.extent()/2.0)
		x.box._delete()
		var h = this.ends[ind] = x.target.handler
		if h.addConnection
			h.addConnection(this.whole, x.box, oldPos)))

	this.detectDropped = $$(@containerChanged.mapE((x) ->
		if !!(x.newValue instanceof JHand)
			if this.ends[0].isConnectorEnd && !!this.start.container()
				this.start.center(x.newValue.localPointFor(this.whole.globalPointFor(this.start.center())))
				x.newValue.addFirst(this.start)
			if this.ends[1].isConnectorEnd && !!this.end.container()
				this.end.center(x.newValue.localPointFor(this.whole.globalPointFor(this.end.center())))
				x.newValue.addFirst(this.end)))

	this.disconectAnEnd = $$(@shiftButtonDown.mapE((ev) ->
		if this.start.globalPointFor(this.start.extent()/2).dist(ev.position) < this.end.globalPointFor(this.end.extent()/2).dist(ev.position)
			var box = this.start
			var ss = true
		else
			box = this.end
		if !!box.handler.isConnectorEnd
			if box.handler.removeConnection
				box.handler.removeConnection(this.whole)
			box = this.makeConnectorEnd()
			this.whole.container().add(box)
			if ss
				box.center(this.start.center())
				this.setupConnector(box, this.end)
			else
				box.center(this.end.center())
				this.setupConnector(this.start, box)
		box.handler.startTracking(ev)))

	this.buttonDown = $$(extractE(this.whole, "buttonDown"))
	this.shiftButtonDown = $$(@buttonDown.mapE((ev) ->
		if ev.buttons.anyMask(8) then ev else undefined))
	this.containerChanged = $$(extractE(@whole, "containerChanged"))

	this.listen(["buttonDown"])! !

!KSUserEventHandler methodsFor: 'flipping' stamp: 'yo 7/13/2012 23:30'!
beFlippingButton = (headShape, tailShape, showHead, duration) ->
	this.beTransitiveButton(showHead, duration)
	this.headShape = headShape
	this.tailShape = tailShape
	this.whole.shape(if this.selected then @headShape else @tailShape)

	this.mayFlip = $$(@fire.mapE((ev) -> this.startFlipping()))

	this.flipStep = $$(@transitionTimer.mapE((t) ->
		if t < (@transitionDuration / 2.0)
			this.whole.shape(@shapeFrom)
			var s = 1.0 - t / (@transitionDuration / 2.0)
		else
			this.whole.shape(@shapeTo)
			var s = (t - (@transitionDuration / 2.0)) / (@transitionDuration / 2.0)
		if !!s.closeTo(0.0)
			var center = this.whole.center()
			this.whole.scale(P(s, 1))
			this.whole.center(center)))! !

!KSUserEventHandler methodsFor: 'flipping' stamp: 'yo 7/13/2012 23:28'!
beTransitiveButton = (isSelected, duration) ->
	this.attachButtonHandler()
	this.transitionDuration = duration ? 1000
	this.selected = isSelected ? false

	this.mayFire = this.fire
	this.fire = $$(@mayFire.mapE((ev) ->
		if !!this.transiting.currentValue() then ev else undefined))

	this.transiting = $$(false fby @transitionTimer < @transitionDuration)! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'yo 7/5/2012 14:40'!
addAlignHandler = (box, location) ->
	this.target = box
	this.location = location
	this.update = $$(extract(@target, "extent").mapE((x) ->
		this.whole._pivotPosition(x.newValue * this.location)))! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'yo 5/11/2012 13:04'!
attachBasicHandler = (downFunc, moveFunc, upFunc) ->
	this.whole.eventHandler()
	this.upFunc2 = 		(x) ->
		x.hand._focus(null)
		x.object._unsubscribe_for(this, JMotionEvent)
		x.object._unsubscribe_for(this, JButtonUpEvent)
		if upFunc
			upFunc(x)
	this.moveFunc2 = 	(x) ->
		if moveFunc
			moveFunc(x)
	this.downFunc2 = (x) ->
		x.hand._focus(x.object)
		x.object._on_to(JMotionEvent,  x.object.handler())
		x.object._on_to(JButtonUpEvent,  x.object.handler())
		if downFunc
			downFunc(x)
	this.doButtonDown		=	$$(extractE(this.whole, "buttonDown").mapE(@downFunc2))
	this.doPointerMotion	=	$$(extractE(this.whole, "pointerMotion").mapE(@moveFunc2))
	this.doButtonUp		=	$$(extractE(this.whole, "buttonUp").mapE(@upFunc2))

	this.listen("buttonDown")
	this._handleControlKey(false)! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'yo 7/18/2012 16:33'!
attachDownMoveUpHandlers = (downFunc, moveFunc, upFunc) ->
	this.whole.eventHandler()

	this.downFunc2 =	(evt) ->
		evt.hand._focus(evt.object)
		evt.object._on_to(JMotionEvent,  evt.object.handler)
		evt.object._on_to(JButtonUpEvent,  evt.object.handler)
		if downFunc
			downFunc(evt)

	this.moveFunc2 =	(evt) ->
		if moveFunc
			moveFunc(evt)

	this.upFunc2 =		(evt) ->
		evt.hand._focus(null)
		evt.object._unsubscribe_for(this, JMotionEvent)
		evt.object._unsubscribe_for(this, JButtonUpEvent)
		if upFunc
			upFunc(evt)

	this.doButtonDown		=	$$(@buttonDown.mapE(@downFunc2))
	this.doPointerMotion	=	$$(@pointerMotion.mapE(@moveFunc2))
	this.doButtonUp		=	$$(@buttonUp.mapE(@upFunc2))
	this.buttonDown = $$(extractE(this.whole, "buttonDown"))
	this.pointerMotion = $$(extractE(this.whole, "pointerMotion"))
	this.buttonUp = $$(extractE(this.whole, "buttonUp"))
	this.listen(["buttonDown"])
	this.handleControlKey(false)! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'tk 7/6/2012 17:12'!
beColorPickerHandler = (aColor) ->
	// the actions for the color picker UI.  JMorph test9.
	this.whole._fill(Color._white())
	this.whole._borderWidth(1)
	this.whole._borderColor(Color._black())
	this.whole._extent(P(320, 340))
	this.setupColorPicker()

	this.hue.setSliderCurrentValue(aColor._hue() / 360.0)
	this.alpha.setSliderCurrentValue(aColor._alpha())
	this.sv.setSliderCurrentValue(P(aColor._saturation(), (1.0- aColor._brightness())))

	// make a stream of colors that produces a new value when any of the three sliders changes
	this.color = $$(lift((a, h, sv) -> Color._h_s_v(h * 360, sv.x(), 1.0 - sv.y()).alpha(a), @alpha.sliderValue, @hue.sliderValue, @sv.sliderValue2D))

	// change the alpha display
	this.update = $$(@color.mapE((c) -> this.alphaHatchFor(c._alpha(1.0))))
	this.updateSV = $$(@hue.sliderValue.mapE((h) -> this.calculateShadeForHue(h*360)))

	// the [ok] button
	this.fire = $$(@button.fire.mapE((x) -> Transcript._show(x.printString())))
	this.dismiss = $$(@fire.mapE((x) -> this.whole._delete()))
	this! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'yo 7/5/2012 15:00'!
beListItemHandler = (defaultFill, enteredFill, pressedFill, selectedFill) ->
	this.attachButtonHandler()
	this.defaultFill = defaultFill
	this.selectedFill = selectedFill
	this.pressedFill = pressedFill
	this.selected = $$(@selectionChangeRequested == true)
	this.selectionChangeRequested = $$(@__container__.itemSelected.mapE((x) -> x.item === this.whole))
	this.isListItem = true
	this.highlightEnabled = $$(true fby @isListItem && !!@selected)
	this! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'yo 7/18/2012 16:38'!
beMenuHandler = (stayUp, actions) ->
	this.stayUp = !!!!stayUp
	this.makeItems = (actionList) ->
		var col = []
		var b
		this.whole.removeAll()
		for action in actionList
			if action == "-".asSymbol()
				b = JBox._extent_fill(P(50, 8), Color.transparent())
			else
				b = action[1].menuLabel()
			col.push(b.eventHandler().beListItemHandler(
				Color.transparent(), Color.gray(0.8), Color.gray(0.7), Color.gray(0.7)))
			b.handler.menuAction = if action == '-'.asSymbol() then "yourself".asSymbol() else action[0]
			b.handler.menuArgument = action[2]
			this.whole.add(b)
		this.items = col
	this.makeItems(actions)
	this.itemSelected = $$(switchColE(@items, "fire"))
	this.dismiss = $$(((@itemSelected || @buttonUp) && !!@stayUp).mapE((x) ->
		if x then this.whole._delete() else undefined))

	this.listChangeRequest = undefined
	this.listChangeRequested = $$(@listChangeRequest.mapE((col) ->
		this.makeItems(col)))

	this.buttonUp = $$(extractE(this.whole, "buttonUp"))
	this.listen(["buttonDown", "buttonUp"])! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'yo 7/5/2012 15:04'!
beRotationHandler = (targetArg) ->
	this.target = targetArg
	this.attachDownMoveUpHandlers(
		(downEvt) ->
			var target = this.target.currentValue()
				if target
					this.clickPosition = this.whole.localPointFor(downEvt.position)
					if this.target == target
						this.origDiff = P(0, 0)
						this.origAngle = (this.clickPosition - target.pivotOffset()).theta()
					else
						this.origDiff = target.localPointFor(this.whole.container().globalPointFor(this.whole.pivotPosition())) - target.pivotOffset()
						this.origAngle = this.origDiff.theta(),
		(moveEvt) ->
			var target = this.target.currentValue()
			var diff = target._localPointFor(moveEvt.position) - target.pivotOffset()
			var rot = diff.theta() - this.origAngle
			var current = target.rotation()
			if this.low
				if current + rot < this.low
					rot = this.low - current
			if this.high
				if current + rot >= this.high
					rot = this.high - current
			var newRot = current + rot
			var pi = Float.pi()
			var t = pi / 45
			for stop in [0.0, pi * 0.5, pi, pi * 1.5, pi * 2.0]
				if (newRot - stop).abs() < t
					rot = stop - current
			target._rotateBy_around(rot, target._pivotRatio())
			if this.whole == target
				this.whole.pivotPosition(target.globalPointFor(this.origDiff) + target.pivotOffset()),
		null)! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'yo 7/5/2012 15:04'!
beScaleHandler = (targetArg) ->
	this.target = targetArg
	this.attachDownMoveUpHandlers(
		(downEvt) ->
			var target = @target
			if (target)
				this.origTransformation = target.transformation()
				this.clickScale = this.origTransformation.invertPoint(target.container().localPointFor(downEvt.position)) / target.scale2D(),
		(moveEvt) ->
			var target = @target
			var now = this.origTransformation.invertPoint(target.container().localPointFor(moveEvt.position)) / this.clickScale
			target.scale(now),
		null)! !

!KSUserEventHandler methodsFor: 'handlers' stamp: 'yo 7/11/2012 16:50'!
beToggleButtonHandler = (initialState) ->
	this.attachButtonHandler()
	this.toggleSelected = $$(@fire.mapE((x) ->
		this._ksSet_put("selected" ,!!this.selected.currentValue())))
	this.highlightEnabled = false
	this._ksSet_put("selected", !!!!initialState)! !

!KSUserEventHandler methodsFor: 'library' stamp: 'yo 4/17/2012 09:40'!
orContainer = (func) ->
	var a = this
	while a
		if func(a)
			return a
		a = a.__container__
	return null! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:22'!
acceptDrops = (target, evt) ->
	target.eventHandler().beDropAcceptor()! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:23'!
chooseColor = (target, evt) ->
	var root = target._topContainer()
	var picker = JBox._new()
	picker.eventHandler().beColorPickerHandler(target._fill()._asColor())
	root._add(picker)
	picker.handler.pickerTarget = target
	picker.handler.script = $$(@color.mapE((x) -> picker.handler().pickerTarget._color(x)))! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/6/2012 10:39'!
createMenu = (actions, receiver) ->
	//Put up the menu from the list of actions."
	var menu = JBox.newMenu()
	var handler = menu.eventHandler()
	handler.actionTarget = receiver ? handler
	handler.script = $$(@itemSelected.mapE((x) ->
		x.event.root.worldState().deleteModals()
		var actionHandler = x.item.handler
		handler.ksPerform(actionHandler.menuAction, [actionHandler.menuArgument ? handler.actionTarget, x.event].asArray())))	
	handler.makeItems(actions)
	menu! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:24'!
deleteBox = (target, evt) ->
	target._delete()! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:30'!
exploreInMorphic = (target, evt) ->
	WorldState.addDeferredUIMessage(() -> target.explore())! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:28'!
inspectInMorphic = (target, evt) ->
	WorldState.addDeferredUIMessage(() -> target.inspect())! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:31'!
installMover = (target, evt) ->
	target.eventHandler().beGenericMoveHandler()! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:31'!
ksExploreInMorphic = (target, evt) ->
	WorldState.addDeferredUIMessage(() -> target.handler.ksExplore())! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:29'!
ksInspectInMorphic = (target, evt) ->
	WorldState.addDeferredUIMessage(() -> target.handler.ksInspect())! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:32'!
newBox = (target, evt) ->
	var box =  JBox._new()
	if !!(target.canInclude(box))
		return
	box.topLeft(P(50, 50))
	target.addFirst(box)! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:32'!
newButton = (target, evt) ->
//	"A box with label.  Control-click gets a halo"
	var box = JBox.newButton("Click Here")
	if !!(target.canInclude(box))
		return
	target.addFirst(box)
	box.topLeft(P(50, 50))! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:32'!
pickUp = (target, evt) ->
	if evt && evt.hand
		evt.hand.handler().attachBox(target)! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:33'!
sendToRear = (target, evt) ->
	target.container()._reorder_beAt(target, target._container().size())! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:33'!
showDebugMenu = (target, ev) ->
	// "Put up the standard debug submenu."
	JBox._invokeMenu_near_for(this.createMenu(target.debugMenu(), target), ev.position, target)! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:33'!
showDefaultMenu = (target, ev) ->
	// "Put up the standard menu."
	JBox._invokeMenu_near_for(this.createMenu(target.defaultMenu(), target), ev.position, target)! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:33'!
showNewObjectMenu = (target, ev) ->
	// "Put up the new object menu."
	JBox._invokeMenu_near_for(this.createMenu(target.newObjectMenu(), target), ev.position, target)! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:33'!
toggleDropShadow = (target, evt) ->
	target.shadowToggle()! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:33'!
toggleSoftShadow = (target, evt) ->
	target.shadowSoftCycle()! !

!KSUserEventHandler methodsFor: 'menu actions' stamp: 'yo 7/5/2012 14:34'!
userCopy = (target, evt) ->
	var newBox = target.deepCopy()
	newBox.topLeft(target.topLeft() + (P(10, 10)))
	target.container()._add_afterIndex(newBox, target.index() - 1)
	//move halo to new object"
//	(target topContainer handler at: #haloTarget) == target ifTrue: [
//			target topContainer handler ksSet: #haloTarget put: new ].
	return newBox! !

!KSUserEventHandler methodsFor: 'shape transformers' stamp: 'yo 7/5/2012 15:06'!
attachShapeStretcher = (aPoint) ->
	this.cut(aPoint)
	this.shapeStretcher = $$(extract(this.whole, "extent").mapE((ev) ->
		this.whole.shape().elements(this.stretchedPaths())))! !

!KSUserEventHandler methodsFor: 'sliders' stamp: 'yo 7/5/2012 15:22'!
setSliderCurrentValue = (aNumberOrPoint) ->
	var minmax = this.sliderMinMax()
	var cmin = minmax.min
	var cmax =minmax.max
	this.sliderMoveToWithin(aNumberOrPoint * (cmax - cmin) + cmin, cmin, cmax)
	// this is pretty bad, but assumes that sliderValue2D here is a collectE stream.
	// once there is new syntax and we can provide a sensible stream value to the initialization of collectE, this can be fixed.
	this.sliderValue2D.__currentValue__ = aNumberOrPoint.asPoint().max(cmin).min(cmax)! !

!KSUserEventHandler methodsFor: 'sliders' stamp: 'yo 7/5/2012 15:23'!
sliderMoveTo = (aPoint) ->
	var minmax = this.sliderMinMax()
	this.sliderMoveToWithin(aPoint, minmax.min, minmax.max)! !

!KSUserEventHandler methodsFor: 'sliders' stamp: 'yo 7/5/2012 15:23'!
sliderMoveToWithin = (aPoint, cmin, cmax) ->
	var newPos = aPoint
	if cmin
		newPos = newPos.max(cmin)
	if cmax
		newPos = newPos.min(cmax)
	this.sliderKnob().topLeft(newPos)! !

!KSUserEventHandler methodsFor: 'sliders' stamp: 'yo 7/5/2012 15:24'!
sliderValue = (newPos) ->
	var minmax = this.sliderMinMax()
	var cmin = minmax.min
	var cmax = minmax.max
	var total = minmax.max - minmax.min
	if total.x() == 0.0
		total = P(1, total.y())
	if total.y() == 0.0
		total = P(total.x(), 1)
	(newPos - cmin) / total! !

!KSUserEventHandler methodsFor: 'squeak compatibility' stamp: 'yo 9/3/2013 14:30'!
ksAt: key put: anObject
	anObject isEventStream ifTrue: [
		((anObject keys reject: [:k | (k at: 1) = $_]) select: [:k |
			| v |
			v := anObject at: k.
			v isEventStream and: [v isLayoutChangedDependents]]) size > 0 ifTrue: [
				(self at: #'__layoutDep__' ifAbsentPut: [KSObject new]) at: anObject put: anObject].	
		anObject type == #setter ifTrue: [anObject name: key].
		(self ksAt: #whole) asBoolean ifTrue: [
			(self ksAt: #whole) worldState asBoolean ifTrue: [
				(self ksAt: #whole) worldState clearSortedBubbles]].
	anObject isBox ifTrue: [
		anObject worldState asBoolean ifTrue: [
			self worldState clearSortedBubbles]]].
	^ super ksAt: key put: anObject! !
