KSHorizontalLayout subclass: #KSHorizontalHidingLayout
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSHorizontalHidingLayout methodsFor: 'as yet unclassified' stamp: 'ael 1/31/2013 02:15'!
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

	var firstTime = true
	for box in (aBox.contents().select((b) -> b.visible.currentValue()))
		box._perform_with(selector, P(x, y))
		x = x + box.bounds().width() + s

	x = x - s	// remove the last space

	var w = x + this.rightMargin
	if !!firstTime
		w = w - s
	if this.naturalLength
		w = this.naturalLength
	aBox.width(w)
	aBox.height(h)! !
