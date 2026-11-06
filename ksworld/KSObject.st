KSProtoObject subclass: #KSObject
	instanceVariableNames: ''
	classVariableNames: 'EventNameMap'
	poolDictionaries: ''
	category: 'KSObjects'!

!KSObject methodsFor: 'basics' stamp: 'yo 3/14/2013 11:27'!
doesNotUnderstand: aMessage
	"If the message selector does not find in the regular method dictionary, it looks up it from the receiver and try to evaluate it."
	| sel |
	sel := aMessage numArgs = 0
		ifTrue: [aMessage selector]
		ifFalse: [(aMessage selector copyFrom: 1 to: (aMessage selector indexOf: $:) - 1) asSymbol].
	self at: sel ifPresent: [:p |
		p isBlock ifTrue: [^ p ksValueWithEnoughArguments: {self}, aMessage arguments].
		^ super error: 'Not a function: ', p printString].
	^ super doesNotUnderstand: aMessage! !

!KSObject methodsFor: 'basics' stamp: 'yo 8/16/2013 10:11'!
handler = () ->
	return this.handler! !

!KSObject methodsFor: 'basics' stamp: 'yo 3/14/2013 11:42'!
hasOwnProperty = (prop) ->
	"See if prop is a key exists in the receiver locally."
	return this.includesKey(prop.asKSKey())! !

!KSObject methodsFor: 'basics' stamp: 'yo 3/14/2013 11:31'!
installTo = (anObject) ->
	anObject.handler = this
	this.whole = anObject
	return this! !

!KSObject methodsFor: 'basics' stamp: 'yo 10/10/2012 11:31'!
installTo: anObject
	anObject at: #handler put: self.
	self at: #whole put: anObject.! !

!KSObject methodsFor: 'basics' stamp: 'yo 8/14/2013 20:17'!
ksAssign: key with: val
	self at: key ifPresent: [:o |
		o isEventStream
			ifTrue: [o set: val. ^ val]].
	self ksAt: key put: val.
	^ val! !

!KSObject methodsFor: 'basics' stamp: 'yo 3/14/2013 11:48'!
ksAt: key
	"Look up key in receiver and its prototype chain.  Currently, however, we don't use __proto__ for."
	^ self at: key ifAbsent: [
		self at: #'__proto__' ifPresent: [:proto | ^ proto ksAt: key].
		Undefined]! !

!KSObject methodsFor: 'basics' stamp: 'yo 4/12/2013 21:09'!
ksAt: key put: val
	"Set the value for the key locally.  When val is a stream, make sure its homeObject is set to this owner object.  Also detect that the update is involved in self -referencing, and remove it from its dependencies."
	self at: key put: val.
	val isEventStream ifTrue: [val homeObject: self].
	^ val! !

!KSObject methodsFor: 'explorer' stamp: 'ael 1/11/2013 14:07'!
explorerContents
	| itemName leftSize maxLen print |
	^self keysSortedSafely replace: [ :key |
		itemName := key isSymbol
				ifTrue: [ key ]
				ifFalse: [
					print := key printString.
					maxLen := 50.
					print size > maxLen
						ifFalse: [ print ]
						ifTrue: [
							"contract with an identityHash, to help distinguish objects with long similar printStrings"
							leftSize := maxLen-12//2.
							print copyReplaceFrom: leftSize+1
								to: print size - (maxLen - leftSize - 12)
								with: '...[', key identityHash asString, ']...'
							]
					].
		ObjectExplorerWrapper
			with: (self at: key)
			name: itemName
			model: self ]! !

!KSObject methodsFor: 'explorer' stamp: 'ael 2/1/2013 14:19'!
hasContentsInExplorer = () ->
	true! !

!KSObject methodsFor: 'explorer' stamp: 'ael 1/8/2013 23:26'!
ksExplore
	(KSObjectExplorer new rootObject: self) open.! !

!KSObject methodsFor: 'explorer' stamp: 'ael 5/3/2012 18:02'!
ksInspect
	(KSEventStreamInspector new object: self) open.! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/14/2013 13:35'!
addEvent = (key, anObject) ->
	// A special case for adding a synthesized event such as pointer enter and pointer leave.
	if this[key]
		this[key].set(anObject)! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/27/2012 20:48'!
attachButtonHandler = function(box) {
	this.actsWhen = "buttonUp";
	this.pressed = $$(false fby mergeE(!!!!buttonDown, !!buttonUp, !!pointerLeave));
	this.entered = $$(false fby mergeE(!!!!pointerEnter, !!pointerLeave))
	this.selected = false;
	this.highlightEnabled = true;

	this.fire = $$(mergeE(
		actsWhen == "buttonUp" && click,
		actsWhen == "buttonDown" && buttonDown).mapE(function(x) {return x ? x : undefined}));

	this.look = $$(mergeE(
		(entered && highlightEnabled).mapE(function(x) {
			if (x) {this.ksPerform("enteredLook")}
			else {this.ksPerform("defaultLook")}}),
		(pressed && highlightEnabled).mapE(function(x) {
			if (x) {this.ksPerform("pressedLook")}
			else {this.ksPerform("defaultLook")}})));

	this.defaultLook = function() {
		if (this.defaultFill) {box._fill(this.defaultFill)};
		if (this.defaultBorderFill) {box._fill(this.defaultBorderFill)};
	}
	this.enteredLook = function() {
		if (!!this.defaultFill) {this.defaultFill = box._fill()};
		box._fill(this.enteredFill ? this.enteredFill : (this.defaultFill._mixed_with(0.5, GeziraFill._uniform(Color._white()))));
		if (this.enteredBorderFill) {box._borderFill(this.enteredBorderFill)}	
	}
	this.pressedLook = function() {
		box._fill(this.pressedFill ? this.pressedFill : (this.defaultFill._mixed_with(0.5, GeziraFill._uniform(Color._red()))));
		if (this.pressedBorderFill) {box._borderFill(this.pressedBorderFill)}	
	}

	this.buttonDown = $$(extractE($(box), "buttonDown"))
	this.buttonUp = $$(extractE($(box), "buttonUp"))
	this.pointerLeave = $$(extractE($(box), "pointerLeave"))
	this.pointerEnter = $$(extractE($(box), "pointerEnter"))
	this.click = $$(buttonUp.mapE(function(x) {return this.pressed.currentValue() ? x :  undefined}))
	box._ksHandler()._wantsPointerMotion(true);
	return this;
}! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/26/2012 15:35'!
beMoveHandler = function(box, downFunc, moveFunc, upFunc) {
	var upFunc2 = 		function(x) {x.hand._focus(null); x.object._unsubscribe_for(this, LMotionEvent); if (upFunc) {upFunc(x)}}
	var moveFunc2 = 	function(x) {if (moveFunc) {moveFunc(x)}}
	var downFunc2 = 	function(x) {x.hand._focus(x.object); x.object._on_to(LMotionEvent,  x.object._ksHandler()); if (downFunc) {downFunc(x)}}
	this.buttonDown =	$$(extractE($(box), "buttonDown").mapE($(downFunc2)))
	this.pointerMotion = $$(extractE($(box), "pointerMotion").mapE($(moveFunc2)));
	this.buttonUp = 	$$(extractE($(box), "buttonUp").mapE($(upFunc2)));
}! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/12/2012 19:07'!
collectE = function(behavior, init, func) {
	var obj = new KSEventStream();
	var src = obj.dependenciesFrom([behavior, init, func]);
	obj.sources = src;
	obj.func = func;
	obj.updater = function (space) {
		return (space.frpGet(obj.func))
			(space.frpGet(obj.sources[0]), obj.__currentValue__ === undefined
									? obj.initialValue
									: obj.currentValue())};
	obj.initialValue = init;
	obj.type = "collectE";
	obj.__currentValue__ = undefined;
	obj.lastValue = undefined;
	obj.lastTime = -1;
	return obj;
}! !

!KSObject methodsFor: 'frp' stamp: 'yo 9/6/2012 16:31'!
copyWith = (key, value) ->
	var newThis = this.copy()
	newThis[key] = value
	return newThis! !

!KSObject methodsFor: 'frp' stamp: 'yo 9/10/2013 13:39'!
dependencyEvaluatorClass = () ->
	if this.twinkler
		return KSTwinkleEvaluator
	else
		return KSDependencyEvaluator! !

!KSObject methodsFor: 'frp' stamp: 'yo 8/30/2012 13:16'!
evaluateAt = (time) ->
	var sorter =  new KSDependencyEvaluator()
	sorter.__topObject__ = this
	sorter.addStreamsFrom(this)
	if this.handler
		sorter.addStreamsFrom(this.handler)
	sorter.evaluateAt(time)! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/14/2013 14:23'!
eventStream = (selector, code, extraDep, arguments) ->
	// When selector is a known combinator name, it creates that type of combinator.  If not, it falls back the general expression combinator and creates it.
	var sel = selector.concat(":with:with:with:").asSymbol()
	if !!this.class().eventStreamClass().canUnderstand(sel)
		sel = #"exprE:with:with:with:"
	return this.class().eventStreamClass().new()._perform_with_with_with_with(sel, selector, code, extraDep, arguments)! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/12/2012 21:12'!
expr = function(f, r, args) {
	var obj = new KSEventStream();
	var src = obj.dependenciesFrom([r].concat(args));
	obj.sources = src;
	obj.updater = function(space) {
		return space.frpGet(r).ksPerform2(f, args.map(function(x) {return space.frpGet(x)}));
	}
	obj.type= "expr";
	obj.__currentValue__ = undefined;
	obj.lastValue = undefined;
	obj.lastTime = -1;
	return obj;
}! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/14/2013 14:31'!
frpGet = (n) ->
	// look up the actual stream for given EventStreamRef and returns its current value if Ref is not refering to the previous value, or returns last value if it is.
	var v = this.lookup(n)
	var last = n.isEventStreamRef() && n.last()
	if v.isEventStream() && last
		return v.lastValue()
	return v.currentValue()! !

!KSObject methodsFor: 'frp' stamp: 'yo 4/11/2012 20:56'!
frpGetLast = (n) ->
	var v = this.lookup(n)
	if v._isEventStream() then v.lastValue else v! !

!KSObject methodsFor: 'frp' stamp: 'yo 4/11/2012 20:47'!
isEventStream
	^ false! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/14/2013 14:31'!
lookup = (n) ->
	// look up the actual stream for given EventStreamRef.
	if n.isEventStreamRef()
		var v = this[n.ref()]
		if v.isEventStream() && v.type() === #"getE"
			return v.findForGet(this)
		else
			return v
	else
		return n! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/28/2013 15:02'!
lookupForSort = (n) ->
	// look up the actual stream for given EventStreamRef.
	if n.isEventStreamRef()
		return this[n.ref()]
	else
		return n! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/14/2013 14:33'!
preferredTimeFrom = (time) ->
	// Maps the physical time to a logical time that the receiver as the time bubbles top object.
	return if this.preferredTimeFunction then this.preferredTimeFunction(time) else time! !

!KSObject methodsFor: 'frp' stamp: 'yo 7/3/2012 22:33'!
resetTimeFor = (symbol) ->
	for s in this.__sources__
		if s._ref() === symbol
			this.lastTime = 0
	for ss in this
		if ss.isEventStream()
			ss.resetTimeFor(symbol)! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/9/2012 19:03'!
shouldEvaluate = function(formula) {
	var that = this;
	if (formula.type == "callValueNow") {return false;}
	var eventSources = formula.sources._filter(function(x) {return that[x.ref] instanceof KSEventStream});
	for (var i = 0; i < eventSources.length; i++) {
	  if (!!that[eventSources[i].ref]) {return false;}
	}
	if (eventSources.length == 0 && formula.lastTime == -1) {return true;}
	for (var i = 0; i < eventSources.length; i++) {
	  if (that[eventSources[i].ref].lastTime > (formula.lastTime ? formula.lastTime : -1)) {return true;}
	}
	return false;
}! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/9/2012 14:14'!
shouldTrigger = function(formula, time) {
	var type = formula.type;
	if (type == "timerE" && (formula.lastTime == null || (formula.lastTime + this.frpGet(formula.interval) <= time))) {return true;}
	if (type == "oneE" && (formula.lastTime == null)) {return true;}
	return false;
}! !

!KSObject methodsFor: 'frp' stamp: 'yo 9/10/2013 11:04'!
sortAndEvaluateAt = (time) ->
	// evaluate streams in the receiver and its handler at given logical time.
	var sorter =  this.dependencyEvaluatorClass().new()
	sorter.__topObject__ = this
	sorter.addStreamsFrom(this)
	if this.handler
		sorter.addStreamsFrom(this.handler)
	sorter.sortAndEvaluateAt(time)! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/14/2013 14:34'!
streamOf = (val) ->
	// creates a behavior that starts with val.
	return this.class().eventStreamClass().of(val).beBehavior()! !

!KSObject methodsFor: 'frp' stamp: 'yo 4/11/2012 21:05'!
syncValues = () ->
	for elem in this.sortedFormulae()
		elem.sync()! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/9/2012 15:46'!
timerE = function(interval) {
	var obj = new KSEventStream();
	var src = obj.dependenciesFrom([interval]);
	obj.sources = src;
	obj.type = "timerE";
	obj.interval = interval;
	obj.__currentValue__ = undefined;
	obj.lastValue = undefined;
	obj.lastTime = -1;
	return obj;
}! !

!KSObject methodsFor: 'frp-test' stamp: 'yo 4/17/2012 23:30'!
buttonTest = () ->
	var aBox = LBox._newLabel("push me")
	var bBox = LBox._new()
	this.whole._add(aBox)
	this.whole._add(bBox)
	bBox._x(100)

	this.aBox = aBox.eventHandler().attachButtonHandler()
	this.bBox = bBox
	this.script = $$(@aBox.fire.mapE((x) -> @bBox._rotateBy(0.2)))
	this

/*
(LesserphicMorph new openInWorld window ksObject buttonTest: {}) ksInspect
*/! !

!KSObject methodsFor: 'frp-test' stamp: 'yo 4/17/2012 21:43'!
colorPickerTest = () ->
	var picker = LBox._new()
	picker.eventHandler().beColorPickerHandler(Color._green()._muchDarker()._alpha(0.7))
	this.whole._add(picker)! !

!KSObject methodsFor: 'frp-test' stamp: 'yo 3/12/2012 21:48'!
myTest = function() {
	this.$$("a", this.collectE(t + 20, 0, function (x, y) {return x + y}));
	this.$$("t", this.timerE(100));

	this.evaluateAt(100);
	this.evaluateAt(200);
	this.evaluateAt(300);
	//return this;
	return this.a.currentValue()
}! !

!KSObject methodsFor: 'frp-test' stamp: 'yo 4/11/2012 23:48'!
sliderTest = () ->
	var slider = LBox._extent_color(Point._x_y(20, 200), Color._yellow()._darker())
	slider.newKsObject().addSliderHandler()
	slider._topLeft(Point._x_y(10, 10))
	this.whole._add(slider)

/*
(LesserphicMorph new openInWorld window ksObject sliderTest: {}) ksInspect
*/! !

!KSObject methodsFor: 'library' stamp: 'yo 7/3/2012 11:05'!
fib = (n) ->
	if n < 2
		n
	else
		this.fib(n-1) + this.fib(n - 2)! !

!KSObject methodsFor: 'library' stamp: 'yo 7/3/2012 11:13'!
fibs: n
	^ n < 2
		ifTrue: [n]
		ifFalse: [(self fibs: n - 1) + (self fibs: n - 2)]! !

!KSObject methodsFor: 'library' stamp: 'yo 3/9/2012 13:12'!
lastId = function() {
	var max = 0;
	for (var k in this) {
		if (k.substr(0, 2) == "tt") {
			var v = (k.substr(2))._toNumber();
			max = max > v ? max : v;
		}
	}
	return max;
}! !

!KSObject methodsFor: 'printing' stamp: 'ael 1/11/2013 13:32'!
ksPrintOn: aStream
	| sorted value |
	self class == KSObject ifFalse: [ aStream nextPutAll: self class name; space ].
	aStream nextPutAll: '{'.
	sorted := self keys.
	sorted := [sorted sorted] on: Error do: [sorted].
	sorted do: [:k |
		aStream nextPutAll: k asString; nextPutAll: ': '.
		value := self at: k.
		value ppIsLiteral
		 	ifTrue: [ value ksPrintOn: aStream ]
			ifFalse: [ aStream nextPutAll: '...']
		] separatedBy: [aStream nextPutAll: ', '].
	aStream nextPutAll: '}'! !

!KSObject class methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/11/2013 10:30'!
ppNewWithSexp: sexp
	^ self new: (self sizeFor: sexp elements size)! !

!KSObject class methodsFor: 'initialization' stamp: 'yo 5/8/2013 11:57'!
initialize
"
	KSObject initialize
"
	EventNameMap := KSObject new.
	EventNameMap
		at: #buttonDown put: 1;
		at: #pointerMotion put: 2;
		at: #buttonUp put: 3;
		at: #doubleClick put: 3;
		at: #keyDown put: 1;
		at: #keyStroke put: 2;
		at: #keyUp put: 3;
		at: #motionQuery put: 1;
		at: #pointerEnter put: 1;
		at: #pointerLeave put: 2;
		at: #dropFiles put: 3;
		at: #extent put: 3;
		at: #bounds put: 3;
		yourself.
	KSObject withAllSubclasses
		do: [:cls | cls compileAll]
		displayingProgress: [:cls | 'Recompiling ', cls name].! !

!KSObject class methodsFor: 'instance creation' stamp: 'yo 10/10/2012 11:32'!
installTo: anObject
	^ self new installTo: anObject! !

!KSObject class methodsFor: 'instance creation' stamp: 'yo 1/10/2013 22:14'!
ksNew: args
	| inst |
	inst := self new.
	args do: [:arg |
		arg ksLocalKeys do: [:k |
			inst ksAt: k put: (arg ksAt: k)]].
	^ inst! !
