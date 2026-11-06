KSObject subclass: #KSLayout
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSLayout methodsFor: 'all' stamp: 'yo 7/26/2012 21:42'!
canInclude = (aBox) ->
	// Return true if this layout can deal with this kind box in its contents
	return true! !

!KSLayout methodsFor: 'all' stamp: 'yo 7/26/2012 21:43'!
layOut = (aBox) ->
	this.subclassResponsibility()! !

!KSLayout methodsFor: 'all' stamp: 'yo 7/27/2012 00:25'!
layoutChildrenFirst = () ->
	return false! !

!KSLayout methodsFor: 'all' stamp: 'yo 1/17/2013 10:14'!
ppSerializer = () ->
	return @whole! !
