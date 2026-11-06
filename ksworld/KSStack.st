KSUserEventHandler subclass: #KSStack
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSStack methodsFor: 'editor support' stamp: 'tk 3/6/2013 14:30'!
createThumbnails = (width) ->
	// hibernate the current page
	var oldData = this.pageArray[@pageIndex-1]
	oldData.removePageSpecific()    // "includes storing text"
	
	var result = []
	for ind in [1...this.pageArray.size()]
		// Make a new Box as it it is the background page for the pageData
		var pageData = this.pageArray[ind-1]
		var pageBox = pageData.background	//.copy()
		// no page-specific boxes or text are present now
		pageData.addPageSpecificTo(pageBox)
		pageBox.doLayout()
		var thumb = pageBox.thumbnailScale(width / pageBox.width())
		pageData.removePageSpecific()
		thumb.pageIndex = ind
		result.push(thumb)
	
	// restore the current page
	// assume background did not get deleted or translated 
	oldData.addPageSpecific()

	return result! !

!KSStack methodsFor: 'editor support' stamp: 'yo 3/4/2013 19:56'!
samePages = (oldArray, newArray) ->
	if oldArray.size() !!= newArray.size()
		return false
	for ind in [0..oldArray.size()]
		if oldArray[ind] !!== newArray[ind]
			return false
	return true! !

!KSStack methodsFor: 'enumeration' stamp: 'yo 2/8/2013 17:23'!
allContentsAndPagesInto: aSet
	(self at: #pageArray) do: [:p | p allContentsAndPagesInto: aSet].
	aSet add: (self at: #baseBackground).! !

!KSStack methodsFor: 'examples' stamp: 'tk 4/2/2013 12:12'!
exampleAdd2Fields = () ->
	// "Add two fields and two backgrounds to a basic stack"
	// page 1, bk1:  green oval, next page button, page 2 that and red oval, page 3 bk2, red box, button."
	this.exampleNoFields()		//set u p a stack
	this.showPageNumber(1)
	var stackBox = @whole
	stackBox.name("Stack2Fields")
	var pageBox = this.pageBox()

	var fldBox = @whole.factory().newTextField()
	pageBox.add(fldBox)
	this.bePerPageText(fldBox)
	fldBox.fill(Color.white())
	fldBox.extent(P(200, 300))
	fldBox.borderWidth(1)
	fldBox.name('fld1')
	fldBox.topLeft(P(10, 120))
	fldBox.textContents('Field 1, Page 1, \BK 1\\One One'.withCRs())

	fldBox = @whole.factory().newTextField()
	fldBox.extent(P(200, 150))
	fldBox.textContents('Field 2, Page 1, \BK 1'.withCRs())
	fldBox.borderWidth(1)
	fldBox.name('fld2')
	pageBox.add(fldBox)
	this.bePerPageText(fldBox)
	fldBox.topLeft(P(250, 20))

	this.showPageNumber(2)
	pageBox = this.pageBox()  // is the same as page 1
	fldBox = pageBox.atName('fld1')
	var txt = 'Field 1, Page 2, \BK 1\\Two Two'.withCRs()
	fldBox.textContents(txt)

	fldBox = pageBox.atName('fld2')
	txt = 'Field 2, Page 2, \BK 1'.withCRs()
	fldBox.textContents(txt)

	fldBox =  @whole.factory().newTextField()
	fldBox.textContents('Page specific field\\'.withCRs())
	fldBox.extent(P(200, 150))
	fldBox.name('specificFld')
	pageBox.add(fldBox)
	this.beInPage(fldBox)
	fldBox.topLeft(P(250, 190))
	fldBox.borderWidth(1)
	this.showPageNumber(1)
	return this! !

!KSStack methodsFor: 'examples' stamp: 'ael 3/4/2013 19:12'!
exampleNoFields = () ->
	//"Add a bunch of shapes and two backgrounds to a basic stack.  Page box (background costume) is within a stack box.  This is a handler.
	// page 1, bk1:  green oval, next page button, page 2 that and red oval, page 3 bk2, red box, button."
	//  self exampleNoFields: self    
	var stackBox = @whole
	stackBox.name("StackNoFields")
	var pageBox = this.pageBox()
	var pageBox3 = pageBox.copy()
	pageBox.name('FirstBkgnd')

	var box1 = KSBox.withShape(KSShape.new().elements([
		GeziraPath.oval(P(0, 0).corner(P(50, 50))).fill(Color.green())])) // "green"
	pageBox.add(box1)
	box1.borderWidth(1)
	box1.name('oval1')
	box1.topLeft(P(10, 20))

	this.newPageHere()
	pageBox = this.pageBox()  // "will be the same"
	var box2 = KSBox.withShape(KSShape.new().elements([
		GeziraPath.oval(P(0, 0).corner(P(50, 50))).fill(Color.red())])) //  "red"
	pageBox.add(box2)
	box2.borderWidth(1)
	box2.name('oval2')
	box2.topLeft(P(150, 20))
	this.beInPage(box2) // "page specific"

	var button =  stackBox.factory().newButton(" BK1's Next Page -> ") // "in background"
	button.fill(Color.yellow())
	//button borderWidth: 1.
	pageBox.add(button) // "in background"
	button.foo = $$(@fire.mapE((ev) -> ev.handler.__stackHandler__.showPageInc(1)))
	button.topLeft(P(100, 450))

	this.newPage(pageBox3) // "new background"
	var ps = KSBox._extent_fill(P(20, 20), Color.red())
	ps.borderWidth(1)
	pageBox3.add(ps)
	ps.topLeft(P(10, 450))
	ps.attachDropAcceptor()

	button =  stackBox.factory().newButton(" BK2's Next Page -> ") // "in background"
	button.fill(Color.yellow())
	pageBox3.add(button) // "in background"
	button.foo = $$(@fire.mapE((ev) -> ev.handler.__stackHandler__.showPageInc(1)))
	button.topLeft(P(100, 450))
	button.borderWidth(1)
	return this! !

!KSStack methodsFor: 'stack' stamp: 'ael 3/5/2013 16:13'!
addNavBarAt = (location) ->
	// "add a navigation bar to the current background.  Default place is bottom center.  location is 'topLeft', etc."

	var nav = KSStack.newNavBar()
	var pageBox = this.pageBox()
	pageBox.addFirst(nav)
	var postSymbol = location ? "bottomCenter"
	if (postSymbol == "bottomCenter")
		nav.topLeft(P(((pageBox.extent().x() - nav.extent().x()) / 2), (pageBox.height() - nav.height() - 1)))

	nav.eval('this.doAction = $$(@itemSelected.mapE((ev) -> 
		@__stackHandler__.navBarAction(ev.handler.actionID)))')

	pageBox.hasNavBar = true! !

!KSStack methodsFor: 'stack' stamp: 'tk 3/4/2013 21:38'!
addNavBarToAll = (location) ->
	// "add a navigation bar to all backgrounds.  Default place (nil) is bottom center.  location is 'topLeft', etc."

	for ind in [1...this.pageArray.size()]
		var pd2 = this.pageArray[ind-1]
		if !!pd2.background.hasNavBar
			this.showPageAt(ind)  // 1-order
			this.addNavBarAt(location)
			// sets pd2.background.hasNavBar = true	! !

!KSStack methodsFor: 'stack' stamp: 'yo 3/4/2013 19:32'!
addPage = (aBackground) ->
	// "Create and install a new page of this background"
	var pgData = KSPageData.new()
	pgData.background = aBackground
	pgData.pageBoxes = []
	this.pageArray.addLast(pgData)
	this.showPageAt(@pageIndex + 1)! !

!KSStack methodsFor: 'stack' stamp: 'tk 3/7/2013 11:19'!
beInBackground = (aBox) ->
	// "make the box be on the background"
	delete aBox.pageSpecific! !

!KSStack methodsFor: 'stack' stamp: 'yo 2/21/2013 19:03'!
beInPage = (aBox) ->
	// "make the box be on this page only"
	aBox.pageSpecific = true! !

!KSStack methodsFor: 'stack' stamp: 'yo 2/21/2013 19:03'!
bePerPageText = (textBox) ->
	// "make the text be in the background and set it up to have different text on each page.  Save the text data in pageData.  Works for the contents of any box, not just text."
	delete textBox.pageSpecific
	textBox.dbjrDataGetter = textBox.name().concat("Contents").asSymbol()! !

!KSStack methodsFor: 'stack' stamp: 'yo 3/4/2013 19:32'!
deleteThisPage = () ->
	// delete the currently showing page.  Show the page after.
	var temp = @pageIndex
	this.showPageAt(temp + 1)
	this.pageArray.removeAt(temp)
	this.showPageAt(temp)! !

!KSStack methodsFor: 'stack' stamp: 'ael 3/5/2013 01:42'!
installTo = (box) ->
	super.installTo(box)
	@whole.removeAll()
	this.pageIndex = this.streamOf(0)    // means there is none.  1-order
	this.pageArray = []
	this.pagesChanged = this.streamOf(undefined)
	this.showBackground = this.streamOf(false)
	this.baseBackground = KSBox._extent_fill(@whole.extent(), Color.white())
	this.baseBackground.name('Page')
	this.baseBackground.attachDropAcceptor()
	this.newPage(this.baseBackground.copy())
	this.pagesChanged = $$(@pageIndex.collectE({newPages: this.pageArray.copy(), pageIndex: @pageIndex}, (new, old) ->
		{oldPages: old.newPages, newPages: this.pageArray.copy(), 
		oldPageIndex: old.pageIndex, pageIndex: new}))! !

!KSStack methodsFor: 'stack' stamp: 'ael 1/22/2013 15:35'!
navBarAction = (name) ->
// A button in the Nav Bar has been pressed, decide what to do
	if (name == "first")
		return this.showPageNumber(1)  // go to first page
	if (name  == "prev")
		return this.showPageInc(-1)  // prev
	if (name == "new")
		return this.newPageHere()  // new page
	if (name == "back")
		return this.showGoBack()  // go back in history
	if (name == "next")
		return this.showPageInc(1)  // next
	if (name == "last")
		return this.showPageNumber(0)  // last! !

!KSStack methodsFor: 'stack' stamp: 'yo 2/21/2013 19:27'!
newPage = (aBackground) ->
	// "Create and install a new page of this background"
	var pgData = KSPageData.new()
	pgData.background = aBackground
	pgData.pageBoxes = []
	this.pageArray._add_beforeIndex(pgData, @pageIndex + 1)
	if (this.pageArray.size() == 1)
		// "very first page"
		@whole.addFirst(aBackground)
		aBackground.topLeft(P(0, 0))   // "Same bounds as stack"
		this.pageIndex.set(1)
	else
		this.showPageAt(@pageIndex + 1)! !

!KSStack methodsFor: 'stack' stamp: 'yo 1/25/2013 00:37'!
newPageHere = () ->
	// "Create and install a new page of the background of the current page"

	this.newPage(this.pageBox())! !

!KSStack methodsFor: 'stack' stamp: 'ael 3/5/2013 01:49'!
oldPageBox = () ->
	return this.pageArray[@pagesChanged.oldPageIndex - 1].background! !

!KSStack methodsFor: 'stack' stamp: 'yo 2/21/2013 13:46'!
pageBox = () ->
	// "The KSBox of this page (not the stack.  It is a separate box)"
	return this.pageData().background! !

!KSStack methodsFor: 'stack' stamp: 'yo 2/8/2013 11:26'!
pageData = () ->
	// of the current page

	return this.pageArray[@pageIndex-1]! !

!KSStack methodsFor: 'stack' stamp: 'yo 2/8/2013 11:26'!
pageNAfterOrNil = (delta) ->
	// "return the page object (do not show it) that is delta after the current page"

	if @pageIndex + delta <= 0 
		return nil
	if @pageIndex + delta > this.pageArray.size()
		return nil
	return this.pageArray[@pageIndex - 1 + delta]! !

!KSStack methodsFor: 'stack' stamp: 'yo 2/21/2013 14:31'!
setupPageData = (pageData) ->
	// Make a new Box as it it is the background page for the pageData
	var aBackground = pageData.background.copy()
	pageData.removePageSpecificFrom(aBackground)
	pageData.addPageSpecificTo(aBackground)
	return aBackground! !

!KSStack methodsFor: 'stack' stamp: 'yo 2/21/2013 19:06'!
showPageAt = (newIndexIn) ->
	// turn to a page and show it.  newIndex is 1-based.
	var newIndex = (newIndexIn - 1) % this.pageArray.size() + 1  // 1-order
	var newData = this.pageArray[newIndex-1]
	var oldData = this.pageArray[@pageIndex-1]
	oldData.removePageSpecific()    // "includes storing text"
	this.pageIndex.set(newIndex)
	if !!(oldData.background === newData.background)
		// "change backgrounds"
		oldData.background.delete()
		@whole.addFirst(newData.background)
		newData.background.topLeft(P(0,0)) // "same position as stack"
	@whole.extent(newData.background.extent())		// "match page size"
	newData.addPageSpecific()! !

!KSStack methodsFor: 'stack' stamp: 'yo 3/4/2013 19:33'!
showPageInc = (delta) ->
	// "turn delta pages in the stack"
	this.showPageAt(@pageIndex + delta)! !

!KSStack methodsFor: 'stack' stamp: 'yo 3/4/2013 19:33'!
showPageNumber = (newIndexIn) ->
	this.showPageAt(newIndexIn)! !

!KSStack methodsFor: 'stack' stamp: 'ael 3/14/2013 00:20'!
stackAction = (name, theSelectedDocBox) ->
	// Process an action that was requested from a button in the Nav Bar or a doc editor's bubble.
	if name == "first"
		return this.showPageNumber(1)  // go to first page
	if name  == "prev"
		return this.showPageInc(-1)  // prev
	if name == "new"
		return this.newPageHere()  // new page
	if name == "back"
		return this.showGoBack()  // go back in history
	if name == "next"
		return this.showPageInc(1)  // next
	if name == "last"
		return this.showPageNumber(0)  // last
	if name == "delete"
		return this.deleteThisPage()  // delete
		
	if name == "toggle page/background"
		if !!theSelectedDocBox
			return
		if theSelectedDocBox.pageSpecific
			this.beInBackground(theSelectedDocBox)
		else
			this.beInPage(theSelectedDocBox)
		// this.whole.__docEditor__.editSignal.set(true)
		return   // toggle page/background

	if name == 	"copy"
		// to do
		return

	if name == 	"paste"
		// to do
		return

	Transcript.show("(MessageSet openMessageList: {'KSStack stackAction:'} name: 'Need action for: ".concat(name.concat("')"))).cr()! !

!KSStack methodsFor: 'stack' stamp: 'tk 2/19/2013 10:54'!
stackBox = () ->
	// "The outer KSBox of the entire stack"

	return @whole! !

!KSStack class methodsFor: 'instance creation' stamp: 'yo 1/27/2013 18:06'!
exampleNoFields
	^ self newStack exampleNoFields! !

!KSStack class methodsFor: 'instance creation' stamp: 'yo 1/27/2013 18:06'!
exampleWith2Fields
	^ self newStack exampleAdd2Fields! !

!KSStack class methodsFor: 'instance creation' stamp: 'yo 1/27/2013 18:19'!
newStack
	"Return a new box that is the frame around a new stack.  
	KSStack testBasicStack  " 
	
	| stkBox stackHandler |
	stkBox := KSBox extent: 540@620 fill: Color white.
	(stackHandler := self new) installTo: stkBox.	"makes first page"
	stkBox name: 'Stack'.
	^ stackHandler! !

!KSStack class methodsFor: 'navigation bar' stamp: 'yo 1/27/2013 18:10'!
newNavBar
	"Return a navigation bar."
	| nav factory |
	nav := KSBox new.
	nav name: 'navBar'.
	nav fill: Color white.
	nav borderWidth: 1.
	nav beMenuHandler: true with: {}.
	nav layout: KSHorizontalLayout new.
	nav layout inset: 6.
	nav layout at: #space put: 2@0.
	factory := KSFactory default.
	nav setItems: {{'first'. factory iconNamed: 'first'}.
					{'prev'. factory iconNamed: 'prev'}.
					{'new'. factory newLabel: ' new'}.
					{'back'. factory newLabel: ' back '}.
					{'next'. factory iconNamed: 'next'}.
					{'last'. factory iconNamed: 'last'}}.
	^ nav! !
