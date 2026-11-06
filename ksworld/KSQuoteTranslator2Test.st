TestCase subclass: #KSQuoteTranslator2Test
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript-Tests'!

!KSQuoteTranslator2Test methodsFor: 'as yet unclassified' stamp: 'yo 9/6/2013 12:18'!
testAssignment
	| str |
	self triples:
		{
			{str := 'foo <- timerE(100)'.		#start.			'| pvtStrm  | (self ksAssign: #foo with: ((true ifTrue: [pvtStrm := (KSNewEventStream ksNew: {}). (pvtStrm addSubExpression:#tt1 with: (self eventStream:#timerE with: ''timerE(100)'' with: nil with: (OrderedCollection ksNew: {100}))). (pvtStrm finalizeTopLevelCreationWith2:(OrderedCollection ksNew: {}))])))'}.
"'foo.bar := 42'.					#start.			'|  | ((self ksAt: #foo) currentValue ksAssign: #bar with: (42))'}.
			{str := 'var foo
'foo[bar] := 42'.					#start.			'|  | ((self ksAt: #foo) currentValue ksAssign: (self ksAt: #bar asKSKey) currentValue with: (42))'}.

			{str := 'var foo
foo[bar] := 42'.					#start.			'| foo  | (true ifTrue: [foo := KSObject undefined. (foo ksAssign: (self ksAt: #bar asKSKey) currentValue with: (42))])'}."
	}.! !

!KSQuoteTranslator2Test methodsFor: 'support' stamp: 'yo 4/12/2013 11:06'!
triples: triples
	| a b |
	triples do: [:triple |
		a := KSProtoObject compileToString2: triple first forClass: KSProtoObject.
		b := triple third.
		self assert: a = b].
"
a
b
"! !
