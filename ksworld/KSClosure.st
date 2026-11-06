Object subclass: #KSClosure
	instanceVariableNames: 'closure source this'
	classVariableNames: 'Closures'
	poolDictionaries: ''
	category: 'KScript'!

!KSClosure methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/20/2012 09:59'!
ppContentsInto: newElem context: dictionary
	newElem attributeAt: #source put: source.
	newElem addElement: (this ppMakeSlotNamed: 'this' context: dictionary).! !

!KSClosure methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/21/2013 23:46'!
ppInitializeFrom: sexp from: from to: to
	this := to fromPPSexp: sexp elements first from: from to: to.
	source := sexp attributeAt: #source.
	closure := (this evalSqueakString: (to codeForDefinition: source)) closure.! !

!KSClosure methodsFor: 'accessing' stamp: 'yo 9/19/2012 11:40'!
closure
	^ closure! !

!KSClosure methodsFor: 'accessing' stamp: 'yo 1/21/2013 23:47'!
closure: cl source: aString this: t
	"| myClosure |
	myClosure := Closures at: aString ifAbsentPut: [cl]."
	closure := cl.
	source := aString.
	this := t.! !

!KSClosure methodsFor: 'accessing' stamp: 'ael 1/9/2013 14:30'!
source
	^source! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 9/20/2012 00:12'!
decompile
	^ closure decompile! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:47'!
ensure: aBlock
	^ [closure value: this] ensure: aBlock! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 9/18/2012 21:21'!
isBlock
	^ true! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:10'!
ksValueWithEnoughArguments: arguments
	^ closure valueWithEnoughArguments: arguments! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:01'!
value
	^ closure value: this! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:01'!
value: firstArg
	^ closure value: this value: firstArg! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:39'!
value: firstArg value: secondArg
	^ closure value: this value: firstArg value: secondArg! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:01'!
value: firstArg value: secondArg value: thirdArg
	^ closure value: this value: firstArg value: secondArg value: thirdArg! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:46'!
value: firstArg value: secondArg value: thirdArg value: fourthArg
	^ closure valueWithArguments: {this. firstArg. secondArg. thirdArg. fourthArg}.! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:02'!
valueWithArguments: anArray
	^ closure valueWithArguments: {this}, anArray! !

!KSClosure methodsFor: 'closure compatibility' stamp: 'yo 1/21/2013 22:02'!
valueWithEnoughArguments: arguments
	^ closure valueWithEnoughArguments: {this}, arguments! !

!KSClosure methodsFor: 'printing' stamp: 'ael 1/9/2013 14:23'!
printOn: aStream
	aStream nextPutAll: '[KSClosure] in '.
	closure outerContext printOn: aStream! !

!KSClosure class methodsFor: 'initialization' stamp: 'yo 1/21/2013 23:39'!
initialize
"
KSClosure initialize
"
	self reset.! !

!KSClosure class methodsFor: 'instance creation' stamp: 'yo 1/21/2013 23:47'!
closure: closure source: aString this: this
	^ self new closure: closure source: aString this: this! !

!KSClosure class methodsFor: 'resetting' stamp: 'yo 1/21/2013 23:07'!
reset
	Closures := Dictionary new.! !
