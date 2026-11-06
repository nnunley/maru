KSUserEventHandler subclass: #KSUIPartsAnimator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSUIPartsAnimator methodsFor: 'as yet unclassified' stamp: 'yo 5/8/2012 14:18'!
start  = () ->
	this.timer = $$(timerE(50))
	this.duration = 2000
	this.elapsed = $$(0 fby @elapsed + this.timer.interval at @timer)
	this.stopTimer = $$(@elapsed.mapE((e) ->
		if e >= @duration
			this.timer = undefined))

	this.func = (et, tt, sp, ep, sr, er) ->
		var ay = (sp._y() - ep._y()) * 2.0 / (tt * tt)
		var px = ep._x() + (sp._x() - ep._x()) * (tt - et) / tt
		{position: P(px, ep._y() + (0.5 * ay * (tt - et) * (tt - et))), rotation: sr + (er - sr) * et / tt}

//	this.step = $$(@elapsed.mapE((t) ->
//		for b in this.whole._contents()
//			var val = this.func(t, @duration, b.handler().startPosition, b.handler().endPosition, b.handler().startRotation, 0.0)
//			b._center(val.position)
//			b._rotation(val.rotation)))

	this.step = $$(@elapsed.mapE((t) ->
		var bnds = this.whole._hostingMorph()._bounds()
		var rect = P(0, 0)._corner(bnds._extent())
		var c = BalloonCanvas._on(Display)._copyOrigin_clipRect(bnds._topLeft(), bnds)
		c._transform(MatrixTransform2x3._withOffset(bnds._topLeft())) //work around BCanvas bug
		Display._deferUpdates(true)
		c._fillRectangle_color(rect, Color._gray())
		for ind in [this.whole._contents()._size() ... 1] by -1
			var b = this.whole._contents()._at(ind)
			var val = this.func(t, @duration, b.handler().startPosition, b.handler().endPosition, b.handler().startRotation, 0.0)
			this._drawBox_at_radian_on(b, val.position, val.rotation, c)
		Display._deferUpdates(false)
		Display._forceToScreen(bnds)
		))

	for box in this.whole._contents()
		var rot = 628._atRandom() / 100.0
		var pos = P(this.whole._width()._asInteger()._atRandom(), this.whole._height() - (30._atRandom()))
		box.handler().startRotation = rot - Float._pi()
		box.handler().startPosition = pos
		box._center(pos)
		box._rotation(rot)! !
