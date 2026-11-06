KSUserEventHandler subclass: #KSScriptor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSScriptor methodsFor: 'building' stamp: 'yo 2/12/2013 15:54'!
beDialog = (box) ->
	box.extent(P(400, 300))
	box.cornerRadius(8)
	box.borderWidth(1)
	box.fill(Color.white())
	box.borderFill(box.factory().theme.edgeColor)
	return box! !

!KSScriptor methodsFor: 'building' stamp: 'yo 2/12/2013 16:29'!
makeList = (factory) ->
	var list = this.listPane = factory.newList()
	list.factory = KSFactory.newFrom(factory)
	list.factory.theme.enteredFill = factory.theme.themeColor
	list.factory.theme.selectedFill = factory.theme.themeColor
	list.fill(Color.white())
	var scroller = factory.createVScrollerFor(list)
	scroller.fill(list.fill())
	list.borderWidth(0)
	scroller.borderFill(factory.theme.borderColor)
	scroller.borderWidth(1)
	scroller.name("listPane")
	return scroller! !

!KSScriptor methodsFor: 'building' stamp: 'yo 2/12/2013 16:54'!
makePane = (factory) ->
	var pane = factory.newTextField()
	pane.fill(Color.white())
	pane.borderWidth(1)
	pane.borderFill(factory.theme.borderColor)
	pane.clipping(true)
	return pane! !

!KSScriptor methodsFor: 'building' stamp: 'yo 3/7/2013 18:52'!
makeTitle = (factory) ->
	var child = factory.newLabel("name")
	child.layout().inset(P(20, 5))
	var header = KSBox._extent_fill(P(100, 20), factory.theme.themeColor)
	header.add(child)
	header.cornerRadius(8)
	header.name("title")
	return header! !

!KSScriptor methodsFor: 'initialization' stamp: 'yo 3/7/2013 18:52'!
behavior = () ->
	this.selection = this.streamOf(undefined)
	this.timer = $$(timerE(1000))

	delete this.listPane.doAction
	this.updateList = $$(mergeE(@target, @timer).doE(() ->
		var keys = @target.keys().sorted()
		if keys !!= this.keys
			this.keys = keys
			this.listPane.setItems(([b, b] for b in keys))))

	this.listSelected = $$(@listPane.itemSelected.mapE((ev) ->
		this.selection.set(ev.handler.textContents())))

	this.defPaneAccepted = $$(@defPane.contentsAccepted.mapE((ev) ->
		try
			@target.eval(ev.handler.textContents())
		catch e
			Transcript.show("error: ".concat(e.printString())).cr()))

	this.valuePaneAccepted = $$(@valuePane.contentsAccepted.mapE((ev) ->
		try
			@target[@selection].set(@target.eval(ev.handler.textContents()))
		catch e
			Transcript.show("error: ".concat(e.printString())).cr()))

	this.evalPaneAccepted = $$(@evalPane.contentsAccepted.mapE((ev) ->
		try
			@target.eval(ev.handler.textContents())
		catch e
			Transcript.show("error: ".concat(e.printString())).cr()))

	this.selectionWatcher = $$(mergeE(@timer, @selection).doE(() ->
		var obj = @target[@selection]
		if obj.isEventStream()
			var newString =  "$$(".concat(obj.code()).concat(")")
			if this.defPane.textContents() !!= newString
				this.defPane.textContents(newString)
		else
			newString = obj.ksString()
			if this.defPane.textContents() !!= newString
				this.defPane.textContents(newString)
		newString = obj.currentValue().ksString()
		if this.valuePane.textContents() !!= newString
			this.valuePane.textContents(newString)))

	this.titleString = $$(mergeE(@target.name, @target.transformation).doE(() ->
		@target.name() ? @target.printString())).startsWith(@target.printString())
	this.titleWatcher = $$(this.titleLabel.textContents(@titleString))

	this.title.beDraggerFor(@whole)! !

!KSScriptor methodsFor: 'initialization' stamp: 'yo 3/7/2013 18:52'!
build = (target) ->
	this.target = this.streamOf(target)
	var factory = target.factory()
	this.beDialog(@whole)

	this.title = this.makeTitle(factory)
	@whole.add(@title)
	this.titleLabel = @title.first()

	this.listScroller = this.makeList(factory)
	@whole.add(this.listScroller)

	this.defPane = this.makePane(factory)
	this.defPane.name("defPane")
	this.defPaneScroller = factory.createVScrollerForText(this.defPane)
	this.defPaneScroller.name("defPaneScroller")
	@whole.add(this.defPaneScroller)

	this.valuePane = this.makePane(factory)
	this.valuePane.name("valuePane")
	this.valuePaneScroller = factory.createVScrollerForText(this.valuePane)
	this.valuePaneScroller.name("valuePaneScroller")
	@whole.add(this.valuePaneScroller)

	this.evalPane = this.makePane(factory)
	this.evalPane.name("evalPane")
	this.evalPaneScroller = factory.createVScrollerForText(this.evalPane)
	this.evalPaneScroller.name("evalPaneScroller")
	@whole.add(this.evalPaneScroller)

	this.behavior()

	@whole.layout(this.layout())! !

!KSScriptor methodsFor: 'initialization' stamp: 'yo 2/22/2013 15:11'!
layout
	^ KSSimpleLayout new
		keep: #height of: 'title' to: 20;
		keep: #width of: 'title' to: #width;
		keep: #topLeft of: 'listPane' to: #bottomLeft of: 'title';
		keep: #height of: 'listPane' to: #height scale: 0.8 offset: -20;
		keep: #right of: 'listPane' to: #width scale: 0.34;

		keep: #topLeft of: 'defPaneScroller' to: #topRight of: 'listPane';
		keep: #right of: 'defPaneScroller' to: #right;
		keep: #height of: 'defPaneScroller' to: #height scale: 0.4 offset: -10;

		keep: #topLeft of: 'valuePaneScroller' to: #bottomLeft of: 'defPaneScroller';
		keep: #right of: 'valuePaneScroller' to: #right;
		keep: #height of: 'valuePaneScroller' to: #height scale: 0.4 offset: -10;

		keep: #topLeft of: 'evalPaneScroller' to: #bottomLeft of: 'listPane';
		keep: #right of: 'evalPaneScroller' to: #right;
		keep: #bottom of: 'evalPaneScroller' to: #bottom;
		yourself! !

!KSScriptor class methodsFor: 'as yet unclassified' stamp: 'yo 2/12/2013 15:50'!
example1
"
	KSScriptor example1
"
	| ks target |
	target := KSBox withShape: (KSFactory default scaleIcon).
	target topLeft: 20@20.
	ks := KSMorph new openInWorld extent: 600@400.
	ks window add: target.
	target inspect: nil! !
