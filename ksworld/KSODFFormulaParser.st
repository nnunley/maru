OMeta2 subclass: #KSODFFormulaParser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-ODFReader'!

!KSODFFormulaParser commentStamp: 'tak 4/7/2011 10:17' prior: 0!
A parser for draw:formula attribute used in draw:custom-shape.
See KSODFReaderTest >> testFormulaParser

http://docs.oasis-open.org/office/v1.1/OS/OpenDocument-v1.1-html/OpenDocument-v1.1.html#outline:9.5.5.Enhanced_Geometry___Equation

Note: This BNF has a bug in atan2, function_reference, modifier_reference, and unary_expression, so I fixed them.

KSODFFormulaParser parse: '3+4'!

!KSODFFormulaParser methodsFor: 'non terminals' stamp: 'tak 4/8/2011 13:26'!
additiveExpression =
	  additiveExpression:x ``+'' spaces multiplicativeExpression:y -> [{#'+'. x. y}]
	| additiveExpression:x ``-'' spaces multiplicativeExpression:y -> [{#'-'. x. y}]
	| multiplicativeExpression! !

!KSODFFormulaParser methodsFor: 'non terminals' stamp: 'tak 4/7/2011 10:25'!
basicExpression =
	  number
	| identifier
	| functionReference
	| modifierReference
	| unaryFunction:f   open additiveExpression:x close -> [{f. x}]
	| binaryFunction:f  open additiveExpression:x comma additiveExpression:y close -> [{f. x. y}]
	| ternaryFunction:f open additiveExpression:x comma additiveExpression:y comma additiveExpression:z close -> [{f. x. y. z}]
	| open additiveExpression:x close -> [x]! !

!KSODFFormulaParser methodsFor: 'non terminals' stamp: 'tak 4/8/2011 13:26'!
multiplicativeExpression =
	  multiplicativeExpression:x ``*'' spaces unaryExpression:y -> [{#'*'. x. y}]
	| multiplicativeExpression:x ``/'' spaces unaryExpression:y -> [{#'/'. x. y}]
	| unaryExpression! !

!KSODFFormulaParser methodsFor: 'non terminals' stamp: 'tak 4/7/2011 10:19'!
number =	<digit digit*>:n spaces -> [n asNumber]! !

!KSODFFormulaParser methodsFor: 'non terminals' stamp: 'tak 4/8/2011 13:26'!
unaryExpression =
	  $- spaces basicExpression:x -> [{#negated. x}]
	| basicExpression! !

!KSODFFormulaParser methodsFor: 'public' stamp: 'tak 4/7/2011 14:15'!
path = (functionReference | modifierReference | anything)*! !

!KSODFFormulaParser methodsFor: 'public' stamp: 'tak 4/7/2011 10:16'!
start = additiveExpression! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:11'!
binaryFunction = (``min'' | ``max'' | ``atan2''):s spaces -> [ s asSymbol ]! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:11'!
close = $) spaces! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:11'!
comma = $, spaces! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:11'!
functionReference = $? <(range($a. $z) | range($A. $Z) | range($0. $9))+>:s spaces -> [{#f. s asSymbol}]! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:12'!
identifier = (``pi'' | ``left'' | ``top'' | ``right'' | ``bottom'' | ``xstretch'' | ``ystretch'' | ``hasstroke'' | ``hasfill'' | ``width'' | ``height'' | ``logwidth'' | ``logheight''):s spaces -> [ s asSymbol ]! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:12'!
modifierReference = $$ number:n spaces -> [{#m. n}]! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:12'!
open = $( spaces! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:12'!
ternaryFunction = ``if'':s spaces -> [ s asSymbol ]! !

!KSODFFormulaParser methodsFor: 'terminals' stamp: 'tak 4/7/2011 14:12'!
unaryFunction = (``abs'' | ``sqrt'' | ``sin'' | ``cos'' | ``tan'' | ``atan''):s spaces -> [ s asSymbol ]! !

!KSODFFormulaParser class methodsFor: 'public' stamp: 'tak 7/27/2011 11:26'!
parse: aString 
	^ [self matchAll: aString with: #start]
		on: OM2Fail
		do: [:e | 
			Transcript cr; show: e; show: aString.
			0]! !

!KSODFFormulaParser class methodsFor: 'public' stamp: 'tak 4/7/2011 13:08'!
parsePath: aString
	^ self matchAll: aString with: #path! !
