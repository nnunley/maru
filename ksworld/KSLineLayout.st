KSLayout subclass: #KSLineLayout
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSLineLayout methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/7/2013 00:34'!
ppSerializer = () ->
	return this! !

!KSLineLayout methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/17/2013 15:53'!
ppWriteElements: sexp context: dictionary
	sexp addElement: (PPElement head: #data elements: (PPTextExporter new export: (self at: #whole) contents with: dictionary)).! !

!KSLineLayout methodsFor: 'accessing' stamp: 'yo 10/9/2012 14:10'!
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
		this.bottomMargin = aPointOrNumber.corner().y()
	if @whole
		@whole.layoutChanged()! !

!KSLineLayout methodsFor: 'accessing' stamp: 'yo 1/8/2013 16:33'!
isCenterJustified = () ->
	return @justification && @justification.beginsWith("center")! !

!KSLineLayout methodsFor: 'accessing' stamp: 'yo 1/8/2013 16:33'!
isLeftJustified = () ->
	return @justification && @justification.beginsWith("left")! !

!KSLineLayout methodsFor: 'accessing' stamp: 'yo 1/8/2013 16:34'!
isRightJustified = () ->
	return @justification && @justification.beginsWith("right")! !

!KSLineLayout methodsFor: 'collection compatibility' stamp: 'yo 9/4/2012 23:44'!
addAll = (stringOrArray) ->
	//Store the string of text (or array of Boxes) into my field, appending at the end.  Ignore the selection.  Set selection to the end.
	for cc in stringOrArray
		if cc.isCharacter()
			this.insertChar(cc)
		else
			@whole.addLast(cc)! !

!KSLineLayout methodsFor: 'initialization' stamp: 'yo 2/8/2013 10:33'!
initialize = () ->
	super.initialize()
	this.isTextLayout = true
	this.font = KSFont.defaultFont()
	this.inset(P(2, 2))
	this.selection = this.streamOf(0.to(1))! !

!KSLineLayout methodsFor: 'initialization' stamp: 'yo 8/29/2012 18:26'!
layOut = (aBox) ->
	this.layout(aBox)! !

!KSLineLayout methodsFor: 'rule actions' stamp: 'yo 8/30/2012 15:03'!
adjustJustification = (aBox) ->
	if aBox.contentsSize() > 0
		if @justification
			this.justify(aBox)
		else
			aBox.width(aBox.last().right() + @rightMargin)
		aBox.height(@font.height() + @topMargin + @bottomMargin)! !

!KSLineLayout methodsFor: 'rule actions' stamp: 'yo 10/5/2012 16:00'!
insertChar = (char) ->
	// General way to insert a character.
	@whole.insertChar(char)! !

!KSLineLayout methodsFor: 'rule actions' stamp: 'yo 2/18/2013 13:33'!
justify = (aBox) ->
	if this.isLeftJustified()
		return
	var w = aBox.last().right() - aBox.first().left()
	var l = aBox.width() - @leftMargin - @rightMargin
	if this.isCenterJustified()
		var r = (l - w) / 2.0
	if this.isRightJustified()
		r = l - w - @rightMargin
	for e in aBox.contents()
		e.translateByInOwner(P(r, 0))! !

!KSLineLayout methodsFor: 'rule actions' stamp: 'tk 1/30/2013 14:47'!
layout = (aBox) ->
	if aBox.contentsSize() > 0
		var prev = aBox.first()
		prev.pivotPosition(P(aBox.leftAtY(0), prev.ascent()) + P(@leftMargin, @topMargin))
		var aLetter = prev.successor()
		while aLetter
			var next = this.place(aLetter, prev)
			prev = aLetter
			aLetter = next
	this.adjustJustification(aBox)! !

!KSLineLayout methodsFor: 'rule actions' stamp: 'yo 8/30/2012 16:56'!
place = (box, pred) ->
	// don't do word wrap, but do allow large fonts and tabs
	box.pivotPosition(pred.pivotPosition() + P(pred.bounds().width(), 0))
	return box.successor()
	//"next to place"! !
