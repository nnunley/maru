OMeta2 subclass: #KSVariableAttributor2
	instanceVariableNames: 'variables'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSVariableAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 3/29/2013 14:33'!
addVariable: v
	variables first add: v! !

!KSVariableAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 3/29/2013 14:34'!
enterFunction
	variables addFirst: IdentitySet new! !

!KSVariableAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 4/4/2013 14:52'!
isTemp: var
	| v |
	v := var isSymbol ifFalse: [var last] ifTrue: [var].
	variables do: [:set | (set includes: v) ifTrue: [^ true]].
	^ false.! !

!KSVariableAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 3/29/2013 14:34'!
leaveFunction
	variables removeFirst.! !

!KSVariableAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 4/3/2013 20:08'!
start =
	[variables := OrderedCollection with: (IdentitySet withAll: #(#this #false #true #null #nil #undefined Array))]
	variableAttribute! !

!KSVariableAttributor2 methodsFor: 'as yet unclassified' stamp: 'yo 4/11/2013 23:26'!
variableAttribute =
	{#func anything:src
		[self enterFunction]
		&anything:args {(anything:n [self addVariable: n])*}
		&anything:temps {(anything:n [self addVariable: n])*}
		anything:hasReturn
		variableAttribute:body
		[self leaveFunction]
	} -> [{#func. src. args. temps. hasReturn. body}]
|	{#eval anything:src
		[self enterFunction]
		&anything:temps {(anything:n [self addVariable: n])*}
		variableAttribute:body
		[self leaveFunction]
	} -> [{#eval2. src. temps. body}]
|	{#varRef anything:src anything:last variableAttribute:first variableAttribute*:rest} (?[self isTemp: first] [{#tempRef. src. last. first}, rest] | [{#fieldRef. src. last. first}, rest])
| 	{#globalVar anything:a anything:b} -> [{#var. a. b}]
|	~(anything:x ?[x isString or: [x isSymbol]]) {variableAttribute+:xs} -> [xs asArray]
|	anything! !
