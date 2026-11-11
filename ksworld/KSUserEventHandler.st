KSObject subclass: #KSUserEventHandler
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects'!

!KSUserEventHandler methodsFor: 'squeak compatibility' stamp: 'yo 9/3/2013 14:30'!
ksAt: key put: anObject
	anObject isEventStream ifTrue: [
		((anObject keys reject: [:k | (k at: 1) = $_]) select: [:k |
			| v |
			v := anObject at: k.
			v isEventStream and: [v isLayoutChangedDependents]]) size > 0 ifTrue: [
				(self at: #'__layoutDep__' ifAbsentPut: [KSObject new]) at: anObject put: anObject].	
		anObject type == #setter ifTrue: [anObject name: key].
		(self ksAt: #whole) asBoolean ifTrue: [
			(self ksAt: #whole) worldState asBoolean ifTrue: [
				(self ksAt: #whole) worldState clearSortedBubbles]].
	anObject isBox ifTrue: [
		anObject worldState asBoolean ifTrue: [
			self worldState clearSortedBubbles]]].
	^ super ksAt: key put: anObject! !
