KSProtoObject subclass: #KSObject
	instanceVariableNames: ''
	classVariableNames: 'EventNameMap'
	poolDictionaries: ''
	category: 'KSObjects'!

!KSObject commentStamp: 'tk 1/29/2013 16:16' prior: 0!
-	The base syntax (without FRP) is not so unlike JavaScript, but the
	indentation is now significant (off-side rule):
----------------------------
   if 3 > 4
       this.doThis()
       this.doThat()
   else
       this.doThis()
       this.doThat()
----------------------------

-	If the clauses are one expression, you can write them in one line as
	an expression.  In that case, keyword "then" is needed:
----------------------------
   result = if 3 > 4 then this.doThis() else this.doThat()
----------------------------

-	The main loop construct is "for", and there are some variations.  In
	the "range" variation you can say the range in the form of start and
	end (but exclusively, using two dots):
----------------------------
var y = 0
for x in [0 .. 10]
       y += x
y // => 45
----------------------------
	or inclusively, using three dots:
----------------------------
var y = 0
for x in [0 ... 10]
       y += x
y // => 55
----------------------------
	You can specify the step with the "by" keyword.
----------------------------
var y = 0
for x in [10 ... 0] by -1
       y += x
y // => 55
----------------------------	
	Regular Arrays (behave like OrderedCollections of Smalltalk) can be
	iterated over:
----------------------------
var list = [1, 2, 3, 4]
var y = 0
for k in list
       y += k
y  // => 10
----------------------------
	For KSObjects (keys and values) you say "for k, v of obj":
	where k,v refers to a key-value pair in obj.
----------------------------
var obj = {a: 1, b: 2, c: 3}
var found = undefined
for k, v of obj
       if v == 3
               found = k
               break
found // => "c"
----------------------------
	(Yes, you can say "break" to exit the loop, but there is no
	"continue".)

	There are also analog of #select:thenCollect: (i.e., a variation of
	list comprehension): For KSObjects (keys and values) you say 
	"for k, v of obj":
----------------------------
(n * 2 for n in [1, 2, 3, 4] when n !!= 3)
// => [2, 4, 8]
----------------------------
	When "when" is omitted, it is just like #collect:.  The parenthesis
	around the above expression are significant.  (I have not implemented
	the case when the head expression is actually more then one
	expression yet.)

	The analog of #detect: can be written similarly:
----------------------------
(n in [3, 4, 5] when n \\ 2 == 0)
// => 4
----------------------------

-	Functions look like:
----------------------------
(x, y) -> x + y
----------------------------
	when they are short and can be written in one line.  When one is
	long, it looks like:
----------------------------
(x, y) ->
   var t = x + y
   t * 2
----------------------------
	The value from the last expression will be returned.

	The syntax to call a function is just like JavaScript (not like
	CoffeeScript; as omitting parenthesis there seems excessive to me):
----------------------------
var foo
foo = (x, y) ->
   var t = x + y
   t * 2
foo(3, 4)  // => 14
----------------------------

-	The object literal format is just like JavaScript.  (not the one
	without curly braces):
----------------------------
var foo = {x: 1, y: 2}
----------------------------

-	There is not "?:" expression.  You just use "if" for that purpose,
	just like Smalltalk.  There is a different "?" operator (existential
	operator).
----------------------------
var newList = oldList ? []
----------------------------
 or,
----------------------------
list ?= []
----------------------------
	(It is just like #ifNil: of Smalltalk.)

	This is about it.

- 	For the FRP stuff, I use "@" sign to mean the loose-coupled namespace
	look up, and $$(...) creates a tree of event streams from all the sub-expressions.
----------------------------
this.selected = $$(@selectionChangeRequested == true)
this.selectionChangeRequested = $$(@__container__.itemSelected.mapE((x) -> x.item === this.whole))
this.isListItem = true
this.highlightEnabled = $$(true fby @isListItem && !!@selected)
----------------------------
	In the above, "@selectionChangeRequested" in the first line refers
	to the stream bound to "this.selectionChangeRequested" created in
	the second line.  The stream created in the second line depends on
	the __container__.itemSelected, and whenever the dependency changes,
	it is updated.  And so on. The "fby" indicates the initial value ("followed-by").

-	You can also refer to a filed name dynamically synthesized.  The syntax for it is @[...]
----------------------------
	this.y = $$(@[x + 1])
	this.y = $$(@[@x + 1])
----------------------------

In the first line, x+1 is computed at the stream creation time.  In the second line, the value of @x will be looked up.

	The @ notation can be used outside of "$$(...)" quotation.  In that
	case, the "current value" of the referred entity (a stream or regular
	value) will be retrieved.
	
----------------------------
	remove a property
	delete this.hasNavBar

----------------------------
	There is no syntax for Literal blocks as args for (collect: [ ] ifAbsent: [ ] ).  Make the method be a Squeak method instead.
	
----------------------------!

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

!KSObject methodsFor: 'frp' stamp: 'yo 9/10/2013 13:39'!
dependencyEvaluatorClass = () ->
	if this.twinkler
		return KSTwinkleEvaluator
	else
		return KSDependencyEvaluator! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/14/2013 14:23'!
eventStream = (selector, code, extraDep, arguments) ->
	// When selector is a known combinator name, it creates that type of combinator.  If not, it falls back the general expression combinator and creates it.
	var sel = selector.concat(":with:with:with:").asSymbol()
	if !!this.class().eventStreamClass().canUnderstand(sel)
		sel = #"exprE:with:with:with:"
	return this.class().eventStreamClass().new()._perform_with_with_with_with(sel, selector, code, extraDep, arguments)! !

!KSObject methodsFor: 'frp' stamp: 'yo 3/14/2013 14:31'!
frpGet = (n) ->
	// look up the actual stream for given EventStreamRef and returns its current value if Ref is not refering to the previous value, or returns last value if it is.
	var v = this.lookup(n)
	var last = n.isEventStreamRef() && n.last()
	if v.isEventStream() && last
		return v.lastValue()
	return v.currentValue()! !

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
