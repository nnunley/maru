TestCase subclass: #KSParserTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript-Tests'!

!KSParserTest methodsFor: 'support' stamp: 'yo 4/12/2012 11:13'!
build: elem

	(elem isArray and: [elem size = 2 and: [elem first isString and: [elem second isSymbol and: [KSParser basicNew respondsTo: elem second]]]]) ifTrue: [^ KSParser matchAll: elem first with: elem second].
	
	elem isArray ifTrue: [^ elem collect: [:e | self build: e]].
	^ elem.! !

!KSParserTest methodsFor: 'support' stamp: 'yo 4/10/2012 09:18'!
get: n
	^{#var. n asString. n}! !

!KSParserTest methodsFor: 'support' stamp: 'yo 4/12/2012 11:13'!
triples: triples
	| a b |
	triples do: [:triple |
		a := KSParser matchAll: triple first with: triple second.
		b := triple third.
		self assert: a = b].
"
a
b
"! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 14:03'!
testAddExpr

	| str |
	self triples:
		{
			{str := '3 + 4'.	#addExpr.	self build: {#send. str. #+. {'3'. #mulExpr}. {'4'. #mulExpr}}}.
			{str := '3 - 4'.#addExpr.		self build: {#send. str. #-. {'3'. #mulExpr}. {'4'. #mulExpr}}}.
			{str := '3 * 4'.#addExpr.	self build: {#send. str. #*. {'3'. #mulExpr}. {'4'. #mulExpr}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 14:04'!
testAndExpr

	| str |
	self triples:
		{
			{str := 'x && y'.		#andExpr.		self build: {#and. str. {'x'. #eqExpr}. {'y'. #eqExpr}}}.
			{str := 'x == y'.			#andExpr.		self build: {#send. str. #==. {'x'. #eqExpr}. {'y'. #eqExpr}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 14:04'!
testArgList

	self triples:
		{
			{''	.#argList.	#()}.
			{'xy'.#argList.	self build: {{'xy'. #expr}}}.
			{'x,y'.#argList.	self build: {{'x'. #expr}. {'y'. #expr}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 14:02'!
testBinding

	| str |
	self triples:
		{
			{str := 'abc = 3'.	#binding.		self build: {#decl. str. {#quote. {'abc'. #name}}. {'3'. #expr}}}.
	 		{str := 'abc'.		#binding. 		self build: {#decl. str. {#quote. {'abc'. #name}}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 1/30/2013 15:05'!
testEqExpr

	| str |
	self triples:
		{
			{str := 'x == y'.	#eqExpr.	self build: {#send. str. #'=='. {'x'. #expr}. {'y'. #expr}}}.
			{str := 'x !!=y'.		#eqExpr.	self build: {#send. str. #'!!='. {'x'. #expr}. {'y'. #expr}}}.
			{str := 'x===y'.	#eqExpr.	self build: {#send. str. #'==='. {'x'. #expr}. {'y'. #expr}}}.
			{str := 'x>=y'.		#eqExpr.	self build: {#send. str. #'>='. {'x'. #expr}. {'y'. #expr}}}.
			{str := 'x ~= y'.		#eqExpr.	self build: {#send. str. #'~='. {'x'. #expr}. {'y'. #expr}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 14:09'!
testEscapeChar

	self triples:
		{
			{'\t'.		#escapeChar.	Character tab}.
			{'\r'	.#escapeChar.		Character cr}.
			{'\n'	.#escapeChar.		Character lf}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:56'!
testExpr

	| str |
	self triples:
		{
			{str := 'if 3 = 4 then 5 else 6'.		#expr.		self build: {#if. str. {'3 = 4'. #expr}. {'5'. #expr}. {'6'. #expr}}}.
			{str := '3 = 4'.		#expr.		self build: {#set. str. {'3'. #expr}. {'4'. #expr}}}.
			{str := '3=4'.		#expr.     	self build: {#set. str. {'3'. #expr}. {'4'. #expr}}}.
			{str := '3-=4'.		#expr.    	self build: {#set. str. {'3'. #expr}. ((self build: {'3-4'. #expr}) at: 2 put: '3-=4'; yourself)}}.
			{str := '3 || 4'.		#expr.		self build: {#or. str. {'3'. #eqExpr}. {'4'. #eqExpr}}}.
			{str := 'x ?= 5'.		#expr.		self build: {#set. str. {'x'. #orExpr}. {#existential. str. {'x'. #orExpr}. {'5'. #eqExpr}}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/11/2012 14:41'!
testForLoop

	| str |
	self triples:
		{
			{str := 'for n in [0 .. 10]
						n + 3'.	#forLoop.
				self build: {#forRange. str. #n. {'[0 .. 10]'. #range}. {'						n + 3'. #stmts}}}.
			{str := 'for n in array
						n + 3'.	#forLoop.
				self build: {#forIn. str. #n. {'array'. #expr}. {'						n + 3'. #stmts}}}.
			{str := 'for k, v of obj
						n + 3'.	#forLoop.
				self build: {#forOf. str. #k. #v. {'obj'. #expr}. {'						n + 3'. #stmts}}}
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 11:04'!
testFunc

	| str |
	self triples:
		{
			{str := '(x, y, z) -> x + y'.			#func.
				(self build: {#func. str. {'x, y, z'. #formals}. #(). true}), {self build: {'x + y'. #stmts}}}.
			{str := '(x, y, z) ->
				x + y'.	#func.
				(self build: {#func. str. {'x, y, z'. #formals}. #(). true}), {self build: {'x + y'. #stmts}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 21:57'!
testJson

	| str |
	self triples:
		{
			{str := '{x: 1}'.		#json.   self build: {#json. str}, (self build: {'x: 1'. #jsonBindings})}.
			{str := '{ }'.			#json.   self build: {#json. str}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 10:55'!
testJsonBinding

	| str |
	self triples:
		{
			{str := 'xyz: 1'.		#jsonBinding.    {#jsonProp. str. {#quote. #xyz}. {#number. 1}}}.
			{str :='xyz: 1 + 2'.	#jsonBinding.    {#jsonProp. str. {#quote. #xyz}. self build: {'1 + 2'. #expr}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 21:57'!
testJsonBindings

	| str |
	self triples:
		{
			{str := 'a: 1, b: 2, c: 3 + 4'.		#jsonBindings.
					{self build: {'a: 1'. #jsonBinding}.
					 self build: {'b: 2'. #jsonBinding}.
					 self build: {'c: 3 + 4'. #jsonBinding}}}
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 10:55'!
testJsonPropertyName

	self triples:
		{
			{'abc'.		#jsonPropertyName.      #(#quote #abc)}.
			{'123'.		#jsonPropertyName.      #(#number 123)}.
			{'"123"'.	#jsonPropertyName.      #(#string '123')}.
			{'"*/="'.		#jsonPropertyName.      #(#string '*/=')}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 21:57'!
testMulExpr

	| str |
	self triples:
		{
			{str := '3*4'.	#mulExpr.	self build: {#send. str. #*. {'3'. #unary}. {'4'. #unary}}}.
	 		{str := '3/4'.	#mulExpr.	self build: {#send. str. #/. {'3'. #unary}. {'4'. #unary}}}.
	 		{str := '3%4'.	#mulExpr.	self build: {#send. str. #%. {'3'. #unary}. {'4'. #unary}}}.
	 		{str := '!!3'.		#mulExpr.	self build: {#send. str. #!!. {'3'. #postfix}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 9/6/2012 14:55'!
testName

	self triples:
		{
			{'a_b'.	#name.		#'a_b'}.
			{'a$b'.	#name.		#'a$b'}.
			{'$$'.	#name.		#'$$'}.
	}.

"	self should: [KSParser matchAll: 'for' with: #name] raise: Error."! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 6/12/2012 15:20'!
testNumber

	self triples:
		{
			{'42'.			#number. {#number. 42}}.
	 		{'42.125'.		#number. {#number. 42.125}}.
			{'4.375e10'.	#number. {#number. 4.375e10}}.
			{'0x1234'.		#number. {#number. 16r1234}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 21:38'!
testOrExpr

	| str |
	self triples:
		{
			{str := '3||4'.		#orExpr.	self build: {#or. str. {'3'. #orExpr}. {'4'. #andExpr}}}.
			{str := '3&&4'.		#orExpr.	self build: {#and. str. {'3'. #orExpr}. {'4'. #andExpr}}}.
			{str := 'null?4'.		#orExpr.	self build: {#existential. str. {'null'. #orExpr}. {'4'. #andExpr}}}
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 21:58'!
testPostfix

	| str |
	self triples:
		{
			{str := 'x++'.		#postfix.	self build: {#post. str. #+. {'x'. #primExpr}}}.
			{str := '3++'.		#postfix.	self build: {#post. str. #+. {'3'. #primExpr}}}.
			{str := '(3+4)++'.	#postfix.	self build: {#post. str. #+. {'(3+4)'. #primExpr}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 10:56'!
testPrimExpr

	| str |
	self triples:
		{
			{str := 'x[y]'.		#primExpr.		self build: {#get. str. {'x'. #primExpr}. {'y'. #expr}}}.
			{str := 'x[z[y]]'.		#primExpr.		self build: {#get. str. {'x'. #primExpr}. {'z[y]'. #expr}}}.
			{str := 'x[y][z]'.		#primExpr.		self build: {#get. str. {'x[y]'. #expr}. {'z'. #expr}}}.
			{str := 'x.f(y)'.		#primExpr.		(self build: {#send. str. {'f'. #name}. {'x'. #primExpr}}), (self build: {'y'. #argList})}.
			{str := 'x.f'.			#primExpr.		self build: {#get. str. {'x'. #primExpr}. {#fieldName. #f}}}.
			{str := 'f(x+3, y)'.	#primExpr.  	(self build: {#call. str. {'f'. #primExpr}}), (self build: {'x+3, y'. #argList})}.
			{str := 'x'.			#primExpr.		self build: {'x'. #primExpr}}
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 10:56'!
testPrimExprHd

	| str |
	self triples:
		{
			{str := '(x)'.				#primExprHd.			self build: {'x'. #expr}}.
			{str := '@x'.			#primExprHd.			{#quotedVar. '@x'. false. #x}}.
			{str := '@x'''.			#primExprHd.			{#quotedVar. '@x'''. true. #x}}.
			{str := '@["x"]'.			#primExprHd.			self build: {#quotedVar. '@["x"]'. false. {'"x"'. #expr}}}.
			{str := 'x'.				#primExprHd.			self build: {'x'. #primExpr}}.
			{str := '123'.			#primExprHd.			#(#number 123)}.
			{str := '"abc"'.			#primExprHd.			#(#string 'abc')}.
			{str := '(x, y) -> x + y'.	#primExpr.    			 self build: {str. #func}}.
			{str := '[]'.				#primExprHd.			self build: {#new. str. self get: #Array}}.
			{str := '[3]'.				#primExprHd.			self build: {#new. str. self get: #Array. {'3'. #expr}}}.
			{str := '[3, 4, a, b]'.		#primExprHd.			self build: {#new. str. self get: #Array. {'3'. #expr}. {'4'. #expr}. {'a'. #expr}. {'b'. #expr}}}.
			{str := 'delete x.y'.		#primExprHd.			self build: {#delete.str. {'x.y'. #expr}}}.
			{str := 'delete x[y]'.		#primExprHd.			self build: {#delete.str. {'x[y]'. #expr}}}.
			{str := 'delete (x+y)[z]'.		#primExprHd.		self build: {#delete.str. {'(x+y)[z]'. #expr}}}.
			{'{a: 1, b: 2}'.			#primExprHd.			self build: {'{a: 1, b: 2}'. #json}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 10:57'!
testRange

	| str |
	self triples:
		{
			{str := '[0 .. 10]'.	#range.
				self build: {#rangeE. str. {#number. 0}. {#number. 10}}}.
			{str := '[0 ... 10]'.	#range.
				self build: {#rangeI. str. {#number. 0}. {#number. 10}}}.
			{str := '[0 ... 10+3]'.	#range.
				self build: {#rangeI. str. {#number. 0}. {'10+3'. #expr}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/10/2012 22:43'!
testRelExpr

	| str |
	self triples:
		{
			{str := '3 > 4'.			#relExpr.	self build: {#send. str. #>. {'3'. #relExpr}. {'4'. #addExpr}}}.
			{str := '3 >=4'.			#relExpr.	self build: {#send. str. #'>='. {'3'. #relExpr}. {'4'. #addExpr}}}.
			{str := '3<4'.			#relExpr.	self build: {#send. str. #'<'. {'3'. #relExpr}. {'4'. #addExpr}}}.
			{str := '3<=4'.			#relExpr.	self build: {#send. str. #'<='. {'3'. #relExpr}. {'4'. #addExpr}}}.
			{str := '3 instanceof 4'.	#relExpr.    self build: {#send. str.  #'__hasInstance__'. {'4'. #addExpr}. {'3'. #relExpr}}}.
			{str := '3+4'.			#relExpr.	self build: {'3+4'. #addExpr}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:29'!
testStmt

	| str |
	self triples:
		{
			{str := 
'if x < 3
	a = 3
else
	b= 4
	c = 5
'.	#oneStmt.	self build: {#if. str. {'x < 3'. #expr}. {'	a = 3'. #stmts}. {'	b= 4
	c = 5'. #stmts}}}.
			{str := 
'while x < 3
	x++
'.			#oneStmt.	self build: {#while. str. {'x < 3'. #expr}. {'x++'. #stmts}}}.
			{str := 'break\' withCRs.		#oneStmt.		#(break 'break')}.
			{str := 'throw x\' withCRs.	#oneStmt.		self build: {#throw. str withBlanksTrimmed. {'x'. #expr}}}.
			{str := 'return\' withCRs.		#oneStmt.		#(return 'return')}.
			{str := 'return 3\' withCRs.	#oneStmt.		self build: {#return. str withBlanksTrimmed. {'3'. #expr}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 1/24/2013 12:12'!
testString

	self triples:
		{
			{'"abc"'.		#string. {#string. 'abc'}}.
	 		{'''abc'''.	#string. {#string. 'abc'}}.
			{'"\t\r\n"'.	#string. {#string. (String with: Character tab with: Character cr with: Character lf)}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 1/24/2013 10:02'!
testSymbol

	self triples:
		{
			{'#"abc"'.		#symbol. {#symbol. 'abc'}}.
	 		{'#''abc'''.	#symbol. {#symbol. 'abc'}}.
			{'#"\t\r\n"'.	#symbol. {#symbol. (String with: Character tab with: Character cr with: Character lf)}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 14:02'!
testTryCatchFinally

	| str |
	self triples:
		{
			{str := 
'try
	x++
catch y
	y
'.	#tryCatchFinally.
				self build: {#begin. ''. {#decl. 'y'. {#quote. #y}}. {#try. str. {'x++'. #stmts}. {'y'. #name}. {'y'. #stmts}. {#quote. nil}}}}.
			{str := 
'try
	x++
catch y
	y
finally
	y++
'.	#tryCatchFinally.
				self build: {#begin. ''. {#decl. 'y'. {#quote. #y}}. {#try. str. {'x++'. #stmts}. {'y'. #name}. {'y'. #stmts}. {'y++'. #stmts}}}}.
	}.! !

!KSParserTest methodsFor: 'tests' stamp: 'yo 4/12/2013 11:02'!
testUnary

	| str |
	self triples:
		{
			{str := '-3'.		#unary.		(self build: {'0-3'. #addExpr}) at: 2 put: str; yourself}.
			{str := '+ 3'.	#unary.       #(number 3)}.
			{str := '++ 3'.	#unary.		self build: {#set. str. {'3'. #postfix}. ((self build: {'3+1'. #addExpr}) at: 2 put: ''; yourself)}}.
			{str := '-- 3'.	#unary.       self build: {#set. str. {'3'. #postfix}. ((self build: {'3-1'. #addExpr}) at: 2 put: ''; yourself)}}.
			{str := '!!3'.		#unary.		self build: {#send. str. #'!!'. {'3'. #postfix}}}.
	}.! !
