TestCase subclass: #KSParser2Test
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript-Tests'!

!KSParser2Test methodsFor: 'support' stamp: 'yo 4/10/2013 15:32'!
build: elem
	(elem isArray and: [
		elem size = 2 and: [
			elem first isString and: [
				elem second isSymbol and: [
					KSParser2 basicNew respondsTo: elem second]]]])
		ifTrue: [^ KSParser2 matchAll: elem first with: elem second].
	
	elem isArray ifTrue: [^ elem collect: [:e | self build: e]].
	^ elem.! !

!KSParser2Test methodsFor: 'support' stamp: 'yo 4/10/2013 15:32'!
triples: triples
	| a b |
	triples do: [:triple |
		a := KSParser2 matchAll: triple first with: triple second.
		b := triple third.
		self assert: a = b].
"
a
b
"! !

!KSParser2Test methodsFor: 'tests' stamp: 'yo 4/11/2013 20:36'!
testAssignment
	| str |
	self triples:
		{
			{str := ':Foo := 42'.		#expr.			{#set. str. {#globalVar. ':Foo'. #Foo}. {#number. 42}}}.
			{str := 'foo := 42'.		#expr.			{#set. str. {#varRef. 'foo'. false.  {#fieldName. #foo}}. {#number. 42}}}.
			{str := 'foo.bar := 42'.	#expr.			{#set. str. {#varRef. 'foo.bar'. false.  {#fieldName. #foo}. {#fieldName. #bar}}. {#number. 42}}}.
			{str := 'this[foo] := 42'.	#expr.			{#set. str. {#varRef. 'this[foo]'. false. {#varRef. 'foo'. false. {#fieldName. #foo}}}. {#number. 42}}}.
	}.! !

!KSParser2Test methodsFor: 'tests' stamp: 'yo 4/11/2013 20:36'!
testPrimExprHd
	| str |
	self triples:
		{
			{str := ':Foo'.			#primExprHd.			{#globalVar. ':Foo'. #Foo}}.
			{str := 'foo'.			#primExprHd.			{#varRef. 'foo'. false.  {#fieldName. #foo}}}.
			{str := 'foo'''.			#primExprHd.			{#varRef. 'foo'''. true.  {#fieldName. #foo}}}.
			{str := 'this[foo]'.		#primExprHd.			{#varRef. 'this[foo]'. false. {#varRef. 'foo'. false. {#fieldName. #foo}}}}.
			{str := 'foo.bar'.		#primExprHd.			{#varRef. 'foo.bar'. false. {#fieldName. #foo}. {#fieldName. #bar}}}.
			{str := 'foo[bar]'.		#primExprHd.			{#varRef. 'foo[bar]'. false. {#fieldName. #foo}. {#varRef. 'bar'. false. {#fieldName. #bar}}}}
	}.! !
