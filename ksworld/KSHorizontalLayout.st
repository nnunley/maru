KSBasicLayout subclass: #KSHorizontalLayout
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSHorizontalLayout methodsFor: 'all' stamp: 'ael 1/31/2013 14:39'!
basicLayOut = (aBox) ->
	if aBox.contentsSize() == 0
		return
	var x = this.leftMargin
	var y
	var h = aBox.contents._inject_into(0, (hh, b) -> hh.max(b.bounds().height()))
	h = h + this.topMargin + this.bottomMargin
	var s
	if this.space
		s = if this.space.isPoint() then this.space.x() else this.space
	else
		s = 0

	var selector
	if this.justification == "center"
		selector = #"leftCenter:"
		y = h / 2.0
	else
		if this.justification == "bottom"
			selector = #"bottomLeft:"
			y = h - this.bottomMargin
		else
			selector = #"topLeft:"
			y = this.topMargin

	(if this.ignoreInvisibles then aBox.contents().select((b) -> b.visible.currentValue()) else aBox.contents())._do_separatedBy((box) ->
		box._perform_with(selector, P(x, y))
		x = x + box.bounds().width(),
		() -> x = x + s)

	var w = x + this.rightMargin
	if this.naturalLength
		w = this.naturalLength
	aBox.width(w)
	aBox.height(h)! !

!KSHorizontalLayout methodsFor: 'all' stamp: 'yo 1/24/2013 13:25'!
glueLayOut = (aBox) ->
	if aBox.contentsSize() == 0
		return
	var wSelector = #"width"
	var 	boxContents = aBox.contents
	var x = this.leftMargin
	var y = this.topMargin
	var h = 0
	var totalShrink = 0
	var totalNaturalLength = 0
	var totalStretch = 0
	var shrinks = []
	var stretches = []
	var s
	for i in [0 .. boxContents.size()]
		var box = boxContents[i]
		h = h.max(box.bounds().height())
		shrinks.push(s = box.glueShrink.currentValue())
		totalShrink = totalShrink + s
		totalNaturalLength = totalNaturalLength + box.lengthIn(wSelector)
		stretches.push(s = box.gluStretch.currentValue())
		totalStretch = totalStretch + s
	h = h + this.topMargin + this.bottomMargin
	var selector
	var y
	if this.justification == "center"
		selector = #"leftCenter:"
	else
		if this.justification == "bottom"
			selector = #"bottomLeft:"
		else
			selector = #"topLeft:"
	if this.justification == "center"
		y = h / 2.0
	else
		if this.justification == "bottom"
			y = h - this.bottomMargin
		else
			y = this.topMargin

	var w = this.naturalLength - (this.leftMargin + this.rightMargin)

	var diff = w -  totalNaturalLength
	if (diff == 0 || (diff > 0 && totalStretch == 0)) || (diff < 0 && totalShrink == 0)
		var diffs = []
		for ii in [0 .. boxContents.size()]
			diffs.push(0)
	else
		if diff > 0
			diffs = (v.min(diff * v.asFloat() / totalStretch) for v in stretches)
		if diff < 0
			diffs = (v.min(diff * v.asFloat() / totalShrink) for v in shrinks)

	for i in [0 .. boxContents.size()]
		var box = boxContents[i]
		box._perform_with(selector, P(x, y))
		box.width(box.lengthIn(wSelector) + diffs[i])
		x = x + box.width()
	aBox.extent(P(this.naturalLength, h))! !

!KSHorizontalLayout methodsFor: 'all' stamp: 'yo 1/24/2013 13:24'!
wrapLayOut = (aBox) ->
	if aBox.contentsSize == 0
		return
	var sx
	var sy
	if this.space
		if this.space.isPoint()
			sx = this.space.x()
			sy = this.space.y()
		else
			sx = this.space
			sy = this.space
	else
		sx = 0
		sy = 0

	var currentLine = []
	var cx = this.leftMargin
	var cy = this.topMargin
	var w = aBox.width() - this.rightMargin
	var max = 0
	var h = 0
	var b
	var selector
	var remember
	var setCurrentLine
	if this.justification == "center"
		selector = #"leftCenter:"
		b = () ->
			cy + (max / 2.0)
	else
		if this.justification == "bottom"
			selector = #"bottomLeft:"
			b = () ->
				cy + max
		else
			selector = #"topLeft:"
			b = () ->
				cy

	remember = (box) ->
		max = max.max(box.bounds().height())
		currentLine.push([box, cx])
		cx = cx + box.bounds().width() + sx

	setCurrentLine = () ->
		h = max
		var base = b.value()
		for each in currentLine
			each[0]._perform_with(selector, P(each[1], base))

	for box in aBox.contents()
		var bounds = box.bounds()
		if cx + bounds.width() > w
			cx = this.leftMargin
			if currentLine.size() == 0
				h = bounds.height()
				box._perform_with(selector, P(cx, b.value()))
				cy = cy + h + sy
			else
				setCurrentLine.value()
				cy = cy + h + sy
				currentLine = []
				remember.value(box)
		else
			remember.value(box)
	if currentLine.size() > 0
		setCurrentLine.value()
	aBox.height(cy + h + this.bottomMargin)! !
