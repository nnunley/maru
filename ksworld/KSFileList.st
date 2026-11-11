KSUserEventHandler subclass: #KSFileList
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSFileList commentStamp: 'ael 3/15/2013 15:59' prior: 0!
Here is a set of do its in KScript to set up a File List:

this.container().add(this.factory().createVScrollerFor(this))

For file name box:
this.fill(Color.white())
this.borderWidth(1)
this.borderFill(this.factory().theme.borderColor)

For directory name box:
this.fill(Color.white())
this.borderWidth(0)
this.beReadOnly(true)

For two buttons:
	var font =KSFamily.withName("DejaVuSans").withStyle(1).withSize(11).fill(this.factory().theme.iconColor)
	this.reLabel("Button", Color.transparent(), nil, font, nil)
	this.layout().inset(2)
	this.borderWidth(0.5)
	this.cornerRadius(4)
	this.defaultFill = Color.transparent()
	this.enteredFill = this.factory().buttonGradient()
	this.pressedFill = this.factory().theme.contrastColor
	this.defaultBorderFill = Color.transparent()
	this.enteredBorderFill = this.factory().theme.iconColor

For the shortcut and file lists:
	this.factory = KSFactory.newFrom(this.factory())
	this.factory.setListFillsFromTheme()
	this.fill(Color.white())
	this.container().fill(this.fill())
	this.borderWidth(0)
	this.container().borderFill(this.factory.theme.borderColor)
	this.container().borderWidth(1)
	
For the title label:
	var font =KSFamily.withName("DejaVuSans").withStyle(1).withSize(11).fill(this.factory().theme.iconColor)
	this.layout().font = font
	this.layout().inset(P(20, 5))
	this.layout().beReadOnly(true)
	this.container().fill(this.factory().theme.themeColor)
	this.container().cornerRadius(8)
	this.fill(Color.transparent())

Give names For the file list pane:
	this.container().name("fileListScroller")
	this.name("fileList")
	this.container().container().fileList = this

Give names For the shortcut list pane:
	this.container().name("shortcutListScroller")
	this.name("shortcutList")
	this.container().container().shortcutList = this

Give names For the accept button:
	this.name("accept")
	this.container().acceptButton = this

Give names For the cencel button:
	this.name("cancel")
	this.container().cancelButton = this
	this.textContents("Cancel")

Give names For the file name field:
	this.name("nameField")
	this.container().nameField = this

Give names For the directory name field:
	this.name("directoryField")
	this.container().directoryField = this

Give names For the title field:
	this.name("label")
	this.container().container().label = this
	this.container().name("titleBar")
	this.container().container().titleBar = this.container()

Give names For the FileList:
	this.name("FileList")!

!KSFileList methodsFor: 'building' stamp: 'yo 1/30/2013 10:38'!
beDialogExtent = (box, aPoint) ->
	box.cornerRadius(8)
//	box shadowFill: (GeziraFill uniform: (Color black alpha: 0.3)).
//	box shadowOffset: 4@4.
//	box shadowBlur: 5.
	box.borderWidth(1)
	box.borderFill(box.factory().theme.edgeColor)
	return box! !

!KSFileList methodsFor: 'building' stamp: 'yo 1/30/2013 10:43'!
makeButton = (factory, name) ->
	var button = factory.newToolButton("button")
	button.layout().font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(13).fill(factory.theme.iconColor)
	button.name(name)
	return button! !

!KSFileList methodsFor: 'building' stamp: 'yo 1/30/2013 10:39'!
makeDirectoryField = (factory) ->
	var directoryField = KSBox.new()
	directoryField.name('directoryField')
	directoryField.fill(Color.white())
	directoryField.borderWidth(0)
	return directoryField! !

!KSFileList methodsFor: 'building' stamp: 'ael 3/15/2013 14:47'!
makeFileList = (factory) ->
	var fileList = factory.newList()
	fileList.factory = KSFactory.newFrom(factory)
	fileList.factory.setListFillsFromTheme()
	fileList.fill(Color.white())
	var scroller = factory.createVScrollerFor(fileList)
	scroller.fill(fileList.fill())
	fileList.borderWidth(0)
	scroller.borderFill(factory.theme.borderColor)
	scroller.borderWidth(1)
	scroller.name("fileListScroller")
	return scroller! !

!KSFileList methodsFor: 'building' stamp: 'yo 1/30/2013 10:38'!
makeLabel = (factory, title) ->
	var child = factory.newLabel(title)
	child.layout().inset(P(20, 5))
	var header = KSBox._extent_fill(P(100, 20), factory.theme.themeColor)
	header.add(child)
	header.cornerRadius(8)
	header.name("label")
	return header! !

!KSFileList methodsFor: 'building' stamp: 'yo 1/30/2013 10:39'!
makeNameField = (factory) ->
	var nameField = KSBox.new()
	nameField.name('nameField')
	nameField.fill(Color.white())
	nameField.borderWidth(1)
	nameField.borderFill(factory.theme.borderColor)
	return nameField! !

!KSFileList methodsFor: 'building' stamp: 'ael 3/15/2013 14:48'!
makeShortcutList = (factory) ->
	var shortcutList = factory.newList()
	shortcutList.factory = KSFactory.newFrom(factory)
	shortcutList.factory.setListFillsFromTheme()
	shortcutList.fill(Color.white())
	var shortcutScroller = factory.createVScrollerFor(shortcutList)
	shortcutScroller.borderFill(factory.theme.borderColor)
	shortcutScroller.name("shortcutListScroller")
	return shortcutScroller! !

!KSFileList methodsFor: 'initialization' stamp: 'yo 2/25/2013 17:00'!
behavior = (initialFileName) ->
	@shortcutList.setItems(([x.value(), x.key()] for x in @shortcuts))
	this.shortcut = this.streamOf(this.defaultShortcuts().first())
	@shortcutList.first().fireRequest.set(true)

	this.fileName = $$(@fileList.itemSelected.mapE((ev) ->
		ev.handler.textContents())).startsWith(initialFileName)
	this.fileUpdater = $$(@shortcut.mapE((s) ->
		var dir = s.value()
		var entries = ([{directory: dir, entry: entry}, entry.name()]
			for entry in dir.entries() when @patterns.findFirst((p) ->
				p.match(entry.name())) > 0)
		entries = entries.sort((a,b) ->
			a.first().entry.modificationTime() > b.first().entry.modificationTime())
		@fileList.setItems(entries)
		var item = (x in @fileList.contents when x.textContents() == @fileName)
		//this.fileListScroller.scrollIntoView(item)
		))

	delete this.shortcutList.doAction
	this.shortcutUpdater = $$(@shortcutList.itemSelected.mapE((ev) ->
		this.shortcut.set((e in @shortcuts when ev.handler.textContents() == e.key()))))

	delete this.fileList.doAction
	this.updateNameField = $$(@fileName.mapE((name) ->
		if name == this.nameField.textContents() then undefined else name).mapE((name1) ->
			this.nameField.textContents(name1)))
	this.updateDirectoryField = $$(this.directoryField.textContents(@shortcut.value().asString()))

	this.dismiss = $$(@cancelButton.fire.doE(() -> @whole.delete()))

	this.fire = $$(@acceptButton.fire.doE(() -> {dir: @shortcut, file: @nameField.textContents()}))
	this.whole.fire = $$(@handler.fire)

	this.nameField.beLineEditor()

	this.label.moveTarget = @whole
	// This must be a bug on how to deal with 'this'
	this.label.attachDownMoveUpHandlers(
		(downEvt) ->
			this.clickPoint = @moveTarget.localPointFor(downEvt.position), 
		(moveEvt) ->
			var diff = @moveTarget.localPointFor(moveEvt.position) - this.clickPoint
			@moveTarget.translateBy(diff),
		null)! !

!KSFileList methodsFor: 'initialization' stamp: 'yo 2/27/2013 13:57'!
build = (extent) ->
	var factory = @whole.factory()
	this.beDialogExtent(@whole, extent)
	@whole.add(this.label = this.makeLabel(factory, "title"))
	@whole.add(this.directoryField = this.makeDirectoryField(factory))
	@whole.add(this.nameField = this.makeNameField(factory))
	@whole.add(this.shortcutListScroller = this.makeShortcutList(factory))
	this.shortcutList = this.shortcutListScroller.first()
	@whole.add(this.fileListScroller = this.makeFileList(factory))
	this.fileList = this.fileListScroller.first()
	@whole.add(this.acceptButton = this.makeButton(factory, "accept"))
	@acceptButton.removeAll()
	@acceptButton.textContents("button")
	@whole.add(this.cancelButton = this.makeButton(factory, "cancel"))
	@cancelButton.removeAll()
	@cancelButton.textContents("Cancel")

	@whole.clipping(true)
	return @whole! !

!KSFileList methodsFor: 'initialization' stamp: 'yo 1/29/2013 14:00'!
defaultShortcuts
	^{'local' -> FileDirectory default.
		'remote' -> PPPusher repository.
		'cache' -> PPPusher repositoryCache}! !

!KSFileList methodsFor: 'initialization' stamp: 'yo 2/27/2013 13:23'!
layout
	^ KSSimpleLayout new
		keep: #topLeft	of: 'label' to: 0@0;
		keep: #right	of: 'label' to: #right offset: 0;
		keep: #height	of: 'label' to: 25;

		keep: #topLeft	of: 'directoryField' to: #bottomLeft of: 'label' offset: 10@5;
		keep: #right	of: 'directoryField' to: #right offset: -10;
		keep: #height	of: 'directoryField' to: 20;

		keep: #topLeft	of: 'shortcutListScroller' to: #bottomLeft of: 'directoryField' offset: 0@5;
		keep: #width	of: 'shortcutListScroller' to: 80;
		keep: #bottom	of: 'shortcutListScroller' to: #bottom offset: -35;

		keep: #topLeft of: 'fileListScroller' to: #topRight of: 'shortcutListScroller' offset: 5@0;
		keep: #right	of: 'fileListScroller' to: #right offset: -10;
		keep: #bottom	of: 'fileListScroller' to: #bottom offset: -35;

		keep: #bottomLeft	of: 'nameField' to: #bottomLeft offset: 10@ -10;
		keep: #height		of: 'nameField' to: 20;
		keep: #right		of: 'nameField' to: #left of: 'accept' offset: -5;

		keep: #bottomRight	of: 'cancel' to: #bottomRight offset: -10@ -10;
		keep: #extent			of: 'cancel' to: 60@20;

		keep: #bottomRight	of: 'accept' to: #bottomLeft of: 'cancel' offset: -5@0;
		keep: #extent			of: 'accept' to: 60@20;
		yourself! !

!KSFileList methodsFor: 'initialization' stamp: 'yo 2/27/2013 22:27'!
setup = (title, acceptLabel, fileName, patterns, extent, shortcuts) ->
	@whole.acceptButton.removeAll()
	@whole.acceptButton.textContents(acceptLabel)

	this.whole.patterns = @whole.streamOf(patterns.findTokens(","))
	this.whole.shortcuts = @whole.streamOf(shortcuts)

	@whole.layout(this.layout())
	this.behavior(fileName)
	return @whole! !

!KSFileList class methodsFor: 'as yet unclassified' stamp: 'yo 1/30/2013 11:09'!
build
"
	KSFileList build
"
	| box handler ks |
	ks := KSMorph new openInWorld extent: 600@400.
	box := KSBox extent: 500@350 fill: Color white.
	handler := self new.
	handler installTo: box.
	handler build: 500@350.
	box layout: handler layout.
	ks window add: box.
	ActiveWorld doOneCycle.
	box layout: nil.
	box saveToDirectory: 'fileList.ks'.
	^ handler.! !

!KSFileList class methodsFor: 'as yet unclassified' stamp: 'yo 2/27/2013 23:54'!
example1
"
	[KSFileList example1] fork.
	QSystemProfiler spyOnWorldFor: 7.
"
	| box ks |
	ks := KSMorph new openInWorld extent: 600@400.
	box := KSBox loadBoxFromDirectoryViaCache: 'http://tinlizzie.org/dbjr/fileList.ks'.
	"box := KSBox loadBoxFromDirectory: 'fileList.ks'."
	box fileListSetup: 'Title' with: 'Accept' with: 'foo.ks' with: '*.ks' with: 500@350 with: box fileListDefaultShortcuts.
	ks window add: box.
	^ box.! !
