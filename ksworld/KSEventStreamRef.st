Object subclass: #KSEventStreamRef
	instanceVariableNames: 'ref isSubExpression last'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects'!

!KSEventStreamRef commentStamp: 'yo 3/14/2013 10:24' prior: 0!
A KSEventStreamRef is an internal data holding the name of the dependency.  Basically a @-variable in KScript will be translated to this, and @-variable with prime will have an instance of this class with the "last" variable set.!

!KSEventStreamRef methodsFor: 'accessing' stamp: 'yo 7/10/2012 10:40'!
isSubExpression
	^ isSubExpression! !

!KSEventStreamRef methodsFor: 'accessing' stamp: 'yo 5/8/2012 15:29'!
last
	^ last! !

!KSEventStreamRef methodsFor: 'accessing' stamp: 'yo 5/8/2012 15:29'!
last: anObject
	last := anObject! !

!KSEventStreamRef methodsFor: 'accessing' stamp: 'yo 5/8/2012 15:29'!
ref
	^ ref! !

!KSEventStreamRef methodsFor: 'accessing' stamp: 'yo 7/10/2012 10:40'!
ref: anObject
	ref := anObject.
	isSubExpression := anObject beginsWith: 'tt'! !

!KSEventStreamRef methodsFor: 'printing' stamp: 'yo 3/14/2013 10:24'!
printOn: aStream
	aStream
		nextPut: ${;
		nextPutAll: 'ref: ';
		nextPutAll: ref.
	last ifNotNil: [
		aStream
			nextPutAll: ', last: true'].
	aStream nextPut: $}.! !

!KSEventStreamRef methodsFor: 'testing' stamp: 'yo 4/6/2012 09:30'!
isEventStreamRef
	^ true! !

!KSEventStreamRef class methodsFor: 'all' stamp: 'yo 5/8/2012 15:36'!
ksNew: args
	| inst |
	inst := self new.
	args do: [:a |
		a keysAndValuesDo: [:k :v |
			inst perform: (k copyWith: $:) asSymbol with: v]].
	^ inst! !

!KSEventStreamRef class methodsFor: 'all' stamp: 'yo 5/8/2012 15:31'!
ref: arg
	^ self new ref: arg; yourself! !

!KSEventStreamRef class methodsFor: 'all' stamp: 'yo 5/8/2012 15:31'!
refLast: arg
	^ self new ref: arg; last: true; yourself! !
