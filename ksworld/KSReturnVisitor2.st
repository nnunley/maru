OMeta2 subclass: #KSReturnVisitor2
	instanceVariableNames: 'stack'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSReturnVisitor2 methodsFor: 'rules' stamp: 'yo 4/12/2013 15:28'!
addReturn: n
	n last first == #methodReturn ifTrue: [
		stack atLast: 1 put: true.
		^ n].
	n last first == #begin ifTrue: [
		^ n allButLast copyWith: (self addReturn: n last)].
	^ n! !

!KSReturnVisitor2 methodsFor: 'rules' stamp: 'yo 4/12/2013 15:45'!
markEnd =
	{#eval2 anything:src anything:t markFuncReturn:n}
										-> [{#eval2. src. t. n}]
|	{#methodDef anything:src anything:name
		{#func anything:a anything:b anything:c anything markMethodReturn:n}}
		[self pushReturnStack]
		[self addReturn: n]:n
		[self popReturnStack]:hasReturn
		[hasReturn ifTrue: [n] ifFalse: [n copyWith: {#methodReturn. ''. {#var. 'this'. #this}}]]:n
										-> [{#methodDef. src. name. {#func. a. b. c. false. n}}]
|	anything! !

!KSReturnVisitor2 methodsFor: 'rules' stamp: 'yo 4/12/2013 15:14'!
markFuncReturn =
	{#func anything:src anything:args anything:temps anything
		[self pushReturnStack]
		markFuncReturn:n
		[self popReturnStack]:hasReturn
	} -> [{#func. src. args. temps. hasReturn. n}]
|	{#return anything:src markFuncReturn:v}
		-> [true ifTrue: [stack atLast: 1 put: true. {#return. src. v}]]
|	~(anything:x ?[x isString or: [x isSymbol]])
		{markFuncReturn*:xs}					-> [xs asArray]
|	anything! !

!KSReturnVisitor2 methodsFor: 'rules' stamp: 'yo 4/12/2013 15:05'!
markMethodReturn =
	&{#func anything*}
	markFuncReturn
|	{#return anything:src anything:v}
		-> [{#methodReturn. src. v}]
|	~(anything:x ?[x isString or: [x isSymbol]])
		{markMethodReturn*:xs}			-> [xs asArray]
|	anything! !

!KSReturnVisitor2 methodsFor: 'support' stamp: 'yo 4/1/2013 11:08'!
initialize
	super initialize.
	stack := OrderedCollection new.! !

!KSReturnVisitor2 methodsFor: 'support' stamp: 'yo 4/1/2013 11:08'!
popReturnStack
	^ stack removeLast! !

!KSReturnVisitor2 methodsFor: 'support' stamp: 'yo 4/1/2013 11:08'!
pushReturnStack
	stack add: false! !
