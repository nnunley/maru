TestCase subclass: #KSCompiler2Test
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript-Tests'!

!KSCompiler2Test methodsFor: 'as yet unclassified' stamp: 'yo 8/14/2013 20:15'!
testAssignment
	| str |
	self triples:
		{
			{str := ':Foo := 42'.	#start.			'|  | (Foo := 42)'}.
			{str := 
'foo := 42'.						#start.			'|  | (self ksAssign: #foo with: (42))'}.

			{str := 'var foo
foo := 42'.						#start.			'| foo  | (true ifTrue: [foo := KSObject undefined. (foo := 42)])'}.

			{str :=
'foo.bar := 42'.					#start.			'|  | ((self ksAt: #foo) currentValue ksAssign: #bar with: (42))'}.
			{str := 'var foo
foo.bar := 42'.								#start.			'| foo  | (true ifTrue: [foo := KSObject undefined. (foo ksAssign: #bar with: (42))])'}.
			{str :=
'foo[bar] := 42'.					#start.			'|  | ((self ksAt: #foo) currentValue ksAssign: (self ksAt: #bar asKSKey) currentValue with: (42))'}.

			{str := 'var foo
foo[bar] := 42'.					#start.			'| foo  | (true ifTrue: [foo := KSObject undefined. (foo ksAssign: (self ksAt: #bar asKSKey) currentValue with: (42))])'}.
	}.! !

!KSCompiler2Test methodsFor: 'as yet unclassified' stamp: 'yo 4/11/2013 23:21'!
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
