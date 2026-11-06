OMeta2 subclass: #KSBreakFinder
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSBreakFinder methodsFor: 'all' stamp: 'yo 6/4/2012 14:12'!
hasBreak :tree =
	empty(tree)
(	{}															-> [false]
|	{#break _*}												-> [true]
|	{(#forRange | #forRangeBy | #forIn | #forOf | #while) _*} 	-> [false]
|	~(anything:x ?[x isString or: [x isSymbol]]) {hasBreak*:xs}	-> [xs reduce: [:a :b | a | b]]
|	anything													-> [false]
)! !
