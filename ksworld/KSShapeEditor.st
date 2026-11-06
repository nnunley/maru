KSUserEventHandler subclass: #KSShapeEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSShapeEditor methodsFor: 'access' stamp: 'ael 3/27/2013 17:21'!
pathBeingEdited = () ->
	return this.pathEditor().pathBeingEdited()! !

!KSShapeEditor methodsFor: 'access' stamp: 'ael 3/23/2013 16:23'!
pathEditor = () ->
	return @editView.handler! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/1/2013 10:32'!
beDialogExtent = (aPoint) ->
	var box = @whole
	box.cornerRadius(8)
	box.extent(aPoint)
	box.borderWidth(1)
	box.borderFill(box.factory().theme.edgeColor)
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 3/28/2013 11:21'!
decorateElementsList = (list) ->
	var buttons = []
	for element in list.contents
		var dismiss = KSBox.withShape(@whole.factory().dismissIcon())
		element.addAsParts(dismiss)
		dismiss.attachButtonHandler()
		dismiss.rightCenter(P(element.width() * 0.9, element.height()/2.0))
		buttons.push(dismiss)

	var c = KSBox._extent_fill(P(130, 52), Color.transparent())
	c.borderWidth(2)

	var grayDuplicate = @whole.factory().duplicateIcon()
	grayDuplicate.fill(GeziraFill._gradient_direction_offset({0: Color.white(), 1: Color.gray()}.associations(), P(0, 18), 0))

	var f = @whole.factory()
	// maybe we can live with just the duplicate button...
	// [f.newLineIcon(), "lineButton"], [f.newRectIcon(), "rectButton"], [grayDuplicate, "duplicateButton"] 
	var center = P(c.width() * 0.5, c.height()/2.0)
	for spec in [ [grayDuplicate, "duplicateButton"] ]
		var button = KSBox.withShape(spec[0])
		button.attachButtonHandler()
		c.addAsParts(button)
		button.center(center)
		this[spec[1]] = button
		center += P(c.width() * 0.2, 0)

	list.addLast(c)
	list.dismissButtons = buttons! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/2/2013 15:53'!
getHatch = (ext) ->
	this.hatch = Form._extent_depth(ext, 32)
	var g = GeziraCanvas.on(this.hatch)
	g.fill(Color.white().asGeziraFill())
	g.fillRectangle(P(0, 0).corner(ext))
	g.fill(Color.gray(0.75).asGeziraFill())
	var odd = false
	var start
	for y in [-2...ext.y()] by 5
		odd = !!odd
		start = if odd then -2 else 3
		for x in [start...start + ext.x()] by 10
			g.fillRectangle(P(x, y).extent(P(5, 5)))
	return this.hatch! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/11/2013 16:34'!
gradientList = () ->
	var desiredExtent = P(60, 60)
	var result = []

	var g1 = GeziraFillLinearGradient.new()._from_to(P(0, 0), P(0, 84))
	g1._addStop_at([0.9716520309448242, 0.8465298414230347,
		0.5953079462051392, 1.0].asFloatArray(), 0)
	g1._addStop_at([0.9960899353027344, 0.9765396118164063,
		0.939393937587738, 1.0].asFloatArray(), 0.8214285714285714)
	g1._addStop_at([0.9716520309448242, 0.8465298414230347,
		0.5953079462051392, 1.0].asFloatArray(), 0.8314285714285714)
	g1._addStop_at([0.9716520309448242, 0.8465298414230347,
		0.5953079462051392, 1.0].asFloatArray(), 0.8414285714285714)
	g1._addStop_at([0.9716520309448242, 0.8465298414230347,
		0.5953079462051392, 1.0].asFloatArray(), 1.0)
	var grads = [g1]
	var boxes = []

	for grad in grads
		grad._from_to(P(0, 0), P(0, 60))
		var b = KSBox.withShape(KSShape.new().elements([GeziraPath._rect_radius(P(0, 0).extent(P(60, 60)), 0).fill(grad)]))
		boxes.push(b)
	for bb in boxes
		var c = KSBox._extent_fill(P(100, 62), Color.transparent())
		c.borderWidth(2)
		c.add(bb)
		bb.topLeft(P(1, 1))
		result.push(c)
	return result! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 4/8/2013 14:53'!
makeClosePathButton = () ->
	var iconElements = [
		GeziraPath._arc_to_center_radius(0, Float.pi(), P(10, 8), 6).fill(Color.black()).stroke(GeziraStroke.width(2)),
		GeziraPath._line_to(P(5, 8), P(15, 8)).fill(Color.red()).stroke(GeziraStroke.width(2))]
	var box = KSBox._extent_fill(P(19, 19), Color.transparent())
	box.beToggleButtonHandler(false)
	box.highlightEnabled.set(true)
	delete box.changeFill
	box.raisedShape = KSShape.new().elements(this.raisedButtonElements().concat(iconElements))
	box.pressedShape = KSShape.new().elements(this.pushedButtonElements().concat(iconElements))
	box.defaultLooks = () -> @raisedShape
	box.selectedLooks = () -> @pressedShape
	box.enteredLooks = () ->
		var baseShape = (if @selected then @pressedShape else @raisedShape).deepCopy()
		baseShape.fill(baseShape.fill()._mixed_with(0.8, Color.white().asGeziraFill()))
	box.pressedLooks = () ->
		var baseShape = (if @selected then @pressedShape else @raisedShape).deepCopy()
		baseShape.fill(baseShape.fill()._mixed_with(0.8, Color.red().asGeziraFill()))
	box.eval('this.changeShape = $$(this.shape(@looks))')
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 3/22/2013 00:06'!
makeCompositeView = (box, elements) ->
	var s = elements.ppScanObjects().ppCreateObjects()
	box.shape(KSShape.new().elements(elements))
	var desiredExtent = P(140, 140)
	box.scale((desiredExtent.x()/box.width()).min(desiredExtent.y()/box.height().max(1)))
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 3/27/2013 17:53'!
makeEditView = (editBackground) ->
	var box = KSBox._extent_fill(editBackground.bounds().extent(), Color.transparent())
	KSPathEditor.installTo(box)
	box.handleControlKey(false)
	box.listen(["motionQuery"])
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 3/31/2013 20:08'!
makeElementsList = (box) ->
	var max = P(0, 0)
	var desiredExtent = P(130, 50)
	var boxes = []
	for element in box.shape().elements()
		// each thumbnail box in the list has a shape with two elements:
		//   1. a transparent rectangle of the same size as the box (shape) being edited
		//   2. one element from the shape itself
		var b = KSBox.withShape(KSShape.new().elements([GeziraPath._rect_radius(P(0, 0).extent(box.extent()), 0).fill(Color.transparent()), element]))
		max = max.max(b.extent())
		boxes.push(b)
	var scale = (desiredExtent.x()/max.x()).min(desiredExtent.y()/max.y())
	var result = []
	for bb in boxes
		result.push(this.newElement(bb, scale))
	return result! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/11/2013 11:39'!
makeFillButton = () ->
	var box = KSBox.withShape(@whole.factory().colorIcon())
	box.attachButtonHandler()
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/11/2013 16:06'!
makeFillColorPicker = (aColor) ->
	var box = @whole.factory().newColorPicker(aColor)
	box.name("fillColorPicker")
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 4/8/2013 14:55'!
makeFilledPathButton = () ->
	var iconElements = [
		GeziraPath.oval(P(4, 4).extent(P(12, 12))).fill(Color.black()).stroke(GeziraStroke.width(2)),
		GeziraPath.oval(P(5, 5).extent(P(10, 10))).fill(Color.red()._mixed_with(0.6, Color.white()))]
	var box = KSBox._extent_fill(P(19, 19), Color.transparent())
	box.beToggleButtonHandler(false)
	box.highlightEnabled.set(true)
	delete box.changeFill
	box.raisedShape = KSShape.new().elements(this.raisedButtonElements().concat(iconElements))
	box.pressedShape = KSShape.new().elements(this.pushedButtonElements().concat(iconElements))
	box.defaultLooks = () -> @raisedShape
	box.selectedLooks = () -> @pressedShape
	box.enteredLooks = () ->
		var baseShape = (if @selected then @pressedShape else @raisedShape).deepCopy()
		baseShape.fill(baseShape.fill()._mixed_with(0.8, Color.white().asGeziraFill()))
	box.pressedLooks = () ->
		var baseShape = (if @selected then @pressedShape else @raisedShape).deepCopy()
		baseShape.fill(baseShape.fill()._mixed_with(0.8, Color.red().asGeziraFill()))
	box.eval('this.changeShape = $$(this.shape(@looks))')
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/11/2013 16:42'!
makeGradButton = () ->
	var fill = this.gradientList().first().first().shape().fill()
	fill._from_to(P(0, 0), P(0, 20))
	var box = KSBox._extent_fill(P(20, 20), fill)
	box.attachButtonHandler()
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/11/2013 16:43'!
makeGradPicker = () ->
	var box = @whole.factory().newList()
	delete box.doAction
	box.setItems(([b, b] for b in this.gradientList()))
	box.name("gradPicker")
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 4/1/2013 22:46'!
makeLabel = (label) ->
	var font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(9.54)
	var box = KSFactory.default().newLabel(label, Color.transparent(), font)
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 4/2/2013 00:21'!
makeReadout = () ->
	var font = KSFamily.withName("DejaVuSans").withStyle(1).withSize(9.54)
	var box = @whole.factory().newLabel(" ", Color.transparent(), font)
	return box! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/28/2013 19:48'!
makeStrokeSlider = () ->
	return @whole.factory().newSlider(P(40, 10))! !

!KSShapeEditor methodsFor: 'build' stamp: 'yo 2/11/2013 20:10'!
newElement = (box, scale) ->
	var c = KSBox._extent_fill(P(130, 52), Color.transparent())
	c.borderWidth(2)
	box.scale(scale)
	c.add(box)
	box.topLeft(P(1, 1))
	return c! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 4/8/2013 14:50'!
pushedButtonElements
	^ {
		(GeziraPath rect: (0@0 corner: 19@19) radius: 3)
			fill: (GeziraFill gradient: {0->Color lightGray. 1 -> Color white} from: 10@0 to: 19@19).
		(GeziraPath rect: (0@0 corner: 19@19) radius: 3)
			fill: (GeziraFill gradient: {0->Color black. 1 -> Color darkGray} from: 10@0 to: 19@19); stroke: (GeziraStroke width: 1)}! !

!KSShapeEditor methodsFor: 'build' stamp: 'ael 4/8/2013 14:50'!
raisedButtonElements
	^ {
		(GeziraPath rect: (0@0 corner: 19@19) radius: 3)
			fill: (GeziraFill gradient: {0->Color white. 1 -> Color lightGray} from: 10@0 to: 19@19).
		(GeziraPath rect: (0@0 corner: 19@19) radius: 3)
			fill: (GeziraFill gradient: {0->Color veryLightGray. 1 -> Color black} from: 10@0 to: 19@19); stroke: (GeziraStroke width: 0.5)}! !

!KSShapeEditor methodsFor: 'events' stamp: 'ael 4/2/2013 00:08'!
miterToSlider = (aNumber) ->
	return (aNumber+1.0)/(@maxMiter+1)! !

!KSShapeEditor methodsFor: 'events' stamp: 'ael 3/31/2013 21:41'!
refreshShapes = () ->
	this.editBackground.shape(this.editBackground.shape())
	this.compositeView.shape(this.compositeView.shape())
	var thumb = this.pathEditor().thumbBox
	thumb.shape(thumb.shape())! !

!KSShapeEditor methodsFor: 'events' stamp: 'ael 4/2/2013 00:31'!
setStrokeSliders = (stroke) ->
	this.widthSlider.setSliderCurrentValue(this.widthToSlider(stroke.width()))
	this.jointsSlider.setSliderCurrentValue(this.miterToSlider(stroke.joints().limit()))
	this.capsSlider.setSliderCurrentValue(this.miterToSlider(stroke.caps().limit()))! !

!KSShapeEditor methodsFor: 'events' stamp: 'ael 4/2/2013 00:09'!
sliderToMiter = (aNumber) ->
	// round to nearest 0.5, but if less than zero it can only be -1.0
	var rounded = (aNumber * (@maxMiter+1) * 2).rounded() / 2.0
	if rounded <= 0.5
		rounded = 0
	return rounded - 1.0! !

!KSShapeEditor methodsFor: 'events' stamp: 'ael 3/23/2013 14:21'!
sliderToWidth = (aNumber) ->
	// round to nearest 0.5
	return (aNumber * (@maxWidth*2)).rounded() / 2.0! !

!KSShapeEditor methodsFor: 'events' stamp: 'ael 4/2/2013 00:31'!
updateEditView = (thumbBox) ->
	// The user has asked to edit one of the elements.  Set up the path editor appropriately.
	this.editView.deleteGradientTool()

	this.editBackground.shape(thumbBox.shape().copy())	// a shallow copy, sharing all elements

	var editor = this.pathEditor()
	var path = editor.pathBeingEdited()			// extracted from the editBackground
	editor.keepPathClosed.set(path.isClosed())	// start by enforcing the status quo
	editor.thumbBox(thumbBox)
	editor.setupPathHandles()

	var stroke = path.stroke()
	this.filledPathButton.selected.set(!!stroke)
	if stroke
		this.setStrokeSliders(stroke)! !

!KSShapeEditor methodsFor: 'events' stamp: 'ael 3/23/2013 14:23'!
widthToSlider = (aNumber) ->
	return aNumber.asFloat()/@maxWidth! !

!KSShapeEditor methodsFor: 'initialization' stamp: 'ael 4/8/2013 15:54'!
behavior = () ->
	this.listSelected = $$(@list.itemSelected.mapE((ev) ->
		this.updateEditView(ev.handler.first())))

	// if the user toggles the path-closed button, tell the pathEditor
	this.closeButtonWatcher = $$(@closePathButton.selected.mapE((close) ->
		this.pathEditor().keepPathClosed.set(close)
		// opening a path forces it to be non-fill
		if !!close && @filledPathButton.selected
			this.filledPathButton.fireRequest.set(true)))
	// and if the path editor has a new closed-path status, reflect that in the button
	this.closedPathWatcher = $$(@editView.handler.keepPathClosed.mapE((close) ->
		if @closePathButton.selected !!= close
			this.closePathButton.selected.set(close)))

	this.switchFilledPath = $$(@filledPathButton.selected.mapE((filled) ->
		var path = this.pathBeingEdited()
		if path
			if filled					// user wants the path to be filled
				if !!this.pathEditor().keepPathClosed.currentValue()	// it's not constrained to be closed
					if !!path.isClosed()					// and indeed it's not closed
						path.points(path.asClosedPath().stroke(path.stroke()).points())	// assumes single contour
					this.pathEditor().keepPathClosed.set(true)
				if path.stroke()
					this.oldStroke = path.stroke()
					path.stroke(nil)
			else					// user wants an unfilled (stroked) path
				if !!path.stroke()
					path.stroke(this.oldStroke ? GeziraStroke.width(1))
				this.setStrokeSliders(path.stroke())
				
			var showControls = path.stroke().asBoolean()
			for b in @whole.contents()
				if b.isStrokeControl
					b.visible.set(showControls)
			this.refreshShapes()))

	this.fillPickerInvoker = $$(@fillButton.fire.doE(() ->
		var pickTarget = this.pathBeingEdited()
		var picker = @whole.topContainer().invokeColorPicker(@fillButton.topRight() + P(10, 0), pickTarget.fill(), pickTarget, (target, color) ->
			target.fill(color)
			this.refreshShapes())
		picker.name("fillColorPicker")))

	/*
this.gradPickerInvoker = $$(@gradButton.fire.doE(() ->
	this.gradPicker = this.makeGradPicker()
	@whole.addFirst(this.gradPicker)))

this.gradSelected = $$(@gradPicker.itemSelected.mapE((ev) ->
	if this.editBackground.shape().elements().size() > 1
		var fill = ev.handler.first().fill()
		var from = (fill.fromTo().first() / ev.handler.extent()) * @editBackground.extent()
		var to = (fill.fromTo().second() / ev.handler.extent()) * @editBackground.extent()
		fill._from_to(from, to)
		this.pathBeingEdited().fill(fill)
		@gradPicker.delete()
		this.refreshShapes()))
	*/

	this.gradEditorInvoker = $$(@gradButton.fire.doE(() ->
		this.editView.addGradientEditor(this.editBackground, this.pathBeingEdited(), (target, newFill) ->
			this.pathBeingEdited().fill(newFill)
			this.refreshShapes())))

	this.strokeWatcher = $$(mergeE(@widthSlider.sliderValue, @jointsSlider.sliderValue, @capsSlider.sliderValue).doE(() ->
		var path = this.pathBeingEdited()
		var stroke
		if path && (stroke = path.stroke())
			var val = this.sliderToWidth(@widthSlider.sliderValue)
			this.widthReadout.textContents(val.asString())
			stroke.width(val)
			val = this.sliderToMiter(@jointsSlider.sliderValue)
			var isRound = val == -1.0
			this.jointsReadout.textContents(if isRound then "r" else val.asString())
			stroke.joints(if isRound then GeziraStroke.round() else GeziraStroke.miter(val))
			val = this.sliderToMiter(@capsSlider.sliderValue)
			var isRound = val == -1.0
			this.capsReadout.textContents(if isRound then "r" else val.asString())
			stroke.caps(if isRound then GeziraStroke.round() else GeziraStroke.miter(val))
			this.refreshShapes()))

	this.readoutSubject = $$(mergeE(@editView.movingHandle, @editView.highlightHandle))
	this.readoutUpdater = $$(mergeE(@readoutSubject, @readoutSubject.transformation).doE(() ->
		var point
		if @readoutSubject
			point = this.pathEditor().globalPointToEditPoint(@editView.globalPointFor(@readoutSubject.center()))
		this.pointReadout.textContents(if point then point.printShowingDecimalPlaces(1) else " ")))

	this.pointerTracker = $$(@editView.motionQuery.mapE((ev) ->
		this.pointReadout.textContents(this.pathEditor().globalPointToEditPoint(ev.position).printShowingDecimalPlaces(1))))		

	this.list.dismissButtonFire = $$(switchColE(@dismissButtons, "fire"))
	this.dismissButtonFire = $$(@list.dismissButtonFire.mapE((ev) ->
		var element = ev.handler.container()
		@list.remove(element)
		element.delete()
		this.makeCompositeView(this.compositeView, (b.first().shape().elements().second() for b in @list.contents._copyFrom_to(1, @list.contents.size() - 1)))
		if @list.itemSelected.handler === element
			@list.first().fireRequest.set(true)))

	this.editView.listen(["doubleClick", "buttonDown", "buttonUp"])

	this.addElementToList = (shapeElem) ->
		var element = this.newElement(shapeElem, shapeElem.scale())
		@list.last().delete()
		@list.add(@list.makeItem([element, element]))	// menu will contain the element itself
		for button in @list.dismissButtons
			button.delete()
		this.decorateElementsList(@list)
		this.makeCompositeView(this.compositeView, (b.first().shape().elements().second() for b in @list.contents._copyFrom_to(1, @list.contents.size() - 1)))
		element

	/*
// placeholder for a command to add a shape element initialised with a straight line.
this.lineButtonFire = $$(@lineButton.fire.doE(() ->
	var shapeElement = @list.itemSelected.handler.first().copy()
	var element = this.addElementToList(shapeElement)
	element.fireRequest.set(true)))
	*/

	this.duplicateButtonFire = $$(@duplicateButton.fire.doE(() ->
		var shapeElement = @list.itemSelected.handler.first().copy()
		var element = this.addElementToList(shapeElement)
		element.fireRequest.set(true)))

	this.doSave = $$(@saveButton.fire.doE(() ->
		@target.shape(this.compositeView.shape())))! !

!KSShapeEditor methodsFor: 'initialization' stamp: 'ael 4/1/2013 23:31'!
layout
	^ KSSimpleLayout new
		keep: #topLeft of: 'compositeHatch' to: #topLeft offset: 5@5;
		keep: #topLeft of: 'compositeView' to: #topLeft offset: 15@15;
		keep: #bottomLeft of: 'editBackground' to: #bottomLeft  offset: 15@ -15;
		keep: #bottomLeft of: 'editHatch' to: #bottomLeft  offset: 5@ -5;
		keep: #topLeft of: 'editView' to: #topLeft of: 'editBackground';
		keep: #topRight of: 'scroller' to: #topRight;
		keep: #width of: 'scroller' to: 150;
		keep: #height of: 'scroller' to: #height offset: -25;
		keep: #bottomRight of: 'save' to: #bottomRight offset: -10@ -3;
		keep: #topLeft of: 'closePathButton' to: #topRight of: 'editBackground' offset: 16@ -6;
		keep: #topLeft of: 'filledPathButton' to: #topLeft of: 'closePathButton' offset: 32@0;
		keep: #topLeft of: 'fillButton' to: #bottomLeft of: 'closePathButton' offset: 0@12;
		keep: #topLeft of: 'gradButton' to: #topLeft of: 'fillButton' offset: 32@0;
		keep: #topLeft of: 'widthLabel' to: #bottomLeft of: 'fillButton' offset: 0@12;
		keep: #topLeft of: 'widthSlider' to: #topLeft of: 'widthLabel' offset: 12@0;
		keep: #topLeft of: 'widthReadout' to: #topRight of: 'widthSlider' offset: 6@0;
		keep: #topLeft of: 'jointsLabel' to: #bottomLeft of: 'fillButton' offset: 0@32;
		keep: #topLeft of: 'jointsSlider' to: #topLeft of: 'jointsLabel' offset: 12@0;
		keep: #topLeft of: 'jointsReadout' to: #topRight of: 'jointsSlider' offset: 6@0;
		keep: #topLeft of: 'capsLabel' to: #bottomLeft of: 'fillButton' offset: 0@52;
		keep: #topLeft of: 'capsSlider' to: #topLeft of: 'capsLabel' offset: 12@0;
		keep: #topLeft of: 'capsReadout' to: #topRight of: 'capsSlider' offset: 6@0;
		keep: #bottomLeft of: 'pointReadout' to: #bottomRight of: 'editBackground' offset: 16@ -6;
		yourself.! !

!KSShapeEditor methodsFor: 'initialization' stamp: 'ael 4/1/2013 23:50'!
setup = (target) ->
	this.maxWidth = 5
	this.maxMiter = 5
	var factory = @whole.factory()
	this.target = target
	@whole.fill(Color.white())
	this.elements = []
	var list = this.list = factory.newList()
	var scroller = this.scroller = factory.createVScrollerFor(list)
	scroller.name('scroller')
	scroller.fill(Color.white())
	delete list.doAction

	this.compositeView = KSBox.new()
	this.makeCompositeView(this.compositeView, target.shape().elements())
	this.compositeView.name('compositeView')
	list.setItems(([x, x] for x in this.makeElementsList(this.compositeView)))
	list.layout().space(2)
	this.decorateElementsList(list)

	this.beDialogExtent(P(400, 350))
	@whole.add(scroller)
	@whole.add(this.compositeView)
	@whole.add(this.editBackground = KSBox.new())
	this.editBackground.extent(this.compositeView.extent())
	this.editBackground.scale(this.compositeView.scale())
	this.editBackground.name("editBackground")
	this.editBackground.fill(Color.white())

	@whole.addFirst(this.editView = this.makeEditView(this.editBackground))
	this.editView.name("editView")
	this.editView.handler.setup(this.editBackground, this.compositeView)

	var hatchBox = KSBox.new()
	hatchBox.texture(this.getHatch(P(160, 160)))
	hatchBox.extent(P(160, 160))
	@whole.add(this.compositeHatch = hatchBox)
	hatchBox.name("compositeHatch")

	var hatchBox = KSBox.new()
	hatchBox.texture(this.getHatch(P(160, 160)))
	@whole.add(this.editHatch = hatchBox)
	hatchBox.name("editHatch")

	@whole.add(this.saveButton = factory.newToolButton("Save", KSFamily.withName("DejaVuSans").withStyle(1).withSize(13).fill(factory.theme.iconColor)))
	this.saveButton.name("save")

	this.closePathButton = this.makeClosePathButton()
	this.closePathButton.name("closePathButton")
	this.closePathButton.scale(1.25)
	@whole.add(this.closePathButton)

	this.filledPathButton = this.makeFilledPathButton()
	this.filledPathButton.name("filledPathButton")
	this.filledPathButton.scale(1.25)
	@whole.add(this.filledPathButton)

	this.fillButton = this.makeFillButton()
	this.fillButton.name("fillButton")
	@whole.add(this.fillButton)

	for spec in [ ["width", "W" ], ["joints", "J" ], ["caps", "C"] ]
		var labelName = spec[0].concat("Label")
		var box = this[labelName] = this.makeLabel(spec[1])
		box.name(labelName)
		box.isStrokeControl = true
		@whole.add(box)
		var sliderName = spec[0].concat("Slider")
		box = this[sliderName] = this.makeStrokeSlider()
		box.name(sliderName)
		box.isStrokeControl = true
		@whole.add(box)
		var readoutName = spec[0].concat("Readout")
		box = this[readoutName] = this.makeReadout()
		box.name(readoutName)
		box.isStrokeControl = true
		@whole.add(box)

	this.gradButton = this.makeGradButton()
	this.gradButton.name("gradButton")
	@whole.add(this.gradButton)

	this.pointReadout = this.makeReadout()
	this.pointReadout.name("pointReadout")
	@whole.add(this.pointReadout)

	this.behavior()
	list.first().fireRequest.set(true)
	@whole.layout(this.layout())! !

!KSShapeEditor class methodsFor: 'as yet unclassified' stamp: 'yo 2/12/2013 15:48'!
example1
"
	KSShapeEditor example1
"
	| ks target |
	target := KSBox withShape: (KSFactory default scaleIcon).
	target topLeft: 20@20.
	ks := KSMorph new openInWorld extent: 600@400.
	ks window add: target.
	target shapeEditor: nil! !
