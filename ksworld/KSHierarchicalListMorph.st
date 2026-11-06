SimpleHierarchicalListMorph subclass: #KSHierarchicalListMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Tools'!

!KSHierarchicalListMorph methodsFor: 'as yet unclassified' stamp: 'ael 5/2/2012 19:44'!
addMorphsTo: morphList from: aCollection allowSorting: sortBoolean withExpandedPaths: expandedPaths atLevel: newIndent
	"replace original method, to handle the use of item paths in deciding which items to expand"
	| priorMorph newCollection firstAddition path |
	priorMorph := nil.
	newCollection := (sortBoolean and: [sortingSelector notNil]) ifTrue: [
		(aCollection asSortedCollection: [ :a :b | 
			(a perform: sortingSelector) <= (b perform: sortingSelector)]) asOrderedCollection
	] ifFalse: [
		aCollection
	].
	firstAddition := nil.
	newCollection do: [:item | 
		priorMorph := self indentingItemClass basicNew 
			initWithContents: item 
			prior: priorMorph 
			forList: self
			indentLevel: newIndent.
		firstAddition ifNil: [firstAddition := priorMorph].
		morphList add: priorMorph.
		path := item pathFromRoot.
		((expandedPaths includes: path) or: [priorMorph isExpanded]) ifTrue: [
			priorMorph isExpanded: true.
			priorMorph 
				addChildrenForList: self 
				addingTo: morphList
				withExpandedPaths: (expandedPaths copyWithout: path).
		].
	].
	^firstAddition
	! !

!KSHierarchicalListMorph methodsFor: 'as yet unclassified' stamp: 'ael 5/2/2012 19:45'!
buildMorphListFrom: aCollection expanded: wereExpanded
	| morphList |

	morphList := OrderedCollection new.
	self 
		addMorphsTo: morphList
		from: aCollection 
		allowSorting: false
		withExpandedPaths: (wereExpanded collect: [ :wr | wr pathFromRoot ])
		atLevel: 0.
	^morphList! !

!KSHierarchicalListMorph methodsFor: 'as yet unclassified' stamp: 'ael 5/7/2012 11:05'!
list: aCollection
	"transfer the selection-maintenance code here (cf. ObjectExplorer>>step), so we can inform the model properly if the selection had to change as a result of the refresh.
	also break out the code for building a wrapper (i.e., morph) list from the code for using that as our scroller's submorphs.
	also put here the code for maintaining - as best we can - the list's scroll position."
	| newMorphList wereExpanded prevScroll vScroll oldSelectionPath |
	(aCollection isNil or: [aCollection isEmpty]) ifTrue: [ scroller removeAllMorphs. ^ self selectedMorph: nil ].

	oldSelectionPath := self selectedMorph ifNotNil: [ :m | m complexContents pathFromRoot ].
	wereExpanded := self currentlyExpanded.
	newMorphList := self buildMorphListFrom: aCollection expanded: wereExpanded.

	prevScroll := scroller offset.
	scroller removeAllMorphs.
	self insertNewMorphs: newMorphList.

	oldSelectionPath
		ifNotNil: [
			self selectionPath: oldSelectionPath.			"try to reinstate the selection"
			self setSelectedMorph: self selectedMorph.	"tell the model what morph is now selected (may be nil)."
			].
		
	"and try to reinstate scroll, bearing in mind that the list might now be shorter"
	vScroll := prevScroll y min: self vLeftoverScrollRange.
	self scrollBy: scroller offset - (prevScroll x @ vScroll).! !

!KSHierarchicalListMorph methodsFor: 'events' stamp: 'ael 5/2/2012 16:41'!
toggleExpandedState: aMorph event: event
	super toggleExpandedState: aMorph event: event.
	(model respondsTo: #listExpansionChanged) ifTrue: [ model listExpansionChanged ]! !

!KSHierarchicalListMorph methodsFor: 'selection' stamp: 'ael 5/15/2012 16:35'!
mouseDown: evt
	| aMorph selectors |
	aMorph := self itemFromPoint: evt position.
	(aMorph notNil and:[aMorph inToggleArea: (aMorph point: evt position from: self)])
		ifTrue:[^self toggleExpandedState: aMorph event: evt]. 
	evt yellowButtonPressed  "First check for option (menu) click"
		ifTrue: [^ self yellowButtonActivity: evt shiftPressed].
	aMorph ifNil:[^super mouseDown: evt].
	"aMorph highlightForMouseDown.			not useful if list is being updated frequently"
	selectors := Array 
		with: #click:
		with: nil
		with: nil
		with: (self dragEnabled ifTrue:[#startDrag:] ifFalse:[nil]).
	evt hand waitForClicksOrDrag: self event: evt selectors: selectors threshold: HandMorph dragThreshold "pixels".! !

!KSHierarchicalListMorph methodsFor: 'selection' stamp: 'ael 5/15/2012 23:14'!
mouseUp: event 
	| aMorph |
	aMorph := self itemFromPoint: event position.
	aMorph ifNil: [^self].
	(aMorph inToggleArea: (aMorph point: event position from: self))
		ifTrue:[^self].			"mouse up after expand/fold" 
	
	"aMorph highlightedForMouseDown ifFalse: [^self].	if list is being updated continuously, this might not be true"
	"aMorph highlightForMouseDown: false."

	model okToChange ifFalse: [^self].
	"No change if model is locked"
	((autoDeselect isNil or: [autoDeselect]) and: [aMorph == selectedMorph]) 
		ifTrue: [self setSelectedMorph: nil]
		ifFalse: [self setSelectedMorph: aMorph].
	Cursor normal show! !

!KSHierarchicalListMorph methodsFor: 'selection' stamp: 'ael 5/7/2012 10:40'!
selectionPath: path
	"Called from outside to request setting a new selection."
	| i wrap |
	path ifNil: [^self selectionIndex: 0].
	
	"look for a wrapper that has the same path"
	i := scroller submorphs findFirst: [:m |
						wrap := m complexContents.
						wrap pathFromRoot = path.
						].
	self selectionIndex: i! !

!KSHierarchicalListMorph methodsFor: 'selection' stamp: 'ael 5/15/2012 16:30'!
setSelectedMorph: aMorph
	"override normal behaviour to set the selection index (through selection:) immediately, rather than have the model update us using the getSelectionSelector"
	| wrap |
	model 
		perform: (setSelectionSelector ifNil: [^self]) 
		with: (wrap := aMorph complexContents).
	self selection: wrap.

 ! !

!KSHierarchicalListMorph methodsFor: 'updating' stamp: 'ael 5/1/2012 19:11'!
update: aSymbol
	aSymbol == #refreshItems
		ifTrue: [
			scroller submorphs do: [ :m | m refreshContents ].
			^self
			].
		
	^super update: aSymbol! !
