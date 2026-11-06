TestCase subclass: #KSEventStreamTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Tests'!

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 1/23/2013 19:38'!
testAnd

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: 
'x = () ->
	this.timer = $$(timerE(100))
	this.flip = $$(@timer.collectE(false, (x, y) -> if y then false else true))
	this.flop = $$(!!@flip)
	this.flopflop = $$(@flop && @flop)
	this.flopflip = $$(@flop && @flip)
	this.flipflop = $$(@flip && @flop)
	this.flipflip = $$(@flip && @flip)
	this
'.
	this x.
	self assert: (this eval: 'this.flipflip.type()') = 'frpAnd'.
	self assert: (this eval: 'this.flipflip.sources().size()') = 2.

	this sortAndEvaluateAt: 100.
	self assert: (this eval: '@flopflop') = false.
	self assert: (this eval: '@flopflip') = false.
	self assert: (this eval: '@flipflop') = false.
	self assert: (this eval: '@flipflip') = true.

	this sortAndEvaluateAt: 199.
	self assert: (this eval: '@flopflop') = false.
	self assert: (this eval: '@flopflip') = false.
	self assert: (this eval: '@flipflop') = false.
	self assert: (this eval: '@flipflip') = true.

	this sortAndEvaluateAt: 200.
	self assert: (this eval: '@flopflop') = true.
	self assert: (this eval: '@flopflip') = false.
	self assert: (this eval: '@flipflop') = false.
	self assert: (this eval: '@flipflip') = false.

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 3/28/2013 14:12'!
testDelay

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: 
'x = () ->
	this.t = $$(timerE(100).mapE((x) -> x / 10))
	this.d = $$(@t.delayE(200))
	this.e = $$(@d.mapE((x) -> x._printString()))
	'.
	this x.
	self assert: (this eval: 'this.d.type()') = 'delayE'.
	self assert: (this eval: 'this.d.property("__interval__")') = 200.
	self assert: (this eval: 'this.d.property("__subExpressions_")') = #().
	self assert: (this eval: '(x._ref() for x in this.t.sources())._contains("tt1")').

	self assert: (this eval: 'this.t.tt1.type()') = 'timerE'.

	this sortAndEvaluateAt: 100.
	self assert: (this eval: '@d') = KSObject undefined.
	self assert: (this eval: 'this.e.lastTime()') = 0.

	this sortAndEvaluateAt: 200.
	self assert: (this eval: '@d') = KSObject undefined.
	self assert: (this eval: '@e') = KSObject undefined.

	this sortAndEvaluateAt: 301.
	self assert: (this eval: '@d') = 10.
	self assert: (this eval: '@e') = '10'.

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 1/23/2013 23:57'!
testGet

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: 
'x = () ->
	this.a = {}
	this.a.a = $$(timerE(100))
	this.t = $$(@a.a.mapE((x) -> x / 10))
	'.
	this x.
	self assert: (this eval: 'this.t.sources().size()') = 2.
	self assert: (this eval: 'this.t.sources()[0].ref()') = 'tt2'.
	self assert: (this eval: 'this.t.sources()[1].ref()') = 'a'.
	self assert: (this eval: 'this.t.tt2.sources().size()') = 1.
	self assert: (this eval: 'this.t.tt2.sources()[0].ref()') = 'a'.

	"This line means that streams that are external needs to be explicitly evaluated.  We could evaluate them when we found them refered to, but that may or may not what we want."
	(this at: #a) sortAndEvaluateAt: (100).
	this sortAndEvaluateAt: (100).
	self assert: (this eval: 'this.t.currentValue()') = 10.

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 3/28/2013 17:11'!
testGetSorty
	"there was an issue with the sort order when getE is involved."
	| this sorter result |
	10 timesRepeat: [
		this := KSObject new becomeUniClass.
		this evalToMethod: 
	'x = () ->
		this.a = {}
		this.a.a = $$(timerE(100))
		this.s = $$(@a.a)
		this.t = $$(@s.mapE((x) -> @s / 10))
		'.
		this x.

		self assert: (this eval: 'this.t.sources().size()') = 1.
		self assert: (this eval: 'this.t.sources()[0].ref()') = 's'.

		sorter := KSDependencyEvaluator new.
		sorter addStreamsFrom: (this at: #a).
		sorter addStreamsFrom: this.
		sorter sort.

		result := sorter at: #result.
		self assert: result first type == #timerE.
		self assert: result second type == #getE.
		self assert: result third type == #mapE.
	].

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 3/28/2013 17:18'!
testGetSorty2
	"there was an issue with the sort order when getE is involved."
	| this sorter result |
	10 timesRepeat: [
		this := KSObject new becomeUniClass.
		this evalToMethod: 
	'x = () ->
		this.a = {}
		this.a.a = $$(timerE(100))
		this.t = $$(@a.a.mapE((x) -> x / 10))
		'.
		this x.

		sorter := KSDependencyEvaluator new.
		sorter addStreamsFrom: (this at: #a).
		sorter addStreamsFrom: this.
		sorter sort.

		result := sorter at: #result.
		self assert: result first type == #timerE.
		self assert: result second type == #mapE.
	].

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 2/20/2013 15:15'!
testManyUpdates

	| this |
	this := KSObject new becomeUniClass.

	this evalToMethod: '
x = () ->
	this.timer = $$(timerE(100))
	this.a = 100
	this.b = $$(0 fby (@a'' + @c'') / 2.0 at @timer)
	this.c = $$(0 fby (@b'' + @d'') / 2.0 at @timer)
	this.d = 100
	'.
	this x.
	self assert: (this eval: 'this.b.currentValue()') = 0.
	self assert: (this eval: 'this.c.currentValue()') = 0.

	this sortAndEvaluateAt: 100.
	self assert: (this eval: 'this.b.currentValue()') = 50.0.
	self assert: (this eval: 'this.c.currentValue()') = 50.0.

	this sortAndEvaluateAt: 200.
	self assert: (this eval: 'this.b.currentValue()') = 75.0.
	self assert: (this eval: 'this.c.currentValue()') = 75.0.
	^ this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 4/3/2013 16:22'!
testManyUpdates2

	| this |
	this := KSObject new becomeUniClass.

	this evalToMethod: '
x = () ->
	this.timer = $$(timerE(100))
	this.a = $$(false fby !!@a'')
	this.b = $$(false fby !!@b on @timer)
	'.
	this x.
	this sortAndEvaluateAt: 100.
	self assert: (this eval: '@a') = false.
	self assert: (this eval: '@b') = true.
	this sortAndEvaluateAt: 200.
	self assert: (this eval: '@a') = false.
	self assert: (this eval: '@b') = false.
	^ this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 2/20/2013 15:15'!
testManyUpdates3

	| this |
	this := KSObject new becomeUniClass.

	this evalToMethod: '
x = () ->
	this.timer = $$(timerE(100))
	this.a = $$(false fby !!@b'' on @timer)
	this.b = $$(false fby !!@a'' on @timer)
	'.
	this x.
	this sortAndEvaluateAt: 100.
	self assert: (this eval: '@a') = true.
	self assert: (this eval: '@b') = true.
	this sortAndEvaluateAt: 200.
	self assert: (this eval: '@a') = false.
	self assert: (this eval: '@b') = false.
	this sortAndEvaluateAt: 300.
	self assert: (this eval: '@a') = true.
	self assert: (this eval: '@b') = true.
	this sortAndEvaluateAt: 400.
	self assert: (this eval: '@a') = false.
	self assert: (this eval: '@b') = false.
	^ this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 1/23/2013 21:54'!
testMergeStream

	| this |
	this := KSObject new becomeUniClass.

	this evalToMethod: '
x = () ->
	this.timer = $$(timerE(100))
	this.timer1 = $$(timerE(150))
	this.nat1 = $$(0 fby @nat1 + 1 at @timer)
	this.nat2 = $$(0 fby @nat2 - 1 at @timer1)
	this.m = $$(mergeE(@nat1, @nat2))
	'.
	this x.
	self assert: (this eval: 'this.m.type()') = 'mergeE'.
	self assert: (this eval: 'this.m.sources().size()') = 2.

	self assert: (this eval: '@nat1') = 0.
	self assert: (this eval: '@nat2') = 0.

	this sortAndEvaluateAt: 100.

	self assert: (this eval: '@nat1') = 1.
	self assert: (this eval: '@nat2') = 0.
	self assert: (this eval: '@m') = 1.

	this sortAndEvaluateAt: 199.
	self assert: (this eval: '@nat1') = 1.
	self assert: (this eval: '@nat2') = -1.
	self assert: (this eval: '@m') = -1.

	this sortAndEvaluateAt: 200.
	self assert: (this eval: '@nat1') = 2.
	self assert: (this eval: '@nat2') = -1.
	self assert: (this eval: '@m') = 2.

	this sortAndEvaluateAt: 300.
	self assert: (this eval: '@nat1') = 3.
	self assert: (this eval: '@nat2') = -2.
	self assert: (#(3 -2) includes: (this eval: '@m')).

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 2/20/2013 15:15'!
testNot

	| this |
	this := KSObject new becomeUniClass.

	this evalToMethod: '
x = () ->
	this.timer = $$(timerE(100))
	this.nat = $$(0 fby @nat'' + 1 at @timer)
	this.even = $$(@nat.mapE((x) -> x % 2 == 0))
	this.odd = $$(!!@even)
	'.
	this x.
	self assert: (this eval: 'this.odd.type()') = #exprE.
	self assert: (this eval: 'this.odd.sources().size()') = 1.

	"Hmm, actually, fby@ should propagate its 'change' to the initial value so dependencies should have the right value?"
	self assert: (this eval: 'this.even.currentValue()') = KSObject undefined.
	self assert: (this eval: 'this.odd.currentValue()') = KSObject undefined.

	this sortAndEvaluateAt: 100.
	self assert: (this eval: '@nat') = 1.
	self assert: (this eval: '@even') = false.
	self assert: (this eval: '@odd') = true.

	this sortAndEvaluateAt: 200.
	self assert: (this eval: '@nat') = 2.
	self assert: (this eval: '@even') = true.
	self assert: (this eval: '@odd') = false.
	^ this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 3/28/2013 14:12'!
testOneE

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: 
'x = () ->
	this.t = $$(oneE("foo"))
	this.s = $$(@t.mapE((x) -> x.concat("bar")))
	'.
	this x.
	self assert: (this eval: 'this.t.type()') == #oneE.
	self assert: (this eval: 'this.t.property("__subExpressions__")') = #().
	self assert: (this eval: '@t') = KSObject undefined.

	this sortAndEvaluateAt: 100.
	self assert: (this eval: '@t') = 'foo'.
	self assert: (this eval: '@s') = 'foobar'.

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 1/23/2013 23:03'!
testSwitchColE

	| this evaluator objs |
	this := KSObject new becomeUniClass.

	this evalToMethod: '
x = () ->
	this.item1 = {}
	this.item2 = {}
	this.item1.timer = $$(timerE(100))
	this.item2.timer = $$(timerE(150))
	this.item1.nat = $$(0 fby @nat'' + 1 at @timer)
	this.item2.nat = $$(0 fby @nat'' - 1 at @timer)
	this.collection = [this.item1, this.item2]
	this.m = $$(switchColE(@collection, "nat").mapE((x) -> x.asString()))
	'.
	this x.
	self assert: (this eval: 'this.m.type()') = 'mapE'.
	self assert: (this eval: 'this.m.sources().size()') = 2.

	self assert: (this eval: 'this.item1.nat.currentValue()') = 0.
	self assert: (this eval: 'this.item2.nat.currentValue()') = 0.

	objs := {this at: #item1. this. this at: #item2}.
	evaluator := KSDependencyEvaluator new.
	objs do: [:e | evaluator addStreamsFrom: e].
	evaluator at: #'__topObject__' put: this.
	evaluator sortAndEvaluateAt: 100.

	self assert: (this eval: 'this.item1.nat.currentValue()') = 1.
	self assert: (this eval: 'this.item2.nat.currentValue()') = 0.
	self assert: (this eval: 'this.m.currentValue()') = '1'.

	evaluator := KSDependencyEvaluator new.
	objs do: [:e | evaluator addStreamsFrom: e].
	evaluator at: #'__topObject__' put: this.
	evaluator sortAndEvaluateAt: 199.
	self assert: (this eval: 'this.item1.nat.currentValue()') = 1.
	self assert: (this eval: 'this.item2.nat.currentValue()') = -1.
	self assert: (this eval: 'this.m.currentValue()') = '-1'.

	evaluator := KSDependencyEvaluator new.
	objs do: [:e | evaluator addStreamsFrom: e].
	evaluator at: #'__topObject__' put: this.
	evaluator sortAndEvaluateAt: 200.
	self assert: (this eval: 'this.item1.nat.currentValue()') = 2.
	self assert: (this eval: 'this.item2.nat.currentValue()') = -1.
	self assert: (this eval: 'this.m.currentValue()') = '2'.

	evaluator := KSDependencyEvaluator new.
	objs do: [:e | evaluator addStreamsFrom: e].
	evaluator at: #'__topObject__' put: this.
	evaluator sortAndEvaluateAt: 300.
	self assert: (this eval: 'this.item1.nat.currentValue()') = 3.
	self assert: (this eval: 'this.item2.nat.currentValue()') = -2.
	self assert: (#('3' '-2') includes: (this eval: 'this.m.currentValue()')).

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 3/28/2013 14:13'!
testTimerAndMapStream

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: '
x = () ->
	this.t = $$(timerE(100).mapE((x) -> x / 10))
	'.
	this x.
	self assert: (this eval: 'this.t.type()') = #mapE.
	self assert: (this eval: 'this.t.property("__subExpressions__").size()') = 1.
	self assert: (this eval: 'this.t.sources().size()') = 1.
	self assert: (this eval: 'this.t.property("__subExpressions__")[0] == this.t.sources()[0].ref()').

	this sortAndEvaluateAt: 100.

	self assert: (this eval: 'this.t.lastValue()') = 10.
	self assert: (this eval: 'this.t.currentValue()') = 10.

	this sortAndEvaluateAt: 199.
	self assert: (this eval: 'this.t.currentValue()') = 10.

	this sortAndEvaluateAt: 200.
	self assert: (this eval: 'this.t.currentValue()') = 20.

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 4/11/2013 19:58'!
testTimerAndNaturalStream

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: '
x = () ->
	this.timer = $$(timerE(100))
	this.nat = $$(0 fby @nat'' + 1 on @timer)
	'.
	this x.
	self assert: (this eval: 'this.timer.type()') = #timerE.
	self assert: (this eval: 'this.timer.property("__interval__")') = 100.
	self assert: (this eval: 'this.timer.property("__subExpressions__")') = #().
	self assert: (this eval: 'this.timer.sources()') = #().

	self assert: (this eval: 'this.nat.type()') = #update.
	self assert: (this eval: 'this.nat.property("__subExpressions__").size()') = 1.
	self assert: (this eval: 'this.nat.property("__subExpressions__")[0] == "tt2"').
	self assert: (this eval: 'this.nat.sources().size()') = 2.
	self assert: (this eval: '(x.ref() for x in this.nat.sources())._contains("tt2")').
	self assert: (this eval: '(x.ref() for x in this.nat.sources())._contains("timer")').

	self assert: (this eval: 'this.nat.tt2.type()') = #exprE.
	self assert: (this eval: 'this.nat.tt2.property("__subExpressions__")') asBoolean = false.
"	self assert: (this eval: 'this.nat.tt2.__sources__.length') = 1."
	self assert: (this eval: '(x.ref() for x in this.nat.tt2.sources())._contains("timer")').

	this eval: 'this.sortAndEvaluateAt(100)'.

	self assert: (this eval: 'this.timer.type()') = #timerE.
	self assert: (this eval: 'this.timer.property("__interval__")') = 100.
	self assert: (this eval: 'this.timer.lastValue()') = 100.
	self assert: (this eval: 'this.timer.currentValue()') = 100.

	self assert: (this eval: 'this.nat.currentValue()') = 1.

	this sortAndEvaluateAt: 199.
	self assert: (this eval: 'this.nat.currentValue()') = 1.

	this sortAndEvaluateAt: 200.
	self assert: (this eval: 'this.nat.currentValue()') = 2.

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 3/28/2013 14:14'!
testTimerAndNaturalStreamsWithCollectE

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: '
x = () ->
	this.timer = $$(timerE(100))
	this.nat = $$(@timer.collectE(0, (x, y) -> y + 1))
	'.
	this x.
	self assert: (this eval: 'this.nat.type()') = #collectE.
	self assert: (this eval: 'this.nat.property("__subExpressions__").size()') = 0.
	self assert: (this eval: 'this.nat.sources().size()') = 1.
	self assert: (this eval: '(x.ref() for x in this.nat.sources()).contains("timer")').

	this sortAndEvaluateAt: 100.

	self assert: (this eval: 'this.timer.type()') = #timerE.
	self assert: (this eval: 'this.timer.property("__interval__")') = 100.
	self assert: (this eval: 'this.timer.lastValue()') = 100.
	self assert: (this eval: 'this.timer.currentValue()') = 100.

	self assert: (this eval: 'this.nat.currentValue()') = 1.

	this sortAndEvaluateAt: 199.
	self assert: (this eval: 'this.nat.currentValue()') = 1.

	this sortAndEvaluateAt: 200..
	self assert: (this eval: 'this.nat.currentValue()') = 2.

	this sortAndEvaluateAt: 300.
	self assert: (this eval: 'this.nat.currentValue()') = 3.

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 1/23/2013 23:02'!
testTimerEDuration

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: 
'x = () ->
	this.t = $$(timerEDuration(100, 1000))
	this.d = $$(@t / 10)
	'.
	this x.
	self assert: (this eval: 'this.t.type()') = #timerEDuration.
	self assert: (this eval: 'this.t.property("__interval__")') = 100.

	this sortAndEvaluateAt: 100.
	self assert: (this eval: 'this.t.currentValue()') = 0.

	this sortAndEvaluateAt: 401.
	self assert: (this eval: 'this.t.currentValue()') = 300.

	this sortAndEvaluateAt: 1000.
	self assert: (this eval: 'this.t.currentValue()') = 900.

	this sortAndEvaluateAt: 1100.
	self assert: (this eval: 'this.t.currentValue()') = 1000.

	this sortAndEvaluateAt: 1500.
	self assert: (this eval: 'this.t.currentValue()') = 1000.

	^this! !

!KSEventStreamTest methodsFor: 'tests' stamp: 'yo 3/28/2013 14:19'!
testTimerEStream

	| this |
	this := KSObject new becomeUniClass.
	this evalToMethod: '
x = () ->
	this.timer = $$(timerE(100))
	'.
	this x.
	self assert: (this eval: 'this.timer.type()') = #timerE.
	self assert: (this eval: 'this.timer.property("__interval__")') = 100.
	self assert: (this eval: 'this.timer.property("__subExpressions__")') = #().
	self assert: (this eval: 'this.timer.sources()') = #().

	this sortAndEvaluateAt: 100.
	self assert: (this eval: 'this.timer.type()') = 'timerE'.
	self assert: (this eval: 'this.timer.property("__interval__")') = 100.
	self assert: (this eval: 'this.timer.lastValue()') = 100.
	self assert: (this eval: 'this.timer.currentValue()') = 100.

	^this! !
