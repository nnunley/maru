SmalltalkEditor subclass: #KScriptEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Tools'!

!KScriptEditor methodsFor: 'editing keys' stamp: 'ael 4/11/2012 20:08'!
ksDoIt: aKeyboardEvent
	"cmd-d in a KScript pane"
	self ksEvaluateSelectionAndDo: [:result :world | ].
	
	^ true! !

!KScriptEditor methodsFor: 'editing keys' stamp: 'ael 1/10/2013 20:00'!
ksEvaluateSelectionAndDo: aBlock
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	| result rcvr failBlock wworld |
	self lineSelectAndEmptyCheck: [^ nil].

	failBlock := [:ex | ex signal].
	
	(model respondsTo: #ksDoItReceiver) ifFalse: [ ^failBlock value ].
	
	rcvr := model ksDoItReceiver.
	wworld := model ksDoItWWorld.		"nil if this image doesn't even have Worlds"
	
	result :=
		[ rcvr evalKS: self selection asString ifFail: failBlock ]
			on: OutOfScopeNotification 
			do: [ :ex | ex resume: true ].
	^aBlock value: result value: wworld
	! !

!KScriptEditor methodsFor: 'editing keys' stamp: 'ael 1/10/2013 19:56'!
ksExploreIt: aKeyboardEvent
	"shift-cmd-i in a KScript pane"
	self ksEvaluateSelectionAndDo: [:result :wworld |
		wworld ifNil: [ result explore ] ifNotNil: [ wworld eval: [ result explore ] ].
		].

	^ true! !

!KScriptEditor methodsFor: 'editing keys' stamp: 'ael 4/11/2012 20:08'!
ksInspectIt: aKeyboardEvent
	"cmd-i in a KScript pane"
	self ksEvaluateSelectionAndDo: [:result :wworld | result inspect].

	^ true! !

!KScriptEditor methodsFor: 'editing keys' stamp: 'ael 1/10/2013 19:58'!
ksPrintIt: aKeyboardEvent
	"cmd-p in a KScript pane"
	| resultString |
	self ksEvaluateSelectionAndDo:
		[:result :wworld |
			resultString := wworld ifNil: [ result printString ] ifNotNil: [ wworld eval: [ result printString ] ].
			self afterSelectionInsertAndSelect: resultString.
			].
	
	^ true! !

!KScriptEditor class methodsFor: 'keyboard shortcut tables' stamp: 'ael 4/11/2012 20:04'!
initialize
	"KScriptEditor initialize"
	self initializeCmdKeyShortcuts.
	self initializeShiftCmdKeyShortcuts.
	self initializeYellowButtonMenu.
	self initializeShiftedYellowButtonMenu.! !

!KScriptEditor class methodsFor: 'keyboard shortcut tables' stamp: 'ael 4/6/2012 15:36'!
initializeCmdKeyShortcuts
	"Initialize the (unshifted) command-key (or alt-key) shortcut table."
	"NOTE: if you don't know what your keyboard generates, use Sensor kbdTest"
	"KScriptEditor initialize"
	| cmds |
	super initializeCmdKeyShortcuts.
	cmds := #($d #ksDoIt: $i #ksInspectIt: $p #ksPrintIt: ).
	1 to: cmds size
		by: 2
		do: [ : i | cmdActions at: (cmds at: i) asciiValue + 1 put: (cmds at: i + 1)].! !

!KScriptEditor class methodsFor: 'keyboard shortcut tables' stamp: 'ael 4/11/2012 20:03'!
initializeShiftCmdKeyShortcuts 
	"Initialize the shift-command-key (or control-key) shortcut table."

	"KScriptEditor initialize"

	| cmds |
	super initializeShiftCmdKeyShortcuts.
	
	cmds := #(
		$i	ksExploreIt:
	).
	1 to: cmds size by: 2 do: [ :i |
		shiftCmdActions at: ((cmds at: i) asciiValue + 1) put: (cmds at: i + 1).			"plain keys"
		shiftCmdActions at: ((cmds at: i) asciiValue - 32 + 1) put: (cmds at: i + 1).		"shifted keys"
		shiftCmdActions at: ((cmds at: i) asciiValue - 96 + 1) put: (cmds at: i + 1).		"ctrl keys"
	].! !
