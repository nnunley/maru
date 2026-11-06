StringHolder subclass: #KSObjectExplorer
	instanceVariableNames: 'rootObject timeOrigin lastValue selectedFieldWrapper evalLanguage visibleItemDicts decompilations'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Tools'!

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/10/2013 16:57'!
augmentedSource
	"augment with a comment to help the user understand the dependencies"
	| sources obj |
	obj := self selectedObject.

	^String streamContents: [ :str |
		str nextPutAll: contents.
		
		obj isEventStream ifTrue: [
			sources := (obj ksAt: #'__sources__') collect: [ :ref | (ref ref) asString ].
			sources ifNotEmpty: [
				str
					cr;
					nextPutAll: '// sources: '.
				sources do: [ :s | str nextPutAll: s ] separatedBy: [ str space ].
				str cr
				].
			]
		]! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/8/2013 23:17'!
augmentedValueString
	"here we don't have any augmenting to do"
	selectedFieldWrapper ifNil: [ ^'' ].
	
	^lastValue ifNil: [ '' ] ifNotNil: [ lastValue asString ].		"might have been a text"
		! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/8/2013 22:50'!
evalText
	^''! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/8/2013 22:50'!
getFieldSelection
	^selectedFieldWrapper! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/8/2013 22:50'!
ksDoItReceiver
	^self! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/8/2013 22:50'!
selectedObject
	^selectedFieldWrapper ifNotNil: [ selectedFieldWrapper withoutListWrapper ]! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/8/2013 22:50'!
selectionItemName
	^selectedFieldWrapper ifNotNil: [ selectedFieldWrapper itemName ]! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/9/2013 19:01'!
selectionModel
	^selectedFieldWrapper ifNotNil: [ selectedFieldWrapper isRoot ifTrue: [ selectedFieldWrapper withoutListWrapper ] ifFalse: [ selectedFieldWrapper model ] ]! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'yo 1/23/2013 14:44'!
selectionSource
	| obj code |
	(obj := self selectedObject) isEventStream ifTrue: [
		^ self valueOrErrorText: [
			code := obj code.
			obj type == #setter
				ifTrue: [ 'this.streamOf(', code, ')' ]
				ifFalse: [ '$$(', code, ')' ].
			].
		].
		
	(obj isClosure or: [ obj isKindOf: KSClosure ])
		ifTrue: [ ^self decompilationOf: obj ].
	
	^''! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/10/2013 20:04'!
selectionValueString
	"this is sent in various worlds, to discover changes in values over the course of a trace"
	| item selectionPath wrapper |
	selectedFieldWrapper ifNil: [ ^'' ].
	
	selectionPath := selectedFieldWrapper pathFromRoot.
	wrapper := visibleItemDicts at: selectionPath ifAbsent: [ ^'<not found>' ].		"presumably trying to access in a previous trace step where this key did not exist"

	item := wrapper withoutListWrapper.
	item isEventStream ifTrue: [ item := item currentValue ].
	^self valueOrErrorText: [
		(item isKindOf: KSObject)
			ifTrue: [ item ksString ]
			ifFalse: [ item printStringLimitedTo: 5000 ]
		]! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/10/2013 17:01'!
updateContents
	| newValue newSource |
	"we must rebuild the entire field list every step.  the list morph will do its best to maintain the folding state, the selection, and the scroll."

	self fieldListMorph ifNotNil: [ self changed: #fieldList; updateItemDict ].		"always update, as long as we're not still initialising"
	
	"both the value and the source may be texts - e.g., the error text"
	newValue := self selectionValueString.
	newSource := self selectionSource.

	newSource = contents
		ifFalse: [
			contents := newSource.
			self changed: #augmentedSource.
			].
	newValue = lastValue
		ifFalse: [
			lastValue := newValue.
			self changed: #augmentedValueString.
			].! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/8/2013 22:50'!
valueOrErrorText: aBlock
	| text |
	^aBlock
		on: Error
		do: [text := self printStringErrorText.
			text
				addAttribute: TextColor red
				from: 1
				to: text size.
			text]
	! !

!KSObjectExplorer methodsFor: 'accessing' stamp: 'ael 1/8/2013 22:50'!
wantsSteps
	^ true.! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
acceptEval: aText 
	"saving has no meaning, so don't make it look like it does"
	^false! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/10/2013 16:59'!
acceptFormula: aText
	"accept a new definition from the code pane"
	| obj itemName rejectBlock selectionModel |

	rejectBlock := [ self refreshView. ^true ].

	(selectedFieldWrapper isNil or: [ selectedFieldWrapper isRoot ]) ifTrue: [ ^rejectBlock value ]	.

	(obj := self selectedObject) isEventStream ifFalse: [ ^rejectBlock value ].

	selectionModel := self selectionModel.
	(selectionModel isKindOf: KSObject) ifFalse: [ ^rejectBlock value ].

	itemName := self selectionItemName.

	^self
		evalEditBlock: [ selectionModel eval: 'this.', itemName asString, ' = ' , aText asString ]
		onFail: [ self formulaTextMorph flash.  ^false ].! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/29/2013 00:25'!
acceptValue: aText
	"the handling of the text depends on whether the object currently being shown is a KS or Squeak object.
	In addition, if the selected object is a stream the value is treated as the new currentValue for that stream."
	| valString failBlock itemName rejectBlock selectionModel isKSExpr selected value |
	rejectBlock := [ self refreshView. ^true  ].

	"reject if there is no selection, or if the selection is the root item"
	(selectedFieldWrapper isNil or: [ selectedFieldWrapper isRoot ]) ifTrue: [ ^rejectBlock value ].

	selected := self selectedObject.
	isKSExpr := (selected isEventStream ifTrue: [ selected currentValue ] ifFalse: [ selected ]) isKindOf: KSObject.

	valString := aText asString.
	failBlock := [ self valueTextMorph flash.  ^false ].

	selected isEventStream ifTrue: [
		[ value := isKSExpr ifTrue: [ selected eval: valString ] ifFalse: [ Compiler evaluate: valString ] ] on: Error do: [ ^failBlock value ].
		selected set: value.
		selected sync.
		^self
		].
		
	selectionModel := self selectionModel.
	(selectionModel isKindOf: KSObject)
		ifTrue: [
			"evaluate a block that asks the model object to set the appropriate value for the selected itemName."
			itemName := self selectionItemName.
			^self
				evalEditBlock: [
					value := isKSExpr ifTrue: [ selectionModel eval: valString ] ifFalse: [ Compiler evaluate: valString ].
					selectionModel ksAt: itemName asKSKey put: value.
					]
				onFail: failBlock.
			]
		ifFalse: [
			"the parent object is a Squeak object.  evaluate as Squeak code and assign to the selected IV"
			selectedFieldWrapper replaceValueFromString: valString ifFail: [ ^failBlock value].
			self changed: #augmentedValueString.
			]! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
autoButtonLabel
	| label |
	label := 'auto'.
	(evalLanguage beginsWith: 'auto')
		ifTrue: [
			label := label, ' (', (evalLanguage == #autoKScript ifTrue: [ 'KScript' ] ifFalse: [ 'Smalltalk' ]), ')'.
			].
	^label! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
autoEvalChosen
	evalLanguage := #auto.	"temporary"
	self setAutoEvalLanguage.! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
doItReceiver
	"Answer the object that should be informed of the result of evaluating a
	text selection."
	selectedFieldWrapper ifNil: [^rootObject].
	^selectedFieldWrapper withoutListWrapper! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
evalAsAuto
	^evalLanguage beginsWith: 'auto'! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
evalAsKScript
	^evalLanguage == #kscript! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
evalAsSmalltalk
	^evalLanguage == #smalltalk! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/10/2013 17:00'!
evalEditBlock: aBlock onFail: failBlock
	"The block takes an evaluation world, and is expected to add, edit or remove a stream.  If it succeeds, we update everything necessary."
	[ aBlock value ] on: Error do: [ :x | ^failBlock value ].
	self refreshView.
	^true! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/10/2013 17:00'!
evalKS: aString ifFail: failBlock
	| result obj sqStr |
	obj := self selectedObject ifNil: [ rootObject ].
	[ result := (obj isKindOf: KSObject)
		ifTrue: [ obj eval: aString ]
		ifFalse: [
			"execute KScript on a Smalltalk object"
			sqStr := KSObject compileToString: aString.
			Compiler new evaluate: sqStr in: nil to: obj.
			].
	] on: Error do: failBlock.

	self refreshView.
	
	^result! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/10/2013 19:58'!
ksDoItWWorld
	^(Smalltalk at: #WTopLevelWorld ifAbsent: [ ^nil ]) default! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
kscriptEvalChosen
	evalLanguage := #kscript.
	self setAutoEvalLanguage.
	! !

!KSObjectExplorer methodsFor: 'evaluation' stamp: 'ael 1/8/2013 22:50'!
smalltalkEvalChosen
	evalLanguage := #smalltalk.
	self setAutoEvalLanguage.! !

!KSObjectExplorer methodsFor: 'initialize-release' stamp: 'ael 1/9/2013 14:27'!
initialize
	selectedFieldWrapper := lastValue := nil.
	visibleItemDicts := Dictionary new.
	decompilations := Dictionary new.
	evalLanguage := #autoKScript.! !

!KSObjectExplorer methodsFor: 'initialize-release' stamp: 'ael 1/8/2013 22:50'!
rootObject: anObject
	rootObject := anObject.
	timeOrigin := Time millisecondClockValue - (rootObject at: #'__currentTime__' ifAbsent: [ 0 ]) max: 0.	"ignore just-past-rollover case"
		
	self updateContents.! !

!KSObjectExplorer methodsFor: 'initialize-release' stamp: 'ael 1/8/2013 23:13'!
windowIsClosing
	rootObject := lastValue := selectedFieldWrapper := visibleItemDicts := nil! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/10/2013 16:57'!
basicExploreSelection
	self selectedObject explore.! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/10/2013 16:57'!
basicInspectSelection
	self selectedObject inspect.! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/10/2013 17:00'!
exploreSelection
	| obj |
	(obj := self selectedObject) ifNil: [ ^self fieldListMorph flash ].
	(obj isKindOf: KSObject)
		ifTrue: [ obj ksExplore ]
		ifFalse: [ obj explore ].! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/9/2013 22:44'!
fieldListMenu: aMenu

	| anySelection parentObj |
	anySelection := self selectedObject notNil.
	anySelection ifTrue: [
		self isEditingKSObject
			ifTrue: [
				aMenu addList: #(
					('inspect (i)'			inspectSelection)
					('explore (I)'			exploreSelection)
					('basic inspect'		basicInspectSelection)
					('basic explore'		basicExploreSelection)
					).
				]
			ifFalse: [
				aMenu addList: #(
					('inspect (i)'			inspectSelection)
					('explore (I)'			exploreSelection)
					)
				].

		"iff the selection is a field in a KSObject, offer field removal"
		parentObj := selectedFieldWrapper parent ifNotNil: [ :pw | pw withoutListWrapper ].
		(parentObj isKindOf: KSObject) ifTrue: [ aMenu addList: #( - ('remove'	removeSelection) ) ].
		].
	^ aMenu.! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/10/2013 17:01'!
inspectSelection
	| obj |
	(obj := self selectedObject) ifNil: [ ^self fieldListMorph flash ].
	(obj isKindOf: KSObject)
		ifTrue: [ obj ksInspect ]
		ifFalse: [ obj inspect ].! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/8/2013 22:50'!
inspectorKey: aChar from: view
	"Respond to a Command key issued while the cursor is over my field list"

	aChar == $i ifTrue: [^self inspectSelection ].
	aChar == $I ifTrue: [^self exploreSelection ].

	^ self arrowKey: aChar from: view! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/8/2013 22:50'!
refreshView
	self updateContents! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/10/2013 16:58'!
removeSelection
	| itemName rejectBlock selectionModel |
	rejectBlock := [ self fieldListMorph flash ].
	"reject if there is no selection, or if the selection is the root item"
	(selectedFieldWrapper isNil or: [ selectedFieldWrapper isRoot ])
		ifTrue: [ ^rejectBlock value ]	.	"nothing selected; wipe out the change"

	selectionModel := self selectionModel.
	(selectionModel isKindOf: KSObject) ifFalse: [ ^rejectBlock value ].
	itemName := self selectionItemName.

	self
		evalEditBlock: [ selectionModel removeKey: itemName ]
		onFail: [].
	
	self refreshView.! !

!KSObjectExplorer methodsFor: 'menu' stamp: 'ael 1/8/2013 22:50'!
updateFieldList
	self changed: #fieldList.! !

!KSObjectExplorer methodsFor: 'private' stamp: 'ael 1/8/2013 22:50'!
addWrappersFrom: aCollection expanded: expandedPaths to: list
	| path |
	aCollection do: [ :wrapper |
		list add: wrapper.
		path := wrapper pathFromRoot.
		((expandedPaths includes: path) and: [ wrapper hasContents ])
			ifTrue: [
				self addWrappersFrom: wrapper contents expanded: (expandedPaths copyWithout: path) to: list.
				].
		].! !

!KSObjectExplorer methodsFor: 'private' stamp: 'ael 1/9/2013 14:30'!
decompilationOf: obj
	| key |
	key := (obj isKindOf: KSClosure) ifTrue: [ obj source ] ifFalse: [ obj ].
	^decompilations at: key ifAbsentPut: [ obj decompile decompileText asString ]! !

!KSObjectExplorer methodsFor: 'private' stamp: 'ael 1/8/2013 22:50'!
isEditingKSObject
	^self selectedObject isKindOf: KSObject! !

!KSObjectExplorer methodsFor: 'private' stamp: 'ael 1/8/2013 22:50'!
printStringErrorText
	^ '<not printable>' asText! !

!KSObjectExplorer methodsFor: 'private' stamp: 'ael 1/10/2013 17:04'!
updateItemDict
	"visibleItemDicts is a Dictionary keyed by wrapper paths"
	| rootCollection expandedPaths wrapperList |
	rootCollection := Array with: (ObjectExplorerWrapper with: rootObject name: 'root' model: self parent: nil).
	expandedPaths := self fieldListMorph currentlyExpanded collect: [ :wr | wr pathFromRoot ].
	wrapperList := OrderedCollection new.
	self addWrappersFrom: rootCollection expanded: expandedPaths to: wrapperList.
	wrapperList do: [ :wr | visibleItemDicts at: wr pathFromRoot put: wr ].! !

!KSObjectExplorer methodsFor: 'selecting' stamp: 'ael 1/8/2013 23:36'!
listExpansionChanged
	"the user has changed the expansions in the field list."
	self updateItemDict! !

!KSObjectExplorer methodsFor: 'selecting' stamp: 'ael 1/8/2013 23:14'!
noteFieldSelection: aWrapper
	"for some reason (a user click, or live update of the field list) the selected wrapper has changed."
	selectedFieldWrapper := aWrapper.
	"self changed: #getFieldSelection.			no need: KSHierarchicalListMorph does this itself"
	self setAutoEvalLanguage.! !

!KSObjectExplorer methodsFor: 'selecting' stamp: 'ael 1/8/2013 22:50'!
setAutoEvalLanguage
	"make sure the evaluation pane has the appropriate behaviour for the selected object. (or the root, if none)"
	| obj tm editorClass |
	(evalLanguage beginsWith: 'auto')
		ifTrue: [
			obj := selectedFieldWrapper ifNil: [ rootObject ] ifNotNil: [ selectedFieldWrapper withoutListWrapper ].
			evalLanguage := (obj isKindOf: KSObject) ifTrue: [ #autoKScript ] ifFalse: [ #autoSmalltalk ].
			].
		
	editorClass := (#(smalltalk autoSmalltalk) includes: evalLanguage) ifTrue: [  SmalltalkEditor ] ifFalse: [ KScriptEditor ].
	tm := self evalTextMorph textMorph.
	tm editor class == editorClass
		ifFalse: [
			tm setProperty: #editorClass toValue: editorClass.
			tm installEditorToReplace: nil.
			self changed: #langChanged.
			].! !

!KSObjectExplorer methodsFor: 'stepping' stamp: 'ael 1/8/2013 23:37'!
stepAt: millisecondClockValue in: aWindow
	self updateContents.! !

!KSObjectExplorer methodsFor: 'stepping' stamp: 'ael 1/9/2013 18:40'!
stepTimeIn: aSystemWindow
	^200.! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
buildEvalPaneWith: builder
	| textSpec |
	textSpec := builder pluggableTextSpec new.
	textSpec 
		model: self;
		getText: #evalText; 
		setText: #acceptEval:;
		selection: #contentsSelection
"		menu: #evalPaneMenu:shifted:".
	^textSpec! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
buildFieldListWith: builder
	| listSpec |
	listSpec := builder pluggableKSHierarchicalListSpec new.
	listSpec 
		model: self;
		list: #fieldList; 
		getIndex: #getFieldSelection; 
		setIndex: #noteFieldSelection:; 
		menu: #fieldListMenu:; 
"		dragItem: #dragFromFieldList:;
		dropItem: #dropOnFieldList:at:;"
		keyPress: #inspectorKey:from:.
	^listSpec! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
buildFormulaPaneWith: builder
	| textSpec |
	textSpec := builder pluggableTextSpec new.
	textSpec 
		model: self;
		getText: #augmentedSource; 
		setText: #acceptFormula:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:.
	^textSpec! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 2/1/2013 11:50'!
buildSwitchesWith: builder
	"Build the instance/comment/class switch"
	| panelSpec buttonSpec |
	panelSpec := builder pluggablePanelSpec new.
	panelSpec children: OrderedCollection new.

	buttonSpec := builder pluggableButtonSpec new.
	buttonSpec 
			model: self;
			label: 'Smalltalk'; 
			state: #evalAsSmalltalk; 
			action: #smalltalkEvalChosen;
			frame: (0@0.7 corner: 1@1).
	panelSpec children addLast: buttonSpec.

	buttonSpec := builder pluggableButtonSpec new.
	buttonSpec 
			model: self;
			label: 'KScript'; 
			state: #evalAsKScript; 
			action: #kscriptEvalChosen;
			frame: (0@0.35 corner: 1@0.65).
	panelSpec children addLast: buttonSpec.

	buttonSpec := builder pluggableButtonSpec new.
	buttonSpec 
			model: self;
			label: #autoButtonLabel; 
			state: #evalAsAuto; 
			action: #autoEvalChosen;
			changeLabelWhen: #langChanged;
			frame: (0@0 corner: 1@0.3).
	panelSpec children addLast: buttonSpec.

	^panelSpec! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
buildValuePaneWith: builder
	| textSpec |
	textSpec := builder pluggableTextSpec new.
	textSpec 
		model: self;
		getText: #augmentedValueString; 
		setText: #acceptValue:; 
		selection: nil; "#contentsSelection;" 
		menu: #codePaneMenu:shifted:.
	^textSpec! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/11/2013 13:40'!
buildWith: builder
	| windowSpec window eval |
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 1@0.6)  -> [self buildFieldListWith: builder].
		(0@0.6corner: 0.45@0.8) -> [self buildValuePaneWith: builder].
		(0.45@0.6 corner: 1@0.8) -> [self buildFormulaPaneWith: builder].
		(0@0.8 corner: 0.2@1) -> [self buildSwitchesWith: builder].
		(0.2@0.8 corner: 1@1) -> [self buildEvalPaneWith: builder].
	}.
	window := builder build: windowSpec.
	eval := self evalTextMorph.
	eval askBeforeDiscardingEdits: false.
	eval textMorph setProperty: #editorClass toValue: KScriptEditor.	"default, but may change"
	self changed: #langChanged.
	self fieldListMorph scroller submorphs first toggleExpandedState.
	^window! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
evalTextMorph
	^ self dependents
		detect: [:dep | (dep isKindOf: PluggableTextMorph)
				and: [dep getTextSelector == #evalText]]
		ifNone: []! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/10/2013 17:05'!
fieldList

	^Array with: (ObjectExplorerWrapper with: rootObject name: 'root' model: self parent: nil)! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
fieldListMorph
	^ self dependents
		detect: [:dep | dep isKindOf: KSHierarchicalListMorph ]
		ifNone: []! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
formulaTextMorph
	^ self dependents
		detect: [:dep | (dep isKindOf: PluggableTextMorph)
				and: [dep getTextSelector == #augmentedSource]]
		ifNone: []! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
initialExtent
	^650@500! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
open
        ^ToolBuilder open: self label: rootObject defaultLabelForInspector! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 23:22'!
paneFont
	^((KSFamily withName: 'DejaVuSansMono') withStyle: 0) withSize: 12! !

!KSObjectExplorer methodsFor: 'toolbuilder' stamp: 'ael 1/8/2013 22:50'!
valueTextMorph
	^ self dependents
		detect: [:dep | (dep isKindOf: PluggableTextMorph)
				and: [dep getTextSelector == #augmentedValue]]
		ifNone: []! !
