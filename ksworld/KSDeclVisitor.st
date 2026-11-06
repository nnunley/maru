OMeta2 subclass: #KSDeclVisitor
	instanceVariableNames: 'declsStack'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSDeclVisitor methodsFor: 'rules' stamp: 'yo 7/6/2012 10:50'!
decls =
	[self enterFunction]
	iDecls:i
	[self leaveFunction]:moreTemps	-> [{#eval. ''. moreTemps asArray. i}]! !

!KSDeclVisitor methodsFor: 'rules' stamp: 'yo 4/12/2013 18:35'!
iDecls =
	{#decl anything:src {#quote anything:n}}			[self addDecl: n]			-> [{#decl. src. {#quote. n}}]
|	{#decl anything:src {#quote anything:n} iDecls:v}	[self addDecl: n]			-> [{#decl. src.  {#quote. n}. v}]
|	{#func anything:src anything:args anything:tmps anything:hasReturn
		[self enterFunction]
		iDecls:body
		[self leaveFunction]:moreTmps}								-> [{#func. src. args. (tmps, moreTmps asArray). hasReturn. body}]
|	{#sets anything*}:n									[self addDecl: #pvtStrm]	-> [n]
|	~(anything:x ?[x isString or: [x isSymbol]]) {iDecls*:xs}				-> [xs asArray]
|	anything! !

!KSDeclVisitor methodsFor: 'rules' stamp: 'yo 7/6/2012 10:50'!
methodDecls =
	iDecls! !

!KSDeclVisitor methodsFor: 'support' stamp: 'yo 3/1/2012 09:52'!
addDecl: n

	declsStack last add: n! !

!KSDeclVisitor methodsFor: 'support' stamp: 'yo 3/1/2012 09:46'!
enterFunction

	declsStack add: IdentitySet new! !

!KSDeclVisitor methodsFor: 'support' stamp: 'yo 3/5/2012 15:38'!
initialize

	super initialize.
	declsStack := OrderedCollection new.! !

!KSDeclVisitor methodsFor: 'support' stamp: 'yo 3/1/2012 09:47'!
leaveFunction

	^ declsStack removeLast! !
