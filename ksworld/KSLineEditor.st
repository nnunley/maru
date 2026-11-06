KSLayout subclass: #KSLineEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSLineEditor methodsFor: 'accessing' stamp: 'yo 8/29/2012 18:23'!
inset = (aPointOrNumber) ->
	if aPointOrNumber.isNumber()
		this.leftMargin = this.topMargin = this.bottomMargin = this.rightMargin = aPointOrNumber
	
	if aPointOrNumber.isPoint()
		this.leftMargin = this.rightMargin = aPointOrNumber.x()
		this.topMargin = this.bottomMargin = aPointOrNumber.y()
	if aPointOrNumber.isRectangle()
		this.leftMargin = aPointOrNumber.origin().x()
		this.rightMargin = aPointOrNumber.corner().x()
		this.topMargin = aPointOrNumber.origin().y()
		this.bottomMargin = aPointOrNumber.corner().y()! !

!KSLineEditor methodsFor: 'collection compatibility' stamp: 'yo 9/4/2012 23:44'!
addAll = (stringOrArray) ->
	//Store the string of text (or array of Boxes) into my field, appending at the end.  Ignore the selection.  Set selection to the end.
	for cc in stringOrArray
		if cc.isCharacter()
			this.insertChar(cc)
		else
			@whole.addLast(cc)! !

!KSLineEditor methodsFor: 'initialization' stamp: 'yo 8/29/2012 18:26'!
layOut = (aBox) ->
	this.layout(aBox)! !

!KSLineEditor methodsFor: 'rule actions' stamp: 'yo 8/30/2012 15:03'!
adjustJustification = (aBox) ->
	if aBox.contentsSize() > 0
		if @justification
			this.justify(aBox)
		else
			aBox.width(aBox.last().right() + @rightMargin)
		aBox.height(@font.height() + @topMargin + @bottomMargin)! !

!KSLineEditor methodsFor: 'rule actions' stamp: 'yo 9/4/2012 15:10'!
insertChar = (char) ->
	// General way to insert a character.  To act on a control character instead, define a message with name charTypedX. i.e. charTypedControlBS
	@whole.addAfterIndex(KSBox._withChar_inFont(char, @font), @whole.contentsSize()-1)! !

!KSLineEditor methodsFor: 'rule actions' stamp: 'yo 8/29/2012 17:52'!
justify = (aBox) ->
	if this.isLeftJustified()
		return

	var w = aBox.last().right() - aBox.first().last()
	var l = aBox.width() - @leftMargin - @rightMargin
	if this.isCenterJustified()
		var r = (l - w) / 2.0
	if this.isRightJustified()
		r = l - w - @rightMargin
	aBox.contentsDo((e) ->
		e.translateByInOwner(P(r, 0)))! !

!KSLineEditor methodsFor: 'rule actions' stamp: 'yo 8/30/2012 15:04'!
layout = (aBox) ->
	if aBox.contentsSize() > 0
		var prev = aBox.first()
		prev.pivotPosition(P(aBox.shape().leftAtY(0), prev.ascent()) + P(@leftMargin, @topMargin))
		var aLetter = prev.successor()
		while aLetter
			var next = this.place(aLetter, prev)
			prev = aLetter
			aLetter = next
	this.adjustJustification(aBox)! !

!KSLineEditor methodsFor: 'rule actions' stamp: 'yo 8/30/2012 16:56'!
place = (box, pred) ->
	// don't do word wrap, but do allow large fonts and tabs
	box.pivotPosition(pred.pivotPosition() + P(pred.bounds().width(), 0))
	return box.successor()
	//"next to place"! !
