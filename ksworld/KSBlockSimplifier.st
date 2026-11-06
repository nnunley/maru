OMeta2 subclass: #KSBlockSimplifier
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSBlockSimplifier methodsFor: 'all' stamp: 'yo 7/10/2012 10:02'!
clause =
	{#begin anything:src simplify*:ss}					-> [{#sbegin. src}, ss]
|	anything! !

!KSBlockSimplifier methodsFor: 'all' stamp: 'yo 7/10/2012 10:25'!
simplify =
	{#if _:src _:cc clause:tt clause:ff}						-> [{#if. src. cc. tt. ff}]
|	{#if _:src _:cc clause:tt}									-> [{#if. src. cc. tt}]
|	{#forIn:h _:src _:v _:l clause:b}							-> [{h. src. v. l. b}]
|	{#forOf:h _:src _:k _:v _:l clause:b}						-> [{h. src. k. v. l. b}]
|	{#forRange:h _:src _:v _:l clause:b}						-> [{h. src. v. l. b}]
|	{#forRangeBy:h _:src _:v _:l clause:b _:i}					-> [{h. src. v. l. b. i}]
|	~(anything:x ?[x isString or: [x isSymbol]]) {simplify*:xs}	-> [xs asArray]
|	anything! !
