KSObject subclass: #KSWorldState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSWorldState methodsFor: 'clipboard' stamp: 'yo 2/7/2013 00:57'!
fromText: aText1
	"From Squeak text, create a collection of KSBoxes.
	Needs to be fixed!!"
	| aText ch f ff defaultFont fill |
	aText := aText1 asText.
	defaultFont := KSFactory default defaultFont.
	^ (1 to: aText size) collect: [:ii |
		ch := aText at: ii.
		f := defaultFont.
		"The following section does not work.  Needs to Sum up attributes of a char, then find the font."
		aText attributesAt: ii do: [:attr |
			fill := (attr respondsTo: #color) ifTrue: [attr color] ifFalse: [Color black].
			(attr respondsTo: #font) ifTrue: [
				ff := attr font.
				f := (((KSFamily withName: ff familyName) withStyle: ff emphasis) withSize: ff pointSize)].
			f := f fill: fill].
		KSBox withChar: ch inFont: f]! !

!KSWorldState methodsFor: 'clipboard' stamp: 'yo 2/7/2013 15:28'!
getClipboard = () ->
	// "Answer the value of clipboard"
	var text = Clipboard.clipboardText()
	if text === this.clipboardContents
		var c = this.clipboard.ppCreateObjects().contents
		for b in c
			b.container.set(nil)
		return c
	return this.fromText(text)! !

!KSWorldState methodsFor: 'clipboard' stamp: 'yo 2/7/2013 20:19'!
setClipboard = (arrayOfGlyphBoxes) ->
	// "Set the value of clipboard"
	var text = KSBox.new()
	text.layout(KSTextLayout.new())
	text.contents = arrayOfGlyphBoxes
	this.clipboard = text.ppScanObjects()
	Clipboard.clipboardText(this.clipboardContents = this.toText(arrayOfGlyphBoxes))! !

!KSWorldState methodsFor: 'clipboard' stamp: 'yo 3/15/2013 18:33'!
toText: aCollection
	"Return a Squeak Text for the contents.  Insert ? when the element is not a glyph."
	| str |
	str := Text new: aCollection size.
	aCollection withIndexDo: [:glyph :ind |
		| font |
		glyph unicode > 0 
			ifTrue: [str at: ind put: (Character value: glyph unicode).
				glyph fill asColor = Color black ifFalse: [
					str addAttribute: (TextColor color: glyph fill asColor) from: ind to: ind].
				font := (glyph at: #font) currentValue.
				str addAttribute: (TextFontReference toFont: (TTCFont familyName: font name pointSize: font pointSize emphasis: font style)) from: ind to: ind.
			]
			ifFalse: [str at: ind put: $?]].
	^ str! !

!KSWorldState methodsFor: 'drawing' stamp: 'yo 1/8/2013 16:43'!
drawOn = (aCanvas) -> 
	@window.fullDrawOn(aCanvas)! !

!KSWorldState methodsFor: 'drawing' stamp: 'yo 7/26/2012 15:48'!
needsRedraw = () ->
	return true! !

!KSWorldState methodsFor: 'evaluation' stamp: 'yo 9/10/2013 19:09'!
clearSortedBubbles = () ->
	var bubbles = this.__sortedBubbles__
	if bubbles
		for top in bubbles
			if top.__sorter__
				top.__sorter__.__invalidated__ = true
	this.__sortedBubbles__ = nil! !

!KSWorldState methodsFor: 'evaluation' stamp: 'yo 9/10/2013 11:04'!
evaluateTimeBubblesAt = (time) ->
	this.__layoutDeps__ = []
	if !!this.__sortedBubbles__
		var firstTime = true
		this.__sortedBubbles__ = []
		// Transcript.show("sorting").space().show(time.asString()).cr()
		var record = [nil, [@hand, @window]]
		while record[1].size() > 0
			var top = record[1].removeFirst()
			if top.topContainer() == this.window && (firstTime || top !!== this.hand)
				firstTime = false
				record[0] = []
				top.timeBubblesInto(record, top)
				var sorter = this.dependencyEvaluatorClass().new()
				for b in record[0]
					sorter.addStreamsFrom(b)
					if b.handler
						sorter.addStreamsFrom(b.handler)
				sorter.__topObject__ = top
				if this.__sortedBubbles__	// could have been cleared on previous iteration 
					this.__sortedBubbles__.push(top)
				sorter.sortAndEvaluateAt(top.preferredTimeFrom(time))
				this.__layoutDeps__.addAll(sorter.layoutDep)
	else
		var firstTime = true
		for bubble in this.__sortedBubbles__
			if bubble.topContainer() == this.window && (firstTime || bubble !!== this.hand)
				firstTime = false
				bubble.__sorter__.evaluateAt(bubble.preferredTimeFrom(time))
				this.__layoutDeps__.addAll(bubble.__sorter__.layoutDep)! !

!KSWorldState methodsFor: 'events' stamp: 'yo 8/28/2012 19:39'!
asClickEvent = (anEvent) ->
	var ev = KSUserEvent.newFrom(anEvent)
	ev.event = "click"
	ev.handler = nil
	return ev! !

!KSWorldState methodsFor: 'events' stamp: 'yo 8/28/2012 19:39'!
asDoubleClickEvent = (anEvent) ->
	var ev = KSUserEvent.newFrom(anEvent)
	ev.event = "doubleClick"
	ev.handler = nil
	return ev! !

!KSWorldState methodsFor: 'events' stamp: 'ael 3/21/2013 12:16'!
postProcess = (anEvent) ->
	var hand = @hand
	var default
	if anEvent.event == "buttonDown"
		// A buttonDown that no box wanted to handle in an application-specific way is passed to the event's default handler, if any was registered.  The standard defaultActionWith() responds to control-buttonDown, priming the receiver to grab the halo if the corresponding control-click appears.
		if !!anEvent.handler
			if (default = anEvent.defaultHandler)
				default.defaultActionWith(anEvent)
			hand.keyboardFocus(nil)				// NB: this logic might not be enough
		// lastButtonDown records the handler or defaultHandler, if either is defined
		hand.lastButtonDown.set(default ? anEvent.handler)
		hand.maybeResetLastClicked(anEvent)

	if anEvent.event == "buttonUp"
		var lastDownHandler = hand.lastButtonDown.currentValue()
		if lastDownHandler
			if lastDownHandler == anEvent.handler
				// same box is handler for down and up, so send a "click"
				lastDownHandler.receive(this.asClickEvent(anEvent))
				if hand.isDoubleClick(anEvent, lastDownHandler)
					lastDownHandler.receive(this.asDoubleClickEvent(anEvent))
				hand.lastClicked(anEvent, lastDownHandler)
			else
				// doesn't count as a click (because a different box - or no box - wants to handle it)
				hand.lastClicked(anEvent, nil)
			// In addition: if the default handler for this buttonUp is also the handler of the preceding buttonDown, maybe do the default action (used for halo).
			if lastDownHandler == anEvent.defaultHandler
				lastDownHandler.defaultActionWith(this.asClickEvent(anEvent))
		hand.lastButtonDown.set(nil)
		hand[anEvent.event].set(anEvent)! !

!KSWorldState methodsFor: 'events' stamp: 'yo 8/28/2012 19:37'!
preProcess = (anEvent) ->
	if anEvent.event == "pointerMotion"
		var ev = KSUserEvent.newFrom(anEvent)
		ev.event = "motionQuery"
		this.window.announceInCollections(ev)
		var ks = {box: ev.handler, event: anEvent}
		this.hand.lastEntered(ks)! !

!KSWorldState methodsFor: 'events' stamp: 'yo 8/28/2012 22:33'!
processActions = () ->
	var didSomething = true
	var nowRealTime = Time.millisecondClockValue()
	var elapsed = Time._milliseconds_since(nowRealTime, this.lastRealTime)
	var now = this.alarmTime + elapsed
	var alarms = this.alarms
	while alarms.size() > 0
		var ev = alarms.removeFirst()[0]
		ev.time = now
		this.window.receive(ev)
	this.evaluateTimeBubblesAt(now)
	this.alarmTime = now
	this.lastRealTime = nowRealTime
	return true! !

!KSWorldState methodsFor: 'events' stamp: 'yo 9/10/2013 11:04'!
processActionsAgain = () ->
	this.dependencyEvaluatorClass().new().justEvaluate(this.__layoutDeps__, this.ksCurrentTime())
	var v = @window.haloTarget
	if v && !!v.topContainer() && @haloVisible
		this.deleteHalo()
	if v && v.topContainer()
		this.window.updateHalo(v)! !

!KSWorldState methodsFor: 'events' stamp: 'yo 7/24/2012 14:33'!
queueEvent = (evt) ->
	this.alarms.push([evt, this.alarmTime])! !

!KSWorldState methodsFor: 'halo and menu' stamp: 'yo 1/10/2013 21:41'!
deleteHalo = () ->
	this.window.halo.deleteGradientTool()
	this.window.haloTarget.set(nil)! !

!KSWorldState methodsFor: 'halo and menu' stamp: 'yo 8/29/2012 16:09'!
deleteMenu = () ->
	if @menu 
		@menu._delete()
	this.hand.focus(nil)
	this.menu = nil! !

!KSWorldState methodsFor: 'halo and menu' stamp: 'yo 8/29/2012 15:17'!
menu = (aBox) ->
	this.deleteMenu()
	this.menu = aBox! !

!KSWorldState methodsFor: 'halo and menu' stamp: 'yo 2/8/2013 18:30'!
transferHalo = () ->
	if !!@window.haloTarget
		return
	if @window.haloTarget.container()
		this.window.haloTarget.set(@window.haloTarget.container())! !

!KSWorldState methodsFor: 'initialization' stamp: 'ael 4/1/2013 19:40'!
initialize = () ->
	super.initialize()
	this.alarms = []
	this.lastRealTime = this.startUpTime = Time.millisecondClockValue()
	this.alarmTime = 0
	this.hand = KSBox.new().beHand()
	this.hand.shape.set(KSShape._extent_fill(P(0, 0), Color.black()))
	this.hand.setTimeBubble(true)

	var fillSamples = []
	fillSamples.addAll((c.asGeziraFill() for c in Color.wheel(8)))
	fillSamples.add(Color.white().asGeziraFill())
	fillSamples.add(Color.black().asGeziraFill())
	this.fillSamples = this.streamOf(fillSamples)

	this.clearSortedBubbles()
	return this! !

!KSWorldState methodsFor: 'initialization' stamp: 'yo 8/29/2012 15:18'!
window = (aBox) ->
	this.window = aBox! !

!KSWorldState methodsFor: 'samples' stamp: 'ael 4/1/2013 20:05'!
addFillToSamples = (fill) ->
	// keep track of up to 10 uniform fills and 10 others
	var newIsUniform = fill.isUniform()
	var sameType = (f for f in @fillSamples when f.isUniform() == newIsUniform)
	if sameType.last() !!= fill
		var samples = @fillSamples.copy()		// we're going to set a new value, so dependants notice
		if sameType.size() == 10
			samples.remove(sameType.first())
		samples.push(fill)
		this.fillSamples.set(samples)! !

!KSWorldState methodsFor: 'samples' stamp: 'ael 4/1/2013 20:05'!
uniformFillSamples = () ->
	return (f for f in @fillSamples when f.isUniform())! !

!KSWorldState methodsFor: 'twinkling' stamp: 'yo 9/10/2013 15:46'!
twinkle = (twinkler) ->
	if twinkler.asBoolean()
		if !!this.twinkler
			this.twinkler = KSTwinkleMap.new()
			this.twinkler.lock()
			this.twinkler.extent(this.window.hostingMorph().extent())
			ActiveWorld.addMorphFront(this.twinkler)
			this.twinkler.position(this.window.hostingMorph().position())
		this.twinkler.createMap(this.window)
		KSNewEventStream.twinkle()
	else
		if this.twinkler
			this.twinkler.delete()
		this.twinkler = null
		KSNewEventStream.unTwinkle()

	this.clearSortedBubbles()! !

!KSWorldState methodsFor: 'twinkling' stamp: 'yo 9/10/2013 15:42'!
twinkler = () ->
	return this.twinkler! !
