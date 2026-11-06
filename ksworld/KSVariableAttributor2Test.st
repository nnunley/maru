TestCase subclass: #KSVariableAttributor2Test
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript-Tests'!

!KSVariableAttributor2Test methodsFor: 'support' stamp: 'yo 4/11/2013 15:35'!
triples: triples
	| a b |
	triples do: [:triple |
		a := KSVariableAttributor2 match: (KSDeclVisitor match: (KSParser2 matchAll: triple first with: triple second) with: #decls) with: #start.
		b := triple third.
		self assert: a = b].
"
a
b
"! !

!KSVariableAttributor2Test methodsFor: 'tests' stamp: 'yo 4/11/2013 23:27'!
testAssignment
	| str |
	self triples:
		{
			{str := ':Foo := 42'.	#start.			{#eval2. ''. {}. {#begin. ''. {#set. str. {#var. ':Foo'. #Foo}. {#number. 42}}}}}.
			{str := 
'foo := 42'.						#start.			{#eval2. ''. {}. {#begin. ''. {#set. str. {#fieldRef. 'foo'. false.  {#fieldName. #foo}}. {#number. 42}}}}}.
			{str := 'var foo
foo := 42'.						#start.			{#eval2. ''. {#foo}. {#begin. ''. {#begin. 'var foo'. {#decl. 'foo'. {#quote. #foo}}}. {#set. 'foo := 42'. {#tempRef. 'foo'. false.  {#fieldName. #foo}}. {#number. 42}}}}}.

			{str :=
'foo.bar := 42'.					#start.			{#eval2. ''. {}. {#begin. ''. {#set. str. {#fieldRef. 'foo.bar'. false.  {#fieldName. #foo}. {#fieldName. #bar}}. {#number. 42}}}}}.
			{str := 'var foo
foo.bar := 42'.					#start.			{#eval2. ''. {#foo}. {#begin. ''. {#begin. 'var foo'. {#decl. 'foo'. {#quote. #foo}}}. {#set. 'foo.bar := 42'. {#tempRef. 'foo.bar'. false.  {#fieldName. #foo}. {#fieldName. #bar}}. {#number. 42}}}}}.

			{str :=
'foo[bar] := 42'.					#start.			{#eval2. ''. {}. {#begin. ''. {#set. str. {#fieldRef. 'foo[bar]'. false.  {#fieldName. #foo}. {#fieldRef. 'bar'. false. {#fieldName. #bar}}}. {#number. 42}}}}}.

			{str := 'var foo
foo[bar] := 42'.					#start.			{#eval2. ''. {#foo}. {#begin. ''. {#begin. 'var foo'. {#decl. 'foo'. {#quote. #foo}}}. {#set. 'foo[bar] := 42'. {#tempRef. 'foo[bar]'. false.  {#fieldName. #foo}. {#fieldRef. 'bar'. false. {#fieldName. #bar}}}. {#number. 42}}}}}.
	}.! !
