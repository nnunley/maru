KSUserEventHandler subclass: #KSFrankScripting
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSFrankScripting methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/28/2013 19:53'!
deserializeOne: sexp
	| handler rcvr |
	rcvr := self makeObject: (sexp elements first attributeAt: #name).
	handler := rcvr at: #handler.
	sexp attributeAt: #trigger ifPresent: [:t |
		handler acceptDropOf: (handler makeTrigger: t)].
	sexp attributeAt: #selector ifPresent: [:verb |
		handler acceptDropOf: (handler makeVerb: verb)].
	^ rcvr.! !

!KSFrankScripting methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/28/2013 19:39'!
deserializeScript: aPPElement
	| block tail |
	aPPElement head == #script ifFalse: [self error: 'not a script'].
	tail := nil.
	aPPElement elements reverseDo: [:e |
		e head == #scriptLine ifFalse: [self error: 'wrong kind of script'].
		block := self deserializeOne: e.
		tail
			ifNil: [tail := block]
			ifNotNil: [(block at: #handler) acceptDropOf: tail. tail := block]].
	^ tail.! !

!KSFrankScripting methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/19/2013 11:29'!
serialize: objBlock
	| under |
	under := self objectUnder: objBlock.
	under asBoolean ifTrue: [
		^ ({#script}, (self serializeInner: under) asArray) asPPElement]
	ifFalse: [^ nil]! !

!KSFrankScripting methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/28/2013 19:10'!
serializeInner: objBlock
	objBlock ifNil: [^ OrderedCollection new].
	^ (self serializeInner: ((objBlock at: #handler) objectUnder: nil)) addFirst: ((objBlock at: #handler) serializeOne); yourself! !

!KSFrankScripting methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/28/2013 19:11'!
serializeOne
	| rcvr verb trigger |
	rcvr := (self at: #whole) name.
	verb := self getVerb: nil.
	trigger := self getTrigger: nil.

	rcvr := {#literal. #type. 'box'. #name. rcvr}.
	^ ({#scriptLine},
		(trigger ifNotNil: [{#trigger. trigger name}] ifNil: [#()]),
		(verb ifNotNil: [{#selector. verb name}] ifNil: [#()]), {rcvr}).! !

!KSFrankScripting methodsFor: 'accessing' stamp: 'yo 1/27/2013 23:32'!
getTrigger = (tile) ->
	return (e in (tile ? this.whole).contents() when e.handler.scriptingType == "trigger")! !

!KSFrankScripting methodsFor: 'accessing' stamp: 'yo 1/28/2013 18:41'!
getVerb = (tile) ->
	return (e in (tile ? this.whole).contents() when e.handler.scriptingType == "verb")! !

!KSFrankScripting methodsFor: 'accessing' stamp: 'yo 1/28/2013 18:41'!
objectUnder = (tile) ->
	return (x in (tile ? this.whole).contents() when x.handler.scriptingType == "object")! !

!KSFrankScripting methodsFor: 'accessing' stamp: 'yo 7/5/2012 20:56'!
passive = (aBoolean) ->
	this.passive = aBoolean! !

!KSFrankScripting methodsFor: 'accessing' stamp: 'yo 1/31/2013 22:57'!
scriptingArea = () ->
	return @whole.orContainerSuchThat((box) -> !!(box.handler instanceof KSFrankScripting))! !

!KSFrankScripting methodsFor: 'event handling' stamp: 'yo 7/5/2012 20:42'!
acceptDropOf = (box) ->
	if box === this.whole
		return
	var wholeType = this.scriptingType
	var boxType = box.handler.scriptingType
	if this.canAcceptUnder(boxType, wholeType)
		this.acceptObjectBlock(box)
	if this.canAcceptSide(boxType, wholeType)
		return this.acceptVerbBlock(box)
	if this.canAcceptTrigger(boxType, wholeType)
		return this.acceptTriggerBlock(box)! !

!KSFrankScripting methodsFor: 'event handling' stamp: 'yo 7/5/2012 20:43'!
acceptObjectBlock = (box) ->
	var whole = this.whole
	var tail = this.objectUnder(whole)
	whole.add(box)
	box.topLeft(P(0, whole._height() + 1))
	var boxLast = this.findLastObjectFrom(box)
	if tail
		boxLast.add(tail)
		tail.topLeft(P(0, boxLast.height() + 1))! !

!KSFrankScripting methodsFor: 'event handling' stamp: 'yo 1/28/2013 18:41'!
acceptTriggerBlock = (box) ->
	var whole = this.whole
	var old = this.getTrigger(nil)
	whole.add(box)
	box.topRight(P(0, 0))
	if old
		var top = this.scriptingArea()
		var oldPos = old.globalPointFor(Point(0, 0))
		top.addFirst(old)
		old.topLeft(top.localPointFor(oldPos) + P(whole.height() * 0.66, whole.height() * -0.66))! !

!KSFrankScripting methodsFor: 'event handling' stamp: 'yo 1/28/2013 18:41'!
acceptVerbBlock = (box) ->
	var whole = this.whole
	var old = this.getVerb(nil)
	whole.add(box)
	box.topLeft(P(whole.width(), 0))
	if old
		var top = this.scriptingArea()
		var oldPos = old.globalPointFor(Point(0, 0))
		top.addFirst(old)
		old.topLeft(top.localPointFor(oldPos) + P(whole.height() * 0.66, whole.height() * -0.66))! !

!KSFrankScripting methodsFor: 'event handling' stamp: 'yo 2/1/2013 09:43'!
handlesEvent = (anEvent) ->
	if anEvent.event == "motionQuery"
		var tileInHand = if anEvent.hand.contents.size() > 0 && (anEvent.hand.contents.first().handler instanceof KSFrankScripting) then anEvent.hand.contents.first() else nil
		if tileInHand
			var center = @whole.localPointFor(anEvent.hand.globalPointFor(tileInHand.center()))
			if tileInHand.handler.scriptingType == "object"
				return (P(0, 0).corner(((@whole.extent() * P(1, 0.6)) + P(0, @whole.height())))).includesPoint(center)
			if tileInHand.handler.scriptingType == "trigger"
				var halfW = tileInHand.bounds().width()/2.0
				return (P(-halfW, 0).corner(P(halfW, @whole.height()))).includesPoint(center)
			if tileInHand.handler.scriptingType == "verb"
				var halfW = tileInHand.bounds().width()/2.0
				return (P(-halfW+@whole.width(), 0).corner(P(halfW + @whole.width(), @whole.height()))).includesPoint(center)

	return @whole.basicHandlesEvent(anEvent)! !

!KSFrankScripting methodsFor: 'event handling' stamp: 'yo 1/27/2013 23:21'!
objectName = (tile) ->
	return (tile ? this.whole).name()! !

!KSFrankScripting methodsFor: 'menu' stamp: 'yo 2/19/2013 11:22'!
newObject = (ev) ->
	var list = ([#'newTile', b.name()] for b
		in @scriptingTarget.contents.asArray().concat([@scriptingTarget]) when b.name().asBoolean())
	var menu = @whole.createMenu(list, this)
	KSBox._invokeMenu_near_for(menu, ev.position, @whole)! !

!KSFrankScripting methodsFor: 'menu' stamp: 'yo 2/14/2013 12:19'!
newTile = (ev) ->
	var label = ev.handler.textContents()
	if label == 'space' || label == 'click'
		var button = this.makeTrigger(label)
	else
		if label == 'show' || label == 'hide'
			button = this.makeVerb(label)
		else
			button = this.makeObject(label)
	ev.hand.attachBox(button)! !

!KSFrankScripting methodsFor: 'menu' stamp: 'yo 2/14/2013 12:13'!
newTrigger = (ev) ->
	var menu = @whole.createMenu([[#'newTile', 'space'], [#'newTile', 'click']], this)
	KSBox._invokeMenu_near_for(menu, ev.position, @whole)! !

!KSFrankScripting methodsFor: 'menu' stamp: 'yo 2/14/2013 12:32'!
newVerb = (ev) ->
	var menu = @whole.createMenu([[#'newTile', 'show'], [#'newTile', 'hide']], this)
	KSBox._invokeMenu_near_for(menu, ev.position, @whole)! !

!KSFrankScripting methodsFor: 'menu' stamp: 'yo 2/14/2013 12:20'!
showMenu = (ev) ->
	var menu = [[#'newTrigger', 'new trigger'], [#'newObject', 'new object'], [#'newVerb', 'new action']]
	KSBox._invokeMenu_near_for(@whole.createMenu(menu, this), ev.position, @whole)! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 3/7/2013 14:55'!
fill = () ->
	return Color.transparent()! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 1/28/2013 10:44'!
font = () ->
	return KSFont.scriptingFont()! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 1/28/2013 10:45'!
height = () ->
	return this.font().height() + 4! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 2/13/2013 14:51'!
makeHead = (v) ->
	var box = this.makeObject("start")
	box.handler.scriptingType = "start"
	delete box.buttonDown
	return box! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 3/7/2013 14:56'!
makeMenuButton = () ->
	var button = this.newMenuButton = @whole.factory().newButton("new")
	button.cornerRadius(0)
	button.attachButtonHandler()
	this.newButton = $$(this.showMenu(@newMenuButton.fire))
	button.name("newMenu")
	return button! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 2/1/2013 10:02'!
makeObject = (objName) ->
	var caption = this.newObjectName(objName)
	var box = this.newBlock(nil, caption, nil)
	box.width(50)
	this.newObjectLayout(box)
	box.handler.scriptingType = "object"
	box.name(objName.asString())
	box.attachDropAcceptor()
	box.addDroppedBox = (request) ->
		box.handler.acceptDropOf(request.box)

	box.myHandlesEvent = (anEvent) ->
		box.handler.handlesEvent(anEvent)

	box.doPointerEnter = $$(@pointerEnter.mapE((ev) ->
		if ev.hand.contents.size() == 0 then undefined else ev).doE(() ->
			box.fill(Color.green())))
	box.doPointerLeave = $$(@pointerLeave.doE(() -> box.fill(Color.white())))
	return box! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 1/28/2013 16:45'!
makeTrigger = (triggerName) ->
	if ["click", "touch", "space"].contains(triggerName)
		var icon = KSBox.withShape(@whole.factory().clickIcon())
		icon.scale(this.height() * 0.65 / icon.height())
	var caption = this.newCaption(triggerName)
	var box = this.newBlock(icon, caption, [])
	box.handler.scriptingType = "trigger"
	box.name(triggerName.asString())
	box.width(25)
	return box! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 1/28/2013 16:44'!
makeVerb = (verbString) ->
	var icon = this.newIcon(verbString)
	var caption = this.newCaption(verbString)
	var box = this.newBlock(icon, caption, [])
	this._newBlockLayout_and(box, caption)
	box.handler.scriptingType = "verb"
	box.name(verbString.asString())
	box.borderFill(Color.gray())
	box.width(40)
	return box! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 1/31/2013 22:24'!
newBlock = (icon, caption, arrows) ->
	var box = KSBox._extent_fill(P(40, this.height()), Color.white())
	if caption
		box.addAsParts(caption)
	if icon
		box.addAsParts(icon)
	box.borderWidth(1)
	box.cornerRadius(1.5)
	box.borderFill(Color.gray())
	this._newBlockLayout_and(box, caption)
	var newHandler = this.class().new()
	newHandler.installTo(box)
	box.attachPickUpHandler()
	box.blockHaloForContents()
	return box! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 1/28/2013 15:47'!
newBlockLayout: tile and: caption
	| sl |
	tile layout: (sl := KSSimpleLayout new).
	sl
		keep: #top of: 'icon' to: #top offset: 2;
		keep: #hcenter of: 'icon' to: #hcenter;
		keep: #hcenter of: 'caption' to: #hcenter;
		keep: #bottom of: 'caption' to: #bottom offset: 0;
		yourself! !

!KSFrankScripting methodsFor: 'new block' stamp: 'ael 3/4/2013 15:05'!
newCaption = (caption) ->
	var c = @whole.factory().newLabel(caption, this.fill(), KSFont.scriptingCaptionFont())
	c.layout().inset(0)
//	c.shadowFill(Color.white())
//	c.shadowBlur(1)
	c.name('caption')
	c.layOut()
	return c! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 1/28/2013 14:46'!
newIcon = (name) ->
	if name == "show" || name == "hide"
		var icon = KSBox.withShape(if name == "show" then @whole.factory().rabbitIcon() else @whole.factory().rabbitHideIcon())
	if !!icon
		icon =  KSBox._extent_fill(P(20, 20), Color.lightGreen())
	var handler = this.class().new()
	handler.installTo(icon)
	handler.scriptingType = "label"
	icon.scale(this.height() * 0.65 / icon.height())
	icon.wantsHaloFromClick(false)
	icon.name('icon')
	return icon! !

!KSFrankScripting methodsFor: 'new block' stamp: 'yo 1/28/2013 10:47'!
newObjectLayout: tile
	tile layout: (KSSimpleLayout new
		keep: #center of: 'caption' to: #center scale: (1@1.3);
		keep: #rightCenter of: 'rightArrow' to: #rightCenter offset: -5@3;
		keep: #leftCenter of: 'leftArrow' to: #leftCenter offset: 5@3;
		yourself).! !

!KSFrankScripting methodsFor: 'new block' stamp: 'ael 3/4/2013 15:05'!
newObjectName = (name) ->
	var c = @whole.factory().newLabel(name, this.fill(), KSFont.scriptingFont())
	c.layout().inset(0)
//	c.shadowFill(Color.white())
//	c.shadowBlur(1)
	c.name('caption')
	c.layOut()
	return c! !

!KSFrankScripting methodsFor: 'private' stamp: 'yo 1/27/2013 23:32'!
findLastObjectFrom = (aBox) ->
	var c = aBox
	while true 
		var d = this.objectUnder(c)
		if !!d
			return c
		c = d! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/21/2013 16:28'!
actionsInScriptingArea = () ->
	this.doClear = $$(@clear.fire.doE(() -> this.clearScriptingArea()))
	this.doGo = $$(@go.fire.mapE((ev) ->
		if ev.handler.selected.currentValue() then this.start() else this.stop()))
	this.restart = $$(@scriptingTarget.doE(() ->
		if @cursor
			this.stop()
			this.start()))

	this.makeDirty = $$(@whole.layoutChanged.mapE((x) -> this.scriptDirty = x || this.scriptDirty))! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/18/2013 15:33'!
atName = (aName) ->
	if @scriptingTarget.name() == aName
		return @scriptingTarget
	else
		if aName == "stack"
			return @scriptingTarget
		return @scriptingTarget.atName(aName)! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'ael 3/5/2013 16:13'!
clearScriptingArea = () ->
	// "Clear the scripting area of all loose tiles..."
	var myHead = this.head()
	for c in this.whole.contents().asArray()
		if c !!== myHead
			c.delete()! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/21/2013 21:25'!
evalBox = (areaHandler) ->
	var v = if this.getVerb(nil) then this.getVerb(nil).name() else null
	var obj = areaHandler.atName(this.objectName(null))
	if obj
		if v == "show"
			obj.visible.set(true)
		if v == "hide"
			obj.visible.set(false)
		if v == "nextPage"
			this.goingToNewPage = true
			obj.__stackHandler__.showPageInc(1)! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 1/27/2013 23:22'!
head = () ->
	return (x in this.whole.contents() when x.handler.scriptingType == "start")! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/18/2013 19:14'!
installTriggerReceiver = (cursor) ->
	var trigger = this.getTrigger(cursor)
	if trigger.name() == "space"
		this.target = @scriptingTarget
		@target.listen(["keyStroke"])
		this.triggerReceiver =  $$(@target.keyStroke)! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/21/2013 21:35'!
next = (tile, evt) ->
	// "Evaluate the stack of tiles
	var cursor = tile
	var event = evt
	var more = true
	while more
		var handler = cursor.handler
		var trigger = this.getTrigger(cursor)
		if this.okToTrigger(trigger, event)
			this.uninstallTriggerReceiver(cursor)
			this.goingToNewPage = false
			handler.evalBox(this)
			event = null
			var newCursor = this.objectUnder(cursor)
			if !!newCursor
				newCursor = this.head()
			if cursor == newCursor || this.goingToNewPage
				more = false
			else
				this.cursor = cursor = newCursor
		else
			more = false
			this.installTriggerReceiver(cursor)! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 1/27/2013 23:28'!
okToTrigger = (trigger, ev) ->
	// Answer whether it is ok to trigger a given trigger with given event."
	if !!trigger
		return true
	if trigger.name() == "space" && ev.event == "keyStroke" && (ev.keyValue == 32 || ev.keyValue == 29)
		return true
	return undefined! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 3/7/2013 15:01'!
scriptingAreaButtons = () ->
	var factory = @whole.factory()
	var buttonsHolder = KSBox._extent_fill(P(20, 20), Color.white())
	buttonsHolder.layout(KSHorizontalLayout.new())
	buttonsHolder.layout().inset(4)
	buttonsHolder.layout().space = 4
	var trash = this.trash = factory.newButton("trash")
	var go = this.go = factory.newButton("go")

	go.borderWidth(3)
	go.borderFill(Color.gray())
	go.beToggleButtonHandler(false)
	go.selectedFill = Color.lightGreen()
	go.defaultFill = Color.lightRed()

	var clear = this.clear = factory.newButton("clear")
	var newButton = this.makeMenuButton()

	buttonsHolder.add(go)
	buttonsHolder.add(clear)
	buttonsHolder.add(trash)
	buttonsHolder.add(newButton)
	buttonsHolder.name("scriptingButtons")
	return buttonsHolder! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 3/7/2013 15:01'!
scriptingAreaButtonsLayout: aBox
	aBox layout ifNil: [aBox layout: KSSimpleLayout new].
	aBox layout
		keep: #bottomLeft of: 'scriptingButtons' to: #bottomLeft offset: 6 @ -5! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/14/2013 14:47'!
scriptingAreaLayout: aBox
	aBox layout ifNil: [aBox layout: KSSimpleLayout new].
	aBox layout
		keep: #topLeft of: 'start' to: #topLeft offset: 70 @ 10.! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/13/2013 14:31'!
scriptingTarget = () ->
	return @scriptingTarget! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/1/2013 09:56'!
setupScriptingArea = (scriptingTarget) ->
	var factory = scriptingTarget.factory()
	var trash = this.trash = factory.newButton("trash")
	var go = this.go = factory.newButton("go")
	var clear = this.clear = factory.newButton("clear")
	var sweep = this.sweep = factory.newButton("sweep")
	var head = this.makeHead("start")

	this.whole.addAsParts(trash)
	this.whole.addAsParts(go)
	this.whole.addAsParts(clear)
	this.whole.addAsParts(sweep)
	this.whole.add(head)

	this.scriptingAreaLayout()
	this.whole.layOut()

	this.scriptingTarget = scriptingTarget
	this.actionsInScriptingArea()! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/13/2013 14:36'!
setupScriptingHead = () ->
	this.whole.add(this.makeHead("start"))
	this.scriptingTarget = this.streamOf(undefined)! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/13/2013 15:24'!
start = () ->
	if !!@scriptingTarget
		return
	this.cursor = this.head()
	this.nextStep = $$(@triggerReceiver.mapE((ev) ->
		if this.okToTrigger(this.getTrigger(this.cursor), ev) then ev else undefined).mapE((ev1) ->
			this.next(this.cursor, ev1)))
	this.next(this.cursor, null)! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/18/2013 15:42'!
stop = () ->
	this.uninstallTriggerReceiver(@cursor)
	this.cursor = nil
	delete this.nextStep! !

!KSFrankScripting methodsFor: 'scripting area' stamp: 'yo 2/18/2013 19:14'!
uninstallTriggerReceiver = (cursor) ->
	delete this.triggerReceiver
	if !!cursor
		return
	var target = this.atName(cursor.handler.objectName(null))
	if target
		delete target.keyStroke! !

!KSFrankScripting methodsFor: 'type check' stamp: 'yo 7/5/2012 20:50'!
canAcceptSide = (boxType, ownerType) ->
	return (boxType == "verb" && ownerType == "object")! !

!KSFrankScripting methodsFor: 'type check' stamp: 'yo 7/5/2012 20:50'!
canAcceptTrigger = (boxType, ownerType) ->
	return (boxType == "trigger" && ownerType == "object")! !

!KSFrankScripting methodsFor: 'type check' stamp: 'yo 7/5/2012 20:50'!
canAcceptUnder = (boxType, ownerType) ->
	return ownerType == "trash" || (boxType == "object" && (ownerType == "object" || (ownerType == "start")))! !
