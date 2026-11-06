Notification subclass: #KSTwinkleRequest
	instanceVariableNames: 'src dst'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSTwinkleRequest methodsFor: 'as yet unclassified' stamp: 'yo 9/10/2013 11:15'!
dst
	^ dst! !

!KSTwinkleRequest methodsFor: 'as yet unclassified' stamp: 'yo 9/10/2013 11:15'!
dst: anObject
	dst := anObject! !

!KSTwinkleRequest methodsFor: 'as yet unclassified' stamp: 'yo 9/10/2013 11:15'!
src
	^ src! !

!KSTwinkleRequest methodsFor: 'as yet unclassified' stamp: 'yo 9/10/2013 11:15'!
src: anObject
	src := anObject! !

!KSTwinkleRequest class methodsFor: 'as yet unclassified' stamp: 'yo 9/10/2013 11:15'!
src: src dst: dst
	^ self new src: src; dst: dst! !
