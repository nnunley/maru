KSUserEventHandler subclass: #KSSoSaruGame
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSSoSaruGame methodsFor: 'all' stamp: 'bf 1/17/2013 16:40'!
bezelShape
	^ KSShape new elements: {
		(GeziraPath rect: (10@10 corner: 180@180) radius: 0) fill: Color white; stroke: (GeziraStroke width: 20)}.! !

!KSSoSaruGame methodsFor: 'all' stamp: 'bf 1/17/2013 16:39'!
headShape
	^ KSShape new elements: {
		(GeziraPath oval: (0@0 corner: 50@50)) fill: Color green}.! !

!KSSoSaruGame methodsFor: 'all' stamp: 'yo 1/24/2013 10:45'!
init = () ->
	this.whole.fill(Color.gray())
	this.whole.borderWidth(0)
	this.whole.borderFill(Color.white())
	this.whole.extent(P(190, 190))
	var s = KSBox.withShape(this.bezelShape())
	s.center(this.whole.extent()/2)
	this.whole.addAsBackgroundParts(s)

	this.label = this.whole.factory().newLabel("clicks: 0")
	this.whole.addAsParts(this.label)
	this.label.bottomLeft(this.whole.bottomLeft())

	this.boxes = []
	for pos in [0 .. 9]
		var box = KSBox._extent_fill(P(50, 50), Color.transparent())
		box.beFlippingButton(this.headShape(), this.tailShape(), [true, false].atRandom(), 500)
		box.flip = undefined
		box.pos = pos
		this.whole.add(box)
		box.topLeft(P((pos % 3).asInteger() * 50 + 20, (pos / 3).asInteger() * 50 + 20))
		this.boxes.push(box)

	this.flipMap = [
		[0, 1, 3],		[0, 1, 2, 4],		[1, 2, 5],
		[0, 3, 4, 6],	[1, 3, 4, 5, 7],		[2, 4, 5, 8],
		[3, 6, 7],		[4, 6, 7, 8],		[5, 7, 8]]

	this.countGreen = () -> (b for b in this.boxes when b.selected.currentValue() ).size().asString()
	this.goal = this.whole.factory().newLabel("green: ".concat(this.countGreen()))
	this.whole.addAsParts(this.goal)
	this.goal.bottomRight(this.whole.bottomRight())

	this.clicks = $$(0 fby @clicks + 1 on @flipThem)
	this.flipThem = $$(switchColE(@boxes, "fire").mapE((x) ->
		for other in this.flipMap[x.handler.pos]
			this.boxes[other].startFlipping()
	))

	this.updateLabel = $$(@clicks.mapE((x) -> this.label.textContents("clicks: ".concat(x.asString()))))
	this.updateGoal = $$(@clicks.doE(() ->
		this.goal.textContents("green: ".concat(this.countGreen()))
		this.goal.bottomRight(this.whole.bottomRight())))
	return this.boxes! !

!KSSoSaruGame methodsFor: 'all' stamp: 'bf 1/17/2013 16:39'!
tailShape
	^ KSShape new elements: {
		(GeziraPath oval: (0@0 corner: 50@50)) fill: Color red}.! !

!KSSoSaruGame class methodsFor: 'entry points' stamp: 'yo 9/4/2012 14:17'!
start
"
	SoSaruGame start
"
	| a w b |
	w := KSMorph new openInWorld extent: 190@190.
	w window add: (a := KSBox new).
	b := self new.
	a at: #handler put: b.
	b at: #whole put: a.
	b init.
	^ a! !
