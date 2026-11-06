TestCase subclass: #KSEvaluatorTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript-Tests'!

!KSEvaluatorTest methodsFor: 'support' stamp: 'yo 1/7/2013 14:33'!
equal: a and: b
	((a isKindOf: KSProtoObject) and: (b isKindOf: KSProtoObject)) ifTrue: [
		(a class = b class and: [a ksKeys = b ksKeys]) ifTrue: [
			a ksKeys isEmpty ifTrue: [^ true].
			a ksKeys do: [:k |
				(self equal: (a ksAt: k) and: (b ksAt: k)) ifFalse: [^ false].
				^ true].
			^ false].
		^ false].
	^ a = b! !

!KSEvaluatorTest methodsFor: 'support' stamp: 'yo 4/17/2012 09:54'!
errors: array
	array do: [:src |
		self should: [KSProtoObject eval: src] raise: Error].! !

!KSEvaluatorTest methodsFor: 'support' stamp: 'yo 4/17/2012 09:54'!
pairs: pairs

	pairs do: [:pair |
		self assert: (self equal: (KSProtoObject eval: pair first) and: pair second)].! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:58'!
testAddExpr

	self pairs:
		{
			{'3 + 4'.		7}.
			{'3 - 4'.		-1}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:58'!
testAndExpr

	self pairs:
		{
			{
'var x = 3
var y = 0
x && y'.		0}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:58'!
testBinding

	self pairs:
		{
			{
'var abc = 3
abc'.		3}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:59'!
testEqExpr

	self pairs:
		{
			{'3 == 3'.				true}.
			{'10 == "10"'.			false}.
			{'"10" == 10'.			false}.
			{'"abc" == "abc"'.		true}.
			{'0 == 0'.				true}.
			{'true == 1'.			false}.
			{'false == 0'.			false}.
			{'1 == true'.			false}.
			{'0 == false'.			false}.
			{'"" == 0'.				false}.
			{'0 == ""'.				false}.
			{'null == undefined'.	false}.
			{'undefined == null'.	false}.
			{'"" == false'.			false}.
			{'false == ""'.			false}.
			{'[0] == []'.				false}.
			{'[0] == [0]'.			true}.
			{'"" == "0"'.				false}.
			{'"" == undefined'.		false}.
			{'"" == null'.				false}.
			{'null == 0'.				false}.
			{'0 == "0"'. 				false}.
			{'false == "false"'. 		false}.
			{'false == "0"'. 			false}.
			{'false == undefined'.	false}.
			{'false == null'. 			false}.
			{'"\t\r\n" == 0'. 			false}
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:59'!
testEscapeChar

	self pairs:
		{
			{'"\t"'.		String tab}.
			{'"\r"'.		String cr}.
			{'"\n"'.		String lf}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/16/2012 15:22'!
testExpr

	self pairs:
		{
			{'3 || 4'.					true}.
			{
'var x = 4
x'.				4}.
			{
'var x = 4
x-=2'.			2}.
			{
'var x = 4
x?=2'.			4}.
			{
'var x = undefined
x?=2'.			2}.
			{
'var x = false
x?=2'.			false}.
		}.

	self errors:
			{'3 = 4'.
			'3=4'.
			'3-=4'.
			'3&&=4'.
			'3 ||= 4'}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/18/2012 00:22'!
testForLoop

	self pairs:
		{
			{
'var y = 0
for x in [0 .. 10]
	y += x
y
'.					45}.
			{
'var y = 0
for x in [0 ... 10]
	y += x
y
'.					55}.
			{
'var list = [1, 2, 3, 4]
var y = 0
for k in list
	y +=k
y
'.					10}.
			{
'var list = [1, 2, 3, 4]
var y = 0
for k in list
	y +=k
	if k == 3 
		break
y
'.					6}.
			{
'var obj = {a: 1, b: 2, c: 3}
var found = undefined
for k, v of obj
	if v == 3
		found = k
		break
found
'.					'c'}.
			{
'var result = []
for i in [1...15] by 5
	result._push(i)
result
'.					{1. 6. 11} asOrderedCollection}.


				}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:59'!
testJson

	self pairs:
		{
			{
'var p = {x:1, y: 2}
var q = {x: 2, y: 3}
p.x + q.y'.		4}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:59'!
testMulExpr

	self pairs:
		{
			{'3 * 4'.		12}.
			{'3 / 4'.		0.75}.
			{'3 % 4'.		3}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 15:59'!
testNumber

	self pairs:
		{
			{'0.75'.		0.75}.
			{'2e10'.		2e10}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 16:00'!
testOrExpr

	self pairs:
		{
			{
'var x = 2
(x || (3/x))'.		true}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 16:00'!
testPostfix

	self pairs:
		{
			{
'var x = 0
x++'.		0}.
			{
'var x = 0
x--'.			0}.
			{
'var x = 0
x++; x'.		1}.
			{
'var x = 0
x--; x'.		-1}.
		}.

	self errors: {
		'3++'.
		'(3+4)++'}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 7/6/2012 10:40'!
testPrimExpr

	self pairs:
		{
			{
'var t = {}
t[0] = 3
t[0]'.										3}.
			{
'var t = {}
t.foo = (x, y) -> x*y
t.ksPerform("foo", [3, 4])'.		12}.
			{
'var t = {}
t["foo"] = 3
t.foo'.								3}.
		}.

"	self errors: {
'var t = undefined
t.foo'}"! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 1/24/2013 00:00'!
testPrimExprHd

	self pairs:
		{
			{
'var x = {}
x[0] = 3
(x[0])'.												3}.
			{'"abc"'.									'abc'}.
			{'[3, 4, 5][1]'.							4}.
			{'[].size()'.								0}.
			{'[3].size()'.								1}.
			{'[3][0]'.									3}.
			{'(x in [3, 4, 5] when x %2 == 0)'.		4}.
			{'delete {x: 1, y: 2}.y'.					2}.
			{
'var x = {x: 1, y: 2}
delete x.y
x.y'.													KSProtoObject undefined}.
			{
'var x = {x: 1, y: 2}
delete x.z
x.y'.													2}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 16:02'!
testRelExpr

	self pairs:
		{
			{'3 >4'.						false}.
			{'3 >= 4'.					false}.
			{'3 < 4'.						true}.
			{'3 <= 4'.					true}.
			{'3 instanceof Number'.		true}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 1/9/2013 16:02'!
testSpecialCalls

	self pairs:
		{
			{'P(1, 2)'.								1@2}.
			{'M(1, 0, 100, 0, 1, 50)'.					MatrixTransform2x3 withOffset: 100@50}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 17:59'!
testStmt

	self pairs:
		{
			{
'if 3 > 4
	var x = 0
else
	var x = 1
'.	1}.
			{
'var x = 0
while x < 3
	x++
x'.		3}.
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 18:00'!
testTryCatchFinally

	self pairs:
		{
			{
'try
	throw {error: "abc"}
catch x
	var y = x.error
y'. 						'abc'}.
			{
'var x = 0
try
	throw {error: "abc"}
catch x
	x.error
finally
	x = "def"
x
'.					 'def'}
		}.! !

!KSEvaluatorTest methodsFor: 'tests' stamp: 'yo 4/11/2012 18:01'!
testUnary

	self pairs:
		{
			{
'var x = 0
++x'.	1}.
			{
'var x = 0
--x'.		-1}.
			{'!!false'.			true}.
			{'!!undefined'. 	true}.
			{'!!null'. 			true}.
			{'!!""'. 			false}.
			{'!!0'. 			false}.
			{'!!"0"'. 			false}.
			{'!!"\n"'. 			false}.
			{'!!" "'. 			false}.
		}.

	self errors: {
		'++x--'.
		'++3'}.! !
