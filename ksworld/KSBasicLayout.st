KSLayout subclass: #KSBasicLayout
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSBasicLayout methodsFor: 'all' stamp: 'yo 8/30/2012 13:21'!
initialize = () ->
	super.initialize()
	this.wrap = false
	this.inset(0)
	return this! !

!KSBasicLayout methodsFor: 'all' stamp: 'yo 7/26/2012 21:46'!
inset = (aPointOrNumber) ->
	if aPointOrNumber.isNumber()
		this.leftMargin = this.topMargin = this.bottomMargin = this.rightMargin = aPointOrNumber
	if  aPointOrNumber.isPoint()
		this.leftMargin = this.rightMargin = aPointOrNumber.x()
		this.topMargin = this.bottomMargin = aPointOrNumber.y()
	if aPointOrNumber.isRectangle()
		this.leftMargin = aPointOrNumber.origin().x()
		this.rightMargin = aPointOrNumber.corner().x()
		this.topMargin = aPointOrNumber.origin().y()
		this.bottomMargin = aPointOrNumber.corner().y()! !

!KSBasicLayout methodsFor: 'all' stamp: 'yo 7/26/2012 21:49'!
justification = (aSymbolOrNil) ->
	this.justification = aSymbolOrNil! !

!KSBasicLayout methodsFor: 'all' stamp: 'yo 7/27/2012 10:30'!
layOut = (aBox) ->
	if this.wrap
		this.wrapLayOut(aBox)
	else
		if this.naturalLength
			this.glueLayOut(aBox)
		else
			this.basicLayOut(aBox)! !

!KSBasicLayout methodsFor: 'all' stamp: 'yo 7/27/2012 00:45'!
layoutChildrenFirst = () ->
	return !!this.wrap && !!this.naturalLength! !

!KSBasicLayout methodsFor: 'all' stamp: 'yo 11/2/2012 14:57'!
space = (aNumberOrPoint) ->
	this.space = aNumberOrPoint! !
