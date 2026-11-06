KSFont subclass: #KSFilledFont
	instanceVariableNames: 'baseFont'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSFilledFont methodsFor: 'all' stamp: 'yo 1/8/2013 16:19'!
baseFont
	^ baseFont! !

!KSFilledFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:30'!
fill: aFill
	^ self baseFont fill: aFill.! !

!KSFilledFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:30'!
withBaseFont: aFont fill: aFill
	baseFont := aFont.
	fill := aFill.! !
