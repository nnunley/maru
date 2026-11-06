OMeta2 subclass: #KSQuoteAttributor
	instanceVariableNames: 'attributes'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSQuoteAttributor methodsFor: 'as yet unclassified' stamp: 'yo 3/29/2013 11:53'!
hasStream =
	&anything:n
(	{#quotedVar hasStream+} -> [true ifTrue: [attributes at: n put: true. true]]
|	{#call hasStream+} -> [true ifTrue: [attributes at: n put: true. true]]
|	{#send hasStream+} -> [true ifTrue: [attributes at: n put: true. true]]
|	~(anything:x ?[x isString or: [x isSymbol]]) {hasStream+:xs}	-> [(xs reduce: [:a :b | a | b]) ifTrue: [attributes at: n put: true. true] ifFalse: [false]]
|	anything													-> [false]
)! !

!KSQuoteAttributor methodsFor: 'as yet unclassified' stamp: 'yo 8/8/2012 18:25'!
start =
	[attributes := IdentityDictionary new]
	hasStream
	[attributes]! !
