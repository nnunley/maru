StringHolder subclass: #KSEventStreamInspector
	instanceVariableNames: 'object value version selectionIndex startUpTime selectionUpdateTime running'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Tools'!

!KSEventStreamInspector commentStamp: 'ael 4/2/2012 16:17' prior: 0!
Instance Variables
	object					the main KSObject being inspected

	lastSelectedStream	Symbol - the stream name last explicitly selected by the user
	lastSelectedTrace		WWorld - the trace entry last explicitly selected by the user 

	selectionIndex			Integer - the index of the currently selected stream

	traceIndex				Integer - the index of the currently selected trace step
	traces					OrderedCollection - the worlds in which we have trace steps for this object

	lastValue				<Object> - the last value used to derive the string shown in the value pane

	running					Boolean - whether the KSObject should be re-evaluated at each inspector step
	selectionUpdateTime	Integer - number of ms used in the most recent derivation of selectionValue!

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 9/6/2013 16:30'!
acceptSource: aText 
	self selectionKey
		ifNil: [self eval: aText asString]
		ifNotNil: [:key |
			version = 2 ifTrue: [
				object ksAt: key put: (self eval: key, ' <- ', aText asString).
			] ifFalse: [
				object ksAt: key put: (object eval: aText asString).
			].
			(object at: key) isEventStream ifTrue: [
				(object at: key) setLastTime: -1]].
	self refreshView! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 9/6/2013 16:14'!
acceptValue: aText 
	"note that the text may end with a comment"
	| valString |
	self selectionKey
		ifNil: [self refreshView]		"nothing selected; wipe out the change"
		ifNotNil: [:key |
			valString := aText asString.
			(object at: key asKSKey) set: (self eval:  valString)].! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 11:03'!
fieldList
	^ self keysArray collect: [:aSymbol | aSymbol asString].! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 6/6/2012 11:27'!
keysArray
	^ (object ksLocalKeys reject: [:e | e beginsWith: '_']) sorted.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 10:26'!
running
	^ running! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 10:26'!
running: aBoolean
	running := aBoolean.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 10:26'!
selection
	"Return current selected formula, or the environment if unselected."
	^ self selectionKey
		ifNil: [object] "Deselected"
		ifNotNil: [ :key | object at: key].! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 10:26'!
selectionIndex
	^ selectionIndex.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 11:03'!
selectionKey
	"Return selected key (a symbol), or nil if deselected."
	selectionIndex = 0 ifTrue: [^ nil]. "Deselected"
	^ self keysArray at: selectionIndex.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 9/6/2013 16:21'!
selectionSource
	| selection |
	selectionIndex = 0 ifTrue: [^ self summarySource]. "Deselected"

	selection := self selection.
	selection isEventStream ifTrue: [
		selection version = 2 ifFalse: [
			^ '$$(', selection code, ')']
		ifTrue: [
			^ selection code]].

	(selection isMemberOf: KSClosure)
		ifTrue: [^ selection source].
	^ selection printString! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 7/5/2012 22:52'!
selectionValue
	| text |
	selectionUpdateTime := [
		text := [selectionIndex = 0
			ifTrue: [self summaryValue] "Deselected"
			ifFalse: [(self selection currentValue) printStringLimitedTo: 5000]]
						on: Error
						do: [text := self printStringErrorText.
							text
								addAttribute: TextColor red
								from: 1
								to: text size.
							text]] timeToRun.
	^ text! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 10:27'!
source
	^ contents! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 10/22/2012 11:28'!
stepAt: millisecondClockValue in: aWindow
	startUpTime ifNil: [startUpTime := millisecondClockValue].
	running
		ifTrue: [object sortAndEvaluateAt: (Time milliseconds: millisecondClockValue since: startUpTime)].
	self updateContents.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 10:27'!
stepTimeIn: aSystemWindow
	^ (selectionUpdateTime ifNil: [0]) * 10 max: 200.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 9/6/2013 16:22'!
summarySource
	| writer |
	writer := '' writeStream.
	self keysArray do: [ :key |
		| selection |
		selection := object at: key.
		writer nextPutAll: (selection isEventStream
			ifTrue: [
				selection version = 2 ifFalse: [
					'this.', key, ' = $$(', selection code, ')'
				] ifTrue: [
					key, ' <- ', selection code]]
			ifFalse: ['this.', key, ' = ', selection printString]).
		writer cr].
	^ writer contents.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 7/5/2012 22:52'!
summaryValue
	| writer |
	writer := '' writeStream.
	self keysArray do: [ :key |
		| selection |
		selection := object at: key.
		writer nextPutAll: key asString.
		writer nextPutAll: ' = '.
		writer nextPutAll: (selection isEventStream
			ifTrue: [(selection currentValue) printString]
			ifFalse: [selection printString]).
		writer cr].
	^ writer contents.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 10:28'!
toggleIndex: anInteger
	"anInteger is the index of selected item, or zero if deselected."
	selectionIndex := anInteger.
	self updateContents.	
	self changed: #selection.
	self changed: #selectionIndex.! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 6/6/2012 15:32'!
updateContents
	| newValue newSource |
	newValue := self selectionValue.
	newSource := self selectionSource.
	newSource = contents ifFalse: [
		contents := newSource.
		self changed: #source].	
	newValue = value ifFalse: [
		value := newValue.
		self changed: #value].! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 6/6/2012 13:47'!
value
	^ value! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 9/6/2013 16:04'!
version: aNumber
	version := aNumber! !

!KSEventStreamInspector methodsFor: 'accessing' stamp: 'yo 3/29/2012 10:28'!
wantsSteps
	^ true.! !

!KSEventStreamInspector methodsFor: 'evaluation' stamp: 'yo 9/6/2013 16:11'!
eval: aString
	^ object perform: (version = 2 ifFalse: [#eval:] ifTrue: [#eval2:]) with: aString asString! !

!KSEventStreamInspector methodsFor: 'evaluation' stamp: 'yo 9/6/2013 16:19'!
evalKS: aString ifFail: failBlock
	| result |
	result := [self eval: aString] on: Error do: failBlock.
	self refreshView.	
	^result! !

!KSEventStreamInspector methodsFor: 'evaluation' stamp: 'yo 6/6/2012 14:55'!
ksDoItReceiver
	^self! !

!KSEventStreamInspector methodsFor: 'evaluation' stamp: 'yo 1/10/2013 22:17'!
ksDoItWWorld
	^ nil! !

!KSEventStreamInspector methodsFor: 'initialize-release' stamp: 'yo 9/6/2013 16:19'!
initialize
	selectionIndex := 0.
	running := false.
	version := 1.! !

!KSEventStreamInspector methodsFor: 'initialize-release' stamp: 'yo 3/29/2012 10:25'!
object: anObject
	object := anObject.! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 3/29/2012 11:03'!
addEntry
	| newKey aKey |
	newKey := UIManager default request: 'Enter a new name'.
	newKey isEmpty ifTrue: [^self].
	aKey := newKey asSymbol.
	object at: aKey put: nil.
	selectionIndex := self keysArray indexOf: aKey.
	self refreshView.! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 3/29/2012 10:25'!
exploreSelection
	self selection explore.! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 6/6/2012 15:15'!
fieldListMenu: aMenu
	aMenu addList: #(
		('inspect (i)'				ksInspectSelection)
		('basic inspect (i)'		inspectSelection)
		('explore (I)'			exploreSelection)
		-
		('refresh view'			refreshView)
		('toggle timer'			toggleTimer)
		-
		('add key'				addEntry)
		('remove'				removeSelection)
	).
	^ aMenu.! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 3/29/2012 10:25'!
inspectSelection
	self selection inspect.! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 6/6/2012 15:21'!
inspectorKey: aChar from: view
	aChar == $i ifTrue: [^ self selection inspect].
	aChar == $I ifTrue: [^ self selection explore].
	^ self arrowKey: aChar from: view! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 1/25/2013 15:52'!
ksInspectSelection
	| sel |
	sel := self selection.
	sel isEventStream ifTrue: [sel := sel currentValue].
	(sel isKindOf: KSProtoObject) ifTrue: [
		(self class new object: sel) open]
	ifFalse: [
		sel inspect]! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 3/29/2012 10:26'!
refreshView
	self changed: #fieldList.
	self changed: #selectionIndex.
	self changed: #source.
	self changed: #value.! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 6/6/2012 15:24'!
removeSelection
	selectionIndex = 0 ifTrue: [^ self changed: #flash].
	object removeKey: (self keysArray at: selectionIndex).
	selectionIndex := 0.
	self refreshView.! !

!KSEventStreamInspector methodsFor: 'menu' stamp: 'yo 3/29/2012 10:28'!
toggleTimer
	self running: self running not.! !

!KSEventStreamInspector methodsFor: 'toolbuilder' stamp: 'yo 6/6/2012 15:04'!
buildEvalPaneWith: builder
	^ (builder pluggableTextSpec new) 
		model: self;
		getText: nil; 
		setText: nil;
		selection: #contentsSelection! !

!KSEventStreamInspector methodsFor: 'toolbuilder' stamp: 'yo 6/6/2012 14:26'!
buildFieldListWith: builder
	^ (builder pluggableListSpec new) 
		model: self;
		list: #fieldList; 
		getIndex: #selectionIndex; 
		setIndex: #toggleIndex:; 
		menu: #fieldListMenu:; 
		keyPress: #inspectorKey:from:! !

!KSEventStreamInspector methodsFor: 'toolbuilder' stamp: 'yo 6/6/2012 14:27'!
buildFormulaPaneWith: builder
	^ (builder pluggableTextSpec new) 
		model: self;
		getText: #source; 
		setText: #acceptSource:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:! !

!KSEventStreamInspector methodsFor: 'toolbuilder' stamp: 'yo 6/6/2012 14:27'!
buildValuePaneWith: builder
	^ (builder pluggableTextSpec new)
		model: self;
		getText: #value; 
		setText: #acceptValue:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:! !

!KSEventStreamInspector methodsFor: 'toolbuilder' stamp: 'yo 6/6/2012 15:19'!
buildWith: builder
	| windowSpec window evalPane |
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 0.3@0.8)  -> [self buildFieldListWith: builder].
		(0.3@0 corner: 1@0.5) -> [self buildFormulaPaneWith: builder].
		(0.3@0.5corner: 1@0.8) -> [self buildValuePaneWith: builder].
		(0@0.8 corner: 1@1) -> [self buildEvalPaneWith: builder].
	}.
	window := builder build: windowSpec.
	evalPane := window paneMorphs detect: [:m | (m isKindOf: PluggableTextMorph)
				and: [m getTextSelector == nil]] ifNone: [nil].
	evalPane askBeforeDiscardingEdits: false.
	evalPane textMorph setProperty: #editorClass toValue: KScriptEditor.
	evalPane textMorph installEditorToReplace: nil.
	^ window! !

!KSEventStreamInspector methodsFor: 'toolbuilder' stamp: 'yo 3/29/2012 10:26'!
open
        ^ToolBuilder open: self label: object defaultLabelForInspector! !

!KSEventStreamInspector class methodsFor: 'examples' stamp: 'yo 6/6/2012 15:31'!
example1
	"KSEventStreamInspector example1"
	| obj |
	obj := KSObject new eval: 
'this.d = $$(@t - @s)
this.e = $$(@d.collectE(0, (x, y) -> x + y))
this.t = $$(timerE(1000))
this.s = 0
this
'.
	self new object: obj;
		running: true;
		open.
	^ obj.! !
