OMeta2 subclass: #KSReturnVisitor
	instanceVariableNames: 'stack'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSReturnVisitor methodsFor: 'rules' stamp: 'yo 7/6/2012 00:29'!
markEnd =
	{#eval anything:src anything:t markFuncReturn:n}
										-> [{#eval. src. t. n}]
|	{#methodDef anything:src anything:name
		{#func anything:a anything:b anything:c anything markMethodReturn:n}}
										-> [{#methodDef. src. name. {#func. a. b. c. false. n}}]
|	anything! !

!KSReturnVisitor methodsFor: 'rules' stamp: 'yo 7/6/2012 00:37'!
markFuncReturn =
	{#begin anything:src
		((&{#begin anything*} [true] | [false]):isBegin
		(&{#return anything*} [true] | [false]):isReturn
		anything:n
		(&anything empty(n) markFuncReturnInner
		| (?[isBegin] empty(n) markFuncReturnInner
			| (?[isReturn] [n size < 3 ifTrue: [{#var. 'this'. #this}] ifFalse: [n third]]))))+:col}
																				-> [{#begin. src}, col]
|	{#func anything:src anything:args anything:temps anything
		[self pushReturnStack]
		markFuncReturn:n
		[self popReturnStack]:hasReturn}		-> [{#func. src. args. temps. hasReturn. n}]
|	anything! !

!KSReturnVisitor methodsFor: 'rules' stamp: 'yo 7/6/2012 00:43'!
markFuncReturnInner =
	{#return anything:src (markFuncReturnInner | [{#var. 'this'. #this}]):x} 	-> [true ifTrue: [stack atLast: 1 put: true. {#return. src. x}]]
|	{#func anything:src anything:args anything:temps anything
		[self pushReturnStack]
		markFuncReturn:n
		[self popReturnStack]:hasReturn}									-> [{#func. src. args. temps. hasReturn. n}]
|	~(anything:x ?[x isString or: [x isSymbol]]) {markFuncReturnInner*:xs}	-> [xs asArray]
|	anything! !

!KSReturnVisitor methodsFor: 'rules' stamp: 'yo 4/1/2013 11:53'!
markMethodReturn =
	{#begin anything:src
		((&{#begin anything*} [true] | [false]):isBegin
		(&{#return anything*} [true] | [false]):isReturn
		anything:n
		(&anything markMethodReturnInner(n)
		| (?[isBegin] markMethodReturn(n)
			| (?[isReturn] [{#methodReturn}, n allButFirst]
				| markMethodReturnInner(n):n [{#methodReturn. ''. n}]))))+:col}
																			-> [{#begin. src}, col]
|	anything! !

!KSReturnVisitor methodsFor: 'rules' stamp: 'yo 7/6/2012 10:33'!
markMethodReturnInner =
	{#return anything*:xs}
														-> [{#methodReturn}, xs]
|	{#func anything:src anything:args anything:temps anything
		[self pushReturnStack]
		markFuncReturn:n
		[self popReturnStack]:hasReturn
	}													-> [{#func. src. args. temps. hasReturn. n}]
|	~(anything:x ?[x isString or: [x isSymbol]])
		{markMethodReturnInner*:xs}					-> [xs asArray]
|	anything! !

!KSReturnVisitor methodsFor: 'support' stamp: 'yo 7/6/2012 00:26'!
initialize
	super initialize.
	stack := OrderedCollection new.! !

!KSReturnVisitor methodsFor: 'support' stamp: 'yo 7/6/2012 00:27'!
popReturnStack
	^ stack removeLast! !

!KSReturnVisitor methodsFor: 'support' stamp: 'yo 7/6/2012 00:27'!
pushReturnStack
	stack add: false! !
