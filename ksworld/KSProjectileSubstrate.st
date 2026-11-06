KSUserEventHandler subclass: #KSProjectileSubstrate
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSProjectileSubstrate methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:53'!
elevationChanged = (elev) ->
	var tracer = this.scene
	if tracer.stepper
		// don't do any special processing before the stepper has started		
		tracer.replayAndDisplay()! !

!KSProjectileSubstrate methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:55'!
setUp = () ->	
	this.elevation = JBox.newSliderExtent(P(16, 200)).handler
	var eBox = this.elevation.whole
	eBox._fill(Color.veryLightGray().asGeziraFill())
	this.whole.add(eBox)
	eBox.rotateBy(0 - Float.pi() / 2)
	this.elevation.knob.shape(JGenericShape._new().elements([GeziraFilledPath.polygon([
		P(0, 0), P(0, 16), P(10, 8), P(30, 8),
		P(10, 8), P(0, 0)].asArray())].asArray()).fill(Color._white()))
	eBox.borderWidth(0)
	eBox.topLeft(P(10, 40))
	this.elevation.jumpOnButtonDown = true
	this.elevation.advanceInPage = false
	this.elevation.max = P(0, 200)
	this.elevation.min = P(0, 0)
	this.elevation.setSliderCurrentValue(0.9)		// high flight so we record a lot of steps
	this.elevationWatcher = $$(@elevation.sliderValue.mapE((c) -> this.elevationChanged(c)))

	this.wind = JBox.newSliderExtent(P(16, 200)).handler
	var wBox = this.wind.whole
	wBox.fill(Color.veryLightGray().asGeziraFill())
	this.whole.add(wBox)
	wBox.rotateBy(0 - Float.pi() / 2)
	this.wind.knob.shape(JGenericShape._new().elements([GeziraFilledPath.polygon([
		P(0, 0), P(0, 16), P(10, 8), P(30, 8),
		P(10, 8), P(0, 0)].asArray())].asArray()).fill(Color.white()))
	wBox._borderWidth(0)
	wBox._topLeft(P(10, 64))
	this.wind.jumpOnButtonDown = true
	this.wind.advanceInPage = false
	this.wind.max = P(0, 200)
	this.wind.min = P(0, 0)
	this.wind.setSliderCurrentValue(0)
	this.windWatcher = $$(@wind.sliderValue.mapE((c) -> this.windChanged(c)))! !

!KSProjectileSubstrate methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 19:55'!
windChanged = (elev) ->
	var tracer = this.scene
	if tracer.stepper
		// don't do any special processing before the stepper has started
		tracer.replayAndDisplay()! !
