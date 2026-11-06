KSUserEventHandler subclass: #KSProjectileScene
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:40'!
endTrace = () ->
	this.archiveTraceSteps()
	this.isTracing(false)
	// this.traceDuration(300)! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'ael 5/22/2012 15:44'!
inFlight
	^(self at: #inFlight) == true! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'ael 5/22/2012 22:38'!
inFlight: bool
	self at: #inFlight put: bool ! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:57'!
launch = () ->
	// this._halt()
	var box = (b in this.whole.contents() when b.name == 'projectile')
	if !!box
		box = this.newProjectile()
		this.whole.add(box)
	this.projectile = box
	box.center(P(10.0, 390.0))
	var elevation = (this.substrate.elevation.sliderValue.currentValue() * 90).degreesToRadians()
	var speed = 50
	box.handler.velocity = P(speed * elevation.cos(), 0 - (speed * elevation.sin()))

	this.inFlight(true)! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:57'!
newProjectile = () ->
	var box
	this.evalInTopWorld(() ->
		box = JBox._new()
		box.shape(JShape.oval(P(10.0, 10.0)))
		box.position(P(-20.0,0))		// out of sight until launched
		box.fill(GeziraFill.uniform(Color.blue().muchLighter()))
		box.eventHandler().beDropAcceptor()
		box.handler.drawInWorlds = true
		//box.handler.beGenericMoveHandler()
		box.name("projectile"))

	return box! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:43'!
pause = () ->
	this.isTracing(!!this.isTracing())! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:43'!
replayAndDisplay = () ->
	this.replayTrace()
	this.showHistory(true)
	this.whole.layoutChanged()
	this.whole.topContainer().hostingMorph().privateRedraw()
	// World.displayWorldSafely()
	this.showHistory(false)! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'ael 7/6/2012 15:54'!
setUp = () ->	
	this.setUpButtons()
	this.traceLabel("--")		// make it a 'top tracer'

	// don't start stepping & tracing until the layout has settled down
	this.delayedStart = $$(oneE(true).delayE(1000).mapE((x) ->
		this.startRunning()))	! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:44'!
setUpButtons = () ->
	var specs = [[ "launch", P(10, 10) ]]
	//		[ "pause",	null ]]
	// [ "resume", "same" ]]
	this.buttons = []
	for spec in specs
		var button = JBox.newButton(spec[0])
		button.pivotRatio(P(0.5, 0.5))
		button.fill(Color._white())
		this.whole.add(button)
		if spec[1]
			if spec[1] == "same"
				button.center(this.buttons.last().center())
			else
				button.topLeft(spec[1])
		else
			button.topLeft(this.buttons.last().topRight() + P(20, 0))
		if spec[1] !!= "same"
			this.buttons.push(button)
		this[spec[0]] = button.handler()

	this.fireLaunch = $$(@launch.fire.mapE((x) ->
		this.startTrace()
		this.launch()))
	this.firePause = $$(@pause.fire.mapE((x) -> this.pause()))! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:45'!
solve = () ->
	// Time.millisecondClockValue().asString().displayAt(P(10,640))
	// this.inFlight().asString().displayAt(P(10,620))
	if this.inFlight()
		var p = this.projectile
		var pos = p.center() 
		var wind = this.substrate.wind.sliderValue.currentValue()
		var accel = P(0-wind, 3)
		p.handler.velocity += accel
		var newPos = pos + p.handler.velocity
		p.center(newPos)
		if newPos.y() > (this.whole.extent().y() + 50)
			this.inFlight(false)
			if !!this.isReplaying()
				this.endTrace()! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:46'!
startRunning = () ->	
	this.inFlight(false)

	this.traceDuration(300)
	this.isTracing(true)
	this.stepper = $$(timerE(100).mapE((x) -> this.solve()))! !

!KSProjectileScene methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:46'!
startTrace = () ->
	this.traceDuration(nil)! !

!KSProjectileScene class methodsFor: 'as yet unclassified' stamp: 'ael 7/6/2012 15:47'!
example1
	| jj jw extent scene substrate |
	extent := 1000 @ 400.
	jj := JMorph new openInWorld extent: extent.
	jw := jj window.
	jw hostingMorph.				"ask now, just to get the value cached"
"	jw worldState disableCulling."
	jw fill: Color transparent.
	jw add: (substrate := JBox extent: extent fill: Color white).
	substrate name: 'substrate'.
	substrate handlerAs: KSProjectileSubstrate.
	substrate add: (scene := JBox extent: extent fill: Color transparent).
	scene name: 'scene'.
	scene handlerAs: KSProjectileScene.
	scene handler ksAt: #substrate put: substrate handler.
	substrate handler ksAt: #scene put: scene handler.
	substrate handler setUp.
	scene handler setUp.

	^ scene handler! !
