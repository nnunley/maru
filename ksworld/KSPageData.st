KSObject subclass: #KSPageData
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSPageData commentStamp: 'tk 3/20/2013 09:47' prior: 0!
A KSPageData is a datastructure for a page of a KSStack.

Instance Variables (held as Javascript like properties)

background = box that is this page.  Shared by all pages of this background.

pageBoxes = array of boxes that go on this page only.  They know their positions.  Each has pageSpecific = true.

If background box has textBox.dbjrDataGetter, then call it textContentsX
textContentsX = a copy of the contents of the textBox as it appears on this page.
	Stored as the contents of a dummy box.!

!KSPageData methodsFor: 'all' stamp: 'yo 2/21/2013 12:15'!
addPageSpecific = () ->
	return this.addPageSpecificTo(this.background)! !

!KSPageData methodsFor: 'all' stamp: 'yo 2/21/2013 13:42'!
addPageSpecificTo = (aBackground) ->
	// "take box in pageBoxes, and add them to the page."
	for bb in this.pageBoxes
		aBackground.addLast(bb)
	this.loadPageTextFrom(aBackground)! !

!KSPageData methodsFor: 'all' stamp: 'yo 2/8/2013 18:18'!
allContentsAndPagesInto: aSet
	self associationsDo: [:assoc |
		assoc key == #pageBoxes ifTrue: [
			assoc value do: [:v | v allContentsAndPartsAndPagesInto: aSet]]
		ifFalse: [
			assoc value allContentsAndPartsAndPagesInto: aSet]].! !

!KSPageData methodsFor: 'all' stamp: 'yo 2/21/2013 11:26'!
loadPageText = () ->
	return this.loadPageTextFrom(this.background)! !

!KSPageData methodsFor: 'all' stamp: 'yo 2/21/2013 12:15'!
loadPageTextFrom = (aBackground) ->
	// "take text from property fldNameContents in pageData and put it into aBackground."
	for textBox in aBackground.contents
		if !!textBox.pageSpecific
			if textBox.dbjrDataGetter
				// "later remember the selection in pageData.  #fieldNameSelection"
				textBox.layout().selection.set(0.to(1))
				// we need to watch out the potential non-pureness issue here.  When a box is added to textBox from the data, the box will be removed from the box at this[textBox.dbjrDataGetter]
				var txt = this[textBox.dbjrDataGetter].contents.asArray()
				textBox.removeAll()
				if txt
					textBox.addAll(txt)! !

!KSPageData methodsFor: 'all' stamp: 'yo 2/21/2013 12:13'!
removePageSpecific = () ->
	return this.removePageSpecificFrom(this.background)! !

!KSPageData methodsFor: 'all' stamp: 'yo 2/21/2013 12:07'!
removePageSpecificFrom = (aBackground) ->
	this.pageBoxes = []
	for mm in aBackground.contents
		if mm.pageSpecific
			this.pageBoxes.addLast(mm)
		else
			if mm.dbjrDataGetter
				// the text
				var dummyBX = KSBox.new()
				dummyBX.layout(KSTextLayout.new())
				dummyBX.addAll(mm.contents.asArray())
				this[mm.dbjrDataGetter] = dummyBX
	for pm in this.pageBoxes
		aBackground.remove(pm)! !
