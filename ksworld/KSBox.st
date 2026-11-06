KSObject subclass: #KSBox
	instanceVariableNames: ''
	classVariableNames: 'GlyphNames QuadCoords'
	poolDictionaries: 'OpenGLConstants'
	category: 'KSObjects-Boxes'!

!KSBox methodsFor: '*generated' stamp: 'yo 8/3/2012 15:54'!
foo = () ->
	this.foo = $$(this.xyz(mergeE(@x, @y)))! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/14/2013 18:26'!
findPPEmbeddedName = (aString) ->
	//"self new findPPEmbeddedName ''"
	//"self new findPPEmbeddedName '[][]'"
	//"self new findPPEmbeddedName '[[]]'"
	//"self new findPPEmbeddedName '[[Embedded.ks]]'"
	if aString.size() < 4 || !!(aString.beginsWith("[[")) || !!(aString.endsWith("]]"))
		return nil
	return aString._copyFrom_to(3, aString.size() -2)! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/19/2013 16:24'!
installODFScript = () ->
	var scr = @__odfScript__
	if scr
		this.odfScript = scr.script()
		delete this.__odfScript__! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'tk 2/27/2013 13:21'!
ppComeFullyUpOnReloadFrom: from to: to
	super ppComeFullyUpOnReloadFrom: from to: to.
	(self at: #'__loadedContents__' ifAbsent: []) ifNotNil: [
		(self at: #'__loadedContents__') do: [:elem | self add: elem].
		self removeKey: #'__loadedContents__'.
		(self layout ksAt: #acceptContentsOnCR) currentValue asBoolean ifTrue: [self blockHaloForContents: true]]! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/17/2013 15:23'!
ppDictionaryInto: sexp context: dictionary
	super ppDictionaryInto: sexp context: dictionary.
	self ppSerializer ppWriteElements: sexp context: dictionary.! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/14/2013 19:33'!
ppEmbeddedName = () ->
	// Find a embedded notation [[filename.ks]]. Return nil if it is not found.
	var p = this.findPPEmbeddedName(this.textContents())
	if p
		return p
	for e in @contents
		p = e.ppEmbeddedName()
		if p
			return p
	return null! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/17/2013 21:14'!
ppIgnoreFieldNames
	^ super ppIgnoreFieldNames, #(worldState #'__direct__' #'__rawEvents__' #'__sorter__' glTexture glVertices glShadowVertices glShadowTexture glScaleInvalid),
		((self ksAt: #isWindow) asBoolean ifTrue: [#(parts halo haloTarget haloVisible removeHalo)] ifFalse: [#()]),
			(self ppSerializer == self ifTrue: [#()] ifFalse: [#(contents parts backgroundParts)])! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/17/2013 16:51'!
ppInitializeFrom: sexp from: from to: to
	sexp elements do: [:each |
		each head == #data ifFalse: [
			to readSlot: each into: self from: from to: to]
		ifTrue: [
			self at: #parts put: KSContentsCollection new.
			self at: #backgroundParts put: KSContentsCollection new.
			self at: #contents put: KSContentsCollection new.
			self at: #'__loadedContents__'
				put: (PPTextImporter new createBoxesFrom: each elements from: from to: to)]]! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/8/2013 17:30'!
ppScanObjects
	| dict |
	dict := PPPusher new.
	dict boundaryObjects add: self container.
	^ dict ppScanObjectsFrom: self.! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/17/2013 15:13'!
ppSerializer = () ->
	return if this.layout() then this.layout().ppSerializer() else this! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/17/2013 15:22'!
ppWriteElements: sexp context: dictionary.! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/19/2013 16:36'!
resetODFScript = () ->
	var scr = @odfScript
	if scr
		var seen = {}
		for e in scr.elements()
			var rcvr = (b.attributeAt(#'name') for b in e.elements() when b.head() == #'literal')
			if !!seen[rcvr]
				seen[rcvr] = e._attributeAt_ifAbsent(#'selector', '')
				var target = this.atName(rcvr)
				if target
					target.visible.set(seen[rcvr] !!= "hidden")! !

!KSBox methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/8/2013 17:34'!
saveToDirectory = (dir) ->
	var dirObject = PPPusher.directoryObject(dir)
	dirObject.assureExistence()
	var dict = PPPusher.new()
	dict.enableResourceCaching()
	this.allContentsAndPartsAndPagesInto(dict.allBoxes())
	dict.lookup(this)
	dict.write(dirObject)! !

!KSBox methodsFor: 'actions' stamp: 'ael 1/22/2013 01:57'!
menuLabelFor = (anObject) ->
	this! !

!KSBox methodsFor: 'cell' stamp: 'yo 3/12/2013 21:32'!
attachCellUpdater = () ->
	this.updateCell = $$(@tableHandler[@cellName].mapE((v) ->
		if !!@suppressUpdate
			this.textContents(v.printString())))! !

!KSBox methodsFor: 'cell' stamp: 'yo 3/12/2013 21:32'!
beCell = (tableHandler, cellName) ->
	this.tableHandler = tableHandler
	this.cellName = cellName.asSymbol()
	this.suppressUpdate = false
	this.attachCellUpdater()
	return this! !

!KSBox methodsFor: 'collection' stamp: 'yo 1/7/2013 16:27'!
add = (aBox) ->
	this.addLast(aBox)! !

!KSBox methodsFor: 'collection' stamp: 'yo 9/4/2013 13:53'!
addAfterIndex = (aBox, ind) ->
	aBox._delete()
	aBox.container.set(this)
	this.contents._add_afterIndex(aBox, ind + 1)
	if !!@noLayout
		this.layoutChanged()
	if this.worldState() && !!this.optimizedField() then this.worldState().clearSortedBubbles()! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/16/2012 14:25'!
addAll = (aCollection) ->
	for each in aCollection
		this.add(each)! !

!KSBox methodsFor: 'collection' stamp: 'yo 8/29/2013 15:58'!
addAsBackgroundParts = (aBox) ->
	aBox._delete()
	this.backgroundParts.add(aBox)
	aBox.container.set(this)
	if this.worldState() && !!this.optimizedField() then this.worldState().clearSortedBubbles()
	this.layoutChanged()! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/16/2012 14:43'!
addAsParts = (aBox) ->
	this.addAsPartsLast(aBox)! !

!KSBox methodsFor: 'collection' stamp: 'yo 8/29/2013 15:58'!
addAsPartsAfterIndex = (aBox, ind) ->
	aBox._delete()
	this.parts._add_afterIndex(aBox, ind+1)
	aBox.container.set(self)
	this.layoutChanged()
	if this.worldState() && !!this.optimizedField() then this.worldState().clearSortedBubbles()! !

!KSBox methodsFor: 'collection' stamp: 'ael 3/5/2013 16:10'!
addAsPartsFirst = (aBox) ->
	var nonHandInd = if @isWindow && this.parts[0].isHand then 0 else -1
	this.addAsPartsAfterIndex(aBox, nonHandInd)! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/24/2012 20:21'!
addAsPartsLast = (aBox) ->
	this.addAsPartsAfterIndex(aBox, this.parts.size() - 1)! !

!KSBox methodsFor: 'collection' stamp: 'yo 1/9/2013 15:18'!
addFirst = (aBox) ->
	// Add the box in front of all other contents
	this.addAfterIndex(aBox, -1)! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/24/2012 20:19'!
addLast = (aBox) ->
	this.addAfterIndex(aBox, this.contents.size()-1)! !

!KSBox methodsFor: 'collection' stamp: 'yo 9/3/2013 20:01'!
addTextContents = (aStringOrArray, font) ->
	// Convert an ascii string to be in my contents as LBoxes with letter glyphs.  Append them to at the end of contents.
	if !!font
		return this.addTextContents(aStringOrArray)
	var layout = this.ensureTextLayout()
	for cc in aStringOrArray
		if cc.isCharacter()
			var b = KSBox._withChar_inFont(cc, font)
			this.addLast(b)
		else
			this.addLast(cc)! !

!KSBox methodsFor: 'collection' stamp: 'yo 9/3/2013 20:04'!
addUnicodeText: aString withFonts: anArray
	 | in s f |
	in := (aString findTokens: '@\' keep: '@\') readStream.
	[in atEnd] whileFalse: [
		s := in next.
		s = '\' ifTrue: [
			s := in next.
			s := (Character value: (Number readFrom: (s first: 5) allButFirst base: 16)) asString, (s allButFirst: 5)].
		f := anArray first.
		s = '@' ifTrue: [
			s := in next.
			f := anArray at: s first digitValue.
			s := s allButFirst].
		self addTextContents: s with: f]! !

!KSBox methodsFor: 'collection' stamp: 'yo 2/8/2013 17:34'!
allContentsAndPartsAndPagesInto: aSet
	| h |
	aSet add: self.
	((h := self ksAt: #handler) isMemberOf: KSStack) ifTrue: [
		h allContentsAndPagesInto: aSet].
	(self at: #parts) asArray do: [:e | e allContentsAndPartsAndPagesInto: aSet].
	(self at: #contents) asArray do: [:e | e allContentsAndPartsAndPagesInto: aSet].
	(self at: #backgroundParts) asArray do: [:e | e allContentsAndPartsAndPagesInto: aSet].! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/16/2012 18:46'!
allContentsAndPartsDo = (aBlock) ->
	for e in this.parts
		e.withAllContentsAndPartsDo(aBlock)
	for e in this.contents
		e.withAllContentsAndPartsDo(aBlock)
	for e in this.backgroundParts
		e.withAllContentsAndPartsDo(aBlock)! !

!KSBox methodsFor: 'collection' stamp: 'yo 9/10/2013 17:48'!
allContentsDo = (aBlock) ->
	for e in this.contents
		e.withAllContentsDo(aBlock)! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 13:01'!
beAPart = (aBoolean) ->
	this.part = aBoolean
	this.backgroundPart = !!aBoolean! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/24/2012 19:46'!
container = (c) ->
	this.container.set(c)! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 13:11'!
contents = () ->
	this.contents! !

!KSBox methodsFor: 'collection' stamp: 'bf 7/27/2012 16:28'!
contentsAndPartsDo = (aBlock) ->
	@parts._do(aBlock)
	@contents._do(aBlock)
	@backgroundParts._do(aBlock)! !

!KSBox methodsFor: 'collection' stamp: 'yo 8/30/2012 15:10'!
contentsAt = (index) ->
	this.contents._at(index)! !

!KSBox methodsFor: 'collection' stamp: 'yo 1/7/2013 18:56'!
contentsSize = () ->
	return this.contents.size()! !

!KSBox methodsFor: 'collection' stamp: 'ael 3/21/2013 13:38'!
delete = () ->
	var cc = @container
	var top = @__topContainer__
	if top
		var hand = top.worldState.hand
		if hand.focus.currentValue() && hand.focus.currentValue().hasContainer(this)
			hand.focus(nil)
		if hand.keyboardFocus.currentValue()
			&& hand.keyboardFocus.currentValue().hasContainer(this)
				hand.keyboardFocus(nil)
		if top.haloTarget.currentValue()
			&& top.haloTarget.currentValue().hasContainer(this)
				top.worldState.deleteHalo()
	if cc
		cc.remove(this)
		this.container.set(nil)! !

!KSBox methodsFor: 'collection' stamp: 'tk 2/27/2013 15:00'!
ensureTextLayout = () ->
	// Force me to have a layout that is able to handle text.
	if !!(@layout instanceof KSTextLayout)
		KSTextLayout.new().installTo(this)
	return @layout! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 14:48'!
findFirst: aBlock
	^ self findFirst: aBlock ifFound: [:e | ^ e].! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 14:48'!
findFirst: aBlock ifFound: foundBlock
	(aBlock value: self) ifTrue: [foundBlock value: self].
	(self at: #backgroundParts) do: [:e | e findFirst: aBlock ifFound: foundBlock].
	(self at: #contents) do: [:e | e findFirst: aBlock ifFound: foundBlock].
	(self at: #parts) do: [:e | e findFirst: aBlock ifFound: foundBlock].
	^ nil! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 14:49'!
findLast: aBlock
	self findLast: aBlock ifFound: [:e | ^ e].! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 14:50'!
findLast: aBlock ifFound: foundBlock
	(self at: #parts) reverseDo: [:e | e findLast: aBlock ifFound: foundBlock].
	(self at: #contents) reverseDo: [:e | e findLast: aBlock ifFound: foundBlock].
	(self at: #backgroundParts) reverseDo: [:e | e findLast: aBlock ifFound: foundBlock].
	(aBlock value: self) ifTrue: [foundBlock value: self].
	^ nil! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 14:50'!
first = () ->
	return this.contents[0]! !

!KSBox methodsFor: 'collection' stamp: 'ael 3/21/2013 13:33'!
hasContainer = (aBox) ->
	// Return true if receiver is, or is contained by, aBox
	var current = this
	while current
		if current === aBox
			return true
		current = current.container()
	return false! !

!KSBox methodsFor: 'collection' stamp: 'tk 2/22/2013 16:48'!
index = () ->
	// This box is the nth element in its contents.  return n.  n is 1-order.
	
	return @container.contents().indexOf(this)
	! !

!KSBox methodsFor: 'collection' stamp: 'yo 1/31/2013 09:57'!
isEmpty = () ->
	return @contents.isEmpty()! !

!KSBox methodsFor: 'collection' stamp: 'yo 1/7/2013 18:57'!
isLeaf = () ->
	return @contents.isEmpty() && @parts.isEmpty() && @backgroundParts.isEmpty()! !

!KSBox methodsFor: 'collection' stamp: 'yo 1/7/2013 18:57'!
last = () ->
	return @contents.last()! !

!KSBox methodsFor: 'collection' stamp: 'yo 1/7/2013 18:57'!
lastParts = () ->
	return @parts.last()! !

!KSBox methodsFor: 'collection' stamp: 'tk 1/23/2013 12:21'!
predecessor = () ->
	// Answer the element before me in my container.
	return @container.contents._before_ifAbsent(this, nil)! !

!KSBox methodsFor: 'collection' stamp: 'yo 8/29/2013 15:59'!
remove = (aBox) ->
	//Remove this box.  If the box is on more than one page of a stack, and if the user refuses to delete it, this method will return with the box not deleted.  This method returns before the dialog box appears, so the delete may happen after the return.
	if this.removeAsParts(aBox)
		return aBox
	if this.removeAsBackgroundParts(aBox)
		return aBox
	var index = @contents.indexOf(aBox)
	if index > 0 
		this.removeAt(index)
		if this.worldState() && !!this.optimizedField() then this.worldState().clearSortedBubbles()! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 15:04'!
remove: aBox
	"Remove this box.  If the box is on more than one page of a stack, and if the user refuses to delete it, this method will return with the box not deleted.  This method returns before the dialog box appears, so the delete may happen after the return."
	| index |
	aBox isPart ifTrue: [^ self removeAsParts: aBox].
	aBox isBackgroundPart ifTrue: [^ self removeAsBackgroundParts: aBox].

	index := contents indexOf: aBox.
	index > 0 ifTrue: [self removeAt: index].	"extra tests done here"! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 15:05'!
removeAll = () ->
	// Remove all of my constituent subviews.  asArray creates a copy.
	for e in this.contents.asArray()
		this.remove(e)! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 15:06'!
removeAllParts = () ->
	// Remove all of my constituent subviews.
	for e in this.backgroundParts.asArray()
		this.removeAsBackgroundParts(e)
	for e in this.parts.asArray()
		this.removeAsParts(e)! !

!KSBox methodsFor: 'collection' stamp: 'yo 8/31/2012 14:08'!
removeAsBackgroundParts = (aBox) ->
	var ret = this.backgroundParts._remove_ifAbsent(aBox, nil)
	if ret
		this.layoutChanged()
	return ret! !

!KSBox methodsFor: 'collection' stamp: 'yo 8/31/2012 14:08'!
removeAsParts = (aBox) ->
	var ret = this.parts._remove_ifAbsent(aBox, nil)
	if ret
		aBox.layoutChanged()
	return ret! !

!KSBox methodsFor: 'collection' stamp: 'yo 8/31/2012 14:09'!
removeAt = (index) ->
	this.layoutChanged()
	return this.contents.removeAt(index)! !

!KSBox methodsFor: 'collection' stamp: 'tk 3/14/2013 12:08'!
removeBackPartsSuchThat = (aBooleanFunc) ->
	// Delete each background part for which the block answers true.
	(this.removeAsBackgroundParts(pp) for pp in this.backgroundParts.copy() when aBooleanFunc(pp))! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 15:24'!
reorderBeAt = (anElement, nth) ->
	// Move anElement so that it becomes the nth element in my contents.  Do not issue any announcements.
	this.contents._reorder_beAt(anElement, nth)
	this.layoutChanged()! !

!KSBox methodsFor: 'collection' stamp: 'tk 1/23/2013 12:22'!
successor = () ->
	//Answer the element after me in my container.  A transform.
	return @container.contents._after_ifAbsent(this, nil)! !

!KSBox methodsFor: 'collection' stamp: 'ael 3/14/2013 15:34'!
textContents = () ->
	return String.newFrom((Character.value(e.unicode()) for e in this.contents when e.unicode() > 0))! !

!KSBox methodsFor: 'collection' stamp: 'yo 8/28/2013 14:40'!
textContentsOpt = (aString) ->
	// Convert an ascii string to be in my contents as KSBoxes with letter glyphs.  Replace entire contents.
	this.removeAll()
	this.ensureTextLayout()
	this.layout().selection.set(0.to(1))
	this.layout().addAllOpt(aString)! !

!KSBox methodsFor: 'collection' stamp: 'yo 7/17/2012 15:45'!
withAllContentsAndPartsDo: aBlock
	aBlock value: self.
	(self at: #parts) asArray do: [:e | e withAllContentsAndPartsDo: aBlock].
	(self at: #contents) asArray do: [:e | e withAllContentsAndPartsDo: aBlock].
	(self at: #backgroundParts) asArray do: [:e | e withAllContentsAndPartsDo: aBlock].! !

!KSBox methodsFor: 'collection' stamp: 'yo 9/10/2013 17:48'!
withAllContentsDo = (aBlock) ->
	aBlock.value(this)
	for e in this.contents
		e.withAllContentsDo(aBlock)! !

!KSBox methodsFor: 'color picker' stamp: 'ael 4/1/2013 17:59'!
alphaHatchFor = (c) ->
	var f = this.getHatch().deepCopy()
	var g = GeziraCanvas.on(f)
	g._fill(GeziraFill._gradient_from_to(
		{0: Color.transparent(),
		1: c}.associations().asSortedArray(),
		P(0, 8),
		P(0, 264)))
	g.draw((P(0, 8).corner(f.boundingBox().bottomRight() - P(0, 8))).asGeziraPath())
	this.alpha.fill(f.asGeziraFill())! !

!KSBox methodsFor: 'color picker' stamp: 'bf 1/17/2013 16:19'!
bullsEyeShape = () ->
	KSShape.new().elements([
		GeziraPath.oval(P(0,0).extent(P(12,12))).fill(Color.white()).stroke(GeziraStroke.width(2)),
		GeziraPath.oval(P(0,0).extent(P(12,12)))])! !

!KSBox methodsFor: 'color picker' stamp: 'yo 10/4/2012 23:20'!
calculateShadeForHue = (h) ->
	var f = Form._extent_depth(P(256, 256), 32)
	var canvas = GeziraCanvas.on(f)
	canvas.fill(GeziraFill._gradient_from_to(
		{0: Color.white(),
		1: Color._h_s_v(h, 1.0, 1.0)}.associations().asSortedArray(),
		P(0.5, 0.5), P(255.5, 0.5)))
	canvas.draw(f.boundingBox().asGeziraPath())
	canvas.fill(GeziraFill._gradient_from_to(
		{0: Color.transparent(),
		1: Color.black()}.associations().asSortedArray(),
		P(0.5, 0.5), P(0.5, 255.5)))
	canvas.draw(f.boundingBox().asGeziraPath())
	this.sv.fill(f.asGeziraFill())! !

!KSBox methodsFor: 'color picker' stamp: 'yo 10/4/2012 22:26'!
getHatch = () ->
	if !!this.hatch
		this.hatch = Form._extent_depth(P(20, 272), 32)
		var g = GeziraCanvas.on(this.hatch)
		g._fill(Color.white().asGeziraFill())
		g.clipBy(P(0, 8).corner(P(20, 264)))
		g.fillRectangle(P(0, 0).corner(P(20, 272)))
		g.fill(Color.gray(0.75).asGeziraFill())
		var odd = false
		var start
		for y in [-2...272] by 5
			odd = !!odd
			start = if odd then -2 else 3
			for x in [start...start + 20] by 10
				g.fillRectangle(P(x, y).extent(P(5, 5)))
	return this.hatch! !

!KSBox methodsFor: 'color picker' stamp: 'ael 4/1/2013 19:28'!
invokeColorPicker = (defaultPosition, initialColorOrFill, target, updater) ->
	// defaultPosition can be nil, and is only used when creating a new picker (rather than recycling)
	var recycle = this.hasOwnProperty("spareColorPicker")
	if recycle
		var picker = this.spareColorPicker
		picker.visible.set(true)
		delete this.spareColorPicker
	else
		picker = KSFactory.default().newColorPicker()
		this.addFirst(picker)
		picker.layOut()
		if defaultPosition
			picker.topLeft(defaultPosition.rounded() + P(0.5, 0.5))
	picker.target = target
	picker.updater = updater
	if recycle
		picker.resetRequest.setPropagatingLater(initialColorOrFill.asColor())
	else
		picker.resetRequest.set(initialColorOrFill.asColor())
	return picker! !

!KSBox methodsFor: 'color picker' stamp: 'yo 3/8/2013 14:15'!
setUpInteractiveColorPickerFor = (aBox) ->
	this.pickerTarget = aBox
	this.script = $$(@color.mapE((col) ->
		this.pickerTarget.fill(col)))! !

!KSBox methodsFor: 'color picker' stamp: 'ael 4/1/2013 20:01'!
setupColorPicker = () ->
	var theme = this.factory()
	this.attachGenericMoveHandler()
	var sv = this.sv = theme.newSlider(P(256, 256))
	sv.name("svSlider")
	sv.fill(Form._extent_depth(P(256, 256), 32).asGeziraFill())
	this.add(sv)
	sv.topLeft(P(12, 12))
	var f = Form._extent_depth(P(30, 272), 32)
	for h in [0 ... 255]
		var p= P(0, h+8)
		f._fill_fillColor(p.corner(P(30, h+8+1)), Color._h_s_v(h * 360.0 / 255.0, 1, 1))
	var hue = this.hue = theme.newSlider(P(16, 272))
	hue.name("hueSlider")
	hue.fill(f.asGeziraFill())
	hue.clipping(true)
	this.add(hue)
	hue.rotateBy(0 - Float.pi() / 2)
	this.hue.knob.shape(KSShape.new().elements([GeziraPath.polygon([
		P(0, 0), P(0, 16), P(10, 8), P(30, 8),
		P(10, 8), P(0, 0)].asArray())].asArray()).fill(Color.white()))
	hue.borderWidth(0)
	hue.topLeft(P(4, 276))
	this.hue.jumpOnButtonDown = true
	this.hue.advanceInPage = false
	this.hue.max = P(0, 256)
	this.hue.min = P(0, 0)

	var alpha = this.alpha = theme.newSlider(P(20, 272))
	alpha.name("alphaSlider")
	f = Form._extent_depth(P(16, 272), 32)
	alpha.fill(f.asGeziraFill())
	alpha.clipping(true)
	this.add(alpha)
	this.alpha.knob.shape(KSShape.new().elements([GeziraPath.polygon([
		P(0, 0), P(0, 16), P(10, 8),
		P(30, 8), P(10, 8), P(0, 0)].asArray())].asArray()).fill(Color.orange()))
	alpha.borderWidth(0)
	alpha.rotateBy(Float.pi())
	alpha.topLeft(P(276, 4))
	alpha.jumpOnButtonDown = true
	alpha.advanceInPage = false
	alpha.max = P(0, 256)
	alpha.min = P(0, 0)

	var button = this.button = theme.newButton("ok")
	this.add(button)
	button.topLeft(P(276, 296))
	this.fire = $$(@button.fire)

	var knob = this.sv.knob
	knob.shape(this.bullsEyeShape())
	knob.fill(Color.white().alpha(0.001))
	this.sv.max = P(250, 250)
	this.sv.min =  P(-6, -6)
	this.sv.jumpOnButtonDown = true
	this.sv.advanceInPage = false

	var swatchHolder = this.swatchHolder = KSBox._extent_fill(P(256, 16), Color.transparent())
	var layout = KSHorizontalLayout.new()
	layout.space(4)
	swatchHolder.layout(layout)
	for i in [0 .. 10]
		var swatch = KSBox._extent_fill(P(22,16), Color.transparent())
		swatch.borderWidth(1)
		swatch.borderFill(Color.veryLightGray())
		swatch.attachButtonHandler()
		swatch.highlightEnabled.set(false)
		swatchHolder.add(swatch)
	this.add(swatchHolder)
	swatchHolder.topLeft(P(12, 300))

	this.watchSamples = $$(@__topContainer__.worldState.fillSamples.doE(() ->
		var uniformFills = this.worldState().uniformFillSamples()
		var swatches = @swatchHolder.contents()
		for i in [0 .. 10]
			swatches[i].fill(uniformFills[i])))! !

!KSBox methodsFor: 'connectors' stamp: 'yo 1/11/2013 10:53'!
beConnectorEndHandler = () ->
	this.isConnectorEnd = true
	this.startTrackingAction = $$(@buttonDown.mapE((ev) ->
		this.startTracking._value(ev)))
	this.trackingHand = this.eventStream()
	this.droppedBy = this.eventStream()
	this.droppedInto = this.eventStream()

	this.startTracking = (ev) ->
		this.trackingHand.set(ev.hand)
		this.oldContainer = this.container()
		ev.hand.attachBox(this)

	this.endTracking = $$(@droppedBy.mapE((x) ->
		if x.target !!== this.oldContainer
			this.droppedInto.set({box: this, target: x.target})
			if x.target.hasOwnProperty("dropRequest")
				x.target.dropRequest.set(undefined)
		this.droppedBy.set(undefined)
		this.trackingHand.set(undefined)))

	this.trackHand = $$(@trackingHand.transformation.doE(() ->
		{position: this.globalPointFor(this.extent()/2)}))

	this.listen(["buttonDown"])! !

!KSBox methodsFor: 'connectors' stamp: 'yo 9/4/2013 16:37'!
beConnectorHandler = (start, end) ->
	this.borderWidth(2)
	this.borderFill(Color.lightBlue())
	this.setupConnector = (s, e, deleting) ->
		this.start = s ? this.makeConnectorEnd()
		this.end = e ? this.makeConnectorEnd()
		this.ends = [this.start, this.end]
		if !!deleting
			for x in this.ends
				if x.handler.addConnection
					x.handler.addConnection(this)
				else
					if x.addConnection
						x.addConnection(this)
	this.setupConnector(start, end, false)

	this.markerStart = "round"
	this.markerEnd = "round"
	this.pathFromTo = this.streamOf((fromPoint, toPoint) ->
		this._defaultPathFrom_to(fromPoint, toPoint))

	this.updateLine = $$(mergeE(
		@start.bounds,
		@end.bounds,
		@shape,
		@pathFromTo,
		switchColE(@ends, "trackHand")).doE(() -> this.updateConnector()))

	this.detectEndsDropped = $$(switchColE(@ends, "droppedInto").mapE((x) ->
		var ind = if x.box == this.start then 0 else 1
		if ind == 0
			this.start = x.target
		else
			this.end = x.target
		var oldPos = x.box.globalPointFor(x.box.extent()/2.0)
		x.box.delete()
		var t = this.ends[ind] = x.target
		if t.addConnection
			t.addConnection(this, x.box, oldPos)
		this.updateConnector()))

	this.detectDropped = $$(@container.mapE((c) ->
		if !!c.isHand
			if this.ends[0].isConnectorEnd && !!@start.container()
				@start.center(c.localPointFor(this.globalPointFor(this.start.center())))
				c.addFirst(this.start)
			if this.ends[1].isConnectorEnd && !!@end.container()
				this.end.center(c.localPointFor(this.globalPointFor(this.end.center())))
				c.addFirst(this.end)))

	this.disconectAnEnd = $$(@shiftButtonDown.mapE((ev) ->
		if this.start.globalPointFor(this.start.extent()/2).dist(ev.position) < this.end.globalPointFor(this.end.extent()/2).dist(ev.position)
			var box = this.start
			var ss = true
		else
			box = this.end
		if !!box.isConnectorEnd
			if box.handler.removeConnection
				box.handler.removeConnection(this)
			else
				if box.removeConnection
					box.removeConnection(this)
			box = this.makeConnectorEnd()
			this.container().add(box)
			if ss
				box.center(this.start.center())
				this.setupConnector(box, this.end, true)
			else
				box.center(this.end.center())
				this.setupConnector(this.start, box, true)
		box.startTracking(ev)))

	this.shiftButtonDown = $$(@buttonDown.mapE((ev) ->
		if ev.buttons.anyMask(8) then ev else undefined))

	this.listen(["buttonDown"])
	return this.worldState()! !

!KSBox methodsFor: 'connectors' stamp: 'bf 1/17/2013 16:29'!
defaultPathFrom: from0 to: to0 
	| markerStartPath markerEndPath from to line0 line headArrow tailArrow paths fill width shape |
	width := self borderWidth.
	fill := self borderFill.
	markerStartPath := ((self markerSpec: (self at: #markerStart)) transformedBy: (MatrixTransform2x3 withScale: width @ width)) fill: fill.
	markerEndPath := ((self markerSpec: (self at: #markerEnd)) transformedBy: (MatrixTransform2x3 withScale: width @ width)) fill: fill.

	line0 := GeziraPath line: from0 to: to0.

	"Offset by marker's width"
	from := (markerStartPath bounds left @ 0) transformedBy: line0 startTangentTransform.
	to := (markerEndPath bounds left @ 0) transformedBy: line0 endTangentTransform.

	line := (GeziraPath line: from to: to)
				stroke: (GeziraStroke width: width);
				 fill: fill.

	headArrow := markerEndPath transformedBy: line0 endTangentTransform.
	tailArrow := markerStartPath transformedBy: line0 startTangentTransform.
	paths := {line. headArrow. tailArrow}.
	shape := KSShape new elements: paths.
	shape borderWidth: width.
	shape borderFill: fill.
	^ shape.! !

!KSBox methodsFor: 'connectors' stamp: 'yo 10/9/2012 23:50'!
makeConnectorEnd = () ->
	var end = KSBox._extent_fill(P(10, 10), this.endFill ? Color.red())
	end.name("end")
	end.beConnectorEndHandler()
	return end! !

!KSBox methodsFor: 'connectors' stamp: 'bf 1/17/2013 16:25'!
markerSpec: aName
	"Return a marker path. The end point is 0@0 and the direction should be right."
	^ aName caseOf: {
		['arrow'] -> [GeziraPath polygon: {0 @ 0. -2 @ -1. -2 @ 1}].
		['round'] -> [GeziraPath arc: Float pi / -2 to: Float pi / 2 center: 0@0 radius: 0.5]
	} otherwise: [GeziraPath line: 0 @ 0.5 to: 0 @ -0.5 "Default thin line"].! !

!KSBox methodsFor: 'connectors' stamp: 'yo 10/10/2012 00:20'!
updateConnector = () ->
	if !!@end || !!@start
		var points = [P(0, 0), P(0, 0)]
	else
		points = (this.container().localPointFor((x.container() ? x).globalPointFor(x.center())) for x in [@start, @end])

	var s = @pathFromTo._value_value(P(0, 0), points[1] - points[0])
	s.computeBounds()
	if !!@forceUpdate && (s.extent() == this.extent() && this.topLeft().closeTo(points[0] - s.offset()))
		return this
	this.forceUpdate = false
	this.shape(s)
	this.topLeft(points[0] - s.offset())
	return this! !

!KSBox methodsFor: 'copying' stamp: 'yo 1/8/2013 17:02'!
copy = () ->
	return this.ppScanObjects().ppCreateObjects()! !

!KSBox methodsFor: 'different text layout' stamp: 'tk 1/16/2013 14:05'!
field = () ->
	var string = 'The first three years were devoted to making much smaller keyboards so that mice would be able to use them without getting repetitive strain injuries.'

	var next = undefined
	for ind in [string.size() - 1 ... 0] by -1
		var char = string[ind]
		var charBox = KSBox._withChar_inFont(char, KSFont.defaultFont())
		this.addFirst(charBox)
		charBox.successor = next
		if next
			next.predecessor = charBox
		charBox.setUpChar()
		next = charBox

	next.position.set(P(0, 10))
	// To re-layout, execute:
	// 	this.contents()[0].position.set(P(0, 10))! !

!KSBox methodsFor: 'different text layout' stamp: 'tk 10/16/2012 16:08'!
setUpChar = () ->
	this.widthToEnd	= if this.isWhiteSpace() || !!@successor then 0 else @successor.widthToEnd + this.width()
	this.position		= $$(this.place(@predecessor.position))

	this.place = (predPos) ->
		if @predecessor.isWhiteSpace() && @predecessor.right() + @widthToEnd > @container.width()
			P(0, predPos.y() + this.lineSkip())
		else
			P(predPos.x() + @predecessor.width(), predPos.y())

	this.setPosition		= $$(this.pivotPosition(@position))! !

!KSBox methodsFor: 'drawing' stamp: 'bf 1/17/2013 10:58'!
drawOn = (aCanvas) -> 
	if !!@visible
		return this

	var s = @shape
	var glyph = this.isGlyph()
	if !!glyph
		if @clipping
			aCanvas.clipBy(this.drawingBounds())

	s.drawOn(aCanvas)

	if !!glyph
		this.backgroundParts.reverseDo((each) ->
			each.fullDrawOn(aCanvas))
		this.contents.reverseDo((each) ->
			each.drawShadowOn(aCanvas)
			each.fullDrawOn(aCanvas))
		this.parts.reverseDo((each) ->
			each.drawShadowOn(aCanvas)
			each.fullDrawOn(aCanvas))! !

!KSBox methodsFor: 'drawing' stamp: 'yo 7/19/2012 15:59'!
drawShadowOn = (aCanvas) ->
	return this! !

!KSBox methodsFor: 'drawing' stamp: 'yo 1/8/2013 13:44'!
fullDrawOn = (aCanvas) ->
	aCanvas.preserveStateDuring(() ->
		aCanvas.transformBy(@transformation)
		this.drawOn(aCanvas))! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'bf 2/13/2013 17:29'!
glCacheTexture = (propName, drawee, drawSel, boundsSel, scaleMatrix, oversample) ->
	var bnds, texExtent, initExtents
	initExtents = () ->
		bnds = drawee.perform(boundsSel)
		var scale = (scaleMatrix.a11().abs().max(scaleMatrix.a21().abs())) * oversample
		texExtent = P(
			(bnds.width() * scale).max(4).min(1024).ceiling().asLargerPowerOfTwo(),
			(bnds.height() * scale).max(4).min(1024).ceiling().asLargerPowerOfTwo())

	// if scale is invalid, calculate the new extent, and drop texture if not at right resolution
	if this.glScaleInvalid && this[propName]
		initExtents.value()
		if !!(this[propName].textureForm().extent() == texExtent)
			delete this[propName]

	// use texture if still valid, otherwise make new one
	if !!this[propName]
		if !!texExtent
			initExtents.value()
		var form = Form._extent_depth(texExtent, 32)
		var canvas = GeziraCanvas.on(form)
		canvas.deferRendering(true)
		canvas.scaleBy(texExtent / bnds.extent())
		canvas.translateBy(bnds.origin().negated())
		drawee.perform(drawSel, canvas)
		canvas.flush()
		this[propName] = OGLTexture.new()
		this[propName]._parameterAt_put(GLTextureWrapS, GLClampToEdge)
		this[propName]._parameterAt_put(GLTextureWrapT, GLClampToEdge)
		this[propName].form(form)

	this[propName]! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'bf 1/31/2013 18:57'!
glDrawList = (gl) ->
	if this.glListID
		gl.glCallList(this.glListID)! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'bf 1/31/2013 19:05'!
glDrawOn = (gl) ->
	if this.glListID
		this.glDrawList(gl)
	else
		gl.glMultMatrixf(@transformation.glTransform())
		this.glDrawOn(gl, @transformation, 0)! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'yo 1/24/2013 13:21'!
glDrawShadowOn = (gl, scaleMatrix) ->
	if !!@shadowFill
		return
	var vertices = this.glShadowVertices()
	var tex = this.glCacheTexture(#'glShadowTexture', this, #'drawShadowOn:', #'shadowBounds', scaleMatrix, 0.5)
	gl.installTexture(tex)
	gl.enableTexture(tex)
	gl.glTexCoordPointer(2, GLFloat, 0, this.glQuadCoords())
	gl.glEnableClientState(GLTextureCoordArray)
	gl.glColor4f(1.0, 1.0, 1.0,  1.0)
	gl.glVertexPointer(2, GLFloat, 0, vertices)
	gl.glEnableClientState(GLVertexArray)
   	gl.glDrawArrays(GLTriangleStrip, 0, vertices.size() / 2)
	gl.glDisableClientState(GLVertexArray)
	gl.disableTexture(tex)
	gl.glDisableClientState(GLTextureCoordArray)! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'bf 7/27/2012 16:14'!
glInvalidateScale = () ->
	if this.glScaleInvalid
		return
	this.glScaleInvalid = true
	this.contentsAndPartsDo((child) ->
		child.glInvalidateScale())! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'bf 7/27/2012 14:06'!
glQuadCoords = () ->
	if !!QuadCoords
		QuadCoords = Texture2Array.with(P(0,0), P(1,0), P(0,1), P(1,1))
	QuadCoords! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'yo 9/4/2013 15:40'!
glReleaseCaches = () ->
	if !!this.glRetainCache
		delete this.glTexture
		delete this.glVertices
		delete this.glShadowVertices
		delete this.glShadowTexture
		delete this.glScaleInvalid! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'bf 7/27/2012 16:13'!
glShadowVertices = () ->
	this.glShadowVertices ?= this.shadowBounds().glVertices()! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'bf 1/31/2013 18:54'!
glUpdateList = (gl, scaleMatrix, depth) ->
	if !!@visible || (!!@shape.needsToBeDrawn() && this.isLeaf())
		if this.glListID
			gl.glDeleteLists(this.glListID, 1)
		delete this.glListID
		return

	var scale = scaleMatrix.composedWithLocal(@transformation)
	var childDepth = if @clipping then depth + 1 else depth
	[@backgroundParts, @contents, @parts].do((boxes) ->
		boxes.do((box) ->
			box.glUpdateList(gl, scale, childDepth)))

	this.glListID ?= gl.glGenLists(1)
	gl.glNewList(this.glListID, GLCompile)

	gl.glPushMatrix()
	gl.glMultMatrixf(@transformation.glTransform())

	var tex
	var fill = @shape.fill()

	// set own color or texture
	if !!@shape.needsToBeDrawn()
		gl.glColorMask(false, false, false, false)
	else
		gl.glColorMask(true, true, true, true)
		if fill.isKindOf(GeziraFillContrastiveOver)
			gl.glColor4f(0, 0.1, 0.1, 0.2)
		else
			if @shape.isRectangular() && fill.isUniform() && !!@shape.hasBorder()
				gl.glColor4f(fill.red() * fill.alpha(), fill.green() * fill.alpha(), fill.blue() * fill.alpha(), fill.alpha())
			else
				tex = this.glCacheTexture(#'glTexture', @shape, #'drawOn:', #'drawingBounds', scale, 1.5)
				gl.installTexture(tex)
				gl.enableTexture(tex)
				gl.glTexCoordPointer(2, GLFloat, 0, this.glQuadCoords())
				gl.glEnableClientState(GLTextureCoordArray)
				gl.glColor4f(1.0, 1.0, 1.0,  1.0)
	// clip to at least current depth, and increment stencil so our kids are only visible in our bounds
	gl.glStencilFunc(GLLequal, depth, 0xFF)
	if @clipping
		gl.glStencilOp(GLKeep, GLKeep, GLIncr)
	else
		gl.glStencilOp(GLKeep, GLKeep, GLKeep)

	// draw own shape
	var vertices = this.glVertices()
	gl.glVertexPointer(2, GLFloat, 0, vertices)
	gl.glEnableClientState(GLVertexArray)
	gl.glDrawArrays(GLTriangleStrip, 0, vertices.size() / 2)
	gl.glDisableClientState(GLVertexArray)

	if tex
		gl.disableTexture(tex)
		gl.glDisableClientState(GLTextureCoordArray)

	// draw children
	[@backgroundParts, @contents, @parts].do((boxes) ->
		boxes.reverseDo((box) ->
			if box.glListID
				gl.glCallList(box.glListID)))

	// clear stencil by drawing own shape again
	if @clipping
		gl.glColorMask(false, false, false, false)
		gl.glStencilFunc(GLLequal, depth, 0xFF)
		gl.glStencilOp(GLKeep, GLKeep, GLReplace)
		vertices = this.glVertices()
		gl.glVertexPointer(2, GLFloat, 0, vertices)
		gl.glEnableClientState(GLVertexArray)
   		gl.glDrawArrays(GLTriangleStrip, 0, vertices.size() / 2)
		gl.glDisableClientState(GLVertexArray)

	gl.glPopMatrix()
	gl.glEndList()! !

!KSBox methodsFor: 'drawing-opengl' stamp: 'bf 7/27/2012 16:13'!
glVertices = () ->
	this.glVertices ?= @shape.drawingBounds().glVertices()! !

!KSBox methodsFor: 'drop' stamp: 'tk 3/8/2013 09:26'!
adjustSizeAndDrop = (aBox) ->
	var defaultDropTarget = @__topContainer__.defaultDropTarget ? @__topContainer__
	var screenBounds = defaultDropTarget.transformationFromGlobal().localBoundsToGlobalNoRound(P(0, 0).extent(defaultDropTarget.extent()))
	var min = P(20, 20)
	var max = screenBounds.extent() * 0.5
	var extent = aBox.bounds().extent().max(min).min(max)
	var scale = extent / aBox.bounds().extent()
	scale = scale.x().min(scale.y())
	aBox.scale(scale)
	this.attachBox(aBox)
	aBox.center(this.extent() / 2.0)
	aBox.topLeft(aBox.topLeft().asIntegerPoint())! !

!KSBox methodsFor: 'drop' stamp: 'yo 10/10/2012 11:09'!
dropForm: aForm named: aString
	| bb |
	bb := KSBox extent: aForm extent fill: Color transparent.
	bb texture: aForm preMultiplyAlpha.
	(aForm bits allSatisfy: [:b | b >= 16rFF000000])
		ifTrue: [bb fill beOpaque].
	bb name: aString.
	bb attachGenericMoveHandler.
	self adjustSizeAndDrop: bb! !

!KSBox methodsFor: 'drop' stamp: 'yo 10/10/2012 11:09'!
dropShape: aShape named: aString
	| bb |
	bb := KSBox withShape: aShape.
	bb name: aString.
	self adjustSizeAndDrop: bb! !

!KSBox methodsFor: 'events' stamp: 'tk 2/27/2013 15:26'!
addEvent = (anEvent) ->
	var strm = this[anEvent.event]
	if strm && !!strm.dormant()
		strm.set(anEvent)! !

!KSBox methodsFor: 'events' stamp: 'ael 3/21/2013 11:56'!
announce = (anEvent) ->
	// if this is an as-yet unhandled event of a type the receiver listens for (see senders of listen:), and is currently listening, and the event passes any necessary tests (e.g., contained within box bounds; modifier-key state is allowed by the modifier masks), then register the receiver as its handler
	if anEvent.handler
		return this
	var strm = this[anEvent.event]
	if strm && !!strm.dormant() && this.handlesEvent(anEvent)
		if anEvent.event == "keyStroke" && strm.lastTime() == -1 && strm.currentValue()
			// make a composite keystroke event so that it does not drop fast typing.
			strm.currentValue().addKeyStroke(anEvent)
		else
			strm.set(anEvent)
			strm.setLastTime(-1)
		anEvent.handler = this! !

!KSBox methodsFor: 'events' stamp: 'yo 8/24/2012 11:12'!
announceInCollections = (evt) ->
	for col in [this.parts, this.contents, this.backgroundParts]
		for e in col
			if evt.handler
				return this
			e.receive(evt)! !

!KSBox methodsFor: 'events' stamp: 'yo 1/31/2013 22:44'!
basicHandlesEvent = (anEvent) ->
	if anEvent.isKeyboardEvent && anEvent.hand.keyboardFocus.currentValue() == this
		return true
	if @visible &&
		(anEvent.event == "pointerLeave" ||
			this.containsPoint(this.localPointFor(anEvent.position)) ||
				anEvent.hand.focus.currentValue() == this)
					this.testModifierKey(anEvent)
	else
		false! !

!KSBox methodsFor: 'events' stamp: 'tk 2/27/2013 13:17'!
blockHaloForContents = (doBlock) ->
	this.allContentsAndPartsDo((e) -> e.wantsHaloFromClick(!!doBlock))! !

!KSBox methodsFor: 'events' stamp: 'yo 1/25/2013 11:03'!
clearEvents = (alarmTime) ->
	for n in EventNameMap.keys()
		if !!(["extent", "bounds"].includes(n))
			var strm = this[n]
			if strm
				strm.set(undefined)
	for value in this
		if (value.isEventStream())
			value.clearEvents(alarmTime)
	if @handler
		for value in @handler
			if (value.isEventStream())
				value.clearEvents(alarmTime)! !

!KSBox methodsFor: 'events' stamp: 'yo 8/28/2012 20:20'!
defaultActionWith = (evt) ->
	if evt.event == "buttonDown"
		if evt.controlKeyPressed()
			evt.handler = self
	if (evt.event == "click" && evt.controlKeyPressed())
		evt.root.haloTarget.set(this)! !

!KSBox methodsFor: 'events' stamp: 'yo 1/24/2013 14:39'!
defaultHandlerWith = (evt) ->
	if this.wantsHaloFromClick() && (evt.event == "buttonDown" || evt.event == "buttonUp")
		this.setDefaultHandlerIfNil(evt)! !

!KSBox methodsFor: 'events' stamp: 'ael 3/5/2013 16:11'!
focusedReceive = (evt) ->
	if evt.isMouseEvent
		this.announceInCollections(evt)
	if evt.handler
		return this
	this.announce(evt)! !

!KSBox methodsFor: 'events' stamp: 'tk 2/21/2013 17:11'!
hand = () ->
	// return the hand of my top container.
	return this.topContainer().worldState().hand! !

!KSBox methodsFor: 'events' stamp: 'yo 7/24/2012 14:16'!
handleControlKey: aBoolean
	aBoolean
		ifTrue: [
			self at: #modifierMask put: ((self at: #modifierMask ifAbsent: [2r1111111]) bitOr: 16).
			self at: #modifierRejectMask put: ((self at: #modifierRejectMask ifAbsent: [0]) bitAnd: (-1 - 16))]
		ifFalse: [
			self at: #modifierRejectMask put: ((self at: #modifierRejectMask ifAbsent: [0]) bitOr: 16).
			self at: #modifierMask put: ((self at: #modifierMask ifAbsent: [2r1111111]) bitAnd: (-1 - 16))]! !

!KSBox methodsFor: 'events' stamp: 'yo 7/24/2012 14:16'!
handleShiftKey: aBoolean
	aBoolean
		ifTrue: [self at: #modifierMask put: ((self at: #modifierMask ifAbsent: [2r1111111]) bitOr: 8).]
		ifFalse: [self at: #modifierRejectMask put: ((self at: #modifierRejectMask ifAbsent: [0]) bitOr: 8)]! !

!KSBox methodsFor: 'events' stamp: 'yo 1/31/2013 22:44'!
handlesEvent = (anEvent) ->
	if this.myHandlesEvent
		return this.myHandlesEvent.value(anEvent)
	return this.basicHandlesEvent(anEvent)! !

!KSBox methodsFor: 'events' stamp: 'yo 1/7/2013 19:04'!
hasHalo = () ->
	// return true if there is a halo showing and I am the target.
	return this.topContainer().haloTarget() == this! !

!KSBox methodsFor: 'events' stamp: 'yo 1/11/2013 10:55'!
listen = (arguments) ->
	for x in arguments
		this[x] = this.eventStream()! !

!KSBox methodsFor: 'events' stamp: 'ael 3/21/2013 12:00'!
receive = (anEvent) ->
	// Main entry point for examining an event that hasn't yet been assigned a handler.
	//  1. forward it to contents and parts, to give them first shot
	//  2. if still not handled, send this.announce() to see if it's an event the receiver listens for
	//  3. if still not handled, see if the receiver wants to register as its default handler

	if anEvent.handler
		return this
	if this.worldState
		return this.receiveForWindow(anEvent)

	var tried = false
	if (@visible && (!!@clipping ||
		this.containsPoint(this.localPointFor(anEvent.position))))
			if anEvent.isMouseEvent
				tried = true
			if !!this.isHand
				this.announceInCollections(anEvent)
	if anEvent.handler
		return this

	// Check if the event is of a type that this box listens for
	this.announce(anEvent)

	// Iff this is a mouse event within the receiver's scope, the receiver can register itself as the event's "defaultHandler" - to be called upon if no later (i.e., outer) box registers as the event's explicit "handler".  Doing this for a control-buttonUp is how a box gets a chance to grab the halo.
	if (!!anEvent.handler && (tried && (this.containsPoint(this.localPointFor(anEvent.position)))))
		this.defaultHandlerWith(anEvent)! !

!KSBox methodsFor: 'events' stamp: 'yo 7/17/2012 16:42'!
receive: anEvent
	| tried |
	anEvent handled ifTrue: [^ self].
	tried := false.

	(anEvent isMouseEvent and: [
		self visible and: [self clipping not or: [
			self containsPoint: (self localPointFor: anEvent position)]]]) ifTrue: [
				tried := true.
				self announceInCollections: anEvent].
	anEvent handled ifTrue: [^ self].
	self announce: anEvent.
	(anEvent handled not and: [tried and: [self containsPoint: (self localPointFor: anEvent position)]])  ifTrue: [
		self defaultHandlerWith: anEvent]! !

!KSBox methodsFor: 'events' stamp: 'yo 7/24/2012 14:17'!
rejectEventsWithModifiers
	self at: #modifierMask put: 0.! !

!KSBox methodsFor: 'events' stamp: 'yo 8/28/2012 19:29'!
setDefaultHandlerIfNil = (evt) ->
	evt.defaultHandler ?= this! !

!KSBox methodsFor: 'events' stamp: 'yo 7/17/2012 19:21'!
setWantsHaloFromClick = (aBoolean) ->
	this.wantsHaloFromClick(aBoolean)! !

!KSBox methodsFor: 'events' stamp: 'ael 3/20/2013 22:53'!
testModifierKey = (anEvent) ->
	// confirm that all modifier bits in the event are set in the modifier mask (which defaults to all 1s) and none are set in the modifier reject mask (which defaults to all 0s)
	if anEvent.buttons == 0
		return true
	var modifierMask = this.modifierMask ? 127
	var modifierRejectMask = this.modifierRejectMask ? 0
	return modifierMask.bitAnd(anEvent.buttons) > 0 &&
		modifierRejectMask.bitAnd(anEvent.buttons) == 0! !

!KSBox methodsFor: 'events' stamp: 'yo 7/17/2012 16:58'!
unblockHaloForContents = () ->
	this.allContentsAndPartsDo((e) -> e.wantsHaloFromClick(true))! !

!KSBox methodsFor: 'events' stamp: 'yo 1/7/2013 19:06'!
wantsHaloFromClick = () ->
	return this.wantsHaloFromClick ? true! !

!KSBox methodsFor: 'factories' stamp: 'ael 3/14/2013 15:05'!
factory = (f) ->
	this.factory = f! !

!KSBox methodsFor: 'file list' stamp: 'yo 2/28/2013 13:27'!
fileListBehavior = (initialFileName) ->
	@shortcutList.setItems(([x.value(), x.key()] for x in @shortcuts))
	this.shortcut = this.streamOf(@shortcuts.first())
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

	this.fire = $$(@acceptButton.fire.doE(() -> {dir: @shortcut, file: @nameField.textContents()}))

	this.nameField.beLineEditor()

	this.titleBar.beDraggerFor(this)! !

!KSBox methodsFor: 'file list' stamp: 'yo 2/27/2013 22:40'!
fileListDefaultShortcuts
	^{'local' -> FileDirectory default.
		'remote' -> PPPusher repository.
		'cache' -> PPPusher repositoryCache}! !

!KSBox methodsFor: 'file list' stamp: 'yo 2/27/2013 22:44'!
fileListLayout
	^ KSSimpleLayout new
		keep: #topLeft	of: 'titleBar' to: 0@0;
		keep: #right	of: 'titleBar' to: #right offset: 0;
		keep: #height	of: 'titleBar' to: 25;

		keep: #topLeft	of: 'directoryField' to: #bottomLeft of: 'titleBar' offset: 10@5;
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

!KSBox methodsFor: 'file list' stamp: 'yo 2/27/2013 22:44'!
fileListSetup = (title, acceptLabel, fileName, patterns, extent, shortcuts) ->
	this.extent(extent)
	this.label.textContents(title)
	@acceptButton.removeAll()
	@acceptButton.textContents(acceptLabel)

	this.patterns = this.streamOf(patterns.findTokens(","))
	this.shortcuts = this.streamOf(shortcuts)

	this.layout(this.fileListLayout())
	this.fileListBehavior(fileName)
	return this! !

!KSBox methodsFor: 'font' stamp: 'yo 1/8/2013 15:51'!
ascent = () ->
	return if @font then @font.ascent() else this.pivotPosition().y() - this.topLeft().y()! !

!KSBox methodsFor: 'font' stamp: 'ael 3/20/2013 12:19'!
beBold = (aBoolean) ->
	// set my shape to be bold if aBooean is true, else not bold 
	if this.unicode() == 0
		return
	if aBoolean !!= this.isBold()
		this.setFont(if aBoolean then @font.bold() else @font.unBold())! !

!KSBox methodsFor: 'font' stamp: 'ael 3/20/2013 12:25'!
beCharacter = (unicode, font) ->
	this.unicode = unicode
	this.font = this.streamOf(font)
	this.shape(font.glyphAt(unicode))		// will work for unicode=0 too! !

!KSBox methodsFor: 'font' stamp: 'yo 8/27/2012 10:54'!
beGlyph = (font, unicode) ->
	this.font(font)
	this.unicode = unicode
	this.shape(font.glyphAt(unicode))! !

!KSBox methodsFor: 'font' stamp: 'ael 3/20/2013 12:19'!
beItalic = (aBoolean) ->
	// set my shape to be bold if aBooean is true, else not bold
	if this.unicode() == 0
		return
	if aBoolean !!= this.isItalic()
		this.setFont(if aBoolean then @font.italic() else @font.unItalic())! !

!KSBox methodsFor: 'font' stamp: 'ael 3/20/2013 12:19'!
beNormal = () ->
	if this.unicode() == 0
		return
	this.setFont(@font.normal())! !

!KSBox methodsFor: 'font' stamp: 'yo 8/29/2013 16:01'!
beOptimizedField = () ->
	this.optimizedField = true
	for e in this.contents()
		e.beOptimizedGlyph()! !

!KSBox methodsFor: 'font' stamp: 'yo 8/29/2013 16:01'!
beOptimizedGlyph = () ->
	this.keysDo((k) ->
		if this[k].isEventStream()
			if !!([#"transformation", #"container"].includes(k))
				this[k] = this[k].currentValue())
	this.optimizedGlyph = true! !

!KSBox methodsFor: 'font' stamp: 'yo 8/14/2013 20:38'!
beTabFromWidths = (tabArray) ->
	// "Set the tab width for this box"

	if !!@shape 
		return
	if !!(this.unicode() == 9) 	// Character tab asciiValue
		return
	if !!tabArray
		return
	var temp1 = @container.width()
	tabArray.reverseDo((tabX) ->
		if tabX - 1 > this.left()
			temp1 = tabX)
	this.ksAssign(#"bounds", this.topLeft().extent(P(temp1 - this.left(), @extent.y())))	//make me wider

//	More complex and not needed:
//	this.shape.set(@shape.copy())
//	@shape.hBearing(P(temp1 - this.left(), @shape.hBearing().y()))! !

!KSBox methodsFor: 'font' stamp: 'tk 1/23/2013 11:46'!
descent = () ->
	return if @font then @font.descent() else this.bottomRight().y() - this.pivotPosition().y()! !

!KSBox methodsFor: 'font' stamp: 'ael 3/20/2013 12:20'!
increaseFontBy = (points) ->
	// replace my shape with a different size of this letter
	if this.unicode() == 0
		return
	this.setFont(@font.withSize(@font.pointSize() + points))! !

!KSBox methodsFor: 'font' stamp: 'yo 1/8/2013 15:52'!
isBold = () ->
	return if @font then @font.style().bitAnd(1) > 0 else false! !

!KSBox methodsFor: 'font' stamp: 'yo 1/8/2013 15:52'!
isGlyph = () ->
	return @font.asBoolean()! !

!KSBox methodsFor: 'font' stamp: 'yo 1/8/2013 15:52'!
isItalic = () ->
	return if @font then @font.style().bitAnd(2) > 0 else false! !

!KSBox methodsFor: 'font' stamp: 'ael 3/14/2013 15:40'!
isNewline = () ->
	var u = this.unicode()
	return (u == 10) || (u == 13)! !

!KSBox methodsFor: 'font' stamp: 'yo 1/8/2013 15:52'!
isNormal = () ->
	return if @font then @font.style() == 0 else false! !

!KSBox methodsFor: 'font' stamp: 'ael 3/14/2013 15:42'!
isWhiteSpace = () ->
	var u = this.unicode()
	return u > 0 && u <= 32! !

!KSBox methodsFor: 'font' stamp: 'yo 1/8/2013 15:52'!
lineSkip = () ->
	return if @font then @font.lineSkip() else 0! !

!KSBox methodsFor: 'font' stamp: 'yo 8/29/2013 15:59'!
optimizedField = () ->
	return @optimizedField ? false! !

!KSBox methodsFor: 'font' stamp: 'yo 8/29/2013 11:13'!
optimizedGlyph = () ->
	return @optimizedGlyph ? false! !

!KSBox methodsFor: 'font' stamp: 'ael 3/20/2013 13:29'!
setFont = (font) ->
	var u = this.unicode()
	if u == 0
		return
	if @font === font
		return
	this.font.set(font)
	var wantedGlyph = font.glyphAt(this.unicode())
	if this.shape() !!== wantedGlyph
		this.shape(wantedGlyph)! !

!KSBox methodsFor: 'font' stamp: 'ael 3/14/2013 15:34'!
unicode = () ->
	return @unicode ? 0! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/31/2013 10:26'!
bounds = () ->
	return @bounds! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/31/2013 10:32'!
computeBounds = () ->
	return @transformation.localBoundsToGlobalNoRound(P(0, 0).extent(@extent))! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/8/2013 13:46'!
containsPoint = (aPoint) ->
	return @shape.containsPoint(aPoint)! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/8/2013 13:46'!
isPureTranslation = () ->
	return this.transformation().isPureTranslation()! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/8/2013 13:46'!
localBoundsToGlobalNoRound = (aRectangle) ->
	return @transformation.localBoundsToGlobalNoRound(aRectangle)! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/8/2013 13:46'!
localPointFor = (aPoint) ->
	return @transformation.invertPoint(if !!@container then aPoint else @container.localPointFor(aPoint))! !

!KSBox methodsFor: 'geometry' stamp: 'yo 8/27/2012 11:13'!
moveToMatchWith = (aBox) ->
	this.transformation(this.transformationToMatchWith(aBox))! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/8/2013 13:39'!
setPivotForGlyph = () ->
	if this.isGlyph()
		try
			var v = @shape.hBearing().negated() / @extent.asFloatPoint()
			this.pivotRatio.set(v)
		catch ex
			this! !

!KSBox methodsFor: 'geometry' stamp: 'ael 2/21/2013 16:34'!
toggleBorder = () ->
	this.borderWidth(if this.borderWidth() == 0 then 1 else 0)! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/8/2013 15:22'!
transformationFromGlobal = () ->
	if !!@container
		return MatrixTransform2x3.identity()
	else
		return @container.transformationFromGlobal().composedWithLocal(@transformation)! !

!KSBox methodsFor: 'geometry' stamp: 'yo 1/8/2013 13:47'!
transformationToMatchWith = (aBox) ->
	var tr = aBox.transformationFromGlobal()
	var tr2 = @container.transformationFromGlobal().inverseTransformation()
	return tr2.composedWithLocal(tr)! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 7/18/2012 09:36'!
basicTransformation = (aTransformation) ->
	var elemInOpaque = !!(this.container()) && this.container().opaqueDamageRect()
	if !!elemInOpaque
		this.invalidRectInContainer(this.basicFullDrawingBounds())
	this._ksSet_put("transformation", aTransformation)
	if !!elemInOpaque
		this.invalidRect(this.basicFullDrawingBounds)! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:39'!
bottom = (aNumber) ->
	this.translateByInOwner(P(0, aNumber - this.bounds().bottom()))! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:39'!
bottomCenter = (aPoint) ->
	this.translateByInOwner(aPoint - this.bounds().bottomCenter())! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:48'!
bottomLeft = () ->
	return this.bounds().bottomLeft()! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:51'!
bottomRight = () ->
	return this.bounds().bottomRight()! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:51'!
center = () ->
	return (this.bounds().topLeft() + this.bounds().bottomRight()) / 2.0! !

!KSBox methodsFor: 'geometry access' stamp: 'ael 3/5/2013 16:11'!
height = (aNumber) ->
	this.extent(P(@shape.width(), aNumber))! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/31/2013 10:30'!
left = () ->
	return this.bounds().left()! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/31/2013 10:30'!
leftCenter = () ->
	return this.bounds().leftCenter()! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 15:25'!
pivotOffset = () ->
	//The pivot is the center of rotation of a box and the baseline for a letter.  Return the pivot offset as a displacement from the top left of this box at a scale of 1.0.  pivotOffset does not change when the box is scaled.  (pivotPosition does change with scale and is in the container's coords)
	return @pivotRatio * @extent! !

!KSBox methodsFor: 'geometry access' stamp: 'ael 3/5/2013 16:11'!
pivotPosition = (aPoint) ->
	// Move this box so that the pivot point is at aPoint in the coordinates of this box's container.  The pivot point is the center of rotation of a box and the baseline for a letter. 
	var tr = @transformation
	var n = tr.inverseTransformation().transformDirection(tr.transformPointNoRound(this.pivotOffset()) - aPoint)
	if (!!n.x().closeTo(0.0) || !!n.y().closeTo(0.0))
		this.translateBy(n.negated())! !

!KSBox methodsFor: 'geometry access' stamp: 'tk 1/11/2013 11:33'!
pivotRatio = (fractionalPoint) ->
	this.pivotRatio.set(fractionalPoint)! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:40'!
right = (aNumber) ->
	this.translateByInOwner(P(aNumber - this.bounds().right(), 0))! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:40'!
rightCenter = (aPoint) ->
	this.translateByInOwner(aPoint - this.bounds().rightCenter())! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:40'!
rotation = (aNumber) ->
	this.rotateBy(aNumber - this.rotation())! !

!KSBox methodsFor: 'geometry access' stamp: 'bf 10/17/2012 14:16'!
scale = (aNumberOrPoint) ->
	var tr = @transformation
	var rot = tr.rotation()
	var off = tr.offset()
	var m = MatrixTransform2x3
	this.transformation(m.withRadRotation(rot).composedWithLocal(m.withScale(aNumberOrPoint)).composedWithGlobal(m.withOffset(off)))! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 15:27'!
scale2D = () ->
	return @transformation.scale2D()! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:41'!
top = (aNumber) ->
	this.translateByInOwner(P(0, aNumber - this.bounds().top()))! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:41'!
topCenter = (aPoint) ->
	this.translateByInOwner(aPoint - this.bounds().topCenter())! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/31/2013 10:32'!
topLeft = (aPoint) ->
	return this.translateByInOwner(aPoint - this.bounds().topLeft())! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 15:29'!
topRight = () ->
	return this.bounds().topRight()! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 8/14/2013 20:16'!
transformation = (aTransformation) ->
	if !!@transformation.similarScaleAs(aTransformation)
		this.glInvalidateScale()
	this.ksAssign(#"transformation", aTransformation)
	this.ksAssign(#"bounds", this.computeBounds())
	if !!@isHand && @container
		@container.layoutChangedFrom(this)! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 8/31/2012 11:06'!
translateBy = (aPoint) ->
	if !!aPoint.closeTo(P(0, 0))
		this.transformation(@transformation.composedWithLocal(MatrixTransform2x3.withOffset(aPoint)))! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 15:29'!
translateByInOwner = (aPoint) ->
	return this.transformation(MatrixTransform2x3.withOffset(aPoint).composedWithLocal(@transformation))! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 8/27/2012 12:03'!
translation = (aPoint) ->
	this.transformation(@transformation.clone().offset(aPoint))! !

!KSBox methodsFor: 'geometry access' stamp: 'yo 1/8/2013 13:41'!
width = (aNumber) ->
	this.extent(P(aNumber, @shape.height()))! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 1/25/2013 10:28'!
forceWithinContainer = () ->
	//Keep me within the bounds of my container.
	if !!@container
		return this
	if this.right() > @container.width()
		this.right(@container.width())
	if this.left() < 0.0
		this.left(0.0)
	if this.bottom() > @container.height()
		this.bottom(@container.height())
	if this.top() < 0.0
		this.top(0.0)! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 1/8/2013 13:44'!
forwardBy = (aNumber) ->
	// Move forward by a given number of units.
	this.translateBy(aNumber * P(1, 0))! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 8/29/2012 13:35'!
globalPointFor = (aPoint) ->
	var p = @transformation.transformPointNoRound(aPoint)
	if !!@container
		return p
	return @container.globalPointFor(p)! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 7/19/2012 18:01'!
invertPoint = (aPoint) ->
	@transformation.invertPoint(aPoint)! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 8/27/2012 11:13'!
localTransformBy = (aTransform) ->
	this.transformation(@transformation.composedWithGlobal(aTransform))! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 1/8/2013 15:39'!
pointInContainer = (aPoint) ->
	return @transformation.transformPointNoRound(aPoint)! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 7/25/2012 10:47'!
rotateBy = (radians) ->
	this.rotateByAround(radians, @pivotRatio)! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 7/25/2012 10:48'!
rotateByAround = (radians, relativeOffset) ->
	var offset = @transformation.transformPointNoRound(@extent * relativeOffset)
	var tfm = MatrixTransform2x3.withOffset(offset)
	tfm = tfm.composedWithLocal(MatrixTransform2x3.withRadRotation(radians))
	tfm = tfm.composedWithLocal(MatrixTransform2x3.withOffset(offset.negated()))
	this.localTransformBy(tfm)! !

!KSBox methodsFor: 'geometry transformation' stamp: 'yo 7/19/2012 19:01'!
scaleBy = (aNumberOrPoint) ->
	this.scaleByAround(aNumberOrPoint, @pivotRatio)! !

!KSBox methodsFor: 'geometry transformation' stamp: 'ael 3/5/2013 16:12'!
scaleByAround = (aNumberOrPoint, relativeOffset) ->
	var tr = @transformation
	var orig = tr.offset()
	var tfm = tr.clone().offset(P(0, 0))
	tfm = tfm.composedWithLocal(MatrixTransform2x3.withScale(aNumberOrPoint))
	tfm.offset(orig)
	var offset2 = @extent * relativeOffset
	var offset = offset2 / aNumberOrPoint
	tfm = tfm.composedWithLocal(MatrixTransform2x3.withOffset(offset - offset2))
	this.transformation(tfm)! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 02:18'!
addGradStopAt = (ratio) ->
	var n = this.newStop()
	var dir = this.gradDir()
	var stops = this.gradStops
	n.center(this.gradStopPointForRatio(ratio))
	stops._add_afterIndex(n, 1)
	this.sortStops()
	var before = stops.before(n)
	var after = stops.after(n)
	var beforeR = (this.targetPointFromGradStop(before) - this.gradFrom()).r() / dir.r()
	var afterR = (this.targetPointFromGradStop(after) - this.gradFrom()).r() / dir.r()
	n.gradStopColor(after.gradColor._mixed_with((ratio - beforeR) / (afterR - beforeR), before.gradColor))
	this.addAsPartsFirst(n)
	this.setStopsRatios()
	return n! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/8/2013 15:50'!
addGradientEditor = (target, elementOrNil, updater) ->
	// the second argument allows the caller to specify a particular element in the target's shape to hold the fill, rather than the default (which would be the first non-stroked element in target, retrieved afresh each time by gradTargetElement())
	if @gradTarget
		return						// gradient tool is already set up
	this.gradTarget = target
	this.gradElement = elementOrNil
	this.gradUpdater = updater
	var isRadial = false
	var priorFill = this.gradTargetElement().fill()
	if priorFill instanceof GeziraFillGradient
		var stops = (Association._key_value(each.key(),
			Color.fromArray(each.value())) for each in priorFill.stops())
		isRadial = priorFill instanceof GeziraFillRadialGradient
		if isRadial
			// only fill centre and radius are stored; set the direction to pass through the box centre
			var fillCenter = priorFill.center()
			var boxCenter = target.extent() / 2.0
			var direction = boxCenter - fillCenter
			var normalized = if direction.isZero() then P(1, 0) else direction.normalized() 
			var fromTo = [fillCenter, priorFill.radius()*normalized + fillCenter]
		else
			fromTo = priorFill.fromTo()
	else
		stops = {0: priorFill.asColor(),
			1: priorFill.asColor().makeForegroundColor()}.associations()
		fromTo = [P(0, 0), target.extent()]
	this.gradIsRadial = isRadial

	// if we're editing the default fill element, blank out any other elements in the shape that have fills
	if !!elementOrNil
		for path in target.shape().elements()
			if path.fill() && !!path.stroke()
				path.fill(nil)

	this.initializeGradientEditor(fromTo.first(), fromTo.second(), stops)! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 17:32'!
beGradientStop = () ->
	this.attachGenericMoveHandler()
	this.moved = this.eventStream()
	this.theDownFunc = (evt) -> this.beingDragged = true
	this.theMoveFunc = (evt) ->
		var stops = @container.gradStops
		if !!(stops.last() === this || stops.first() === this)
			var ratio = @container.gradStopRatioNear(evt.position)
			var pos = @container.gradStopPointForRatio(ratio)
		else
			pos = @container.localPointFor(evt.position)
		this.center(pos)

	this.theUpFunc = (evt) ->
		delete this.beingDragged
		var stops = @container.gradStops
		if !!(stops.last() === this || stops.first() === this)
			var ratio = @container.gradStopRatioNear(evt.position)
			if ratio < 0 || ratio > 1.0
				stops.remove(this)
				@container.stopsChanged()
				this.delete()

	// maintain the represented colour independent of fill, so fill can change on mouseOver etc
	this.gradStopColor = (color) -> this.fill(this.defaultFill = this.gradColor = color)

	this.moved = $$(@transformation.mapE((ev) -> if @beingDragged then this else undefined))
	this.attachButtonHandler()
	// redefine "fire" to fire only when shift-clicked
	this.mayFire = this.fire
	this.fire = $$(@mayFire.mapE((ev) ->
		if ev.buttons && ev.shiftKeyPressed() then ev else undefined))
	this.defaultLooks = this.pressedLooks = () -> {fill: this.gradColor, borderFill: null}
	this.colorPick = $$(@doubleClick.doE(() -> @__topContainer__.invokeColorPicker(@container.gradTarget.topRight() + P(10, 0), this.gradColor, this, (target, color) ->
		target.gradStopColor(color)
		target.container().stopsChanged())))! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/8/2013 15:42'!
deleteGradientTool = () ->
	if @gradTarget
		for box in @gradStops
			box.delete()
		delete this.gradStops
		delete this.gradStopsRatios
		@gradDirection.delete()
		delete this.gradDirection
		delete this.gradTarget
		delete this.gradElement
		delete this.gradUpdater
		delete this.gradIsRadial! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 3/31/2013 23:24'!
gradDir = () ->
	// in the target's coordinates
	return this.gradTo() - this.gradFrom()! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 02:04'!
gradFrom = () ->
	// in the target's coordinates
	return this.targetPointFromGradStop(@gradStops.first())! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 00:28'!
gradStopPointFor = (targetPoint) ->
	// convert a point in target space to a coordinate relative to the gradient editor
	return this.localPointFor(@gradTarget.globalPointFor(targetPoint))! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 00:38'!
gradStopPointForRatio = (ratio) ->
	// convert a ratio on the gradient-definition line to a coordinate relative to the gradient editor
	return this.gradStopPointFor(this.gradFrom() + (this.gradDir() * ratio))! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 3/31/2013 23:22'!
gradStopRatioNear = (globalPos) ->
	var localPos = @gradTarget.localPointFor(globalPos)
	var from = this.gradFrom()
	var a = this.gradDir()
	var b = localPos - from
	return if a.isZero() then 0.0 else a.dotProduct(b) / a.r().squared()! !

!KSBox methodsFor: 'gradient editor' stamp: 'bf 1/17/2013 16:23'!
gradStopShape = () ->
	return KSShape.new().elements([
		GeziraPath.oval(P(0,0).extent(P(12,12))).fill(GeziraFill.contrastiveOver(0.2)).stroke(GeziraStroke.width(2)),
		GeziraPath.oval(P(0,0).extent(P(12,12)))])! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 09:48'!
gradTargetElement = () ->
	// if the gradient element is not specified, pull it out of the shape each time (this enables the gradient editor to track changes in the target, such as when resized using the halo)
	return this.gradElement ? this.gradTarget.shape().ensureFillElement()! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 02:04'!
gradTo = () ->
	// in the target's coordinates
	return this.targetPointFromGradStop(@gradStops.last())! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 16:48'!
initializeGradientEditor = (from, to, stops) ->
	var dir = to - from
	this.gradStops = []
	for s in stops
		var n = this.newStop()
		n.center(this.gradStopPointFor(from + (dir * s.key())))
		n.gradStopColor(s.value())
		this.addAsPartsFirst(n)
		this.gradStops.add(n)

	this.gradStops.first().center(this.gradStopPointFor(from))
	this.gradStops.last().center(this.gradStopPointFor(to))
	var dir = this.gradDirection = KSBox.new()
	dir.beConnectorHandler(this.gradStops.first(), this.gradStops.last())
	dir.borderWidth(20)
	dir.borderFill(GeziraFill.contrastiveOver(0.2))
	dir.attachButtonHandler()
	dir.enteredFill = GeziraFill.contrastiveOver(0.4)		// default is to mix with a solid, which contrastive fills can't do
	dir.pressedFill = GeziraFill.contrastiveOver(0.6)	// likewise
	this.addAsParts(this.gradDirection)
	this.stopsChanged()

	this.stopPositionWatcher = $$(switchColE(@gradStops, "moved").mapE((item) ->
		if item === this.gradStops.first() || item === this.gradStops.last()
			this.moveGradStopsRelatively()
		this.stopsChanged()))
	this.setRelatives = $$(switchColE(@gradStops, "buttonDown").doE(() -> this.setStopsRatios()))

	// note: gradient handles reconfigure "fire" to happen only when shift key is down
	this.toggleRadialWatcher = $$(switchColE(@gradStops, "fire").mapE((ev) ->
		var item = ev.handler
		if item == this.gradStops.first() || item == this.gradStops.last()
			this.toggleRadialGradient(item)))

	this.addStopWatcher = $$(@gradDirection.doubleClick.mapE((ev) ->
		this.addGradStopAt(this.gradStopRatioNear(ev.position))))

	this.scaleWatcher = $$(@gradTarget.transformation.mapE((trans) ->
		if !!trans.sameScaleAs(@gradTarget.transformation')
			this.repositionStops()))! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 02:09'!
moveGradStopsRelatively = () ->
	for i in [1 .. @gradStops.size() - 1]
		@gradStops[i].center(this.gradStopPointForRatio(@gradStopsRatios[i]))! !

!KSBox methodsFor: 'gradient editor' stamp: 'yo 1/10/2013 15:59'!
newStop = () ->
	var box = KSBox.withShape(this.gradStopShape())
	box.name("stop")
	box.beGradientStop()
	return box! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 10:11'!
repositionStops = () ->
	//  respond to a change in the target's shape
	var fromTo = this.gradTargetElement().fill().fromTo()
	this.gradStops.first().center(this.gradStopPointFor(fromTo.first()))
	this.gradStops.last().center(this.gradStopPointFor(fromTo.second()))
	this.moveGradStopsRelatively()! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 02:11'!
setStopsRatios = () ->
	var r = this.gradDir().r()
	this.gradStopsRatios = ((this.targetPointFromGradStop(s) - this.gradFrom()).r() / r for s in this.gradStops)! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 02:22'!
sortStops = () ->
	var stops = this.gradStops
	var mid = stops._copyFrom_to(2, stops.size() - 1)
	var from = @gradStops.first().center()		// in gradient-editor coords
	mid.sort((a, b) -> (a.center().squaredDistanceTo(from) < b.center().squaredDistanceTo(from)))
	stops._replaceFrom_to_with_startingAt(2, stops.size() - 1, mid, 1)! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/8/2013 15:55'!
stopsChanged = () ->
	// as part of gradient-editor behaviour, update the fill in response to a change in the stops
	var target = @gradTarget
	if !!target
		return

	this.sortStops()		// sorts by absolute distance from "from", but we ignore -ve ones
	var fillStops = []
	var stopMovers = @gradStops
	for s in stopMovers
		var ratio = this.gradStopRatioNear(this.globalPointFor(s.center()))
		if s === stopMovers.first() || s === stopMovers.last() || ratio._between_and(0, 1.0)
			fillStops.push(Association._key_value(ratio, s.gradColor))

	var offset = target.shape().offset()
	var from = this.targetPointFromGradStop(stopMovers.first()) - offset
	var to = this.targetPointFromGradStop(stopMovers.last()) - offset
	var newGrad = if this.gradIsRadial then GeziraFill._gradient_center_radius(fillStops, from, (to - from).r()) else GeziraFill._gradient_from_to(fillStops, from, to)
	this.gradUpdater._value_value(this.gradTarget, newGrad)! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/1/2013 02:03'!
targetPointFromGradStop = (stop) ->
	// in the target's coordinates
	return @gradTarget.localPointFor(this.globalPointFor(stop.center()))! !

!KSBox methodsFor: 'gradient editor' stamp: 'ael 4/8/2013 15:55'!
toggleRadialGradient = (pivot) ->
	// pivot is the gradStop (at one end or the other) that was shift-clicked.  It becomes the centre of a radial gradient, or the "from" of a linear one
	var target = @gradTarget
	if !!target
		return

	var oldGrad = this.gradTargetElement().fill()
	var stops = oldGrad.stops()
	// reverse the stops if the last is now to become the centre of a radial gradient
	if pivot === @gradStops.last()
		stops = (Association._key_value(1.0 - each.key(), each.value()) for each in stops)
		this.gradStops = this.gradStops.reversed()
	var offset = target.shape().offset()
	var from = this.gradFrom() - offset
	var to = this.gradTo() - offset
	this.gradIsRadial = !!this.gradIsRadial
	var newGrad = if this.gradIsRadial then GeziraFill._gradient_center_radius(stops, from, (to - from).r()) else GeziraFill._gradient_from_to(stops, from, to)
	this.gradUpdater._value_value(this.gradTarget, newGrad)! !

!KSBox methodsFor: 'halo' stamp: 'yo 3/1/2013 14:22'!
adjustHalo: gtr for: target
	| w ext newExt o b whole |
	w := self at: #haloWidth ifAbsent: [12].
	o := self at: #haloOffset ifAbsent: [10].
	whole := self at: #halo.
	ext := target extent * gtr scale2D.
	newExt := (ext x max: 30)@(ext y max: 30).
	whole extent: newExt.
	whole translateBy: (ext - newExt) / 2.

	b := (w / 2) + o.
	self at: #haloLayout ifAbsentPut: (KSSimpleLayout new
		keep: #left of: 'haloR' to: #right offset: o;
		keep: #top of: 'haloR' to: #top offset: (w+o) negated;
		keep: #height of: 'haloR' to: #height offset: (o*2+w);
		keep: #width of: 'haloR' to: w;
		keep: #top of: 'haloB' to: #bottom offset: o;
		keep: #left of: 'haloB' to: #left offset: o negated;
		keep: #width of: 'haloB' to: #width offset: (o*2+w);
		keep: #height of: 'haloB' to: w;
		keep: #bottom of: 'haloT' to: #top offset: o negated;
		keep: #left of: 'haloT' to: #left offset: (w+o) negated;
		keep: #height of: 'haloT' to: w;
		keep: #width of: 'haloT' to: #width offset: (o*2+w);
		keep: #top of: 'haloL' to: #top offset: o negated;
		keep: #right of: 'haloL' to: #left offset: o negated;
		keep: #width of: 'haloL' to: w;
		keep: #height of: 'haloL' to: #height offset: (o*2+w);

		keep: #center of: '1.0@0.5' to: #rightCenter offset: b@0;
		keep: #center of: '0.5@1.0' to: #bottomCenter offset: 0@b;
		keep: #center of: 'menu' to: #topLeft offset: (b@b) negated;
		keep: #topLeft of: 'debug' to: #topRight of: 'menu';	"also enforced manually in #layout method"
		keep: #center of: 'duplicate' to: #topRight offset: b@b negated;
		keep: #center of: 'rot' to: #bottomLeft offset: (b negated)@b;
		keep: #center of: 'scale' to: #bottomRight offset: b@b;
		yourself).
	self haloLayout.! !

!KSBox methodsFor: 'halo' stamp: 'yo 2/27/2013 23:50'!
beHaloEdgeHandler = () ->
	// In the Halo, the blue outline that moves the object.
	// make a stream that keeps up with the halo target
	this.beDraggerFor(this)
	this.moveTarget = $$(@container.haloTarget)! !

!KSBox methodsFor: 'halo' stamp: 'yo 1/22/2013 20:44'!
beHaloMenuActionHandler = () -> 
	// this is the handler of a menu item.
	// When a item fires, perform the selector on the menu's haloTarget, with the user event
	this.haloMenuAction = $$(@fire.mapE((x) ->
		this.ksMenuPerform(this.actionSelector, [@container.haloTarget, x])))! !

!KSBox methodsFor: 'halo' stamp: 'yo 10/5/2012 15:12'!
beHaloResizeHandler = () ->
	this.target = $$(@container.haloTarget)
	this.attachDownMoveUpHandlers(
		(downEvt) ->
			if @target
				this.clickPoint = @target.localPointFor(downEvt.position) - @target.extent(),
		(moveEvt) ->
			if @target
				var diff = @target.localPointFor(moveEvt.position) - this.clickPoint
				if @name == "1.0@0.5"
					@target.width(diff.x())
				if @name == "0.5@1.0"
					@target.height(diff.y()),
		null)! !

!KSBox methodsFor: 'halo' stamp: 'yo 10/5/2012 15:12'!
beHaloRotationHandler = () ->
	this.beRotationHandler(null)
	this.target = $$(@container.haloTarget)! !

!KSBox methodsFor: 'halo' stamp: 'yo 10/5/2012 15:12'!
beHaloScaleHandler = () ->
	this.beScaleHandler(null)
	this.target = $$(@container.haloTarget)! !

!KSBox methodsFor: 'halo' stamp: 'yo 1/9/2013 19:57'!
gradMoveStopsRelatively = (r) ->
	var from = @container.gradFrom
	var a =@container.direction
	this.center(from + (r * a))! !

!KSBox methodsFor: 'halo' stamp: 'yo 1/28/2013 18:49'!
haloLayout = () ->
	var whole = @halo
	@haloLayout.layOut(whole)
	//"make sure all parts are visible"
	var wBounds = whole.container().bounds()
	whole.contentsAndPartsDo((e) ->
		var p = whole.globalPointFor(e.center())
		if !!(wBounds.containsPoint(p))
			e.center(whole.localPointFor(p.adhereTo(wBounds))))
	//"make sure debug menu button does not overlap menu button"
	var d = whole.atName("debug")
	var m = whole.atName("menu")
	if d && m
		d.topLeft(m.topRight())! !

!KSBox methodsFor: 'hand' stamp: 'yo 3/6/2013 21:13'!
beHand = () ->
	this.name("hand")
	this.isHand = true
	this.focus = this.streamOf(nil)
	this.keyboardFocus = this.streamOf(nil)
	this.lastButtonDown = this.streamOf(nil) 
	this.lastEntered = this.streamOf({box: nil, event: nil})
	this.doButtonUp = $$(@buttonUp.mapE((ev) ->
		this.dropBox(ev)
		this.focus(null)))

	this.attachBox = (box) ->
		var global = box.transformationFromGlobal()
		this.addFirst(box)
		box.transformation(global)
		box.localTransformBy(this.transformationFromGlobal().inverseTransformation())
		var bnds = box.bounds()
		if !!bnds.containsPoint(P(0, 0))
			box.topLeft(bnds.topLeft()._min_max(P(0, 0), bnds.extent().negated()))
		box.formerPosition = {container: box.container(), translation: box.topLeft()}

	this.dropBox = (ev) ->
		for b in this.contents()
			var target = if @lastEntered && @lastEntered.box then @lastEntered.box else @container
			if target.hasContainer(b) || b.hasContainer(target)
				target = @container
			var trans = b.transformation().composedWithGlobal(this.transformationFromGlobal())
			trans = trans.composedWithGlobal(target.transformationFromGlobal().inverseTransformation())
			if target.hasOwnProperty("dropRequest")
				target.dropRequest.set({box: b, transformation: trans, hand: this.whole, formerPosition: b.formerPosition})
				b.formerPosition = undefined
			else
				b.transformation(trans)
				target.addFirst(b)
			if b.hasOwnProperty("droppedBy")
				b.droppedBy.set({hand: this.whole, target: target})

	this.filesDropped = $$(@container.dropFiles)
	this.acceptFiles = $$(@filesDropped.mapE((dropEvent) ->
		for pair in dropEvent.contents
			if pair[0].isForm()
				this._dropForm_named(pair[0], pair[1])
			else
				this._dropShape_named(pair[0], pair[1])))

	this.lastClicks = []
	this.listen(["buttonUp"])
	return this! !

!KSBox methodsFor: 'hand' stamp: 'yo 1/25/2013 10:37'!
focus  = (aBoxOrNil) ->
	if aBoxOrNil == @focus'
		return undefined
	this.focus.set(aBoxOrNil)
//	this.lastEntered({box: aBoxOrNil, position: nil})
	return this! !

!KSBox methodsFor: 'hand' stamp: 'yo 8/24/2012 11:18'!
isDoubleClick = (evt, box) ->
	return (@lastClicks.size() == 1 && @lastClicks.last().first() == box) &&
		evt.position.dist(@lastClicks.last().second().position) < 20 &&
			evt.time - @lastClicks.last().second().time < 500! !

!KSBox methodsFor: 'hand' stamp: 'ael 3/27/2013 23:22'!
keyboardFocus = (aBoxOrNil) ->
	if aBoxOrNil == @keyboardFocus'
		return undefined
	if @keyboardFocus' && @keyboardFocus'.showSelection
		@keyboardFocus'.showSelection.set(false)
	if aBoxOrNil && aBoxOrNil.showSelection
		aBoxOrNil.showSelection.set(true)
	this.keyboardFocus.set(aBoxOrNil)! !

!KSBox methodsFor: 'hand' stamp: 'yo 8/22/2012 11:59'!
lastClicked = (evt, box) ->
	var lastClicks = @lastClicks
	if !!box
		lastClicks.removeAll()
	if !!(lastClicks.size() == 0 || lastClicks.last().first() == box)
		lastClicks.removeAll()
	lastClicks.push([box, evt])! !

!KSBox methodsFor: 'hand' stamp: 'ael 2/25/2013 20:37'!
lastEntered = (newEvent) ->
	if @lastEntered'.box === newEvent.box
		return undefined
	if !!newEvent.box || (@lastEntered'.box !!== newEvent.box)
		if @lastEntered'.box
			var ev = KSUserEvent.newFrom(newEvent.event)
			ev.event = "pointerLeave"
			@lastEntered'.box.addEvent(ev.event, ev)
	if newEvent.box && (@lastEntered'.box !!== newEvent.box)
		var ev = KSUserEvent.newFrom(newEvent.event)
		ev.event = "pointerEnter"
		newEvent.box.addEvent(ev.event, ev)
	this.lastEntered.set(newEvent)! !

!KSBox methodsFor: 'hand' stamp: 'yo 1/8/2013 15:42'!
maybeResetLastClicked = (evt) ->
	var lastClicks = this.lastClicks
	if lastClicks.size() == 0
		return this
	if Time._milliseconds_since(evt.time, lastClicks.last().last().time) > 500
		lastClicks.removeAll()! !

!KSBox methodsFor: 'handlers' stamp: 'ael 3/25/2013 23:55'!
addSliderHandler = () ->
	this.knob = this.factory().newSliderKnob(@extent)
	this.knob.attachGenericMoveHandler()
	this.knob.name("knob")
	this.knob.slider = this
	this.knob.min = P(0, 0)

	this.knobFraction = this.streamOf(0.3)
	this.setKnobExtent = $$(this.knob.extent(@extent * P(1, @knobFraction)))
	this.knob.extent(@extent * P(1, @knobFraction))
	this.knob.name("sliderKnob")
	var initPoint = @extent - this.knob.bounds().extent()
	this.knob.beSliderKnob(initPoint)
	this.resizeSlider = $$(@extent.doE(() ->
		if @extent ~= @extent'
			this.setSliderCurrentValue(@sliderValue2D)))

	this.attachGenericMoveHandler()
	this.advanceInPage = true
	this.sliderTarget = this.knob
	this.sliderValue2D = $$(@knob.sliderValue2D)
	this.sliderValue2D.set(P(0, 0))
	this.sliderValue = $$(@sliderValue2D.y())
	this.sliderValue.set(0)
	this.addAsParts(this.knob)
	this.handleControlKey(false)
	this! !

!KSBox methodsFor: 'handlers' stamp: 'yo 4/3/2013 15:19'!
attachButtonHandler = () ->
	this.isButton = this.streamOf(true)
	this.actsWhen = this.streamOf("buttonUp")
	this.pressed = $$(mergeE(!!!!@buttonDown, !!@buttonUp, !!@pointerLeave)).startsWith(false)
	this.entered = $$(mergeE(!!!!@pointerEnter, !!@pointerLeave)).startsWith(false)
	this.selected = this.streamOf(false)
	this.clicked = $$(@buttonUp && @pressed')
	this.highlightEnabled = this.streamOf(true)

	this.fireRequest = this.eventStream()
	this.fire = $$(mergeE(
			@fireRequest,
			@actsWhen == "buttonUp" && @clicked,
			@actsWhen == "buttonDown" && @buttonDown).mapE((x) ->
				if @fireRequest
					this.fireRequest.set(undefined)	// otherwise button events will never appear again
					{handler: this}
				else
					if x then if @actsWhen == "buttonUp" then @buttonUp else @buttonDown else undefined))

	this.looks = $$(mergeE(@entered, @pressed, @selected, @highlightEnabled).doE(() ->
		var ll
		if @pressed && @highlightEnabled
			ll = this.pressedLooks()
		else
			if @entered && @highlightEnabled
				ll = this.enteredLooks()
			else
				if @selected
					ll = this.selectedLooks()
		ll ? this.defaultLooks()))
	
	this.changeFill = $$(@looks.mapE((fills) ->
		if fills.fill
			this.fill(fills.fill)
		if fills.borderFill
			this.borderFill(fills.borderFill)))

	this.defaultLooks = () ->
		{fill: this.defaultFill? null,
		borderFill: this.defaultBorderFill ? null}
	this.enteredLooks = () ->
		this.defaultFill ?= @shape.fill()
		{fill: this.enteredFill ? this.defaultFill._mixed_with(0.5, GeziraFill._uniform(Color.white())), 
		borderFill: this.enteredBorderFill ? null}
	this.pressedLooks = () ->
		{fill: this.pressedFill ? (if this.defaultFill then this.defaultFill._mixed_with(0.5, Color._red().asGeziraFill()) else Color._red()),
		borderFill: this.pressedBorderFill ? null}
	this.selectedLooks = () ->
		{fill: this.selectedFill ? Color.gray().lighter(),
		borderFill: this.selectedBorderFill ? null}

	this.listen(["buttonDown", "buttonUp", "doubleClick", "pointerLeave",  "pointerEnter",  "motionQuery"])
	this.handleControlKey(false)
	return this! !

!KSBox methodsFor: 'handlers' stamp: 'yo 2/27/2013 23:00'!
attachDownMoveUpHandlers = (downFunc, moveFunc, upFunc) ->
	this.theDownFunc = downFunc
	this.theMoveFunc = moveFunc
	this.theUpFunc = upFunc

	this.downFunc2 =	(evt) ->
		var obj = evt.handler
		obj.pointerMotion.dormant(false)
		obj.buttonUp.dormant(false)
		evt.hand.focus(obj)
		if this.theDownFunc
			this.theDownFunc(evt)

	this.moveFunc2 =	(evt) ->
		if this.theMoveFunc
			this.theMoveFunc(evt)

	this.upFunc2 =		(evt) ->
		var obj = evt.handler
		evt.hand.focus(null)
		obj.pointerMotion.dormant(true)
		obj.buttonUp.dormant(true)
		if this.theUpFunc
			this.theUpFunc(evt)

	this.listen(["pointerMotion", "buttonUp", "buttonDown"])
	this.pointerMotion.dormant(true)
	this.buttonUp.dormant(true)

	this.doButtonDown		=	$$(@buttonDown.mapE(@downFunc2))
	this.doPointerMotion	=	$$(@pointerMotion.mapE(@moveFunc2))
	this.doButtonUp		=	$$(@buttonUp.mapE(@upFunc2))
	this.handleControlKey(false)! !

!KSBox methodsFor: 'handlers' stamp: 'yo 1/11/2013 10:51'!
attachDropAcceptor = () ->
	// define methods that allow the handler to accept dropped objects
	this.dropRequest = this.eventStream()
	// a dropRequest, called req below, has this structure:
	// {box: box, transformation: transformation, hand: hand, formerPosition: {container: box, translation: point}}

	this.doDrop = $$(@dropRequest.mapE((req) ->
		if this.mayAccept(req)
			this.addDroppedBox(req)  // addDroppedBox and mayAccept are properties to store functions
		else
			if req.formerPosition		
				req.formerPosition.container.addFirst(req.box)
				req.box.translation(req.formerPosition.translation)
			else
				req.hand.container().addFirst(req.box)
				req.box.translation(req.hand.translation())))

	this.mayAccept = (request) -> true

	this.addDroppedBox = (request) ->
		request.box.transformation(request.transformation)
		this.addFirst(request.box)

	this.handleControlKey(false)
	this.listen(["buttonUp", "pointerEnter", "pointerLeave", "motionQuery"])! !

!KSBox methodsFor: 'handlers' stamp: 'yo 5/8/2013 11:28'!
attachGenericMoveHandler = () ->
	this.advanceInPage = this.streamOf(false)
	this.jumpOnButtonDown = this.streamOf(false)
	this.slider = this.streamOf(null)
	this.sliderTarget = this.streamOf(null)
	this.attachDownMoveUpHandlers(
		(downEvt) ->
			var c = this.sliderKnob().container().localPointFor(downEvt.position)
			if @advanceInPage
				var oldPos = this.sliderKnob().topLeft()
				var newPos = P(oldPos.x(),
					if c.y() < oldPos.y() then oldPos.y() - this.sliderKnob().height() else oldPos.y() + this.sliderKnob().height())
				this.sliderMoveTo(newPos)
				delete downEvt.object.pointerMotion
				downEvt.hand.focus(null)
			else
				if @jumpOnButtonDown
					var newPos = c - (this.sliderKnob().bounds().extent() / 2.0)
					this.sliderMoveTo(newPos)
				this.clickDiff = (@sliderTarget ? this).topLeft() - c
			return downEvt
			,
		(moveEvt) ->
			if this.clickDiff
				this.sliderMoveTo(this.clickDiff + (this.sliderKnob().container().localPointFor(moveEvt.position)))
				moveEvt
			else
				undefined
			,
		null)

	this.sliderValueRequest = this.eventStream()
	this.sliderValue2D = $$(mergeE(!!!!@sliderValueRequest, @bounds.topLeft()).mapE((x) ->
		if x == true			// it's a value request
			@container.sliderMoveToRatio(@sliderValueRequest)
			@sliderValueRequest
		else
			// ask for the topLeft again, because we might have been delayed
			if @container then @container.newSliderValue(@bounds.topLeft()) else undefined))
	this.sliderValue = $$(@sliderValue2D.y())
	this.sliderValue.set(0)
	return this! !

!KSBox methodsFor: 'handlers' stamp: 'ael 3/27/2013 20:16'!
attachGriddedMoveHandler = (gridSize) ->
	this.gridSize = gridSize
	this.attachDownMoveUpHandlers(
		null,
		(moveEvt) ->
			var gridded = ((@container.localPointFor(moveEvt.position)) / @gridSize).asIntegerPoint() * @gridSize
			this.center(gridded),
		null)! !

!KSBox methodsFor: 'handlers' stamp: 'yo 10/9/2012 19:01'!
attachPickUpHandler = () ->
	this.doButtonDown = $$(@buttonDown.mapE((ev) ->
		ev.hand.attachBox(this)))
	this.listen(["buttonDown"])! !

!KSBox methodsFor: 'handlers' stamp: 'ael 4/1/2013 19:57'!
beColorPicker = () ->
	// Transcript.cr().show(this.ksCurrentTime())
	this.setupColorPicker()

	// resets are handled through a request stream, and can be postponed by a tick by sending setPropagatingLater(...)
	this.resetRequest = this.eventStream()
	this.reset = $$(@resetRequest.mapE((color) -> this.resetColorPicker(color)))

	this.followPicker = $$(@color.mapE((x) -> @updater._value_value(@target, x)))
	this.dismissPicker = $$(@fire.doE(() ->
		this.worldState().addFillToSamples(@color.asGeziraFill())
		var top = this.__topContainer__
		if top.hasOwnProperty("spareColorPicker")
			this.delete()		// we don't keep two spares
		else
			top.spareColorPicker = this
			this.visible.set(false)))

	// make a stream of colors that produces a new value when any of the three sliders changes - but try to wait until all have changed in a given cycle
	this.hueValue = $$(@hue.sliderValue)
	this.alphaValue = $$(@alpha.sliderValue)
	this.svValue2D = $$(@sv.sliderValue2D)
	this.color = $$(mergeE(@hueValue, @alphaValue, @svValue2D).doE(() -> Color._h_s_v(@hue.sliderValue * 360, @sv.sliderValue2D.x(), 1.0 - @sv.sliderValue2D.y()).alpha(@alpha.sliderValue)))	// use remote streams because local ones aren't in fact guaranteed to have been updated

	// and streams to change the alpha and s,v displays to suit the current selections
	this.update = $$(@color.mapE((c) -> this.alphaHatchFor(c.alpha(1.0))))
	this.updateSV = $$(@hueValue.mapE((h) -> this.calculateShadeForHue(h*360)))

	this.watchSwatches = $$(switchColE(@swatchHolder.contents, "fire").mapE((evt) -> this.resetColorPicker(evt.handler.fill().asColor())))

	this.watchSwatchFire = $$(switchColE(@swatchHolder.contents, "doubleClick").doE(() -> this.button.fireRequest.set(true)))! !

!KSBox methodsFor: 'handlers' stamp: 'yo 2/27/2013 23:05'!
beDraggerFor = (box) ->
	this.moveTarget = box
	this.attachDownMoveUpHandlers(
		(downEvt) ->
			this.clickPoint = @moveTarget.localPointFor(downEvt.position), 
		(moveEvt) ->
			var diff = @moveTarget.localPointFor(moveEvt.position) - this.clickPoint
			@moveTarget.translateBy(diff),
		null)! !

!KSBox methodsFor: 'handlers' stamp: 'yo 10/11/2012 10:15'!
beFillInTheBlank = () ->
	this.okButton.attachButtonHandler()
	this.cancelButton.attachButtonHandler()
	this.fieldBox.beLineEditor()
	this.fire = $$(@okButton.fire.doE(() ->
		this.delete()
		{box: this, result: @fieldBox.textContents()}))
	this.cancelPressed = $$(@cancelButton.fire.doE(() -> this.delete()))! !

!KSBox methodsFor: 'handlers' stamp: 'yo 1/30/2013 15:11'!
beFlippingButton = (headShape, tailShape, showHead, duration) ->
	this.beTransitiveButton(showHead, duration)
	this.headShape = headShape
	this.tailShape = tailShape
	this.shape(if @selected then @headShape else @tailShape)

	this.flip = $$(@fire.doE(() -> this.startFlipping()))

	this.flipStep = $$(@transitionTimer.mapE((t) ->
		if t < (@transitionDuration / 2.0)
			this.shape(@shapeFrom)
			var s = 1.0 - t / (@transitionDuration / 2.0)
		else
			this.shape(@shapeTo)
			var s = (t - (@transitionDuration / 2.0)) / (@transitionDuration / 2.0)
		if !!(s ~= 0.0)
			var center = this.center()
			this.scale(P(s, 1))
			this.center(center)))! !

!KSBox methodsFor: 'handlers' stamp: 'yo 4/11/2013 19:58'!
beListItemHandler = (defaultFill, enteredFill, pressedFill, selectedFill) ->
	this.attachButtonHandler()
	this.defaultFill = defaultFill
	this.enteredFill = enteredFill
	this.selectedFill = selectedFill
	this.pressedFill = pressedFill
	// to help the sorter, derive a local stream for the container's itemSelected
	this.selectionChange = $$(@container.itemSelected)
	this.selected = $$(@selectionChange.mapE((x) -> x.handler === this))
	this.isListItem = true
	this.highlightEnabled = $$(@isListItem && !!@selected).startsWith(true)
	return this! !

!KSBox methodsFor: 'handlers' stamp: 'yo 8/29/2012 13:40'!
beRotationHandler = (targetArg) ->
	this.target = targetArg
	this.attachDownMoveUpHandlers(
		(downEvt) ->
			var target = @target
			if target
				this.clickPosition = this.localPointFor(downEvt.position)
				if target == this
					this.origDiff = P(0, 0)
					this.origAngle = (this.clickPosition - target.pivotOffset()).theta()
				else
					this.origDiff = target.localPointFor(this.container().globalPointFor(this.pivotPosition())) - target.pivotOffset()
					this.origAngle = this.origDiff.theta(),
		(moveEvt) ->
			var target = @target
			var diff = target.localPointFor(moveEvt.position) - target.pivotOffset()
			var rot = diff.theta() - this.origAngle
			var current = target.rotation()
			if this.low
				if current + rot < this.low
					rot = this.low - current
			if this.high
				if current + rot >= this.high
					rot = this.high - current
			var newRot = current + rot
			var pi = Float.pi()
			var t = pi / 45
			for stop in [0.0, pi * 0.5, pi, pi * 1.5, pi * 2.0]
				if (newRot - stop).abs() < t
					rot = stop - current
			target.rotateByAround(rot, target.pivotRatio())
			if target == this
				this.pivotPosition(target.globalPointFor(this.origDiff) + target.pivotOffset()),
		null)! !

!KSBox methodsFor: 'handlers' stamp: 'yo 8/29/2012 14:27'!
beScaleHandler = (targetArg) ->
	this.target = targetArg
	this.attachDownMoveUpHandlers(
		(downEvt) ->
			var target = @target
			if target
				this.origTransformation = @target.transformation
				this.clickScale = this.origTransformation.invertPoint(target.container().localPointFor(downEvt.position)) / target.scale2D(),
		(moveEvt) ->
			var target = @target
			var now = this.origTransformation.invertPoint(target.container().localPointFor(moveEvt.position)) / this.clickScale
			target.scale(now),
		null)! !

!KSBox methodsFor: 'handlers' stamp: 'yo 1/31/2013 11:19'!
beSliderKnob = (initPoint) ->
	this.initPoint = initPoint
	this.max = $$(@extent.collectE(@initPoint, (newExt, oldExt) ->
		var possibleExt = newExt - this.bounds().extent()
		var curMax = this.container().sliderMinMax().max
		P(
			if curMax._x() == 0 then 0 else possibleExt.x(),
			if curMax._y() == 0 then 0 else possibleExt.y())))! !

!KSBox methodsFor: 'handlers' stamp: 'ael 3/27/2013 16:02'!
beToggleButtonHandler = (initialState) ->
	this.attachButtonHandler()
	this.selected = $$(@fire.doE(() -> !!@selected')).startsWith(initialState)
	this.highlightEnabled.set(false)! !

!KSBox methodsFor: 'handlers' stamp: 'yo 1/24/2013 16:35'!
beTransitiveButton = (isSelected, duration) ->
	this.attachButtonHandler()
	delete this.looks
	this.highlightEnabled.set(false)
	this.transitionDuration = this.streamOf(duration ? 1000)
	this.selected.set(isSelected ? false)

	this.mayFire = this.fire
	this.fire = $$(@mayFire.mapE((ev) ->
		if !!@transiting then ev else undefined))

	this.transiting = $$(this.transitionTimer && @transitionTimer < @transitionDuration).startsWith(false)! !

!KSBox methodsFor: 'handlers' stamp: 'ael 3/28/2013 11:50'!
resetColorPicker = (aColor) ->
	this.hue.setSliderCurrentValue(aColor.hue() / 360.0)
	this.alpha.setSliderCurrentValue(aColor.alpha())
	this.sv.setSliderCurrentValue(P(aColor.saturation(), (1.0- aColor.brightness())))! !

!KSBox methodsFor: 'handlers' stamp: 'yo 1/22/2013 00:43'!
stackHandler  = () ->
	// If this box has a handler that makes it a stack, return that
	if this.handler.isKindOf(KSStack)
		return this.handler
	if @container
		return @container.stackHandler()
	return nil! !

!KSBox methodsFor: 'handlers' stamp: 'yo 1/24/2013 16:59'!
startFlipping = () ->
	if @selected
		this.shapeFrom = @headShape
		this.shapeTo = @tailShape
	else
		this.shapeFrom = @tailShape
		this.shapeTo = @headShape
	this.startTransiting()! !

!KSBox methodsFor: 'handlers' stamp: 'yo 9/4/2012 14:20'!
startTransiting = () ->
	this.selected = !!@selected
	this.transitionTimer = $$(timerEDuration(20, @transitionDuration))! !

!KSBox methodsFor: 'initialization' stamp: 'ael 3/14/2013 15:25'!
initChangesSlots = () ->
	this.boxDeleted = $$(@container.collectE(nil, (newContainer, oldContainer) ->
		if !!newContainer && oldContainer then {old: oldContainer, box: this} else undefined))! !

!KSBox methodsFor: 'initialization' stamp: 'yo 1/7/2013 16:32'!
initGlues = (aNumber) ->
	this.glueShrink = this.streamOf(0)
	this.glueStretch = this.streamOf(0)
	this.glueLength = this.streamOf(aNumber)! !

!KSBox methodsFor: 'initialization' stamp: 'yo 8/29/2013 15:59'!
initialize = () ->
	super.initialize()
	this.container = this.streamOf(nil)
	this.contents = KSContentsCollection.new()
	this.parts = KSContentsCollection.new()
	this.backgroundParts = KSContentsCollection.new()
	this.transformation = this.streamOf(MatrixTransform2x3.identity())
	this.pivotRatio = this.streamOf(P(0.5, 0.5))
//	these three are indeed "virtual fields"
	this.extent = this.streamOf(P(50, 40))
	this.desiredExtent = this.streamOf(undefined)
	this.bounds = this.streamOf(P(0, 0).corner(P(50, 40)))
	this.shape = this.streamOf(KSShape._extent_fill(@extent, Color.random().alpha(0.7)))
	this.layout = this.streamOf(nil)
	this.layoutChanged = this.eventStream()
	this.layoutChanged.set({})
	this.visible = this.streamOf(true)
	this.clipping = this.streamOf(false)
	this.name = this.streamOf(undefined)
	this.optimizedGlyph = false
	this.optimizedField = false
	this.initChangesSlots()

	// now reserved for boxes that are sent beCharacter()
	// this.unicode = this.streamOf(0)
	// this.font = this.streamOf(undefined)

	return this! !

!KSBox methodsFor: 'layout' stamp: 'ael 3/5/2013 16:10'!
basicFullDrawingBounds = () ->
	var r = []
	this.wholeContentsDo((t) ->
		r.push(t.basicFullDrawingBounds()))
	return Rectangle.merging(r)! !

!KSBox methodsFor: 'layout' stamp: 'yo 8/15/2013 12:51'!
doLayout = () ->
	if @layout
		if !!@layout.layoutChildrenFirst()
			@layout.layOut(this)

	var boundRects = []
	this.wholeContentsDo((t) ->
		if !!(t.isHand && t.isEmpty()) && (t.layoutChanged.currentValue())
			t.doLayout()
			t.ksAssign(#"layoutChanged", nil))

	if @layout
		if @layout.layoutChildrenFirst()
			@layout.layOut(this)! !

!KSBox methodsFor: 'layout' stamp: 'yo 1/8/2013 15:30'!
drawingBounds = () ->
	return @shape.drawingBounds()! !

!KSBox methodsFor: 'layout' stamp: 'yo 7/19/2012 14:15'!
invalidRect = (aRectangle) ->
	return this! !

!KSBox methodsFor: 'layout' stamp: 'yo 7/19/2012 14:15'!
invalidRectInContainer = (aRectangle) ->
	return this! !

!KSBox methodsFor: 'layout' stamp: 'yo 1/8/2013 11:39'!
layOut = () ->
	if @layout
		 @layout.layOut(this)! !

!KSBox methodsFor: 'layout' stamp: 'yo 1/30/2013 10:52'!
layout = (layout) ->
	this.layout.set(layout)
	if layout
		layout.whole = this
	this.layoutChanged()! !

!KSBox methodsFor: 'layout' stamp: 'yo 7/26/2012 15:24'!
layoutChanged = () ->
	this.layoutChangedFrom(this)! !

!KSBox methodsFor: 'layout' stamp: 'yo 9/3/2013 15:04'!
layoutChangedFrom = (aBox) ->
	var oldV = @layoutChanged
	if !!oldV
		this.ksAssign(#"layoutChanged", {event: "layoutChanged", box: aBox, via: this})
		if @container && !!(@container.isWindow && @container.halo == this)
			@container.layoutChangedFrom(aBox)! !

!KSBox methodsFor: 'layout' stamp: 'yo 1/8/2013 15:30'!
lengthIn = (symbol) ->
	return @glueLength ? this[symbol].currentValue()! !

!KSBox methodsFor: 'layout' stamp: 'yo 7/19/2012 14:37'!
setBounds = (aRectangle) ->
	if @bounds == aRectangle
		return this
	var tr = @transformation
	//I think thre is a better way to handle it when it the box is rotated.  (Right now, if you rotate a box and then say (aBox bounds: aRectangle) = aRectangle, the result is false).
	var oldBox = @bounds
	if oldBox.extent() == P(0, 0) || tr.isPureTranslation()
		this.extent.set(aRectangle.extent())
		this.topLeft.set(aRectangle.origin())
		return this
	var extentPoint = aRectangle.extent()
	var l = P(0, 0).extent(@extent)
	var o = this.pointInContainer(l.origin())
	var c = this.pointInContainer(l.corner())
	try
		var relOrigin = (o - oldBox.origin()) / oldBox.extent()
		var relCorner = (c - oldBox.origin()) / oldBox.extent()
	catch ex
		ex.resume(ex.dividend())
	// map origin and corner into the new extent
	o = oldBox.origin() + (relOrigin * extentPoint)
	c = oldBox.origin() + (relCorner * extentPoint)
	o = tr.invertPoint(o)
	c = tr.invertPoint(c)
	this.extent.set(c - o)
	this.topLeft(aRectangle.origin())! !

!KSBox methodsFor: 'layout' stamp: 'yo 1/8/2013 13:44'!
wholeContentsDo = (aFunction) ->
	for b in this.parts
		aFunction(b)
	for b in this.contents
		aFunction(b)
	for b in this.backgroundParts
		aFunction(b)! !

!KSBox methodsFor: 'layout' stamp: 'yo 1/8/2013 15:30'!
wholeContentsSize = () ->
	return this.parts.size() + this.contents.size() + this.backgroundParts.size()! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 10/10/2012 10:17'!
acceptDrops = (evt) ->
	this.attachDropAcceptor()! !

!KSBox methodsFor: 'menu actions' stamp: 'ael 1/20/2013 23:51'!
beActionListHandler = (items) ->
	// like beMenuHandler, but without the assumption that the action list includes selectors.
	// Instead, each non-empty item is given an index number that the client of this list can use to decide what to do.
	// Each item is specified as a tuple: { < string or #- >.  <icon> (optional) }
	this.layout(KSVerticalLayout.new())
	this.layout().inset(3)
	this.name("list")

	this.setItems = (actionList) ->
		var font = KSFamily.withName("DejaVuSans").withStyle(0).withSize(12)
		var col = []
		var index = 0
		this.itemIndices = {}
		var b
		this.removeAll()
		for action in actionList
			if action[0] == "-".asSymbol()
				b = KSBox._extent_fill(P(50, 8), Color.transparent())
				this.itemIndices[b] = -1
			else
				b = this.factory()._newLabel_font_fill(action[0], font, Color.black())
				this.itemIndices[b] = index
				index = index + 1
				if action.size() > 1
					var icon = action[1]
					icon.scale(12.0/icon.extent().y())
					b.layout().inset(P(2,0))
					b.addFirst(icon)
			col.push(b.beListItemHandler(
				Color.transparent(), Color.gray(0.8), Color.gray(0.7), Color.gray(0.7)))
			this.add(b)
		this.items = col

	this.setItems(items)
	this.selectedItemIndex = $$(switchColE(@items, "fire").mapE((ev) ->
		this.itemIndices[ev.item]))

	this.listChangeRequest = this.eventStream()
	this.listChangeRequested = $$(@listChangeRequest.mapE((col) ->
		this.setItems(col)))

	this.listen(["buttonUp", "buttonDown"])
	this.handleControlKey(false)! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 10/10/2012 14:21'!
beListHandler = (evt) ->
	this.beMenuHandler(true, [])! !

!KSBox methodsFor: 'menu actions' stamp: 'ael 3/13/2013 23:52'!
beMenuHandler = (stayUp, actions) ->
	// actions is a collection of tuples [ selector or annotation,  text or box, (optional) icon ]
	this.stayUp = this.streamOf(!!!!stayUp)
	this.layout(KSVerticalLayout.new())
	this.layout().inset(3)
	this.name("menu")
	this.makeItem = (action) ->
		if action == "-"
			var b = KSBox._extent_fill(P(50, 8), Color.transparent())
		else
			b = action[1].menuLabelFor(this)
			if action.size() > 2
				b.layout().inset(P(2,0))
				b.addFirst(action[2])
			b.actionID = action[0]
			b.beListItemHandler(
				b.fill(),
				this.factory().theme.enteredFill ? Color.gray(0.8),
				this.factory().theme.pressedFill ? Color.gray(0.7),
				this.factory().theme.selectedFill ? Color.gray(0.7))
		b

	this.setItems = (actionList) ->
		this.removeAll()
		for action in actionList
			this.add(this.makeItem(action))
			this.layOut()
	this.setItems(actions)
	this.itemSelected = $$(switchColE(@contents, "fire"))
	this.doAction = $$(@itemSelected.mapE((ev) ->
		var menuAction = ev.handler.actionID
		if menuAction
			var ed = @actionTarget.__docEditor__
			if !!ed then ed = @actionTarget.whole.__docEditor__
			if ed
				ed.triggerMenuCommand(@actionTarget, menuAction, [ev])
			else
				@actionTarget.ksMenuPerform(menuAction, [ev])))
	this.dismiss = $$((mergeE(@itemSelected, @buttonUp) && !!@stayUp).mapE((x) ->
		if x then this.delete() else undefined))

	this.listChangeRequest = this.eventStream()
	this.listChangeRequested = $$(@listChangeRequest.mapE((col) ->
		this.setItems(col)))

	this.listen(["buttonUp", "buttonDown"])
	this.handleControlKey(false)! !

!KSBox methodsFor: 'menu actions' stamp: 'ael 3/14/2013 15:55'!
beSelectableListHandler = () ->
	// like beMenuHandler, but the first place in each item tuple is treated as an annotation to be added to the menu-item box as an actionID property, and therefore accessible as event.handler.actionID
	this.beMenuHandler(true, [])
	this.name("list")
	this.layout().inset(P(3,3).corner(P(3,20)))
	// redefine what happens on selection.  itemSelected is available as a stream of events
	delete this.doAction! !

!KSBox methodsFor: 'menu actions' stamp: 'ael 4/1/2013 17:33'!
chooseColor = (evt) ->
	this.topContainer().invokeColorPicker(this.topRight() + P(10, 0), this.fill().asColor(), this, (target, color) -> target.fill(color))! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 2/1/2013 13:13'!
copyFromHalo = (target, evt) ->
	var newBox = target.userCopy(evt)
	if evt && evt.root
		evt.root.haloTarget.set(newBox)! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 1/17/2013 20:42'!
createMenu = (actions, receiver) ->
	//Put up the menu from the list of actions."
	var menu = this.factory().newMenu()
	menu.actionTarget = receiver ? menu
	menu.setItems(actions)
	menu.width(100)
	return menu! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 2/27/2013 11:02'!
customizeMenu
	^ 	#(	(attachButtonHandler		'be a button')
			(addSliderHandler			'be a slider')
			(beListHandler				'be a list')
			(beLineEditor				'be a line of text')
			(beTextField				'be a text field')
			(attachGenericMoveHandler 	'be movable'))! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 1/8/2013 15:46'!
debugMenu
	"Answer specs that define the generic LBox debugging-tools menu -- an array of (selector item-wording) pairs.   An item consisting of a simple #- signifies a 'line' in the menu.  The receiver of the selectors indicated will be the LBoxMenuHandler associated with the box.      self removeProperty: #menu  "

	^ self at: #debugMenu ifAbsent: [#(	
		(inspectInMorphic		'inspect box - morphic')
		(exploreInMorphic		'explore box - morphic')
		(ksInspectInMorphic	'ks inspect - morphic')
		(ksExploreInMorphic	'ks explore - morphic')
	)]! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 10/5/2012 15:42'!
deepCopy = () ->
	this.ppScanObjects().ppCreateObjects()! !

!KSBox methodsFor: 'menu actions' stamp: 'ael 3/17/2013 21:21'!
defaultMenu
	^ 	#(	(pickUp				'pick up')
			(deleteBox			'delete')
			(userCopy			'duplicate')
			(acceptDrops		'accept drops')
			(setName			'set name...')
			-
			(gradientEditor		'edit gradient')
			(scriptor			'edit script')
			(shapeEditor		'edit shape')
			(newBox			'new box')
			-
			(showCustomizeMenu		'be something...')
			-),
			(Array streamContents: [:strm |
				(self shape texture notNil)
					ifTrue: [strm nextPut: #(repaint  'repaint image')]])! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 10/8/2012 20:06'!
deleteBox = (evt) ->
	this.delete()! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 8/31/2012 18:32'!
exploreInMorphic = (evt) ->
	WorldState.addDeferredUIMessage(() -> this.explore())! !

!KSBox methodsFor: 'menu actions' stamp: 'ael 4/8/2013 15:51'!
gradientEditor = (evt) ->
	@__topContainer__.halo.addGradientEditor(@__topContainer__.haloTarget, null, (target, newFill) -> target.fill(newFill))! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 8/30/2012 21:58'!
inspectInMorphic = (evt) ->
	WorldState.addDeferredUIMessage(() -> this.inspect())! !

!KSBox methodsFor: 'menu actions' stamp: 'ael 1/8/2013 16:28'!
ksExploreInMorphic = (evt) ->
	WorldState.addDeferredUIMessage(() -> this.ksExplore())! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 8/31/2012 18:34'!
ksInspectInMorphic = (evt) ->
	WorldState.addDeferredUIMessage(() -> this.ksInspect())! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 1/9/2013 10:53'!
newBox = (ev) ->
	this.addFirst(KSBox.new())! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 1/9/2013 11:11'!
newMovableBox = (ev) ->
	var box = KSBox.new()
	box.attachGenericMoveHandler()
	this.addFirst(box)! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 10/10/2012 10:32'!
pickUp = (evt) ->
	this.attachPickUpHandler()! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 2/12/2013 15:59'!
scriptor = (evt) ->
	var box = KSBox.new()
	var handler = KSScriptor.new()
	handler.installTo(box)
	handler.build(this)
	this.topContainer().addFirst(box)
	box.topLeft(evt.position ? this.topRight())
	box.forceWithinContainer()
	return box! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 1/9/2013 10:13'!
setName = (evt) ->
	this.namer = this.factory().newFillInTheBlank("new name for this box?", this.name() ? "aBox")
	evt.event.root.addAsParts(this.namer)
	this.namer.center(evt.event.root.extent() / 2.0)
	this.nameChanger = $$(@namer.fire.mapE((result) ->
		this.name(result.result)
		//The following may be a hack to make a demo work.
		this.container.currentValue()[result.result] = this))! !

!KSBox methodsFor: 'menu actions' stamp: 'ael 4/1/2013 18:19'!
shapeEditor = (evt) ->
	var editor = KSBox.new()
	var handler = KSShapeEditor.new()
	handler.installTo(editor)
	handler.setup(this)
	this.topContainer().addFirst(editor)
	editor.topLeft((evt.position ? this.topRight()).rounded()+P(0.5, 0.5))
	editor.forceWithinContainer()! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 2/11/2013 10:17'!
showCustomizeMenu = (ev) ->
	KSBox._invokeMenu_near_for(this.createMenu(this.customizeMenu(), this), ev.position, this)! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 8/30/2012 10:41'!
showDebugMenu = (target, ev) ->
	KSBox._invokeMenu_near_for(target.createMenu(target.debugMenu(), target), ev.position, target)! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 10/8/2012 19:47'!
showDefaultMenu = (target, ev) ->
	KSBox._invokeMenu_near_for(target.createMenu(target.defaultMenu(), target), ev.position, target)! !

!KSBox methodsFor: 'menu actions' stamp: 'yo 2/1/2013 11:19'!
userCopy = (evt) ->
	var newBox = this.ppScanObjects().ppCreateObjects()
	this.container().addFirst(newBox)
	newBox.topLeft(this.topLeft() + P(15, 15))
	return newBox! !

!KSBox methodsFor: 'printing' stamp: 'ael 3/14/2013 15:35'!
printOn: aStream
	aStream
		nextPutAll: self class name;
		nextPutAll: '('.
	(self ksAt: #name) asBoolean ifTrue: [
		aStream
			nextPutAll: (self ksAt: #name) currentValue;
			nextPutAll: ', '].
	self unicode > 0 ifTrue: [
		aStream
			nextPut: $';
			nextPutAll: (GlyphNames at: self unicode + 1);
			nextPutAll: ''', '].

	aStream
		nextPutAll: (self topLeft x printShowingMaxDecimalPlaces: 1);
		nextPut: $@;
		nextPutAll: (self topLeft y printShowingMaxDecimalPlaces: 1);
		nextPutAll: ')'.! !

!KSBox methodsFor: 'services' stamp: 'yo 1/8/2013 15:41'!
atName = (aString) ->
	for b in this.parts
		if b.name.currentValue() == aString
			return b
	for b in this.contents
		if b.name.currentValue() == aString
			return b
	for b in this.backgroundParts
		if b.name.currentValue() == aString
			return b
	return nil! !

!KSBox methodsFor: 'services' stamp: 'yo 9/10/2013 16:06'!
imageForm = () ->
	// Make Gezira render this box into a form at printer resolution and store as a .png file
	var scaleNum = 72.0 / 72.0
	var canv = GeziraCanvas.on(Form._extent_depth((@extent * scaleNum).asIntegerPoint(), 32))
	canv.transformBy(MatrixTransform2x3.withScale(scaleNum))
	this.drawOn(canv)
	return canv.instVarNamed("target")! !

!KSBox methodsFor: 'services' stamp: 'yo 2/21/2013 15:23'!
layerDescription = () ->
	// Create a string that tells if this box is in contents or parts.  What rank is it?  12th in contents.

	// Containment is meaningless if the box is top in an editor
	if @container.name() == "mainViewBox"
		return ""

	if !!@container
		return "not inside any other box"

	var where
	var nth = @container.contents.indexOf(self)
	if nth > 0
		where = "contents"
	else
		nth = @container.backgroundParts.indexOf(self)
		if nth > 0
			where = "background parts"
		else
			nth = @container.parts.indexOf(self)
			if nth > 0
				where = "foreground parts"
			else
				return "not inside any other box"

	if @__stackHandler__ && (p in @__stackHandler__.pageArray when p.background === this)
		var page = "Page ".concat(@__stackHandler__.pageIndex.asString()).concat(", ")
	return (page ? "").concat(nth.asString()).concat(nth.ordinalSuffix()).concat(" in ").concat(where)! !

!KSBox methodsFor: 'services' stamp: 'yo 1/8/2013 15:41'!
name = () ->
	return @name! !

!KSBox methodsFor: 'services' stamp: 'yo 7/20/2012 09:10'!
printToFile = (fName, theDPI) ->
	// Make Gezira render this box into a form at printer resolution and store as a .png file
	var scaleNum = theDPI / 72.0
	var canv = GeziraCanvas.on(Form._extent_depth((@extent * scaleNum).asIntegerPoint(), 32))
	canv.transformBy(MatrixTransform2x3.withScale(scaleNum))
	this.drawOn(canv)
	PNGReadWriter._putForm_onFileNamed(canv.instVarNamed("target"), fName)! !

!KSBox methodsFor: 'services' stamp: 'yo 7/20/2012 09:11'!
thumbnailScale: scaleNum
	"Create a box that has an image that is a small version of me.  Does not update."
	| f |
	f := self thumbnailScale: scaleNum centeredWithin: (self extent * scaleNum) asIntegerPoint transformedBy: MatrixTransform2x3 identity.
	^ (self class extent: f form extent fill: Color transparent) fill: f; yourself! !

!KSBox methodsFor: 'services' stamp: 'yo 1/17/2013 21:36'!
thumbnailScale: scaleNum centeredWithin: aPoint transformedBy: trans
	"Create a box that has an image that is a small version of me.  Does not update."
	| canv m off bb |
	canv := GeziraCanvas on: (Form extent: aPoint depth: 32).
	bb := self drawingBounds.
	m := trans composedWithLocal: (MatrixTransform2x3 withScale: scaleNum).
	off := (aPoint - (m transformPointNoRound: bb corner) + (m transformPointNoRound: bb origin)) / 2.0.
	m offset: off.
	canv transformBy: m.
	self drawOn: canv.
	^GeziraFillImage new setForm: (canv instVarNamed: 'target').! !

!KSBox methodsFor: 'shape' stamp: 'yo 2/8/2013 11:39'!
borderFill = (aFill) ->
	this.ensurePathsForShapeTransformer(() ->
		this.shape(@shape.borderFill(aFill)))
	return this! !

!KSBox methodsFor: 'shape' stamp: 'yo 2/8/2013 11:39'!
borderWidth = (aNumber) ->
	this.ensurePathsForShapeTransformer(() ->
		this.shape(@shape.borderWidth(aNumber)))
	return this! !

!KSBox methodsFor: 'shape' stamp: 'yo 8/29/2012 12:00'!
clipping = (aBoolean) ->
	this.clipping.set(aBoolean)
	this.layoutChanged()! !

!KSBox methodsFor: 'shape' stamp: 'yo 2/8/2013 11:39'!
cornerRadius = (aNumber) ->
	var c = this.cornerRadius()
	this.shape(@shape.cornerRadius(aNumber))
	if this.fractions && c !!= this.cornerRadius()
		delete this.paths
		this.cut(this.stretcherCut)
	return this! !

!KSBox methodsFor: 'shape' stamp: 'yo 1/25/2013 00:26'!
ensurePathsForShapeTransformer = (aFunction) ->
	var i = @shape.elements().size()
	aFunction.value()
	if this.fractions && i !!= @shape.elements().size()
		delete this.paths
		this.cut(this.stretcherCut)! !

!KSBox methodsFor: 'shape' stamp: 'yo 3/1/2013 21:22'!
extent = (aPoint) ->
	if !!aPoint.closeTo(@extent)
		this.shape(@shape.extent(aPoint))
		this.layoutChanged()
	if !!(aPoint.closeTo(@extent))
		this.desiredExtent.set(aPoint)! !

!KSBox methodsFor: 'shape' stamp: 'yo 10/10/2012 10:59'!
fill = (aFill) ->
	this.shape(@shape.fill(aFill))! !

!KSBox methodsFor: 'shape' stamp: 'yo 1/30/2013 14:44'!
leftAtY = (y) ->
	return @shape.leftAtY(y)! !

!KSBox methodsFor: 'shape' stamp: 'tk 1/30/2013 15:09'!
lineTop = () ->
	return this.pivotPosition().y() - this.ascent()! !

!KSBox methodsFor: 'shape' stamp: 'yo 1/30/2013 14:44'!
rightAtY = (y) ->
	return @shape.rightAtY(y)! !

!KSBox methodsFor: 'shape' stamp: 'yo 9/3/2013 15:03'!
shape = (anObject) ->
	this.ksAssign(#"shape", anObject)
	if !!anObject.extent().closeTo(@extent)
		this.extent.set(anObject.extent())
	this.ksAssign(#"bounds", this.computeBounds())
	this.setPivotForGlyph()
	this.layoutChanged()
	this.glReleaseCaches()! !

!KSBox methodsFor: 'shape' stamp: 'yo 2/21/2013 14:30'!
texture = () ->
	return this.shape().texture()! !

!KSBox methodsFor: 'shape editor' stamp: 'ael 3/27/2013 23:11'!
bePathMover = () ->
	this.tell = $$(@transformation.doE(() -> {indices: this.indices, center: this.center()}))
	this.entered = $$(mergeE(!!!!@pointerEnter, !!@pointerLeave)).startsWith(false)
	this.listen(["pointerLeave",  "pointerEnter",  "motionQuery", "keyStroke"])
	this.highlight = $$(@entered.mapE((e) -> {requester: this, highlight: e}))
	this.getFocus = $$(@entered.mapE((e) ->
		if @pointerEnter.hand
			@pointerEnter.hand.keyboardFocus(if e then this else nil)))
	this.highlighted = false! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 8/31/2012 13:53'!
adjustTransform: desiredExtent
	| scale transform |
	scale := desiredExtent / self originalExtent.
	transform := MatrixTransform2x3 withScale: scale.
	self shape: ((self at: #shape) currentValue
		transform: transform;
		computeBounds;
		extent: desiredExtent)! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 11/28/2012 11:32'!
attachShapeScaler = () ->
	this.shapeScaler = $$(@desiredExtent.mapE((ext) ->
		this.adjustTransform(ext)))! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 11/28/2012 11:32'!
attachShapeStretcher = (aPoint) ->
	this.cut(aPoint)
	this.shapeStretcher = $$(@desiredExtent.mapE((ext) ->
		this.shape(@shape.elements(this.stretchedPaths(ext)))))! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 8/29/2012 15:56'!
computeExtents
	| minX maxX minY maxY left right top bottom x y paths fractions |
	minX := maxX := minY := maxY := nil.
	left := right := top := bottom := nil.
	paths := self at: #paths.
	fractions := self at: #fractions.
	paths with: fractions do: [:path :fracts |
		1 to: path size by: 2 do: [:i |
			x := path floats at: i.
			minX := (minX ifNil: [x]) min: x.
			maxX := (maxX ifNil: [x]) max: x.
			(fracts at: i) < 0.5
				ifTrue: [left := (left ifNil: [x]) max: x]
				ifFalse: [right := (right ifNil: [x]) min: x]].
		2 to: path size by: 2 do: [:i |
			y := path floats at: i.
			minY := (minY ifNil: [y]) min: y.
			maxY := (maxY ifNil: [y]) max: y.
			(fracts at: i) < 0.5
				ifTrue: [top := (top ifNil: [y]) max: y]
				ifFalse: [bottom := (bottom ifNil: [y]) min: y]]].
	(minX@minY) isZero ifFalse: [
		self error: 'non-zero offset not implemented yet'].
	left ifNil: [left := 0].
	right ifNil: [right := maxX].
	top ifNil: [top := 0].
	bottom ifNil: [bottom := maxY].
	self at: #originalExtent put: maxX@maxY.
	self at: #minimalExtent put: (left + maxX - right)@(top + maxY - bottom)	! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 1/25/2013 00:14'!
cut: aPoint
	"Specify fractions by a 'cut location'. Fractions will be set to 0 or 1 depending on whether the vertex is left/right/above/below the cut."
	| cut |
	self at: #stretcherCut put: aPoint.
	cut := {aPoint x. aPoint y}.
	self at: #fractions put: (self paths collect: [:path |
		path floats withIndexCollect: [:each :i |
			each < (cut at: i - 1 \\ 2 + 1)
				ifTrue: [0]
				ifFalse: [1]]]).
	self computeExtents.! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 8/29/2012 15:55'!
initForScaling
	"Specify fractions to do proportional scaling."
	| ext |
	ext := {self extent x. self extent y}.
	self at: #fractions put: (self paths collect: [:path |
		path floats withIndexCollect: [:each :i |
			each / (ext at: i - 1 \\ 2 + 1)]]).
	self computeExtents.! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 8/29/2012 15:55'!
originalExtent
	^ self at: #originalExtent ifAbsentPut: [(self at: #shape) currentValue drawingBounds extent]! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 8/29/2012 15:54'!
paths
	^ self at: #paths ifAbsentPut: [(self at: #shape) currentValue elements]! !

!KSBox methodsFor: 'shape transformers' stamp: 'yo 8/31/2012 13:42'!
stretchedPaths: desiredExtent
	| newExtent delta fractions minimalExtent originalExtent paths new x y f |
	minimalExtent := self at: #minimalExtent.
	originalExtent := self at: #originalExtent.
	paths := self at: #paths.
	fractions := self at: #fractions.
	newExtent := desiredExtent max: minimalExtent.
	delta := newExtent - originalExtent.
	delta abs < (0.5 @ 0.5)
		ifTrue: [^ paths].
	^ paths
		with: fractions
		collect: [:path :fraction | 
			new := FloatArray new: path floats size.
			1 to: new size by: 2 do: [:i | 
				x := path floats at: i.
				f := fraction at: i.
				new at: i put: x + (f * delta x)].
			2 to: new size by: 2 do: [:i | 
				y := path floats at: i.
				f := fraction at: i.
				new at: i put: y + (f * delta y)].
			path clone floats: new]! !

!KSBox methodsFor: 'slider' stamp: 'ael 3/6/2013 20:53'!
beScrollerFor = (box, wantsHScroll, wantsVScroll, wantsWidthTracking) ->
	this.add(box)

	if !!wantsHScroll && !!wantsVScroll && !!wantsWidthTracking
		return this

	this.target = box
	var targetName = box.name()
	this.clipping(true)
	var layout = KSSimpleLayout.new()
	this.layout(layout)

	if wantsHScroll
		var slider = this.hSlider = box.factory().newSlider(P(10, 1))	// ensure we get a horizontal one
		slider.name("hSlider")
		this.addAsParts(slider)
		layout._keep_of_to(#"bottomLeft", "hSlider", #"bottomLeft")	
		layout._keep_of_to_offset(#"topRight", "hSlider", #"bottomRight", P(0, -10))

	if wantsVScroll
		slider = this.vSlider = box.factory().newSlider(P(1, 10))	// ensure we get a vertical one
		slider.name("vSlider")
		this.addAsParts(slider)
		layout._keep_of_to(#"topRight", "vSlider", #"topRight")	
		layout._keep_of_to_offset(#"bottomLeft", "vSlider", #"bottomRight", P(-10, 0))

	if wantsWidthTracking
		layout._keep_of_to(#"left", targetName, #"left")	
		layout._keep_of_to_of(#"right", targetName, #"left", "vSlider")
		this.adjustHeight = $$(@extent.mapE((ext) -> this.target.handler.minimumHeight.set(ext.y())))

	this.scroller = $$(mergeE(@hSlider.sliderValue, @vSlider.sliderValue).doE(() ->
		var desiredTop
		var desiredLeft
		if @hSlider
			var v = @hSlider.sliderValue
			if v < 0 || v > @hSlider.sliderMinMax().max
				this.hSlider.setSliderCurrentValue(P(0,0))
			else
				desiredLeft = (v.negated() * (@target.bounds().width() - (this.width()))).min(0)
		if @vSlider
			var v = @vSlider.sliderValue
			if v < 0 || v > @vSlider.sliderMinMax().max
				this.vSlider.setSliderCurrentValue(P(0,0))
			else
				desiredTop = (v.negated() * (@target.bounds().height() - (this.height()))).min(0)
		@target.topLeft(P(desiredLeft ? 0, desiredTop ? 0))))

	this.scrollAdjuster = $$(mergeE(@layoutChanged,@target.layoutChanged).doE(() ->
		if @hSlider
			var visibleWidth = @extent.x()
			var ratio = (visibleWidth / (@target.bounds().width())).min(1.0)
			this.hSlider.visible.set((1-ratio)*visibleWidth > 5)
			this.hSlider.knobFraction.set(ratio)
		if @vSlider
			var visibleHeight = @extent.y()
			var ratio = (visibleHeight / (@target.bounds().height())).min(1.0)
			this.vSlider.visible.set((1-ratio)*visibleHeight > 5)
			this.vSlider.knobFraction.set(ratio)))

	if wantsVScroll
		this.scrollIntoView = (item) ->
			var rect = item.bounds().outsetBy(P(0, 3))
			var thisHeight = this.height()
			var targetHeight = @target.bounds().height()	// NB: bounds() to get container's coords
			if thisHeight >= targetHeight
				return this						// whole list should already be in view
			var currentValueY = @slider.sliderValue
			var scrollRange = targetHeight - thisHeight
			// minimum satisfactory slider value is when bottom of item is aligned with bottom of view
			var minSliderY = ((@target.pointInContainer(rect.bottomRight()).y() - thisHeight) / scrollRange).max(0)
			if currentValueY < minSliderY
				this.slider.setSliderCurrentValue(P(0, minSliderY))
			else
				// max is when top of item is aligned with top of view
				var maxSliderY = (@target.pointInContainer(rect.topLeft()).y() / scrollRange).min(1.0)
				if currentValueY > maxSliderY
					this.slider.setSliderCurrentValue(P(0, maxSliderY))

	return this! !

!KSBox methodsFor: 'slider' stamp: 'ael 1/31/2013 17:01'!
beVScrollerFor = (box) ->
	this.add(box)
	this.target = box

	var slider = this.slider = box.factory().newSlider(P(1,10))	// ensure we get a vertical one
	slider.name("slider")
	this.addAsParts(slider)
	this.clipping(true)

	var layout = KSSimpleLayout.new()
	layout._keep_of_to(#"topRight", "slider", #"topRight")	
	layout._keep_of_to_offset(#"bottomLeft", "slider", #"bottomRight", P(-10,0))
	this.layout(layout)

	this.scroller = $$(@slider.sliderValue.mapE((v) ->
		if v < 0 || v > @slider.sliderMinMax().max
			this.slider.setSliderCurrentValue(P(0,0))
		else
			var top = (v.negated() * (@target.bounds().height() - (this.height()))).min(0)
			@target.topLeft(P(0, top))))

	this.scrollAdjuster = $$(mergeE(@extent,@target.bounds).doE(() ->
		var visibleHeight = @extent.y()
		var ratio = (visibleHeight / (@target.bounds().height())).min(1.0)
		this.slider.knobFraction.set(ratio)))

	this.scrollIntoView = (item) ->
		var rect = item.bounds().outsetBy(P(0, 3))
		var thisHeight = this.height()
		var targetHeight = @target.bounds().height()	// NB: bounds() to get container's coords
		if thisHeight >= targetHeight
			return this						// whole list should already be in view
		var currentValueY = @slider.sliderValue
		var scrollRange = targetHeight - thisHeight
		// minimum satisfactory slider value is when bottom of item is aligned with bottom of view
		var minSliderY = ((@target.pointInContainer(rect.bottomRight()).y() - thisHeight) / scrollRange).max(0)
		if currentValueY < minSliderY
			this.slider.setSliderCurrentValue(P(0, minSliderY))
		else
			// max is when top of item is aligned with top of view
			var maxSliderY = (@target.pointInContainer(rect.topLeft()).y() / scrollRange).min(1.0)
			if currentValueY > maxSliderY
				this.slider.setSliderCurrentValue(P(0, maxSliderY))

	return this! !

!KSBox methodsFor: 'slider' stamp: 'yo 2/26/2013 19:20'!
beVTextScrollerFor = (aTextField) ->
	this.beVScrollerFor(aTextField)
	var layout = this.layout()
	layout._keep_of_to(#"left", aTextField.name(), #"left")	
	layout._keep_of_to_of(#"right", aTextField.name(), #"left", "slider")
	this.adjustHeight = $$(@extent.mapE((ext) ->
		this.target.handler.minimumHeight.set(ext.y())))
	return this! !

!KSBox methodsFor: 'slider' stamp: 'ael 3/28/2013 12:07'!
newSliderValue = (knobPos) ->
	// convert a slider knob position to a ratio
	var minmax = this.sliderMinMax()
	var cmin = minmax.min
	var cmax = minmax.max
	var total = minmax.max - minmax.min
	if total.x() == 0.0
		total = P(1, total.y())
	if total.y() == 0.0
		total = P(total.x(), 1)
	return (knobPos - cmin) / total! !

!KSBox methodsFor: 'slider' stamp: 'ael 3/28/2013 12:17'!
setSliderCurrentValue = (aNumberOrPoint) ->
	var p = if aNumberOrPoint instanceof Point then aNumberOrPoint else P(0, aNumberOrPoint)
	this.sliderKnob().sliderValueRequest.setPropagatingLater(p)! !

!KSBox methodsFor: 'slider' stamp: 'yo 7/27/2012 13:47'!
sliderKnob = () ->
	return @sliderTarget ? this! !

!KSBox methodsFor: 'slider' stamp: 'yo 8/23/2012 13:49'!
sliderMinMax = () ->
	var m = if @slider then @slider.sliderMinMax() else {min: @min, max: @max}
	var cmin = if m.min then m.min else P(0, 0)
	if m.max
		var cmax = m.max
	else
		if this.sliderKnob().container()
			cmax = this.sliderKnob().container().extent() - this.sliderKnob().bounds().extent()
		else
			cmax = this.sliderKnob().bounds().extent()
	return {min: cmin, max: cmax}! !

!KSBox methodsFor: 'slider' stamp: 'ael 3/28/2013 12:10'!
sliderMoveTo = (newPos) ->
	// move slider knob to the requested position, constrained by min and max
	var minmax = this.sliderMinMax()
	var cmin = minmax.min
	var cmax = minmax.max
	var pos = newPos.max(cmin).min(cmax)
	var knob = this.sliderKnob()
	if !!(knob.topLeft() ~= pos)
		knob.topLeft(pos)! !

!KSBox methodsFor: 'slider' stamp: 'ael 3/28/2013 12:11'!
sliderMoveToRatio = (aNumberOrPoint) ->
	// convert a ratio to the appropriate slider knob position
	var minmax = this.sliderMinMax()
	var cmin = minmax.min
	var cmax = minmax.max
	this.sliderMoveTo(aNumberOrPoint * (cmax - cmin) + cmin)! !

!KSBox methodsFor: 'slider' stamp: 'yo 8/23/2012 20:48'!
sliderMoveToWithin = (aPoint, cmin, cmax) ->
	var newPos = aPoint
	if cmin
		newPos = newPos.max(cmin)
	if cmax
		newPos = newPos.min(cmax)
	this.sliderKnob().topLeft(newPos)! !

!KSBox methodsFor: 'slider' stamp: 'yo 7/27/2012 13:43'!
sliderValue = (newPos) ->
	var minmax = this.sliderMinMax()
	var cmin = minmax.min
	var cmax = minmax.max
	var total = minmax.max - minmax.min
	if total.x() == 0.0
		total = P(1, total.y())
	if total.y() == 0.0
		total = P(total.x(), 1)
	return (newPos - cmin) / total! !

!KSBox methodsFor: 'squeak interface' stamp: 'ael 2/4/2013 21:51'!
ksAt: key 
	key == #'__topContainer__' ifTrue: [^ self topContainer].
	key == #'__stackHandler__' ifTrue: [^ self stackHandler].
	key == #'__docEditor__' ifTrue: [^ self docEditor].
	^ super ksAt: key! !

!KSBox methodsFor: 'squeak interface' stamp: 'yo 9/10/2013 17:54'!
ksAt: key put: anObject
	"Okay, there are a few people who seem to think that adding some comments to this method helps.  The idea of 'priority' in sorting event streams has to be described somewhere else, but this complicated case for isEventStream tries to put streams that represent raw user events, that depend on the raw user events, and that depend on the layout into different bins in the sorter.

When putting into bins is done, it calls #clearSortedBubbles.  Which clears the cache of sorted streams."
	anObject isEventStream ifTrue: [
		| keys max |
		anObject name: key.
		keys := anObject sources collect: [:e | EventNameMap at: e ref ifAbsent: [0]].
		(keys size > 0 and: [(max := keys max) = 0]) ifTrue: [
			(self at: #'__direct__' ifAbsentPut: [KSObject new]) at: anObject put: max].

		(EventNameMap includesKey: key asKSKey) ifTrue: [
				(self at: #'__rawEvents__' ifAbsentPut: [KSObject new]) at: key put: anObject].

		anObject isLayoutChangedDependents ifTrue: [
			(self at: #'__layoutDep__' ifAbsentPut: [KSObject new]) at: anObject put: anObject].

		(self worldState asBoolean and: [self optimizedField not]) ifTrue: [
			self worldState clearSortedBubbles]].
	anObject isBox ifTrue: [
		self worldState asBoolean ifTrue: [
			self worldState clearSortedBubbles]].
	^ super ksAt: key put: anObject! !

!KSBox methodsFor: 'text editor' stamp: 'yo 3/11/2013 13:25'!
beLabel = () ->
	if !!(this.layout() instanceof KSTextLayout)
		KSTextLayout.new().installTo(this)
	this.layout().beSingleLineInput(true)
	this.layout().beReadOnly(true)
	this.layout().horizontalShrink = true! !

!KSBox methodsFor: 'text editor' stamp: 'yo 2/27/2013 20:50'!
beLineEditor = () ->
	if !!(this.layout() instanceof KSTextLayout)
		KSTextLayout.new().installTo(this)
	this.layout().beSingleLineInput(true)
	this.layout().beReadOnly(false)! !

!KSBox methodsFor: 'text editor' stamp: 'tk 2/27/2013 14:42'!
beTextField = () ->
	if !!(this.layout() instanceof KSTextLayout)
		KSTextLayout.new().installTo(this)
	this.layout().beSingleLineInput(false)! !

!KSBox methodsFor: 'text editor' stamp: 'tk 2/27/2013 15:03'!
fontNearest = (index) ->
	// Find the font of the current glyph, or the nearest one preceeding it that has a font
	for i in [(index.max(0).min(@contents.size())) ... 1] by -1
		if @contents._at(i).font
			return @contents._at(i).font.currentValue()
	if @layout.font
		return @layout.font
	return KSFont.defaultFont()! !

!KSBox methodsFor: 'text editor' stamp: 'yo 10/5/2012 23:47'!
insertChar = (char) ->
	// General way to insert a character.
	this.addAfterIndex(KSBox._withChar_inFont(char, this.fontNearest(@contents.size())), @contents.size()-1)! !

!KSBox methodsFor: 'text editor' stamp: 'tk 2/27/2013 15:11'!
reLabel = (label, aFill, aNumber, font, justification) ->
	//reLabel: label textFill: aFill width: aNumber font: font justification: justification
	this.removeAll()
	if !!(@layout.isMemberOf(KSTextLayout))
		KSTextLayout.new().installTo(this)
		this.layout().font = font
		this.layout().inset(P(0, 0))
		this.layout().horizontalShrink = true
		this.layout().verticalShrink = true
		this.layout().noWrap = true
		this.layout().beReadOnly(true)
	var f = font.fill(aFill)
	this.layout().addAll(label)
//	if aNumber
//		box.layout().
	this.layout().justification = justification
	this.layOut()
	this.blockHaloForContents()
	return this! !

!KSBox methodsFor: 'time bubbles' stamp: 'yo 1/8/2013 13:38'!
isBox = () ->
	return true! !

!KSBox methodsFor: 'time bubbles' stamp: 'yo 1/7/2013 19:06'!
isTimeBubble = () ->
	return @isTimeBubble.asBoolean()! !

!KSBox methodsFor: 'time bubbles' stamp: 'yo 1/8/2013 13:38'!
setTimeBubble = (aBoolean) ->
	this.isTimeBubble = this.streamOf(aBoolean)! !

!KSBox methodsFor: 'time bubbles' stamp: 'yo 7/19/2012 11:05'!
timeBubblesInto = (aRecord, top) ->
	if this.isTimeBubble && top !!== this
		aRecord[1].push(this)
	else
		aRecord[0].push(this)
		for col in [this.parts, this.contents, this.backgroundParts]
			for e in col
				e.timeBubblesInto(aRecord, top)! !

!KSBox methodsFor: 'tree hierarchy' stamp: 'yo 3/20/2013 12:30'!
docEditor = () ->
	// If this box is in a window containing a document editor, return the KSDocEditor handler
	var cc = this
	while cc
		if cc.handler.isMemberOf(KSDocEditor)
			return cc.handler
		cc = cc.container()
	return nil! !

!KSBox methodsFor: 'tree hierarchy' stamp: 'yo 7/24/2012 15:45'!
orContainerSuchThat = (aFunction) ->
	// Return self or the nearest container (above me) that satisfies the block
	var cc = this
	while true
		if aFunction(cc)
			return cc
		cc = cc.container()
		if !!cc
			return cc! !

!KSBox methodsFor: 'tree hierarchy' stamp: 'ael 3/20/2013 13:14'!
topContainer = () ->
	// Return the upper-most container.  Its container is nil, and it should be a window.
	var cc = this
	while true
		var nextC = cc.container()
		if !!nextC
			return (if cc.isWindow then cc else nil)
		cc = nextC! !

!KSBox methodsFor: 'tree hierarchy' stamp: 'yo 7/24/2012 14:47'!
worldState = () ->
	// Return the container's worldState, or error if it is absent.
	if @worldState
		return @worldState
	if @container
		return @container.worldState()
	return nil! !

!KSBox methodsFor: 'window' stamp: 'ael 4/1/2013 19:58'!
beWindow = () ->
	this.isWindow = true
	this.haloTarget = this.streamOf(null)
	this.halo = this.newHalo()
	this.addAsParts(this.halo)
	this.haloVisible = $$(@haloTarget.mapE((x) -> this.halo.visible.set(!!!!x)))
	this.removeHalo = $$(@halo.fire.mapE((ev) ->
		if ev.shiftKeyPressed()
			return this.worldState().transferHalo()
		this.worldState().deleteHalo()))

	this.tooltip = KSFactory.default().newTooltip()
	this.addAsParts(this.tooltip)
	this.tooltipTarget = $$(@worldState.hand.lastEntered.delayE(500).mapE((ev) ->
		if ev.box && ev.event === @worldState.hand.lastEntered.event && ev.box.wantsTooltip
			ev.box
		else
			undefined))
	this.tooltipRemover = $$(@worldState.hand.lastEntered.doE(() -> this.tooltipTarget.set(nil)))
	this.tooltipAdjuster = $$(@tooltipTarget.mapE((target) ->
		if target
			var string = target.tooltipString ? target.actionID.asString().truncateWithElipsisTo(30)
			this.tooltip.textContents(string)
			this.tooltip.topLeft(target.globalPointFor(target.extent() * P(1, 0.5)))
		else
			this.tooltip.topRight(P(0, 0))
		this.tooltip.visible.set(!!!!target)))

	this.listen(["dropFiles"])! !

!KSBox methodsFor: 'window' stamp: 'yo 9/3/2013 14:13'!
hostingMorph = () ->
	/* Answer the KSMorph that hosts the receiver.  Since no backpointer is held, this must be done by sledge hammer.  If none is found, answer nil. */
	if !!this.cachedKSMorph
		this.cachedKSMorph = KSMorph.current()
	return this.cachedKSMorph! !

!KSBox methodsFor: 'window' stamp: 'yo 1/28/2013 15:18'!
initializeAsWorld = (extentPoint) ->
	this.removeAllParts()
	var worldState = this.worldState = KSWorldState.new()
	worldState.window = this
	this.initializeShape(extentPoint)
	this.addAsParts(worldState.hand)
	this.clipping(true)
	this.name("Window")
	this.beWindow()
	this.setTimeBubble(true)! !

!KSBox methodsFor: 'window' stamp: 'yo 7/24/2012 10:20'!
initializeAsWorld: extentPoint 
	| worldState |
	self removeAllParts.
	worldState := self ksAt: #worldState asKSKey put: KSWorldState new init.
	worldState ksAt: #window asKSKey put: self.
	self initializeShape: extentPoint.
	self
		addAsParts: (worldState ksAt: #hand asKSKey).
	self ksAt: #clipping asKSKey put: true.
	self ksAt: #name asKSKey put: 'KSWindow'.
	self beWindow.
	^ self setTimeBubble: true! !

!KSBox methodsFor: 'window' stamp: 'yo 7/26/2012 12:28'!
initializeShape: extentPoint
	self shape: (KSShape extent: extentPoint fill: (GeziraFill gradient: {0->Color veryLightGray. 1->Color white} direction: 0@extentPoint y offset: 0)) computeBounds! !

!KSBox methodsFor: 'window' stamp: 'yo 2/8/2013 18:26'!
newHalo = () ->
	var halo = this.factory().newHalo()
	halo.haloTarget = $$(@container.haloTarget)
	halo.attachButtonHandler()
	delete halo.pointerEnter
	delete halo.pointerLeave
	delete halo.motionQuery
	halo.rejectEventsWithModifiers()
	halo.handleControlKey(true)
	halo.handleShiftKey(true)
	halo.highlightEnabled = false
	return halo! !

!KSBox methodsFor: 'window' stamp: 'yo 8/24/2012 11:12'!
receiveForWindow = (anEvent) ->
	// Receive and dispatch incoming events.
	if anEvent.handler
		return this
	this.worldState.preProcess(anEvent)
	var tried = false
	if anEvent.isKeyboardEvent
		if anEvent.hand.keyboardFocus.currentValue()
			tried = true
			anEvent.hand.keyboardFocus.currentValue().announce(anEvent)
	if anEvent.isMouseEvent
		anEvent.hand.topLeft(this.localPointFor(anEvent.position))
		if anEvent.hand.focus.currentValue()
			anEvent.hand.focus.currentValue().focusedReceive(anEvent)
			if anEvent.handler
				tried = true
	if !!tried
		this.announceInCollections(anEvent)
	this.worldState.postProcess(anEvent)
	if !!anEvent.handler
		this.announce(anEvent)! !

!KSBox methodsFor: 'window' stamp: 'ael 3/17/2013 23:23'!
updateHalo = (target) ->
	var halo = @halo
	if !!halo
		return
	if halo.gradTarget && target !!== halo.gradTarget
		halo.deleteGradientTool()
	var gtr = target.transformationFromGlobal()
	halo.transformation(MatrixTransform2x3.withRadRotation(gtr.rotation()).composedWithGlobal(MatrixTransform2x3.withOffset(gtr.transformPointNoRound(P(0, 0)))))
	this._adjustHalo_for(gtr, target)! !

!KSBox class methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/29/2013 00:56'!
loadBoxFromDirectory: dir
	| file aString pp dirObject |
	dirObject := PPPusher directoryObject: dir.
	file := dirObject readOnlyFileNamed: 'index.pp'.
	aString := file binary contentsOfEntireFile asString.
	pp := PPPuller new initialize.
	^ pp readFromDirectory: dirObject.! !

!KSBox class methodsFor: '*ksobjects-pushpull' stamp: 'ael 2/18/2013 12:55'!
loadBoxFromDirectoryViaCache: dir
	| dirObject cacheDir |
	dirObject := PPPusher directoryObject: dir.
	(dirObject isKindOf: FileDirectory) ifFalse: [
		Transcript cr; show: 'checking ', dir.
		[PPPusher copyServerDirectory: dirObject]
			on: Error do: [:ex | Transcript show: ex messageText].
		cacheDir := PPPusher cacheDirectoryForDAVDirectory: dirObject]
	ifTrue: [
		cacheDir := dirObject].
	^ self loadBoxFromDirectory: cacheDir.! !

!KSBox class methodsFor: '*ksobjects-pushpull' stamp: 'ael 2/18/2013 12:55'!
loadBoxFromDirectoryViaCacheFirst: dir
	| dirObject cacheDir result |
	dirObject := PPPusher directoryObject: dir.
	cacheDir := PPPusher cacheDirectoryForDAVDirectory: dirObject.
	result := [self loadBoxFromDirectory: cacheDir]
		on: FileDoesNotExistException
		do: [:ex | Transcript show: ex messageText; cr. nil].
	result ifNotNil: [^ result].
	Transcript cr; show: 'checking ', dir.
	[PPPusher copyServerDirectory: dirObject] on: Error do: [:ex | Transcript show: ex messageText].
	^ self loadBoxFromDirectory: cacheDir! !

!KSBox class methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/29/2013 00:58'!
saveBox: aBox toDirectory: dir
	| file pp dirObject |
	dirObject := PPPusher directoryObject: dir.
	dirObject assureExistence.
	file := dir forceNewFileNamed: 'index.pp'.
	pp := aBox ppScanObjects.
	[file nextPutAll: pp prettyStringWithSorting]
		ensure: [file close]! !

!KSBox class methodsFor: 'initialization' stamp: 'yo 2/18/2013 14:06'!
initialize
"
	KSBox initialize 
"

	KSFamily initialize.
	GlyphNames := #(
	"ISO8859-15 would be better, but I can't find the table for it and am to lazy to construct it by hand."
	"0"		"1"		"2"		"3"		"4"		"5"		"6"		"7"
  "00"	#'.notdef'	controlSTX	controlSOT	controlETX	controlEOT	controlENQ	controlACK	controlBEL
  "01"	controlBS	controlHT	controlLF	controlVT	controlFF	controlCR	controlSO	controlSI
  "02"	controlDLE	controlDC1	controlDC2	controlDC3	controlDC4	controlNAK	controlSYN	controlETB
  "03"	controlCAN	controlEM	controlSUB	controlESC	controlFS	controlGS	controlRS	controlUS
  "04"	space		exclam		quotedbl	numbersign	dollar		percent		ampersand	quotesingle
  "05"	parenleft	parenright	asterisk	plus		comma		hyphen		period		slash
  "06"	zero		one		two		three		four		five		six		seven
  "07"	eight		nine		colon		semicolon	less		equal		greater		question
  "10"	at		A		B		C		D		E		F		G
  "11"	H		I		J		K		L		M		N		O
  "12"	P		Q		R		S		T		U		V		W
  "13"	X		Y		Z		bracketleft	backslash	bracketright	asciicircum	underscore
  "14"	grave		a		b		c		d		e		f		g
  "15"	h		i		j		k		l		m		n		o
  "16"	p		q		r		s		t		u		v		w
  "17"	x		y		z		braceleft	bar		braceright	asciitilde	controlDEL
  "20"	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'
  "21"	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'
  "22"	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'
  "23"	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'	#'.notdef'
  "24"	space		exclamdown	cent		sterling	currency	yen		brokenbar	section
  "25"	dieresis	copyright	ordfeminine	guillemotleft	logicalnot	softhyphen	registered	macron
  "26"	degree		plusminus	twosuperior	threesuperior	acute		mu		paragraph	periodcentered
  "27"	cedilla		onesuperior	ordmasculine	guillemotright	onequarter	onehalf		threequarters	questiondown
  "30"	Agrave		Aacute		Acircumflex	Atilde		Adieresis	Aring		AE		Ccedilla
  "31"	Egrave		Eacute		Ecircumflex	Edieresis	Igrave		Iacute		Icircumflex	Idieresis
  "32"	Eth		Ntilde		Ograve		Oacute		Ocircumflex	Otilde		Odieresis	multiply
  "33"	Oslash		Ugrave		Uacute		Ucircumflex	Udieresis	Yacute		Thorn		germandbls
  "34"	agrave		aacute		acircumflex	atilde		adieresis	aring		ae		ccedilla
  "35"	egrave		eacute		ecircumflex	edieresis	igrave		iacute		icircumflex	idieresis
  "36"	eth		ntilde		ograve		oacute		ocircumflex	otilde		odieresis	divide
  "37"	oslash		ugrave		uacute		ucircumflex	udieresis	yacute		thorn		ydieresis ).! !

!KSBox class methodsFor: 'instance creation' stamp: 'yo 9/6/2012 15:51'!
extent: aPoint fill: aFill
	| inst |
	inst := self new.
	inst shape: (KSShape extent: aPoint fill: aFill).
	^ inst.! !

!KSBox class methodsFor: 'instance creation' stamp: 'ael 3/20/2013 12:05'!
withChar: char inFont: font
	^self new beCharacter: char asInteger with: font; yourself! !

!KSBox class methodsFor: 'instance creation' stamp: 'yo 8/30/2012 13:16'!
withShape: aShape
	^ self new shape: aShape; yourself! !

!KSBox class methodsFor: 'instance creation' stamp: 'yo 9/3/2013 15:22'!
withTexture: aTexture
	^ (self extent: 0@0 fill: Color transparent) texture: aTexture; yourself! !

!KSBox class methodsFor: 'menu' stamp: 'ael 3/15/2013 14:22'!
invokeMenu: aMenuBox near: globalPoint for: aBox
	"Put up the menu and let the user choose an item."
	| root |
	root := aBox ksAt: #'__topContainer__'.
	aMenuBox borderWidth: 2.
	aMenuBox layout layOut: aMenuBox.
	aMenuBox topLeft: globalPoint.
	root worldState menu: aMenuBox.
	root addAsPartsFirst: aMenuBox.
	aMenuBox forceWithinContainer.
	(root worldState at: #hand) focus: aMenuBox.! !
