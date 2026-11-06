Error subclass: #KSThrow
	instanceVariableNames: 'value'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSThrow methodsFor: 'accessing' stamp: 'yo 7/6/2012 11:00'!
value
	^ value! !

!KSThrow methodsFor: 'accessing' stamp: 'yo 7/6/2012 11:00'!
value: aValue
	value := aValue! !

!KSThrow methodsFor: 'exceptionDescription' stamp: 'yo 4/17/2012 09:57'!
defaultAction
	self halt: value! !
