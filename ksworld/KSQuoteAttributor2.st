OMeta2 subclass: #KSQuoteAttributor2
	instanceVariableNames: 'attributes'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSQuoteAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 4/12/2013 20:45'!
hasStream =
	{#call anything {#var '$$' anything} hasStreamInner}		-> [false]
|	&(anything:x ?[x isCollection and: [x isString not]]) {hasStream+}	-> [false]
|	anything													-> [false]! !

!KSQuoteAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 4/12/2013 20:45'!
hasStreamInner =
	&anything:n
(	{#call hasStreamInner+} -> [true ifTrue: [attributes at: n put: true. true]]
|	{#send hasStreamInner+} -> [true ifTrue: [attributes at: n put: true. true]]
|	{#fieldRef anything:src anything:first anything*} -> [true ifTrue: [attributes at: n put: true. true]]
|	&(anything:x ?[x isCollection and: [x isString not]]) {hasStreamInner+:xs}
		-> [(xs reduce: [:a :b | a | b]) ifTrue: [attributes at: n put: true. true] ifFalse: [false]]
|	anything													-> [false]
)! !

!KSQuoteAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 4/12/2013 20:32'!
start =
	[attributes := IdentityDictionary new]
	hasStream
	[attributes]! !
