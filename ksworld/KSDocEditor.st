KSUserEventHandler subclass: #KSDocEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSDocEditor methodsFor: 'events' stamp: 'ael 3/4/2013 21:56'!
boxBelongsToDoc = (box) ->
	return box.orContainerSuchThat((c) -> c.name() == "mainViewBox") && box.name() !!= "mainViewBox"! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 3/1/2013 00:55'!
checkBubbleVisibility = () ->
	// this.relevantBubbles holds all bubbles relevant to the current tab and selected object
	// Originally we tried each bubble in turn, seeing if it would fit on the bubble bar.  If not, we looked at the next one in case it happened to be narrower... and so on.
	// Now we just load each bubble in turn, stopping as soon as the bubble bar is full (or over-full).

	if !!@fullScreen
		var bar = this.bubbleBar
		bar.removeAll()
		var maxRight = @whole.globalPointFor(@whole.extent()).x()
		for bName in @relevantBubbles
			var wantsToHide = this.bubbleHideRules[bName].value()
			if !!wantsToHide
				var bubble = this.loadBubble(bName)
				bubble.visible.set(true)
				bar.add(bubble)
				bar.layOut()
				if bubble.globalPointFor(bubble.extent()).x() >= maxRight
					break! !

!KSDocEditor methodsFor: 'events' stamp: 'yo 3/15/2013 18:35'!
docFontChosen = (event) ->
	var fontName = event.handler.textContents()
	if fontName.size() == 0
		return
	this.defaultFont.set(@defaultFont.withFamily(fontName).normal())! !

!KSDocEditor methodsFor: 'events' stamp: 'yo 3/15/2013 18:08'!
docFontSizeChosen = (event) ->
	var val = event.handler.textContents().asInteger()
	this.defaultFont.set(@defaultFont.withSize(val))! !

!KSDocEditor methodsFor: 'events' stamp: 'yo 8/19/2013 15:16'!
editorAction = (name) ->
	// Perform an action that depends on overall editor state
	var box

	if name == "backInDocHistory"
		return this.moveInDocHistory(-1)

	if name == "forwardInDocHistory"
		return this.moveInDocHistory(1)

	if name == "insertBackground"
		'to do'

	if name == "newDoc"
		this.docLoaderRequest.set(KSStack.newStack().stackBox())
		return

	if name == "toggleFullScreen"			// from button at top right
		this.fullScreen.set(!!@fullScreen)
		return

	if name == "toggleFullScreenAll"
		this.fullScreenAll(!!@fullScreenAll)
		return

	if name == "toggleHostWindow"
		'to do'

	if name == "newCell"
		var box = @factory.newCell()
		box.layout().font = @defaultFont
		@whole.hand().addFirst(box)

	if name == "newText"
		var box = @factory.newTextField()
		box.layout().font = @defaultFont
		@whole.hand().addFirst(box)
		// DO NOT RETURN so pageSpecific can be set below

	if name == "newTable"
		'to do'

	if name == "newBox"
		box = KSBox.new()
		box.acceptDrops(nil)
		@whole.hand().addFirst(box)
		// DO NOT RETURN so pageSpecific can be set below

	if name == "newList"
		box = @factory.newList()
		@whole.hand().addFirst(box)
		// DO NOT RETURN so pageSpecific can be set below

	if name == "newOval"
		box = KSBox.withShape(KSShape.new().elements([
			GeziraPath.oval(P(0, 0).corner(P(50, 50))).fill(Color.green())])) // "green"
		@whole.hand().addFirst(box)
		// DO NOT RETURN so pageSpecific can be set below

	if name == "newButton"
		box = @factory.newButton('a button')
		@whole.hand().addFirst(box)
		// DO NOT RETURN so pageSpecific can be set below

	if box		// for every command that makes a box.
		box.pageSpecific = true
		return

	Transcript.show("(MessageSet openMessageList: {'KSDocEditor editorAction:'} name: 'Need action for: ".concat(name.concat("')"))).cr()! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 4/1/2013 17:37'!
editorActionInteractive = (name, event) ->
	// Perform an action that depends on overall editor state and on a launch location
	if name == "saveDocument"
		this.saveDocument()
		return
	if name == "loadDocument"
		this.loadDocument()
		return
	if name == "chooseBackground"
		'to do'
		// return

	if name == "docFontChoose"
		var list = ([#'docFontChosen', b] for b in KSFamily.families().keys())
		var menu = @whole.createMenu(list, this)
		KSBox._invokeMenu_near_for(menu, event.position, @whole)
		return

	if name == "chooseDocFontSize"
		var list = ([#'docFontSizeChosen', b] for b in ['10', '12', '14', '18', '20', '24', '36'])
		var menu = @whole.createMenu(list, this)
		KSBox._invokeMenu_near_for(menu, event.position, @whole)
		return

	if name == "docLargerFont"
		this.defaultFont.set(@defaultFont.withSize(@defaultFont.pointSize()+1))
		return

	if name == "docSmallerFont"
		this.defaultFont.set(@defaultFont.withSize(@defaultFont.pointSize()-1))
		return

	if name == "docTextColor"
		@whole.topContainer().invokeColorPicker(event.position + P(30, 0), @defaultFont.fill() ? Color.black(), this, (target, color) -> target.defaultFont.set(target.defaultFont.currentValue().fill(color)))
		return

	if name == "setDPI"
		'to do'
		// return

	if name == "setPageSize"
		'to do'
		// return

	if name == "loadSISS"
		'to do'
		// return

	if name == "loadPage"
		'to do'
		// return

	if name == "loadODF"
		'to do'
		// return

	if name == "appendODF"
		'to do'
		// return

	if name == "saveSISS"
		var fileName = this.titleHolder.textContents()
		if !!fileName.endsWith('.ks')
			fileName = fileName.concat('.ks')
		@doc.saveToDirectory(fileName)
		return

	if name == "savePage"
		'to do'
		// return

	if name == "insertMarkForPrinting"
		'to do'
		// return

	if name == "makePDF"
		'to do'
		// return

	Transcript.show("(MessageSet openMessageList: {'KSDocEditor editorActionInteractive:with:'} name: 'Need action for: ".concat(name.concat("')"))).cr()! !

!KSDocEditor methodsFor: 'events' stamp: 'yo 8/19/2013 15:27'!
fullScreenAll = (aBoolean) ->
/*
	This method set full screen modes on DocEditor, KSMorph, and the screen all at once.
	Go to full screen mode if it is true, otherwise restore the original state.
*/
	this.fullScreenAll.set(aBoolean)
	if aBoolean
		this.lastScreenAllProject = Project.current().lastScreenModeSelected()
		this.lastScreenAllMorph = KSMorph.current().fullscreen()
		this.lastScreenAllDocEditor = @fullScreen
		Project.current().fullScreenOn()
		Project.current().showWorldMainDockingBar(false)
		KSMorph.current().fullscreen(true)
		this.fullScreen.set(true)
	else
		/* "self toggleFullScreen: (self valueOfProperty: #lastScreenAllDocEditor) = true. */
		this.fullScreen.set(false)
		KSMorph.current().fullscreen(this.lastScreenAllMorph == true)
		Project.current().showWorldMainDockingBar(true)
		if this.lastScreenAllProject == true
			Project.current().fullScreenOn()
		else
			Project.current().fullScreenOff()
		/*KSMorph.current().openInWorld()*/ /* Make sure it isn't hidden by the docking bar */! !

!KSDocEditor methodsFor: 'events' stamp: 'yo 2/28/2013 14:01'!
loadDocument = () ->
	if !!this.protoFileList
		this.protoFileList = KSBox.loadBoxFromDirectoryViaCache('http://tinlizzie.org/dbjr/fileList.ks')
	this.fileList = this.protoFileList.copy()
	var default = @doc.name()?@titleHolder.textContents()
	if default.size() == 0
		default = "document.ks"
	this.fileList.fileListSetup("Load a Docment", "Load", default, "*.ks,*.odp",
		P(500, 350), @whole.fileListDefaultShortcuts())
	@whole.topContainer().addAsParts(this.fileList)
	this.fileListCancel = $$(mergeE(@fileList.cancelButton.fire, @fileListAccept).doE(() ->
		this.fileList.delete()))
	this.fileListAccept = $$(@fileList.fire.mapE((ev) ->
		this.openDocPath(PPPusher.directoryObject(ev.dir.value()).directoryNamed(ev.file))))! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 3/14/2013 00:20'!
maybeBoxAction = (name) ->
	var box = @selectedDocBox
	if !!box
		return

	if name == "toggleBorder"				// cell bubble
		box.toggleBorder()
		return

	if name == "delete"
		box.delete()
		return

	if name == "userCopy"
		box.userCopy(undefined)
		return

	if name == "chooseGradient"
		// to do
		return

	if name == "chooseRadialGradient"
		// to do
		return

	if name == "toggleRoundedCorners"
		// to do
		return

	if name == "borderThicker"
		box.borderWidth(box.borderWidth() + 1)
		return

	if name == "borderThinner"
		box.borderWidth(0.max(box.borderWidth() - 1))
		return

	if name == "toggleDropShadow"
		// to do
		return

	if name == "toggleSoftShadow"
		// to do
		return

	if name == "bringToFront"
		box.container().reorderBeAt(box, 1)
		// this.editSignal.set(true)
		return

	if name == "bringCloser"
		var where = box.index()	// 1-order
		if where > 1
			box.container().reorderBeAt(box, where-1)
			// this.editSignal.set(true)
		return

	if name == "sendToRear"
		box.container().reorderBeAt(box, box.container().contents().size())
		// this.editSignal.set(true)
		return

	if name == "sendFurther"
		where = box.index()	// 1-order
		if where < box.container().contents().size()
			box.container().reorderBeAt(box, where+1)
			// this.editSignal.set(true)
		return

	if name == "pickUp"
		box.hand().attachBox(box)
		return

	if name == "transferHalo"
		box.worldState().transferHalo()
		return

	Transcript.show("(MessageSet openMessageList: {'KSDocEditor maybeBoxAction:'} name: 'Need action for: ".concat(name.concat("')"))).cr()! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 4/1/2013 17:37'!
maybeBoxActionInteractive = (name, event) ->
	var box = @selectedDocBox
	if !!box
		return

	if name == "chooseSolidInterior"
		@whole.topContainer().invokeColorPicker(event.position + P(30, 0), @selectedDocBox.fill() ? Color.red(), @selectedDocBox, (target, color) -> target.fill(color))
		return

	if name == "chooseImageInterior"
		'to do'

	if name == "chooseSolidBorder"
		@whole.topContainer().invokeColorPicker(event.position + P(30, 0), @selectedDocBox.borderFill() ? Color.green(), @selectedDocBox, (target, color) -> target.borderFill(color))
		return

	if name == "chooseGradientBorder"
		'to do'

	if name == "chooseRadialBorder"
		'to do'

	if name == "chooseBorderWidth"
		'to do'

	if name == "chooseSolidShadow"
		'to do'

	if name == "chooseGradientShadow"
		'to do'

	if name == "chooseRadialShadow"
		'to do'

	if name == "chooseImageShadow"
		'to do'

	if name == "chooseShadowOffset"
		'to do'

	Transcript.show("(MessageSet openMessageList: {'KSDocEditor maybeBoxActionInteractive:with:'} name: 'Need action for: ".concat(name.concat("')"))).cr()! !

!KSDocEditor methodsFor: 'events' stamp: 'tk 3/7/2013 11:29'!
maybeStackAction = (action) ->
	if @doc && @doc.stackHandler() then @doc.stackHandler().stackAction(action, @selectedDocBox)! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 3/14/2013 00:20'!
maybeTextAction = (mustBeNonEmpty, action) ->
	// actions that are only valid when there's a selection in text
	if @textSelection && (!!mustBeNonEmpty || @textSelection.isNotEmpty())
		@focusLayout.textAction(action)
		@focusLayout.whole.layoutChanged()
		// this.editSignal.set(true)! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 3/18/2013 01:38'!
maybeTextActionInteractive = (mustBeNonEmpty, action, event) ->
	// actions that are only valid when there's a selection in text
	if @textSelection && (!!mustBeNonEmpty || @textSelection.isNotEmpty())
		@focusLayout.textActionInteractive(action, event)! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 2/14/2013 11:18'!
moveInDocHistory = (inc) ->
	var newIndex = this.docHistoryIndex + inc
	if newIndex < 0 || newIndex > this.docHistory.size()-1
		return Beeper.beep()
	this.docHistoryIndex = newIndex
	this.openDocPath(this.docHistory[newIndex])! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 2/19/2013 21:36'!
provisionalFindAction = (scope) ->
	// placeholder for testing bubble behaviour
	Transcript.show("find '".concat(@findString).concat("' in ").concat(scope)).cr()! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 2/19/2013 21:37'!
provisionalSendToAddress = () ->
	// placeholder for testing bubble behaviour
	Transcript.show("send to address '".concat(@sendTarget).concat("'")).cr()! !

!KSDocEditor methodsFor: 'events' stamp: 'yo 2/28/2013 14:01'!
saveDocument = () ->
	if !!@doc
		return
	if !!this.protoFileList
		this.protoFileList = KSBox.loadBoxFromDirectoryViaCache('http://tinlizzie.org/dbjr/fileList.ks')
	this.fileList = this.protoFileList.copy()
	var default = @doc.name()?@titleHolder.textContents()
	if default.size() == 0
		default = "document"
	if !!default.endsWith(".ks")
		default = default.concat(".ks")
	this.fileList.fileListSetup("Save a Docment", "Save", default, "*.ks",
		P(500, 350), @whole.fileListDefaultShortcuts())
	@whole.topContainer().addAsParts(this.fileList)
	this.fileListCancel = $$(mergeE(@fileList.cancelButton.fire, @fileListAccept).doE(() ->
		this.fileList.delete()))
	this.fileListAccept = $$(@fileList.fire.mapE((ev) ->
		@doc.saveToDirectory(PPPusher.directoryObject(ev.dir.value()).directoryNamed(ev.file))
		if ev.file !!= default
			@titleHolder.textContents(ev.file)
			@titleHolder.handler.textAction("accept")))! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 3/13/2013 23:53'!
triggerMenuCommand = (target, action, args) ->
	this.menuCommandRequest.set({ target: target, selector: action, args: args })! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 2/28/2013 19:16'!
zoomAction = (event) ->
	this.zoomRequestPercent.set(Number.readFrom(event.handler.textContents()))
	this.zoomMode.set("percent")! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 1/26/2013 17:52'!
zoomFitExtent = () ->
	this.zoomMode.set("extent")! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 1/26/2013 17:52'!
zoomFitWidth = () ->
	this.zoomMode.set("width")! !

!KSDocEditor methodsFor: 'events' stamp: 'ael 1/25/2013 13:55'!
zoomMenuItems
	^(#(25 50 75 100 125 150 200 300 400)
		collect: [:i |
			{#zoomAction: . '{1}%' format: {i}}
	]) , #(
		-
		(#zoomFitWidth 'Fit Width')
		(#zoomFitExtent 'Fit Page')
	)! !

!KSDocEditor methodsFor: 'initialization' stamp: 'ael 3/6/2013 20:51'!
addDocumentView = () ->
	var topBox = @whole

	var box = this.mainViewBox = KSBox._extent_fill(P(200,300),Color.gray())
	box.name("mainViewBox")
	var substrate = this.mainViewSubstrate = @factory.createHVScrollerFor(box)
	substrate.fill(Color.gray())
	substrate.name("mainViewSubstrate")
	topBox.add(substrate)

	this.setupThumbnailsBehavior()! !

!KSDocEditor methodsFor: 'initialization' stamp: 'yo 3/15/2013 18:32'!
addLayoutButtons = () ->
	var topBox = @whole

	// tool selection button
	var box = this.toolButton = @factory.showHideButton()
	box.name("toolButton")
	topBox.addAsParts(box)

	// full-screen button
	box = this.fullScreenButton = @factory.showHideButton()
	box.attachButtonHandler()
	box.name("fullScreenButton")
	topBox.addAsParts(box)
	this.fullScreen = this.streamOf(false)
	this.fullScreenSwitcher = $$(@fullScreenButton.fire.doE(() -> this.editorAction("toggleFullScreen")))

	// zoom button
	box = this.zoomButton = @factory.newButton("100%")
	box.layout().font = box.layout().font.withSize(14)
	box.defaultFill = @factory.theme.themeColor
	box.name("zoomButton")
	topBox.addAsParts(box)
	this.zoomLauncher = $$(@zoomButton.fire.mapE((ev) ->
		KSBox._invokeMenu_near_for(@whole.createMenu(this.zoomMenuItems(), this), ev.position, @whole)))

	// zoom control
	this.zoomMode = this.streamOf("extent")
	this.zoomRequestPercent = this.streamOf(100)

	// any explicitly selected zoom percent is maintained independent of full-screen mode
	// NB: important not to use .startsWith(), because initialisation based on the values in the feed streams will be rejected
	this.zoomNonFullscreenPercent = $$(mergeE(@doc, @mainViewSubstrate.extent, @zoomMode, @zoomRequestPercent).doE(() ->
		var desiredPercent
		if !!@fullScreen
			if @zoomMode == "percent"
				desiredPercent = @zoomRequestPercent
			else
				// iff there is a loaded doc we can respond to "width" and "extent" settings
				if !!@mainViewBox.contents().isEmpty()
					var docBox = @mainViewBox.contents().first()
					var docBoxExtent = docBox.extent()
					var viewExtent = @mainViewSubstrate.extent()
					var scrollbarMargin = P(10, 10)
					if @zoomMode == "width"
						// try without a vertical scroll bar
						desiredPercent = (viewExtent.x()/docBoxExtent.x()*100).floor()
						// if that scale won't fit vertically, back off to fit with the scroll bar
						if docBoxExtent.y()*desiredPercent*0.01 > viewExtent.y()
							desiredPercent = ((viewExtent.x()-scrollbarMargin.x())/docBoxExtent.x()*100).floor()
					if @zoomMode == "extent"
						var scale = @mainViewSubstrate.extent()/docBox.extent()
						desiredPercent = ((scale.x().min(scale.y()))*100).floor()
		if desiredPercent then this.zoomButton.textContents(desiredPercent.asString().concat("%"))
		desiredPercent))

	// scaling and placing the document depends on full-screen mode and selected/calculated %
	this.zoomWatcher = $$(mergeE(@doc, @zoomNonFullscreenPercent, @mainViewSubstrate.extent).doE(() ->
		if @zoomNonFullscreenPercent && !!@mainViewBox.contents().isEmpty()
			var docBox = @mainViewBox.contents().first()
			var docBoxExtent = docBox.extent()
			var scrollbarAllowance = if @fullScreen || @zoomMode == "extent" then P(0, 0) else if @zoomMode == "width" then P(10, 0) else P(10, 10)
			var viewExtent
			var desiredPercent
			if @fullScreen
				viewExtent = @whole.extent()
				var scale = viewExtent/docBoxExtent
				desiredPercent = ((scale.x().min(scale.y()))*100).floor()
			else
				viewExtent = @mainViewSubstrate.extent()
				desiredPercent = @zoomNonFullscreenPercent
			docBox.scale(desiredPercent*0.01)
			var docBoxScaledExtent = docBoxExtent*desiredPercent*0.01
			// the thing to be scrolled must be at least as big as the doc and the scrollable area
			this.mainViewBox.extent(docBoxScaledExtent.max(viewExtent-scrollbarAllowance))
			// docBox is centred within the scroll area, unless that would put its top-left off screen
			docBox.center((viewExtent-scrollbarAllowance).max(docBoxScaledExtent)*0.5)
		else
			this.mainViewBox.extent(@mainViewSubstrate.extent())))

	// tool layout control
	this.layoutSwitcher = $$(mergeE(@activeLayout, @fullScreen).doE(() ->
		var lname = if @fullScreen then "fullScreen" else @activeLayout
		for k, v of this.paneVisibilities[lname]
			this[k].visible.set(v)
		topBox.layout(this.layouts[lname])))
	this.activeLayout = $$(@toolButton.fire.doE(() ->
		var cycle = [ "noFilesOrThumbs", "noFiles", "noThumbs", "all" ]
		cycle[cycle.indexOf(@activeLayout').rem(cycle.size())])).startsWith("all")! !

!KSDocEditor methodsFor: 'initialization' stamp: 'ael 3/15/2013 14:47'!
addListPanes = () ->
	var topBox = @whole
	var menuFont = KSFamily.withName("DejaVuSans").withStyle(0).withSize(12)
	var initialHeight = 100	// arbitrary

	var browserBox = this.browserBox = KSBox._extent_fill(P(300,initialHeight), Color.white())
	browserBox.name("browserBox")
	var bbLayout = KSSimpleLayout.new()
	
	var listFactory = KSFactory.newFrom(@factory)
	listFactory.setListFillsFromTheme()

	// shortcut list (left column of "browserBox")
	var box = this.shortcutListBox = KSBox._extent_fill(P(100,initialHeight),Color.transparent())
	var substrate = @factory.createVScrollerFor(box)	// do now, before box gets resized
	substrate.name("shortcutListSubstrate")
	substrate.borderWidth(1)
	substrate.borderFill(@factory.theme.edgeColor)
	var shortcutItems = []
	for shortcut in this.browserBoxShortcuts()	// KSObjects with label, icon, path, patterns
		if shortcut.label == #"-"
			shortcutItems.push(shortcut.label)
		else
			var icon = shortcut.icon
			icon.scale(12.0/icon.extent().y())
			shortcutItems.push([shortcut, shortcut.label, icon])
	box.menuFont = menuFont
	box.factory(listFactory)
	box.beSelectableListHandler()
	box.setItems(shortcutItems)
	browserBox.add(substrate)

	// file list (right column of "browserBox")
	box = this.fileListBox = KSBox._extent_fill(P(200,initialHeight),Color.transparent())
	var substrate = @factory.createVScrollerFor(box)
	substrate.borderWidth(1)
	substrate.borderFill(@factory.theme.edgeColor)
	substrate.name("fileListSubstrate")
	box.menuFont = menuFont
	box.factory(listFactory)
	box.beSelectableListHandler()
	browserBox.add(substrate)

	this.shortcutWatcher = $$(@shortcutListBox.itemSelected.mapE((ev) ->
		var item = ev.handler.actionID
		var path = item.path
		var entries = ([{path: path, entry: entry}, entry.name()] for entry in path.entries() when item.patterns.findFirst((p) ->
			p.match(entry.name())) > 0)
		entries = entries.sort((a,b) ->
			a.first().entry.modificationTime() > b.first().entry.modificationTime())
		this.fileListBox.setItems(entries)))

	this.fileWatcher = $$(@fileListBox.itemSelected.mapE((ev) ->
		var item = ev.handler.actionID
		var fullPath = item.path.fullNameFor(item.entry.name())
		this.openDocPath(fullPath)))

	bbLayout._keep_of_to(#"topLeft", "shortcutListSubstrate", #"topLeft")
	// bbLayout._keep_of_to_offset(#"right", "shortcutListSubstrate", #"left", P(100, 0))
	bbLayout._keep_of_to(#"bottom", "shortcutListSubstrate", #"bottom")
	bbLayout._keep_of_to(#"topRight", "fileListSubstrate", #"topRight")
	bbLayout._keep_of_to(#"bottom", "fileListSubstrate", #"bottom")
	browserBox.layout(bbLayout)

	topBox.add(browserBox)

	// thumbnail list
	box = this.thumbnailListBox = KSBox._extent_fill(P(150,initialHeight),Color.transparent())
	box.menuFont = menuFont
	box.beSelectableListHandler()
	box.layout().inset(1)
	box.layout().space = 2
	var substrate = @factory.createVScrollerFor(box)
	substrate.name("thumbnailListBox")
	substrate.borderWidth(2)
	substrate.borderFill(@factory.theme.edgeColor)
	topBox.add(substrate)! !

!KSDocEditor methodsFor: 'initialization' stamp: 'yo 3/7/2013 15:02'!
addScriptingPane = () ->
	var topBox = @whole

	// the substrate has variable width, and contains (but doesn't clip) the script area
	var box = this.scriptingSubstrate = KSBox._extent_fill(P(0,200),Color.white())
	box.name("scriptingSubstrate")
	topBox.addAsParts(box)

	var scriptingArea = this.scriptingArea = KSBox._extent_fill(P(400, 400), Color.white())
	scriptingArea.name("scriptingArea")
	var handler = KSFrankScripting.new()
	handler.installTo(scriptingArea)
	handler.scriptingAreaLayout(scriptingArea)
	box.addAsParts(handler.scriptingAreaButtons())
	handler.scriptingAreaButtonsLayout(box)
	handler.setupScriptingHead()
	box.add(scriptingArea)
	handler.actionsInScriptingArea()
	handler.scriptDirty = false

	box = this.scriptingHandle = @factory.showHideIconBox()
	box.name("scriptingHandle")
	box.moveTarget = @scriptingSubstrate
	box.attachDownMoveUpHandlers(
		(downEvt) ->
			this.clickPoint = downEvt.position
			this.startWidth = this.moveTarget.width(), 
		(moveEvt) ->
			var diff = moveEvt.position - this.clickPoint
			this.moveTarget.width((this.startWidth - diff.x()).max(0)),
		null)
	topBox.addAsParts(box)

	this.scriptingAreaTargetUpdater = $$(mergeE(@doc, @doc.handler.pagesChanged).doE(() ->
		if @doc.handler instanceof KSStack
			this.scriptingArea.handler.scriptingTarget.set(@doc.handler.pageBox())
		else
			this.scriptingArea.handler.scriptingTarget.set(@doc)))

	this.scriptUpdater = $$(@doc.handler.pagesChanged.doE(() ->
		this.updateODFScripts()))! !

!KSDocEditor methodsFor: 'initialization' stamp: 'ael 3/14/2013 15:56'!
addToolBar = (toolHeight) ->
	// Outer part is toolBar, governed by the containing topBox's layout
	// The toolBar contains tabBar across the top and bubbleBar below (with Frank icon, as a part, to the left)
	// Both tabBar and bubbleBar are dynamically reconfigurable
	var topBox = @whole
	var tabHeight = 21

	var toolBar = this.toolBar = KSBox._extent_fill(P(topBox.width(), toolHeight), Color.white())
	toolBar.name("toolBar")
	toolBar.borderWidth(1)
	toolBar.borderFill(@factory.theme.edgeColor)
	// toolBar.clipping(true)
	var gradParms = [ [0, @factory.theme.themeColor], [(tabHeight-1)/toolHeight, @factory.theme.themeColor], [(tabHeight-1)/toolHeight, @factory.theme.edgeColor], [tabHeight/toolHeight, @factory.theme.edgeColor], [tabHeight/toolHeight, @factory.theme.lightColor], [1, @factory.theme.themeColor] ].collect((pair) ->
		Association._key_value(pair[0], pair[1]))
	toolBar.fill(GeziraFill._gradient_from_to(gradParms, P(0, 0), P(0, toolHeight)))

	var tabBar = this.tabBar = KSBox._extent_fill(P(topBox.width(), tabHeight), Color.transparent())
	tabBar.beSelectableListHandler()
	tabBar.name("tabBar")
	var layout = KSHorizontalLayout.new()
	layout.space(16)
	layout.inset(1)
	tabBar.layout(layout)
	toolBar.add(tabBar)

	var titleHolder = this.titleHolder = this.whole.factory().newLineEditor(nil, Color.transparent(), KSFamily.withName("DejaVuSans").withStyle(1).withSize(13).fill(@factory.theme.iconColor))
	titleHolder.borderWidth(0)
	titleHolder.name("titleHolder")
	titleHolder.layout().horizontalShrink = true
	titleHolder.layout().acceptContentsOnFocusLoss(true)
	titleHolder.textContents("No document")
	titleHolder.eval('this.docWatcher = $$(@__docEditor__.doc.mapE((doc) -> this.textContents(doc.name.currentValue() ? "")))')
	this.titleWatcher = $$(@titleHolder.contentsAccepted.doE(() ->
		if @doc
			@doc.name(@titleHolder.textContents())))
	toolBar.add(titleHolder)

	var frank = @factory.graphicNamed("frank")
	frank.scale(0.17)
	toolBar.addAsParts(frank)

	var bubbleBar = this.bubbleBar = KSBox._extent_fill(P(topBox.width(), toolHeight), Color.transparent())
	bubbleBar.name("bubbleBar")
	var layout = KSHorizontalLayout.new()
	// layout.ignoreInvisibles = true			no longer needed
	layout.space(4)
	bubbleBar.layout(layout)
	toolBar.add(bubbleBar)

	layout = KSSimpleLayout.new()
	layout._keep_of_to_offset(#"topLeft", "tabBar", #"topLeft", P(100, 0))
	layout._keep_of_to(#"right", "tabBar", #"right")	
	layout._keep_of_to_offset(#"topLeft", "bubbleBar", #"topLeft", P(100, tabHeight+3))	// room for Frank
	layout._keep_of_to(#"right", "bubbleBar", #"right")	
	layout._keep_of_to_offset(#"topLeft", "frank", #"topLeft", P(10, 0))
	layout._keep_of_to_offset(#"topRight", "titleHolder", #"topRight", P(-30, 0))	
	toolBar.layout(layout)

	topBox.add(toolBar)! !

!KSDocEditor methodsFor: 'initialization' stamp: 'yo 1/29/2013 15:55'!
browserBoxShortcuts
	| tuples icon shape grName |
	tuples := (#(('Inbox' 'emailInbox' ) ('Sent' 'emailSent' ) ('Trash' 'emailTrash' ) ('Draft' 'emailDraft' ) ('Spam' 'emailSpam' ) )
			collect: [:nameGraphic |
				nameGraphic, { ((FileDirectory default directoryNamed: 'Email') directoryNamed: nameGraphic first) assureExistence. '*.ks,*.eml' }
				]),
			{#(-)},
			{
				{'local'. 'emailFolder'. FileDirectory default. '*.ks'}.
				{'remote'. 'emailFolder'. PPPusher repository. '*.ks'}.
				{'ODF'. 'emailFolder'. FileDirectory default. '*.odp'}.
				{'cache'. 'emailFolder'. PPPusher repositoryCache. '*.ks'}
			}.

	^tuples collect: [ :tuple |
		tuple size = 1
			ifTrue: [ {#label->tuple first} as: KSObject ]
			ifFalse: [
				grName := tuple second.
				shape := (self ksAt: #factory) graphicShapeNamed: grName.
				icon := KSBox withShape: shape.
				icon pivotRatio: 0@0.9.
				{#label->tuple first.
				#icon->icon.
				#path->tuple third.
				#patterns->(tuple fourth findTokens: ',')} as: KSObject
				]
			]! !

!KSDocEditor methodsFor: 'initialization' stamp: 'tk 3/7/2013 12:06'!
contentGroupBubbleCommands = () ->
	return [
		// each code string will be evaluated in the context of the doc editor, and can assume the binding of var 'event' to the event that triggered the command

		// edit
		[ "edit paste", "this.maybeTextAction(false, 'paste')" ],
		[ "edit cut", "this.maybeTextAction(true, 'cut')" ],
		[ "edit copy", "this.maybeTextAction(true, 'copy')" ],
		[ "edit select all", "this.maybeTextAction(false, 'selectAll')" ],

		// letters
		[ "choose font", "this.maybeTextActionInteractive(true, 'fontChoose', event)" ],
		[ "choose font size", "this.maybeTextActionInteractive(true, 'chooseFontSize', event)" ], 
		[ "choose font color", "this.maybeTextActionInteractive(true, 'selectTextColor', event)" ],
		[ "choose font background", "this.maybeTextActionInteractive(false, 'hiLiteColor', event)" ],
		[ "enlarge font", "this.maybeTextAction(true, 'fontLarger')" ],
		[ "shrink font", "this.maybeTextAction(true, 'fontSmaller')" ],
		[ "box text", "this.maybeTextAction(true, 'boxText')" ],
		[ "bold font", "this.maybeTextAction(true, 'toggleBold')" ],
		[ "italic font", "this.maybeTextAction(true, 'toggleItalic')" ],
		[ "underline font", "this.maybeTextAction(true, 'toggleUnderline')" ],
		[ "strikeout font", "this.maybeTextAction(true, 'toggleStrikeout')" ],
		[ "subscript font", "this.maybeTextAction(true, 'subscript')" ],
		[ "superscript font", "this.maybeTextAction(true, 'superscript')" ],
		[ "capitalize text", "this.maybeTextAction(true, 'capitalizeText')" ],

		// paragraph
		[ "paragraph link", undefined ],
		[ "paragraph unlink", undefined ],
		[ "paragraph justify", "this.maybeTextAction(false, 'justify'.concat(event.handler.actionArg.capitalized()))" ],
		[ "paragraph extra space", undefined ],	
		[ "paragraph line space", undefined ],

		// cells
		[ "cell border", "this.maybeBoxAction('toggleBorder')" ],
		[ "new cell", "this.editorAction('newCell')" ],
		[ "cell font size", "this.maybeTextActionInteractive(true, 'chooseFontSize', event)" ],	// ok?

		// wander
		[ "wander random", "this.maybeTextAction(false, 'wanderRandom')" ],
		[ "wander back", "this.maybeTextAction(false, 'wanderBack')" ],
		[ "wander stop", "this.maybeTextAction(false, 'wanderStop')" ],

		// box
		[ "box pick up", "this.maybeBoxAction('pickUp')" ],
		[ "box delete", "this.maybeBoxAction('delete')" ],
		[ "box duplicate", "this.maybeBoxAction('userCopy')" ],
		[ "box halo on container", "this.maybeBoxAction('transferHalo')" ],

		// color
		[ "solid fill", "this.maybeBoxActionInteractive('chooseSolidInterior', event)" ],
		[ "gradient fill", "this.maybeBoxAction('chooseGradient')" ],
		[ "radial fill", "this.maybeBoxAction('chooseRadialGradient')" ],
		[ "image fill", "this.maybeBoxActionInteractive('chooseImageInterior', event)" ],

		// border
		[ "solid border", "this.maybeBoxActionInteractive('chooseSolidBorder', event)" ],
		[ "gradient border", "this.maybeBoxActionInteractive('chooseGradientBorder', event)" ],
		[ "radial border", "this.maybeBoxActionInteractive('chooseRadialBorder', event)" ],
		[ "toggle rounded corners", "this.maybeBoxAction('toggleRoundedCorners')" ],
		[ "border width", "this.maybeBoxActionInteractive('chooseBorderWidth', event)" ],
		[ "border thicker", "this.maybeBoxAction('borderThicker')" ],
		[ "border thinner", "this.maybeBoxAction('borderThinner')" ],

		// shadow
		[ "solid shadow", "this.maybeBoxActionInteractive('chooseSolidShadow', event)" ],
		[ "gradient shadow", "this.maybeBoxActionInteractive('chooseGradientShadow', event)" ],
		[ "radial shadow", "this.maybeBoxActionInteractive('chooseRadialShadow', event)" ],
		[ "image shadow", "this.maybeBoxActionInteractive('chooseImageShadow', event)" ],
		[ "shadow offset", "this.maybeBoxActionInteractive('chooseShadowOffset', event)" ],
		[ "hard shadow", "this.maybeBoxAction('toggleDropShadow')" ],
		[ "soft shadow", "this.maybeBoxAction('toggleSoftShadow')" ],

		// overlap
		[ "overlap be in front", "this.maybeBoxAction('bringToFront')" ],
		[ "overlap come forward", "this.maybeBoxAction('bringCloser')" ],
		[ "overlap align", undefined ],
		[ "overlap be in back", "this.maybeBoxAction('sendToRear')" ],
		[ "overlap go back", "this.maybeBoxAction('sendFurther')" ],
		[ "overlap wrapping", undefined ],
		[ "toggle page/background", "this.maybeStackAction('toggle page/background')" ],

		// insert
		[ "insert text area", "this.editorAction('newText')" ],
		[ "insert table", "this.editorAction('newTable')" ],
		[ "insert oval", "this.editorAction('newOval')" ],
		[ "insert box", "this.editorAction('newBox')" ],
		[ "insert cell", "this.editorAction('newCell')" ],
		[ "insert page", "this.maybeStackAction('new')" ],
		[ "insert button", "this.editorAction('newButton')" ],
		[ "insert list", "this.editorAction('newList')" ],
		[ "insert horizontal rule", "this.editorAction('newHorizontalRule')" ],

		// new
		[ "new from clipboard", undefined ], 
		[ "new angular shape", undefined ],
		[ "new small page", undefined ],
		[ "new from photo", undefined ], 
		[ "new smooth shape", undefined ],
		[ "new paint area", undefined ], 
		[ "new scribble", undefined ] ]! !

!KSDocEditor methodsFor: 'initialization' stamp: 'ael 2/20/2013 16:25'!
createCommandTable = () ->

	this.commandTable = {}
	for pair in this.documentGroupBubbleCommands().concat(this.contentGroupBubbleCommands()).concat(this.scriptGroupBubbleCommands())
		if pair[1]
			this.commandTable[pair[0]] = pair[1]! !

!KSDocEditor methodsFor: 'initialization' stamp: 'ael 3/6/2013 14:01'!
createLayouts = () ->
	var layoutSpecs = [
		[ 'fullScreen', [
			[ 'topLeft', 'mainViewSubstrate', 'topLeft' ],
			[ 'bottomRight', 'mainViewSubstrate', 'bottomRight' ],
			[ 'topRight', 'fullScreenButton', 'topRight' ],
			[ 'hidden', 'toolBar' ],
			[ 'hidden', 'browserBox' ],
			[ 'hidden', 'thumbnailListBox' ],
			[ 'hidden', 'toolButton' ],
			[ 'hidden', 'zoomButton' ] ] ],
		[ 'noFilesOrThumbs', [
			[ 'topLeft', 'toolBar', 'topLeft' ],
			[ 'right', 'toolBar', 'right' ],
			[ 'topLeft', 'mainViewSubstrate', 'bottomLeft', 'toolBar' ],
			[ 'bottomRight', 'mainViewSubstrate', 'bottomRight' ],
			[ 'topRight', 'fullScreenButton', 'topRight' ],
			[ 'bottomLeft', 'toolButton', 'bottomLeft' ],
			[ 'bottomLeft', 'zoomButton', 'bottomRight', 'toolButton' ],
			[ 'hidden', 'browserBox' ],
			[ 'hidden', 'thumbnailListBox' ] ] ],
		[ 'noThumbs', [
			[ 'topLeft', 'toolBar', 'topLeft' ],
			[ 'right', 'toolBar', 'right' ],
			[ 'topLeft', 'browserBox', 'bottomLeft', 'toolBar' ],
			[ 'bottom', 'browserBox', 'bottom' ],
			[ 'topLeft', 'mainViewSubstrate', 'topRight', 'browserBox' ],
			[ 'bottomRight', 'mainViewSubstrate', 'bottomRight' ],
			[ 'topRight', 'fullScreenButton', 'topRight' ],
			[ 'bottomLeft', 'toolButton', 'bottomLeft' ],
			[ 'bottomLeft', 'zoomButton', 'bottomLeft', 'mainViewSubstrate' ],
			[ 'hidden', 'thumbnailListBox' ] ] ],
		[ 'noFiles', [
			[ 'topLeft', 'toolBar', 'topLeft' ],
			[ 'right', 'toolBar', 'right' ],
			[ 'topLeft', 'thumbnailListBox', 'bottomLeft', 'toolBar' ],
			[ 'bottom', 'thumbnailListBox', 'bottom' ],
			[ 'topLeft', 'mainViewSubstrate', 'topRight', 'thumbnailListBox' ],
			[ 'bottomRight', 'mainViewSubstrate', 'bottomRight' ],
			[ 'topRight', 'fullScreenButton', 'topRight' ],
			[ 'bottomLeft', 'toolButton', 'bottomLeft' ],
			[ 'bottomLeft', 'zoomButton', 'bottomLeft', 'mainViewSubstrate' ],
			[ 'hidden', 'browserBox' ] ] ],
		[ 'all', [
			[ 'topLeft', 'toolBar', 'topLeft' ],
			[ 'right', 'toolBar', 'right' ],
			[ 'topLeft', 'browserBox', 'bottomLeft', 'toolBar' ],
			[ 'bottom', 'browserBox', 'bottom' ],
			[ 'topLeft', 'thumbnailListBox', 'topRight', 'browserBox' ],
			[ 'bottom', 'thumbnailListBox', 'bottom' ],
			[ 'topLeft', 'mainViewSubstrate', 'topRight', 'thumbnailListBox' ],
			[ 'bottomRight', 'mainViewSubstrate', 'bottomRight' ],
			[ 'topRight', 'fullScreenButton', 'topRight' ],
			[ 'bottomLeft', 'toolButton', 'bottomLeft' ],
			[ 'bottomLeft', 'zoomButton', 'bottomLeft', 'mainViewSubstrate' ] ] ] ]

	var scriptConstraints = [
		[ 'top', 'scriptingSubstrate', 'top', 'mainViewSubstrate' ],
		[ 'bottomRight', 'scriptingSubstrate', 'bottomRight' ],
		[ 'bottomRight', 'scriptingHandle', 'bottomLeft', 'scriptingSubstrate' ] ]

	this.layouts = {}
	this.paneVisibilities = {}

	for spec in layoutSpecs
		var constraints = spec[1].concat(scriptConstraints)
		var layout = KSSimpleLayout.new()
		this.layouts[spec[0]] = layout
		var paneVisibilities = {}
		this.paneVisibilities[spec[0]] = paneVisibilities
		for constraintSpec in constraints
			var hidden = (constraintSpec[0] == 'hidden')
			paneVisibilities[constraintSpec[1]] = !!hidden
			var specToUse = (if !!hidden then constraintSpec else [ 'topRight', constraintSpec[1], 'topLeft' ])
			if specToUse.size() == 3
				layout._keep_of_to(specToUse[0].asSymbol(), specToUse[1], specToUse[2].asSymbol())
			else
				layout._keep_of_to_of(specToUse[0].asSymbol(), specToUse[1], specToUse[2].asSymbol(), specToUse[3])

	// also make the editor track the size of the containing window, but with a half-pixel offset so that integer-coordinate lines appear sharp
	this.extentWatcher = $$(@whole.__topContainer__.layoutChanged.doE((() ->
		var e = @whole.__topContainer__.extent()
		var inset = P(0.5, 0.5)
		if !!(@whole.bounds().corner() ~= e-inset)
			@whole.bounds(inset.corner(e-inset)))))! !

!KSDocEditor methodsFor: 'initialization' stamp: 'ael 4/1/2013 19:36'!
createTabsAndBubbles = () ->
	var tabDefs = [
		[ 'Document', [ 'Document', 'In & Out' ] ],
		[ 'Content', [ 'Content', 'Shape', 'Insert New' ] ],
		[ 'Script', [ 'Script', 'Control', 'Sensing', 'Operators', 'Pen', 'Gezira' ] ] ]

	// "turn" removed from Content and Insert New
	// "geometry" and "visibility" removed from Shape
	var bubbleDefs = [
		[ 'Document', [ 'pages', 'threads', 'blank page', 'default font', 'frame' ] ],
		[ 'In & Out', [ 'find', 'send', 'reply' ] ],
		[ 'Content', [ 'edit', 'letters', 'paragraph', 'cells', 'wander' ] ],
		[ 'Shape', [ 'box', 'color', 'border', 'shadow', 'overlap' ] ],
		[ 'Insert New', [ 'insert', 'new', 'blank page' ] ],
		[ 'Script', [ 'control', 'scripts' ] ],
		[ 'Control', [ 'control' ] ],
		[ 'Sensing', [ 'control' ] ],
		[ 'Operators', [ 'control' ] ],
		[ 'Pen', [ 'control' ] ],
		[ 'Gezira', [ 'gezira', 'gezira tiles', 'gezira compositions' ] ] ]

	var ruleDefs = [		// rules for *not* showing a bubble, evaluated in docEd context
		[ 'letters', '!!@textSelection' ],
		[ 'paragraph', '!!@textSelection' ],
		[ 'cells', '!!@selectedDocBox.tableHandler' ],
		[ 'box', '!!@selectedDocBox' ], 
		[ 'color', '!!@selectedDocBox' ], 
		[ 'border', '!!@selectedDocBox' ], 
		[ 'shadow', '!!@selectedDocBox' ], 
		[ 'overlap', '!!@selectedDocBox' ], 
		[ 'wander', '!!@selectedDocBox || @selectedDocBox.contents().isEmpty()' ] ]

	this.tabGroups = {}
	this.topTabs = []
	for pair in tabDefs
		this.tabGroups[pair[0]] = pair[1]
		this.topTabs.push(pair[0])

	// build sets of all bubbles relevant to selected tab.  We now only include bubbles from the same group.
	this.bubbleSets = {}
	for i in [0 .. bubbleDefs.size()]
		var bs = []
		var sameGroup = (group in tabDefs when group[1].includes(bubbleDefs[i][0]))[1]
		for j in [i .. bubbleDefs.size()]
			if sameGroup.includes(bubbleDefs[j][0])
				for b in bubbleDefs[j][1]
					if !!bs.includes(b)
						bs.push(b)
		this.bubbleSets[bubbleDefs[i][0]] = bs

	this.bubbleHideRules = {}
	for pair in ruleDefs
		this.bubbleHideRules[pair[0]] = this.eval("() -> ".concat(pair[1]))		// NB: creates a closure in docEd context

	this.loadedBubbles = {}

	this.relevantBubbles = $$(@selectedTab.mapE((tabName) -> @bubbleSets[tabName]))

	this.tabSwitcher = $$(@selectedTab.mapE((tabName) ->
		var tabBar = @tabBar
		var shownGroup = (group in this.topTabs when this.tabGroups[group].includes(tabName))
		var tabItems = []
		for group in @topTabs
			for t in (if group == shownGroup then @tabGroups[group] else [group])
				tabItems.push([t, t])
		tabBar.setItems(tabItems)
		tabBar.removeAllParts()
		tabBar.layOut()
		for tabSpec in [ [ [ tabName ], 8, Color.white() ], [ @tabGroups[shownGroup], 14, @factory.theme.themeColor._alphaMixed_with(0.5, Color.white()) ] ]
			var tabSet = tabSpec[0]
			var firstItem = (item in tabBar.contents when item.actionID == tabSet.first())
			var lastItem = (item in tabBar.contents when item.actionID == tabSet.last())
			var merged = firstItem.bounds().merge(lastItem.bounds()).outsetBy(P(tabSpec[1], 1))
			var tabShape = @factory.newTabShape(merged.extent(), @factory.theme.edgeColor, tabSpec[2])
			tabShape.topLeft(merged.origin())
			tabBar.addAsBackgroundParts(tabShape)))

	this.bubbleWatcher = $$(mergeE(@relevantBubbles, @selectedDocBox, @focusLayout, @textSelection, @whole.extent).doE(() -> this.checkBubbleVisibility()))
	this.selectedTab = $$(@tabBar.itemSelected.mapE((ev) -> ev.handler.actionID)).startsWith("Document")

	// ignore halo movement to any box not in the document (to allow halo on editor itself).
	// If halo moves to a doc box with a text layout, force the keyboard focus to the same box - otherwise force it to nil 
	this.selectedDocBox = $$(@whole.__topContainer__.haloTarget.mapE((box) ->
		if box
			if this.boxBelongsToDoc(box)
				var newFocus = if box.layout() instanceof KSTextLayout then box else nil
				@whole.hand().keyboardFocus(newFocus)
				this.docKeyboardFocus.set(newFocus)	// because it won't catch a change to nil
				box
			else
				undefined		// don't change
		else
			nil))

	// similarly, only track switches of keyboard focus within the scope of the document,
	// and if focus changes to a doc box and there's a halo anywhere, make sure it's on the same box.
	this.docKeyboardFocus = $$(@whole.__topContainer__.worldState.hand.keyboardFocus.mapE((box) ->
		if box && this.boxBelongsToDoc(box)
			var haloTarget = @whole.__topContainer__.haloTarget
			if haloTarget && (haloTarget !!== box)
				this.whole.__topContainer__.haloTarget.set(box)
			box
		else
			undefined))		// NB: no change if keyboardFocus becomes nil (e.g. when clicking in toolbar)

	// reset both if the user switches to a new page
	this.pageWatcher = $$(@doc.handler.pagesChanged.doE(() ->
		if @selectedDocBox		// NB: not necessarily current haloTarget
			if @selectedDocBox === @whole.__topContainer__.haloTarget
				this.whole.__topContainer__.haloTarget.set(nil)	// but if so, remove halo
			this.selectedDocBox.set(nil)	// and in any case clear doc selection
		if @docKeyboardFocus
			if @docKeyboardFocus === @whole.hand().keyboardFocus
				this.whole.hand().keyboardFocus(nil)
			this.docKeyboardFocus.set(nil)))

	// for operations that affect a layout, figure out which layout would be relevant
	// (add pageWatcher and selectedDocBox dependencies because they can affect docKeyboardFocus) 
	this.focusLayout = $$(mergeE(@docKeyboardFocus, @selectedDocBox, @pageWatcher).doE(() ->
		// we can have a keyboard focus without a selected doc box, but not v.v.
		if @docKeyboardFocus
			@docKeyboardFocus.layout() ? nil	// force nil, because undefined means no change
		else
			nil))

	// similarly for operations that affect a text selection
	this.textSelection = $$(mergeE(@focusLayout, @focusLayout.selection, (@editorCommandFinished.doE(() -> #"cmd"))).mapE((trigger) ->
		var newVal = nil
		if @focusLayout
			// note: textSelection can be empty
			var range = @focusLayout.selection
			if range && (@focusLayout instanceof KSTextLayout)
				newVal = @focusLayout.whole.contents._copyFrom_to(range.first()+1, range.last()-1)
		// avoid needless triggers when text selection hasn't changed
		if trigger === #"cmd" && newVal === @textSelection'
			undefined
		else
			newVal))

	// watch for "fire" events in command bubbles to launch commands
	this.bubbleCommandDispatch = $$(switchColE(@bubbleBar.contents, "fire").mapE((ev) ->
		var codeString = @commandTable[ev.handler.actionID]
		if codeString
			this.eval("(event) -> ".concat(codeString)).value(ev)
		else
			Transcript.show("Action not in Command Table: ".concat(ev.handler.actionID)).cr()
		true))

	// and set up a stream to watch for commands launched via menus (see triggerMenuCommand)
	this.menuCommandRequest = this.streamOf({ target: null, selector: null, args: null })
	this.menuCommandDispatch = $$(@menuCommandRequest.mapE((cmd) ->
		if cmd.target
			cmd.target.ksMenuPerform(cmd.selector, cmd.args)
		true))

	// many objects want to know when the processing of an editor command has finished
	this.editorCommandFinished = $$(mergeE(@bubbleCommandDispatch, @menuCommandDispatch))! !

!KSDocEditor methodsFor: 'initialization' stamp: 'yo 2/28/2013 13:48'!
documentGroupBubbleCommands = () ->
	return [
		// each code string will be evaluated in the context of the doc editor, and can assume the binding of var 'event' to the event that triggered the command

		// pages
		[ "back in doc history", "this.editorAction('backInDocHistory')" ],
		[ "forward in doc history", "this.editorAction('forwardInDocHistory')" ],

		[ "show go back", "this.maybeStackAction('back')" ],
		[ "previous page", "this.maybeStackAction('prev')" ],
		[ "next page", "this.maybeStackAction('next')" ],
		[ "new page", "this.maybeStackAction('new')" ],
		[ "copy page", "this.maybeStackAction('copy')" ],
		[ "delete page", "this.maybeStackAction('delete')" ],
		[ "paste page", "this.maybeStackAction('paste')" ],

		// threads
		[ "thread first", undefined ],
		[ "thread previous", undefined ],
		[ "thread back", undefined ],
		[ "thread next", undefined ],
		[ "thread last", undefined ],
		[ "thread choose", undefined ],
		[ "thread new", undefined ],
		[ "thread edit", undefined ],

		// blank page
		[ "blank background", "this.editorAction('insertBackground')" ],
		[ "page like", "this.editorActionInteractive('chooseBackground', event)" ],
		[ "new document", "this.editorAction('newDoc')" ],

		// default font
		[ "choose default font", "this.editorActionInteractive('docFontChoose', event)" ],
		[ "choose default font size", "this.editorActionInteractive('chooseDocFontSize', event)" ],
		[ "enlarge default font", "this.editorActionInteractive('docLargerFont', event)" ],
		[ "shrink default font", "this.editorActionInteractive('docSmallerFont', event)" ],
		[ "choose default font color", "this.editorActionInteractive('docTextColor', event)" ],

		// frame
		[ "toggle portrait landscape", "this.maybeStackAction('toggleAspect')" ],
		[ "margin narrower", undefined ],
		[ "margin wider", undefined ],
		[ "full screen", "this.editorAction('toggleFullScreenAll')" ],
		[ "screen dpi", "this.editorActionInteractive('setDPI', event)" ],
		[ "page size", "this.editorActionInteractive('setPageSize', event)" ],
		[ "extra window", "this.editorAction('toggleHostWindow', event)" ],

		// find
		[ "find in everything", "this.provisionalFindAction('everything')" ],		// to do
		[ "find in mail", "this.provisionalFindAction('mail')" ],
		[ "find in docs", "this.provisionalFindAction('docs')" ],
		[ "find in internet", "this.provisionalFindAction('internet')" ],

		[ "load doc", "this.editorActionInteractive('loadDocument', event)" ],
		[ "load page", "this.editorActionInteractive('loadPage', event)" ],
		[ "load odf", "this.editorActionInteractive('loadODF', event)" ],
		[ "append odf", "this.editorActionInteractive('appendODF', event)" ],

		// send
		[ "send to internet", "this.editorActionInteractive('saveDocumentRemote', event)" ],
		[ "send to file", "this.editorActionInteractive('saveDocument', event)" ],
		[ "send to address", "this.provisionalSendToAddress()" ],
		[ "save page", "this.editorActionInteractive('savePage', event)" ],
		[ "insert mark for printing", "this.editorActionInteractive('insertMarkForPrinting', event)" ],
		[ "make pdf", "this.editorActionInteractive('makePDF', event)" ],

		// reply
		[ "doc reply", undefined ],
		[ "doc forward", undefined ] ]	! !

!KSDocEditor methodsFor: 'initialization' stamp: 'ael 2/25/2013 13:37'!
loadBubble = (bName) ->
	if !!this.loadedBubbles.includesKey(bName.asSymbol())		// a better way?
		Cursor.execute().showWhile(() ->						// ditto
			var path = "http://tinlizzie.org/dbjr/".concat(bName).concat("Bubble.ks")
			try
				if KSDocEditor.forceCacheRefresh()
					var box = KSBox.loadBoxFromDirectoryViaCache(path)
				else
					box = KSBox.loadBoxFromDirectoryViaCacheFirst(path)
				box.name(bName)
			catch ex
				if ex instanceof FileDoesNotExistException
					box = nil
				else
					ex.signal()
			this.loadedBubbles[bName] = box
			if box
				box.eval('this.fire = $$(switchColE(@contents, "fire"))')		// each bubble gathers fire events from all its buttons
			else
				Transcript.show("Failed to find bubble: ".concat(bName)).cr())
	return this.loadedBubbles[bName]! !

!KSDocEditor methodsFor: 'initialization' stamp: 'yo 3/1/2013 22:29'!
openDocPath = (path) ->
	this.saveScript()
	if path.asString().endsWith(".odp")
		var doc = this.openODF(path)
	else
		var doc = KSBox.loadBoxFromDirectoryViaCache(path)
	this.docLoaderRequest.set(doc)

	var history = this.docHistory
	var index = this.docHistoryIndex
	if !!(index >= 0 && index < history.size() && path == history[index])	// if not moving to an existing entry...
		for i in [1 ... history.size()-index-1] 		// wipe old forward entries, if any
			history.pop()
		history.push(path)
		if history.size() > 40
			history.removeFirst()
		this.docHistoryIndex = history.size()-1! !

!KSDocEditor methodsFor: 'initialization' stamp: 'ael 2/21/2013 19:11'!
scriptGroupBubbleCommands = () ->
	return [
		// each code string will be evaluated in the context of the doc editor, and can assume the binding of var 'event' to the event that triggered the command

		// control
		[ "control stop all", undefined ],
		[ "control resume", undefined ],

		// scripts
		[ "script1", undefined ],
		[ "script2", undefined ],
		[ "script3", undefined ],

		// gezira
		[ "new gezira scripting area", undefined ],
		[ "gezira operator", undefined ] ]

		// gezira tiles
		// (yeah, right...)

		// gezira compositions
		// (ditto)! !

!KSDocEditor methodsFor: 'initialization' stamp: 'yo 8/19/2013 14:09'!
setupOn = (initialDoc) ->
	this.factory = @whole.factory()
	this.defaultFont = this.streamOf(KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(10))
	this.findString = this.streamOf("")
	this.sendTarget = this.streamOf("")
	this.docHistory = []
	this.docHistoryIndex = -1

	@factory.themeNamed("orange")		// "blue"  "green"  "steel"
	var docEditorBox = @whole
	docEditorBox.name("docEditorBox")
	docEditorBox.borderWidth(1)
	docEditorBox.borderFill(@factory.theme.edgeColor)
	var inset = P(0.5, 0.5)
	docEditorBox.bounds(inset.corner(docEditorBox.__topContainer__.bounds().corner()-inset))

	var toolHeight = 112
	this.addToolBar(toolHeight)
	this.createLayouts()
	this.createTabsAndBubbles()
	this.createCommandTable()
	this.addListPanes()
	this.addDocumentView()
	this.addLayoutButtons()
	this.addScriptingPane()				// after layout buttons so script area doesn't obscure them

	this.toolBar.layOut()				// so the right width of bubbles is loaded

	this.docChangeCleanup = $$(@doc.doE(() ->
		@whole.worldState().deleteHalo()
		@whole.hand().keyboardFocus(nil)))

	this.docLoaderRequest = this.streamOf(initialDoc)
	this.doc = $$(@docLoaderRequest.mapE((anObject) ->
		this.mainViewBox.removeAll()
		if anObject
			this.mainViewBox.add(anObject)
		anObject))

	this.fullScreenAll = this.streamOf(false)! !

!KSDocEditor methodsFor: 'odf' stamp: 'yo 8/17/2013 10:35'!
openODF = (urlString) ->
	// Import ODF presentation from the stream.
	// If an ODF page has a text object like [[url.ks]],
	// the page is replaced by the specified file."
	var doc = KSODFDocument.readFromStream(PPPusher.fileObject(urlString))
	var boxes = doc.renderPages()
	doc.close()

	var stack = KSStack.newStack()
	for box in boxes
		var replacementName = box.ppEmbeddedName()
		if replacementName
			var replacement = KSBox.loadBoxFromDirectoryViaCache(box.ppEmbeddedName())
		var realBox = replacement ? box
		stack.addPage(realBox)
		realBox.installODFScript()
		realBox.resetODFScript()

	var newName = FileDirectory.baseNameFor(urlString.asUrl().localName())
	// stack stackName: newName.
	stack.stackAction('first', nil)		//first page is a dummy
	stack.stackAction('delete', nil)
	return stack.whole! !

!KSDocEditor methodsFor: 'odf' stamp: 'yo 2/21/2013 16:45'!
saveScript = () ->
	Transcript.show(Time.millisecondClockValue().printString()).cr()
	if @scriptingArea.handler.scriptDirty
		if @doc.handler instanceof KSStack
			var box = @doc.handler.pageBox()
		else
			box = @doc
		if !!box
			return
		box.odfScript = this.scriptingArea.handler.serialize(this.scriptingArea.handler.head())
		this.scriptingArea.handler.head().removeAll()
	this.scriptingArea.handler.scriptDirty = false! !

!KSDocEditor methodsFor: 'odf' stamp: 'ael 3/5/2013 01:56'!
updateODFScripts = () ->
	var areaHandler = @scriptingArea.handler
	var docHandler = @doc.handler
	if docHandler instanceof KSStack
		if areaHandler.scriptDirty
			if @doc.handler.pageChanges.oldPageIndex !!= 0
				docHandler.oldPageBox().odfScript = areaHandler.serialize(areaHandler.head())
		areaHandler.head().removeAll()
		var h = areaHandler.head().handler
		var scr = docHandler.pageBox().odfScript
		if scr
			h.acceptDropOf(h.deserializeScript(scr))
		//	this.scriptingArea.doLayout()
		//	this.scriptingArea.layoutChanged.set(nil)
	this.scriptingArea.handler.scriptDirty = false! !

!KSDocEditor methodsFor: 'thumbnails' stamp: 'yo 3/4/2013 19:58'!
setupThumbnailsBehavior = () ->
	this.thumbnailUpdater = $$(mergeE(@doc,
		@doc.handler.pagesChanged.mapE((pages) ->
			if @doc.handler.samePages(pages.oldPages, pages.newPages) then undefined else pages)).doE(() ->
			this.thumbnailListBox.removeAll()
			if @doc && @doc.handler
				var boxes = @doc.handler.createThumbnails(136)
				this.thumbnailListBox.setItems((["", bb] for bb in boxes))))

	this.thumbnailHighlighter = $$(mergeE(@thumbnailUpdater, @doc.handler.pagesChanged).doE(() ->
		var current = @doc.handler.pageIndex
		for ind in [1...@thumbnailListBox.contents.size()]
			var b = @thumbnailListBox.contentsAt(ind)
			b.borderWidth(2)
			b.borderFill(if ind == current then @factory.theme.edgeColor else @factory.theme.contrastColor)
			delete b.selectionChangeRequested
			b.highlightEnabled = b.streamOf(false)))

	this.thumbnailSelection = $$(@thumbnailListBox.itemSelected.mapE((ev) ->
		if ev.handler.pageIndex
			&& (ev.handler.pageIndex !!= @doc.handler.pageIndex.currentValue())
				@doc.handler.showPageNumber(ev.handler.pageIndex)))

	// one more stream to update the bitmap of particular thumbnail when page is turned.! !

!KSDocEditor class methodsFor: 'demo' stamp: 'tk 4/5/2013 12:50'!
paperFrontPageCol1: text
	"Divide the text  into paragraphs and insert in column 1 of the current document (Front Page.ks).  For the front page of the paper Making Applications in KS World.  Store into property:  Column1Texts of the KSMorph.
	 KSDocEditor paperFrontPageCol1: 'Abstract
We report on a language called KScript and a GUI frame- work called KSWorld. The goal of KScript and KSWorld is to try to reduce the accidental complexity in GUI framework writing and application building. We aim for an understand- able, concise way to specify an application’s behavior and appearance, minimizing extra details that arise only because of the medium being used.
KScript is a dynamic language based on the declara- tive and time-aware dataflow-style execution model of Func- tional Reactive Programming (FRP), extended with support for loose coupling among program elements and a high de- gree of program reconfigurability.
KSWorld is built using KScript. The fields, or slots, of graphical widgets in KSWorld are reactive variables. Defini- tions of such variables can be added or modified in a local- ized manner, allowing on-the-fly customization of the visual and behavioral aspects of widgets and entire applications. Thus the KSWorld environment supports highly exploratory application building: a user constructs the appearance inter- actively with direct manipulation, then attaches and refines reactive variable definitions to achieve the desired overall behavior.
We illustrate our use of KSWorld to build an editor for general graphical documents, including dynamic documents that serve as active essays. The graphical building blocks for documents are the same as those used for building the editor itself, enabling a bootstrapping process in which the earliest working version of the editor can be used to create further components for its own interface.
As one way of measuring progress on our complexity goal, we provide an overview of the number of lines of code in KSWorld. The total for the KScript compiler, the FRP evaluator, the framework, document model and document editor is currently around 10,000 lines.
1. Introduction
The software for today’s personal computing environments has become so complex that no single person can understand'
	"
	"Take a column of text, divide it into paragraphs, and create text boxes for them.  "
	| ksm docEd pageBox col1A col2A paras model fld prev extra bodyFont bodyFont1 bfa cnt indent |
	ksm := ActiveWorld submorphOfClass: KSMorph.
	docEd := ksm window first ksAt: #handler.
	pageBox := (docEd ksAt: #doc) currentValue first.
	col1A := pageBox atName: 'col 1 para'.
	col2A := pageBox atName: 'col 2 para'.
	"Column1Texts is an OC of strings, each holding the contents of a paragraph."
	paras := text findTokens: '
'.
	"paras explore."
	ksm setProperty: #Column1Texts toValue: paras copy.
	"(( ActiveWorld submorphOfClass: KSMorph) valueOfProperty: #Column1Texts) explore"
	col1A layout ksAt: #verticalShrink put: true.
	(col1A layout ksAt: #selection) set: (0 to: 1).
	col1A layout setDefaultFromSelection.
	bodyFont1 := col1A layout ksAt: #font.
	bfa := bodyFont1 unBold.
		"not bold"
		"@font.face().family().withStyle(@font.face().style().bitAnd(15-1))"
	bodyFont := (bfa withSize: (bodyFont1 pointSize - 3)).
		"decrease by 2"
	col1A removeAll.
	col1A layout addAll: (model := paras removeFirst).
	prev := col1A.
	cnt := 0.
	paras do: [:txt | cnt := cnt + 1.
		fld := col1A factory newTextField.
		fld scale: col1A scale.
		pageBox add: fld.
		fld layout ksAt: #verticalShrink put: true.
		fld layout ksAt: #font put: bodyFont.
		fld width: col1A width.
		fld layout ksAt: #justification put: 'full'.
		fld borderWidth: 0.
		prev layout layOut: prev.
		indent := ''.
		extra := txt size < 40 
			ifTrue: ["new section" 
				12] 
			ifFalse: ["normal"
				cnt ~= 1 ifTrue: [indent := '   '].
				0].
		fld topLeft: (prev bottomLeft) + (0@(extra)).
		fld layout addAll: indent,txt.
		extra > 0 ifTrue: [fld contents do: [:let | 
				let beBold: true.
				let increaseFontBy: 3]].
		fld layout layOut: fld.
		prev := fld.
		].
	pageBox layoutChanged.
	^ paras! !

!KSDocEditor class methodsFor: 'demo' stamp: 'tk 4/5/2013 12:29'!
paperFrontPageCol2: text
	"Divide the text  into paragraphs and insert in column 1 of the current document (Front Page.ks).  For the front page of the paper Making Applications in KS World.  Store into property:  Column1Texts of the KSMorph.
	 KSDocEditor paperFrontPageCol2: 'an entire system: a typical desktop OS and commonly used application suite amount to over 100 million lines of code. Our group’s early experiences with personal computing led us to understand that much of this complexity is “acciden- tal”, rather than inherent. In the STEPS project we therefore explored how to reduce such accidental complexity in soft- ware, setting as our domain of interest the entire personal computing environment [1].
In this paper we focus on the end-user authoring envi- ronment. We feel that end-users should be able to make ap- plications of the same kind as those they are using. Toward'
	#### remember to change the font of    buttonDown:, buttonUp, pointerMotion,
	"
	"Take a column of text, divide it into paragraphs, and create text boxes for them.  "
	| ksm docEd pageBox col1A col2A paras fld prev extra bodyFont fst jj indent |
	ksm := ActiveWorld submorphOfClass: KSMorph.
	docEd := ksm window first ksAt: #handler.
	pageBox := (docEd ksAt: #doc) currentValue first.
	col1A := pageBox atName: 'col 1 para'.
	col2A := pageBox atName: 'col 2 para'.
	"Column1Texts is an OC of strings, each holding the contents of a paragraph."
	paras := text findTokens: '
'.
	"paras explore."
	ksm setProperty: #Column2Texts toValue: paras copy.
	"(( ActiveWorld submorphOfClass: KSMorph) valueOfProperty: #Column2Texts) explore"
	col2A layout ksAt: #verticalShrink put: true.
	(col2A layout ksAt: #selection) set: (0 to: 1).
	col2A layout setDefaultFromSelection.
	bodyFont := col2A layout ksAt: #font.
	col2A removeAll.
	fst := paras removeFirst.
	fst := fst copyReplaceAll: '•' with: '
   •'.		"bullets"
	fst first isSeparator ifTrue: [fst := fst allButFirst].	"remove cr"
	jj := (fst includes: '•' first) ifTrue: ['left'] ifFalse: ['full'].
	col2A layout ksAt: #justification put: jj.
	col2A layout addAll: fst.
	prev := col2A.
	paras do: [:txt | 
		fld := col2A factory newTextField.
		fld scale: col2A scale.
		pageBox add: fld.
		fld layout ksAt: #verticalShrink put: true.
		fld layout ksAt: #font put: bodyFont.
		fld width: col2A width.
		fld layout ksAt: #justification put: 'full'.
		fld borderWidth: 0.
		prev layout layOut: prev.
		extra := txt size < 40 
			ifTrue: ["new section" indent := ''.
				12] 
			ifFalse: ["normal"  indent := '   '.
				0].
		fld topLeft: (prev bottomLeft) + (0@(extra)).
		fld layout addAll: indent,txt.
		extra > 0 ifTrue: [fld contents do: [:let | 
				let beBold: true.
				let increaseFontBy: 3]].
		fld layout layOut: fld.
		prev := fld.
		].
	pageBox layoutChanged.
	^ paras! !

!KSDocEditor class methodsFor: 'demo' stamp: 'tk 3/27/2013 12:23'!
paperFrontPageFigCaption
	"After putting in Figure 1, put a horizontal rule under it and the caption.  Bold part of it.
	 KSDocEditor paperFrontPageFigCaption
	"

	| ksm docEd pageBox col1A col2A fig1 box fld |
	ksm := ActiveWorld submorphOfClass: KSMorph.
	docEd := ksm window first ksAt: #handler.
	pageBox := (docEd ksAt: #doc) currentValue first.
	col1A := pageBox atName: 'col 1 para'.
	col2A := pageBox atName: 'col 2 para'.
	fig1 := pageBox atName: 'Figure1'.
	box := KSBox extent: (col2A width @ 0.5) fill: (Color black).
	pageBox addFirst: box.
	box scale: col2A scale.
	box topCenter: fig1 bottomCenter + (0@5).
	box name: 'hr'.
	
	"Caption"
	fld := col1A factory newTextField.
	fld scale: col2A scale.
	fld name: 'caption'.
	pageBox addFirst: fld.
	fld layout ksAt: #verticalShrink put: true.
	fld layout ksAt: #font put: (col2A layout ksAt: #font).
	fld width: col2A width.
	fld layout ksAt: #justification put: 'center'.
	fld borderWidth: 0.
	fld layout addAll: 'Figure 1. The Frank Document Editor.'.
	1 to: 'Figure 1.' size do: [:ind | (fld contents at: ind) beBold: true].
	fld topCenter: box bottomCenter + (0@2).
	
"	| ksm docEd pageBox |
	ksm := ActiveWorld submorphOfClass: KSMorph.
	docEd := ksm window first ksAt: #handler.
	pageBox := (docEd ksAt: #doc) currentValue first.
	(pageBox atName: 'hr') delete.
	(pageBox atName: 'caption') delete.
"! !

!KSDocEditor class methodsFor: 'demo' stamp: 'tk 4/5/2013 12:39'!
paperFrontPageScreenshot: picName
	"Assuming there is a thumbnail named 'frank1.png' in the current folder, it creates the Box with it and insert it to the top of the second column.
	For NSF report:
	 KSDocEditor paperFrontPageScreenshot: 'frank1.png'.
	For Onwaed!! paper
	 KSDocEditor paperFrontPageScreenshot: 'onward.png'.
	"
	"extent should be 540@(1.29*540)"
"
(ActiveWorld submorphOfClass: KSMorph) extent: 730@980
Content and letters bubbles showing.

PNGReadWriter putForm: ((ActiveWorld submorphOfClass: KSMorph) window thumbnailScale: 1.0) texture onFileNamed: 'onward-out.png'
| bi fo |
fo := ((ActiveWorld submorphOfClass: KSMorph)window thumbnailScale: 1.0) texture.
bi := fo bits.
bi withIndexDo: [:vv :ii | bi at: ii put: (vv bitOr: 16rFF000000)].
PNGReadWriter putForm: fo onFileNamed: 'onward-out.png'.
"
"
For the onward paper, I'm using
self extent: 730@980 
for the KSMorph, and 125%
"

	| ksm docEd pageBox box thumb |
	ksm := ActiveWorld submorphOfClass: KSMorph.
	docEd := ksm window first ksAt: #handler.
	pageBox := (docEd ksAt: #doc) currentValue first.
	pageBox extent = (540@696.6) ifFalse: [
		Transcript cr; show: 'page extent is not 540@696.6.  ', pageBox extent printString].
	thumb := (PNGReadWriter on: (FileStream readOnlyFileNamed: picName)) nextImage.
	box := KSBox extent: thumb extent fill: (GeziraFill image: thumb).
	pageBox addFirst: box.
	box name: 'Figure1'.
	box scale: (190 / 690.0).
	box topCenter: (pageBox atName: 'col 2 para') topCenter x@(pageBox atName: 'col 1 para') top.! !

!KSDocEditor class methodsFor: 'demo' stamp: 'tk 3/11/2013 15:20'!
paperFrontPageSetup
	"In the current document (Front Page.ks), move fields around to look like the current front page of the paper Making Applications in KS World.
	 KSDocEditor paperFrontPageSetup
	"
	"Take a column of text, divide it into paragraphs, and create text boxes for them.  "
	"extent should be 540@(1.29*520)"
	| ksm docEd pageBox ab col1A col2A ib tb eb |
	ksm := ActiveWorld submorphOfClass: KSMorph.
	docEd := ksm window first ksAt: #handler.
	pageBox := (docEd ksAt: #doc) currentValue first.
	pageBox extent = (540@696.6) ifFalse: [
		Transcript cr; show: 'page extent not 520@670.  ', pageBox extent printString]. 
	tb := pageBox atName: 'Title'.
	ab := pageBox atName: 'Authors'.
	ib := pageBox atName: 'Institution'.
	eb := pageBox atName: 'Emails'.
	col1A := pageBox atName: 'col 1 para'.
	col2A := pageBox atName: 'col 2 para'.
	tb topCenter: (pageBox width // 2 @ tb topCenter y).
	ab topCenter: (pageBox width // 2 @ ab topCenter y).
	ib topCenter: (pageBox width // 2 @ ib topCenter y).
	eb topCenter: (pageBox width // 2 @ eb topCenter y).
	
	
	"Column1 is an OC of strings, each holding the contents of a paragraph."
	! !

!KSDocEditor class methodsFor: 'instance creation' stamp: 'ael 3/5/2013 01:38'!
open
"
	KSDocEditor open ksExplore
"
	^self openIn: KSMorph new on: nil! !

!KSDocEditor class methodsFor: 'instance creation' stamp: 'ael 3/5/2013 01:52'!
openIn: ksm on: docBoxOrNil
"
	(KSDocEditor openOn: nil) ksExplore
"
	| docEd ex topBox |
	ex := 900@450.
	ksm openInWorld extent: ex.
	docEd := self new.
	topBox := KSBox extent: ex fill: Color white.
	docEd installTo: topBox.
	ksm window add: topBox.
	docEd setupOn: nil..
	ActiveWorld doOneCycleNow.
	(docEd at: #docLoaderRequest) set: docBoxOrNil.
	(docEd at: #docLoaderRequest) setLastTime: -1.
	^ topBox! !

!KSDocEditor class methodsFor: 'instance creation' stamp: 'tk 3/5/2013 07:43'!
openStackNoFields
"
	KSDocEditor openStackNoFields		ksExplore
"
	| stack ksm |
	ksm := KSMorph new.		"also resets time"
	stack := KSStack exampleNoFields.
	stack addNavBarToAll: nil.
	^self openIn: ksm on: (stack at: #whole)! !

!KSDocEditor class methodsFor: 'instance creation' stamp: 'tk 3/5/2013 07:42'!
openStackTwoFields
"
	KSDocEditor openStackTwoFields		ksExplore
"
	| stack ksm |
	ksm := KSMorph new.		"also resets time"
	stack := KSStack exampleWith2Fields.
	stack addNavBarToAll: nil.
	^self openIn: ksm on: (stack at: #whole)! !

!KSDocEditor class methodsFor: 'resources' stamp: 'ael 2/8/2013 02:37'!
forceCacheRefresh
	"whether remote files (including bubbles) are downloaded every time, or only if not in the local cache already"
	^true! !
