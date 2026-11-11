KSUserEventHandler subclass: #KSTextLayout
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSTextLayout commentStamp: 'tk 2/12/2013 14:19' prior: 0!
A KSTextLayout is a handler to lay out and edit word wrapped text.
(the old class LTextLayoutPre is folded into this class.  No separate 'pre' superclass.)

font		
selection		an interval (0-order).  start is an index before the selected character, and stop is after the last char.
selectionAnchor		index of the anchor charater (before or after it?)
caret		THe vertical bar box.
tabArray		
undoStack		
lastTypeInTransaction		
autoVerticalResize		true if field shrinks and grows at its bottom.
valueChanged		
name		
flowDir		(1@0)
overflowDir		(0@1)
groupMeasureSel		#wordWidth
groupPrepSel		#measureWords
breakSel		#isNewline
isReadOnly
maxHeight		of a letter on this line
missingHeight		extra in a letter taller than maxHeight
maxDescent	in pixels
lineStart		box of letter at start of the current line
justification			left, right, center, or full
extraOnLeft		pixels of space before the first char of the line
extraEachSpace	amount added to each space character
spacesInLine		number
current		box of letter we are processing now
debug		boolean
debugState

The actual layout is governed by 'rules'.  These are methods for simple understandable rules.  Each rule works on either an individual character (an element) or on the text field as a whole (the client).

We also handle input events, such as selection and type-in.
We hold the selection and the insertion point.  
Later we will put selection and input into one aspect, and layout into another.

selection is an interval that does not include the end indicies.  start is an index before the selected character, and stop is after the last char.  1 to: 2 is an insertion point between chars 1 and 2.  1 to: 3 selects the second char.  0 to: 1 is an insertion point at the beginning.  contents size to: contents size + 1 is an insertion point after the end of the text.

For tall letters and justification, which require the entire line to be moved, remember how much they must be moved. Set current to the start of the line, and proceed from there.  Always just working on a single letter.  Only go back to the start of the line when we reach the end of the line.  Next time the errors will be 0.

maxHeight is the height of the tallest character in this line.  It is the distance from the bottom of the chars in the previous line to baseline of this line.  
missingHeight is the amount that the baseLine must be moved down to accomodate a new tall character.  When a word ends and missingHeight > 0, we go back and move the line down.

Justification:  If the spacing in not right at the end of a line, set extraOnLeft and extraEachSpace.  Go back to lineStart and layout the line again.

valueChanged is true when the content of the client changed in a way that would cause a spreadsheet cell to re-evaluate.  Changing the selection or emphasis or text size does not set valueChanged.  Deleting or inserting characters does change valueChanged.  User may reset it to false.!

!KSTextLayout methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/7/2013 00:34'!
ppSerializer = () ->
	return this! !

!KSTextLayout methodsFor: '*ksobjects-pushpull' stamp: 'yo 2/7/2013 00:35'!
ppWriteElements: sexp context: dictionary
	sexp addElement: (PPElement head: #data elements: (PPTextExporter new export: (self at: #whole) contents with: dictionary)).! !

!KSTextLayout methodsFor: 'accessing' stamp: 'tk 1/23/2013 11:09'!
canInclude = (aBox) ->
	// Return true if this layout can deal with this kind box in its contents
	return true! !

!KSTextLayout methodsFor: 'accessing' stamp: 'tk 2/27/2013 10:48'!
inset = (aPointOrNumber) ->
	if aPointOrNumber.isNumber()
		this.leftMargin = this.topMargin = this.bottomMargin = this.rightMargin = aPointOrNumber

	if aPointOrNumber.isPoint()
		this.leftMargin = this.rightMargin = aPointOrNumber.x()
		this.topMargin = this.bottomMargin = aPointOrNumber.y()
	if aPointOrNumber.isRectangle()
		this.leftMargin = aPointOrNumber.origin().x()
		this.rightMargin = aPointOrNumber.corner().x()
		this.topMargin = aPointOrNumber.origin().y()
		this.bottomMargin = aPointOrNumber.corner().y()
	if @whole
		@whole.layoutChanged()! !

!KSTextLayout methodsFor: 'accessing' stamp: 'tk 1/23/2013 11:01'!
layoutChildrenFirst = () ->
	return true! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 3/20/2013 13:41'!
adjustJustification = (isLast) ->
	// "Justify the line that just finished for left, right, center, or full.  For full, treat each space character as a glue box.  Move the spaces to make them larger and fill the line.  Current is the first letter on the next line, or the last char if at the end of text.
	// Set extraOnLeft and extraEachSpace jump back to lineStart and re-layout.
	// Later insert spaces or glue between non-glyph boxes."
	// OK for this.justification to be a strange value from ODF 

	if !!((this.extraOnLeft == 0) && (this.extraEachSpace == 0))  
	   // just did the adjustment on this line
		this.extraOnLeft = 0
		this.extraEachSpace = 0
		return false
	if !!this.justification
		return false
	if this.justification == 'left'
		return false		// already done
	// compute extra space
	// "get back to before the trailing white space"
	var pred = if isLast then this.current else this.current.predecessor()
	var gotChar = false
	for ii in [1...10000]
		if pred
			if pred.isWhiteSpace()
				if pred.unicode() == 32 then this.spacesInLine -= 1
				pred = pred.predecessor()
			else
				gotChar = true
				break
			if pred === this.lineStart
				break
		else
			break
	if !!gotChar 	// entire line is white space
		this.extraOnLeft = 0
		this.extraEachSpace = 0
		return false
	// "How much space is on the right?"
	var rtEdge = (@whole.rightAtY(pred.pivotPosition().y())) - this.rightMargin
	var extra = rtEdge - pred.right()
	if extra < 0.5
		return false		// close enough
	if (this.justification == 'full') && !!isLast
		if this.spacesInLine < 1
			return false	
		if extra > (0.5 * rtEdge)
			return false			// very few words
		this.extraOnLeft = 0
		if extra > 0.5
			this.extraEachSpace = (extra / this.spacesInLine)
		else
			this.extraEachSpace = 0		// too small
		// Transcript.cr().show(this.extraEachSpace)
	if this.justification == 'right'
		this.extraOnLeft = extra
		this.extraEachSpace = 0
	if this.justification == 'center'
		this.extraOnLeft = extra / 2
		this.extraEachSpace = 0
	if (this.extraOnLeft == 0) && (this.extraEachSpace == 0)
		return		// unknown kind of justification 
	this.startLineOver = this.lineStart
	this.startLineOver.pivotPosition(P(((@whole.leftAtY(this.startLineOver.pivotPosition().y())) + this.leftMargin) + this.extraOnLeft,  (this.startLineOver.pivotPosition().y())))
	return true! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 2/14/2013 09:59'!
layOut = (theTextBox) ->
	// "Note layOut: with a capital O is what the system sends an LBox"
	this.measureGroup()

	if (@whole.isEmpty()) 
		return this
	this.current = @whole.first()

	var res = this.place()
	while res 
		res = this.place()	//	"set the position of all letters"! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 1/23/2013 11:16'!
measureGroup = () ->
	// "Cache the word width.  Letter at start of a word has property wordWidth.  Other letters do not. "  

	this.perform(this.groupPrepSel)
	// "Later parameterize this also.  selectors to determine if start of group, add to measure."! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 3/19/2013 16:20'!
measureWords = () ->
	// "find word starts in one line and measure them.  Check for edit making word continue on next line.  Move some chars, and allow first line to be too long.
	// Maybe compute maxAscent and maxDescent here also."

	var fieldWidth = @whole.width() - this.leftMargin - this.rightMargin
	var inWord = false
	var predRight = 0
	var lastStart = nil
	for letter in @whole.contents
		delete letter[this.groupMeasureSel]
		var ascention = letter.pivotOffset().x() 
		if (predRight + letter.width() - ascention > fieldWidth)
			inWord = false     // "break a very long word"
		if letter.isWhiteSpace()
			// "do not measure white space"
			if inWord
				inWord = false  // "white space means stop a word always"
		else
			if inWord
				predRight = predRight + letter.width() - ascention
			else  // "start of a new word"
				if lastStart
					lastStart[this.groupMeasureSel] = predRight
				lastStart = letter
				predRight = letter.width() * (1.0 - letter.pivotRatio().x())
				inWord = true

	if lastStart
		lastStart[this.groupMeasureSel] = predRight! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 2/27/2013 10:09'!
place = () ->
//	"consider one letter"

	if !!this.current
		return nil
	for ruleMethod in [#'rule1', #'rule2', #'rule3', #'rule4', #'rule5', #'notNil']
		if (this.perform(ruleMethod))
			// "rule succeeded"
			if !!this.current 
				return nil  // "whole box is full"
			this.current = this.current.successor()
			return this.current
	return nil! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 3/7/2013 14:04'!
rule1 = () ->
	// "If I am first in my line, pursue the goal of being at my container's upper left's inset, and initialize variables."  

	if (this.current === @whole.first())
		this.current.pivotPosition(P(this.leftMargin, this.topMargin + this.current.ascent()))
		this.lineStart = this.current
		this.maxHeight = this.current.ascent()
		this.maxDescent = this.current.descent()
		this.missingHeight = 0
		this.spacesInLine = 0
		this.extraOnLeft = 0
		this.extraEachSpace = 0
		this.rule5()		// If last letter in field, test if we do vertical shrink 
		return true
	return false! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 3/19/2013 16:44'!
rule2 = () ->
	/* "Else if I am the start of a group and my predecessor's end plus my group's measure overhangs the container in the flow direction, 
	If justification or excess height, start the line over, else pursue the goal of being the next start of flow in the overflow direction and initialize line measures."  */
	var wrap = false
	var value = this.current[this.groupMeasureSel]    // wordWidth
	var pred = this.current.predecessor()
	if pred
		pred.beTabFromWidths(this.tabArray)
	if value
		if this.extraEachSpace > 0		// full justification
			value = value - 4.0		// fudge for bad measurement
		var bottomRightMargin = P(this.rightMargin , this.bottomMargin)
		if (pred.bottomRight() + value) * this.flowDir >= ((@whole.extent() - bottomRightMargin) * this.flowDir)
			wrap = true
	if pred
		if (pred.perform(this.breakSel))
			wrap = true    // "start of the next line"

	if wrap && !!this.noWrap
		// "adjust previous line"
		this.tallLetterMove()
		this.adjustJustification(false)	  //later combine
		if this.startLineOver
			this.current = this.startLineOver
			return true

		// "Set current position to the front of the next line."
		this.maxHeight = this.current.ascent()
		var leading = this.leading
		if leading == undefined then leading = 2
		this.current.pivotPosition(P(this.current.pivotPosition().x(),   (pred.pivotPosition().y() + this.maxHeight + this.maxDescent + leading)))	// "set y only"
		//   "set x based on y"
		this.current.pivotPosition(P(((@whole.leftAtY(this.current.pivotPosition().y())) + this.leftMargin) + this.extraOnLeft,  (this.current.pivotPosition().y())))
		// this.maxHeight = this.current.ascent()
		this.maxDescent = this.current.descent()
		this.missingHeight = 0
		this.spacesInLine = 0
		this.extraOnLeft = 0
		this.extraEachSpace = 0
		this.lineStart = this.current
		return true
	return false   // "go on to the next rule"! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'yo 8/20/2013 11:48'!
rule3 = () ->
	// "Else pursue the goal of being after my predecessor in the flow direction."  

	var pred = this.current.predecessor()
	var pt = pred.bottomRight() * this.flowDir  	// "x of previous"
	var ascention = this.current.pivotOffset() * this.flowDir
		// "x inset of pivot point of current letter"
		// need bounds?  this.current.topLeft() - this.current.topLeft() + 
	var otherDir = P(1,1) - this.flowDir
	"this.current.pivotPosition((pred.pivotPosition() * otherDir) +  pt + ascention)"
	this.current.pivotPosition(P(pred.pivotPosition().x() + pred.bounds().width(), pred.pivotPosition().y()))
	return false		// always do rule 4! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'ael 3/20/2013 12:37'!
rule4 = () ->
	// "Record excess tall letter height, count a space, widen spaces if full justification."

	this.tallLetter(this.current)		// record how tall
	if this.current.unicode() == 32
		// first pass
		this.spacesInLine += 1
		// second pass
		var pt = this.current.pivotPosition()
		this.current.pivotPosition(pt + P(this.extraEachSpace, 0))
	return false		// one more thing to do! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 3/7/2013 14:37'!
rule5 = () ->
	// "If this is the last letter:  If justification or excess height, start the line over, else optionally shrink the field width and height."  

	if this.current === @whole.last()
		this.tallLetterMove()			// move line down, set startLineOver
		this.adjustJustification(true)	// do we need to justify, set startLineOver
		if this.startLineOver
			this.current = this.startLineOver
		else
			this.installSelection()
			if this.verticalShrink
				var hh = this.current.pivotPosition().y() + this.maxDescent + this.bottomMargin
				hh = hh.max(this.font.height()).max(@minimumHeight?hh)
				// pivotPosition includes the top margin inset.
				@whole.height(hh)

			// set the appropriate width
			var w = if this.horizontalShrink then this.current.right() + this.rightMargin else @whole.width()
			w = w.max(@minimumWidth ? w)
			w = w.min(@maximumWidth ? w)
			@whole.width(w)
	return true		// this rule handled the current letter! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'yo 2/7/2013 22:03'!
startOfWord = (box) ->
	// find that letter box that begins this word
	if !!box.predecessor() 
		return box
	if box.unicode() == 0
		if !!box.texture()
			return box
	if (box.predecessor().isWhiteSpace())
		return box
	return this.startOfWord(box.predecessor())! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 1/22/2013 10:44'!
tallLetter = (aBox) ->
	// "If this letter is taller than all we have seen on this line, increase missingHeight"

	var howMuchTaller = aBox.ascent() - (this.maxHeight + this.missingHeight)
	if howMuchTaller > 0 
		this.missingHeight = this.missingHeight + howMuchTaller
	this.maxDescent = this.maxDescent.max(aBox.descent())! !

!KSTextLayout methodsFor: 'basic word wrap' stamp: 'tk 2/18/2013 14:11'!
tallLetterMove = () ->
	// "We are at the end fo a line.  If missingHeight is > 0, there was a tall letter in the line.  Move the first letter in this line down, and start over laying out this line."

	if this.missingHeight <= 0 
		this.startLineOver = nil
		return false

	// "move first letter down"
	this.lineStart.pivotPosition(this.lineStart.pivotPosition() + P(0, this.missingHeight))

	// "Start on the second letter"
	this.maxHeight = this.maxHeight + this.missingHeight
	this.missingHeight = 0
	// "maxDescent and lineStart stay the same"
	this.startLineOver = this.lineStart
	return true! !

!KSTextLayout methodsFor: 'initialization' stamp: 'ael 3/11/2013 14:37'!
acceptContentsOnCR = (state) ->
	this.acceptContentsOnCR.set(state)! !

!KSTextLayout methodsFor: 'initialization' stamp: 'ael 3/11/2013 16:30'!
acceptContentsOnFocusLoss = (state) ->
	if state
		this.updateKeyboardFocus = $$(@whole.__topContainer__.worldState.hand.keyboardFocus.collectE({oldFocus: nil, newFocus: nil}, (newVal, oldVal) -> { oldFocus: oldVal.newFocus, newFocus: newVal }))
		this.autoSave = $$(@updateKeyboardFocus.mapE((oldNew) ->
			if oldNew.oldFocus === @whole && oldNew.newFocus !!== @whole
				this.whole.currentValue().contentsAccepted.set({handler: @whole})))
	else
		delete this.updateKeyboardFocus
		delete this.autoSave! !

!KSTextLayout methodsFor: 'initialization' stamp: 'yo 2/27/2013 23:37'!
beReadOnly = (readOnly) ->
// if false, allow editing, if true be inert
	this.isReadOnly = readOnly
	if readOnly
		delete this.textDoButtonDown
		delete this.textDoPointerMotion
		delete this.textDoButtonUp
		delete this.editorDispatch
		@whole.blockHaloForContents()
	else
		if !!this.textDoButtonDown
			this.behavior()! !

!KSTextLayout methodsFor: 'initialization' stamp: 'tk 2/27/2013 13:15'!
beSingleLineInput = () ->
// Make carriage return take the current contents and push it to the box's @contentsAccepted stream

	this.beSingleLineInput(true)! !

!KSTextLayout methodsFor: 'initialization' stamp: 'ael 3/11/2013 14:37'!
beSingleLineInput = (beSingleLine) ->
// Make carriage return take the current contents and push it to the box's @contentsAccepted stream

	this.noWrap = beSingleLine
	this.acceptContentsOnCR(beSingleLine)	
	this.verticalShrink = beSingleLine
	this.isLineEditor = beSingleLine
	if @whole
		@whole.blockHaloForContents(beSingleLine)! !

!KSTextLayout methodsFor: 'initialization' stamp: 'ael 3/11/2013 14:39'!
behavior = () ->

	this.updateSelection = $$(@selection.doE(() ->
		this.installSelection()))

	this.typeIn = (keyStrokeEvt) ->
		this.insertChar(keyStrokeEvt.keyValue)

	this.editorDispatch = $$(@whole.keyStroke.mapE((keyEv) ->
		for keyValue in keyEv.keyValues
			var char = Character.value(keyValue)
			var cstr
			if !!char.isAlphaNumeric() 
				cstr = ("0".concat(keyValue.printString())).last(2) //"do08 = delete"
			else
				cstr = String.with(char)
			if keyEv.buttons.bitAnd(64) > 0
				cstr = 'CMD'.concat(cstr)  // CMDv
			cstr = 'do'.concat(cstr)		// doCMDv or do08
			var cstrS = Symbol.findInterned(cstr)		// or nil
			if cstrS
				if this.respondsTo(cstrS)
					this.perform(cstrS)
					@whole.layoutChanged()
				else
					this.insertChar(keyValue)
			else
				this.insertChar(keyValue)))

	var hadButtonUp = this.whole.buttonUp && !!this.whole.buttonUp.dormant()
	@whole.listen(["keyStroke", "buttonDown", "pointerMotion", "buttonUp"])
	if !!hadButtonUp
		this.whole.buttonUp.dormant(true)
	this.whole.pointerMotion.dormant(true)
	@whole.handleControlKey(false)

	this.textDoButtonDown = $$(this.handleButtonDown(@whole.buttonDown))
	this.textDoPointerMotion = $$(this.handlePointerMotion(@whole.pointerMotion))
	this.textDoButtonUp = $$(@whole.buttonUp.mapE((ev) ->
		this.whole.buttonUp.dormant(true)
		this.whole.pointerMotion.dormant(true)
		ev.hand.focus(nil)))
	this.whole.contentsAccepted = @whole.streamOf(undefined)! !

!KSTextLayout methodsFor: 'initialization' stamp: 'yo 2/27/2013 22:36'!
createCaret = () ->
	// "build the object that will show as the insertion point in the text"
	var ca = KSBox._extent_fill(P(2, @font.lineSkip()), this.selectionColor.muchDarker())
	ca.selection = true
	ca.pivotRatio(P(1, (@font.ascent() / @font.height())))
	return ca! !

!KSTextLayout methodsFor: 'initialization' stamp: 'yo 9/3/2013 16:43'!
initialize = () ->
	super.initialize()
	this.font = KSFactory.default().defaultFont()
	this.flowDir = P(1, 0)
	this.overflowDir = P(0,1)
	this.groupMeasureSel = #'wordWidth'
	this.groupPrepSel = #'measureWords'
	this.breakSel = #'isNewline'
	this.isReadOnly = false
	this.undoStack = []
	this.selectionColor = Color._r_g_b( 0.7, 1.0, 0.7)
	this.selection = this.streamOf(0.to(1))
	this.selectionAnchor = 1  // "should not be needed"
	this.inset(2)
	this.tabArray = 30._to_by(500, 30)
	this.extraOnLeft = 0
	this.extraEachSpace = 0
	this.justification = "left"
	this.spacesInLine = 0
	this.isLineEditor = false
	this.acceptContentsOnCR = this.streamOf(false)
	this.verticalShrink = false
	this.minimumHeight = this.streamOf(nil)
	this.contentsChanged = this.streamOf(undefined)! !

!KSTextLayout methodsFor: 'initialization' stamp: 'ael 3/11/2013 14:35'!
installTo = (aBox) ->
	super.installTo(aBox)
	aBox.layout(this)
	aBox.showSelection = this.streamOf(false)
	this.behavior()
	this.caretAtLineEnd = false
	this.installSelection()
	aBox.contentsAccepted = aBox.streamOf(undefined)
	this.updateFocus = $$(@whole.showSelection.doE(() -> this.installSelection()))! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/21/2013 10:27'!
chooseFontSize = (event) ->
// Ask the user for a font size.  Later add the possibility of new sizes

	var list = ([#'selectionToSize', b] for b in ['10', '12', '14', '18', '20', '24', '36'])
	var menu = @whole.createMenu( list, this)
	KSBox._invokeMenu_near_for(menu, event.position, @whole)! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:27'!
do08 = () ->
	// "Delete, Backspace"

	this.textAction("delete")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/25/2013 17:27'!
do13 = () ->
	// "return char." 
	this.textAction("return")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:25'!
do28 = () ->
	// "left arrow.  move the cursor" 
	this.textAction("cursorLeft")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:18'!
do29 = () ->
	// "right arrow.  move the cursor" 
	this.textAction("cursorRight")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/11/2013 09:13'!
do30 = () ->
	// "up arrow.  move the cursor" 
	this.textAction("cursorUp")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/11/2013 11:24'!
do31 = () ->
	// "Down arrow.  move the cursor" 
	this.textAction("cursorDown")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/1/2013 19:25'!
doCMD28 = () ->
	// "Previous page if in a stack.  Command left arrow" 
	if @whole.stackHandler()
		@whole.stackHandler().navBarAction('prev')! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/1/2013 19:25'!
doCMD29 = () ->
	// "Go to the next page, if the field is in a stack.  Command right arrow" 
	if @whole.stackHandler()
		@whole.stackHandler().navBarAction('next')! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:30'!
doCMD43 = () ->
	// "Command-+.  Increase font size of the selecton.  Handles both = and + since shift key is not tested" 
	this.textAction("fontLarger")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:34'!
doCMD45 = () ->
	// "Command-minus.  Decrease font size of the selecton" 
	this.textAction("fontSmaller")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:34'!
doCMD61 = () ->
	// "Command-+.  Increase font size of the selecton.  Handles both = and + since shift key is not tested" 
	this.textAction("fontLarger")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:35'!
doCMDa = () ->
	// "Command-a.  Select all text.  Selection is an interval from the index before the selected letters to the index after the last one." 
	this.textAction("selectAll")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:37'!
doCMDb = () ->
	// "Command-b.  Toggle the boldness of the selecton" 

	this.textAction("toggleBold")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:41'!
doCMDc = () ->
	// "Command-c.  Copy the selection and put it into the clipboard" 

	this.textAction("copy")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 3/20/2013 19:05'!
doCMDd = () ->
	// "Command-d.  Do-it.  Execute the selected code" 

	this.textAction("doIt")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:39'!
doCMDi = () ->
	// "Command-i.  Toggle the italic-ness of the selecton" 

	this.textAction("toggleItalic")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 3/20/2013 19:05'!
doCMDp = () ->
	// "Command-p.  print-it.  Execute the selected code and insert the answer" 

	this.textAction("printIt")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'yo 2/22/2013 14:35'!
doCMDs = () ->
	// "Command-s.  Generates accept event." 
	this.textAction("accept")			! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:46'!
doCMDt = () ->
	// "Command-t.  Force the selection to be not-bold and not-italic and not underlined, etc." 

	this.textAction("beNormal")			! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/14/2013 09:25'!
doCMDu = () ->
	// "Toggle text justificaton, alignment for entire text box." 

	this.textAction("justify")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/5/2013 12:44'!
doCMDv = () ->
	// "Command-v.  Paste.  Copy the clipboard and replace the selection with it" 

	this.textAction("paste")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 2/6/2013 14:26'!
doCMDx = () ->
	// "Command-x.  Cut.  Remove the selection and put it into the clipboard" 

	this.textAction("cut")! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 3/4/2013 10:40'!
doCursorDown = () ->
	// Move the cursor down to the next line

	if !!this.firstInSelection() 
		return nil
	var aLetter = @whole.contents[0.max(@selection.last()-2)]
	var baseLine = aLetter.pivotPosition().y()
	for ind in [@selection.last() +1 -1 ... @whole.contents.size()-1] 
		var baseBelow = @whole.contents[ind].pivotPosition().y()
		if baseBelow - 0.1 > baseLine
			var nextLineInd = ind
			break
	if !!nextLineInd
		return nil		// put cursor at end
	// find the closest letter
	var minDistSq = 100000000
	var minIndex = nextLineInd
	var curCenter = aLetter.right()
	for ind2 in [nextLineInd ... @whole.contents.size()-1] 
		var bx = @whole.contents[ind2]
		var baseBelow2 = bx.pivotPosition().y()
		if baseBelow2 - 0.1 > baseBelow
			break		// do not need to test entire field
		var distSq = (bx.right() - curCenter).abs()
		if distSq < minDistSq
			minDistSq = distSq
			var minIndex = ind2
	this.selectionAnchor = nil
	this.selection.set((minIndex+1).to(minIndex+2))! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 3/4/2013 10:35'!
doCursorUp = () ->
	// Move the cursor upward to the next line

	var aLetter = this.firstInSelection()
	if !!aLetter 
		return nil
	var baseLine = aLetter.pivotPosition().y()
	for ind in [@selection.first() +1 -2 ... 0] by -1
		var baseAbove = @whole.contents[ind].pivotPosition().y()
		if baseAbove + 0.1 < baseLine
			var prevLineInd = ind
			break
	if !!prevLineInd
		return nil
	// find the closest letter
	var minDistSq = 100000000
	var minIndex = prevLineInd
	var curCenter = aLetter.left()
	for ind2 in [prevLineInd ... 0] by -1
		var bx = @whole.contents[ind2]
		var baseAbove2 = bx.pivotPosition().y()
		if baseAbove2 + 0.1 < baseAbove
			break		// do not need to test entire field
		var distSq = (bx.left() - curCenter).abs()
		if distSq < minDistSq
			minDistSq = distSq
			var minIndex = ind2
	this.selectionAnchor = nil
	this.selection.set(minIndex.to(minIndex+1))! !

!KSTextLayout methodsFor: 'key commands' stamp: 'ael 3/20/2013 12:27'!
selectionToColor = (color) ->
// force the selected text to be a certain color

	for ii in ((@selection.first()).to(@selection.last() -2))
		var letter = @whole.contents[ii]
		if letter.unicode() !!= 0
			letter.setFont(letter.font.currentValue().fill(color))! !

!KSTextLayout methodsFor: 'key commands' stamp: 'ael 3/20/2013 12:27'!
selectionToFont = (event) ->
// force the selected text to be a certain font, whose name is in the event

	var familyName = event.handler.textContents()
	if familyName.size() == 0
		return
	for ii in ((@selection.first()).to(@selection.last() -2))
		var letter = @whole.contents[ii]
		if letter.unicode() !!= 0
			var oldFont = letter.font.currentValue()
			letter.setFont(oldFont.withFamily(familyName).fill(oldFont.fill()))! !

!KSTextLayout methodsFor: 'key commands' stamp: 'ael 3/20/2013 12:27'!
selectionToSize = (event) ->
// force the selected text to be a certain size

	var fontSize = event.handler.textContents().asInteger()
	for ii in ((@selection.first()).to(@selection.last() -2))
		var letter = @whole.contents[ii]
		if letter.unicode() !!= 0
			letter.setFont(letter.font.currentValue().withSize(fontSize))! !

!KSTextLayout methodsFor: 'key commands' stamp: 'tk 3/12/2013 16:30'!
setDefaultFromSelection = () ->
	// set the field's default font and size from the first char of the current seleciton.
	
	if this.firstInSelection()
		this.font = this.firstInSelection().font.currentValue()
	! !

!KSTextLayout methodsFor: 'key commands' stamp: 'ael 4/1/2013 19:37'!
textAction = (name) ->
// Modify the text, either from a Command key, a menu, or from a program
//	this.textAction("cursorLeft")

	var letter
	if @selection.last() - 1 > @whole.contents.size()
		this.error("selection off end")    // later just fix it
	if name == "accept"
		this.whole.contentsAccepted.set({handler: @whole})
		return
	if name == "delete"    // do08
		if this.selectionEmpty() 
			if @selection.first() > 0
				@whole.removeAt(@selection.first())
				this.selection.set((@selection.first() -1).to(@selection.first()))
		else
			while !!(this.selectionEmpty())
				@whole.removeAt(@selection.first() +1)
				this.selection.set((@selection.first()).to(@selection.last() - 1))
		this.installSelection()
		return
	if name == "return"   // do13 and enter
		if @acceptContentsOnCR
			this.whole.currentValue().contentsAccepted.set({handler: @whole})
		else
			this.insertChar(13)
		return
	if name == "cut"   // doCMDx
		this.textAction("copy")
		this.textAction("delete")
		return
	if name == "copy"   // doCMDc
		if !!this.selectionEmpty()
			@whole.worldState().setClipboard(@whole.contents._copyFrom_to(@selection.first() + 1, @selection.last() -1))
		return
	if name == "paste"   // doCMDv
		if @selection.size() > 2 
			this.do08()	// "delete the old selection"
		for box in @whole.worldState().getClipboard()
			@whole.addAfterIndex(box, (@selection.last() -2))
			this.selection.set((@selection.first() +1).to(@selection.first() +2))
		return
	if name == "doIt"   // doCMDd
		Compiler.evaluate(this.selectionAsString())
		return
	if name == "printIt"   // doCMDp
		var res = Compiler.evaluate(this.selectionAsString())
		// move selection and insert
		this.selection.set((@selection.last() -1).to(@selection.last()))
		this.insertChar(' '.first())
		this.addAll(res.printString())
		return
	if name == "cursorLeft"    // do28
		if @selection.first() >= 1
			this.selection.set((@selection.first() -1).to(@selection.first()))
		else
			this.selection.set(0.to(1))
		return
	if name == "cursorRight"   // do29
		if @selection.last() <= @whole.contents.size()
			this.selection.set((@selection.last()).to(@selection.last() + 1))
		else
			this.selection.set(@whole.contents.size().to(@whole.contents.size() +1))
		return
	if name == "cursorUp"   // do30
		this.doCursorUp()
		return
	if name == "cursorDown"   // do31
		this.doCursorDown()
		return
	if name == "fontLarger"   // doCMD43,  doCMD61
		for ii in ((@selection.first()).to(@selection.last() -2))
			@whole.contents[ii].increaseFontBy(1)
		return
	if name == "fontSmaller"   // doCMD45
		for ii in ((@selection.first()).to(@selection.last() -2))
			@whole.contents[ii].increaseFontBy(-1)
		return
	if name == "selectAll"   // doCMDa
		this.selection.set(0.to(@whole.contents.size() + 1))
		return
	if name == "toggleBold"   // doCMDb
		for ii in ((@selection.first()).to(@selection.last() -2))
			letter = @whole.contents[ii]
			letter.beBold(!!letter.isBold())
		return
	if name == "toggleItalic"   // doCMDi
		for ii in ((@selection.first()).to(@selection.last() -2))
			letter = @whole.contents[ii]
			letter.beItalic(!!letter.isItalic())
		return
	if name == "beNormal"   // doCMDt
		for ii in ((@selection.first()).to(@selection.last() -2))
			@whole.contents[ii].beNormal()
		return
	if name == "justify"   // doCMDu
		var list = ['left', 'full', 'center', 'right', 'left']
		var jj = list.indexOf(this.justification)		// 1-order
		this.justification = list[jj]		// implicit +1
		return
	if name == "justifyLeft"
		this.justification = "left"
		return
	if name == "justifyCenter"
		this.justification = "center"
		return
	if name == "justifyRight"
		this.justification = "right"
		return
	if name == "justifyFull"
		this.justification = "full"
		return
	if name == "justifyDistributed"
		// to do
		return
	if name == "superscript"   // up
		var verticalRatio = 1.33
	if name == "subscript"   // down
		verticalRatio = 0.33
	if verticalRatio
		for ii in ((@selection.first()).to(@selection.last() -2))
			var letBox = @whole.contents[ii]
			if letBox.stdPivotRatio	// currently sub or super
				letBox.pivotRatio(letBox.stdPivotRatio)
				delete letBox.stdPivotRatio
			else
				var pr = letBox.pivotRatio()
				letBox.stdPivotRatio = pr
				letBox.pivotRatio(P(pr.x(), verticalRatio))	//up or down
		return

	Transcript.show("(MessageSet openMessageList: {'KSTextLayout textAction:'} name: 'Need action for: ".concat(name.concat("')"))).cr()! !

!KSTextLayout methodsFor: 'key commands' stamp: 'ael 4/1/2013 17:38'!
textActionInteractive = (name, event) ->
//  Handle actions that depend on knowing the widget/location from which launched

	if name == "fontChoose"
		var list = ([#'selectionToFont', b] for b in KSFamily.families().keys())
		var menu = @whole.createMenu( list, this)
		KSBox._invokeMenu_near_for(menu, event.position, @whole)
		return
	if name == "chooseFontSize"
		var sz = this.chooseFontSize(event)
		return
	if name == "selectTextColor"
		var initialColor = this.firstInSelection().font.currentValue().fill() ? Color.black()
		@whole.topContainer().invokeColorPicker(event.position + P(30, 0), initialColor, this, (target, color) -> target.selectionToColor(color))
		return
	if name == "selection hiLiteColor.  Later allow permanent boxed text"
		@whole.topContainer().invokeColorPicker(event.position + P(30, 0), this.selectionColor, this, (target, color) ->
			target.selectionColor = color
			target.installSelection())
		return

	Transcript.show("(MessageSet openMessageList: {'KSTextLayout textActionInteractive:with:'} name: 'Need action for: ".concat(name.concat("')"))).cr()! !

!KSTextLayout methodsFor: 'replace text' stamp: 'tk 1/23/2013 10:53'!
addAll = (stringOrArray) ->
	//Store the string of text (or array of Boxes) into my field, appending at the end.  Ignore the selection.  Set selection to the end.
	for cc in stringOrArray
		if cc.isCharacter()
			this.insertChar(cc)
		else
			@whole.addLast(cc)! !

!KSTextLayout methodsFor: 'replace text' stamp: 'yo 8/28/2013 14:41'!
addAllOpt = (stringOrArray) ->
	//Store the string of text (or array of Boxes) into my field, appending at the end.  Ignore the selection.  Set selection to the end.
	for cc in stringOrArray
		if cc.isCharacter()
			this.insertCharOpt(cc)
		else
			@whole.addLast(cc)! !

!KSTextLayout methodsFor: 'replace text' stamp: 'yo 8/29/2013 16:10'!
insertChar = (char) ->
	// General way to insert a character.  Selection must already have size 0.    To act on a control character instead, define a message with name charTypedX. i.e. charTypedControlBS

	if @selection.size() > 2 
		this.do08()	// "delete the old selection"

	var b = KSBox._withChar_inFont(char, @whole.fontNearest(@selection.first() + 1))
	if @whole.optimizedField
		b.beOptimizedGlyph()
	@whole.addAfterIndex(b, @selection.last() -1 -1)
	this.selection.set((@selection.first() +1).to(@selection.first() +2))! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 2/22/2013 17:49'!
firstInSelection = () ->
// return the first letter box of the selection, or the letter after the cursor, or nil

	var fIndex = @selection.first() +1
	if fIndex > @whole.contents.size()
		fIndex = fIndex -1
		if fIndex > @whole.contents.size()
			return nil
	if fIndex < 1
		return nil
	return @whole.contents[fIndex -1]! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 2/27/2013 15:35'!
handleButtonDown = (buttonEvent) ->
	// "What letter was clicked on?  Which side?  Start selection there."

	if @isReadOnly
		return this
	buttonEvent.hand.keyboardFocus(@whole)
	buttonEvent.hand.focus(@whole)
	this.whole.pointerMotion.dormant(false)
	this.whole.buttonUp.dormant(false)
	if @whole.isEmpty()
		this.selectionAnchor = 1
		var triple = [nil, nil, true]
	else
		// Click in a letter. 
		var letterIP = if this.selectionEmpty() then this.selectionAnchor else nil
		var pt = @whole.localPointFor(buttonEvent.position)
		triple = this.letterNearest(pt)
		this.selectionAnchor = triple[1]		// index of letter  
		if pt.x() - triple[0].left() > (triple[0].width() / 2)
			this.selectionAnchor = this.selectionAnchor + 1

		if letterIP == this.selectionAnchor 
			return this.selectWord(this.selectionAnchor)

	this.selection.set((this.selectionAnchor - 1).to(this.selectionAnchor))
	this.caretAtLineEnd = !!triple[2]
	this.installSelection()! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 2/22/2013 16:01'!
handlePointerMotion = (motionEvent) ->
	// "Change the selectin based on where we move.  Before or after anchor"

	if @whole.isEmpty()
		return
	var pt = @whole.localPointFor(motionEvent.position)
	var triple = this.letterNearest(pt)  //[letterBox, index, isInALetter]
	if !!triple[0] 
		return 
	if !!triple[1] 
		return 
	if pt.x() - triple[0].left() > (triple[0].width() / 2)
		triple[1] = triple[1] + 1
	if this.selectionAnchor < triple[1]		// index of letter  
		this.selection.set((this.selectionAnchor - 1).to(triple[1]))
	else
		this.selection.set((triple[1] -1).to(this.selectionAnchor))
	this.caretAtLineEnd = !!triple[2]
	this.installSelection()


	// handle clicking outside all letters but in field.  Must find right line.! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 2/27/2013 10:55'!
install3Selections = () ->
	// "Create rectangles for selection on start line, selection of whole lines, and selection on end line. Place them in the background.  Mark with property selection."

	var letter1 = @whole.contentsAt(@selection.first() + 1)
	var letter2 = @whole.contentsAt(@selection.last() - 1)
	var p1 = P(letter1.left(), letter1.lineTop())
	if letter1.pivotPosition().y() ~= letter2.pivotPosition().y()  // nearly equal
		var x2 = letter2.right()
	else
		var x2 = @whole.rightAtY(letter1.bottom()) - this.rightMargin
	var p2 = P(x2, (p1.y() + letter1.lineSkip()))
	this.installSelectionBox(p1.corner(p2))

	if letter2.top() > letter1.bottom()
		p1 = P(@whole.leftAtY(letter1.bottom()) + this.leftMargin, p2.y())
		p2 = P(@whole.rightAtY(letter2.top()) - this.rightMargin, letter2.lineTop())
		this.installSelectionBox(p1.corner(p2))
	if !!(letter1.pivotPosition().y()._perform_with(#'=?', letter2.pivotPosition().y()))
		p1 = P(@whole.leftAtY(letter1.top()) + this.leftMargin, letter2.lineTop())
		p2 = P(letter2.right(), p1.y() + letter2.lineSkip())
		this.installSelectionBox(p1.corner(p2))! !

!KSTextLayout methodsFor: 'selection' stamp: 'yo 2/27/2013 22:36'!
installCaret = () ->
	// "Put the caret object in the right place in the background"
	// Later:  If no prev char, or prev char is return 0@lineHeight
	// 	else rt of prev char  

	if !!this.caret
		this.caret = this.createCaret()

	@whole.addAsBackgroundParts(this.caret)
	// "Four cases."
	// "1. no text"
	if @whole.isEmpty()
		this.caret.height(this.font.lineSkip())
		return this.caret.pivotPosition(P(this.leftMargin , this.font.height()))

	// "2. Insertion point before first char"
	if (@selection.first() == 0)
		var c = @whole.contents[@selection.first()]	// "letter after insertion point"
		this.caret.pivotPosition(P(c.left(), c.pivotPosition().y()))
		if c.font.currentValue()
			var h = (c.localBoundsToGlobalNoRound((P(0, 0).corner(P(0, c.font.currentValue().lineSkip()))))).height()
		else
			h = c.bounds().height()
		return this.caret.height(h)

	// "3. Insertion point between letters"
	if (@selection.first() < @whole.contentsSize())
		c = @whole.contents[@selection.first()]		// "letter after insertion point"
		var prev = @whole.contents[@selection.first() -1]
		if prev.font.currentValue()
			var prevHt = prev.font.currentValue().lineSkip()
		else
			prevHt = prev.height()
		this.caret.height(prevHt.max(c.height()))
		if this.caretAtLineEnd
			c = c.predecessor()
			this.caret.pivotPosition(P(c.right(), c.pivotPosition().y()))
		else
			this.caret.pivotPosition(P(c.left(), c.pivotPosition().y()))
		return 
	// "4. Insertion point after last letter"
	// "(selection first >= whole contents size) ifTrue: "
	c = @whole.last()
	var pt = P(c.right(), c.pivotPosition().y())
	if c.font.currentValue()
		h = c.localBoundsToGlobalNoRound(P(0, 0).corner(P(0, c.font.currentValue().lineSkip()))).height()
		if c.isNewline() // "return is on next line"
			pt = P((@whole.leftAtY(pt.y() + h) + this.leftMargin) , pt.y() + h)
	else
		h = c.bounds().height()
	this.caret.height(h)
	this.caret.pivotPosition(pt)! !

!KSTextLayout methodsFor: 'selection' stamp: 'yo 1/31/2013 14:37'!
installSelection = () ->
	// "Remove the old selection, and decide to call for selection or insertion point.  Create the selection objects and put them into background parts."

	@whole.removeBackPartsSuchThat((pp) -> pp.selection)
	if @whole.showSelection
		if this.selectionEmpty()
			this.installCaret()
		else
			this.install3Selections()! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 1/29/2013 16:41'!
installSelectionBox = (my) ->
	// "Create rectangles for selection on start line, selection of whole lines, and selection on end line. Place them in the background.  Mark with property selection."

	var bb = KSBox._extent_fill(my.extent(), this.selectionColor)
	bb.selection = true
	bb.pivotRatio(P(0, 0))
	bb.pivotPosition(my.origin())
	@whole.addAsBackgroundParts(bb)! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 2/11/2013 09:57'!
letterNearest = (fieldPoint) ->
	// "What letter was clicked on? [letter, index, clickIsInBox] If none, which was the closest.  Later, which line was it on?"

	var minDist = 100000000
	var minLetter = undefined		// box
	var minIndex = undefined
	var highestBottomY = 10000
	var highestBottom = undefined		// box
	var highestBottomIndex = undefined
	var highestBottomBaseLine = 10000
	for index in [1...@whole.contents.size()]
		var bx = @whole.contentsAt(index)
		if bx.bounds().includesPoint(fieldPoint)
			return [bx, index, true]
		var dist = bx.bounds().center().squaredDistanceTo(fieldPoint)
		if dist < minDist
			minLetter = bx
			minDist = dist
			minIndex = index
		if bx.bottom() > fieldPoint.y()  // same line?
			if bx.bottom() < highestBottomY
				highestBottomY = bx.bottom()
				highestBottom = bx
				highestBottomIndex = index
				highestBottomBaseLine = bx.pivotPosition().y()
		if highestBottomBaseLine + 0.1 > bx.pivotPosition().y()
				highestBottom = bx		// last in this line
				highestBottomIndex = index

	// outside any point, return letter on sameline, or closest
	if highestBottom.right() < fieldPoint.x()
		// end of line
		return [highestBottom, highestBottomIndex, false]
	else
		return [minLetter, minIndex, true]! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 2/1/2013 17:14'!
replaceSelection = (glyphBox) ->
	//  "General way to insert a character that is incased in a box."

	if @selection.size() > 2 
		this.do08()  	// "delete the old selection"
	@whole._add_afterIndex(glyphBox, this.selection.first() + 1)
	this.selection.set((@selection.first() +1).to(@selection.first() +2))! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 2/8/2013 12:37'!
selectWord = (index) ->
	//  "Find the left and right of the current word.  Index is letter after insertion point."

	var ll = index-1
	var rr = index
	for left in [(index - 1)...0] by -1
		ll = left
		if left == 0
			break
		if @whole.contents[left-1].isWhiteSpace()
			break
	var max = @whole.contents.size()+1
	for right in [index...max]
		rr = right
		if right == max
			break
		if @whole.contents[right-1].isWhiteSpace()
			break
	this.selection.set(ll.to(rr))
	this.installSelection()! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 3/20/2013 19:10'!
selectionAsString = () ->
	// Return a string for the text in the selection
	
	return (((@selection.first() + 1).to(@selection.last() -1)).collect((ii) ->
		Character.value(@whole.contents[ii-1].unicode()))).as(String)! !

!KSTextLayout methodsFor: 'selection' stamp: 'yo 1/31/2013 14:07'!
selectionEmpty = () ->
	// "Need this since Interval includes the start and stop (size 2), and selection only includes the elements between the start and stop.  1-order numbers"

	return @selection.size() <= 2! !

!KSTextLayout methodsFor: 'selection' stamp: 'tk 2/8/2013 12:16'!
textReplaceSelection = (aString) ->
	//  "Convert an ascii string to be in my contents as KSBoxes with letter glyphs.  Replace only the selection."

	for char in aString
		this.insertChar(char)! !
