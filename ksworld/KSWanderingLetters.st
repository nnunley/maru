KSUserEventHandler subclass: #KSWanderingLetters
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:02'!
adoptLayout = (world) ->
	// only used in example1
	var topWorld = WTopLevelWorld._default()
	world.eval(() ->
		for charBox in this.whole.contents()
			var pos = charBox.handler.position.currentValue()
			topWorld.eval(() ->
				charBox.pivotPosition(P(pos.x, pos.y))
				)
		)
	this.whole.layoutChanged()! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/17/2012 10:24'!
applyLayout = (layoutWorld) ->
	var topWorld		= WTopLevelWorld._default()
	var charHandlers	= this.charHandlers
	var lboxes			= this.lboxes
	layoutWorld.eval(() ->
		for charIndex in [ 0 .. lboxes.size() ]
			var pos = charHandlers[charIndex].position.currentValue()
			topWorld.eval(() ->
				lboxes[charIndex].pivotPosition(P(pos.x, pos.y))
				)
		)! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/17/2012 10:24'!
field = () ->
	// only used in example1
	var string = 'Else if I am a word start and my predecessor\'s right plus my word\'s width is greater than the right margin, pursue the goal of being at the start of the next line. '		// final space is important

	this.inset			= P(2,2)
	this.leading			= 2
	this.firstCharPosition	=	{ x: this.inset.x(), y: this.inset.y()+10 }
	var charHandlers	= []
	var predHandler	= undefined
	for ind in [0 .. string.size()]
		var char = string[ind]
		var charBox = JBox._withShape(JBox.defaultFont().glyphAt(char))
		var charHandler = charBox.handlerAs(this.class())
		this.whole.add(charBox)
		charHandler.setUpChar(predHandler,this)
		predHandler = charHandler
		charHandlers.push(charHandler)

	var nextH				= undefined
	for charH in charHandlers.reversed()
		charH.widthToEnd	= if charH.isSpace then 0 else (if nextH then nextH.widthToEnd + charH.width else charH.width)
		nextH = charH

	charHandlers.last().setUpChoiceTrigger()
	this.charHandlers	= charHandlers

	this.timer = $$(timerE(200))
	this.widthChanger = $$(@timer.mapE((t) ->
		if t
			this.whole.width(100 + (t % 10000 / 50).asInteger())
			var posStream = charHandlers.last().position
			posStream.lastValue = posStream.__currentValue__
			posStream.lastTime = t
			posStream.__currentValue__ = undefined
			this.finished	= false
			this.layouts 	= [this.thisWorld().sprout()]
		))
	this.maxWidth	= $$(this.whole.width() fby @whole.width() at @timer)
	this.minWidth	= $$(@maxWidth fby @maxWidth * 0.7)
	this.lineEnds	= WCollection._new()
	this.layouts 	= [this._thisWorld().sprout()]! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/17/2012 10:24'!
fieldOfLBoxes = (textArea) ->
	// NB: assumes top-left inset of 2@2, and leading of 2
	// Also cuts off 30 pixels at the right.
	this.charHandlers	= []
	this.lboxes			= textArea.contents()
	if this.lboxes.size() == 0
		return
	this.inset				= P(2,2)
	this.leading			= 2
	this.firstCharPosition	=	{ x: this.inset._x(), y: this.inset.y()+this.lboxes.first().ascent() }
	var charHandlers	= this.charHandlers
	var predHandler	= undefined
	for ind in [0 .. this.lboxes.size()]
		var lbox = this.lboxes[ind]
		var charHandler = this.class()._new()
		charHandler.setUpLBoxChar(lbox,predHandler,this)
		predHandler = charHandler
		charHandlers._push(charHandler)
	var nextH				= undefined
	for charH in charHandlers.reversed()
		charH.widthToEnd	= if charH.isSpace then 0 else (if nextH then nextH.widthToEnd + charH.width else charH.width)
		nextH = charH
	charHandlers.last().setUpFinishTrigger()
	this.maxWidth		= textArea.extent()._x() - 30
	this.minWidth		= this.maxWidth - [300, this.maxWidth*0.25].min()
	this.lineEnds			= WCollection._new()
	this.layouts 			= [this._thisWorld().sprout()]! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:06'!
finishedLayout = () ->
	this.scoreLayouts()
	this.adoptLayout(this.layoutWithRank(1))! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/17/2012 10:24'!
layoutWithRank = (rank) ->
	if rank > this.layouts.size()
		undefined
	else
		this.scoreSortedLayouts[rank-1]! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:06'!
lineEndCoords = () ->
	// ** no longer used ** - replaced by recording each break as we go along
	var endCoords = []
	if this.charHandlers.isEmpty()
		return this.endCoords
	var prevY = undefined
	for char in this.charHandlers.reversed()
		if !!char.isSpace
			var charPos = char.position.currentValue()
			var posY = charPos.y
			if !!prevY || (posY < prevY)
				endCoords.push(P(charPos.x+char.width, posY))
				prevY = posY
	endCoords.reversed()! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'ael 6/12/2012 23:58'!
outlinePathForLayout: layoutWorld withOffset: rankOffset

	| endCoords lastY points offsetEnd coord newX newY |
	endCoords := layoutWorld eval: [ (self at: #lineEnds) as: OrderedCollection ].
	endCoords ifEmpty: [ ^ GeziraStrokedPath new points: {{0@0. 0@0. 0@0}} ].

	1 to: endCoords size do: [ :i |
		coord := endCoords at: i.
		newX := coord x - rankOffset.
		newY := (i = endCoords size or: [ (endCoords at: i + 1) x < coord x ])
			ifTrue: [ coord y - rankOffset ]
			ifFalse: [ coord y + rankOffset ].
		endCoords at: i put: newX @ newY.
		].
	points := OrderedCollection new.
	points add: rankOffset@rankOffset.
	lastY := rankOffset.
	endCoords do: [ :end |
		offsetEnd := end x @ (end y + 12).
		points add: offsetEnd x @ lastY.
		points add: offsetEnd.
		lastY := offsetEnd y.
		].
	points add: rankOffset@lastY.
	points add: rankOffset@rankOffset.
	^GeziraStrokedPath polyline: points.! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:15'!
placeInWorld = (toPlace, world) ->
	// we maintain a collection of alternative layouts (represented by worlds).
	// when we place a character that starts a word, there are three options
	//  1. if the word overflows the maximum line width, place it on the next line
	//  2. if the start of the word is within the minimum line width, place it on the current line
	//  3. otherwise split worlds, creating one in which the word is on the current line and one in which it is on the next
	var field				= toPlace.fieldHandler
	var predecessor	= toPlace.pred
	var predWidth 		= predecessor.width
	var isWordStart	= predecessor.isSpace && !!toPlace.isSpace
	var wordWidth		= toPlace.widthToEnd
	var posStream 		= toPlace.position
	var evalTime			= this.__currentTime__
	var layouts			= this.layouts
	world.eval(() ->
		var predPos			= predecessor.position.currentValue()
		var minWidth			= field.minWidth.currentValue()
		var maxWidth		= field.maxWidth.currentValue()
		var sameLinePos	= { x: predPos.x + predWidth, y: predPos.y }
		var pos					= sameLinePos
		if isWordStart
			var newLinePos		= { x: field.inset.x(), y: predPos.y + toPlace.lineSkip + field.leading }
			var wordEnd			= predPos.x + predWidth + wordWidth
			if wordEnd > maxWidth
				pos = newLinePos
				this.recordLineEnd(predecessor)
			else
				if predPos.x + predWidth > minWidth
					var newLineWorld = world.copy()
					layouts._push(newLineWorld)
					newLineWorld._eval(() ->
						posStream.lastValue = posStream.__currentValue__
						posStream.lastTime = evalTime
						posStream.__currentValue__ = newLinePos
						this.recordLineEnd(predecessor)
						)
		world.eval(() ->
			posStream.lastValue = posStream.__currentValue__
			posStream.lastTime = evalTime
			posStream.__currentValue__ = pos
			)
		)! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:07'!
placeWithAlternates = (toPlace) ->
	var layoutWorlds = this.layouts
	for world in layoutWorlds.copy()
		this.placeInWorld(toPlace,world)
	layoutWorlds.first().eval(() -> toPlace.position.__currentValue__)! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'ael 6/7/2012 22:48'!
privateSortLayouts: scoredLayouts
	^(scoredLayouts sort: [ :a :b | (a at: 1) <= (b at: 1) ]) collect: [ :tup | tup at: 2 ]! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:08'!
recordLineEnd = (lastChar) ->
	// lastChar is either the space before a line break, or the last character in the text.
	// If a space, search back for the first preceding non-space (or start of the text)
	var field = lastChar.fieldHandler
	var endChar = lastChar
	while endChar !!== undefined && endChar.isSpace
		endChar = endChar.pred
	var posObj
	var endPoint
	if endChar
		posObj = endChar.position.currentValue()
		endPoint = P(posObj.x + endChar.width, posObj.y)
	else
		posObj = field.firstCharPosition
		endPoint = P(posObj.x, posObj.y)
	field.lineEnds.add(endPoint)! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/17/2012 10:24'!
scoreLayouts = () ->
	// record the last line (which won't have been handled as a line break), then score the layout according to the line lengths
	// The "score" is in fact an accumulation of penalties.  The basic penalty is the sum of the squares of differences between lengths of successive lines.
	// The last line is treated specially: the squared difference is halved if the last line is shorter than that next-to-last, but doubled if it is longer.  In other words, short last lines are somewhat tolerated.
	var scoredLayouts	= []
	for layout in this.layouts
		var score = 0
		layout.eval(() ->
			this.recordLineEnd(this.charHandlers.last())
			var endCoords = this.lineEnds
			var numCoords = endCoords.size()
			for n in [1...numCoords-1]
				var diff = endCoords._at(n+1)._x() - endCoords._at(n).x()
				var factor = (if n == numCoords - 1 then (if diff > 0 then 2.0 else 0.5) else 1)
				score += diff.squared() * factor
			if numCoords > 1
				score = score / (numCoords - 1)
			)
		scoredLayouts.push([score, layout])
	this.scoreSortedLayouts = this.privateSortLayouts(scoredLayouts)
	this.layouts.size().asString().concat(' layouts  ').displayAt(P(10,800))! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'ael 7/6/2012 14:37'!
setUpChar = (predHandler,fieldHandler) ->
		// only used in example1
		if predHandler
			predHandler.next = this
			this.pred	= predHandler

		this.fieldHandler	= fieldHandler
		this.width				= this.whole.width()
		this.lineSkip			= this.whole._shape().lineSkip()
		this.isSpace			= this.whole._shape().isWhiteSpace()
		this.position			= if !!predHandler then fieldHandler.firstCharPosition else $$(undefined fby @fieldHandler.placeWithAlternates(this) at mergeE(@pred.position, @fieldHandler.maxWidth))

		this.setPosition	= $$(@position.mapE((pos) ->
			this.whole.pivotPosition(P(pos.x, pos.y))
			))! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:09'!
setUpChoiceTrigger = () ->
	this.trigger = $$(@position.mapE((x) ->
		if x then this.fieldHandler.finishedLayout()))! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:09'!
setUpFinishTrigger = () ->
	this.trigger = $$(@position.mapE((x) ->	
		if x then this.fieldHandler.finished = true))! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'ael 7/6/2012 14:37'!
setUpLBoxChar = (lbox,predHandler,fieldHandler) ->
	this.lbox				= lbox
	this.fieldHandler	= fieldHandler
	if predHandler
		predHandler.next = this
		this.pred	= predHandler
	this.width				= lbox.width()
	this.lineSkip			= lbox.shape().lineSkip()
	this.isSpace			= lbox.shape().isWhiteSpace()
	this.position			= if !!predHandler then fieldHandler.firstCharPosition else $$(undefined fby @fieldHandler.placeWithAlternates(this) at @pred.position)! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'ael 6/4/2012 23:13'!
stepAt = (evalTime) ->
	this.evaluateAt(evalTime)
	for handler in this.charHandlers
		handler.evaluateAt(evalTime)! !

!KSWanderingLetters methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:10'!
wrapRange = () ->
	[this.minWidth, this.maxWidth]! !

!KSWanderingLetters class methodsFor: 'as yet unclassified' stamp: 'yo 7/5/2012 20:12'!
example1
"
KSWanderingLetters example1
KSWanderingLetters example1 handler initForTracing; ksExplore
"
	| field ll |
	ll := JMorph new openInWorld extent: 300@200.
	ll window add: (field := JBox extent: 120@200 fill: Color white).
	field handlerAs: KSWanderingLetters.
	field handler field.
	^ field! !
