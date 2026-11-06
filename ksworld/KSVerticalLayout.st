KSBasicLayout subclass: #KSVerticalLayout
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSVerticalLayout methodsFor: 'all' stamp: 'ael 1/31/2013 14:42'!
basicLayOut = (aBox) ->
	if aBox.contentsSize() == 0
		return
	var y = this.topMargin
	var x
	var w = aBox.contents._inject_into(0, (ww, b) -> ww.max(b.bounds().width()))
	w = w + this.leftMargin + this.rightMargin
	var s
	if this.space
		s = if this.space.isPoint() then this.space.y() else this.space
	else
		s = 0

	var selector
	if this.justification == "center"
		selector = #"topCenter:"
		x = w / 2.0
	else
		if this.justification == "right"
			selector = #"topRight:"
			x = w - this.rightMargin
		else
			selector = #"topLeft:"
			x = this.leftMargin

	(if this.ignoreInvisibles then aBox.contents().select((b) -> b.visible.currentValue()) else aBox.contents())._do_separatedBy((box) ->
		box._perform_with(selector, P(x, y))
		y = y + box.bounds().height(),
		() -> y = y + s)

	var h = y + this.bottomMargin
	if this.naturalLength
		h = this.naturalLength
	aBox.width(w)
	aBox.height(h)! !

!KSVerticalLayout methodsFor: 'all' stamp: 'yo 1/24/2013 13:43'!
glueLayOut = (aBox) ->
	if aBox.contentsSize() == 0
		return
	var hSelector = #"height"
	var boxContents = aBox.contents
	var x = this.leftMargin
	var y = this.topMargin
	var w = 0
	var totalShrink = 0
	var totalNaturalLength = 0
	var totalStretch = 0
	var shrinks = []
	var stretches = []
	var s
	for i in [0 .. boxContents.size()]
		var box = boxContents[i]
		w = w.max(box.bounds().width())
		shrinks.push(s = box.glueShrink.currentValue())
		totalShrink = totalShrink + s
		totalNaturalLength = totalNaturalLength + box.lengthIn(hSelector)
		stretches.push(s = box.gluStretch.currentValue())
		totalStretch = totalStretch + s
	w = w + this.leftMargin + this.rightMargin
	var selector
	var x
	if this.justification == "center"
		selector = #"topCenter:"
	else
		if this.justification == "right"
			selector = #"topRight:"
		else
			selector = #"topLeft:"
	if this.justification == "center"
		x = w / 2.0
	else
		if this.justification == "right"
			x = w - this.rightMargin
		else
			x = this.leftMargin

	var h = this.naturalLength - (this.topMargin + this.bottomMargin)

	var diff = h -  totalNaturalLength
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
		box.height(box.lengthIn(hSelector) + diffs[i])
		y = y + box.height()
	aBox.extent(P(w, this.naturalLength))! !

!KSVerticalLayout methodsFor: 'all' stamp: 'yo 1/24/2013 13:42'!
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
	var h = aBox.height() - this.bottomMargin
	var max = 0
	var w = 0
	var b
	var selector
	var remember
	var setCurrentLine
	if this.justification == "center"
		selector = #"topCenter:"
		b = () ->
			cx + (max / 2.0)
	else
		if this.justification == "right"
			selector = #"topRight:"
			b = () ->
				cx + max
		else
			selector = #"topLeft:"
			b = () ->
				cx

	remember = (box) ->
		max = max.max(box.bounds().width())
		currentLine.push([box, cy])
		cy = cy + box.bounds().height() + sy

	setCurrentLine = () ->
		w = max
		var base = b.value()
		for each in currentLine
			each[0]._perform_with(selector, P(base, each[1]))

	for box in aBox.contents()
		var bounds = box.bounds()
		if cy + bounds.height() > h
			cy = this.topMargin
			if currentLine.size() == 0
				w = bounds.width()
				box._perform_with(selector, P(b.value(), cy))
				cx = cx + w + sx
			else
				setCurrentLine.value()
				cx = cx + w + sx
				currentLine = []
				remember.value(box)
		else
			remember.value(box)
	if currentLine.size() > 0
		setCurrentLine.value()
	aBox.width(cx + w + this.rightMargin)! !
