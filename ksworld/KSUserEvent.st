KSObject subclass: #KSUserEvent
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSUserEvent methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/8/2013 16:40'!
ppWriteValue = () ->
	return null! !

!KSUserEvent methodsFor: 'all' stamp: 'yo 10/6/2012 00:09'!
addKeyStroke = (anEvent) ->
	this.keyValues.push(anEvent.keyValue)! !

!KSUserEvent methodsFor: 'all' stamp: 'yo 1/8/2013 16:40'!
controlKeyPressed = () ->
	return this.buttons.anyMask(16)! !

!KSUserEvent methodsFor: 'all' stamp: 'yo 2/8/2013 18:32'!
shiftKeyPressed = () ->
	return this.buttons.anyMask(8)! !
