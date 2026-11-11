KSObject subclass: #KSFactory
	instanceVariableNames: ''
	classVariableNames: 'Graphics'
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/5/2013 15:36'!
createHScrollerFor = (box) ->
	return KSBox._extent_fill(box.extent(), Color.transparent()).beScrollerFor(box, true, false, false)! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/5/2013 15:36'!
createHVScrollerFor = (box) ->
	return KSBox._extent_fill(box.extent(), Color.transparent()).beScrollerFor(box, true, true, false)! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/5/2013 15:36'!
createVScrollerFor = (box) ->
	return KSBox._extent_fill(box.extent(), Color.transparent()).beScrollerFor(box, false, true, false)! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/5/2013 15:37'!
createVScrollerForText = (textBox) ->
	textBox.handler.verticalShrink = true
	return KSBox._extent_fill(textBox.extent(), Color.transparent()).beScrollerFor(textBox, false, true, true)! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 10/9/2012 11:57'!
fillInTheBlankLayout
	| layout |
	layout := KSSimpleLayout new.
	layout
		keep: #topLeft of: 'titleBox' to: #topLeft;
		keep: #topLeft of: 'fieldBox' to: #bottomLeft of: 'titleBox';
		keep: #bottomLeft of: 'okButton' to: #bottomLeft of: nil offset: (10 @ -10);
		keep: #bottomRight of: 'cancelButton' to: #bottomRight of: nil offset: (-10 @ -10);
		yourself.
	^ layout! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 1/17/2013 21:29'!
graphicNamed = (aString) ->
	var box = KSBox.withShape(this.graphicShapeNamed(aString))
	box.attachShapeScaler()
	box.name(aString)
	return box! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 1/16/2013 14:39'!
graphicPathsNamed = (name) ->
	if this.graphics()[name]
		return this.graphics()[name]
	var svg = (KSSVGReader.new().readFromStream(this.perform(name.concat("SVG").asSymbol()).readStream())).elements().asArray()
	this.graphics()[name] = svg
	return svg! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 1/17/2013 21:30'!
graphicShapeNamed = (aString) ->
	return KSShape.new().elements(this.graphicPathsNamed(aString))! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 1/16/2013 14:36'!
graphics
	^ Graphics ifNil: [Graphics := KSObject new].! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/5/2013 16:09'!
newButton = (label) ->
	var box = this.newLabel(label)
	var shape = KSShape._extent_fill(P(16, 16), box.fill())
	shape.cornerRadius(4)
	box.shape(shape)
	box.attachShapeStretcher(box.extent()/2.0)
	box.layout().inset(2)
	box.name(label.asString())
	box.borderWidth(1)
	box.attachButtonHandler()
	box.layOut()
	return box! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 3/12/2013 22:09'!
newCell = () ->
	var box = this.newLabel(" ", Color.gray(0.92), KSFont.defaultFont())
	box.layout().justification = "right"
	box.layout().verticalShrink = false
	box.layout().horizontalShrink = false
	box.clipping(true)
	box.width(36)
	box.borderWidth(1)
	box.borderFill(Color.gray(0.75))
	box.pivotRatio(P(0, 0.667))
	box.attachCellUpdater()
	return box! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/25/2013 08:48'!
newColorPicker = () ->
	var picker = KSBox.new()
	picker.fill(Color._white())
	picker.borderWidth(1)
	picker.borderFill(Color._black())
	picker.extent(P(308, 328))
	picker.beColorPicker()
	return picker! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 10/9/2012 14:26'!
newFillInTheBlank = (title, initialAnswer) ->
	var inst = KSBox._extent_fill(P(140, 80), Color.white())
	inst.borderWidth(1)
	var titleBox = KSBox._extent_fill(P(120, 24), @theme.themeColor)
	titleBox.name("titleBox")
	var fieldBox = KSBox._extent_fill(P(120, 24), Color.white())
	fieldBox.name("fieldBox")
	fieldBox.textContents(initialAnswer)
	var okButton = this.newButton("OK")
	okButton.name("okButton")
	var cancelButton = this._newButton("Cancel")
	cancelButton.name("cancelButton")

	inst.add(titleBox)
	inst.add(fieldBox)
	inst.add(okButton)
	inst.add(cancelButton)
	inst.fieldBox = fieldBox
	inst.okButton = okButton
	inst.cancelButton = cancelButton

	titleBox.textContents(title)
	titleBox.layout().justification = "center"
	titleBox.width(140)
	inst.layout(this.fillInTheBlankLayout())
	inst.beFillInTheBlank()
	return inst! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 9/9/2013 14:18'!
newLabel = (label, fill, font) ->
	var box = KSBox._extent_fill(P(0, 0), fill ? Color.transparent())
	box.beLabel()
	box.layout().font = font
	box.layout().inset(P(0, 0))
	box.layout().horizontalShrink = true
	box.layout().verticalShrink = true
	box.layout().noWrap = true
	box.textContents(label)
	//box.beOptimizedField()
	box.layOut()
	return box! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/4/2013 16:29'!
newLineEditor = (width, fill, font) ->
	// create a one-line editable text field.  If width is non-nil, the field is fixed to that width.
	var box = KSBox.new()
	box.beLineEditor()
	box.fill(fill ? Color.transparent())
	box.borderWidth(1)
	box.name('line')
	box.layout().font = font ? KSFactory.default().defaultFont()
	if width
		box.layout().minimumWidth = box.layout().maximumWidth = width

	// lay out once to set the initial extent - but need to have some text in order to do so
	box.textContents(" ")
	box.layOut()
	box.textContents("")

	return box! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 1/29/2013 14:08'!
newList = () ->
	var box = this.newMenu()
	box.stayUp.set(true)
	return box! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 1/25/2013 10:19'!
newMenu
	^ (KSBox extent: 10@10 fill: (((Color r: 0.929 g: 0.929 b: 0.929)) alpha: 0.9))
		cornerRadius: 3;
		borderWidth: 1;
		borderFill: (Color black alpha: 0.5);
		attachShapeStretcher: 5@5;
		beMenuHandler: false with:{}! !

!KSFactory methodsFor: 'box creation' stamp: 'yo 10/4/2012 23:06'!
newSlider = (aPoint) ->
	var ext = aPoint
	if aPoint.x() > aPoint.y()
		ext = aPoint.transposed()
	var inst = KSBox._extent_fill(ext, this.theme.themeColor)
	if aPoint.x() > aPoint.y()
		inst.rotation(-90.degreesToRadians())	
	inst.borderFill(this.theme.borderColor)
	inst.borderWidth(1)
	inst.addSliderHandler()
	inst.name("slider")
	inst.factory = this
	return inst! !

!KSFactory methodsFor: 'box creation' stamp: 'bf 9/4/2012 19:42'!
newSliderKnob = (aPoint) ->
	var knob = KSBox._extent_fill(aPoint, this.theme.contrastColor)
	knob.borderFill(this.theme.borderColor)
	knob.borderWidth(1)
	// knob.cornerRadius: ext x / 2.
	knob.factory = this
	return knob! !

!KSFactory methodsFor: 'box creation' stamp: 'tk 3/12/2013 16:43'!
newTextField = () ->
	// create an editable text field.
	var textBox = KSBox.new()
	textBox.beTextField()
	textBox.extent(P(200, 40))
	textBox.fill(Color.transparent())
	textBox.borderWidth(1)
	textBox.name('text')
	textBox.layout().font = KSFactory.default().defaultFont()
	return textBox! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/5/2013 16:13'!
newToolButton = (label, fontOrNil) ->
	var font = fontOrNil ? KSFamily.withName("DejaVuSans").withStyle(1).withSize(9.54).fill(this.theme.iconColor)
	var button = this.newLabel(label, Color.transparent(), font)
	button.layout().inset(2)
	button.name(label)
	button.borderWidth(0.5)
	button.cornerRadius(4)
	button.attachButtonHandler()
	button.defaultFill = Color.transparent()
	button.enteredFill = this.buttonGradient()
	button.pressedFill = this.theme.contrastColor
	button.defaultBorderFill = Color.transparent()
	button.enteredBorderFill = this.theme.iconColor
	button.layOut()
	button.wantsTooltip = true
	return button! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/4/2013 16:47'!
newTooltip = () ->
	var box = this.newLabel(" ", Color.lightYellow(), KSFamily.withName("DejaVuSans").withStyle(0).withSize(10))
	box.layout().inset(2)
	box.borderFill(Color.brown())
	box.borderWidth(1)
	box.visible.set(false)
	return box! !

!KSFactory methodsFor: 'box creation' stamp: 'ael 3/15/2013 14:47'!
setListFillsFromTheme = () ->
	var listBaseColor = @theme.listBaseColor ? @theme.edgeColor.adjustBrightness(1.0)		// stop-gap
	this.theme.enteredFill = listBaseColor.veryMuchLighter()
	this.theme.pressedFill = listBaseColor
	this.theme.selectedFill = listBaseColor.muchLighter()! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/27/2013 18:22'!
addBubbleButton = (bubble, buttonLabel, buttonID, topLeft) ->
	var addArrow = buttonLabel.endsWith(">")
	var label = if addArrow then buttonLabel.allButLast() else buttonLabel
	label = "  ".concat(label).concat("  ")
	var button = this.newToolButton(label)
	if addArrow
		button.add(this.menulikeDownArrow())
	bubble.add(button)
	button.topLeft(topLeft)
	button.actionID = buttonID
	button.wantsTooltip = true! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/18/2013 15:41'!
addBubbleButtons = (bubble, buttonsSpec) ->
	// buttonSpec is a collection of collections, each with a column x-offset and a list of pairs [ label, actionID ]
	// e.g. [ [ 0, [ label1, action1 ], [ label2, action2 ] ], [ 100, [ label3, action3 ] ] ]

	// (will be supplied in newToolButton/2) var font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(10.5).fill(this.theme.iconColor)
	var maxInCol = buttonsSpec.collect((s) -> s.size()-1).max()		// tallest column
	var initY
	var yInc
	var x = 4
	if maxInCol < 4
		initY = 6
		yInc = 20
	else
		initY = 2
		yInc = if maxInCol < 5 then 17 else 16

	for columnSpec in buttonsSpec
		var y = initY
		x = x + columnSpec[0]		// each says how much space to leave for prev column
		for buttonSpec in columnSpec.allButFirst()
			this.addBubbleButton(bubble, buttonSpec[0], buttonSpec[1], P(x, y))
			y = y + yInc! !

!KSFactory methodsFor: 'bubble-data' stamp: 'yo 1/18/2013 15:25'!
beBubble = (box, width) ->
	box.extent(P(width, 84))
	var fill = GeziraFillLinearGradient.new()._from_to(P(0, 0), P(0, 84))
	fill._addStop_at([0.9716520309448242, 0.8465298414230347,
		0.5953079462051392, 1.0].asFloatArray(), 0)
	fill._addStop_at([0.9960899353027344, 0.9765396118164063,
		0.939393937587738, 1.0].asFloatArray(), 0.8214285714285714)
	fill._addStop_at([0.9716520309448242, 0.8465298414230347,
		0.5953079462051392, 1.0].asFloatArray(), 0.8314285714285714)
	fill._addStop_at([0.9716520309448242, 0.8465298414230347,
		0.5953079462051392, 1.0].asFloatArray(), 0.8414285714285714)
	fill._addStop_at([0.9716520309448242, 0.8465298414230347,
		0.5953079462051392, 1.0].asFloatArray(), 1.0)
	box.fill(fill)
	box.cornerRadius(8)
	box.borderFill(this.theme.edgeColor)
	box.borderWidth(1)
	return box! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/14/2013 00:05'!
boxBubble = (bubble) ->
	this.beBubble(bubble, 180)
	var box

	box = this.newLineEditor(170, Color.white(), KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(13))
	box.clipping(true)
	box.layout().inset(2)
	box.layout().acceptContentsOnFocusLoss(true)
	box.borderFill(this.theme.edgeColor)
	box.topLeft(P(4, 4))
	bubble.add(box)
	box.eval('this.selectionWatcher = $$(mergeE(@__docEditor__.selectedDocBox, @__docEditor__.editorCommandFinished).doE(() ->
		var b = @__docEditor__.selectedDocBox
		this.textContents(if b then b.printString() else "")))')
	box.eval('this.nameChanger = $$(@contentsAccepted.doE(() ->
		var b = @__docEditor__.selectedDocBox
		if b
			var newName = this.textContents()
			if newName !!= b.printString()		// reduce risk of accidental rename
				b.name(newName)))')

	var font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(9.54).fill(this.theme.iconColor)
	box = this.newLabel("", Color.transparent(), font)
	box.topLeft(P(4, 22))
	bubble.add(box)
	box.eval('this.selectionWatcher = $$(mergeE(@__docEditor__.selectedDocBox, @__docEditor__.editorCommandFinished).doE(() ->
		var b = @__docEditor__.selectedDocBox
		this.textContents(if b then b.layerDescription() else "")))')

	for spec in [ [ P(4, 35), "pick up", "box pick up" ], [ P(4, 53), "delete", "box delete" ], [ P(65, 35), "duplicate", "box duplicate" ], [ P(65, 53), "halo on container", "box halo on container" ] ]
		this.addBubbleButton(bubble, spec[1], spec[2], spec[0])

	this.bubbleLabel("box", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/6/2013 23:04'!
boxWithNestedShape = (shape, outerExtent, offset) ->
	// quick and dirty way to fiddle with the offset of a shape within a box
	var shapeBox = KSBox.withShape(shape)
	shapeBox.topLeft(offset)
	var outer = KSBox._extent_fill(outerExtent, Color.transparent())
	outer.add(shapeBox)
	return outer! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/4/2013 15:22'!
bubbleLabel = (label, bubble) ->
	var font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(10.5).fill(this.theme.iconColor)
	var box = this.newLabel(label, Color.transparent(), font)
	bubble.add(box)
	box.layout().font = font
	box.bottomCenter(P((bubble.extent()/2.0).x(), bubble.height() - 2))! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/4/2013 18:45'!
cellsBubble = (bubble) ->
	this.beBubble(bubble, 228)
	var box

	var font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(9.54).fill(this.theme.iconColor)
	box = this.newLabel("name: ", nil, font)
	box.topLeft(P(4, 6))
	bubble.add(box)

	box = this.newLineEditor(50, Color.white(), KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(13))
	box.clipping(true)
	box.layout().inset(2)
	box.borderFill(this.theme.edgeColor)
	box.topLeft(P(44, 4))
	bubble.add(box)
	box.eval('this.cellNameWatcher = $$(@__docEditor__.selectedDocBox.mapE((b) ->
		this.textContents(if b && b.tableHandler then b.name() else "")))')

	box = this.newLineEditor(220, Color.white(), KSFamily.withName("DejaVuSans").withStyle(1).withSize(10))
	box.clipping(true)
	box.layout().inset(2)
	box.borderFill(this.theme.edgeColor)
	box.topLeft(P(4, 24))
	bubble.add(box)
	box.eval('this.cellFormulaWatcher = $$(@__docEditor__.selectedDocBox.mapE((b) ->
		this.textContents(if b && b.tableHandler then b.tableHandler[b.name()].asString() else "")))')

	for spec in [ [ P(4, 45), "border", "cell border" ], [ P(64, 45), "new cell", "new cell" ], [ P(124, 45), "font size", "cell font size" ] ]
		this.addBubbleButton(bubble, spec[1], spec[2], spec[0])

	this.bubbleLabel("cells", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/22/2013 14:58'!
contentTextyBubbleSpecs = () ->
	// all relevant bubbles are
	// edit, letters, paragraph, turn, cells, wander, box, color, border, shadow, overlap, geometry, visible, turn, insert, new, blank page
	return [
		[ "wander", 65, [
			[ 0, [ "random", "wander random" ], [ "back", "wander back" ], [ "stop", "wander stop" ] ] ] ],

		[ "color", 92, [
			[ 0, [ "solid fill", "solid fill" ], [ "gradient fill", "gradient fill" ], [ "radial fill", "radial fill" ], [ "image fill", "image fill" ] ] ] ],

		[ "border", 210, [
			[ 0, [ "solid border", "solid border" ], [ "gradient border", "gradient border" ], [ "radial border", "radial border" ], [ "toggle rounded corners", "toggle rounded corners" ] ],
			[ 105, [ "border width", "border width" ], [ "border thicker", "border thicker" ], [ "border thinner", "border thinner" ] ] ] ],

		[ "shadow", 212, [
			[ 0, [ "solid shadow", "solid shadow" ], [ "gradient shadow", "gradient shadow" ], [ "radial shadow", "radial shadow" ], [ "image shadow", "image shadow" ] ],
			[ 110, [ "shadow offset", "shadow offset" ], [ "hard shadow", "hard shadow" ], [ "soft shadow", "soft shadow" ] ] ] ],

		[ "geometry", 80, [
			[ 0, [ "x>", "geometry x" ], [ "heading>", "geometry heading" ], [ "width>", "geometry width" ] ],
			[ 28, [ "y>", "geometry y" ] ] ] ],

		[ "visibility", 70, [
			[ 0, [ "hide", "visibility hide" ], [ "show", "visibility show" ] ] ] ],

		[ "insert", 220, [
			[ 0, [ "text area", "insert text area" ], [ "table", "insert table" ], [ "oval", "insert oval" ] ],
			[ 65, [ "box", "insert box" ], [ "cell", "insert cell" ], [ "page", "insert page" ] ],
			[ 45, [ "button", "insert button" ], [ "list", "insert list" ], [ "horizontal rule", "insert horizontal rule" ] ] ] ],

		[ "new", 270, [
			[ 0, [ "from clipboard", "new from clipboard" ], [ "angular shape", "new angular shape" ], [ "small page (stack)", "new small page" ] ],
			[ 100, [ "photo", "new from photo" ], [ "smooth shape", "new smooth shape" ] ],
			[ 96, [ "paint area", "new paint area" ], [ "scribble", "new scribble" ] ] ] ] ]! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/7/2013 13:57'!
defaultFontBubble = (bubble) ->
	this.beBubble(bubble, 155)

	var box = this.newLabel(" ", Color.white(), KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(13))
	box.clipping(true)
	box.layout().inset(2)
	box.layout().minimumWidth = box.layout().maximumWidth = 124
	box.layOut()
	// box.borderFill(this.theme.edgeColor)
	// box.borderWidth(1)
	box.topLeft(P(8, 12))
	bubble.add(box)
	box.eval('this.fontFaceWatcher = $$(@__docEditor__.defaultFont.mapE((font) ->
		this.textContents(font.family().name().asString())))')

	box = KSBox.new()
	box.shape(KSShape.new().elements([GeziraPath.polygon([P(0, 0), P(10, 0), P(5, 9)]).fill(this.theme.edgeColor)]))
	box.attachButtonHandler()
	box.actionID = "choose default font"
	box.wantsTooltip = true
	box.topLeft(P(136, 16))
	bubble.add(box)

	box = this.newLabel(" ", Color.white(), KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(13))
	box.clipping(true)
	box.layout().inset(2)
	box.layout().minimumWidth = box.layout().maximumWidth = 26
	box.layOut()
	box.topLeft(P(106, 42))
	// box.borderFill(this.theme.edgeColor)
	// box.borderWidth(1)
	bubble.add(box)
	box.eval('this.fontSizeWatcher = $$(@__docEditor__.defaultFont.mapE((font) ->
		this.textContents(font.pointSize().asString())))')

	box = KSBox.new()
	box.shape(KSShape.new().elements([GeziraPath.polygon([P(0, 0), P(10, 0), P(5, 9)]).fill(this.theme.edgeColor)]))
	box.attachButtonHandler()
	box.actionID = "choose default font size"
	box.wantsTooltip = true
	box.topLeft(P(136, 46))
	bubble.add(box)

	box = KSBox.withShape(this.fontEnlargeIcon())
	box.attachButtonHandler()
	box.actionID = "enlarge default font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["topLeft", "bottomLeft"], ["top", "left", "bottom"])
	bubble.add(box)
	box.topLeft(P(10, 42))

	box = KSBox.withShape(this.fontShrinkIcon())
	box.attachButtonHandler()
	box.actionID = "shrink default font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(P(30, 42))

	box = KSBox.withShape(this.fontColorIcon())
	box.attachButtonHandler()
	box.actionID = "choose default font color"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["topRight", "bottomRight"], ["top", "right", "bottom"])
	bubble.add(box)
	box.topLeft(P(50, 42))

	this.bubbleLabel("default font", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/18/2013 23:52'!
documentTextyBubbleSpecs = () ->
	// all relevant bubbles are
	// pages, threads, blank page, default font, frame, find, send, reply 
	return [
		[ "blank page", 125, [
			[ 0, [ "blank background", "blank background" ], [ "page like...", "page like" ], [ "new document", "new document" ] ] ] ],

		[ "frame", 215, [
			[ 0, [ "portrait/landscape", "toggle portrait landscape" ], [ "margin narrower", "margin narrower" ], [ "margin wider", "margin wider" ] ],
			[ 114, [ "fullscreen", "full screen" ], [ "screen DPI", "screen dpi" ], [ "page size", "page size" ], [ "extra window", "extra window" ] ] ] ],

		[ "reply", 80, [
			[ 0, [ "reply>", "doc reply" ], [ "forward>", "doc forward" ] ] ] ] ]! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/20/2013 17:11'!
editBubble = (bubble) ->
	this.beBubble(bubble, 160)
	var box

	box = this.graphicNamed("clipboard")
	box.topLeft(P(4, 18))
	bubble.add(box)

	box = this.newToolButton(" paste ")
	box.actionID = "edit paste"
	box.topLeft(P(30, 26))
	bubble.add(box)

	var y = 6
	for pair in [ [ "cut", "cut" ], [ "copy", "copy" ], [ "selectAll", "select all" ] ]
		box = this.graphicNamed(pair[0])
		box.topLeft(P(77, y))
		bubble.add(box)
		box = this.newToolButton(" ".concat(pair[1]).concat(" "))
		box.topLeft(P(96, y))
		box.actionID = "edit ".concat(pair[1])
		bubble.add(box)
		y += 20

	this.bubbleLabel("edit", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/4/2013 18:46'!
findBubble = (bubble) ->
	this.beBubble(bubble, 320)
	var box

	bubble.add(this.newToolButton("find"))
	bubble.last().topLeft(P(8, 5))

	box = this.newLineEditor(270, Color.white(), KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(13))
	box.clipping(true)
	box.layout().inset(2)
	box.borderFill(this.theme.edgeColor)
	box.topLeft(P(35, 4))
	box.textContents("abc")
	bubble.add(box)
	box.eval('this.pushFindString = $$(@layoutChanged.doE(() ->
		if @__docEditor__
			this.__docEditor__.findString.set(this.textContents())))')

	bubble.add(this.newToolButton("in:"))
	bubble.last().topLeft(P(10, 26))

	bubble.add(this.newToolButton("everything"))
	bubble.last().actionID = "find in everything"
	bubble.last().topLeft(P(33, 26))

	bubble.add(this.newToolButton("mail"))
	bubble.last().actionID = "find in mail"
	bubble.last().topLeft(P(101, 26))

	bubble.add(this.newToolButton("my docs"))
	bubble.last().actionID = "find in docs"
	bubble.last().topLeft(P(137, 26))

	bubble.add(this.newToolButton("internet"))
	bubble.last().actionID = "find in internet"
	bubble.last().topLeft(P(194, 26))

	bubble.add(this.newToolButton("again"))
	bubble.last().actionID = "find again"
	bubble.last().topLeft(P(270, 26))

	bubble.add(this.newToolButton("load"))
	bubble.last().actionID = "load doc"
	bubble.last().topLeft(P(41, 52))

	bubble.add(this.newToolButton("load page"))
	bubble.last().actionID = "load page"
	bubble.last().topLeft(P(89, 52))

	bubble.add(this.newToolButton("ODF"))
	bubble.last().actionID = "load odf"
	bubble.last().topLeft(P(167, 52))

	bubble.add(this.newToolButton("append ODF"))
	bubble.last().actionID = "append odf"
	bubble.last().topLeft(P(211, 52))

	this.bubbleLabel("find", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/27/2013 18:36'!
generateAllBubbles = () ->
	for bname in [ 'box', 'cells', 'default Font', 'edit', 'find', 'gezira', 'letters', 'overlap', 'pages', 'paragraph', 'send', 'threads', 'turn' ]
		this.generateBubbleFromMethod(bname)
	for cat in [ 'document', 'content', 'script' ]
		this.generateBubblesForCategory(cat)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/18/2013 16:56'!
generateBubbleFromMethod = (name) ->
	// name can be more than one word - e.g. default Font
	var ksm = KSMorph.new()
	ksm.openInWorld()
	var bubble = KSBox.new()
	ksm.window().add(bubble)
	this.ksPerform(((name.copyWithout(Character.space())).concat("Bubble:")).asSymbol(), [ bubble ])
	bubble.saveToDirectory(name.asLowercase().concat("Bubble.ks"))! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/18/2013 23:57'!
generateBubblesForCategory = (category) ->
	// categories are   document, content, script
	var specs = this.ksPerform((category.concat("TextyBubbleSpecs")).asSymbol(), [])

	var ksm = KSMorph.new()
	ksm.openInWorld()
	var window = ksm.window()
	var bubble

	for spec in specs
		window.removeAll()
		bubble = KSBox.new()
		window.add(bubble)
		this.beBubble(bubble, spec[1])		// set the width
		this.addBubbleButtons(bubble, spec[2])
		this.bubbleLabel(spec[0], bubble)
		bubble.saveToDirectory(spec[0].concat("Bubble.ks"))! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/27/2013 18:48'!
geziraBubble = (bubble) ->
	this.beBubble(bubble, 160)

	var box = this.newToolButton(" new gezira scripting area ")
	box.actionID = "new gezira scripting area"
	box.topLeft(P(8, 4))
	bubble.add(box)

	var buttonsInLine = 0
	var initX = 8
	var x = initX
	var y = 20
	for char in GZKernel.specialCharacters().asSortedCollection()
		box = this.newToolButton(" ".concat(char.asString()).concat(" "))
		box.attachButtonHandler()
		box.actionID = "gezira operator"
		box.wantsTooltip = true
		box.tooltipString = "gezira operator: ".concat(char.asString())
		box.operator = char
		box.topLeft(P(x, y))
		bubble.add(box)
		if buttonsInLine == 6			// this is the seventh
			buttonsInLine = 0
			x = initX
			y += 16
		else
			buttonsInLine += 1
			x += 20

	this.bubbleLabel("gezira", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'yo 1/22/2013 11:52'!
insertBubble = (bubble) ->
	this.beBubble(bubble, 260)

	var font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(10.5).fill(this.theme.iconColor)
	bubble.add(this.newToolButton("text area"))
	bubble.atName("text area").topLeft(P(5, 4))

	bubble.add(this.newToolButton("box"))
	bubble.atName("box").topLeft(P(83.6160888671875, 4.0))

	bubble.add(this.newToolButton("button"))
	bubble.atName("button").topLeft(P( 132.65260314941406, 4.0))

	bubble.add(this.newToolButton("table"))
	bubble.atName("table").topLeft(P(5.0, 24.10515594482422))

	bubble.add(this.newToolButton("cell"))
	bubble.atName("cell").topLeft(P(62.06724548339844, 24.10515594482422))

	bubble.add(this.newToolButton("list"))
	bubble.atName("list").topLeft(P( 110.232666015625, 24.10515594482422))

	bubble.add(this.newToolButton("oval"))
	bubble.atName("oval").topLeft(P(5.0, 44.21031188964844))

	bubble.add(this.newToolButton("page"))
	bubble.atName("page").topLeft(P(56.98048782348633, 44.21031188964844))

	bubble.add(this.newToolButton("horizontal rule"))
	bubble.atName("horizontal rule").topLeft(P(113.04621887207031, 44.21031188964844))

	this.bubbleLabel("insert", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/11/2013 17:18'!
lettersBubble = (bubble) ->
	this.beBubble(bubble, 264)

	var prevBox
	var box = this.newLabel(" ", Color.white(), KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(13))
	box.clipping(true)
	box.layout().inset(2)
	box.layout().minimumWidth = box.layout().maximumWidth = 124
	box.layOut()
	box.topLeft(P(5, 12))
	// box.borderFill(this.theme.edgeColor)
	// box.borderWidth(1)
	bubble.add(box)
	box.eval('this.fontFaceWatcher = $$(@container.selectionFont.mapE((font) -> this.textContents(font.family().name().asString())))')

	bubble.add(KSBox.new())
	var box = bubble.contents().last()
	box.shape(KSShape.new().elements([GeziraPath.polygon([P(0, 0), P(10, 0), P(5, 9)]).fill(this.theme.edgeColor)]))
	box.attachButtonHandler()
	box.actionID = "choose font"
	box.wantsTooltip = true
	box.topLeft(P(131, 16))

	box = this.newLabel(" ", Color.white(), KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(13))
	box.clipping(true)
	box.layout().inset(2)
	box.layout().minimumWidth = box.layout().maximumWidth = 26
	box.layOut()
	box.topLeft(P(144, 12))
	// box.borderFill(this.theme.edgeColor)
	// box.borderWidth(1)
	bubble.add(box)
	box.eval('this.fontSizeWatcher = $$(this.textContents(@container.selectionFont.pointSize().asString()))')

	bubble.add(KSBox.new())
	var box = bubble.contents().last()
	box.shape(KSShape.new().elements([GeziraPath.polygon([P(0, 0), P(10, 0), P(5, 9)]).fill(this.theme.edgeColor)]))
	box.attachButtonHandler()
	box.actionID = "choose font size"
	box.wantsTooltip = true
	box.topLeft(P(172, 16))

	var box = KSBox.withShape(this.fontEnlargeIcon())
	box.attachButtonHandler()
	box.actionID = "enlarge font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["topLeft", "bottomLeft"], ["top", "left", "bottom"])
	bubble.add(box)
	box.topLeft(P(188.0, 12))

	var box = KSBox.withShape(this.fontShrinkIcon())
	box.attachButtonHandler()
	box.actionID = "shrink font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["topRight", "bottomRight"], ["top", "right", "bottom"])
	bubble.add(box)
	box.topLeft(P(208.0, 12))

	var box = KSBox.withShape(this.textBoxedIcon())
	box.attachButtonHandler()
	box.actionID = "box text"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["all"], ["all"])
	bubble.add(box)
	box.topLeft(P(234, 12))

	var box = KSBox.withShape(this.fontBoldIcon())
	box.attachButtonHandler()
	box.actionID = "bold font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["topLeft", "bottomLeft"], ["top", "bottom", "left"])
	bubble.add(box)
	box.topLeft(P(5.0, 42))
	prevBox = box

	var box = KSBox.withShape(this.fontItalicIcon())
	box.attachButtonHandler()
	box.actionID = "italic font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.fontUnderlineIcon())
	box.attachButtonHandler()
	box.actionID = "underline font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.fontStruckOutIcon())
	box.attachButtonHandler()
	box.actionID = "strikeout font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.fontSubscriptIcon())
	box.attachButtonHandler()
	box.actionID = "subscript font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.fontSuperscriptIcon())
	box.attachButtonHandler()
	box.actionID = "superscript font"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.textCapsIcon())
	box.attachButtonHandler()
	box.actionID = "capitalize text"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["topRight", "bottomRight"], ["top", "right", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.fontbackgroundIcon())
	box.attachButtonHandler()
	box.actionID = "choose font background"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["topLeft", "bottomLeft"], ["top", "left", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight() + P(12, 0))
	prevBox = box

	var box = KSBox.withShape(this.fontColorIcon())
	box.attachButtonHandler()
	box.actionID = "choose font color"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(20, 20), ["topRight", "bottomRight"], ["top", "right", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	bubble.eval('this.selectionFont = $$(@__docEditor__.textSelection.mapE((boxes) ->
		if boxes
			var lay = @__docEditor__.focusLayout
			var first = if lay.respondsTo(#"firstInSelection") then lay.firstInSelection() else nil
			if first then first.font.currentValue() else lay.font.currentValue()
		else
			@__docEditor__.defaultFont))')

	this.bubbleLabel("letters", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/19/2013 21:52'!
menulikeDownArrow = () ->
	var down = KSBox.withShape(KSShape.new().elements([GeziraPath.polygon([P(0, 0), P(10, 0), P(5, 9)]).fill(Color.brown())]))
	down.pivotRatio(P(0.5, 0.8))
	return down! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/14/2013 11:58'!
overlapBubble = (bubble) ->
	this.beBubble(bubble, 210)
	var box

	box = this.newToolButton("  on background  ", KSFamily.withName("DejaVuSans").withStyle(1).withSize(9.54).fill(Color.red()))
	box.add(this.menulikeDownArrow())
	box.actionID = "toggle page/background"
	box.eval('this.layerWatcher = $$(mergeE(@__docEditor__.selectedDocBox, @__docEditor__.editorCommandFinished).doE(() ->
		var b = @__docEditor__.selectedDocBox
		if b && b.container() && b.container().container().handler instanceof KSStack
			this.textContents(if b.pageSpecific then "  on page  " else "  on background  ")
			this.add(KSFactory.default().menulikeDownArrow())
		else
			this.textContents("  --")))')
	box.width(60)
	box.topLeft(P(94, 36))
	bubble.add(box)

	for spec in [ [ P(4, 2), "be in front", "overlap be in front" ], [ P(4, 19), "come forward", "overlap come forward" ], [ P(4, 36), "be in back", "overlap be in back" ], [ P(4, 53), "go back", "overlap go back" ], [ P(94, 2), "align>", "overlap align" ], [ P(94, 19), "wrapping>", "overlap wrapping" ] ]
		this.addBubbleButton(bubble, spec[1], spec[2], spec[0])

	this.bubbleLabel("overlap", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/7/2013 13:35'!
pagesBubble = (bubble) ->
	this.beBubble(bubble, 167)

	var box = this.boxWithNestedShape(this.firstIcon(), P(25, 20), P(6, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(25, 20), ["all"], ["all"])
	box.actionID = "back in doc history"
	box.wantsTooltip = true
	box.topLeft(P(8, 6))
	bubble.add(box)

	box = this.boxWithNestedShape(this.prevIcon(), P(23, 20), P(6, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	box.actionID = "previous page"
	box.wantsTooltip = true
	box.topLeft(P(39, 6))
	bubble.add(box)

	box = this.newToolButton(" back ")
	box.actionID = "show go back"
	box.topLeft(P(66, 9))
	bubble.add(box)

	box = this.boxWithNestedShape(this.nextIcon(), P(23, 20), P(7, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	box.actionID = "next page"
	box.wantsTooltip = true
	box.topLeft(P(102, 6))
	bubble.add(box)

	box = this.boxWithNestedShape(this.lastIcon(), P(25, 20), P(7, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(25, 20), ["all"], ["all"])
	box.actionID = "forward in doc history"
	box.wantsTooltip = true
	box.topLeft(P(131, 6))
	bubble.add(box)

	box = this.newToolButton(" new page ")
	box.actionID = "new page"
	box.topLeft(P(5, 30))
	bubble.add(box)

	box = this.newToolButton(" copy page ")
	box.actionID = "copy page"
	box.topLeft(P(98, 30))
	bubble.add(box)

	box = this.newToolButton(" delete page ")
	box.actionID = "delete page"
	box.topLeft(P(5, 47))
	bubble.add(box)

	box = this.newToolButton(" paste page ")
	box.actionID = "paste page"
	box.topLeft(P(98, 47))
	bubble.add(box)

	this.bubbleLabel("pages", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/7/2013 13:48'!
paragraphBubble = (bubble) ->

	this.beBubble(bubble, 180)

	var box = this.boxWithNestedShape(this.linkIcon(), P(30, 20), P(6, 1))
	box.attachButtonHandler()
	box.actionID = "paragraph link"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(30, 20), ["topLeft", "bottomLeft"], ["left", "top", "bottom"])
	bubble.add(box)
	box.topLeft(P(8, 12))
	var prevBox = box

	var box = this.boxWithNestedShape(this.unlinkIcon(), P(30, 20), P(6, 1))
	box.attachButtonHandler()
	box.actionID = "paragraph unlink"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(30, 20), ["topRight", "bottomRight"], ["right", "top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.textLeftJustificationIcon())
	box.attachButtonHandler()
	box.actionID = "paragraph justify"
	box.actionArg = "left"
	box.wantsTooltip = true
	box.tooltipString = "paragraph justify left"
	this.addButtonFillAndBorderTo(box, P(25, 20), ["topLeft", "bottomLeft"], ["left", "top", "bottom"])
	bubble.add(box)
	box.topLeft(P(8, 42))
	prevBox = box

	var box = KSBox.withShape(this.textCenterJustificationIcon())
	box.attachButtonHandler()
	box.actionID = "paragraph justify"
	box.actionArg = "center"
	box.wantsTooltip = true
	box.tooltipString = "paragraph justify center"
	this.addButtonFillAndBorderTo(box, P(25, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.textRightJustificationIcon())
	box.attachButtonHandler()
	box.actionID = "paragraph justify"
	box.actionArg = "right"
	box.wantsTooltip = true
	box.tooltipString = "paragraph justify right"
	this.addButtonFillAndBorderTo(box, P(25, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.textJustifyIcon())
	box.attachButtonHandler()
	box.actionID = "paragraph justify"
	box.actionArg = "full"
	box.wantsTooltip = true
	box.tooltipString = "paragraph justify full"
	this.addButtonFillAndBorderTo(box, P(25, 20), [], ["top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())
	prevBox = box

	var box = KSBox.withShape(this.textDistributedJustifyIcon())
	box.attachButtonHandler()
	box.actionID = "paragraph justify"
	box.actionArg = "distributed"
	box.wantsTooltip = true
	box.tooltipString = "paragraph justify distributed"
	this.addButtonFillAndBorderTo(box, P(25, 20), ["topRight", "bottomRight"], ["right", "top", "bottom"])
	bubble.add(box)
	box.topLeft(prevBox.topRight())

	var box = KSBox.withShape(this.linkIcon())
	box = this.boxWithNestedShape(this.textExtraSpaceIcon(), P(23, 20), P(3, 4))
	box.attachButtonHandler()
	box.actionID = "paragraph extra space"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	bubble.add(box)
	box.topLeft(P( 149.0,12))

	var box = KSBox.withShape(this.textLineSpacedIcon())
	box.attachButtonHandler()
	box.actionID = "paragraph line space"
	box.wantsTooltip = true
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	bubble.add(box)
	box.topLeft(P(149, 42))

	this.bubbleLabel("paragraph", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 2/18/2013 22:58'!
scriptTextyBubbleSpecs = () ->
	// all relevant bubbles are
	// control, scripts, gezira, gezira tiles, gezira compositions 
	return [
		[ "control", 70, [
			[ 0, [ "stop all", "control stop all" ], [ "resume", "control resume" ] ] ] ],

		[ "scripts", 70, [
			[ 0, [ "script1", "script1" ], [ "script2", "script2" ], [ "script3", "script3" ] ] ] ],

		[ "gezira tiles", 1020, [
			[ 0, [ "apply texture", "gz apply texture" ], [ "gaussian blur11x1", "gz gaussian blur11x1" ], [ "gradient extend pad", "gz gradient extend pad" ], [ "radial gradient shape", "gz radial gradient shape" ], [ "write image", "gz write image" ] ],
			[ 130, [ "bicubic filter", "gz bicubic filter" ], [ "gaussian blur1x11", "gz gaussian blur1x11" ], [ "gradient extend reflect", "gz gradient extend reflect" ], [ "rasterize", "gz rasterize" ] ], 
			[ 140, [ "bilinear filter", "gz bilinear filter" ], [ "gaussian blur1x21", "gz gaussian blur1x21" ], [ "gradient extend repeat", "gz gradient extend repeat" ], [ "read image", "gz read image" ] ], 
			[ 140, [ "calculate bounds", "gz calculate bounds" ], [ "gaussian blur1x5", "gz gaussian blur1x5" ], [ "image extend pad", "gz image extend pad" ], [ "rectangle spans", "gz rectangle spans" ] ], 
			[ 110, [ "clip beziers", "gz clip beziers" ], [ "gaussian blur21x1", "gz gaussian blur21x1" ], [ "image extend reflect", "gz image extend reflect" ], [ "stroke bezier path", "gz stroke bezier path" ] ], 
			[ 120, [ "composite textures", "gz composite textures" ], [ "gaussian blur5x1", "gz gaussian blur5x1" ], [ "image extend repeat", "gz image extend repeat" ], [ "transform beziers", "gz transform beziers" ] ], 
			[ 130, [ "contrastive over", "gz contrastive over" ], [ "gradient", "gz gradient" ], [ "inverse over", "gz inverse over" ], [ "transform points", "gz transform points" ] ], 
			[ 110, [ "funnel", "gz funnel" ], [ "gradient color span", "gz gradient color span" ], [ "linear gradient shape", "gz linear gradient shape" ], [ "uniform color", "gz uniform color" ] ] ] ],

		[ "gezira compositions", 475, [
			[ 0, [ "clear", "gz clear" ],  [ "dst in", "gz dst in" ], [ "multiply", "gz multiply" ], [ "src atop", "gz src atop" ] ], 
			[ 60, [ "color burn", "gz color burn" ], [ "dst out", "gz dst out" ], [ "over", "gz over" ], [ "src in", "gz src in" ] ], 
			[ 70, [ "color dodge", "gz color dodge" ], [ "dst over", "gz dst over" ], [ "overlay", "gz overlay" ], [ "src out", "gz src out" ] ], 
			[ 80, [ "darken", "gz darken" ], [ "exclusion", "gz exclusion" ], [ "plus", "gz plus" ], [ "subtract", "gz subtract" ] ], 
			[ 60, [ "difference", "gz difference" ], [ "hard light", "gz hard light" ], [ "screen", "gz screen" ], [ "xor", "gz xor" ] ],
			[ 70, [ "dst", "gz dst" ], [ "invert", "gz invert" ], [ "soft light", "gz soft light" ] ], 
			[ 60, [ "dst atop", "gz dst atop" ], [ "lighten", "gz lighten" ], [ "src", "gz src" ] ] ] ] ] ! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/4/2013 18:46'!
sendBubble = (bubble) ->
	this.beBubble(bubble, 205)
	var box

	bubble.add(this.newToolButton("to internet"))
	box = bubble.last()
	box.actionID = "send to internet"
	box.topLeft(P(11.0, 7.0))

	bubble.add(this.newToolButton("to file"))
	box = bubble.last()
	box.actionID = "send to file"
	box.topLeft(P(142, 7.0))

	bubble.add(this.newToolButton("to  "))
	box = bubble.last()
	box.add(this.menulikeDownArrow())
	box.actionID = "send to address"
	box.topLeft(P(11, 28))

	var font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(10.5).fill(this.theme.iconColor)
	box = this.newLineEditor(147, Color.white(), KSFamily.withName("PalatinoLinotype").withStyle(0).withSize(13))
	box.clipping(true)
	box.layout().inset(2)
	box.textContents("f@rank.org")
	box.borderFill(this.theme.edgeColor)
	box.topLeft(P(44, 27))
	bubble.add(box)
	box.eval('this.pushSendTarget = $$(@layoutChanged.doE(() ->
		if @__docEditor__
			this.__docEditor__.sendTarget.set(this.textContents())))')

	bubble.add(this.newToolButton("save page"))
	bubble.last().actionID = "save page"	
	bubble.last().topLeft(P(11, 52))

	bubble.add(this.newToolButton("mark"))
	bubble.last().actionID = "insert mark for printing"	
	bubble.last().topLeft(P(87, 52))

	bubble.add(this.newToolButton("make PDF"))
	bubble.last().actionID = "make pdf"	
	bubble.last().topLeft(P(132, 52))

	this.bubbleLabel("send", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/7/2013 14:02'!
threadsBubble = (bubble) ->
	this.beBubble(bubble, 167)

	var box = this.boxWithNestedShape(this.firstIcon(), P(25, 20), P(6, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(25, 20), ["all"], ["all"])
	box.actionID = "thread first"
	box.wantsTooltip = true
	box.topLeft(P(8, 6))
	bubble.add(box)

	box = this.boxWithNestedShape(this.prevIcon(), P(23, 20), P(6, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	box.actionID = "thread previous"
	box.wantsTooltip = true
	box.topLeft(P(39, 6))
	bubble.add(box)

	box = this.newToolButton(" back ")
	box.actionID = "thread back"
	box.wantsTooltip = true
	box.topLeft(P(66, 9))
	bubble.add(box)

	box = this.boxWithNestedShape(this.nextIcon(), P(23, 20), P(7, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	box.actionID = "thread next"
	box.wantsTooltip = true
	box.topLeft(P(102, 6))
	bubble.add(box)

	box = this.boxWithNestedShape(this.lastIcon(), P(25, 20), P(7, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(25, 20), ["all"], ["all"])
	box.actionID = "thread last"
	box.wantsTooltip = true
	box.topLeft(P(133, 6))
	bubble.add(box)

	box = this.newToolButton(" choose thread ")
	box.add(this.menulikeDownArrow())
	box.actionID = "thread choose"
	box.topLeft(P(34, 30))
	bubble.add(box)

	box = this.newToolButton(" new ")
	box.actionID = "thread new"
	box.wantsTooltip = true
	box.topLeft(P(34, 47))
	bubble.add(box)

	box = this.newToolButton(" edit ")
	box.actionID = "thread edit"
	box.wantsTooltip = true
	box.topLeft(P(98, 47))
	bubble.add(box)

	this.bubbleLabel("threads", bubble)! !

!KSFactory methodsFor: 'bubble-data' stamp: 'ael 3/7/2013 13:39'!
turnBubble = (bubble) ->
	this.beBubble(bubble, 33)

	var box = this.boxWithNestedShape(this.firstIcon(), P(23, 20), P(4, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	box.actionID = "turn first"
	box.wantsTooltip = true
	box.topLeft(P(5, 4))
	bubble.add(box)

	box = this.boxWithNestedShape(this.prevIcon(), P(23, 20), P(6, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	box.actionID = "turn prev"
	box.wantsTooltip = true
	box.topLeft(P(5, 26))
	bubble.add(box)

	box = this.boxWithNestedShape(this.nextIcon(), P(23, 20), P(7, 3))
	box.attachButtonHandler()
	this.addButtonFillAndBorderTo(box, P(23, 20), ["all"], ["all"])
	box.actionID = "turn next"
	box.wantsTooltip = true
	box.topLeft(P(5, 48))
	bubble.add(box)

	this.bubbleLabel("turn", bubble)! !

!KSFactory methodsFor: 'defaults' stamp: 'yo 1/17/2013 20:47'!
defaultFont = () ->
	return KSFont.defaultFont()! !

!KSFactory methodsFor: 'defaults' stamp: 'yo 1/17/2013 20:39'!
defaultMenuFont
	^ ((KSFamily withName: #DejaVuSans) withStyle: 0) withSize: 16! !

!KSFactory methodsFor: 'defaults' stamp: 'ael 3/15/2013 14:39'!
themeNamed = (tname) ->
	//LBox themeNamed: #orange.
	var theme = this.theme = {}
	if tname == "blue"
		theme.themeColor = Color._r_g_b(0.59, 0.766, 0.957) // main inside
		//"bottom of bubble"
		theme.edgeColor = Color._r_g_b(0.0, 0.595, 0.753) // "darker border"
		theme.iconColor = Color._r_g_b(0.972, 0.847, 0.595) // complementary"
		theme.lightColor = Color.white()  "white for main gradient"

	if tname == "green"
		theme.themeColor = Color._r_g_b(0.527, 0.85, 0.527) // main inside
		//"bottom of bubble"
		theme.edgeColor = Color._r_g_b(0.0, 0.784, 0.0) // "darker border"
		theme.iconColor = Color._r_g_b(1.0, 0.729, 0.18) // complementary"
		theme.lightColor = Color.white()  "white for main gradient"

	if tname == "orange"
		theme.themeColor = Color._r_g_b(0.972, 0.847, 0.595) // main inside
		//"bottom of bubble"
		theme.edgeColor = Color._r_g_b(0.847, 0.313, 0.0) // "darker border"
		theme.iconColor = Color._r_g_b(0.533, 0.784, 0.972) // complementary"
		theme.lightColor = Color.white()  "white for main gradient"
		theme.listBaseColor = Color.orange()

	if tname == "steel"
		theme.themeColor = Color._r_g_b(0.665, 0.687, 0.659) // main inside
		//"bottom of bubble"
		theme.edgeColor = Color._r_g_b(0.086, 0.109, 0.094) // "darker border"
		theme.iconColor = (theme.themeColor).negated() // complementary"
		theme.lightColor = Color.white()  "white for main gradient"

	theme.borderColor = theme.themeColor._alphaMixed_with(0.5, Color.gray())
	theme.contrastColor = theme.themeColor._alphaMixed_with(0.15, Color.white())
	theme.itemTextColor = theme.edgeColor._alphaMixed_with(0.65, Color.black())
	theme.iconColor = theme.itemTextColor
	
	return this! !

!KSFactory methodsFor: 'doc editor' stamp: 'ael 1/30/2013 20:49'!
newTabShape = (extent, edgeColor, fillColor) ->
	// make a transparent box with a border that looks like a tab
	var inst = KSBox._extent_fill(P(100,10), Color.transparent())
	var tabShape = KSShape.new().elements([ GeziraPath.path(
		[0, 20.5, 0, 20.5, 0, 20,
		0, 20,	5, 20,	5, 15,
		5, 15,	5, 15,	5, 5,
		5, 5,	5, 0,	10, 0,
		10, 0,	10, 0,	90, 0,
		90, 0,	95, 0,	95, 5,
		95, 5,	95, 5,	95, 15,
		95, 15,	95, 20,	100, 20,
		100, 20, 100, 20, 100, 20.5 ]).stroke( GeziraStroke.width(1) ).fill( edgeColor) ])
	inst.shape(tabShape)
	inst.fill(fillColor)
	inst.attachShapeStretcher(P(50, 10))
	inst.extent(extent)
	return inst! !

!KSFactory methodsFor: 'doc editor' stamp: 'ael 2/12/2013 18:52'!
showHideButton = () ->
	var button = this.showHideIconBox()
	button.attachButtonHandler()
	return button! !

!KSFactory methodsFor: 'doc editor' stamp: 'ael 2/12/2013 18:51'!
showHideIconBox = () ->
	var shape = this.scaleIcon()
	shape.allElementsDo((path) ->
		path.points(path.points() + P(1, 1))
		if path.stroke()
			path.fill(this.theme.edgeColor)
			path.stroke().width(1)
		else
			path.fill(this.theme.themeColor))

	shape.transform(MatrixTransform2x3.withRotation(90))
	var box = KSBox.withShape(shape)
	box.attachShapeScaler()
	box.extent(P(20, 20))
	return box! !

!KSFactory methodsFor: 'graphics-data' stamp: 'yo 9/3/2013 15:25'!
balloonSVG

	^ '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!!-- Created with Inkscape (http://www.inkscape.org/) -->
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://web.resource.org/cc/"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   id="svg1938"
   sodipodi:version="0.32"
   inkscape:version="0.44.1"
   width="254"
   height="297"
   version="1.0"
   sodipodi:docbase="/home/janfrog/work/smalltalk-logos/smalltalk"
   sodipodi:docname="balloon.svg">
  <metadata
     id="metadata1943">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/GPL/2.0/" />
        <dc:title>Smalltalk Balloon</dc:title>
        <dc:date>21.2.2007</dc:date>
        <dc:creator>
          <cc:Agent>
            <dc:title>Martin Dvořák</dc:title>
          </cc:Agent>
        </dc:creator>
        <dc:description>Classical Smalltalk Balloon</dc:description>
        <dc:contributor>
          <cc:Agent>
            <dc:title>Jan Vraný</dc:title>
          </cc:Agent>
        </dc:contributor>
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/GPL/2.0/">
        <cc:permits
           rdf:resource="http://web.resource.org/cc/Reproduction" />
        <cc:permits
           rdf:resource="http://web.resource.org/cc/Distribution" />
        <cc:requires
           rdf:resource="http://web.resource.org/cc/Notice" />
        <cc:permits
           rdf:resource="http://web.resource.org/cc/DerivativeWorks" />
        <cc:requires
           rdf:resource="http://web.resource.org/cc/ShareAlike" />
        <cc:requires
           rdf:resource="http://web.resource.org/cc/SourceCode" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <defs
     id="defs1941">
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4084">
      <stop
         style="stop-color:#efa57a;stop-opacity:1;"
         offset="0"
         id="stop4086" />
      <stop
         style="stop-color:#efa57a;stop-opacity:0;"
         offset="1"
         id="stop4088" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4076">
      <stop
         style="stop-color:#e7793a;stop-opacity:1;"
         offset="0"
         id="stop4078" />
      <stop
         style="stop-color:#e7793a;stop-opacity:0;"
         offset="1"
         id="stop4080" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4068">
      <stop
         style="stop-color:#e7793a;stop-opacity:1;"
         offset="0"
         id="stop4070" />
      <stop
         style="stop-color:#e7793a;stop-opacity:0;"
         offset="1"
         id="stop4072" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4060">
      <stop
         style="stop-color:#55ea56;stop-opacity:1;"
         offset="0"
         id="stop4062" />
      <stop
         style="stop-color:#55ea56;stop-opacity:0;"
         offset="1"
         id="stop4064" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4052">
      <stop
         style="stop-color:#ea9c55;stop-opacity:1;"
         offset="0"
         id="stop4054" />
      <stop
         style="stop-color:#ea9c55;stop-opacity:0;"
         offset="1"
         id="stop4056" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4044">
      <stop
         style="stop-color:#ea5561;stop-opacity:1;"
         offset="0"
         id="stop4046" />
      <stop
         style="stop-color:#ea5561;stop-opacity:0;"
         offset="1"
         id="stop4048" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4036">
      <stop
         style="stop-color:#6455ea;stop-opacity:1;"
         offset="0"
         id="stop4038" />
      <stop
         style="stop-color:#6455ea;stop-opacity:0;"
         offset="1"
         id="stop4040" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4028">
      <stop
         style="stop-color:#55ea8c;stop-opacity:1;"
         offset="0"
         id="stop4030" />
      <stop
         style="stop-color:#55ea8c;stop-opacity:0;"
         offset="1"
         id="stop4032" />
    </linearGradient>
    <linearGradient
       id="linearGradient4020">
      <stop
         style="stop-color:#ea55df;stop-opacity:1;"
         offset="0"
         id="stop4022" />
      <stop
         style="stop-color:#ea55df;stop-opacity:0;"
         offset="1"
         id="stop4024" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4012">
      <stop
         style="stop-color:#55e0ea;stop-opacity:1;"
         offset="0"
         id="stop4014" />
      <stop
         style="stop-color:#55e0ea;stop-opacity:0;"
         offset="1"
         id="stop4016" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient4004">
      <stop
         style="stop-color:#eaa455;stop-opacity:1;"
         offset="0"
         id="stop4006" />
      <stop
         style="stop-color:#eaa455;stop-opacity:0;"
         offset="1"
         id="stop4008" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient3996">
      <stop
         style="stop-color:#ea55e7;stop-opacity:1;"
         offset="0"
         id="stop3998" />
      <stop
         style="stop-color:#ea55e7;stop-opacity:0;"
         offset="1"
         id="stop4000" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient3988">
      <stop
         style="stop-color:#ea5566;stop-opacity:1;"
         offset="0"
         id="stop3990" />
      <stop
         style="stop-color:#ea5566;stop-opacity:0;"
         offset="1"
         id="stop3992" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient3980">
      <stop
         style="stop-color:#e6ea55;stop-opacity:1;"
         offset="0"
         id="stop3982" />
      <stop
         style="stop-color:#e6ea55;stop-opacity:0;"
         offset="1"
         id="stop3984" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       id="linearGradient3972">
      <stop
         style="stop-color:#5573ea;stop-opacity:1;"
         offset="0"
         id="stop3974" />
      <stop
         style="stop-color:#5573ea;stop-opacity:0;"
         offset="1"
         id="stop3976" />
    </linearGradient>
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient3972"
       id="linearGradient3978"
       x1="117.62566"
       y1="168.60001"
       x2="56.296555"
       y2="74.334793"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient3980"
       id="linearGradient3986"
       x1="168.0098"
       y1="155.5081"
       x2="119.56202"
       y2="84.486374"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient3988"
       id="linearGradient3994"
       x1="219.53423"
       y1="144.89989"
       x2="151.19965"
       y2="51.495544"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient3996"
       id="linearGradient4002"
       x1="236.0696"
       y1="121.38713"
       x2="152.2177"
       y2="37.452351"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4004"
       id="linearGradient4010"
       x1="205.38948"
       y1="47.290119"
       x2="136.08949"
       y2="33.08577"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4012"
       id="linearGradient4018"
       x1="182.26526"
       y1="18.827097"
       x2="126.55051"
       y2="35.574669"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4020"
       id="linearGradient4026"
       x1="152.12041"
       y1="17.474043"
       x2="132.3204"
       y2="36.84824"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4028"
       id="linearGradient4034"
       x1="94.339935"
       y1="15.905828"
       x2="133.49377"
       y2="27.527567"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4036"
       id="linearGradient4042"
       x1="52.450821"
       y1="20.214853"
       x2="143.88383"
       y2="30.545286"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4044"
       id="linearGradient4050"
       x1="14.813214"
       y1="72.065445"
       x2="107.47573"
       y2="20.843706"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4052"
       id="linearGradient4058"
       x1="28.386497"
       y1="132.14407"
       x2="-17.401899"
       y2="72.744072"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4060"
       id="linearGradient4066"
       x1="67.514305"
       y1="142.40312"
       x2="4.3037248"
       y2="87.7379"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4068"
       id="linearGradient4074"
       x1="94.96212"
       y1="266.65515"
       x2="84.808182"
       y2="249.10719"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4076"
       id="linearGradient4082"
       x1="96.672188"
       y1="285.42984"
       x2="82.349434"
       y2="256.16028"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       inkscape:collect="always"
       xlink:href="#linearGradient4084"
       id="linearGradient4090"
       x1="72.838031"
       y1="262.90592"
       x2="108.09431"
       y2="262.90592"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <sodipodi:namedview
     inkscape:window-height="723"
     inkscape:window-width="1024"
     inkscape:pageshadow="2"
     inkscape:pageopacity="0.0"
     guidetolerance="10.0"
     gridtolerance="10.0"
     objecttolerance="10.0"
     borderopacity="1.0"
     bordercolor="#666666"
     pagecolor="#ffffff"
     id="base"
     inkscape:showpageshadow="false"
     showborder="false"
     inkscape:zoom="2.3232323"
     inkscape:cx="127"
     inkscape:cy="149.41798"
     inkscape:window-x="0"
     inkscape:window-y="45"
     inkscape:current-layer="layer3" />
  <g
     inkscape:groupmode="layer"
     id="layer1"
     inkscape:label="image"
     style="opacity:1;display:none"
     sodipodi:insensitive="true">
    <image
       xlink:href="balloon.png"
       sodipodi:absref="/home/masca/balloon.png"
       width="254"
       height="297"
       id="image1945"
       x="0"
       y="0" />
  </g>
  <g
     inkscape:groupmode="layer"
     id="layer3"
     inkscape:label="colors"
     style="display:inline">
    <path
       style="fill:url(#linearGradient4042);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 48.576909,32.237323 C 64.522007,4.79693 121.81308,21.669065 133.12297,33.349771 C 126.44829,30.754059 86.214741,19.25876 48.576909,32.237323 z "
       id="path3935"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient4050);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 12.236933,86.747286 C 11.309889,12.398662 112.54267,23.337737 132.01052,34.091403 C 80.281683,32.793547 31.148553,48.738638 12.236933,86.747286 z "
       id="path3937"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient4058);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 134.11115,34.181473 C -29.66706,35.095335 -0.63667582,146.02414 43.342689,192.2284 C 9.2558288,116.1885 46.534157,55.944617 134.11115,34.181473 z "
       id="path3939"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient4066);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 133.8646,34.462219 C -6.3038665,69.689746 17.057542,196.50885 86.770959,239.1527 C 44.868747,165.3603 102.71605,57.823632 133.8646,34.462219 z "
       id="path3941"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient3978);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 134.23541,33.720587 C 52.655877,117.89584 67.859345,229.88229 92.333205,240.63596 C 130.52725,240.26514 150.18051,84.522389 134.23541,33.720587 z "
       id="path3943"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient3986);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 134.97705,34.091403 C 156.69951,101.0486 118.65454,235.65784 99.644517,240.66386 C 121.15689,245.29327 157.42185,226.96052 181.10644,183.42287 C 220.65182,110.72948 152.49685,50.481089 134.97705,34.091403 z "
       id="path3945"
       sodipodi:nodetypes="ccsc" />
    <path
       style="fill:url(#linearGradient3994);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 136.46031,34.091404 C 235.09739,122.34563 178.36254,208.00415 140.91011,229.8823 C 277.74124,182.04702 245.10942,70.802195 136.46031,34.091404 z "
       id="path3947"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient4002);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 135.34786,33.720586 C 192.82435,53.744655 235.4682,91.197078 231.76005,147.93194 C 256.97554,123.82889 263.65023,47.069965 135.34786,33.720586 z "
       id="path3949"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient4010);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 136.0895,33.349772 C 190.97028,37.799565 220.63556,58.936081 232.87249,73.027092 C 232.01964,45.512635 178.3074,21.263126 136.0895,33.349772 z "
       id="path3951"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient4018);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 135.34787,32.608139 C 164.64234,27.416714 180.58743,31.495691 195.42007,35.574667 C 185.77886,15.550599 147.21398,17.775496 135.34787,32.608139 z "
       id="path3953"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient4026);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 126.81909,15.179784 C 132.01052,21.483656 132.38134,24.821002 134.97705,32.978955 C 142.39337,23.708554 147.21397,23.708554 156.85519,20.742025 C 147.95561,9.6175422 135.34787,11.471623 126.81909,15.179784 z "
       id="path3955"
       sodipodi:nodetypes="cccc" />
    <path
       style="fill:url(#linearGradient4034);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 87.883415,17.775496 C 105.31176,18.146312 125.70665,25.93345 133.49378,32.978955 C 130.89807,21.854473 131.6397,22.225289 125.33582,14.438151 C 109.39073,9.2467262 97.895439,9.2467264 87.883415,17.775496 z "
       id="path3957"
       sodipodi:nodetypes="cccc" />
    <path
       sodipodi:nodetypes="csc"
       id="path3961"
       d="M 103.48707,262.55445 C 102.17561,275.61738 77.013633,266.31488 78.216971,259.69652 C 79.987349,249.95944 103.93832,253.379 103.48707,262.55445 z "
       style="fill:url(#linearGradient4074);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;display:inline" />
    <path
       style="fill:url(#linearGradient4082);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 73.253202,264.96113 C 67.236511,287.97496 102.73498,299.10584 105.59291,271.7299 C 100.17789,275.64075 85.286581,279.5516 73.253202,264.96113 z "
       id="path3968"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:url(#linearGradient4090);fill-opacity:1.0;fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 84.384078,250.97232 C 75.810295,251.57399 71.14736,260.14778 73.403619,263.15612 C 77.615302,274.13658 100.17789,280.30369 106.94667,268.2703 C 107.99959,263.75779 109.95501,261.05028 103.7879,254.58234 C 101.9829,254.58233 98.974552,254.73276 97.620796,254.88317 C 102.58456,256.98901 106.64583,261.65194 101.38123,267.81905 C 94.1612,272.33157 72.049863,265.26196 79.420309,256.38734 C 82.879905,253.52941 88.595761,253.52941 90.099934,253.52941 C 87.392423,252.32608 86.038668,251.7244 84.384078,250.97232 z "
       id="path3970"
       sodipodi:nodetypes="ccccccccc" />
  </g>
  <g
     inkscape:groupmode="layer"
     id="layer2"
     inkscape:label="lines"
     style="display:inline"
     sodipodi:insensitive="true">
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 134.46929,33.937985 C 67.683575,12.723699 8.2248302,36.319164 12.310544,86.997735"
       id="path1950"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 133.0872,34.138974 C 33.678097,30.619502 -39.714485,91.977285 45.221229,195.69157"
       id="path1952"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 133.49529,33.937985 C -23.647565,75.580842 35.357142,214.5 81.714286,234.92857"
       id="path1954"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 134.2,34.1 C 64.9,102.3 60.5,208.45 88.55,239.25"
       id="path1961"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 134.75,34.1 C 152.35,119.35 122.65,229.35 98.45,240.9"
       id="path1963"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 134.62375,33.486875 C 250.09816,132.94094 162.25,239.25 107.25,242"
       id="path1965"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 134.44105,33.458174 C 230.25614,62.154106 293.158,175.39882 137.96207,231.55"
       id="path1967"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 134.37984,33.486875 C 246.02984,42.836875 266.57572,112.3311 230.3189,150.37703"
       id="path1969"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 134.22775,33.580609 C 188.12775,19.830609 234.07297,50.277034 232.97297,74.477034"
       id="path1971"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 134.4401,33.490691 C 147.80637,14.964969 186.95682,17.163517 195.78241,36.012205"
       id="path1973"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 48.4,31.9 C 61.05,11.55 104.25895,12.898685 134.50895,33.798685"
       id="path1975"
       sodipodi:nodetypes="cc" />
    <path
       style="opacity:1;fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1;display:inline"
       d="M 88.008004,17.216273 C 97.060628,8.101312 118.92159,10.022713 126.5,15.95 C 132.5397,20.673818 131.26635,24.966168 134.56635,33.766168"
       id="path1977"
       sodipodi:nodetypes="csc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 126.10669,15.64462 C 138.85262,9.7864829 152.59462,12.327034 157.20407,21.258137"
       id="path1980"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 75.57793,232.19628 C 70.349268,252.79404 110.59412,266.26181 114.55523,241.22761"
       id="path2868"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 73.35971,264.67736 C 67.467259,292.2868 105.79262,295.73838 105.47573,270.93697"
       id="path2870"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;stroke-opacity:1"
       d="M 78.714708,261.66692 C 87.746032,258.65648 99.027685,263.72669 101.08747,267.52935"
       id="path2878"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 103.48707,262.55445 C 102.17561,275.61738 77.013633,266.31488 78.216971,259.69652 C 79.987349,249.95944 103.93832,253.379 103.48707,262.55445 z "
       id="path3959"
       sodipodi:nodetypes="csc" />
    <path
       style="fill:none;fill-opacity:0.75;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="M 84.684913,251.12274 C 78.517805,251.87483 73.403619,255.93609 72.952367,259.54611 C 71.297777,273.83574 102.13331,282.55994 107.39792,267.21738 C 108.75168,261.65195 107.69875,258.19235 103.33665,254.43192"
       id="path3964"
       sodipodi:nodetypes="cccc" />
  </g>
</svg>
'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'yo 1/16/2013 14:09'!
buttonSVG
^'<svg x="0px" y="0px" width="36px" height="36px" viewBox="-6.203 -7 36 36">
<path fill="#B4622D" d="M2.801,22C1.258,22,0,20.751,0,19.219V2.781C0,1.249,1.258,0,2.801,0h17c1.545,0,2.801,1.249,2.801,2.781
	v16.438c0,1.532-1.256,2.781-2.801,2.781H2.801z"/>
<path fill="#FFF4D6" d="M2.801,21.603c-1.322,0-2.4-1.071-2.4-2.384V2.781c0-1.312,1.078-2.384,2.4-2.384h17
	c1.324,0,2.4,1.071,2.4,2.384v16.438c0,1.312-1.076,2.384-2.4,2.384H2.801z"/>
<linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="11.3013" y1="21.2051" x2="11.3013" y2="0.7954">
	<stop  offset="0.0123" style="stop-color:#FCD9A3"/>
	<stop  offset="0.3436" style="stop-color:#FDC36D"/>
	<stop  offset="0.5215" style="stop-color:#FDC36D"/>
	<stop  offset="0.6196" style="stop-color:#FCD08E"/>
	<stop  offset="0.9939" style="stop-color:#FDDAA6"/>
</linearGradient>
<path fill="url(#SVGID_1_)" d="M21.801,19.219c0,1.096-0.895,1.986-2,1.986h-17c-1.104,0-2-0.891-2-1.986V2.781
	c0-1.096,0.896-1.986,2-1.986h17c1.105,0,2,0.891,2,1.986V19.219z"/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'yo 9/3/2013 18:01'!
checkMarkSVG
	^' <?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!!-- Created with Inkscape (http://www.inkscape.org/) -->
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://web.resource.org/cc/"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="19.21315"
   height="18.294994"
   id="svg2"
   sodipodi:version="0.32"
   inkscape:version="0.45"
   sodipodi:modified="true"
   version="1.0">
  <defs
     id="defs4" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     gridtolerance="10000"
     guidetolerance="10"
     objecttolerance="10"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="7.9195959"
     inkscape:cx="17.757032"
     inkscape:cy="7.298821"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     inkscape:window-width="984"
     inkscape:window-height="852"
     inkscape:window-x="148"
     inkscape:window-y="66" />
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-192.905,-516.02064)">
    <path
       style="fill:#000000"
       d="M 197.67968,534.31563 C 197.40468,534.31208 196.21788,532.53719 195.04234,530.37143 L 192.905,526.43368 L 193.45901,525.87968 C 193.76371,525.57497 194.58269,525.32567 195.27896,525.32567 L 196.5449,525.32567 L 197.18129,527.33076 L 197.81768,529.33584 L 202.88215,523.79451 C 205.66761,520.74678 208.88522,517.75085 210.03239,517.13691 L 212.11815,516.02064 L 207.90871,520.80282 C 205.59351,523.43302 202.45735,527.55085 200.93947,529.95355 C 199.42159,532.35625 197.95468,534.31919 197.67968,534.31563 z "
       id="path2223" />
  </g>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
clipboardSVG
	^'<svg x="0px" y="0px" width="36px" height="36px" viewBox="-4.711 -3.104 36 36">
<rect y="2.427" fill="#B4622D" width="24.063" height="24.95"/>
<path fill="#FFF4D6" d="M22.623,4.407v-0.54H1.439v22.069h2.092C11.875,20.921,18.388,13.309,22.623,4.407z"/>
<path fill="#FCD08E" d="M22.623,4.407C17.378,13.196,11.357,18.93,3.531,25.937h19.092V4.407z"/>
<path fill="#C0C1C3" stroke="#9EA0A3" stroke-width="0.75" d="M14.971,3.368V0.375H8.927v2.993H5.102V7.36h13.916V3.368H14.971z
	 M13.086,4.533h-2.107V2.427h2.107V4.533z"/>
<path fill="#DFE0E1" d="M13.473,5.92c0.545-0.151,0.959-0.615,1.039-1.187c0.145,0.049,0.299,0.075,0.459,0.075h2.607V5.92H13.473z
	 M6.541,5.92V4.809h2.386c0.222,0,0.431-0.051,0.618-0.14c0.057,0.601,0.48,1.094,1.046,1.251H6.541z"/>
<polygon fill="#E0AC5E" points="21.953,11.185 20.05,11.185 20.05,16.894 25.779,16.894 25.779,14.989 "/>
<polygon fill="#FFFFFF" points="21.428,15.516 21.428,12.604 24.355,15.516 "/>
<polygon fill="#ECF0F9" points="19.182,18.039 19.197,12.587 10.002,12.587 10.002,29.024 19.197,29.024 24.89,29.024 
	24.874,18.039 "/>
<rect x="12.438" y="16.894" fill="#E0AC5E" width="7.612" height="1.942"/>
<rect x="12.438" y="20.739" fill="#E0AC5E" width="9.516" height="1.904"/>
<linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="8.6309" y1="20.7197" x2="25.7793" y2="20.7197">
	<stop  offset="0" style="stop-color:#E09E37"/>
	<stop  offset="1" style="stop-color:#B4622D"/>
</linearGradient>
<polygon fill="url(#SVGID_1_)" points="20.05,16.894 20.05,18.243 24.348,18.243 24.348,28.913 10.109,28.913 10.109,12.579 
	18.715,12.579 18.715,16.894 20.05,16.894 20.05,11.185 8.631,11.185 8.631,30.255 25.779,30.255 25.779,16.894 "/>
<rect x="12.438" y="24.544" fill="#E0AC5E" width="9.516" height="1.904"/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
copySVG
	^'<svg x="0px" y="0px" width="36px" height="36px" viewBox="-10.188 -11.64 36 36">
<polygon fill="#E0AC5E" points="7,0 6,0 6,3 9.011,3 9.011,2 "/>
<polygon fill="#FFF5DE" points="5.552,3.854 5.552,0.737 0.721,0.737 0.721,9.375 5.552,9.375 8.543,9.375 8.543,3.854 "/>
<rect x="2" y="3" fill="#E0AC5E" width="4" height="1.021"/>
<rect x="2" y="5.021" fill="#E0AC5E" width="5" height="1"/>
<polygon fill="#B4622D" points="6,3 6,4.021 8,4.021 8,9.02 1,9.02 1,1 5,1 5,3 6,3 6,0 0,0 0,10.02 9.011,10.02 9.011,3 "/>
<rect x="2" y="7.02" fill="#E0AC5E" width="5" height="1"/>
<polygon fill="#E0AC5E" points="12.995,2.98 11.995,2.98 11.995,5.98 15.005,5.98 15.005,4.98 "/>
<polygon fill="#FFF5DE" points="11.548,6.834 11.548,3.718 6.716,3.718 6.716,12.356 11.548,12.356 14.538,12.356 14.538,6.834 "/>
<rect x="7.995" y="5.98" fill="#E0AC5E" width="4" height="1.02"/>
<rect x="7.995" y="8" fill="#E0AC5E" width="5" height="1"/>
<polygon fill="#B4622D" points="11.995,5.98 11.995,7 13.995,7 13.995,12 6.995,12 6.995,3.98 10.995,3.98 10.995,5.98 11.995,5.98 
	11.995,2.98 5.995,2.98 5.995,13 15.005,13 15.005,5.98 "/>
<rect x="7.995" y="10" fill="#E0AC5E" width="5" height="1"/>
<polygon fill="#FFF4D6" points="6.72,2.28 6.72,0.737 8.271,2.28 "/>
<polygon fill="#FFF4D6" points="12.715,5.261 12.715,3.718 14.266,5.261 "/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
cutSVG
	^'<svg x="0px" y="0px" width="36px" height="36px" viewBox="-13.479 -9.658 36 36">
<path fill="#FFF5DE" d="M9.055,12.972c-0.478-0.918-1.162-1.109-1.653-1.109c-0.176,0-0.354,0.031-0.542,0.096
	c-0.019-0.376-0.062-0.683-0.13-0.925c-0.07-0.256-0.191-0.584-0.37-0.984L6.312,9.94l1.805-3.898
	c0.381-0.819,0.63-1.438,0.759-1.888c0.132-0.469,0.199-0.965,0.199-1.476c0-0.562-0.154-1.119-0.46-1.655L8.031,0L4.7,6.845
	L1.14,0.287L0.55,0.901C0.186,1.283,0,1.749,0,2.283c0,0.752,0.375,1.853,1.144,3.363l2.123,4.182
	c-0.359,0.779-0.555,1.47-0.555,2.082c0,0.014,0,0.026,0,0.039c-0.146-0.048-0.271-0.07-0.39-0.07c-0.538,0-1.274,0.215-1.729,1.241
	c-0.293,0.657-0.441,1.337-0.441,2.016c0,0.573,0.18,1.053,0.535,1.43c0.359,0.38,0.83,0.581,1.357,0.581
	c0.532,0,1.007-0.202,1.37-0.581c0.358-0.366,0.604-1.025,0.774-2.069c0.139-0.83,0.262-1.441,0.368-1.819
	c0.12-0.427,0.237-0.613,0.296-0.686c0.02-0.025,0.057-0.049,0.084-0.072c0.155,0.382,0.34,1.027,0.512,2.119
	c0.123,0.764,0.231,1.297,0.328,1.634c0.125,0.427,0.349,0.778,0.663,1.041c0.333,0.276,0.749,0.417,1.239,0.417
	c0.762,0,1.19-0.353,1.415-0.649c0.29-0.38,0.436-0.912,0.436-1.58C9.529,14.224,9.37,13.575,9.055,12.972z M2.271,15.094
	c-0.095,0.247-0.174,0.295-0.255,0.295c-0.021,0-0.039-0.003-0.059-0.006c-0.014-0.018-0.061-0.072-0.061-0.229
	c0-0.35,0.078-0.74,0.229-1.16c0.052-0.148,0.138-0.325,0.24-0.325l0.094,0.003c0.011,0.017,0.041,0.095,0.041,0.261
	C2.502,14.302,2.425,14.692,2.271,15.094z M7.656,15.35c-0.032,0-0.132,0-0.218-0.354c-0.151-0.629-0.184-0.958-0.184-1.123
	c0-0.124,0.023-0.191,0.042-0.214c0.006-0.006,0.016-0.017,0.075-0.017c0.033,0,0.121,0,0.213,0.312
	c0.131,0.448,0.197,0.856,0.197,1.216C7.782,15.271,7.753,15.305,7.656,15.35z"/>
<path fill="#B4622D" d="M8.505,13.258c-0.27-0.517-0.638-0.775-1.104-0.775c-0.225,0-0.464,0.085-0.717,0.253
	c-0.117,0.079-0.201,0.118-0.252,0.118c-0.067,0-0.112-0.038-0.135-0.113c-0.022-0.076-0.039-0.26-0.051-0.552
	c-0.012-0.427-0.051-0.757-0.115-0.99s-0.177-0.532-0.34-0.896l-0.463,1.002c0.292,0.505,0.536,1.384,0.732,2.637
	c0.118,0.729,0.223,1.249,0.312,1.558s0.244,0.555,0.463,0.737s0.5,0.273,0.842,0.273c0.41,0,0.717-0.135,0.921-0.404
	c0.205-0.27,0.31-0.671,0.31-1.204C8.909,14.322,8.774,13.774,8.505,13.258z M8.192,15.742c-0.141,0.152-0.316,0.228-0.536,0.228
	c-0.413,0-0.688-0.276-0.821-0.829c-0.133-0.554-0.2-0.976-0.2-1.268c0-0.27,0.067-0.479,0.2-0.628
	c0.134-0.148,0.313-0.224,0.537-0.224c0.391,0,0.66,0.253,0.81,0.759c0.147,0.505,0.222,0.969,0.222,1.39
	C8.403,15.4,8.333,15.591,8.192,15.742z"/>
<path fill="#B4622D" d="M8.276,3.984c0.119-0.416,0.178-0.851,0.178-1.306S8.327,1.774,8.075,1.331L3.897,9.914
	c-0.377,0.77-0.564,1.435-0.564,1.996c0,0.129,0.011,0.258,0.033,0.388c0.034,0.18,0.051,0.3,0.051,0.362
	c0,0.135-0.048,0.202-0.143,0.202c-0.045,0-0.711-0.362-0.952-0.362c-0.517,0-0.904,0.29-1.163,0.871
	c-0.258,0.582-0.387,1.17-0.387,1.765c0,0.41,0.121,0.744,0.365,1.003c0.244,0.258,0.547,0.387,0.906,0.387
	c0.365,0,0.674-0.132,0.927-0.396c0.259-0.264,0.46-0.842,0.606-1.735c0.141-0.848,0.267-1.477,0.382-1.887
	c0.115-0.409,0.253-0.713,0.413-0.909s0.4-0.365,0.721-0.506l2.46-5.314C7.917,4.998,8.159,4.399,8.276,3.984z M2.853,15.312
	c-0.178,0.472-0.455,0.708-0.83,0.708c-0.229,0-0.41-0.081-0.544-0.244s-0.201-0.371-0.201-0.623c0-0.422,0.087-0.878,0.265-1.369
	c0.175-0.491,0.45-0.737,0.825-0.737c0.251,0,0.44,0.073,0.565,0.22c0.127,0.146,0.189,0.367,0.189,0.665
	C3.122,14.381,3.032,14.841,2.853,15.312z"/>
<path fill="#B4622D" d="M3.779,9.468l0.773-1.592L0.999,1.331C0.747,1.595,0.62,1.912,0.62,2.283c0,0.646,0.359,1.673,1.078,3.082
	L3.779,9.468z"/>
<path fill="#E0AC5E" d="M4.512,9.745c0-0.106,0.036-0.197,0.11-0.273c0.072-0.076,0.162-0.113,0.27-0.113
	c0.101,0,0.188,0.037,0.264,0.113C5.23,9.548,5.271,9.636,5.271,9.737c0,0.106-0.04,0.196-0.115,0.27
	c-0.076,0.072-0.163,0.109-0.264,0.109c-0.107,0-0.197-0.037-0.27-0.109C4.548,9.934,4.512,9.847,4.512,9.745z"/>
</svg>
'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
emailDownTriangleSVG
^'<svg>
<polygon points="16.104,0 8.055,8.052 0,0 "/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
emailDraftSVG
^'<svg>
<line fill="none" stroke="#E5F2FE" stroke-width="2" x1="21.917" y1="13.201" x2="47.26" y2="13.201"/>
<line fill="none" stroke="#E5F2FE" stroke-width="2" x1="21.917" y1="17.227" x2="47.26" y2="17.227"/>
<line fill="none" stroke="#E5F2FE" stroke-width="2" x1="21.917" y1="21.252" x2="47.26" y2="21.252"/>
<line fill="none" stroke="#E5F2FE" stroke-width="2" x1="21.917" y1="25.277" x2="34.331" y2="25.277"/>
<line fill="none" stroke="#E5F2FE" stroke-width="2" x1="21.917" y1="29.303" x2="34.331" y2="29.303"/>
<line fill="none" stroke="#E5F2FE" stroke-width="2" x1="21.917" y1="33.328" x2="34.331" y2="33.328"/>
<line fill="none" stroke="#FBC6C3" stroke-width="2" x1="26.691" y1="8.484" x2="26.691" y2="36.332"/>
<line fill="none" stroke="#CCD3D9" stroke-width="2" x1="29.973" y1="13.201" x2="35.427" y2="13.201"/>
<line fill="none" stroke="#CCD3D9" stroke-width="2" x1="29.973" y1="17.191" x2="40.198" y2="17.191"/>
<polygon fill="none" points="23.392,36.287 34.922,36.287 45.813,25.545 45.813,8.52 23.392,8.52 "/>
<path fill="#D2D3D5" d="M21.392,6.52v31.767h14.351l12.071-11.906V6.52H21.392z M45.813,25.545L34.922,36.287h-11.53V8.52h22.422V25.545z"/>
<linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="35.542" y1="26.0283" x2="40.4372" y2="30.9235">
<stop offset="0.6196" style="stop-color:#FFFFFF"/>
<stop offset="0.9939" style="stop-color:#DEDEDE"/>
</linearGradient>
<polygon fill="url(#SVGID_1_)" points="35.541,26.027 45.332,26.027 35.541,35.818 "/>
<polygon fill="#D2D3D5" points="47.219,23.969 33.571,23.969 33.571,36.785 35.571,36.785 35.571,25.969 47.219,25.969 "/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
emailFolderSVG
^'<svg>
<path fill="#B5622D" d="M62.382,16.089H49.884v-1.435c0-0.91-0.74-1.647-1.649-1.647H35.617c-0.91,0-1.647,0.737-1.647,1.647v19.606c0,0.911,0.737,1.648,1.647,1.648h26.765c0.908,0,1.647-0.737,1.647-1.648V17.737C64.029,16.827,63.29,16.089,62.382,16.089z"/>
<linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="48.9995" y1="34.9395" x2="48.9995" y2="17.3472">
<stop offset="0.8466" style="stop-color:#FAC26E"/>
<stop offset="0.9448" style="stop-color:#FDDEB0"/>
</linearGradient>
<path fill="url(#SVGID_1_)" d="M63.144,33.939c0,0.55-0.45,1-1,1H35.855c-0.55,0-1-0.45-1-1V18.347c0-0.55,0.45-1,1-1h26.288c0.55,0,1,0.45,1,1V33.939z"/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
emailInboxSVG
^'<svg>
<polygon fill="#C37E00" points="33.025,31.596 33.377,39.528 46.166,39.528 46.166,38.422 52.872,38.422 52.872,39.528 65.561,39.528 66.033,31.596 "/>
<polygon fill="#DFAE5F" points="34.553,38.399 34.299,31.596 64.74,31.596 64.404,38.399 "/>
<polygon fill="#87570C" points="59.959,14.984 64.586,30.508 63.738,30.508 59.895,20.096 "/>
<polygon fill="#87570C" points="39.1,15.061 39.096,20.116 35.324,30.553 34.248,30.555 "/>
<rect x="39.096" y="15.098" fill="#A76C25" width="20.867" height="4.999"/>
<linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="49.5298" y1="30.6182" x2="49.5298" y2="20.0962">
<stop offset="0" style="stop-color:#EFC167"/>
<stop offset="0.5951" style="stop-color:#E0AB43"/>
<stop offset="0.9816" style="stop-color:#C37E00"/>
</linearGradient>
<polygon fill="url(#SVGID_1_)" points="59.988,20.096 39.096,20.096 35.289,30.618 63.77,30.618 "/>
<path fill="#EFC167" d="M59.959,15.206l4.627,15.302H34.441l4.631-15.302H59.959z M60.92,14.119H38.096l-5.074,17.477h33.016L60.92,14.119L60.92,14.119z"/>
<polygon fill="#86550C" points="64.49,36.729 34.479,36.733 34.412,35.266 64.592,35.26 "/>
<polygon fill="#A26035" points="64.592,35.26 34.412,35.266 34.338,33.572 64.691,33.554 "/>
<path fill="#87570C" d="M52.893,35.303v-1.432c0-1.857-1.506-3.363-3.363-3.363s-3.363,1.506-3.363,3.363v1.432H52.893z"/>
<rect x="46.166" y="35.303" fill="#9C630C" width="6.706" height="1.428"/>
<rect x="46.166" y="36.766" fill="#BD966D" width="6.706" height="1.634"/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
emailSentSVG
^'<svg>
<linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="48.9995" y1="11.2764" x2="48.9995" y2="33.2163">
<stop offset="0.6196" style="stop-color:#FFFFFF"/>
<stop offset="1" style="stop-color:#E5F2FE"/>
</linearGradient>
<rect x="33.912" y="11.276" fill="url(#SVGID_1_)" width="30.176" height="21.939"/>
<path fill="#CACCCD" d="M63.088,12.276v19.939H34.912V12.276H63.088 M65.088,10.276H32.912v23.939h32.176V10.276L65.088,10.276z"/>
<line fill="none" stroke="#CACCCD" stroke-width="2" x1="37.094" y1="15.203" x2="44.98" y2="15.203"/>
<line fill="none" stroke="#CACCCD" stroke-width="2" x1="37.094" y1="19.146" x2="47.369" y2="19.146"/>
<line fill="none" stroke="#CACCCD" stroke-width="2" x1="46.771" y1="25.049" x2="56.57" y2="25.049"/>
<line fill="none" stroke="#CACCCD" stroke-width="2" x1="46.771" y1="29.257" x2="58.721" y2="29.257"/>
<rect x="54.488" y="18.283" fill="#DDE8D5" width="2.1" height="2.099"/>
<rect x="58.691" y="14.091" fill="#DCC4C7" width="2.1" height="2.099"/>
<rect x="56.594" y="14.091" fill="#BCD2C5" width="2.098" height="2.099"/>
<rect x="58.691" y="18.283" fill="#DFCDB1" width="2.1" height="2.099"/>
<rect x="56.594" y="18.283" fill="#EAB4A4" width="2.098" height="2.099"/>
<rect x="54.488" y="14.091" fill="#C6E3D4" width="2.1" height="2.099"/>
<rect x="54.488" y="16.188" fill="#BCDBC6" width="2.1" height="2.098"/>
<rect x="56.594" y="16.188" fill="#F3B7C4" width="2.098" height="2.098"/>
<rect x="58.691" y="16.188" fill="#E3C0C0" width="2.1" height="2.098"/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
emailSpamSVG
^'<svg>
<path fill="#9E9E9E" d="M60.231,11.71c-0.906,0.125-1.756,0.18-2.541,0.18c-3.375-0.003-5.65-1.01-7.102-2.001c-0.725-0.496-1.238-0.989-1.568-1.354c-0.166-0.182-0.283-0.33-0.359-0.432c-0.074-0.099-0.098-0.138-0.098-0.137l-0.564-0.895l-0.566,0.895c0,0-0.021,0.038-0.098,0.137c-0.541,0.708-3.141,3.781-9.027,3.789c-0.787-0.002-1.633-0.057-2.543-0.182l-0.758-0.102v0.766c0,0.033-0.002,5.01,1.562,10.718c1.566,5.692,4.709,12.2,11.16,15.069l0.27,0.12l0.27-0.12c6.451-2.869,9.592-9.377,11.16-15.069c1.564-5.708,1.564-10.685,1.564-10.718v-0.767L60.231,11.71z"/>
<linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="36.6724" y1="23.1782" x2="58.9632" y2="23.1782">
<stop offset="0" style="stop-color:#DBDBDB"/>
<stop offset="0.5215" style="stop-color:#FAFAFA"/>
<stop offset="0.9939" style="stop-color:#B0B0B0"/>
</linearGradient>
<path fill="url(#SVGID_1_)" d="M47.999,36.347c-4.564-2.221-7.836-6.834-9.732-13.722c-1.037-3.784-1.357-7.267-1.457-9.034c0.506,0.039,1.006,0.059,1.496,0.061c5.236-0.008,8.283-2.23,9.688-3.642c0.469,0.474,1.018,0.93,1.602,1.331c2.238,1.529,4.961,2.306,8.094,2.309c0.492,0,0.992-0.02,1.5-0.059c-0.1,1.769-0.42,5.252-1.457,9.036
C55.835,29.513,52.562,34.126,47.999,36.347L47.999,36.347z"/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
emailTrashSVG
^'<svg>
<path fill="#959A9E" d="M55.226,10.525H40.777c-2.331,0-4.237,1.431-4.237,3.177v1.016h22.92v-1.016C59.46,11.956,57.554,10.525,55.226,10.525z"/>
<linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="48" y1="37.9229" x2="48" y2="7.3076">
<stop offset="0" style="stop-color:#DBDBDB"/>
<stop offset="0.5215" style="stop-color:#FAFAFA"/>
<stop offset="0.9939" style="stop-color:#B0B0B0"/>
</linearGradient>
<path fill="url(#SVGID_1_)" d="M50.479,7.412h-4.959c-0.801,0-1.454,0.654-1.454,1.454v0.465h7.868V8.866C51.935,8.066,51.28,7.412,50.479,7.412z"/>
<path fill="#959A9E" d="M50.479,7.412h-4.959c-0.801,0-1.454,0.654-1.454,1.454v0.465h7.868V8.866C51.935,8.066,51.28,7.412,50.479,7.412z"/>
<path fill="#959A9E" d="M38.318,15.284v17.995c0,2.312,1.608,4.205,3.578,4.205h12.207c1.97,0,3.581-1.893,3.581-4.205V15.284H38.318z"/>
<linearGradient id="SVGID_2_" gradientUnits="userSpaceOnUse" x1="39.3184" y1="26.3848" x2="56.6846" y2="26.3848">
<stop offset="0" style="stop-color:#DBDBDB"/>
<stop offset="0.5215" style="stop-color:#FAFAFA"/>
<stop offset="0.9939" style="stop-color:#B0B0B0"/>
</linearGradient>
<path fill="url(#SVGID_2_)" d="M41.896,36.484c-1.397,0-2.578-1.468-2.578-3.205V16.284h17.366v16.995c0,1.737-1.182,3.205-2.581,3.205H41.896z"/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'yo 1/17/2013 21:33'!
frankHeadSVG
	^'<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   version="1.1"
   width="663.07654"
   height="683.61395"
   id="svg2"
   style="display:inline">
  <defs
     id="defs4" />
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1">
    <path
       d="M 554.25393,352.52715 C 559.9843,499.43152 396.82627,616.15662 259.64227,563.29566 123.78342,522.37112 63.445651,340.91551 147.78635,226.79199 226.00532,102.31096 426.57341,98.09954 509.9487,219.18748 c 28.63356,38.1346 44.42022,85.65814 44.30523,133.33967 z"
       id="path4006"
       style="fill:#ff5200;fill-opacity:0.8;stroke:none;display:inline" />
    <g
       transform="translate(5.847171,45.725513)"
       id="layer10"
       style="display:inline">
      <path
         d="m 161.56181,395.34865 c -0.49555,0.0258 -0.97175,0.12086 -1.4375,0.28125 -5.20076,1.98426 -20.43687,7.92223 -21.65625,8.40625 -5.72217,4.86099 -5.67232,22.48258 0.5,41.71875 6.0669,18.90765 15.96917,32.92536 23.34375,33.78125 1.38692,0.39236 2.63281,-0.25451 3.75,-0.875 0.012,-0.008 0.0193,-0.0229 0.0312,-0.0312 l 18.3438,-6.56255 c 5.36698,-1.88168 7.32933,-13.50625 5,-28.21875 l 30.50001,-19.6875 c -4.43043,-16.54387 -4.36682,-18.27017 -4.28125,-18.4375 l -36.28126,6.53125 c -0.009,-0.0289 -11.15922,-16.88263 -17.8125,-16.90625 z"
         id="path4218"
         style="fill:#eecc2f;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 183.60379,420.88972 -19.8125,7.96875 c 0.58743,1.50517 1.10466,3.03238 1.625,4.5625 l 20,-7.90625 c -0.53865,-1.56797 -1.19822,-3.08536 -1.8125,-4.625 z"
         id="path4104"
         style="fill:#fffef0;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 171.95942,401.12626 c -2.94112,1.03158 -4.01379,1.42109 -8.15625,2.84375 -5.60421,1.92467 -8.8661,2.88742 -12.0625,3.84375 0.15137,0.18214 0.32163,0.38574 0.46875,0.5625 3.6486,5.01645 6.48256,10.53267 8.9375,16.21875 l 19.75,-7.75 c -2.04845,-4.64818 -4.34549,-9.18043 -7.09375,-13.4375 -0.55344,-0.77108 -1.25175,-1.49891 -1.84375,-2.28125 z"
         id="path4099"
         style="fill:#fffef0;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 190.82246,457.38152 c -4.47992,1.39968 -6.36778,2.02249 -12.9375,4 -2.3124,0.69604 -4.24225,1.24351 -6.5,1.90625 -0.002,0.0979 0.003,0.21535 0,0.3125 -0.0585,1.93443 -0.21983,3.69638 -0.5,5.3125 -0.28016,1.61612 -0.68744,3.072 -1.1875,4.3125 -0.50006,1.2405 -1.09427,2.28618 -1.8125,3.09375 -0.43958,0.49427 -0.99015,0.75567 -1.53125,1.03125 l 0.0312,0.0937 18.71875,-6.6875 c 3.33938,-1.17079 5.2618,-6.25724 5.71875,-13.375 z"
         id="path4131"
         style="fill:#8c7505;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 216.14358,410.13468 c -12.23875,2.7881 -26.12464,5.93566 -35.59376,7.96875 0.77312,1.66898 1.50389,3.3848 2.21875,5.1875 l 34.00001,-9.71875 -0.625,-3.4375 z"
         id="path4149"
         style="fill:#fffef0;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 167.98824,450.678 c -1.00616,1.73067 -2.04273,3.16986 -3.09375,4.3125 -1.08699,1.18175 -2.19511,2.05689 -3.3125,2.65625 -1.11738,0.59936 -2.2451,0.93564 -3.375,1 -1.12989,0.0644 -2.28171,-0.13924 -3.40625,-0.5625 -1.12453,-0.42326 -2.24245,-1.07399 -3.34375,-1.9375 -1.10129,-0.86351 -2.18982,-1.93111 -3.25,-3.1875 -1.06017,-1.25639 -2.09257,-2.71062 -3.09375,-4.3125 -1.00117,-1.60188 -1.9507,-3.35 -2.875,-5.25 -0.9243,-1.9 -1.8267,-3.94301 -2.65625,-6.09375 -0.82954,-2.15074 -1.59558,-4.42715 -2.3125,-6.78125 -0.71691,-2.3541 -1.38234,-4.77116 -1.96875,-7.28125 -0.5864,-2.51009 -1.09323,-5.10005 -1.53125,-7.71875 -0.13749,-0.822 -0.22203,-1.67036 -0.34375,-2.5 -1.40081,8.08061 -0.0392,20.48372 4.1875,33.65625 6.76268,21.07605 18.30404,36.10112 25.78125,33.5625 5.86309,-1.9906 7.42722,-14.22659 4.59375,-29.5625 z"
         id="path4072"
         style="fill:#8c7505;fill-opacity:1;stroke:none;display:inline" />
    </g>
    <g
       transform="translate(5.847171,45.725513)"
       id="layer12"
       style="display:inline">
      <path
         d="m 437.73805,335.49015 12.53889,-1.57586 c 5.99878,-0.7539 12.28279,5.33664 15.24657,16.96699 l 0,0 c 2.90583,11.403 0.55228,20.79549 -4.91456,22.74505 l -12.08453,4.30953"
         id="path3957"
         style="fill:#eecc2f;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 452.45307,353.68594 c 2.96378,11.63034 -0.26184,22.56882 -5.87724,24.09992 -5.6154,1.53111 -12.5702,-6.65595 -15.53398,-18.28629 -2.96377,-11.63035 -0.8142,-22.29981 4.8012,-23.83092 5.6154,-1.5311 13.64624,6.38694 16.61002,18.01729 z"
         id="path3959"
         style="fill:#8c7505;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 447.97341,341.19759 11.9168,-1.06352 3.56437,7.6629 -11.50454,1.51141 z"
         id="path3965"
         style="fill:#fffef0;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 444.625,328.46875 0.40625,3.5625 c 5.76864,0.55419 11.62436,12.09368 12.34375,15.90625 0.54224,1.37532 1.79678,1.39054 1.53125,0 -2.5816,-6.56039 -6.64321,-19.63419 -14.28125,-19.46875 z m 13.9375,32.375 c -0.32452,0.0683 -0.6476,0.55634 -0.875,1.6875 -1.51329,7.62976 -5.61565,7.54846 -8.78125,5.34375 l 0.625,5.875 c 1.49279,0.49655 3.06611,0.59857 4.71875,0.1875 4.18935,-2.99397 4.6718,-6.39639 5.21875,-11.59375 -0.0994,-0.95355 -0.48901,-1.58779 -0.90625,-1.5 z"
         id="path3967"
         style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:3.18105221;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
      <path
         d="m 457.48862,327.06896 c -4.97169,-0.22434 -9.86316,1.09461 -14.94319,1.74148 l 5.7394,3.08572 6.90778,-1.7099 c 15.12437,2.44664 16.75878,29.17881 9.47263,36.61507 l -6.18373,0.656 -4.69716,6.67281 12.10396,-4.31975 c 11.88917,-11.15493 1.8134,-39.83634 -8.39969,-42.74143 z"
         id="path3969"
         style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:3.18105221;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    </g>
    <path
       d="m 218.78393,372.87861 c -28.06888,-27.19258 -60.16888,-21.36477 -60.7528,-7.29574 -1.22572,29.53302 16.98685,58.99595 63.79881,66.65942 z"
       id="path4251"
       style="fill:#9fdf73;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 178.72805,353.82692 c -11.9174,-0.3635 -20.39064,4.59742 -20.6875,11.75 -1.00692,24.2613 11.1294,48.44243 41.4375,60.5625 -0.15012,-0.18486 -0.32037,-0.34381 -0.46875,-0.53125 -2.24477,-2.83576 -4.27091,-5.96852 -6.125,-9.3125 -1.85408,-3.34398 -3.52335,-6.89716 -5,-10.59375 -1.47665,-3.69659 -2.76255,-7.54392 -3.875,-11.4375 -1.11245,-3.89358 -2.051,-7.84628 -2.8125,-11.78125 -0.7615,-3.93497 -1.35746,-7.83551 -1.78125,-11.65625 -0.42379,-3.82074 -0.68192,-7.54284 -0.78125,-11.09375 -0.0583,-2.08424 0.0439,-3.95751 0.0937,-5.90625 z"
       id="path4051"
       style="fill:#36bb5d;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 423.22274,329.02225 c 12.23688,-23.5108 31.50477,-34.68152 38.27313,-24.56826 9.43867,14.10324 7.73904,39.34274 -21.96155,74.05016 z"
       id="path3808"
       style="fill:#9fdf73;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 452.54435,360.46991 c -1.86934,-0.87218 -3.68163,-1.81373 -5.3125,-2.90625 -1.87201,-1.25407 -3.56859,-2.65313 -5.15625,-4.21875 -1.58766,-1.56562 -3.07102,-3.28762 -4.40625,-5.1875 -1.33523,-1.89988 -2.54155,-3.9619 -3.65625,-6.21875 -1.1147,-2.25685 -2.13641,-4.70724 -3.0625,-7.34375 -0.92609,-2.63651 -1.76187,-5.46112 -2.53125,-8.5 -0.36979,-1.46058 -0.66095,-3.13009 -1,-4.6875 -1.54375,2.33983 -3.04687,4.79693 -4.4375,7.46875 l -0.0312,0.0937 c 1.34286,3.37789 2.75159,6.8202 3.96875,10.09375 2.1901,5.89026 4.15312,11.55227 5.8125,16.875 1.65938,5.32273 2.99921,10.29014 3.96875,14.75 0.60339,2.77559 1.10017,5.72767 1.625,8.625 l 0.96875,-0.9375 c 5.41409,-6.32678 9.59428,-12.21813 13.25,-17.90625 z"
       id="path4042"
       style="fill:#36bb5d;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 382.55849,240.38277 c 16.26346,24.74873 48.64063,92.76454 56.39692,128.44345 7.7126,35.47798 8.79045,83.25079 8.79045,83.25079 0,0 -38.40618,26.94854 -89.9729,41.88393 -51.52598,14.92359 -126.1689,17.06384 -126.1689,17.06384 0,0 -10.52263,-30.03578 -16.54675,-68.7724 -6.66341,-42.84745 -11.42886,-119.80843 -11.42886,-119.80843"
       id="path4023"
       style="fill:#9fdf73;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 383.37842,238.47551 -144.8125,66.40625 -33.9375,15.5625 c 0,0 4.77409,76.96505 11.4375,119.8125 6.02412,38.73662 16.53125,68.78125 16.53125,68.78125 0,0 27.11264,-0.86231 59.8125,-4.71875 -0.23695,-0.14862 -0.51469,-0.25617 -0.75,-0.40625 -3.63184,-2.31641 -7.06665,-4.80371 -10.3125,-7.46875 -3.24585,-2.66504 -6.31641,-5.51563 -9.1875,-8.53125 -2.87109,-3.01562 -5.55493,-6.19434 -8.0625,-9.5625 -2.50757,-3.36816 -4.81348,-6.93359 -6.96875,-10.65625 -2.15527,-3.72266 -4.15454,-7.6084 -5.96875,-11.6875 -1.81421,-4.0791 -3.45313,-8.34375 -4.9375,-12.78125 -1.48438,-4.4375 -2.80298,-9.0459 -3.96875,-13.84375 -1.16577,-4.79785 -2.17285,-9.77734 -3.03125,-14.9375 -0.8584,-5.16016 -1.56274,-10.50684 -2.125,-16.03125 -0.56226,-5.52441 -0.97266,-11.23438 -1.25,-17.125 -0.27734,-5.89062 -0.43384,-11.95996 -0.4375,-18.21875 -0.004,-6.25879 0.11621,-12.71484 0.375,-19.34375 -0.0824,2.10972 -0.0703,4.08233 -0.125,6.15625 0.89553,1.62336 1.78769,3.23595 2.59375,4.9375 1.11717,2.35828 2.16061,4.76332 3.15625,7.21875 1.61572,-0.68637 3.22765,-1.59508 4.8125,-2.71875 1.58485,-1.12367 3.14327,-2.45721 4.65625,-3.9375 1.51298,-1.48029 2.9749,-3.11876 4.375,-4.875 1.4001,-1.75624 2.75377,-3.61098 4,-5.5625 1.24623,-1.95152 2.38614,-3.99638 3.4375,-6.0625 1.05136,-2.06612 1.99701,-4.14996 2.8125,-6.25 0.81549,-2.10004 1.49264,-4.19671 2.03125,-6.25 0.53861,-2.05329 0.93551,-4.07413 1.15625,-6 2.82155,0.79984 5.79447,1.58789 8.8125,2.53125 3.01803,0.94336 6.0969,2.05035 9.09375,3.5 1.49842,0.72483 2.98518,1.51808 4.4375,2.4375 1.45232,0.91942 2.87099,1.96564 4.25,3.125 1.37901,1.15936 2.72151,2.43035 4,3.875 1.27849,1.44465 2.47423,3.03721 3.625,4.8125 2.35199,-1.57447 4.46688,-3.11688 6.34375,-4.65625 1.87687,-1.53937 3.52586,-3.06684 5,-4.59375 1.47414,-1.52691 2.76246,-3.05666 3.90625,-4.59375 1.14379,-1.53709 2.14542,-3.08633 3.03125,-4.65625 0.88583,-1.56992 1.6435,-3.15585 2.34375,-4.78125 0.70025,-1.6254 1.35044,-3.29648 1.9375,-5 1.17411,-3.40705 2.18812,-6.98833 3.34375,-10.84375 3.55449,1.0308 7.25609,2.33858 11.03125,3.84375 3.77516,1.50517 7.60929,3.2165 11.5,5.0625 3.89071,1.846 7.81762,3.82171 11.71875,5.875 3.90113,2.05329 7.78731,4.18546 11.59375,6.3125 1.54453,-2.84349 3.15654,-5.85316 4.6875,-8.96875 1.53096,-3.11559 2.98103,-6.32471 4.21875,-9.53125 1.23772,-3.20654 2.2727,-6.4149 2.9375,-9.53125 0.3324,-1.55818 0.55077,-3.09209 0.6875,-4.59375 0.13673,-1.50166 0.18765,-2.98374 0.0937,-4.40625 5.47256,2.77755 10.55958,5.16504 15.625,7.15625 2.53271,0.9956 5.07278,1.89399 7.625,2.6875 1.11751,0.34745 2.27386,0.59805 3.40625,0.90625 -10.63776,-23.34147 -22.05709,-45.1142 -29.9375,-57.25 -0.1437,-0.15325 -0.48752,-0.47756 -0.625,-0.625 z"
       id="path4024"
       style="fill:#36bb5d;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 346.70954,405.58659 c -1.46484,5.50773 2.63244,1.67036 5.05491,0.76099 13.13441,-8.90539 21.4871,3.72036 10.59177,15.19754 -1.0687,1.61934 1.01695,3.86822 2.69506,2.75393 1.3513,-0.82852 2.48097,-1.97732 3.67098,-3.01859 2.91405,-2.77596 5.49911,-9.22154 5.52187,-13.40082 -4.10814,-13.50073 -18.99849,-7.86754 -27.53459,-2.29305 z"
       id="path3855"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 317.00029,320.90832 c -27.5276,8.67754 -60.50115,39.33702 -81.57117,62.77591 -1.32613,1.71981 0.49909,3.68825 2.17791,2.31062 26.70889,-24.57046 59.74256,-53.32733 80.69945,-62.30892 1.47672,-1.30123 0.62014,-3.2005 -1.30619,-2.77761 z"
       id="path3857"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 282.21209,328.05765 c 6.36366,6.00485 11.70934,13.08988 16.0361,20.68304 1.0561,4.46859 5.39393,1.90704 3.23556,-0.94663 -2.10918,-7.48346 -11.62402,-21.48031 -16.61407,-22.73934 -2.27867,-2.22981 -4.58585,1.79317 -2.65759,3.00293 z"
       id="path3859"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 261.28467,338.53801 c -2.03186,-0.0238 -2.63153,2.99468 -0.81531,3.83732 7.22428,6.06055 13.48008,13.07544 19.30498,20.78587 3.45588,4.57456 8.3821,4.47242 5.44221,1.11468 -4.26684,-4.77081 -15.90308,-24.66878 -23.93188,-25.73787 z"
       id="path3861"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 241.84717,357.63176 c 7.71665,6.95614 14.37178,15.07892 19.75458,23.95459 1.35002,1.55797 3.23719,0.51521 2.4564,-1.39271 -3.52151,-10.27935 -13.02435,-22.4416 -20.7106,-25.55455 -2.20168,-1.0209 -2.74535,1.90308 -1.50038,2.99267 z"
       id="path3863"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <g
       transform="translate(5.847171,45.725513)"
       id="layer5"
       style="display:inline">
      <path
         d="m 194.63481,251.28361 c 45.47351,-20.31035 117.83636,-82.80989 185.10055,-84.84178 0,0 24.20488,29.33245 77.37424,66.17702 -30.90113,2.17595 -46.94673,-2.76094 -68.83698,-13.87114 0.7512,11.38006 -6.43712,25.65539 -12.61523,37.02935 -15.22575,-8.50815 -31.62956,-16.96048 -45.84751,-21.08369 -4.62253,15.42167 -7.07661,26.53171 -25.89252,39.1275 -9.20617,-14.20233 -22.93477,-17.09869 -34.22099,-20.29806 -1.76593,15.40695 -14.35977,36.18227 -27.28556,41.6732 -3.98254,-9.82174 -8.7035,-19.11267 -16.03372,-25.90131 -8.72015,12.26288 -20.73478,25.91637 -36.24733,32.00427 1.74228,-23.33597 6.21244,-26.95202 4.50505,-50.01536 z"
         id="path3871"
         style="fill:#948594;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 381.9731,242.46431 c -0.5545,-0.8661 -1.09445,-1.87037 -1.65625,-2.6875 -1.75025,-2.54572 -3.53648,-4.83801 -5.375,-6.96875 -1.83852,-2.13074 -3.73432,-4.09918 -5.6875,-5.90625 -1.95318,-1.80707 -3.96829,-3.45653 -6.0625,-5.03125 -2.09421,-1.57472 -4.26962,-3.06632 -6.53125,-4.5 -2.26163,-1.43368 -4.60708,-2.80353 -7.0625,-4.1875 -4.91084,-2.76793 -10.24944,-5.53929 -16.09375,-8.65625 -0.38962,2.66241 -0.98983,5.39258 -1.78125,8.125 -0.79142,2.73242 -1.75606,5.47233 -2.84375,8.1875 -1.08769,2.71517 -2.31531,5.38934 -3.59375,8 -1.27844,2.61066 -2.60508,5.14361 -3.96875,7.5625 -2.72735,4.83779 -5.53362,9.20283 -7.96875,12.75 -2.43513,3.54717 -4.51377,6.28527 -5.8125,7.84375 -1.03899,-2.85722 -1.94032,-5.57136 -2.90625,-8.25 -0.96593,-2.67864 -1.98373,-5.33759 -3.25,-8 -1.26627,-2.66241 -2.77876,-5.34774 -4.71875,-8.15625 -1.93999,-2.80851 -4.32541,-5.72679 -7.3125,-8.84375 -2.59747,2.33772 -6.83104,5.82254 -11.75,9.71875 -4.91896,3.89621 -10.52137,8.19267 -15.78125,12.21875 -10.51976,8.05216 -19.71875,14.9375 -19.71875,14.9375 2.59747,-5.06507 5.34448,-9.97511 8.65625,-15.21875 3.31177,-5.24364 7.16343,-10.82613 11.96875,-17.125 4.80532,-6.29887 10.57814,-13.33176 17.65625,-21.5625 2.46114,-2.86193 6.10683,-6.80183 8.90625,-9.96875 -36.32326,19.71047 -69.92521,43.79328 -95.15625,55.0625 1.70739,23.06334 -2.78897,26.66403 -4.53125,50 15.51256,-6.0879 27.52985,-19.73712 36.25,-32 7.33022,6.78864 12.04871,16.08451 16.03125,25.90625 12.92579,-5.49093 25.54657,-26.28055 27.3125,-41.6875 11.28622,3.19937 25.01258,6.11017 34.21875,20.3125 18.81591,-12.59579 21.25247,-23.70333 25.875,-39.125 14.21795,4.12321 30.618,12.5856 45.84375,21.09375 2.33019,-4.2899 4.70634,-9.03939 6.84375,-13.84375 z"
         id="path3884"
         style="fill:#484048;fill-opacity:1;stroke:none;display:inline" />
    </g>
    <path
       d="m 390.65967,200.25676 c -48.08435,1.78154 -92.30668,24.70292 -131.60143,50.80912 -18.58348,11.98422 -36.28754,25.648 -56.52357,34.81583 2.54454,18.34211 -3.97388,36.08306 -4.62505,54.28125 16.26477,-5.53431 28.72314,-18.30413 38.59375,-31.90625 6.88767,7.15801 11.22965,16.28551 14.8125,25.4375 16.54156,-7.15099 26.31775,-24.84119 29.9375,-41.8125 12.61535,2.85536 25.64247,8.7487 32.0938,20.5938 13.65666,-7.89975 23.3775,-21.36696 26.95348,-36.68134 4.60511,-5.26172 16.50057,4.80741 23.5956,6.66091 7.6544,3.69447 15.12569,7.75255 22.54467,11.89543 6.1741,-11.48191 12.9379,-23.36605 13.8125,-36.65625 21.15691,11.51706 45.684,15.07963 69.46229,12.60537 7.37535,0.47501 -3.79166,-4.11143 -5.1407,-6.04957 -26.53131,-18.92122 -52.34831,-39.44698 -73.91534,-63.9933 z m -1.75,4.09375 c 18.25717,27.51087 44.01596,49.7977 73.72513,64.17518 -22.21273,1.93476 -42.7316,-8.06327 -61.6437,-18.4067 -8.20536,-0.72894 -3.27626,7.97194 -5.11072,12.93527 -1.45866,9.80259 -4.67268,19.33426 -9.26428,28.10897 -14.83905,-8.07337 -28.02002,-19.34671 -44.29713,-24.61239 -6.27489,1.35113 -5.04878,8.012 -7.15239,12.80642 -2.9914,11.74305 -9.54708,23.84966 -19.78127,30.45424 -7.74416,-10.71787 -18.23935,-23.04408 -31.33413,-25.67924 -7.34219,-0.19852 -7.74323,6.85836 -8.62523,12.48253 -4.19594,11.94676 -12.18592,27.47382 -23.31747,34.0881 -4.00608,-9.68016 -4.55551,-23.54065 -12.63616,-30.42917 -4.43096,6.31806 -1.73494,-0.83298 -7.51461,6.57227 -5.93266,7.60127 -25.4572,26.67756 -32.51977,30.10125 5.12375,-16.71081 11.13393,-38.78246 10.62813,-51.66221 48.76515,-23.66116 88.09276,-56.17288 139.86479,-73.67137 12.60005,-4.10325 25.71665,-6.77118 38.97881,-7.26315 z"
       id="path3075"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 457.90967,442.72551 c 0.15657,-66.67099 -15.20281,-133.98775 -35.59375,-157.71875 -0.3369,-0.66289 -1.06899,-1.10467 -1.8125,-1.09375 -1.39173,0.009 -2.41446,1.79459 -1.71875,3 25.51149,49.27973 34.29676,95.14089 35.9375,153.125 -2.39537,1.65774 -42.416,29.1376 -88.5,41 -46.084,11.8624 -82.78702,15.54374 -124.1875,16.9375 -16.08887,-52.92644 -21.87535,-99.00922 -25.28125,-158.34375 -0.49611,-2.77643 -4.0446,-1.91299 -4,0.21875 -4.56494,20.26539 -0.49151,98.7493 28.09375,161.28125 38.37268,0.0676 60.41543,0.0145 111.96592,-8.6127 51.55049,-8.62724 82.57348,-33.85951 105.09658,-49.79355 z"
       id="path4118"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;stroke:none;stroke-width:0.1;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 182.31592,346.28801 c -6.60611,0.46759 -15.23352,3.64543 -17.54721,10.99659 -7.32662,32.00674 31.51928,63.48641 53.67506,67.41645 2.17081,-0.0628 2.46194,-3.50127 0.33259,-3.92814 -27.57883,-4.48019 -49.68606,-30.96529 -48.22019,-59.04042 1.07307,-20.55192 31.81565,-12.2074 40.69911,-5.25221 1.99171,0.8657 3.11352,-0.46492 1.36743,-1.75624 -8.72969,-6.1445 -19.66768,-9.11644 -30.30679,-8.43603 z"
       id="path3977"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 192.90967,358.19426 c -4.50363,-0.56625 -10.63239,1.05753 -12.43718,5.55052 -4.00066,16.10645 15.19061,33.79775 27.82604,38.22085 1.5539,0.59464 4.26407,2.26898 4.90891,-0.0236 0.45859,-1.6125 -1.23035,-2.71547 -2.66113,-2.70529 -12.35529,-4.73628 -26.61642,-19.52054 -25.45018,-31.73827 4.02014,-11.13421 19.48233,-3.08978 25.57849,0.0829 2.13449,0.61358 3.12525,-1.48276 1.1413,-2.48084 -5.85418,-3.2759 -12.14023,-6.27485 -18.90625,-6.90625 z"
       id="path3979"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 448.91584,314.42309 c -1.66436,2.78302 -7.61636,7.03498 -5.66299,10.52133 3.48389,-0.99255 6.70303,-9.21314 11.25431,-12.17022 4.19921,0.41639 4.63973,5.82469 4.98802,8.78272 -0.69849,9.13858 -4.48443,18.50834 -9.71017,25.71812 -3.44285,1.12086 -0.71894,3.504 1.16879,3.41534 1.88773,-0.0887 13.27359,-18.56249 13.87861,-29.65717 0.10433,-4.02062 -0.80162,-8.05295 -3.62012,-11.10376 -4.84022,-3.26175 -9.4346,1.54935 -12.29645,4.49364 z"
       id="path3981"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 461.22217,294.75676 c -8.76289,0.34093 -23.1469,8.99934 -24.7745,18.73423 2.49028,3.70658 5.21581,-2.13963 6.58129,-4.00661 4.13751,-5.22526 8.71045,-10.6973 15.46775,-11.70943 23.47019,11.51183 4.95807,53.52213 -7.38173,69.56625 -2.96662,1.08371 -3.3928,5.63346 0.39318,3.24811 2.72226,-2.88561 4.94975,-6.21487 7.34029,-9.38155 7.81866,-10.91748 14.63407,-23.14975 16.36615,-36.65902 0.96247,-9.46965 -1.36595,-19.63148 -7.744,-26.88833 -1.69596,-1.60344 -3.90514,-2.71498 -6.24843,-2.90365 z"
       id="path3983"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 173.50342,433.53801 c -6.64018,1.71703 -12.78906,4.71331 -19.375,6.90625 -6.58594,2.19294 -8.95925,9.29645 -9.18372,15.16424 -0.28723,19.40399 6.0012,38.67501 16.22436,55.05291 3.44281,4.77657 7.56075,10.1262 13.53134,11.56021 7.06377,-1.9329 13.96756,-5.48929 21.1851,-7.69655 7.66309,-2.24602 8.40378,-11.60922 8.53962,-18.31538 1.07814,-3.88472 0.2826,-11.6275 -0.0206,-11.42206 9.28736,-6.00425 26.82969,-17.7654 26.82969,-17.7654 l -1.53709,-5.90154 c 0,0 -17.49503,15.71535 -25.98803,21.20357 -1.74479,-9.27156 -5.95926,-21.4481 -10.09708,-29.91625 11.57292,-1.98958 32.36842,-2.27657 32.36842,-2.27657 l -0.99807,-5.52499 c 0,0 -22.02759,3.76687 -33.04139,5.65031 -4.22303,-6.87879 -9.39534,-16.19312 -18.4375,-16.71875 z m 0.125,4.0625 c 8.98006,1.80174 14.82568,9.93149 20.11334,20.37764 5.28765,10.44614 9.02958,23.36395 6.44542,42.82809 -2.12211,11.15785 -8.40797,9.93093 -17.54397,11.47344 3.51735,-13.87746 -0.12741,-25.69303 -4.30968,-38.96465 -4.10672,-11.2362 -8.85386,-22.33624 -18.29719,-30.08785 4.71734,-1.64181 8.80322,-4.28728 13.59208,-5.62667 z m -3.60478,22.67535 c 9.45039,15.21451 11.91973,34.83653 8.77196,48.32733 -1.63899,8.31575 -10.86109,9.32636 -13.91442,3.51622 -9.33884,-10.77861 -13.08354,-24.96978 -16.89044,-38.37677 -1.30571,-7.99454 -2.44581,-14.66362 1.63545,-22.12058 7.29725,-7.38359 17.2425,3.18162 20.39745,8.6538 z"
       id="path3993"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 294.28587,415.9697 c 3.03567,-17.77234 21.42812,-46.73626 40.24226,-57.24153"
       id="path3874"
       style="fill:none;stroke:none;display:inline" />
    <path
       d="m 360.43491,353.09465 c 17.37036,-3.86008 48.73351,10.13271 55.97116,22.67797"
       id="path3910"
       style="fill:none;stroke:none;display:inline" />
    <path
       d="m 73.87848,228.97715 c 26.14162,2.27318 79.56144,11.36592 102.29328,25.00503"
       id="path3951"
       style="fill:none;stroke:#000000;stroke-width:10;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none" />
    <path
       d="m 126.16171,132.36683 c 31.82458,15.91228 73.87848,63.64915 80.69803,81.83462"
       id="path3953"
       style="fill:none;stroke:#000000;stroke-width:10;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none" />
    <path
       d="m 227.31841,95.995884 c 12.50251,32.961166 18.18547,71.605296 17.04888,98.883506"
       id="path3955"
       style="fill:none;stroke:#000000;stroke-width:10;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none" />
    <g
       id="g3113"
       style="display:inline">
      <path
         d="m 383.82523,391.43373 c -16.21685,2.11004 -25.60279,-29.48478 -5.89798,-30.40585 20.03131,-0.18878 19.893,27.17753 5.89798,30.40585 z"
         id="path3062"
         style="fill:#000000;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 387.14325,374.59163 c -3.52101,0.58011 -10.63798,-4.58146 -7.15694,-8.08713 4.39195,-4.77207 10.69827,6.10025 7.15694,8.08713 z"
         id="path3880"
         style="fill:#ffffff;fill-opacity:1;stroke:none;display:inline" />
    </g>
    <path
       d="m 369.78125,336.78125 c -0.50761,0.0147 -0.77595,0.29338 -0.84375,0.875 -0.0961,0.95372 -0.1759,2.82013 -0.1875,5.5625 l -0.9375,-0.65625 c -0.41679,-0.22232 -0.99511,-0.3344 -1.75,-0.3125 -1.47074,0.0427 -2.63756,0.61296 -3.53125,1.6875 -0.88718,1.07437 -1.3004,2.48121 -1.25,4.21875 0.0417,1.4382 0.53105,2.60886 1.46875,3.5 0.9111,0.87238 2.0279,1.2891 3.375,1.25 0.54664,-0.0159 1.06651,-0.12225 1.5625,-0.3125 0.31929,-0.121 0.63596,-0.27989 0.9375,-0.46875 l -0.4375,-2 c -0.31967,0.27296 -0.58526,0.50033 -0.75,0.59375 -0.3716,0.21269 -0.82836,0.32785 -1.375,0.34375 -0.80045,0.0232 -1.50874,-0.2559 -2.125,-0.84375 -0.60976,-0.58803 -0.9131,-1.31676 -0.9375,-2.15625 -0.0378,-1.30153 0.1908,-2.27737 0.71875,-2.9375 0.52776,-0.66662 1.34421,-0.99955 2.4375,-1.03125 0.57267,-0.0166 1.08227,0.0888 1.5,0.34375 0.41753,0.24842 0.73741,0.63631 1,1.15625 l 0.0312,1.15625 0.0312,1.125 0.0625,1.6875 c -0.0785,0.10721 -0.16551,0.19997 -0.25,0.28125 l 0.40625,2.0625 c 0.0629,-0.0455 0.12541,-0.0765 0.1875,-0.125 0.20571,0.58021 0.50277,0.85545 0.90625,0.84375 0.24078,-0.007 0.44768,-0.10676 0.625,-0.28125 0.17733,-0.17448 0.28925,-0.39594 0.28125,-0.65625 -0.002,-0.0586 -0.0156,-0.12805 -0.0312,-0.21875 -0.23385,-1.10045 -0.3746,-2.73919 -0.4375,-4.90625 -0.0277,-0.95662 -0.019,-1.9161 0.0312,-2.875 0.17056,-3.09869 0.24495,-5.09542 0.21875,-6 -0.0183,-0.63123 -0.34531,-0.92345 -0.9375,-0.90625 z"
       id="path3939"
       style="font-size:20px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;display:inline;font-family:Comic Sans MS;-inkscape-font-specification:Comic Sans MS" />
    <path
       d="m 377.87926,354.16866 c -1.44101,-0.29733 -2.5335,-0.89834 -3.27748,-1.80303 -0.8111,-0.9983 -1.06863,-2.21476 -0.77262,-3.64939 0.34206,-1.65778 1.03056,-2.96488 2.0655,-3.92131 1.12612,-1.04397 2.41925,-1.41531 3.87938,-1.11404 1.05843,0.2184 1.88555,0.5752 2.48137,1.07039 0.73173,0.60967 1.00354,1.3704 0.81541,2.28217 -0.13157,0.63762 -0.61154,1.14351 -1.43991,1.51768 -0.36618,0.16376 -1.11572,0.38137 -2.24863,0.65282 l -4.01069,0.97726 c 0.24786,0.60289 0.60877,1.09283 1.08273,1.46982 0.48034,0.37831 1.07438,0.64048 1.78213,0.78652 0.43994,0.0908 0.97351,0.11445 1.6007,0.071 0.79579,-0.0552 1.33694,-0.22935 1.62347,-0.52255 0.28782,-0.29958 0.55607,-0.42371 0.80475,-0.3724 0.22315,0.046 0.40305,0.17291 0.53969,0.38058 0.14431,0.20262 0.19345,0.41551 0.14742,0.63867 -0.14605,0.70775 -0.84235,1.19892 -2.08891,1.47351 -1.06502,0.23228 -2.05978,0.25304 -2.98431,0.0623 m 1.53956,-8.76623 c -0.77789,-0.1605 -1.48755,0.009 -2.12899,0.50799 -0.64014,0.49279 -1.21271,1.3186 -1.71772,2.47743 l 3.22431,-0.79052 c 1.26984,-0.32296 2.19301,-0.64102 2.76949,-0.95417 -0.4431,-0.62322 -1.1588,-1.0368 -2.14709,-1.24073"
       id="path3941"
       style="font-size:20px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;display:inline;font-family:Comic Sans MS;-inkscape-font-specification:Comic Sans MS" />
    <path
       d="m 388.35338,357.20098 c -0.93516,-0.34306 -1.71748,-0.83809 -2.34695,-1.4851 -0.30322,0.22163 -0.59541,0.28088 -0.87656,0.17774 -0.23226,-0.0852 -0.40064,-0.24059 -0.50512,-0.46616 -0.10062,-0.21721 -0.10609,-0.44806 -0.0164,-0.69255 0.0583,-0.15891 0.15074,-0.39199 0.27732,-0.69922 0.13268,-0.30499 0.22818,-0.53694 0.28648,-0.69586 0.23767,-0.64788 0.57473,-1.62338 1.01116,-2.92649 0.44479,-1.30698 0.78602,-2.28441 1.0237,-2.9323 0.16368,-0.44617 0.47616,-1.28852 0.93745,-2.52705 0.46352,-1.24462 0.77824,-2.09308 0.94417,-2.54539 0.13453,-0.36671 0.33201,-0.66874 0.59245,-0.90608 0.33846,-0.29883 0.68495,-0.38323 1.03946,-0.2532 0.4584,0.16818 0.59007,0.51814 0.39501,1.04989 -0.0314,0.0856 -0.0926,0.20527 -0.18374,0.35907 -0.0911,0.15383 -0.15236,0.27352 -0.18374,0.35908 l -0.76407,1.99774 -0.87599,2.33116 c 0.66404,-0.16553 1.26695,-0.24948 1.80872,-0.25185 0.55012,-0.006 1.03605,0.068 1.45779,0.22273 1.3141,0.48208 2.19568,1.3776 2.64475,2.68655 0.42257,1.2299 0.38049,2.53552 -0.12624,3.91685 -0.51124,1.39357 -1.39435,2.41146 -2.64933,3.05368 -1.255,0.64222 -2.55177,0.7178 -3.89032,0.22676 m 3.38548,-8.15106 c -0.50121,-0.18385 -1.06619,-0.23162 -1.69497,-0.1433 -0.30829,0.0464 -0.85935,0.18752 -1.65319,0.42333 l -0.60019,1.57937 -0.51551,1.4336 -0.54242,1.50694 c 0.24405,0.24209 0.59383,0.56458 1.04936,0.96747 0.33634,0.25515 0.73983,0.46905 1.21047,0.6417 0.88625,0.32512 1.72795,0.28022 2.52509,-0.13469 0.79712,-0.4149 1.3661,-1.08688 1.70692,-2.01592 0.33408,-0.91071 0.38403,-1.75575 0.14986,-2.53513 -0.25293,-0.84172 -0.79807,-1.41618 -1.63542,-1.72337"
       id="path3943"
       style="font-size:20px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;display:inline;font-family:Comic Sans MS;-inkscape-font-specification:Comic Sans MS" />
    <path
       d="m 404.99417,358.17581 c -0.21715,0.41542 -0.53998,1.04006 -0.96848,1.87392 -0.42852,0.83386 -0.75135,1.4585 -0.96848,1.87393 -0.0664,0.12693 -0.15873,0.32474 -0.27713,0.59343 -0.11264,0.2717 -0.20213,0.47102 -0.26847,0.59796 -0.12969,0.24809 -0.31891,0.40631 -0.56765,0.47463 -0.25178,0.0741 -0.49883,0.0478 -0.74115,-0.0788 -0.44428,-0.23223 -0.58374,-0.65407 -0.4184,-1.26553 -0.91725,-0.002 -1.84611,-0.24871 -2.78658,-0.74029 -0.75584,-0.39508 -1.2944,-0.88962 -1.61568,-1.48363 -0.35511,-0.65577 -0.39912,-1.36564 -0.13203,-2.12961 0.57418,-1.6466 1.17341,-3.06707 1.7977,-4.26142 0.41316,-0.79045 0.97018,-1.64529 1.67105,-2.56453 0.34315,-0.45974 0.74841,-0.56747 1.21576,-0.3232 0.2481,0.12969 0.41359,0.31904 0.49647,0.56805 0.0859,0.24325 0.064,0.48892 -0.0657,0.73701 -0.13873,0.26542 -0.40367,0.66687 -0.79481,1.20438 -0.38539,0.54053 -0.65799,0.96369 -0.81783,1.26948 -0.50365,0.96355 -0.90318,1.80522 -1.1986,2.52499 -0.29542,0.71978 -0.48823,1.32055 -0.57844,1.80232 0.13612,0.20338 0.28141,0.38217 0.43589,0.53638 0.15749,0.14843 0.32566,0.26939 0.50453,0.36289 0.77314,0.40412 1.6544,0.70681 2.64379,0.90808 l 0.90967,-1.76142 0.8603,-1.68805 c 0.65141,-1.24627 1.2717,-2.29944 1.86086,-3.15954 0.34091,-0.49764 0.75947,-0.61678 1.25568,-0.35742 0.24809,0.12969 0.41358,0.31903 0.49647,0.56804 0.0829,0.24902 0.0552,0.49167 -0.083,0.72797 l -1.86577,3.19003"
       id="path3945"
       style="font-size:20px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;display:inline;font-family:Comic Sans MS;-inkscape-font-specification:Comic Sans MS" />
    <path
       d="m 413.41942,365.86219 -2.13296,2.50351 c -0.80618,1.02324 -1.54682,1.79933 -2.22193,2.32828 -0.86304,0.67332 -1.7027,1.01968 -2.519,1.03907 -0.98816,0.0217 -2.07613,-0.40706 -3.2639,-1.28642 -0.69591,-0.51523 -1.24447,-0.99426 -1.64566,-1.43709 -0.56244,-0.61893 -0.69064,-1.13507 -0.38461,-1.54843 0.34478,-0.46569 0.74478,-0.53002 1.2,-0.19299 0.18837,0.13946 0.46939,0.41636 0.84306,0.83073 0.3698,0.41958 0.82542,0.82171 1.36688,1.20639 1.01625,0.72808 2.06982,0.75475 3.16071,0.08 0.72377,-0.45242 1.58355,-1.33472 2.57934,-2.64691 -0.66994,0.31406 -1.29798,0.45663 -1.8841,0.42771 -0.5809,-0.025 -1.1225,-0.22351 -1.62482,-0.5954 -0.94707,-0.70118 -1.48062,-1.59437 -1.60063,-2.67958 -0.11091,-1.08657 0.21522,-2.14526 0.97837,-3.17605 1.04595,-1.41276 2.29403,-2.25059 3.74426,-2.5135 1.49574,-0.26969 2.96569,0.13005 4.40986,1.19924 0.48661,0.36027 0.84825,0.72522 1.08494,1.09485 0.23665,0.36964 0.34835,0.74395 0.33509,1.12295 0.54824,0.4302 0.59768,0.94878 0.14832,1.55575 -0.27506,0.3715 -0.69801,0.82791 -1.26888,1.36922 -0.65495,0.63298 -1.08973,1.07253 -1.30434,1.31866 m -0.003,-5.26375 c -0.99417,-0.73603 -2.01708,-0.96277 -3.06873,-0.6802 -0.94374,0.25716 -1.76813,0.86189 -2.47317,1.81419 -0.56172,0.75871 -0.84008,1.43558 -0.83508,2.03061 0.005,0.59503 0.29527,1.10561 0.87084,1.53174 0.52848,0.39126 1.26207,0.47265 2.20078,0.24417 0.85674,-0.21625 1.51601,-0.57061 1.97782,-1.06306 0.52825,-0.48376 1.3026,-1.2835 2.32306,-2.39922 -0.0892,-0.31716 -0.21727,-0.59827 -0.38415,-0.84334 -0.16689,-0.24506 -0.37068,-0.45669 -0.61137,-0.63489"
       id="path3947"
       style="font-size:20px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;display:inline;font-family:Comic Sans MS;-inkscape-font-specification:Comic Sans MS" />
    <g
       transform="translate(-62.268955,13.571837)"
       id="g3117"
       style="display:inline">
      <path
         d="m 383.82523,391.43373 c -16.21685,2.11004 -25.60279,-29.48478 -5.89798,-30.40585 20.03131,-0.18878 19.893,27.17753 5.89798,30.40585 z"
         id="path3119"
         style="fill:#000000;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 387.14325,374.59163 c -3.52101,0.58011 -10.63798,-4.58146 -7.15694,-8.08713 4.39195,-4.77207 10.69827,6.10025 7.15694,8.08713 z"
         id="path3121"
         style="fill:#ffffff;fill-opacity:1;stroke:none;display:inline" />
    </g>
    <g
       id="text3123"
       style="font-size:20px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;display:inline;font-family:Comic Sans MS;-inkscape-font-specification:Comic Sans MS">
      <path
         d="m 278.01153,401.19032 c -0.004,0.31248 -0.11741,0.58136 -0.3414,0.80664 -0.22396,0.22529 -0.49219,0.33612 -0.80469,0.3325 -0.31246,-0.004 -0.57805,-0.12064 -0.79676,-0.35106 -0.21869,-0.23041 -0.32623,-0.50186 -0.32262,-0.81434 0.004,-0.31247 0.1174,-0.5781 0.34129,-0.79688 0.22399,-0.22528 0.49222,-0.33611 0.80469,-0.33249 0.31249,0.004 0.57808,0.12064 0.79677,0.35105 0.21878,0.22391 0.32636,0.4921 0.32272,0.80458 m 7.93425,-0.34753 c 0.3906,0.005 0.97662,0.002 1.75804,-0.009 0.77499,-0.0171 1.35778,-0.0233 1.74838,-0.0188 0.28644,0.003 0.51978,0.0939 0.70002,0.2718 0.18024,0.17789 0.2687,0.41005 0.26538,0.69648 -0.003,0.27994 -0.0971,0.50998 -0.28145,0.69015 -0.18432,0.17366 -0.41969,0.25883 -0.70613,0.2555 -0.3906,-0.005 -0.97339,0.002 -1.74839,0.0188 -0.78142,0.0105 -1.36743,0.0135 -1.75803,0.009 -0.61193,-0.007 -1.37322,-0.0485 -2.28387,-0.12413 -0.91715,-0.0757 -1.68169,-0.11715 -2.29364,-0.12424 -0.29294,-0.003 -0.52953,-0.094 -0.70978,-0.27192 -0.18016,-0.18439 -0.26862,-0.41655 -0.26539,-0.69648 0.003,-0.27993 0.097,-0.50672 0.28134,-0.68038 0.1844,-0.18016 0.42308,-0.26855 0.71602,-0.26516 0.61194,0.007 1.37649,0.0485 2.29363,0.12425 0.91065,0.0757 1.67194,0.11704 2.28387,0.12413"
         id="path3920" />
      <path
         d="m 287.58075,388.94364 3.20086,0.75603 c 1.27833,0.25063 2.30683,0.55568 3.0855,0.91516 0.99289,0.46084 1.68415,1.05004 2.07378,1.76761 0.47014,0.86944 0.58486,2.03322 0.34416,3.49135 -0.14103,0.85432 -0.31708,1.561 -0.52813,2.12002 -0.29419,0.78285 -0.69502,1.13239 -1.20247,1.04862 -0.57169,-0.0944 -0.81141,-0.42098 -0.71916,-0.97982 0.0382,-0.23125 0.1564,-0.60764 0.35467,-1.12919 0.20469,-0.52048 0.35469,-1.10938 0.45,-1.7667 0.18432,-1.23649 -0.27257,-2.18621 -1.37065,-2.84918 -0.73277,-0.43768 -1.91014,-0.8003 -3.5321,-1.08785 0.58509,0.45291 0.99846,0.94675 1.24011,1.48153 0.2427,0.52836 0.31316,1.10086 0.21137,1.71751 -0.19193,1.16266 -0.74338,2.04491 -1.65435,2.64676 -0.91633,0.59437 -2.00721,0.7871 -3.27264,0.57821 -1.73433,-0.28629 -3.04926,-1.01474 -3.94479,-2.18535 -0.92232,-1.20801 -1.23716,-2.69846 -0.94451,-4.47135 0.0986,-0.59737 0.25842,-1.08568 0.47937,-1.46492 0.22098,-0.37922 0.50312,-0.64937 0.84643,-0.81046 0.13274,-0.68412 0.57167,-0.96469 1.31678,-0.8417 0.45608,0.0753 1.05517,0.24348 1.7973,0.50455 0.86205,0.29408 1.45154,0.48047 1.76847,0.55917 m -4.68262,2.4042 c -0.20146,1.22047 0.0634,2.23418 0.7946,3.04112 0.65936,0.72251 1.57358,1.18026 2.74265,1.37324 0.9314,0.15376 1.66072,0.0927 2.18796,-0.1832 0.52723,-0.27588 0.84917,-0.76711 0.96581,-1.4737 0.10709,-0.64877 -0.15513,-1.33871 -0.78667,-2.06983 -0.58327,-0.66375 -1.19936,-1.08878 -1.84826,-1.27508 -0.67146,-0.24941 -1.73638,-0.57367 -3.19476,-0.97278 -0.24154,0.22407 -0.43328,0.46626 -0.57524,0.72656 -0.14194,0.26031 -0.2373,0.5382 -0.28609,0.83367"
         id="path3922" />
      <path
         d="m 295.81445,380.39356 c -0.20482,0.5211 -0.60511,0.70303 -1.20087,0.5458 l -2.09046,-0.52787 c -0.74226,-0.19381 -1.42241,-0.41218 -2.04045,-0.65511 -0.16966,-0.0667 -0.45389,-0.18889 -0.85271,-0.36664 -0.39644,-0.1838 -0.67949,-0.30904 -0.84915,-0.37574 -1.30877,-0.51441 -2.05843,-0.52926 -2.24896,-0.0445 -0.26673,0.67863 -0.11863,1.48534 0.44431,2.42012 0.51406,0.84562 1.26964,1.64627 2.26674,2.40193 0.23154,0.10501 0.51772,0.24897 0.85854,0.4319 0.28867,0.15543 0.5754,0.28912 0.86018,0.40105 0.18177,0.0715 0.46158,0.16045 0.83942,0.26698 0.37784,0.10655 0.65764,0.19554 0.83942,0.26699 0.27266,0.10717 0.46048,0.27893 0.56345,0.51527 0.10535,0.23028 0.10683,0.47569 0.004,0.73624 -0.10479,0.2666 -0.27417,0.44836 -0.50813,0.54527 -0.23396,0.0969 -0.48727,0.0918 -0.75993,-0.0154 -0.18177,-0.0714 -0.46277,-0.15741 -0.84299,-0.25789 -0.37784,-0.10654 -0.65765,-0.19554 -0.83943,-0.26699 -0.62409,-0.2453 -1.47085,-0.62709 -2.54028,-1.14537 -1.0731,-0.52672 -1.92169,-0.91273 -2.54579,-1.15804 -0.19389,-0.0762 -0.48646,-0.17721 -0.87772,-0.30302 -0.38887,-0.13186 -0.68025,-0.2359 -0.87415,-0.31211 -0.26054,-0.10241 -0.43927,-0.27059 -0.53619,-0.50455 -0.10058,-0.2424 -0.10086,-0.49084 -8.4e-4,-0.74533 0.21911,-0.55744 0.73323,-0.70862 1.54235,-0.45356 l 1.0741,0.39071 c -0.95714,-1.55141 -1.22494,-2.86336 -0.80341,-3.93584 0.38107,-0.96945 1.07379,-1.47715 2.07816,-1.52308 0.67198,-0.0367 1.57017,0.15199 2.69458,0.56595 l 0.91796,0.36082 0.84168,0.34132 c 0.50291,0.19768 1.17928,0.39008 2.02911,0.5772 0.84614,0.1787 1.51764,0.36569 2.01449,0.56097 0.2666,0.1048 0.44717,0.2772 0.5417,0.51721 0.10297,0.23635 0.10325,0.48479 8.5e-4,0.74533"
         id="path3924" />
      <path
         d="m 299.07422,374.76692 c -0.62007,0.90101 -1.48592,1.44714 -2.59754,1.6384 -1.23838,0.21467 -2.49528,-0.0892 -3.77072,-0.91165 -1.2342,-0.80196 -2.09108,-1.84214 -2.57063,-3.12055 -0.57197,-1.50008 -0.3966,-2.92051 0.52611,-4.26129 0.73819,-1.07261 1.78808,-1.5474 3.14969,-1.42438 1.09639,0.10649 2.19681,0.55163 3.30126,1.33541 1.17953,0.83548 1.98177,1.84597 2.40671,3.03146 0.48219,1.34346 0.3339,2.58099 -0.44488,3.7126 m -6.85169,-5.42663 c -0.54792,0.78469 -0.59511,1.65713 -0.14157,2.61731 0.36613,0.76568 0.93801,1.4161 1.71566,1.95128 0.77765,0.53518 1.52947,0.74041 2.25546,0.61569 0.60292,-0.10667 1.06863,-0.39867 1.39712,-0.87599 0.38385,-0.55776 0.51039,-1.17801 0.37962,-1.86075 -0.13678,-0.76589 -0.5794,-1.42615 -1.32787,-1.98077 -2.02384,-1.50345 -3.44998,-1.65904 -4.27842,-0.46677"
         id="path3926" />
      <path
         d="m 303.81639,358.55285 c 0.49616,0.64668 0.51473,1.16744 0.0557,1.56227 -0.42446,0.36514 -0.84685,0.30339 -1.26717,-0.18525 -0.0807,-0.0938 -0.23667,-0.26014 -0.468,-0.49913 l -0.55716,-0.60278 c -0.69916,0.7646 -1.13458,1.5213 -1.30627,2.27012 -0.1633,0.69868 -0.11246,1.49655 0.15252,2.3936 l 3.50471,4.04432 c 0.42881,0.4985 0.3989,0.9579 -0.0897,1.37822 -0.43433,0.37362 -0.8659,0.31118 -1.29471,-0.18732 l -4.47065,-5.19718 c -0.1401,-0.16287 -0.34533,-0.41143 -0.61567,-0.74568 -0.2654,-0.33848 -0.46816,-0.58916 -0.60827,-0.75204 -0.4288,-0.49849 -0.42604,-0.93454 0.008,-1.30816 0.48369,-0.41607 1.08039,-0.21657 1.7901,0.59848 0.16219,-1.72823 0.82075,-3.0891 1.97568,-4.08259 0.39978,-0.34388 0.82788,-0.4502 1.28429,-0.31897 0.4564,0.13126 0.94571,0.50042 1.46793,1.10749 0.22077,0.25666 0.3669,0.43153 0.43838,0.5246"
         id="path3928" />
      <path
         d="m 314.72609,361.73699 c -1.4006,0.45078 -2.64741,0.46564 -3.74042,0.0446 -1.19752,-0.46949 -2.02068,-1.40144 -2.46946,-2.79585 -0.5186,-1.6113 -0.56299,-3.08798 -0.13317,-4.43004 0.46607,-1.46314 1.4087,-2.4231 2.8279,-2.87987 1.02875,-0.33109 1.92434,-0.42784 2.68676,-0.29023 0.93708,0.17032 1.54824,0.69859 1.83347,1.5848 0.19946,0.61974 0.0308,1.2964 -0.50592,2.02996 -0.23807,0.32284 -0.78329,0.88132 -1.63566,1.67544 l -3.00955,2.82548 c 0.5126,0.40269 1.06798,0.6514 1.66614,0.74613 0.60434,0.0927 1.25047,0.0284 1.93838,-0.19299 0.42761,-0.13762 0.90366,-0.37975 1.42816,-0.72638 0.66546,-0.43987 1.05069,-0.85795 1.1557,-1.25423 0.10299,-0.40247 0.27534,-0.6426 0.51704,-0.72039 0.2169,-0.0698 0.43595,-0.048 0.65714,0.0655 0.22537,0.10529 0.37297,0.26638 0.44279,0.48329 0.22139,0.68791 -0.14279,1.45827 -1.09253,2.31109 -0.81257,0.72659 -1.66816,1.2345 -2.56677,1.52371 m -2.97661,-8.38789 c -0.75608,0.24335 -1.29037,0.74018 -1.60286,1.49048 -0.3145,0.74412 -0.4062,1.74481 -0.27512,3.00209 l 2.41706,-2.27573 c 0.94619,-0.90639 1.59306,-1.63779 1.94061,-2.19421 -0.69254,-0.32424 -1.51911,-0.33178 -2.47969,-0.0226"
         id="path3930" />
    </g>
    <path
       d="m 290.40777,404.55609 c -1.08771,-28.21421 19.13629,-46.2628 31.15772,-43.81633"
       id="path3127"
       style="fill:none;stroke:none;display:inline" />
    <path
       d="m 334.85871,471.90664 c 22.09833,22.55316 73.03198,-14.07951 61.87955,-35.42181 -22.37273,-23.56261 -73.54093,13.10288 -61.87955,35.42181 z m 56.94508,-31.76067 c 5.94677,25.38584 -43.38364,49.44349 -50.36008,27.27433 4.03829,-36.35783 39.46042,-43.95021 50.36008,-27.27433 z"
       id="path3132"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:6;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 370.65674,433.66325 c 9.58134,7.09729 13.24351,13.4786 13.24351,13.4786 l -18.20983,9.57777 c 0,0 -1.29878,-10.28392 -6.62175,-15.60689"
       id="path3860"
       style="fill:#ffffff;stroke:none;display:inline" />
    <path
       d="m 376.092,429.58538 -2.02651,2.31628 c 7.27847,5.39146 9.69439,11.42736 10.94601,13.27843 -1.74245,2.78791 -5.82848,5.8873 -12.1013,7.10701 -1.22865,-4.86627 -3.42403,-10.3388 -8.16195,-15.07672 l -2.84375,2.84375 c 4.20806,4.76518 5.66243,11.12783 6.40625,17.28125 9.23488,-3.94943 16.20137,-7.69362 22.625,-11.875 -4.86781,-7.22335 -9.62694,-11.93673 -14.84375,-15.875 z"
       id="path3858"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
  </g>
</svg>
'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
frankSVG
	^'<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   version="1.1"
   width="765"
   height="990"
   id="svg2"
   style="display:inline">
  <defs
     id="defs4" />
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     id="layer4"
     style="display:inline">
    <g
       transform="translate(-2,1)"
       id="g4108">
      <path
         d="m 304.30761,696.4311 c 25.20419,4.34555 34.63366,-12.47834 49.16057,-1.96844 22.10285,24.59299 -8.65078,71.55862 -39.34017,76.72688 -32.95883,0.42333 -92.76455,-36.74782 -99.71743,-58.47557 -6.95288,-21.72775 11.87057,-31.69663 11.87057,-31.69663"
         id="path3838"
         style="fill:#545454;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 339.21454,757.93887 c -3.77101,0.39454 -7.92923,0.63499 -12.4375,0.65625 -4.64442,0.0219 -9.64284,-0.17342 -14.875,-0.6875 -5.23216,-0.51408 -10.69024,-1.33931 -16.3125,-2.53125 -2.81113,-0.59597 -5.65965,-1.30171 -8.53125,-2.09375 -2.8716,-0.79204 -5.78014,-1.68166 -8.6875,-2.6875 -2.90736,-1.00584 -5.83157,-2.10636 -8.75,-3.34375 -2.91843,-1.23739 -5.81397,-2.60709 -8.71875,-4.09375 -2.90478,-1.48666 -5.82106,-3.09007 -8.6875,-4.84375 -2.86644,-1.75368 -5.69661,-3.64908 -8.5,-5.6875 -2.80339,-2.03842 -5.56562,-4.22159 -8.28125,-6.5625 -2.71563,-2.34091 -5.39683,-4.83887 -8,-7.5 -2.60318,-2.66113 -5.12774,-5.50092 -7.59375,-8.5 -2.29532,-2.79149 -4.50043,-5.77589 -6.65625,-8.875 -0.31777,3.42373 -0.17437,7.17777 1.21875,11.53125 6.95288,21.72775 66.75992,58.89208 99.71875,58.46875 8.77868,-1.47838 17.54321,-6.43349 25.09375,-13.25 z"
         id="path3836"
         style="fill:#beb6be;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 237.9493,679.57472 c -14.05123,0.59622 -24.62122,6.10017 -25.5,20.59375 2.00574,2.84701 4.03163,5.63485 6.15625,8.21875 2.46601,2.99908 5.02183,5.80762 7.625,8.46875 2.60317,2.66113 5.25312,5.15909 7.96875,7.5 2.71563,2.34091 5.50911,4.52408 8.3125,6.5625 2.80339,2.03842 5.63356,3.93382 8.5,5.6875 0.31876,0.19502 0.64952,0.33921 0.96875,0.53125 0.27835,-0.4516 0.4858,-0.88977 0.78125,-1.34375 1.17666,-1.80803 2.48386,-3.64044 3.90625,-5.46875 1.42239,-1.82831 2.96619,-3.64803 4.59375,-5.46875 3.25512,-3.64145 6.85509,-7.24363 10.6875,-10.6875 3.83241,-3.44387 7.88357,-6.75793 11.96875,-9.78125 4.08518,-3.02332 8.20532,-5.77645 12.21875,-8.15625 1.62098,-0.96118 3.08413,-1.54433 4.65625,-2.375 -13.76714,-5.53928 -41.7989,-15.17422 -62.84375,-14.28125 z"
         id="path4289"
         style="fill:#262626;fill-opacity:1;stroke:none;display:inline" />
      <path
         d="m 253.08895,737.70721 c -0.31182,-0.187 -0.62612,-0.34075 -0.9375,-0.53125 -2.86644,-1.75368 -5.72786,-3.64908 -8.53125,-5.6875 -2.80339,-2.03842 -5.56562,-4.22159 -8.28125,-6.5625 -2.71563,-2.34091 -5.36558,-4.83887 -7.96875,-7.5 -2.60317,-2.66113 -5.15899,-5.46967 -7.625,-8.46875 -2.29532,-2.79149 -4.50042,-5.77589 -6.65625,-8.875 -0.31281,3.41626 -0.13897,7.15947 1.25,11.5 3.1513,9.8478 17.33573,22.77822 34.78125,34.03125 0.48819,-1.28508 0.98525,-2.57994 1.65625,-3.90625 0.66623,-1.31687 1.48311,-2.65421 2.3125,-4 z"
         id="path4311"
         style="fill:#7f707f;fill-opacity:1;stroke:none;display:inline" />
    </g>
  </g>
  <g
     id="layer3"
     style="display:inline">
    <path
       d="m 325.3141,612.02947 c -0.86911,22.59686 -8.6911,79.95812 -27.81152,105.16231 -20.85864,5.21466 -64.31414,-12.16754 -84.30367,-58.23037 13.03665,0 50.40838,4.34555 66.05236,-38.24084"
       id="path4259"
       style="fill:#2274a8;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 324.17352,611.45238 -46.0625,8.6875 c -15.64398,42.58639 -52.9946,38.25 -66.03125,38.25 11.34939,26.15295 30.26481,43.037 48.3125,51.8125 -0.0642,-0.3645 -0.19409,-0.72952 -0.25,-1.09375 -0.34646,-2.25687 -0.52773,-4.48189 -0.5625,-6.71875 -0.0348,-2.23686 0.0798,-4.45568 0.34375,-6.65625 0.26395,-2.20057 0.66906,-4.38325 1.21875,-6.53125 0.54969,-2.148 1.24003,-4.2646 2.0625,-6.34375 0.82247,-2.07915 1.79272,-4.13098 2.875,-6.125 1.08228,-1.99402 2.26463,-3.95114 3.59375,-5.84375 1.32912,-1.89261 2.78076,-3.72508 4.34375,-5.5 1.56299,-1.77492 3.24736,-3.48406 5.03125,-5.125 1.78389,-1.64094 3.66444,-3.19681 5.65625,-4.6875 1.99181,-1.49069 4.09448,-2.92585 6.28125,-4.25 2.18677,-1.32415 4.47499,-2.54617 6.84375,-3.6875 2.36876,-1.14133 4.80597,-2.18276 7.34375,-3.125 2.53778,-0.94224 5.18117,-1.80439 7.875,-2.53125 2.66261,-0.71843 5.38503,-1.28905 8.1875,-1.78125 1.69092,-11.50047 2.67169,-21.83882 2.9375,-28.75 z"
       id="path4263"
       style="fill:#1f4d6e;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 468.60605,544.46185 c 0,0 43.74988,14.00935 69.83138,27.05011 -26.68548,33.79314 -36.63487,35.86845 -48.19902,64.97606 -18.25131,-14.77487 -49.87638,-53.38736 -53.35282,-67.29312 z"
       id="path4247"
       style="fill:#2e76a8;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 461.54734,549.8325 -24.09375,18.8125 c 3.47644,13.90576 35.09244,52.50638 53.34375,67.28125 2.80592,-7.06265 5.52832,-12.49984 8.40625,-17.21875 -0.12043,-0.0857 -0.22269,-0.10011 -0.34375,-0.1875 -2.80587,-2.02548 -5.78773,-4.50477 -8.78125,-7.34375 -2.99352,-2.83898 -6.01208,-6.06234 -8.90625,-9.5625 -2.89417,-3.50016 -5.64841,-7.27223 -8.15625,-11.28125 -1.25392,-2.00451 -2.45897,-4.08434 -3.5625,-6.1875 -1.10353,-2.10316 -2.11399,-4.22348 -3.03125,-6.40625 -0.91726,-2.18277 -1.74238,-4.41291 -2.4375,-6.65625 -0.69512,-2.24334 -1.25039,-4.52763 -1.6875,-6.8125 -0.43711,-2.28487 -0.73178,-4.56764 -0.875,-6.875 -0.14322,-2.30736 -0.15529,-4.62669 0.0312,-6.9375 0.0169,-0.20885 0.074,-0.4162 0.0937,-0.625 z"
       id="path4257"
       style="fill:#1f4d6e;fill-opacity:1;stroke:none;display:inline" />
  </g>
  <g
     id="layer9"
     style="display:inline">
    <path
       d="m 529.1073,646.00139 c -7.66517,-11.73554 -9.12157,-36.11847 -7.38335,-55.23889 1.73822,-19.12042 -12.43166,-36.03456 -9.56293,-59.47001 2.60733,-21.30001 79.41212,-36.0343 93.8775,-14.34168 21.70868,32.55485 -5.38709,65.94984 -10.00158,82.53275 -5.27456,18.95502 -13.00264,50.785 -21.27548,53.89845 -14.96516,5.63209 -39.38288,2.22083 -45.65416,-7.38062 z"
       id="path3829"
       style="fill:#525252;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 570.66428,506.32846 c -2.77944,0.0945 -5.60011,0.31839 -8.4375,0.625 -3.46554,1.02883 -6.34042,2.1338 -8.71875,3.375 -1.18916,0.6206 -2.23619,1.28649 -3.1875,1.96875 -0.95131,0.68226 -1.79516,1.40662 -2.53125,2.15625 -0.73609,0.74963 -1.36275,1.52104 -1.90625,2.34375 -0.5435,0.82271 -1.00146,1.69225 -1.375,2.59375 -0.74709,1.803 -1.17194,3.75382 -1.375,5.90625 -0.20306,2.15243 -0.19116,4.4837 -0.0312,7.03125 0.15991,2.54755 0.47068,5.32415 0.8125,8.3125 0.34182,2.98835 0.71984,6.21265 1.0625,9.6875 0.34266,3.47485 0.65005,7.18047 0.8125,11.1875 0.0812,2.00352 0.0288,4.09345 -0.0937,6.25 -0.12258,2.15655 -0.31327,4.37903 -0.59375,6.65625 -0.56095,4.55445 -1.39535,9.34454 -2.3125,14.1875 -0.91715,4.84296 -1.9376,9.75243 -2.84375,14.625 -0.90615,4.87257 -1.72205,9.70047 -2.25,14.34375 -0.26398,2.32164 -0.43067,4.59672 -0.53125,6.8125 -0.10058,2.21578 -0.10872,4.35995 0,6.4375 0.10872,2.07755 0.32358,4.09304 0.6875,6 0.36392,1.90696 0.86623,3.70225 1.53125,5.40625 0.66502,1.704 1.48798,3.31256 2.5,4.78125 1.01202,1.46869 2.22008,2.79899 3.625,4 1.40492,1.20101 3.00004,2.25528 4.84375,3.15625 1.55795,0.76133 3.37974,1.34923 5.28125,1.875 6.73454,0.2504 13.5817,-0.57005 19.125,-2.65625 8.27284,-3.11345 16.00669,-34.95123 21.28125,-53.90625 4.61449,-16.58291 31.70868,-49.9764 10,-82.53125 -5.42452,-8.13473 -19.61771,-11.16062 -35.375,-10.625 z"
       id="path3822"
       style="fill:#beb6be;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 542.69345,590.60434 c -0.575,-0.60759 -1.18771,-1.14861 -1.75,-1.78125 -1.69682,-1.90912 -3.30862,-3.9232 -4.875,-6.03125 -1.56638,-2.10805 -3.08611,-4.29942 -4.5,-6.5625 -1.41389,-2.26308 -2.7294,-4.59454 -3.96875,-6.96875 -1.23935,-2.37421 -2.39474,-4.80857 -3.4375,-7.25 -1.04276,-2.44143 -1.98838,-4.87901 -2.8125,-7.34375 -0.82412,-2.46474 -1.51032,-4.93084 -2.09375,-7.375 -0.58343,-2.44416 -1.05431,-4.87033 -1.375,-7.25 -0.32069,-2.37967 -0.49535,-4.72872 -0.53125,-7 -0.0359,-2.27128 0.0728,-4.47477 0.34375,-6.59375 0.20528,-1.60547 0.57621,-3.09785 0.96875,-4.59375 -3.46889,2.87745 -5.78285,6.00677 -6.1875,9.3125 -2.86873,23.43545 11.30072,40.34833 9.5625,59.46875 -1.73822,19.12042 -0.29017,43.48321 7.375,55.21875 3.94831,6.04494 15.08467,9.6369 26.53125,10.0625 -1.90151,-0.52577 -3.7233,-1.11367 -5.28125,-1.875 -1.84371,-0.90097 -3.43883,-1.95524 -4.84375,-3.15625 -1.40492,-1.20101 -2.61298,-2.53131 -3.625,-4 -1.01202,-1.46869 -1.83498,-3.07725 -2.5,-4.78125 -0.66502,-1.704 -1.16733,-3.49929 -1.53125,-5.40625 -0.36392,-1.90696 -0.61003,-3.92245 -0.71875,-6 -0.10872,-2.07755 -0.10058,-4.22172 0,-6.4375 0.10058,-2.21578 0.29852,-4.49086 0.5625,-6.8125 0.52795,-4.64328 1.34385,-9.47118 2.25,-14.34375 0.77298,-4.15646 1.63325,-8.34734 2.4375,-12.5 z"
       id="path4235"
       style="fill:#262626;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 553.56806,600.51801 c -0.6016,-0.40241 -1.218,-0.72267 -1.8125,-1.15625 -1.89156,-1.37955 -3.72603,-2.92746 -5.53125,-4.59375 -1.20701,-1.11411 -2.37107,-2.36782 -3.53125,-3.59375 -0.80425,4.15266 -1.66452,8.34354 -2.4375,12.5 -0.90615,4.87257 -1.72205,9.66922 -2.25,14.3125 -0.26398,2.32164 -0.46192,4.62797 -0.5625,6.84375 -0.10058,2.21578 -0.0775,4.35995 0.0312,6.4375 0.10872,2.07755 0.32358,4.06179 0.6875,5.96875 0.36392,1.90696 0.86623,3.7335 1.53125,5.4375 0.66502,1.704 1.48798,3.31256 2.5,4.78125 1.01202,1.46869 2.22008,2.79899 3.625,4 1.40492,1.20101 3.00004,2.25528 4.84375,3.15625 1.49193,0.72906 3.25606,1.26782 5.0625,1.78125 4.74965,0.1917 9.5588,-0.0821 13.9375,-1.03125 l -0.53125,0 c -2.17558,-0.538 -4.10544,-1.23899 -5.84375,-2.09375 -1.73831,-0.85476 -3.28418,-1.8613 -4.625,-3 -1.34082,-1.1387 -2.48565,-2.42267 -3.46875,-3.8125 -0.9831,-1.38983 -1.80359,-2.89185 -2.46875,-4.5 -0.66516,-1.60815 -1.17551,-3.33135 -1.5625,-5.125 -0.38699,-1.79365 -0.63265,-3.64741 -0.78125,-5.59375 -0.1486,-1.94634 -0.20626,-3.96504 -0.15625,-6.03125 0.05,-2.06621 0.1974,-4.19049 0.40625,-6.34375 0.4177,-4.30653 1.12311,-8.76089 1.9375,-13.21875 0.31482,-1.72328 0.6617,-3.41041 1,-5.125 z"
       id="path4245"
       style="fill:#7f707f;fill-opacity:1;stroke:none;display:inline" />
  </g>
  <g
     id="layer2"
     style="display:inline">
    <path
       d="m 462.21201,431.32823 15.95607,-18.15002 c 0,0 -15.99691,-13.48624 -21.40625,-24.5625 3.86381,-4.89416 8.03176,-10.05582 17.5625,-11.34375 4.12447,13.34389 11.10074,17.32773 11.90625,17.75 -0.26146,-11.78587 1.67068,-22.86492 3.96875,-30.21875 2.1251,-0.70837 4.50445,-1.0251 6.90625,-1.0625 5.28396,-0.0822 10.56864,1.22285 12.90625,2.78125 -1.6601,11.62078 -0.34505,28.95952 -0.28125,29.78125 5.1806,-9.06243 12.37243,-20.34118 19.5625,-27.53125 7.367,5.10023 19.27706,17.0019 19.84375,20.96875 0.0515,7.31548 -24.16425,30.40906 -31.53125,35.40625 3.5547,5.04871 3.48982,16.3178 2.5625,20.59375 0,0 24.1245,1.13857 30.71875,2.375 0.56669,9.63377 -1.16006,25.33308 -9.09375,31 -10.20047,0.5667 -35.17313,-7.75703 -45.9375,-16.3125 l -16.15791,5.14158 z"
       id="path4071"
       style="fill:#9fdf73;fill-opacity:1;stroke:none" />
    <path
       d="m 547.82534,471.05112 c -0.57122,-0.12975 -1.15027,-0.20137 -1.71875,-0.34375 -2.17259,-0.54414 -4.30996,-1.18809 -6.4375,-1.90625 -4.25507,-1.43631 -8.44156,-3.18582 -12.46875,-5.21875 -4.02719,-2.03293 -7.92046,-4.34678 -11.65625,-6.84375 -3.73579,-2.49697 -7.30665,-5.17157 -10.6875,-8 -3.38085,-2.82843 -6.56886,-5.81645 -9.53125,-8.84375 -2.96239,-3.0273 -5.7071,-6.09391 -8.1875,-9.1875 -2.4804,-3.09359 -4.69012,-6.19145 -6.625,-9.21875 -1.42772,-2.23381 -2.52436,-4.36501 -3.625,-6.5 l -14.5,16.5 17.5,36.59375 16.15625,-5.125 c 10.76437,8.55547 35.73703,16.8792 45.9375,16.3125 2.57902,-1.84216 4.44209,-4.80929 5.84375,-8.21875 z"
       id="path4509"
       style="fill:#36bb5d;fill-opacity:1;stroke:none" />
    <path
       d="m 385.4735,433.5076 c 58.24003,6.64466 75.07636,-14.0851 87.5436,-23.15218 24.93447,18.70085 19.83424,49.86893 17.00077,68.00308 -45.33539,3.40016 -71.88772,-16.43407 -91.3548,-25.51871 z"
       id="path3840"
       style="fill:#ea4e10;fill-opacity:1;stroke:none" />
    <path
       d="m 493.3125,457.03125 c -0.67416,0.0595 -1.39224,0.19551 -2.0625,0.25 -6.41406,0.52148 -12.65625,0.82031 -18.6875,0.90625 -6.03125,0.0859 -11.86719,-0.0371 -17.46875,-0.34375 C 449.49219,457.53711 444.125,457.03125 439,456.375 c -5.125,-0.65625 -9.99219,-1.47461 -14.59375,-2.4375 -4.60156,-0.96289 -8.9375,-2.08594 -12.96875,-3.3125 -4.03125,-1.22656 -7.77344,-2.55273 -11.1875,-4 -2.70818,-1.14803 -5.05037,-2.39358 -7.34375,-3.65625 l 6.75,9.875 c 19.46708,9.08464 46.03961,28.90016 91.375,25.5 0.93453,-5.98098 2.01247,-13.41078 2.28125,-21.3125 z"
       id="path4210"
       style="fill:#a60b0b;fill-opacity:1;stroke:none" />
    <path
       d="m 389.14889,426.50048 c 23.46597,53.88482 76.97754,93.79032 99.64523,106.25755 -25.50115,33.43486 -79.08901,65.18325 -79.08901,65.18325 0,0 -11.18672,-4.91496 -19.12041,-17.3822 -0.5667,15.86739 -7.82199,27.81152 -7.82199,27.81152 -39.66847,18.13415 -97.38664,24.48492 -138.18849,18.25131 12.46723,-65.73631 14.09375,-132.6033 9.56021,-167.73823 z"
       id="path4192"
       style="fill:#ee4c0e;fill-opacity:1;stroke:none" />
    <path
       d="m 481.93034,410.29964 c 1.07723,-0.81207 2.18141,-1.58294 3.3125,-2.25 1.13109,-0.66706 2.28845,-1.24556 3.4375,-1.6875 -1.23744,0 -2.58855,-0.39631 -4,-1.09375 -1.41145,-0.69744 -2.88345,-1.69454 -4.375,-2.9375 -1.49155,-1.24296 -2.99101,-2.70718 -4.46875,-4.34375 -1.47774,-1.63657 -2.94248,-3.43425 -4.3125,-5.3125 -1.37002,-1.87825 -2.64412,-3.84448 -3.8125,-5.8125 -1.16838,-1.96802 -2.22091,-3.93788 -3.09375,-5.84375 -3.367,2.20115 -5.81663,5.00731 -8.03125,7.8125 5.40934,11.07626 21.40625,24.5625 21.40625,24.5625 0,0 3.06417,-2.43056 3.9375,-3.09375 z"
       id="path4506"
       style="fill:#36bb5d;fill-opacity:1;stroke:none" />
    <path
       d="M 370.40625,425.5625 248.125,454.875 c 4.53354,35.13493 2.90473,102.01369 -9.5625,167.75 22.00518,3.3619 48.92042,2.92689 75.28125,-0.90625 -0.0288,-0.0128 -0.065,-0.0185 -0.0937,-0.0312 -2.68665,-1.19543 -5.21872,-2.44992 -7.5625,-3.78125 -2.34378,-1.33133 -4.51904,-2.75732 -6.53125,-4.21875 -2.01221,-1.46143 -3.83932,-2.97678 -5.53125,-4.5625 -1.69193,-1.58572 -3.24207,-3.23328 -4.625,-4.9375 -1.38293,-1.70422 -2.60226,-3.46432 -3.6875,-5.28125 -1.08524,-1.81693 -2.01367,-3.66992 -2.8125,-5.59375 -0.79883,-1.92383 -1.47629,-3.91257 -2,-5.9375 -0.52371,-2.02493 -0.89636,-4.09851 -1.15625,-6.21875 -0.25989,-2.12024 -0.3989,-4.29025 -0.40625,-6.5 -0.007,-2.20975 0.10986,-4.45654 0.34375,-6.75 0.23389,-2.29346 0.56741,-4.62863 1.03125,-7 0.46384,-2.37137 1.0675,-4.77527 1.75,-7.21875 0.6825,-2.44348 1.45389,-4.9277 2.34375,-7.4375 0.88986,-2.5098 1.88281,-5.05469 2.96875,-7.625 2.17188,-5.14062 4.73657,-10.4021 7.625,-15.75 2.88843,-5.3479 6.11035,-10.77246 9.625,-16.28125 3.51465,-5.50879 7.32446,-11.09546 11.375,-16.71875 4.05054,-5.62329 8.31641,-11.30859 12.8125,-17 4.49609,-5.69141 9.21118,-11.38062 14.0625,-17.09375 4.85132,-5.71313 9.85254,-11.43652 14.96875,-17.125 3.94871,-4.39039 8.00366,-8.74252 12.0625,-13.09375 z"
       id="path4201"
       style="fill:#a60b0b;fill-opacity:1;stroke:none" />
  </g>
  <g
     id="layer10"
     style="display:inline">
    <path
       d="m 161.56181,395.34865 c -0.49555,0.0258 -0.97175,0.12086 -1.4375,0.28125 -5.20076,1.98426 -20.43687,7.92223 -21.65625,8.40625 -5.72217,4.86099 -5.67232,22.48258 0.5,41.71875 6.0669,18.90765 15.96917,32.92536 23.34375,33.78125 1.38692,0.39236 2.63281,-0.25451 3.75,-0.875 0.012,-0.008 0.0193,-0.0229 0.0312,-0.0312 l 18.3438,-6.56255 c 5.36698,-1.88168 7.32933,-13.50625 5,-28.21875 l 30.50001,-19.6875 c -4.43043,-16.54387 -4.36682,-18.27017 -4.28125,-18.4375 l -36.28126,6.53125 c -0.009,-0.0289 -11.15922,-16.88263 -17.8125,-16.90625 z"
       id="path4218"
       style="fill:#eecc2f;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 183.60379,420.88972 -19.8125,7.96875 c 0.58743,1.50517 1.10466,3.03238 1.625,4.5625 l 20,-7.90625 c -0.53865,-1.56797 -1.19822,-3.08536 -1.8125,-4.625 z"
       id="path4104"
       style="fill:#fffef0;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 171.95942,401.12626 c -2.94112,1.03158 -4.01379,1.42109 -8.15625,2.84375 -5.60421,1.92467 -8.8661,2.88742 -12.0625,3.84375 0.15137,0.18214 0.32163,0.38574 0.46875,0.5625 3.6486,5.01645 6.48256,10.53267 8.9375,16.21875 l 19.75,-7.75 c -2.04845,-4.64818 -4.34549,-9.18043 -7.09375,-13.4375 -0.55344,-0.77108 -1.25175,-1.49891 -1.84375,-2.28125 z"
       id="path4099"
       style="fill:#fffef0;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 190.82246,457.38152 c -4.47992,1.39968 -6.36778,2.02249 -12.9375,4 -2.3124,0.69604 -4.24225,1.24351 -6.5,1.90625 -0.002,0.0979 0.003,0.21535 0,0.3125 -0.0585,1.93443 -0.21983,3.69638 -0.5,5.3125 -0.28016,1.61612 -0.68744,3.072 -1.1875,4.3125 -0.50006,1.2405 -1.09427,2.28618 -1.8125,3.09375 -0.43958,0.49427 -0.99015,0.75567 -1.53125,1.03125 l 0.0312,0.0937 18.71875,-6.6875 c 3.33938,-1.17079 5.2618,-6.25724 5.71875,-13.375 z"
       id="path4131"
       style="fill:#8c7505;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 216.14358,410.13468 c -12.23875,2.7881 -26.12464,5.93566 -35.59376,7.96875 0.77312,1.66898 1.50389,3.3848 2.21875,5.1875 l 34.00001,-9.71875 -0.625,-3.4375 z"
       id="path4149"
       style="fill:#fffef0;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 167.98824,450.678 c -1.00616,1.73067 -2.04273,3.16986 -3.09375,4.3125 -1.08699,1.18175 -2.19511,2.05689 -3.3125,2.65625 -1.11738,0.59936 -2.2451,0.93564 -3.375,1 -1.12989,0.0644 -2.28171,-0.13924 -3.40625,-0.5625 -1.12453,-0.42326 -2.24245,-1.07399 -3.34375,-1.9375 -1.10129,-0.86351 -2.18982,-1.93111 -3.25,-3.1875 -1.06017,-1.25639 -2.09257,-2.71062 -3.09375,-4.3125 -1.00117,-1.60188 -1.9507,-3.35 -2.875,-5.25 -0.9243,-1.9 -1.8267,-3.94301 -2.65625,-6.09375 -0.82954,-2.15074 -1.59558,-4.42715 -2.3125,-6.78125 -0.71691,-2.3541 -1.38234,-4.77116 -1.96875,-7.28125 -0.5864,-2.51009 -1.09323,-5.10005 -1.53125,-7.71875 -0.13749,-0.822 -0.22203,-1.67036 -0.34375,-2.5 -1.40081,8.08061 -0.0392,20.48372 4.1875,33.65625 6.76268,21.07605 18.30404,36.10112 25.78125,33.5625 5.86309,-1.9906 7.42722,-14.22659 4.59375,-29.5625 z"
       id="path4072"
       style="fill:#8c7505;fill-opacity:1;stroke:none;display:inline" />
  </g>
  <g
     id="layer12"
     style="display:inline">
    <path
       d="m 437.73805,335.49015 12.53889,-1.57586 c 5.99878,-0.7539 12.28279,5.33664 15.24657,16.96699 l 0,0 c 2.90583,11.403 0.55228,20.79549 -4.91456,22.74505 l -12.08453,4.30953"
       id="path3957"
       style="fill:#eecc2f;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 452.45307,353.68594 c 2.96378,11.63034 -0.26184,22.56882 -5.87724,24.09992 -5.6154,1.53111 -12.5702,-6.65595 -15.53398,-18.28629 -2.96377,-11.63035 -0.8142,-22.29981 4.8012,-23.83092 5.6154,-1.5311 13.64624,6.38694 16.61002,18.01729 z"
       id="path3959"
       style="fill:#8c7505;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 447.97341,341.19759 11.9168,-1.06352 3.56437,7.6629 -11.50454,1.51141 z"
       id="path3965"
       style="fill:#fffef0;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 444.625,328.46875 0.40625,3.5625 c 5.76864,0.55419 11.62436,12.09368 12.34375,15.90625 0.54224,1.37532 1.79678,1.39054 1.53125,0 -2.5816,-6.56039 -6.64321,-19.63419 -14.28125,-19.46875 z m 13.9375,32.375 c -0.32452,0.0683 -0.6476,0.55634 -0.875,1.6875 -1.51329,7.62976 -5.61565,7.54846 -8.78125,5.34375 l 0.625,5.875 c 1.49279,0.49655 3.06611,0.59857 4.71875,0.1875 4.18935,-2.99397 4.6718,-6.39639 5.21875,-11.59375 -0.0994,-0.95355 -0.48901,-1.58779 -0.90625,-1.5 z"
       id="path3967"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:3.18105221;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 457.48862,327.06896 c -4.97169,-0.22434 -9.86316,1.09461 -14.94319,1.74148 l 5.7394,3.08572 6.90778,-1.7099 c 15.12437,2.44664 16.75878,29.17881 9.47263,36.61507 l -6.18373,0.656 -4.69716,6.67281 12.10396,-4.31975 c 11.88917,-11.15493 1.8134,-39.83634 -8.39969,-42.74143 z"
       id="path3969"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:3.18105221;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
  </g>
  <g
     id="layer7"
     style="display:inline">
    <path
       d="m 212.93676,327.1531 c -28.06888,-27.19258 -60.16888,-21.36477 -60.7528,-7.29574 -1.22572,29.53302 16.98685,58.99595 63.79881,66.65942 z"
       id="path4251"
       style="fill:#9fdf73;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 172.88088,308.10141 c -11.9174,-0.3635 -20.39064,4.59742 -20.6875,11.75 -1.00692,24.2613 11.1294,48.44243 41.4375,60.5625 -0.15012,-0.18486 -0.32037,-0.34381 -0.46875,-0.53125 -2.24477,-2.83576 -4.27091,-5.96852 -6.125,-9.3125 -1.85408,-3.34398 -3.52335,-6.89716 -5,-10.59375 -1.47665,-3.69659 -2.76255,-7.54392 -3.875,-11.4375 -1.11245,-3.89358 -2.051,-7.84628 -2.8125,-11.78125 -0.7615,-3.93497 -1.35746,-7.83551 -1.78125,-11.65625 -0.42379,-3.82074 -0.68192,-7.54284 -0.78125,-11.09375 -0.0583,-2.08424 0.0439,-3.95751 0.0937,-5.90625 z"
       id="path4051"
       style="fill:#36bb5d;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 417.37557,283.29674 c 12.23688,-23.5108 31.50477,-34.68152 38.27313,-24.56826 9.43867,14.10324 7.73904,39.34274 -21.96155,74.05016 z"
       id="path3808"
       style="fill:#9fdf73;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 446.69718,314.7444 c -1.86934,-0.87218 -3.68163,-1.81373 -5.3125,-2.90625 -1.87201,-1.25407 -3.56859,-2.65313 -5.15625,-4.21875 -1.58766,-1.56562 -3.07102,-3.28762 -4.40625,-5.1875 -1.33523,-1.89988 -2.54155,-3.9619 -3.65625,-6.21875 -1.1147,-2.25685 -2.13641,-4.70724 -3.0625,-7.34375 -0.92609,-2.63651 -1.76187,-5.46112 -2.53125,-8.5 -0.36979,-1.46058 -0.66095,-3.13009 -1,-4.6875 -1.54375,2.33983 -3.04687,4.79693 -4.4375,7.46875 l -0.0312,0.0937 c 1.34286,3.37789 2.75159,6.8202 3.96875,10.09375 2.1901,5.89026 4.15312,11.55227 5.8125,16.875 1.65938,5.32273 2.99921,10.29014 3.96875,14.75 0.60339,2.77559 1.10017,5.72767 1.625,8.625 l 0.96875,-0.9375 c 5.41409,-6.32678 9.59428,-12.21813 13.25,-17.90625 z"
       id="path4042"
       style="fill:#36bb5d;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 376.71132,194.65726 c 16.26346,24.74873 48.64063,92.76454 56.39692,128.44345 7.7126,35.47798 8.79045,83.25079 8.79045,83.25079 0,0 -38.40618,26.94854 -89.9729,41.88393 -51.52598,14.92359 -126.1689,17.06384 -126.1689,17.06384 0,0 -10.52263,-30.03578 -16.54675,-68.7724 -6.66341,-42.84745 -11.42886,-119.80843 -11.42886,-119.80843"
       id="path4023"
       style="fill:#9fdf73;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 377.53125,192.75 -144.8125,66.40625 -33.9375,15.5625 c 0,0 4.77409,76.96505 11.4375,119.8125 6.02412,38.73662 16.53125,68.78125 16.53125,68.78125 0,0 27.11264,-0.86231 59.8125,-4.71875 -0.23695,-0.14862 -0.51469,-0.25617 -0.75,-0.40625 -3.63184,-2.31641 -7.06665,-4.80371 -10.3125,-7.46875 -3.24585,-2.66504 -6.31641,-5.51563 -9.1875,-8.53125 -2.87109,-3.01562 -5.55493,-6.19434 -8.0625,-9.5625 -2.50757,-3.36816 -4.81348,-6.93359 -6.96875,-10.65625 -2.15527,-3.72266 -4.15454,-7.6084 -5.96875,-11.6875 -1.81421,-4.0791 -3.45313,-8.34375 -4.9375,-12.78125 -1.48438,-4.4375 -2.80298,-9.0459 -3.96875,-13.84375 -1.16577,-4.79785 -2.17285,-9.77734 -3.03125,-14.9375 -0.8584,-5.16016 -1.56274,-10.50684 -2.125,-16.03125 -0.56226,-5.52441 -0.97266,-11.23438 -1.25,-17.125 -0.27734,-5.89062 -0.43384,-11.95996 -0.4375,-18.21875 -0.004,-6.25879 0.11621,-12.71484 0.375,-19.34375 -0.0824,2.10972 -0.0703,4.08233 -0.125,6.15625 0.89553,1.62336 1.78769,3.23595 2.59375,4.9375 1.11717,2.35828 2.16061,4.76332 3.15625,7.21875 1.61572,-0.68637 3.22765,-1.59508 4.8125,-2.71875 1.58485,-1.12367 3.14327,-2.45721 4.65625,-3.9375 1.51298,-1.48029 2.9749,-3.11876 4.375,-4.875 1.4001,-1.75624 2.75377,-3.61098 4,-5.5625 1.24623,-1.95152 2.38614,-3.99638 3.4375,-6.0625 1.05136,-2.06612 1.99701,-4.14996 2.8125,-6.25 0.81549,-2.10004 1.49264,-4.19671 2.03125,-6.25 0.53861,-2.05329 0.93551,-4.07413 1.15625,-6 2.82155,0.79984 5.79447,1.58789 8.8125,2.53125 3.01803,0.94336 6.0969,2.05035 9.09375,3.5 1.49842,0.72483 2.98518,1.51808 4.4375,2.4375 1.45232,0.91942 2.87099,1.96564 4.25,3.125 1.37901,1.15936 2.72151,2.43035 4,3.875 1.27849,1.44465 2.47423,3.03721 3.625,4.8125 2.35199,-1.57447 4.46688,-3.11688 6.34375,-4.65625 1.87687,-1.53937 3.52586,-3.06684 5,-4.59375 1.47414,-1.52691 2.76246,-3.05666 3.90625,-4.59375 1.14379,-1.53709 2.14542,-3.08633 3.03125,-4.65625 0.88583,-1.56992 1.6435,-3.15585 2.34375,-4.78125 0.70025,-1.6254 1.35044,-3.29648 1.9375,-5 1.17411,-3.40705 2.18812,-6.98833 3.34375,-10.84375 3.55449,1.0308 7.25609,2.33858 11.03125,3.84375 3.77516,1.50517 7.60929,3.2165 11.5,5.0625 3.89071,1.846 7.81762,3.82171 11.71875,5.875 3.90113,2.05329 7.78731,4.18546 11.59375,6.3125 1.54453,-2.84349 3.15654,-5.85316 4.6875,-8.96875 1.53096,-3.11559 2.98103,-6.32471 4.21875,-9.53125 1.23772,-3.20654 2.2727,-6.4149 2.9375,-9.53125 0.3324,-1.55818 0.55077,-3.09209 0.6875,-4.59375 0.13673,-1.50166 0.18765,-2.98374 0.0937,-4.40625 5.47256,2.77755 10.55958,5.16504 15.625,7.15625 2.53271,0.9956 5.07278,1.89399 7.625,2.6875 1.11751,0.34745 2.27386,0.59805 3.40625,0.90625 -10.63776,-23.34147 -22.05709,-45.1142 -29.9375,-57.25 -0.1437,-0.15325 -0.48752,-0.47756 -0.625,-0.625 z"
       id="path4024"
       style="fill:#36bb5d;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 340.86237,359.86108 c -1.46484,5.50773 2.63244,1.67036 5.05491,0.76099 13.13441,-8.90539 21.4871,3.72036 10.59177,15.19754 -1.0687,1.61934 1.01695,3.86822 2.69506,2.75393 1.3513,-0.82852 2.48097,-1.97732 3.67098,-3.01859 2.91405,-2.77596 5.49911,-9.22154 5.52187,-13.40082 -4.10814,-13.50073 -18.99849,-7.86754 -27.53459,-2.29305 z"
       id="path3855"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 311.15312,275.18281 c -27.5276,8.67754 -60.50115,39.33702 -81.57117,62.77591 -1.32613,1.71981 0.49909,3.68825 2.17791,2.31062 26.70889,-24.57046 59.74256,-53.32733 80.69945,-62.30892 1.47672,-1.30123 0.62014,-3.2005 -1.30619,-2.77761 z"
       id="path3857"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 276.36492,282.33214 c 6.36366,6.00485 11.70934,13.08988 16.0361,20.68304 1.0561,4.46859 5.39393,1.90704 3.23556,-0.94663 -2.10918,-7.48346 -11.62402,-21.48031 -16.61407,-22.73934 -2.27867,-2.22981 -4.58585,1.79317 -2.65759,3.00293 z"
       id="path3859"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 255.4375,292.8125 c -2.03186,-0.0238 -2.63153,2.99468 -0.81531,3.83732 7.22428,6.06055 13.48008,13.07544 19.30498,20.78587 3.45588,4.57456 8.3821,4.47242 5.44221,1.11468 -4.26684,-4.77081 -15.90308,-24.66878 -23.93188,-25.73787 z"
       id="path3861"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 236,311.90625 c 7.71665,6.95614 14.37178,15.07892 19.75458,23.95459 1.35002,1.55797 3.23719,0.51521 2.4564,-1.39271 -3.52151,-10.27935 -13.02435,-22.4416 -20.7106,-25.55455 -2.20168,-1.0209 -2.74535,1.90308 -1.50038,2.99267 z"
       id="path3863"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 278.87051,391.58333 c 11.61732,12.71374 28.22067,20.40718 45.52295,22.05158 14.52434,1.6321 29.65536,1.61085 43.63042,-3.14062 6.73436,-2.39037 15.22731,-5.75687 17.0596,-13.11473 0.19456,-2.2782 -4.84151,-5.35282 -5.32941,-3.11899 -2.338,7.01608 -9.85504,11.60577 -16.41814,13.53774 -14.134,3.73786 -29.07958,3.384 -43.42968,1.13919 -14.75736,-2.56919 -24.33611,-11.9233 -34.39015,-22.8048 -3.90103,-3.61253 -9.40279,2.68021 -6.64559,5.45063 z"
       id="path3851"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 353.83634,414.70547 c 2.12168,4.38533 5.69072,9.67097 4.90737,16.87994 -7.25362,2.66225 -20.63365,2.53351 -27.84917,0.23472 1.33322,-4.54946 1.58049,-11.51383 1.29739,-15.79916"
       id="path56"
       style="fill:#ffffff;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 358.84375,409.90625 -4.5685,1.85483 c 2.06492,4.26801 5.77094,8.58436 5.631,14.33267 -5.90863,2.88891 -16.83861,4.21301 -23.5625,0.21875 1.01002,-4.74741 2.12944,-10.31046 1.86992,-14.23892 l -4.80742,0.25 c 0.0584,5.95214 -0.21927,11.38231 -1.78125,16.89517 9.63716,2.14086 24.10705,2.74124 31.84175,-0.0202 1.17677,-6.93324 -1.77373,-13.49894 -4.623,-19.29233 z"
       id="path3865"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
  </g>
  <g
     id="layer1"
     style="display:inline">
    <path
       d="m 309.91286,328.57994 c -11.63972,4.70015 -25.00222,18.83468 -29.70542,31.6257 -0.36831,2.11666 2.74552,3.47114 3.90414,1.58128 1.76821,-3.03539 3.768,-6.06454 5.90714,-9.00645 0.74606,7.65755 7.37909,13.64718 15.44682,13.64718 8.56756,0 13.20172,-5.93365 13.20172,-14.26736 0,-8.33371 -4.63416,-15.91456 -13.20172,-15.91456 -0.34307,-0.64699 4.39609,-3.39576 5.66949,-4.1939 1.29574,-1.33443 0.67645,-3.67258 -1.22217,-3.47195 z"
       id="path3854"
       style="stroke-width:4;stroke-miterlimit:4;stroke-dasharray:none;display:inline" />
    <path
       d="m 311.48682,352.03935 c -4.32516,0.76632 -13.06754,-6.05205 -8.79149,-10.68299 5.39501,-6.30386 13.1416,8.05836 8.79149,10.68299 z"
       id="path3860"
       style="fill:#ffffff;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 377.97806,345.70822 c -16.21685,2.11004 -25.60279,-29.48478 -5.89798,-30.40585 20.03131,-0.18878 19.893,27.17753 5.89798,30.40585 z"
       id="path3062"
       style="fill:#000000;fill-opacity:1;stroke:none" />
    <path
       d="m 359.46875,313.75 c -0.96089,0.46976 -1.3897,1.79031 -0.88811,2.73497 0.50159,0.94467 1.83572,1.32914 2.76311,0.79628 10.93829,-3.16724 24.83037,0.93365 30.875,10.15625 0.35104,1.07329 1.7291,1.66871 2.75126,1.18873 1.02216,-0.47997 1.44415,-1.92062 0.84249,-2.87623 -8.13674,-13.01975 -23.25194,-18.19565 -36.34375,-12 z"
       id="path3877"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 381.29608,328.86612 c -3.52101,0.58011 -10.63798,-4.58146 -7.15694,-8.08713 4.39195,-4.77207 10.69827,6.10025 7.15694,8.08713 z"
       id="path3880"
       style="fill:#ffffff;fill-opacity:1;stroke:none;display:inline" />
  </g>
  <g
     id="layer8"
     style="display:inline">
    <path
       d="m 345.74636,541.27456 c 0,0 31.69505,-3.61082 46.94077,-8.02406 1.20361,-8.02406 -2.80842,-22.46738 -4.81444,-26.4794 -8.42527,-0.80241 -35.30587,8.02405 -48.54558,13.2397 -2.00601,-4.81445 -6.82045,-15.64693 -14.04211,-19.25775 5.55656,-13.8914 14.19305,-37.48864 16.85053,-49.7492 -5.21564,-2.40721 -27.28181,-7.62286 -34.50347,-6.41925 -2.80843,8.82647 -8.42527,35.70709 -11.63489,51.75521 -4.01203,-16.04812 -19.25776,-40.52152 -22.46738,-45.33596 -8.02407,1.20362 -24.47339,8.02407 -30.89264,14.84452 2.40722,8.82648 20.86256,39.71911 20.86256,39.71911 0,0 -30.49145,-20.46136 -43.73115,-25.27579 -8.42526,9.62888 -18.45534,25.27579 -19.65895,34.10226 15.64693,7.62286 34.50347,7.22166 47.34197,15.64692 -6.66336,21.50485 19.13376,42.93583 50.55161,40.52153 31.41785,-2.41429 48.54558,-18.85655 47.74317,-29.28784 z"
       id="path3888"
       style="fill:#9fdf73;fill-opacity:1;stroke:none" />
    <path
       d="m 322.74818,445.99175 c -5.21882,-0.89771 -10.52288,-2.09911 -15.84375,-1.53125 -3.25018,11.30446 -5.59553,22.84572 -8.17903,34.3148 -1.45267,6.6692 -2.87374,13.34531 -4.25847,20.02895 6.57411,-1.33043 13.34081,-1.75124 20.03125,-1.28125 -3.00915,-5.23245 -2.84325,-11.57679 -2.41167,-17.40828 1.0499,-10.48643 4.14451,-20.72812 8.58731,-30.26363 0.65422,-1.30434 1.23811,-2.65749 2.07436,-3.85934 z"
       id="path3970"
       style="fill:#36bb5d;fill-opacity:1;stroke:none" />
    <path
       d="m 340.82613,551.93542 c -0.37843,0.2077 -0.7797,0.48732 -1.15625,0.6875 -2.95091,1.56878 -5.82586,2.87834 -8.65625,4 -2.83038,1.12166 -5.61164,2.04974 -8.3125,2.75 -2.70085,0.70026 -5.31268,1.1954 -7.875,1.5 -2.56232,0.3046 -5.05397,0.40909 -7.46875,0.34375 -2.41478,-0.0653 -4.77301,-0.30919 -7.03125,-0.71875 -2.25823,-0.40956 -4.43856,-0.9907 -6.53125,-1.71875 -2.09268,-0.72805 -4.08186,-1.60419 -6,-2.625 -1.91814,-1.02081 -3.76542,-2.1809 -5.5,-3.46875 -1.73459,-1.28785 -3.36424,-2.68959 -4.90626,-4.21875 -1.54202,-1.52916 -3.00329,-3.19276 -4.34375,-4.9375 -1.34046,-1.74474 -2.55761,-3.59665 -3.6875,-5.53125 -1.12989,-1.9346 -2.15218,-3.93252 -3.0625,-6.03125 -0.91032,-2.09873 -1.72451,-4.29411 -2.40625,-6.53125 -0.68174,-2.23714 -1.24334,-4.52518 -1.6875,-6.875 -0.44416,-2.34982 -0.77117,-4.75072 -0.96875,-7.1875 -0.82323,0.52687 -1.71531,0.98165 -2.6875,1.34375 -0.97219,0.3621 -2.02701,0.63846 -3.125,0.84375 -2.19598,0.41059 -4.59599,0.51251 -7.15625,0.34375 -2.56026,-0.16876 -5.26069,-0.62819 -8,-1.3125 -2.73931,-0.68431 -5.51686,-1.61394 -8.25,-2.75 -2.73314,-1.13606 -5.42701,-2.47599 -7.96875,-4 -2.54174,-1.52401 -4.92864,-3.21434 -7.09375,-5.0625 -2.16511,-1.84816 -4.1155,-3.86024 -5.71875,-5.96875 -0.47524,-0.62501 -0.86593,-1.262 -1.28125,-1.90625 -4.9109,7.52144 -9.01843,15.35389 -9.75,20.71875 15.64693,7.62286 34.50526,7.19973 47.34375,15.625 -6.66335,21.50485 19.14465,42.94554 50.56251,40.53125 21.16003,-1.62603 35.63496,-9.61336 42.71875,-17.84375 z"
       id="path3925"
       style="fill:#36bb5d;fill-opacity:1;stroke:none" />
    <path
       d="m 391.58028,519.31421 c -0.0161,0.0391 -0.0149,0.0861 -0.0312,0.125 -0.39387,0.9363 -0.89763,1.80228 -1.46875,2.625 -0.57112,0.82272 -1.20816,1.5995 -1.9375,2.3125 -0.72933,0.713 -1.53774,1.36161 -2.40625,1.96875 -1.73702,1.21427 -3.72673,2.24853 -5.90625,3.0625 -2.17951,0.81397 -4.56154,1.43045 -7.03125,1.875 -2.4697,0.44455 -5.04865,0.70651 -7.65625,0.8125 -2.6076,0.10599 -5.21931,0.0454 -7.8125,-0.15625 -2.59319,-0.20169 -5.16726,-0.55275 -7.59375,-1.03125 -2.42648,-0.4785 -4.73627,-1.08805 -6.84375,-1.8125 l 2.78125,15.15625 c 0.14031,-0.80556 0.21403,-1.59268 0.15625,-2.34375 0,0 31.69178,-3.61801 46.9375,-8.03125 0.59455,-3.96365 -0.10766,-9.49983 -1.1875,-14.5625 z"
       id="path3939"
       style="fill:#36bb5d;fill-opacity:1;stroke:none" />
    <path
       d="m 265.40932,508.24372 c 2.22542,-1.24122 4.62522,-2.41236 7.15625,-3.5 2.53103,-1.08764 5.2043,-2.09729 7.9375,-3 0.50894,-0.16809 1.0486,-0.27564 1.5625,-0.4375 -1.04109,-0.37728 -2.08604,-0.77958 -3.09375,-1.28125 -1.23124,-0.61295 -2.42598,-1.31071 -3.59375,-2.09375 -2.33554,-1.56608 -4.53965,-3.45032 -6.53125,-5.59375 -1.9916,-2.14343 -3.78491,-4.54155 -5.3125,-7.125 -1.52759,-2.58345 -2.77523,-5.36386 -3.71875,-8.25 -0.47176,-1.44307 -0.88427,-2.91325 -1.1875,-4.40625 -0.30323,-1.493 -0.50532,-3.00549 -0.625,-4.53125 -0.11968,-1.52576 -0.14136,-3.0524 -0.0625,-4.59375 0.0789,-1.54135 0.27008,-3.08522 0.5625,-4.625 0.26439,-1.39217 0.61186,-2.77873 1.0625,-4.15625 -6.65111,2.83435 -13.36762,6.5488 -16.96875,10.375 2.40722,8.82647 20.84375,39.71875 20.84375,39.71875"
       id="path3945"
       style="fill:#36bb5d;fill-opacity:1;stroke:none" />
  </g>
  <g
     id="layer5"
     style="display:inline">
    <path
       d="m 194.63481,251.28361 c 45.47351,-20.31035 117.83636,-82.80989 185.10055,-84.84178 0,0 24.20488,29.33245 77.37424,66.17702 -30.90113,2.17595 -46.94673,-2.76094 -68.83698,-13.87114 0.7512,11.38006 -6.43712,25.65539 -12.61523,37.02935 -15.22575,-8.50815 -31.62956,-16.96048 -45.84751,-21.08369 -4.62253,15.42167 -7.07661,26.53171 -25.89252,39.1275 -9.20617,-14.20233 -22.93477,-17.09869 -34.22099,-20.29806 -1.76593,15.40695 -14.35977,36.18227 -27.28556,41.6732 -3.98254,-9.82174 -8.7035,-19.11267 -16.03372,-25.90131 -8.72015,12.26288 -20.73478,25.91637 -36.24733,32.00427 1.74228,-23.33597 6.21244,-26.95202 4.50505,-50.01536 z"
       id="path3871"
       style="fill:#948594;fill-opacity:1;stroke:none;display:inline" />
    <path
       d="m 381.9731,242.46431 c -0.5545,-0.8661 -1.09445,-1.87037 -1.65625,-2.6875 -1.75025,-2.54572 -3.53648,-4.83801 -5.375,-6.96875 -1.83852,-2.13074 -3.73432,-4.09918 -5.6875,-5.90625 -1.95318,-1.80707 -3.96829,-3.45653 -6.0625,-5.03125 -2.09421,-1.57472 -4.26962,-3.06632 -6.53125,-4.5 -2.26163,-1.43368 -4.60708,-2.80353 -7.0625,-4.1875 -4.91084,-2.76793 -10.24944,-5.53929 -16.09375,-8.65625 -0.38962,2.66241 -0.98983,5.39258 -1.78125,8.125 -0.79142,2.73242 -1.75606,5.47233 -2.84375,8.1875 -1.08769,2.71517 -2.31531,5.38934 -3.59375,8 -1.27844,2.61066 -2.60508,5.14361 -3.96875,7.5625 -2.72735,4.83779 -5.53362,9.20283 -7.96875,12.75 -2.43513,3.54717 -4.51377,6.28527 -5.8125,7.84375 -1.03899,-2.85722 -1.94032,-5.57136 -2.90625,-8.25 -0.96593,-2.67864 -1.98373,-5.33759 -3.25,-8 -1.26627,-2.66241 -2.77876,-5.34774 -4.71875,-8.15625 -1.93999,-2.80851 -4.32541,-5.72679 -7.3125,-8.84375 -2.59747,2.33772 -6.83104,5.82254 -11.75,9.71875 -4.91896,3.89621 -10.52137,8.19267 -15.78125,12.21875 -10.51976,8.05216 -19.71875,14.9375 -19.71875,14.9375 2.59747,-5.06507 5.34448,-9.97511 8.65625,-15.21875 3.31177,-5.24364 7.16343,-10.82613 11.96875,-17.125 4.80532,-6.29887 10.57814,-13.33176 17.65625,-21.5625 2.46114,-2.86193 6.10683,-6.80183 8.90625,-9.96875 -36.32326,19.71047 -69.92521,43.79328 -95.15625,55.0625 1.70739,23.06334 -2.78897,26.66403 -4.53125,50 15.51256,-6.0879 27.52985,-19.73712 36.25,-32 7.33022,6.78864 12.04871,16.08451 16.03125,25.90625 12.92579,-5.49093 25.54657,-26.28055 27.3125,-41.6875 11.28622,3.19937 25.01258,6.11017 34.21875,20.3125 18.81591,-12.59579 21.25247,-23.70333 25.875,-39.125 14.21795,4.12321 30.618,12.5856 45.84375,21.09375 2.33019,-4.2899 4.70634,-9.03939 6.84375,-13.84375 z"
       id="path3884"
       style="fill:#484048;fill-opacity:1;stroke:none;display:inline" />
  </g>
  <g
     id="layer6"
     style="display:inline">
    <path
       d="m 384.8125,154.53125 c -48.08435,1.78154 -92.30668,24.70292 -131.60143,50.80912 -18.58348,11.98422 -36.28754,25.648 -56.52357,34.81583 2.54454,18.34211 -3.97388,36.08306 -4.62505,54.28125 16.26477,-5.53431 28.72314,-18.30413 38.59375,-31.90625 6.88767,7.15801 11.22965,16.28551 14.8125,25.4375 16.54156,-7.15099 26.31775,-24.84119 29.9375,-41.8125 12.61535,2.85536 25.64247,8.7487 32.0938,20.5938 13.65666,-7.89975 23.3775,-21.36696 26.95348,-36.68134 4.60511,-5.26172 16.50057,4.80741 23.5956,6.66091 7.6544,3.69447 15.12569,7.75255 22.54467,11.89543 6.1741,-11.48191 12.9379,-23.36605 13.8125,-36.65625 21.15691,11.51706 45.684,15.07963 69.46229,12.60537 7.37535,0.47501 -3.79166,-4.11143 -5.1407,-6.04957 -26.53131,-18.92122 -52.34831,-39.44698 -73.91534,-63.9933 z m -1.75,4.09375 c 18.25717,27.51087 44.01596,49.7977 73.72513,64.17518 -22.21273,1.93476 -42.7316,-8.06327 -61.6437,-18.4067 -8.20536,-0.72894 -3.27626,7.97194 -5.11072,12.93527 -1.45866,9.80259 -4.67268,19.33426 -9.26428,28.10897 -14.83905,-8.07337 -28.02002,-19.34671 -44.29713,-24.61239 -6.27489,1.35113 -5.04878,8.012 -7.15239,12.80642 -2.9914,11.74305 -9.54708,23.84966 -19.78127,30.45424 -7.74416,-10.71787 -18.23935,-23.04408 -31.33413,-25.67924 -7.34219,-0.19852 -7.74323,6.85836 -8.62523,12.48253 -4.19594,11.94676 -12.18592,27.47382 -23.31747,34.0881 -4.00608,-9.68016 -4.55551,-23.54065 -12.63616,-30.42917 -4.43096,6.31806 -1.73494,-0.83298 -7.51461,6.57227 -5.93266,7.60127 -25.4572,26.67756 -32.51977,30.10125 5.12375,-16.71081 11.13393,-38.78246 10.62813,-51.66221 48.76515,-23.66116 88.09276,-56.17288 139.86479,-73.67137 12.60005,-4.10325 25.71665,-6.77118 38.97881,-7.26315 z"
       id="path3075"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <g
       transform="matrix(0.86910998,0,0,0.86910998,29.726043,42.140214)"
       id="g3873"
       style="fill:none;stroke:#000000;stroke-width:4.60240936;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none;display:inline">
      <path
         d="m 323.21875,454.09375 c -0.82749,0.13756 -1.55452,0.76431 -1.8125,1.5625 -4.99165,10.10386 -8.79761,30.55506 -11.36235,55.68981 -8.80095,-23.43738 -19.2916,-46.2854 -23.76265,-48.87731 -0.48047,-0.72048 -1.39325,-1.12616 -2.25,-1 -11.27939,-2.18013 -28.11245,5.38949 -36.90625,17.78125 -0.53401,0.57407 -0.74247,1.43244 -0.53125,2.1875 -0.16507,7.91794 5.51753,15.78854 13.25,27.15625 3.74277,5.50235 8.01642,11.45706 10.102,15.02091 -14.42713,-13.53468 -35.88664,-28.03655 -46.6645,-28.33341 -0.86259,-0.30468 -1.89827,-0.0328 -2.5,0.65625 -14.18333,9.35532 -23.89661,21.56066 -23.1875,40.4375 6.58626,14.20311 41.59424,10.38551 54.45015,18.03048 -3.05717,12.74953 2.55744,26.79393 13.5186,35.68827 27.33427,20.94459 59.42875,22.06266 85.54159,4.12731 9.63851,-4.9974 16.5706,-17.82619 17.11389,-24.56481 9.06906,-2.97307 47.41738,0.14047 55.53202,-10.9375 0.77813,-5.18751 2.6496,-10.77139 0.65108,-19.25077 -1.96073,-8.31905 -5.05872,-9.84576 -6.43233,-12.59298 -0.3454,-0.68287 -1.05146,-1.16981 -1.8125,-1.25 -5.86979,-0.55903 -15.78767,0.13241 -26.71875,3.33033 -10.10973,2.95763 -21.66523,10.1214 -29.30062,13.05809 -0.38936,-11.3432 -5.81594,-19.43124 -14.59375,-22.24482 16.12314,-32.35699 18.73118,-42.61531 20.01937,-55.5186 -5.19086,-11.10623 -36.44472,-14.36565 -42.34375,-10.15625 z m 2.125,4.5625 c 12.45986,0.55956 23.16803,2.20353 35.1875,6.59375 -3.37048,14.15313 -12.64049,39.60122 -18.75,54.875 -0.43982,1.06188 0.0666,2.42185 1.09375,2.9375 7.02856,3.51427 12.7858,15.50466 15.0625,20.96875 0.45999,1.09674 1.86281,1.6874 2.96875,1.25 7.53456,-2.96816 19.0472,-6.97558 29.8125,-10.125 9.86793,-2.88689 19.18578,-4.8339 23.65625,-4.875 0.986,2.3772 3.27748,7.532 4.35046,12.50671 1.11378,5.1639 0.77331,9.71479 0.46204,13.74329 -17.5572,4.76676 -52,8.78125 -52,8.78125 -1.17033,0.1346 -2.12461,1.29441 -2.03125,2.46875 0.3585,4.66055 -3.66048,11.95258 -12.59375,18.25 -8.93327,6.29742 -22.51008,11.63918 -40.21875,13 -17.50811,1.3454 -33.40989,-4.00817 -43.875,-12.5 -10.46511,-8.49183 -16.60285,-17.14773 -13.08187,-28.51111 0.30205,-0.95124 1.07443,-4.72546 0.23812,-5.27014 -15.17741,-9.96018 -36.02388,-9.78537 -53.0625,-17.4375 2.3403,-14.71802 12.03526,-25.47209 21.24406,-36.23812 7.32897,2.95451 18.35195,10.7961 28.34969,16.95687 10.63244,6.55188 19.375,12.40625 19.375,12.40625 0.86074,0.5704 2.1102,0.46045 2.8581,-0.2515 0.74791,-0.71194 0.91923,-1.95447 0.3919,-2.84225 0,0 -5.27157,-8.84933 -10.90625,-18.96875 -5.3198,-9.55393 -11.59156,-18.36109 -13.19421,-23.17408 9.61615,-8.45034 20.15329,-14.28446 32.60046,-16.79467 4.52821,6.98097 20.46387,33.16797 24.6875,50.0625 0.2395,1.01545 1.2448,1.79434 2.28789,1.77262 1.04308,-0.0217 2.01509,-0.84178 2.21211,-1.86632 3.55198,-17.75991 9.66058,-46.88025 12.875,-57.71875 z"
         id="path3973"
         style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4.60240936;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
      <path
         d="m 261.12471,541.62533 c 0.90004,0.80186 2.4486,0.71237 3.25029,-0.18783 18.1961,-15.43321 45.37631,-22.39767 66,-21.84375 1.21301,0.0925 2.39788,-0.93986 2.47222,-2.15412 -7.69991,-11.48361 -55.66283,2.95856 -71.72251,24.1857 z"
         id="path3975"
         style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4.60240936;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    </g>
    <path
       d="m 414.65625,238.1875 c -1.39173,0.009 -2.41446,1.79459 -1.71875,3 25.51149,49.27973 34.29676,95.14089 35.9375,153.125 -2.39537,1.65774 -38.97487,26.65592 -88.5,41 -6.12243,1.77325 -13.08763,3.4936 -19.68235,4.92154 2.58544,1.34435 6.55335,3.99194 6.23787,6.55868 C 410.9388,434.84563 429.5394,412.93404 452.0625,397 c 0.15657,-66.67099 -15.20281,-133.98775 -35.59375,-157.71875 -0.3369,-0.66289 -1.06899,-1.10467 -1.8125,-1.09375 z"
       id="path4118"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;stroke:none;stroke-width:0.1;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 304.94831,452.375 c 0.53671,-2.14229 0.82636,-4.41619 1.3909,-6.28507 -8.19987,1.12559 -16.8019,2.25898 -24.28374,3.01529 0.76266,1.26101 1.45771,3.13374 2.31698,4.7736 6.93892,-0.45244 14.4404,-0.95519 20.57586,-1.50382 z"
       id="path4116"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;stroke:none;stroke-width:0.1;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 247.76081,455.1875 c 1.20567,-1.36505 2.84416,-2.7169 4.07779,-3.72257 -8.35812,0.50394 -14.55478,0.74986 -15.6511,0.78507 -16.08887,-52.92644 -21.87535,-99.00922 -25.28125,-158.34375 -0.49611,-2.77643 -4.04458,-1.91299 -4,0.21875 -4.56494,20.26539 -0.49151,98.7493 28.09375,161.28125 4.35435,-0.018 8.60454,-0.152 12.76081,-0.21875 z"
       id="path4636"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;stroke:none;stroke-width:0.1;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 580.375,498.5625 c -20.04728,0.30745 -40.93066,4.18771 -57.71875,15.8125 -6.68141,4.90988 -7.90441,13.65564 -7.03125,21.34375 0.32795,5.33353 1.65395,11.0502 3.25,16.9375 -10.26579,-4.01529 -20.69082,-7.65719 -31.125,-11.21875 -1.21747,1.33412 -2.3569,2.67406 -3.65625,4 11.49808,3.61184 23.83524,7.04269 35.78125,10.90625 2.31632,8.16433 4.88242,16.54805 5.96875,24.5625 -0.0109,0.009 -0.0203,0.0218 -0.0312,0.0312 -14.19724,12.25061 -23.17004,24.61118 -27.15625,42.96875 -14.49441,-15.90851 -37.04976,-32.03219 -48.3125,-50.09375 -0.82378,0.59827 -1.64138,1.18934 -2.46875,1.78125 14.14706,22.342 30.34829,42.65162 49.625,58.125 6.37475,-17.0352 17.52059,-32.37598 28.78125,-45.5 0.0291,-0.0339 0.0647,-0.0599 0.0937,-0.0937 3.4e-4,1.66655 -0.0734,3.29648 -0.28125,4.90625 -0.94045,17.70694 -5.05517,29.13109 3.15625,45.3125 11.89693,12.98328 43.22182,20.43594 54.28125,8.84375 17.28992,-18.12282 15.43803,-48.27886 26.125,-68.03125 7.80536,-16.23445 15.09989,-34.56928 10.53125,-52.8125 -2.42698,-10.07806 -7.88755,-20.96902 -18.40625,-24.4375 -6.79746,-2.65107 -14.17326,-3.27322 -21.40625,-3.34375 z m 0.0625,5.375 c 9.74828,0.21597 24.68275,1.97157 31.46875,9.75 10.13501,13.62245 9.62486,27.74929 3.78125,43.1875 -4.99881,14.50301 -16.43791,28.14998 -19.46875,43.34375 -4.07736,13.98252 -4.19271,28.94426 -11.96875,41.46875 -5.20608,6.92304 -16.14754,2.13972 -21.1875,-2.71875 -8.2126,-4.27166 -4.31887,-19.86107 -2.90625,-31.1875 2.92496,-19.93488 7.81544,-40.11378 5.09375,-60.5 -0.752,-11.93402 -4.00655,-25.22667 2.78125,-36.0625 3.29124,-4.66466 7.13226,-5.57162 12.40625,-7.28125 z m -16.5,0.53125 c 2.88093,-0.13413 7.25,0.9375 7.25,0.9375 0,0 -10.96583,2.45008 -11.75,13.09375 -0.94659,17.12564 4.53387,48.83975 0.34375,65.8125 -2.87842,28.15613 -17.63857,51.10335 11,61.6875 -5.50843,0.8986 -14.6829,1.5442 -18.71875,-2.40625 -7.90338,-6.69804 -8.06655,-17.80905 -7.53125,-27.3125 1.50904,-22.54444 10.56792,-44.31545 8.09375,-67.15625 -0.22281,-10.73712 -2.87097,-21.78207 -0.96875,-32.5 1.27247,-7.06874 3.42374,-10.27727 10.125,-11.53125 0.41293,-0.39258 1.19594,-0.58029 2.15625,-0.625 z m -8.875,0.5625 c -6.38282,3.99214 -9.99214,11.13254 -9.4375,18.34375 0.36322,14.26438 4.77654,38.2427 2.8125,52.5625 -2.04754,28.13114 -21.17545,49.60931 2.5,69.03125 -6.68033,-1.61825 -15.78323,-2.43037 -18.28125,-9.40625 -4.85766,-11.03641 -3.97449,-23.67417 -4.34375,-35.5625 -0.0492,-4.88084 0.35978,-9.81262 0.53125,-14.71875 0.01,-0.011 0.0216,-0.0203 0.0312,-0.0312 0.0145,-0.41648 0.021,-0.83385 0.0312,-1.25 0.13072,-5.32916 -0.12192,-10.62519 -1.71875,-15.8125 -0.84634,-3.37679 -1.82348,-6.83674 -2.75,-10.3125 -0.0473,-0.17758 -0.0779,-0.35349 -0.125,-0.53125 -0.23591,-0.89062 -0.39883,-1.79268 -0.625,-2.6875 -0.0216,-0.009 -0.041,-0.0225 -0.0625,-0.0312 -2.55363,-10.11155 -4.32703,-20.43815 -1.1875,-30.40625 4.72781,-15.01092 18.54073,-16.09218 32.625,-19.1875 z"
       id="path3872"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:3.47643995;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 231.49729,677.76901 c -11.52364,7.91776 -16.38955,22.57799 -10.68117,33.2402 17.67204,33.00811 63.88565,59.63961 100.68388,59.92829 l 0.125,0 0.15625,-0.0312 c 36.9089,-7.36997 60.61124,-54.82443 40.34375,-79.5938 L 362,691.15625 c -13.48278,-9.23754 -27.87282,3.63343 -47.81009,0.16411 l -2.39477,4.96089 c 12.18172,1.64499 21.87008,-3.31948 29.22222,-2.97222 31.97035,1.51004 23.29667,42.41902 5.7583,58.67452 -23.2059,-0.24556 -80.23683,5.6759 -121.16183,-49.88256 -1.34805,0.42648 -1.90679,1.04126 -1.67276,2.60131 35.15726,45.52268 86.19136,55.19329 117.30888,53.39145 -6.27631,4.77963 -8.04468,7.07725 -14.8125,8.25 -24.75162,-0.0999 -93.68902,-27.56814 -103.03125,-56.15625 -3.57869,-10.95114 2.64829,-22.10459 12.35193,-28.53125 z"
       id="path3915"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 333.7352,620.93026 c -2.33166,0.38328 -6.05608,0.61877 -8.41349,0.9467 -3.96667,29.37651 -7.2127,64.32107 -20.99532,85.21332 -37.97424,0.51406 -74.47323,-31.09949 -80.8507,-55.58333 31.05546,2.53294 54.77334,-7.70865 63.43252,-26.55465 -1.26508,-1.57455 -3.84292,0.37313 -10.48913,0.0128 -14.77074,21.46498 -36.99936,25.08962 -60.79408,24.90987 7.50636,36.0399 57.2314,64.04256 88.56245,62.0937 16.6875,-25.81884 26.05048,-63.79821 29.54775,-91.03841 z"
       id="path4788"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 476.75,402.625 c -3.57178,1.9549 -6.54614,4.99403 -9.94553,7.27297 -22.07093,14.79039 -38.74883,17.6904 -62.47639,16.57549 -1.92698,0.46307 -1.39353,3.60115 0.57817,3.40154 30.07815,1.37229 60.20404,-4.41325 71.50266,-24.36968 20.28844,19.12873 19.57835,38.71855 17.67686,63.56516 -23.44452,1.47438 -49.34085,-1.2337 -69.70627,-13.30576 -1.17685,-0.83651 -3.24463,-2.64422 -4.45862,-0.82008 -1.14655,2.01819 1.68884,3.14515 2.96211,3.96605 21.44486,12.54307 47.00734,17.08871 71.61526,15.1238 13.96338,-54.22895 -7.7612,-65.71198 -17.74825,-71.40946 z"
       id="path3856"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:3.47643995;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 492.68359,358.61913 c -2.37905,8.52953 -4.32342,16.50318 -4.40234,25.38087 -4.39699,-4.00187 -7.41276,-8.26828 -9.40234,-13.75978 -9.55646,-3.23506 -17.40598,6.3332 -19.38282,11.81446 2.27999,9.02307 13.19026,17.71829 20.12891,23.78907 -1.76151,1.06985 -0.59894,4.09226 1.4375,3.34375 1.19434,-0.92247 1.65639,-2.30892 1.35157,-4 -6.73776,-8.06602 -14.89344,-15.35373 -19.72657,-23.90625 3.4491,-4.75083 8.47708,-8.52486 14.375,-9.4375 0.40563,4.36709 5.27052,11.35077 11.00196,15.00978 0.10577,2.786 0.63642,7.13531 0.99804,9.89647 0.7265,1.88227 1.95018,1.4735 1.41799,-0.47266 -0.97658,-12.17145 1.98688,-26.41176 4.95701,-37.46484 4.95942,-0.98263 13.96802,-1.92758 16.46875,2.46875 -0.78964,8.92212 -0.76698,17.96533 0,26.875 -2.7561,4.84509 -5.34148,9.78678 -7.71875,14.8125 -0.39451,2.10987 2.34817,2.12939 2.84766,0.0664 11.18908,-17.29891 16.51958,-27.44475 26.27734,-38.72657 6.62282,3.70152 13.73538,9.93642 17.99804,17.34962 -0.58179,5.05488 -5.19638,9.30529 -8.24804,13.21679 -7.03186,7.9327 -14.75213,15.32919 -23.09375,21.84375 -0.94402,2.57431 2.26592,4.72978 2.09375,7.4375 1.07455,4.79393 0.75404,9.78388 0.28125,14.59375 9.03346,2.03505 20.75735,1.34218 29.69337,2.53712 1.60762,8.42444 -0.60205,22.20121 -7.40625,29.33006 -15.39755,-1.23311 -33.68543,-9.36141 -45.03712,-17.49218 -2.17504,-0.66193 -3.08084,2.72463 -1,3.46875 8.38357,5.83045 34.23283,25.11766 49.65625,15.125 8.85803,-7.43093 15.34172,-32.37885 4.375,-33.1875 -8.86619,-0.99347 -17.78186,-1.4259 -26.6875,-1.90625 0.64418,-6.20057 -1.39707,-12.8241 -4.17576,-18.53125 22.35041,-14.46138 33.31188,-26.73369 32.75386,-35.53521 -4.03983,-14.02571 -15.46075,-21.00206 -21.51169,-21.07028 -1.29933,-0.0991 -6.55541,4.6191 -9.49609,7.78712 -3.48885,4.70052 -6.4251,11.44982 -9.4707,16.45701 -0.36399,-8.12108 0.63179,-19.07119 1.49413,-27.13864 -7.05681,-7.85171 -18.17715,-7.5207 -22.84766,0.0254 z"
       id="path3858"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:3.47643995;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 399.40625,431.21875 c 19.58355,40.12505 55.5414,87.19492 95.625,96.875 -25.10456,26.06736 -52.91194,47.22741 -77.40625,65.0625 -7.71301,-3.66328 -18.34375,-18.21875 -18.34375,-18.21875 -1.25309,14.39645 -9.25,26.5 -9.25,26.5 0,0 -94.66147,24.74509 -135.4375,19.65625 7.00159,-17.9548 10.35231,-39.98415 11.78125,-62.21875 -1.95671,-1.24012 -3.93559,-2.41289 -5.84375,-3.875 -0.41048,-0.33308 -0.76326,-0.71325 -1.15625,-1.0625 -2.48612,30.10415 -6.08722,56.65391 -8.5,69.0625 47.4515,8.58348 103.20857,-1.12451 140.9375,-17.25 5.78395,-5.18115 7.84375,-23.25 7.84375,-23.25 0,0 9.47515,11.23044 17.46875,13.5625 29.34966,-18.3043 65.47955,-43.43431 81.71875,-68.53125 -25.41195,-16.8161 -78.64792,-62.11407 -96.375,-97.5625 -0.93029,0.43283 -2.0968,0.82252 -3.0625,1.25 z"
       id="path3870"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:3.47643995;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 176.46875,300.5625 c -6.60611,0.46759 -15.23352,3.64543 -17.54721,10.99659 -7.32662,32.00674 31.51928,63.48641 53.67506,67.41645 2.17081,-0.0628 2.46194,-3.50127 0.33259,-3.92814 -27.57883,-4.48019 -49.68606,-30.96529 -48.22019,-59.04042 1.07307,-20.55192 31.81565,-12.2074 40.69911,-5.25221 1.99171,0.8657 3.11352,-0.46492 1.36743,-1.75624 -8.72969,-6.1445 -19.66768,-9.11644 -30.30679,-8.43603 z"
       id="path3977"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 187.0625,312.46875 c -4.50363,-0.56625 -10.63239,1.05753 -12.43718,5.55052 -4.00066,16.10645 15.19061,33.79775 27.82604,38.22085 1.5539,0.59464 4.26407,2.26898 4.90891,-0.0236 0.45859,-1.6125 -1.23035,-2.71547 -2.66113,-2.70529 -12.35529,-4.73628 -26.61642,-19.52054 -25.45018,-31.73827 4.02014,-11.13421 19.48233,-3.08978 25.57849,0.0829 2.13449,0.61358 3.12525,-1.48276 1.1413,-2.48084 -5.85418,-3.2759 -12.14023,-6.27485 -18.90625,-6.90625 z"
       id="path3979"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 443.06867,268.69758 c -1.66436,2.78302 -7.61636,7.03498 -5.66299,10.52133 3.48389,-0.99255 6.70303,-9.21314 11.25431,-12.17022 4.19921,0.41639 4.63973,5.82469 4.98802,8.78272 -0.69849,9.13858 -4.48443,18.50834 -9.71017,25.71812 -3.44285,1.12086 -0.71894,3.504 1.16879,3.41534 1.88773,-0.0887 13.27359,-18.56249 13.87861,-29.65717 0.10433,-4.02062 -0.80162,-8.05295 -3.62012,-11.10376 -4.84022,-3.26175 -9.4346,1.54935 -12.29645,4.49364 z"
       id="path3981"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 455.375,249.03125 c -8.76289,0.34093 -23.1469,8.99934 -24.7745,18.73423 2.49028,3.70658 5.21581,-2.13963 6.58129,-4.00661 4.13751,-5.22526 8.71045,-10.6973 15.46775,-11.70943 23.47019,11.51183 4.95807,53.52213 -7.38173,69.56625 -2.96662,1.08371 -3.3928,5.63346 0.39318,3.24811 2.72226,-2.88561 4.94975,-6.21487 7.34029,-9.38155 7.81866,-10.91748 14.63407,-23.14975 16.36615,-36.65902 0.96247,-9.46965 -1.36595,-19.63148 -7.744,-26.88833 -1.69596,-1.60344 -3.90514,-2.71498 -6.24843,-2.90365 z"
       id="path3983"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
    <path
       d="m 167.65625,387.8125 c -6.64018,1.71703 -12.78906,4.71331 -19.375,6.90625 -6.58594,2.19294 -8.95925,9.29645 -9.18372,15.16424 -0.28723,19.40399 6.0012,38.67501 16.22436,55.05291 3.44281,4.77657 7.56075,10.1262 13.53134,11.56021 7.06377,-1.9329 13.96756,-5.48929 21.1851,-7.69655 7.66309,-2.24602 8.40378,-11.60922 8.53962,-18.31538 1.07814,-3.88472 0.2826,-11.6275 -0.0206,-11.42206 9.28736,-6.00425 26.82969,-17.7654 26.82969,-17.7654 l -1.53709,-5.90154 c 0,0 -17.49503,15.71535 -25.98803,21.20357 -1.74479,-9.27156 -5.95926,-21.4481 -10.09708,-29.91625 11.57292,-1.98958 32.36842,-2.27657 32.36842,-2.27657 l -0.99807,-5.52499 c 0,0 -22.02759,3.76687 -33.04139,5.65031 -4.22303,-6.87879 -9.39534,-16.19312 -18.4375,-16.71875 z m 0.125,4.0625 c 8.98006,1.80174 14.82568,9.93149 20.11334,20.37764 5.28765,10.44614 9.02958,23.36395 6.44542,42.82809 -2.12211,11.15785 -8.40797,9.93093 -17.54397,11.47344 3.51735,-13.87746 -0.12741,-25.69303 -4.30968,-38.96465 -4.10672,-11.2362 -8.85386,-22.33624 -18.29719,-30.08785 4.71734,-1.64181 8.80322,-4.28728 13.59208,-5.62667 z m -3.60478,22.67535 c 9.45039,15.21451 11.91973,34.83653 8.77196,48.32733 -1.63899,8.31575 -10.86109,9.32636 -13.91442,3.51622 -9.33884,-10.77861 -13.08354,-24.96978 -16.89044,-38.37677 -1.30571,-7.99454 -2.44581,-14.66362 1.63545,-22.12058 7.29725,-7.38359 17.2425,3.18162 20.39745,8.6538 z"
       id="path3993"
       style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:4;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
  </g>
</svg>
'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'yo 1/28/2013 15:26'!
hatShape
	| gray blackBack blackFront1 blackFront2 blackFront |
	gray := GeziraPath arcPoints: 0 to: Float pi *2 center: 123@161 radius: 76@25.
	blackBack := (GeziraPath arcPoints: Float pi to: Float pi*2 center: 123@161 radius: 123@44), {0@123. 0@123. 47@123}, (GeziraPath arcPoints: Float pi to: Float pi *2 center: 123@161 radius: 76@25) reversed, {199@161. 199@161. 246@161}.
	blackFront1 := (GeziraPath arcPoints: Float pi * 0.75 to: Float pi center: 123@161 radius: 123@44) reversed.
	blackFront2 := (GeziraPath arcPoints: 0 to: Float pi *0.25 center: 123@161 radius: 123@44) reversed.
	blackFront := blackFront1, {blackFront1 last. 63@249. 42@300. 42@300. 123@348. 210@300. 210@300. 188@248. blackFront2 first}, blackFront2,
		{246@161. 246@161. 199@161}, (GeziraPath arcPoints: 0 to: Float pi center: 123@161 radius: 76@25), {47@161. 47@161. 0@161}.
	^ KSShape new elements:{
		(GeziraPath new points: {blackBack}) fill: (Color black).
		(GeziraPath new points: {gray}) fill: (Color r: 0.323 g: 0.323 b: 0.323).
		(GeziraPath new points: {blackFront}) fill: Color black} ! !

!KSFactory methodsFor: 'graphics-data' stamp: 'yo 1/28/2013 11:37'!
rabbitPath
	^ {
78@136. 33@93. 18@52. 18@52. 15@8. 54@16.
54@16. 64@31. 75@55. 75@55. 85@80. 104@117. 
104@117. 126@114. 131@117. 131@117. 140@88. 142@66. 
142@66. 148@44. 155@24. 155@24. 158@4. 183@0.
183@0. 206@9. 206@32. 206@32. 202@48. 190@76.
190@76. 176@104. 162@136. 162@136. 184@155. 172@178.
172@178. 167@207. 123@212. 123@212. 90@207. 73@179.
73@179. 63@166. 78@136}.! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
selectAllSVG
	^'<svg x="0px" y="0px" width="36px" height="36px" viewBox="-6.846 -8.539 36 36">
<g>
	<rect x="0.5" y="0.5" fill="#52C3F0" width="15.887" height="9.903"/>
	<path fill="#000100" d="M16.387,0h-1v0.5h1V0L16.387,0z M13.887,0h-1v0.5h1V0L13.887,0z M11.387,0h-1v0.5h1V0L11.387,0z M8.887,0
		h-1v0.5h1V0L8.887,0z M6.387,0h-1v0.5h1V0L6.387,0z M3.887,0h-1v0.5h1V0L3.887,0z M1.387,0H0.5H0v0.5v0.113h0.5V0.5l0,0l0,0h0.887
		V0L1.387,0z M0.5,2.113H0v1h0.5V2.113L0.5,2.113z M0.5,4.613H0v1h0.5V4.613L0.5,4.613z M0.5,7.113H0v1h0.5V7.113L0.5,7.113z
		 M0.5,9.613H0v0.79v0.5h0.5h0.21v-0.5H0.5V9.613L0.5,9.613z M3.21,10.403h-1v0.5h1V10.403L3.21,10.403z M5.71,10.403h-1v0.5h1
		V10.403L5.71,10.403z M8.21,10.403h-1v0.5h1V10.403L8.21,10.403z M10.71,10.403h-1v0.5h1V10.403L10.71,10.403z M13.21,10.403h-1
		v0.5h1V10.403L13.21,10.403z M15.71,10.403h-1v0.5h1V10.403L15.71,10.403z M16.887,8.58h-0.5v1h0.5V8.58L16.887,8.58z M16.887,6.08
		h-0.5v1h0.5V6.08L16.887,6.08z M16.887,3.58h-0.5v1h0.5V3.58L16.887,3.58z M16.887,1.08h-0.5v1h0.5V1.08L16.887,1.08z"/>
</g>
<rect x="1.738" y="2.062" fill="#231F20" width="13.41" height="0.799"/>
<rect x="1.738" y="4.062" fill="#231F20" width="13.41" height="0.799"/>
<rect x="1.738" y="6.062" fill="#231F20" width="13.41" height="0.798"/>
<rect x="1.738" y="8.062" fill="#231F20" width="13.41" height="0.798"/>
<polygon fill="#231F20" points="15.823,13.557 14.94,16.938 8.676,5.144 20.469,11.407 17.088,12.293 22.44,17.644 21.176,18.91 "/>
<polygon fill="#FFFFFF" points="21.932,17.644 16.39,12.104 19.485,11.293 9.545,6.013 14.825,15.953 15.634,12.858 21.176,18.4 "/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'yo 1/22/2013 11:44'!
textCapsIcon
	| s minMax minY maxY strut |
	s := self characterIconWithString: 'Aa' style: 0 size: 10 offset: 2@5.
	minMax := s elements collect: [:a | a minMax].
	minY := (Array newFrom: (minMax collect: [:m | m origin y])) min.
	maxY := (Array newFrom: (minMax collect: [:m | m corner y])) max.
	strut := (GeziraPath line: 0@(minY-2) to: 0@(maxY+2)) fill: Color transparent.
	s elements: s elements, {strut}.
	^ s! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
thumbDownSVG
	"Based on http://commons.wikimedia.org/wiki/File:Thumb_down_icon.svg licensed under CC-SA by Piastu"
	^'<svg>
<defs>
<linearGradient x1="43" y1="7.01" x2="22" y2="52" id="fieldGradient" gradientUnits="userSpaceOnUse">
<stop stop-color="#febcbc" offset="0" />
<stop stop-color="#d46767" offset="1" />
</linearGradient>
<linearGradient x1="55.5" y1="42.8" x2="9.55" y2="16.2" id="edgeGradient" gradientUnits="userSpaceOnUse">
<stop stop-color="#a73030" offset="0" />
<stop stop-color="#c65a5a" offset="1" />
</linearGradient>
<radialGradient cx="32.5" cy="29.5" r="26.5" fx="32.5" fy="29.5" id="shadowGradient" gradientUnits="userSpaceOnUse">
<stop stop-color="#c0c0c0" offset="0" />
<stop stop-color="#c0c0c0" offset="0.88" />
<stop stop-color="#c0c0c0" stop-opacity="0" offset="1" />
</radialGradient>
</defs>
<circle cx="32.5" cy="29.5" r="26.5" transform="matrix(13.9,0,0,13.9,-78,-1030)" id="shadow" style="fill:url(#shadowGradient)" />
<circle cx="31" cy="31" r="25.8" transform="matrix(13,0,0,13,-50.6,-1040)" id="field" style="fill:url(#fieldGradient);stroke:url(#edgeGradient);stroke-width:2" />
<path d="m 211,-777 45,0 c 21,-24 44,-42 68,-53 8,0 14,-1 17,-1 11,0 22,2 36,6 l 10,-6 13,0 c 30,0 45,11 45,32 0,2 0,3 0,6 22,2 33,12 33,31 0,2 -1,5 -1,9 8,2 14,5 18,11 5,5 7,11 7,19 0,6 -3,13 -7,20 11,11 16,25 16,39 0,17 -9,30 -27,40 -18,10 -42,15 -72,15 l -7,0 c 2,19 8,36 17,53 l 4,9 c 11,20 16,35 16,46 0,30 -16,49 -48,57 l -8,2 -16,-68 -56,-59 c -4,-5 -10,-14 -20,-26 l -8,-12 c -10,-12 -16,-20 -20,-22 -4,-3 -10,-4 -18,-4 l -36,0 c -10,-24 -16,-48 -16,-72 0,-24 5,-48 15,-72 z" fill="#FFF"/>
<path d="m 203,-785 48,0 c 22,-25 46,-44 72,-55 8,-1 14,-1 18,-1 10,0 23,2 37,6 l 11,-6 14,0 c 32,0 47,11 47,33 0,2 0,4 0,6 23,2 34,13 34,33 0,2 0,5 0,9 8,3 15,6 19,12 5,5 7,12 7,20 0,6 -3,14 -7,21 11,12 17,26 17,41 0,18 -10,32 -29,43 -19,10 -44,16 -75,16 l -8,0 c 2,19 8,38 17,56 l 5,9 c 12,21 17,37 17,49 0,31 -17,51 -50,59 l -10,3 -16,-72 -59,-63 c -4,-5 -11,-14 -21,-27 l -9,-12 c -10,-13 -17,-21 -21,-24 -4,-3 -10,-4 -19,-4 l -37,0 c -12,-25 -18,-50 -18,-76 0,-25 6,-50 16,-76 z m 11,17 c -7,19 -10,38 -10,56 0,21 3,41 11,62 27,0 44,1 50,4 7,4 18,15 31,34 6,8 14,18 25,32 l 64,68 13,60 c 22,-8 32,-21 32,-41 0,-11 -3,-22 -10,-34 l -5,-7 c -16,-28 -25,-55 -25,-80 l 0,-9 12,0 c 33,0 59,-3 76,-10 17,-7 26,-17 26,-31 0,-12 -4,-23 -13,-31 -9,-9 -20,-13 -33,-13 l -20,0 -58,26 c 9,13 21,20 36,20 4,0 8,-1 14,-3 6,-1 13,-4 22,-7 l 15,-1 15,16 -26,0 c -8,4 -15,6 -21,7 -6,2 -12,3 -17,3 -27,0 -47,-14 -60,-42 l 11,-5 c -13,-7 -24,-18 -31,-35 l 12,-5 c -9,-6 -18,-17 -27,-32 l 20,-9 c -11,-8 -20,-19 -26,-34 l 39,-18 c -6,-1 -12,-2 -16,-2 l -13,1 c -28,16 -51,36 -69,60 l -44,0 z m 146,46 c 8,10 17,17 27,20 l 48,-22 17,0 c 16,0 28,2 37,7 2,-4 4,-8 4,-11 0,-7 -4,-12 -10,-15 -7,-3 -16,-5 -29,-5 l -34,0 -60,26 z m -13,-37 c 1,1 2,2 2,3 5,6 11,11 18,14 l 50,-22 52,1 1,-5 c 0,-12 -13,-18 -38,-18 l -24,0 -61,27 z m -7,-43 c 1,1 2,3 3,4 4,6 10,11 16,16 l 46,-21 29,0 0,-2 c 0,-14 -10,-21 -31,-21 l -10,0 -53,24 z" fill="#000"/>
</svg>'! !

!KSFactory methodsFor: 'graphics-data' stamp: 'ael 1/21/2013 12:02'!
thumbUpSVG
	"Based on http://commons.wikimedia.org/wiki/File:Thumb_up_icon.svg licensed under CC-SA by Piastu"
	^'<svg>
<defs>
<linearGradient x1="43" y1="7.01" x2="22" y2="52" id="fieldGradient" gradientUnits="userSpaceOnUse">
<stop stop-color="#c4febc" offset="0" />
<stop stop-color="#69d467" offset="1" />
</linearGradient>
<linearGradient x1="55.5" y1="42.8" x2="9.55" y2="16.2" id="edgeGradient" gradientUnits="userSpaceOnUse">
<stop stop-color="#35a730" offset="0" />
<stop stop-color="#5cc65a" offset="1" />
</linearGradient>
<radialGradient cx="32.5" cy="29.5" r="26.5" fx="32.5" fy="29.5" id="shadowGradient" gradientUnits="userSpaceOnUse">
<stop stop-color="#c0c0c0" offset="0" />
<stop stop-color="#c0c0c0" offset="0.88" />
<stop stop-color="#c0c0c0" stop-opacity="0" offset="1" />
</radialGradient>
</defs>
<circle cx="32.5" cy="29.5" r="26.5" transform="matrix(13.9,0,0,13.9,-78,-36.4)" style="fill:url(#shadowGradient)" />
<circle cx="31" cy="31" r="25.8" transform="matrix(13,0,0,13,-50.6,-50.6)" style="fill:url(#fieldGradient);stroke:url(#edgeGradient);stroke-width:2" />
<path d="m 211,495 45,0 c 21,24 44,41 68,52 8,1 14,1 17,1 11,0 22,-2 36,-5 l 10,5 13,0 c 30,0 45,-11 45,-32 0,-1 0,-3 0,-5 22,-2 33,-13 33,-32 0,-2 -1,-4 -1,-8 8,-2 14,-6 18,-11 5,-5 7,-12 7,-19 0,-6 -3,-13 -7,-20 11,-12 16,-25 16,-40 0,-16 -9,-30 -27,-40 -18,-10 -42,-15 -72,-15 l -7,0 c 2,-18 8,-36 17,-53 l 4,-8 c 11,-20 16,-36 16,-47 0,-30 -16,-49 -48,-57 l -8,-2 -16,68 -56,60 c -4,4 -10,13 -20,26 l -8,11 c -10,12 -16,20 -20,23 -4,2 -10,4 -18,4 l -36,0 c -10,23 -16,47 -16,71 0,24 5,48 15,73 z" fill="#FFF"/>
<path d="m 203,502 48,0 c 22,26 46,44 72,56 8,1 14,1 18,1 10,0 23,-2 37,-6 l 11,6 14,0 c 32,0 47,-11 47,-34 0,-1 0,-3 0,-6 23,-2 34,-13 34,-33 0,-2 0,-5 0,-9 8,-2 15,-6 19,-11 5,-6 7,-12 7,-20 0,-7 -3,-14 -7,-22 11,-12 17,-26 17,-41 0,-18 -10,-32 -29,-42 -19,-11 -44,-16 -75,-16 l -8,0 c 2,-20 8,-38 17,-56 l 5,-9 c 12,-21 17,-38 17,-49 0,-32 -17,-52 -50,-60 l -10,-2 -16,71 -59,63 c -4,5 -11,14 -21,27 l -9,12 c -10,13 -17,21 -21,24 -4,3 -10,5 -19,5 l -37,0 c -12,24 -18,49 -18,75 0,25 6,51 16,76 z m 11,-16 c -7,-20 -10,-38 -10,-56 0,-21 3,-42 11,-62 27,0 44,-2 50,-5 7,-3 18,-14 31,-34 6,-7 14,-18 25,-31 l 64,-69 13,-60 c 22,8 32,21 32,42 0,10 -3,21 -10,34 l -5,7 c -16,28 -25,54 -25,79 l 0,9 12,0 c 33,0 59,4 76,10 17,7 26,17 26,31 0,13 -4,23 -13,32 -9,8 -20,12 -33,12 l -20,1 -58,-27 c 9,-13 21,-20 36,-20 4,0 8,1 14,3 6,2 13,4 22,8 l 15,0 15,-16 -26,0 c -8,-3 -15,-6 -21,-7 -6,-2 -12,-2 -17,-2 -27,0 -47,14 -60,41 l 11,6 c -13,6 -24,18 -31,34 l 13,6 c -10,6 -19,16 -28,31 l 20,10 c -11,8 -20,19 -26,33 l 39,18 c -6,1 -12,2 -16,2 l -13,0 c -28,-17 -51,-37 -69,-60 l -44,0 z m 146,-47 c 8,-10 17,-16 27,-19 l 48,21 17,0 c 16,0 28,-2 37,-6 2,3 4,7 4,11 0,6 -4,11 -10,14 -7,4 -16,5 -29,5 l -34,0 -60,-26 z m -13,38 c 1,-2 2,-3 2,-4 5,-6 11,-10 18,-14 l 50,22 52,0 1,4 c 0,13 -13,19 -38,19 l -24,0 -61,-27 z m -7,43 c 1,-2 2,-3 3,-5 4,-5 10,-10 16,-15 l 46,20 29,0 0,2 c 0,15 -10,22 -31,22 l -10,0 -53,-24 z" fill="#000"/>
</svg>'! !

!KSFactory methodsFor: 'halo' stamp: 'yo 2/1/2013 11:23'!
newHalo
	| inst b lighterOrange lighterRed sel |
	inst := KSBox extent: -1@ -1 fill: Color transparent.
	inst name: 'halo'.
	(inst at: #visible) set: false.
	lighterOrange := (Color orange) mixed: 0.4 with: Color white.
	lighterRed := (Color red) mixed: 0.4 with: Color white.

"Listed clockwise from top-left...
	  	size			shape					color			name		selector"
	{
		{16@16.		nil.						#contrast.		'haloR'.		#beHaloEdgeHandler:}.
		{16@16.		nil.						#contrast.		'haloB'.		#beHaloEdgeHandler:}.
		{16@16.		nil.						#contrast.		'haloL'.		#beHaloEdgeHandler:}.
		{16@16.		nil.						#contrast.		'haloT'.		#beHaloEdgeHandler:}.

		{20@20.		self resizeHIcon.		#white.			1.0@0.5.	#beHaloResizeHandler:}.
		{20@20.		self resizeVIcon.		#white.			0.5@1.0.	#beHaloResizeHandler:}.
		{20@20.		self menuIcon.			lighterRed.		'menu'. 		#showDefaultMenu}.
		{20@20.		self duplicateIcon.		nil.				'duplicate'. 	#copyFromHalo}.
		{20@20.		self menuIcon.			lighterOrange.	'debug'. 	#showDebugMenu}.
		{20@20.		self rotationIcon.		#white.			'rot'. 		#beHaloRotationHandler:}.
		{20@20.		self scaleIcon.			#white. 		'scale'. 		#beHaloScaleHandler:}
} do: [:tuple |
	b := KSBox new.
	b shape: (tuple second ifNil: [KSShape extent: tuple first fill: Color transparent]).
	b wantsHaloFromClick: false.
	tuple third ifNotNil: [
		b fill: (tuple third = #contrast
			ifTrue: [GeziraFill contrastiveOver: 0.2]
			ifFalse: [Color colorFrom: tuple third])].
	b name: tuple fourth asString.
	inst addAsPartsFirst: b.
	((sel := tuple fifth) last = $:)
		ifTrue: [b perform: sel allButLast asSymbol]
		ifFalse: [
			b attachButtonHandler.
			b at: #actionSelector put: sel.
			b beHaloMenuActionHandler].
	].
	^ inst! !

!KSFactory methodsFor: 'helpers' stamp: 'yo 1/22/2013 15:54'!
addBorderTo = (box, extent, whichCorners, whichEdges) ->
	var shape = box.shape()
	var edges = (x.asSymbol() for x in whichEdges)
	var corners = (x.asSymbol() for x in whichCorners)
	var borders = GeziraPath._rect_radius_at_edges(P(0, 0).extent(extent), 2, corners, edges)
	for border in borders
		border.stroke(GeziraStroke.width(0.5))
		border.fill(KSFactory.default().theme.edgeColor)
	shape.elements([
		(GeziraPath._rect_radius_at(P(0, 0).extent(extent), 2, corners)).fill(this.buttonGradient())].concat(
			shape.elements()).concat(
				borders))
	box.shape(shape)
	return box! !

!KSFactory methodsFor: 'helpers' stamp: 'ael 3/7/2013 00:22'!
addButtonFillAndBorderTo = (box, extent, whichCorners, whichEdges) ->
	var shape = box.shape()
	var edges = (x.asSymbol() for x in whichEdges)
	var corners = (x.asSymbol() for x in whichCorners)

	// first the default (quiescent) border edges
	var borders = GeziraPath._rect_radius_at_edges(P(0, 0).extent(extent), 2, corners, edges)
	for border in borders
		border.stroke(GeziraStroke.width(0.5))
		border.fill(KSFactory.default().theme.edgeColor)
	box.defaultShapeElements = [
		(GeziraPath._rect_radius_at(P(0, 0).extent(extent), 2, corners)).fill(this.buttonGradient())].concat(shape.elements().copy()).concat(borders)

	// then the state to show when entered
	var closedBorder = GeziraPath._rect_radius_at(P(0, 0).extent(extent), 2, corners)
	closedBorder.stroke(GeziraStroke.width(1))
	closedBorder.fill(KSFactory.default().theme.edgeColor)
	box.enteredShapeElements = [
		(GeziraPath._rect_radius_at(P(0, 0).extent(extent), 2, corners)).fill(this.buttonGradient())].concat(shape.elements().copy()).concat([closedBorder])

	box.shape(shape.elements(box.defaultShapeElements))
	box.eval('this.shapeSetter = $$(@entered.mapE((e) -> this.shape(@shape.elements(if e then @enteredShapeElements else @defaultShapeElements))))')! !

!KSFactory methodsFor: 'helpers' stamp: 'yo 1/16/2013 14:40'!
buttonGradient
	^ (self graphicPathsNamed: 'button') last fill.! !

!KSFactory methodsFor: 'helpers' stamp: 'tk 2/27/2013 14:30'!
characterIconWithString: string style: num size: size offset: off
	| s label ss layout |
	label := KSBox extent: 1000@100 fill: Color white.
	(layout := KSTextLayout new) installTo: label.
	layout inset: 0@0.
	layout at: #font put: (((KSFamily withName: #TimesNewRoman) withStyle: num) withSize: size).
	layout addAll: string.
	label layOut.
	ss := label contents collect: [:b |
		s := b shape.
		s elements first points collect: [:a | a asArray collect: [:p | (s transform transformPoint: p) + b topLeft + off]]].
	^ (KSShape new
		elements: 
			(ss asArray collect: [:t | (GeziraPath new points: t) fill: Color black asGeziraFill]);
		borderWidth: 1;
		borderFill: Color darkGray).! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/28/2013 11:36'!
clickIcon
	| hand |
	hand := {
74@105. 87@95. 98@105. 98@105. 98@105. 98@170.
98@170. 98@170. 98@146. 98@146. 112@139. 122@150. 
122@150. 122@150. 122@168. 122@168. 122@168. 122@150.
122@150. 132@144. 145@153. 145@153. 145@153. 145@173.
145@173. 145@173. 145@158. 145@158. 158@152. 169@165. 
169@165. 169@165. 169@220. 169@220. 169@220. 152@264.
152@264. 152@264. 80@264. 80@264. 80@264. 51@203. 
51@203. 51@203. 51@174. 51@174. 62@168. 74@174.
74@174. 74@174. 74@200. 74@200. 74@200. 74@105}.

	^ KSShape new elements:
		{(GeziraPath polygon: {73@0. 101@61. 158@38. 125@89. 175@130. 110@128. 100@177. 80@132. 12@156. 49@103. 0@64. 62@66. 73@0}) fill: (Color r: 1.0 g: 0.903 b: 0.0).
		(GeziraPath new points: {hand}) fill: Color white.
		(GeziraPath new points: {hand}) fill: Color black; stroke: (GeziraStroke round: 8)}! !

!KSFactory methodsFor: 'icons' stamp: 'yo 2/11/2013 11:42'!
colorIcon
	^ KSShape new elements: {
		(GeziraPath rect: (0@0 corner: 20@20) radius: 0) fill: 
		(Form
		extent: 20@20
		depth: 32
		fromArray: #( 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4278190081 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294960879 4294960872 4294962406 4294964198 4294966246 4294770662 4294246374 4293787622 4293328871 4293328878 4293328886 4293328894 4293327359 4293325567 4293323519 4293519103 4294043391 4294567679 4294960895 4294960887 4294954207 4294954192 4294957260 4294961356 4294965196 4294574028 4293525452 4292542412 4291624910 4291624925 4291624941 4291624956 4291621887 4291618047 4291614207 4292070655 4293053695 4294102271 4294954238 4294954222 4294947791 4294947768 4294952371 4294958259 4294964147 4294311859 4292804531 4291297203 4289986485 4289986508 4289986531 4289986554 4289981951 4289976063 4289970175 4290622463 4292129791 4293637119 4294947837 4294947814 4294941119 4294941088 4294947225 4294955161 4294962841 4294115225 4292083609 4290051993 4288282524 4288282555 4288282586 4288282617 4288276479 4288268799 4288260863 4289174015 4291140095 4293171711 4294941180 4294941149 4294934702 4294934664 4294942080 4294952064 4294961792 4293853056 4291362688 4288872320 4286644100 4286644138 4286644176 4286644215 4286636799 4286626815 4286617087 4287660287 4290216191 4292706559 4294934779 4294934741 4294928030 4294927984 4294937190 4294948966 4294960742 4293656422 4290641766 4287627110 4284940139 4284940185 4284940231 4284940277 4284931327 4284919295 4284907519 4286211839 4289226495 4292241151 4294928122 4294928076 4294921358 4294921304 4294932044 4294945868 4294959692 4293459788 4289920844 4286381900 4283236178 4283236232 4283236286 4283236339 4283225855 4283212031 4283198207 4284763391 4288302335 4291841279 4294921465 4294921412 4294914942 4294914880 4294927155 4294942771 4294958387 4293197619 4289199923 4285136691 4281597754 4281597815 4281597876 4281597938 4281585919 4281570047 4281554431 4283315199 4287312895 4291376127 4294915065 4294915003 4294908270 4294908200 4294922009 4294939673 4294957337 4293000985 4288479001 4283957017 4279893793 4279893862 4279893931 4279894000 4279880447 4279862783 4279844863 4281866751 4286388735 4290910719 4294908408 4294908339 4294901853 4294901777 4294916864 4294936576 4294956288 4292738816 4287758080 4282711808 4278255368 4278255445 4278255522 4278255598 4278240511 4278220799 4278201087 4280418559 4285399295 4290445567 4294902007 4294901930 4293263444 4293263375 4293276928 4293294592 4293312512 4291290624 4286768640 4282246656 4278248967 4278249036 4278249105 4278249174 4278235366 4278217702 4278200038 4280156390 4284678374 4289200358 4293263582 4293263513 4291559499 4291559437 4291571456 4291587328 4291602944 4289842176 4285844480 4281781248 4278242310 4278242372 4278242433 4278242495 4278230220 4278214604 4278198988 4279959756 4283957452 4288020684 4291559621 4291559560 4289921089 4289921036 4289931520 4289945344 4289959168 4288393984 4284855040 4281316096 4278235910 4278235963 4278236017 4278236071 4278225331 4278211507 4278197683 4279697587 4283236531 4286775475 4289921197 4289921143 4288217144 4288217098 4288226048 4288238080 4288249856 4286945536 4283930880 4280916224 4278229253 4278229299 4278229345 4278229391 4278220185 4278208409 4278196633 4279500953 4282515609 4285530265 4288217236 4288217190 4286578735 4286578696 4286586368 4286596096 4286605824 4285497344 4282941440 4280451072 4278222852 4278222890 4278222929 4278222967 4278215296 4278205312 4278195584 4279304320 4281794688 4284285056 4286578811 4286578773 4284874789 4284874758 4284880896 4284888576 4284896512 4283983360 4282017280 4279985664 4278216195 4278216226 4278216256 4278216287 4278210150 4278202214 4278194534 4279042150 4281073766 4283105382 4284874851 4284874820 4283170844 4283170821 4283175424 4283181312 4283187200 4282534912 4281027584 4279520256 4278209538 4278209561 4278209584 4278209607 4278205004 4278199116 4278193228 4278845516 4280352844 4281860172 4283170890 4283170867 4281532434 4281532419 4281535488 4281539328 4281543168 4281086720 4280103680 4279055104 4278203137 4278203153 4278203168 4278203183 4278200115 4278196019 4278192179 4278583347 4279631923 4280614963 4281532465 4281532450)
	offset: 0@0) asGeziraFill}! !

!KSFactory methodsFor: 'icons' stamp: 'yo 2/26/2013 19:37'!
cursorIcon
	| shape |
	shape := KSShape new elements: {
		(GeziraPath polygon: {0@0. 0@10. 8@6. 0@0}) fill: Color black.
		(GeziraPath line: 4@8 to: 6@14) stroke: (GeziraStroke round: 2); fill: Color black.
	}.
	^ shape! !

!KSFactory methodsFor: 'icons' stamp: 'yo 2/11/2013 19:34'!
dismissIcon
	^ KSShape new
		elements: ({
			(GeziraPath rect: (1@1 corner: 19@19) radius: 3)
				fill: (GeziraFill gradient: {0->Color white. 1 -> Color gray} direction: 0@20 offset: 0).
			(GeziraPath rect: (1@1 corner: 19@19) radius: 3)
				fill: (GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@20 offset: 0); stroke: (GeziraStroke width: 0.5).
			(GeziraPath line: 6@6 to: 14@14)
				stroke: (GeziraStroke round: 2).
			(GeziraPath line: 6@14 to: 14@6)
				stroke: (GeziraStroke round: 2)} collect: [:e |
			e stroke ifNotNil: [e fill: (GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@20 offset: 0)] ifNil: [e]])! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:47'!
duplicateIcon
	| shape borderFill |
	borderFill := GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@18 offset: 0.
	shape := KSShape extent: 18@18 fill: (GeziraFill gradient: {0->Color white. 1 -> Color green muchLighter} direction: 0@18 offset: 0).
	shape borderWidth: 0.5; borderFill: borderFill; cornerRadius: 3.
	shape elements: (shape elements, ({
		(GeziraPath rect: (4@4 corner: 11@11) radius: 0) stroke: (GeziraStroke round: 1).
		(GeziraPath rect: (7@7 corner: 14@14) radius: 0) stroke: (GeziraStroke round: 1)
	} collect: [:s | s fill: borderFill])).
	^ shape.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:55'!
firstIcon
	^ KSShape new
		elements: {
			(GeziraPath polygon: {15@0. 15@15. 5@7. 5@15. 3@15. 3@0. 5@0. 5@7})
				fill: Color brown}.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:12'!
fontBoldIcon
	| s minMax minY maxY strut |
	s := self characterIconWithString: 'B' style: 1 size: 12 offset: 5@3.
	minMax := s elements collect: [:a | a minMax].
	minY := (Array newFrom: (minMax collect: [:m | m origin y])) min.
	maxY := (Array newFrom: (minMax collect: [:m | m corner y])) max.
	strut := (GeziraPath line: 0@(minY-2) to: 0@(maxY+2)) fill: Color transparent.
	^ s elements: (s elements, {strut})! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:50'!
fontColorIcon
	| s line |
	s := self characterIconWithString: 'A' style: 0 size: 12 offset: 5@0.
	line := ((GeziraPath polyline: {0@0. (s extent x@0)} + (s offset x negated@16)) fill: Color red asGeziraFill)
		stroke: (GeziraStroke width: 4).
	s elements: s elements, {line}.
	^ s.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/18/2013 22:28'!
fontEnlargeIcon
	| s |
	s := self characterIconWithString: 'A' style: 0 size: 12 offset: 3@5.
	^ s elements: s elements, {(GeziraPath polygon: ({12@6. 15@3. 18@6})) fill: Color blue}.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:25'!
fontItalicIcon
	| s minMax minY maxY minX maxX strut |
	s := self characterIconWithString: 'I' style: 2 size: 13 offset: 7@3.
	minMax := s elements collect: [:a | a minMax].
	minY := (Array newFrom: (minMax collect: [:m | m origin y])) min.
	maxY := (Array newFrom: (minMax collect: [:m | m corner y])) max.
	minX := (Array newFrom: (minMax collect: [:m | m origin x])) min.
	maxX := (Array newFrom: (minMax collect: [:m | m corner x])) max.
	strut := (GeziraPath line: minX-1@(minY-1.5) to: maxX+1@(maxY+2)) fill: Color transparent.
	^ s elements: (s elements, {strut})! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/18/2013 22:28'!
fontShrinkIcon
	| s |
	s := self characterIconWithString: 'A' style: 0 size: 7 offset: 6@7.
	^ s elements: s elements, {(GeziraPath polygon: ({12@3. 15@6. 18@3})) fill: Color blue}.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:34'!
fontStruckOutIcon
	| s line h minY maxY minX maxX minMax strut |
	s := self characterIconWithString: 'abc' style: 0 size: 10 offset: 2@5.
	minMax := s elements collect: [:a | a minMax].
	minY := (Array newFrom: (minMax collect: [:m | m origin y])) min.
	maxY := (Array newFrom: (minMax collect: [:m | m corner y])) max.
	minX := (Array newFrom: (minMax collect: [:m | m origin x])) min.
	maxX := (Array newFrom: (minMax collect: [:m | m corner x])) max.
	h := (maxY + minY) / 2.
	strut := (GeziraPath line: 10@(h-4) to: 10@(h+4)) fill: Color transparent.
	line := ((GeziraPath polyline: {minX@h. maxX@h}) fill: Color black asGeziraFill)
		stroke: (GeziraStroke round: 1).
	s elements: s elements, {line}, {strut}.
	^ s.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:39'!
fontSubscriptIcon
	| s |
	s := self fontSuperAndSubscriptIcon.
	s elements first fill: Color transparent.
	s elements second fill: Color blue.
	^ s! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:39'!
fontSuperAndSubscriptIcon
	| x s outline minMax minY maxY minX maxX t |
	x := self characterIconWithString: 'x' style: 0 size: 12 offset: 5@2.
	s := self characterIconWithString: '2' style: 0 size: 5 offset: 14@2.
	t := self characterIconWithString: '2' style: 0 size: 5 offset: 14@12.
	minMax := x elements collect: [:a | a minMax].
	minY := (Array newFrom: (minMax collect: [:m | m origin y])) min.
	maxY := (Array newFrom: (minMax collect: [:m | m corner y])) max.
	minX := (Array newFrom: (minMax collect: [:m | m origin x])) min.
	maxX := (Array newFrom: (minMax collect: [:m | m corner x])) max.
	outline := GeziraFilledPath rect: ((minX@minY corner: maxX@maxY) expandBy: 2) radius: 0.
	s elements: s elements, t elements, (x elements collect: [:e | e fill: Color black]).
	^ s! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:39'!
fontSuperscriptIcon
	| s |
	s := self fontSuperAndSubscriptIcon.
	s elements second fill: Color transparent.
	s elements first fill: Color blue.
	^ s! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:29'!
fontUnderlineIcon
		| s underline minMax minY maxY minX maxX strut |
	s := self characterIconWithString: 'U' style: 0 size: 12 offset: 5@3.
	minMax := s elements collect: [:a | a minMax].
	minY := (Array newFrom: (minMax collect: [:m | m origin y])) min.
	maxY := (Array newFrom: (minMax collect: [:m | m corner y])) max.
	minX := (Array newFrom: (minMax collect: [:m | m origin x])) min.
	maxX := (Array newFrom: (minMax collect: [:m | m corner x])) max.
	strut := (GeziraPath line: 0@(minY-2) to: 0@(maxY+2)) fill: Color transparent.
	underline := (GeziraPath polyline: {minX@(maxY + 1.5). maxX@(maxY+1.5)}) fill: Color black asGeziraFill;
		stroke: (GeziraStroke round: 1).
	s elements: s elements, {underline}, {strut}.
	^ s.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:49'!
fontbackgroundIcon
	| s highlight |
	s := self characterIconWithString: 'ab' style: 0 size: 9 offset: 5@5.
	highlight := (GeziraPath rect: ((0@0 extent: (s extent + (2@5))) translatedBy: s offset negated - (1@1)) radius: 0) fill: (Color r: 0.7 g: 1 b: 0.7).
	s elements: {highlight}, s elements.
	^ s.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:59'!
iconNamed: aString
	^ (KSBox withShape: (self perform: (aString, 'Icon') asSymbol)) name: aString; yourself! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:55'!
lastIcon
	^ KSShape new
		elements: {
			(GeziraPath polygon: {5@0. 5@15. 15@7. 15@15. 17@15. 17@0. 15@0. 15@7})
				fill: Color brown}! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 12:48'!
linkIcon
	^ KSShape new elements: {
	(GeziraPath new points: {((GeziraPath rect: (2@2 extent: 5@2) radius: 1) points first), (GeziraPath rect: (0@0 extent: 9@6) radius: 3) points first reversed}) fill: (GeziraFill gradient: {0-> (Color gray: 0.6). 0.4 -> (Color gray: 0.90). 0.6 -> (Color gray: 0.90). 1.0 -> (Color gray: 0.6)} center: 3.5@3 radius: 3).

	(GeziraPath new points: {(((GeziraPath rect: (2@2 extent: 5@2) radius: 1) points first), (GeziraPath rect: (0@0 extent: 9@6) radius: 3) points first reversed) + (10@0)}) fill: (GeziraFill gradient: {0-> (Color gray: 0.6). 0.4 -> (Color gray: 0.9). 0.6 -> (Color gray: 0.9). 1.0 -> (Color gray: 0.6)} center: 16@3 radius: 3).

	(GeziraPath rect: ((0@0 extent: 9@2) translatedBy: 4.5@2) radius: 2) fill: (GeziraFill gradient: {0.0 -> (Color gray: 0.6). 0.4 -> (Color gray: 0.9). 0.6 -> (Color gray: 0.9). 1.0 -> (Color gray: 0.6)} direction: 0@2 offset: -0.8).
	(GeziraPath rect: (10 @ -6 extent: 0@16) radius: 0) fill: Color black
	}! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:44'!
menuIcon
	| shape borderFill |
	borderFill := GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@18 offset: 0.
	shape := KSShape extent: 18@18 fill: (GeziraFill gradient: {0->Color white. 1 -> Color cyan muchLighter} direction: 0@18 offset: 0).
	shape borderWidth: 0.5; borderFill: borderFill; cornerRadius: 3.
	shape elements: (shape elements, {
		(GeziraPath polyline: {4@7. 9@11. 14@7}) stroke: (GeziraStroke round: 2); fill: borderFill}).
	^ shape.! !

!KSFactory methodsFor: 'icons' stamp: 'ael 3/21/2013 23:02'!
newLineIcon
	^ KSShape new
		elements: ({
			(GeziraPath rect: (1@1 corner: 19@19) radius: 3)
				fill: (GeziraFill gradient: {0->Color white. 1 -> Color gray} direction: 0@20 offset: 0).
			(GeziraPath rect: (1@1 corner: 19@19) radius: 3)
				fill: (GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@20 offset: 0); stroke: (GeziraStroke width: 0.5).
			(GeziraPath line: 6@10 to: 14@10)
				stroke: (GeziraStroke round: 2)} collect: [:e |
			e stroke ifNotNil: [e fill: (GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@20 offset: 0)] ifNil: [e]])! !

!KSFactory methodsFor: 'icons' stamp: 'ael 3/21/2013 23:18'!
newRectIcon
	^ KSShape new
		elements: ({
			(GeziraPath rect: (1@1 corner: 19@19) radius: 3)
				fill: (GeziraFill gradient: {0->Color white. 1 -> Color gray} direction: 0@20 offset: 0).
			(GeziraPath rect: (1@1 corner: 19@19) radius: 3)
				fill: (GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@20 offset: 0); stroke: (GeziraStroke width: 0.5).
			(GeziraPath rect: (6@6 corner: 14@14) radius: 0)
				fill: (Color black asGeziraFill); stroke: (GeziraStroke width: 0.5) })! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:56'!
nextIcon
	^ KSShape new
		elements: {
			(GeziraPath polygon: {5@0. 5@15. 15@7}) fill: Color brown}.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 2/11/2013 20:05'!
plusIcon
	^ KSShape new
		elements: ({
			(GeziraPath rect: (1@1 corner: 19@19) radius: 3)
				fill: (GeziraFill gradient: {0->Color white. 1 -> Color gray} direction: 0@20 offset: 0).
			(GeziraPath rect: (1@1 corner: 19@19) radius: 3)
				fill: (GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@20 offset: 0); stroke: (GeziraStroke width: 0.5).
			(GeziraPath line: 10@5 to: 10@15)
				stroke: (GeziraStroke round: 2).
			(GeziraPath line: 5@10 to: 15@10)
				stroke: (GeziraStroke round: 2)} collect: [:e |
			e stroke ifNotNil: [e fill: (GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} direction: 0@20 offset: 0)] ifNil: [e]])! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:56'!
prevIcon
	^ KSShape new
		elements: {
			(GeziraPath polygon: {15@0. 15@15. 5@7}) fill: Color brown}! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/28/2013 11:38'!
rabbitHideIcon
	| s |
	s := self hatShape.
	s elements: {
		s elements first.
		s elements second.
		s elements third.
		(GeziraPath new points: {{100@0. 100@0. 100@0}}) fill: Color white}.
	^ s.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/28/2013 11:37'!
rabbitIcon
	| s |
	s := self hatShape.
	s elements: {
		s elements first.
		s elements second.
		(GeziraPath new points: {self rabbitPath}) fill: (Color r: 1.0 g: 0.774 b: 0.774).
		(GeziraPath new points: {self rabbitPath}) fill: (Color r: 1.0 g: 0.613 b: 0.613); stroke: (GeziraStroke round: 8).
		s elements third}.
	^ s.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:37'!
resizeHIcon
	| shape |
	shape := KSShape extent: 18@18 fill: Color white.
	shape borderWidth: 0.5; borderFill: Color darkGray; cornerRadius: 3.
	shape elements: (shape elements, ({
			GeziraPath polygon: {2@9. 5@6. 5@12}.
			(GeziraPath polygon: {2@9. 5@6. 5@12}) stroke: (GeziraStroke round: 2).
			(GeziraPath line: 5@9 to: 13@9) stroke: (GeziraStroke width: 2).
			GeziraPath polygon: {16@9. 13@6. 13@12}.
			(GeziraPath polygon: {16@9. 13@6. 13@12}) stroke: (GeziraStroke round: 2)
	} collect: [:s | s fill: Color darkGray])).
	^ shape! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:36'!
resizeVIcon
	| shape |
	shape := KSShape extent: 18@18 fill: Color white.
	shape borderWidth: 0.5; borderFill: Color darkGray; cornerRadius: 3.
	shape elements: (shape elements, ({
		GeziraPath polygon: {9@2. 6@5. 12@5}.
		(GeziraPath polygon: {9@2. 6@5. 12@5}) stroke: (GeziraStroke round: 2).
		(GeziraPath line: 9@5 to: 9@13) stroke: (GeziraStroke width: 2).
		(GeziraPath polygon: {9@16. 6@13. 12@13}) fill: Color darkGray.
		(GeziraPath polygon: {9@16. 6@13. 12@13}) stroke: (GeziraStroke round: 2)
	} collect: [:s | s fill: Color darkGray])).
	^ shape! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:15'!
rotationIcon
	| shape |
	shape := KSShape extent: 18@18 fill: Color white.
	shape borderWidth: 0.5; borderFill: Color darkGray; cornerRadius: 3.
	shape elements: (shape elements, ({
		GeziraPath polygon: {3@5. 5@3. 7@5}.
		GeziraPath path: {{5@5. 5@13. 13@13}}.
		GeziraPath polygon: {13@11. 15@13. 13@15}
	} collect: [:s | s stroke: (GeziraStroke round: 2); fill: Color darkGray])).
	^ shape.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 16:13'!
scaleIcon
	| shape |
	shape := KSShape extent: 18@18 fill: Color white.
	shape borderWidth: 0.5; borderFill: Color darkGray; cornerRadius: 3.
	shape elements: (shape elements, ({
		GeziraPath polygon: {4@4. 7@4. 4@7}.
		GeziraPath line: 5@5 to: 13@13.
		GeziraPath polygon: {14@14. 14@11. 11@14}.
	} collect: [:s | s stroke: (GeziraStroke round: 2); fill: Color darkGray])).
	^ shape! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/22/2013 11:04'!
textBoxedIcon

	| s box minMax minY maxY minX maxX |
	s := self characterIconWithString: 'A' style: 0 size: 12 offset: 5@3.
	minMax := s elements collect: [:a | a minMax].
	minY := (Array newFrom: (minMax collect: [:m | m origin y])) min.
	maxY := (Array newFrom: (minMax collect: [:m | m corner y])) max.
	minX := (Array newFrom: (minMax collect: [:m | m origin x])) min.
	maxX := (Array newFrom: (minMax collect: [:m | m corner x])) max.
	box := (GeziraPath rect: ((minX@minY corner: maxX@maxY) expandBy: 2) radius: 0) fill: Color black;
		stroke: (GeziraStroke round: 1).
	s elements: s elements, {box}.
	^ s.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 13:24'!
textCenterJustificationIcon
	| s |
	s := KSShape extent: 20@20 fill: Color transparent.
	^ s elements: s elements, ({{4@2. 16@2}. {6@5. 14@5}. {4@8. 16@8}. {6@11. 14@11}. {4@14. 16@14}. {6@17. 14@17}} collect: [:e |
		(GeziraPath polyline: e) fill: Color black; stroke: (GeziraStroke width: 1)]).! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 13:46'!
textDistributedJustifyIcon 
	| p newElements s |
	p := {{5@9. 15@9}. {5@12. 15@12}. {5@15. 15@15}. {5@18. 15@18}}.
	s := KSShape extent: 20@20 fill: Color transparent.
	newElements := (p collect: [:e |
		(GeziraPath polyline: e) fill: Color black; stroke: (GeziraStroke width: 1)]),
		{(GeziraPath polyline: {3@3. 3@19}) fill: Color black;
			stroke: (GeziraStroke width: 1).
		(GeziraPath polyline: {17@3. 17@19}) fill: Color black;
			stroke: (GeziraStroke width: 1).
		(GeziraPath polyline: {7@7. 5@5. 7@3}) fill: Color blue;
			stroke: (GeziraStroke width: 1).
		(GeziraPath polyline: {13@7. 15@5. 13@3}) fill: Color blue;
			stroke: (GeziraStroke width: 1).
		(GeziraPath polyline: {5@5. 15@5}) fill: Color blue;
			stroke: (GeziraStroke width: 1)}.
	^ s elements: s elements, newElements.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 13:52'!
textExtraSpaceIcon
	| s minMax minY maxY strut |
	s := self characterIconWithString: 'S' style: 1 size: 12 offset: 5@5.
	minMax := s elements collect: [:a | a minMax].
	minY := (Array newFrom: (minMax collect: [:m | m origin y])) min.
	maxY := (Array newFrom: (minMax collect: [:m | m corner y])) max.
	strut := (GeziraPath line: 0@(minY-2) to: 0@(maxY+2)) fill: Color transparent.
	^ s elements: (s elements copyWith: strut).! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 13:36'!
textJustifyIcon
	| s |
	s := KSShape extent: 20@20 fill: Color transparent.
	^ s elements: s elements, ({{4@2. 16@2}. {4@5. 16@5}. {4@8. 16@8}. {4@11. 16@11}. {4@14. 16@14}. {4@17. 16@17}} collect: [:e |
		(GeziraPath polyline: e) fill: Color black; stroke: (GeziraStroke width: 1)]).! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 13:20'!
textLeftJustificationIcon
	| s |
	s := KSShape extent: 20@20 fill: Color transparent.
	^ s elements: s elements, ({{4@2. 16@2}. {4@5. 13@5}. {4@8. 16@8}. {4@11. 13@11}. {4@14. 16@14}. {4@17. 13@17}} collect: [:e |
		(GeziraPath polyline: e) fill: Color black; stroke: (GeziraStroke width: 1)]).! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 13:49'!
textLineSpacedIcon
	| p newElements s |
	p := {{7@2. 17@2}. {7@6. 17@6}. {7@10. 17@10}. {7@14. 17@14}. {7@18. 17@18}}.
	s := KSShape extent: 20@20 fill: Color transparent.
	newElements := (p collect: [:e |
		(GeziraPath polyline: e) fill: Color black; stroke: (GeziraStroke width: 1)]),
		{(GeziraPath polyline: {2@4. 4@2. 6@4}) fill: Color blue;
			stroke: (GeziraStroke width: 1).
		(GeziraPath polyline: {2@16. 4@18. 6@16}) fill: Color blue;
			stroke: (GeziraStroke width: 1).
		(GeziraPath polyline: {4@2. 4@8}) fill: Color blue;
			stroke: (GeziraStroke width: 1).
		(GeziraPath polyline: {4@18. 4@12}) fill: Color blue;
			stroke: (GeziraStroke width: 1)}.
	^ s elements: s elements, newElements.! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 13:31'!
textRightJustificationIcon
	| s |
	s := KSShape extent: 20@20 fill: Color transparent.
	^ s elements: s elements, ({{4@2. 16@2}. {7@5. 16@5}. {4@8. 16@8}. {7@11. 16@11}. {4@14. 16@14}. {7@17. 16@17}} collect: [:e |
		(GeziraPath polyline: e) fill: Color black; stroke: (GeziraStroke width: 1)]).! !

!KSFactory methodsFor: 'icons' stamp: 'yo 1/25/2013 12:55'!
unlinkIcon
	^ KSShape new elements: {
	(GeziraPath new points: {((GeziraPath rect: (2@2 extent: 5@2) radius: 1) points first), (GeziraPath rect: (0@0 extent: 9@6) radius: 3) points first reversed}) fill: (GeziraFill gradient: {0-> (Color gray: 0.6). 0.4 -> (Color gray: 0.9). 0.6 -> (Color gray: 0.9). 1.0 -> (Color gray: 0.6)} center: 3.5@3 radius: 3).

	(GeziraPath new points: {(((GeziraPath rect: (2@2 extent: 5@2) radius: 1) points first), (GeziraPath rect: (0@0 extent: 9@6) radius: 3) points first reversed) + (10@0)}) fill: (GeziraFill gradient: {0-> (Color gray: 0.6). 0.4 -> (Color gray: 0.9). 0.6 -> (Color gray: 0.9). 1.0 -> (Color gray: 0.6)} center: 16@3 radius: 3)}, 
	((0 to: 7) collect: [:i |
		| rad in out |
		rad := i * (Float pi / 4).
		in := ((rad cos@rad sin) * 2.5) + (10@3).
		out := (rad cos@rad sin) * 4.5 + (10@3).
		(GeziraStrokedPath polyline: {in. out}) fill: (Color white alpha: 0.8); stroke: (GeziraStroke round: 1.2)]),
	{(GeziraPath rect: (10 @ -6 extent: 0@16) radius: 0) fill: Color black}! !

!KSFactory methodsFor: 'ometa ast demo' stamp: 'yo 8/30/2013 10:34'!
makeAst = (node) -> 
	"Return a tree which the first object is the parent and rest are children "
	"KSMorph test31"
	if node.isArray()
		return this.makeAstTree(node)
	else
		return this.makeAstTile(node.asString())! !

!KSFactory methodsFor: 'ometa ast demo' stamp: 'yo 8/30/2013 12:04'!
makeAstChildren = (anArray) ->
	/* "Return sibling tiles" */
	var children = anArray.collect((each) -> this.makeAst(each))
	var background = KSBox.new()
	background.fill(Color.transparent())
	background.layout(KSHorizontalLayout.new())
	background.layout().space(5)
	/*background.layout().justification(#"bottom") */
	background.addAll(children)
	return background! !

!KSFactory methodsFor: 'ometa ast demo' stamp: 'yo 8/30/2013 12:05'!
makeAstConnectors = (label, children) ->
	/* Add connectors into the background layer */
	for each in children.contents().collect((e) -> e.label)
		var c = KSBox.new()
		c.borderFill(Color.blue().alpha(0.3))
		c.borderWidth(6)
		label.topContainer().add(c)
		c.beConnectorHandler(label, each)
		c.updateConnector()
		/*label container on: LLayoutChanged to: cview]*/! !

!KSFactory methodsFor: 'ometa ast demo' stamp: 'yo 8/30/2013 12:03'!
makeAstTile = (aString) ->
	/* Return a tile with the label */
	var tile = this.newLabel(aString)
	tile.fill((Color._h_s_v(aString.hash() % 360, 0.2, 1)))
	tile.name(aString)
	tile.layout().inset(6)
	tile.borderFill(Color.black())
	tile.borderWidth(2)
	tile.cornerRadius(8)
	tile.label = tile
	return tile! !

!KSFactory methodsFor: 'ometa ast demo' stamp: 'yo 8/30/2013 11:49'!
makeAstTree = (anArray) ->
	/* Return a tree which the first object is the parent and rest are children */
	var parent = this.makeAstTile(anArray.first().asString())
	var children = this.makeAstChildren(anArray.allButFirst())
	var background = KSBox.new()
	background.fill(Color.transparent())
	background.layout(KSVerticalLayout.new())
	background.layout().justification(#"center")
	background.layout().space(10)
	background.add(parent)
	background.add(children)
	background.label = parent
	this.makeAstConnectors(parent, children)
	background.doLayout()
	return background! !

!KSFactory methodsFor: 'picture data' stamp: 'yo 9/3/2013 15:17'!
bert
	| url |
	url := 'http://tinlizzie.org/~bert/BertHeadShot2.png'.
	^( [PNGReadWriter formFromFileNamed: (url copyAfterLast: $/)]
		on: FileDoesNotExistException do: [:ex |
			| data |
			data := HTTPSocket httpGet: url.
			FileStream newFileNamed: (url copyAfterLast: $/)
				do: [:file | file binary; nextPutAll: data binary contents].
			PNGReadWriter formFromStream: data]) preMultiplyAlpha! !

!KSFactory methodsFor: 'picture data' stamp: 'yo 9/3/2013 15:16'!
yoshiki
	| url |
	url := 'http://tinlizzie.org/~ohshima/YoshikiHeadShot.png'.
	^ [PNGReadWriter formFromFileNamed: (url copyAfterLast: $/)]
		on: FileDoesNotExistException do: [:ex |
			| data |
			data := HTTPSocket httpGet: url.
			FileStream newFileNamed: (url copyAfterLast: $/)
				do: [:file | file binary; nextPutAll: data binary contents].
			PNGReadWriter formFromStream: data]! !

!KSFactory class methodsFor: 'instance creation' stamp: 'yo 1/22/2013 00:29'!
default
	^ self new themeNamed: 'orange'! !
