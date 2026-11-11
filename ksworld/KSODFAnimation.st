Object subclass: #KSODFAnimation
	instanceVariableNames: 'sequence'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-ODFReader'!

!KSODFAnimation commentStamp: 'tak 3/31/2011 13:59' prior: 0!
KSODFAnimation represents a simple animation sequence.
It doesn't support pararel animations yet.

Structure:
 sequence		Collection -- a list of lists of {name. command}

The sequence is a nested structure. The first level is a sequential executed elements, and the second level is a pararel executed elements. For example:

{{script1. script2}.
 {script3}}

script1 and script2 is executed in same time, and script3 is executed after that.
Each sequential element assumes a mouse down event to continue.!

!KSODFAnimation methodsFor: 'accessing' stamp: 'tak 3/30/2011 16:20'!
arrayedSequence
	"for test cases"
	^ (sequence
		collect: [:each | each asArray]) asArray! !

!KSODFAnimation methodsFor: 'accessing' stamp: 'tak 3/25/2011 14:53'!
sequence
	^ sequence! !

!KSODFAnimation methodsFor: 'accessing' stamp: 'tak 3/31/2011 13:38'!
sequence: aCollection 
	sequence := aCollection! !

!KSODFAnimation methodsFor: 'initialize' stamp: 'tak 3/25/2011 14:52'!
initialize
	sequence := OrderedCollection new.! !

!KSODFAnimation methodsFor: 'parsing' stamp: 'tak 3/30/2011 16:17'!
addName: id command: command 
	sequence last add: {id. command}! !

!KSODFAnimation methodsFor: 'parsing' stamp: 'tak 3/30/2011 16:17'!
addNextEvent
	sequence add: OrderedCollection new! !

!KSODFAnimation methodsFor: 'parsing' stamp: 'tak 3/31/2011 15:04'!
read: xml 
	xml
		ifNil: [^ self].
	xml localName caseOf: {
		[#anim:par] -> [self readAnimPar: xml].
		[#anim:seq] -> [self readAnimSeq: xml].
		[#anim:set] -> [self readAnimSet: xml]}
		 otherwise: [Transcript cr; show: 'Unsupported animation '; show: xml localName]! !

!KSODFAnimation methodsFor: 'parsing' stamp: 'tak 3/31/2011 13:15'!
readAnimPar: xml
	xml elementsDo: [ :each |
		self read: each].! !

!KSODFAnimation methodsFor: 'parsing' stamp: 'tak 3/31/2011 13:16'!
readAnimSeq: xml
	xml
		elementsDo: [:each | 
			self addNextEvent.
			self read: each]! !

!KSODFAnimation methodsFor: 'parsing' stamp: 'tak 3/31/2011 13:16'!
readAnimSet: xml
	| id command |
	id := xml @ #smil:targetElement.
	command := xml @ #smil:to.
	self addName: id command: command! !

!KSODFAnimation methodsFor: 'script' stamp: 'tak 3/31/2011 14:51'!
firstState
	"Return state of the first command for each object."
	| state id command |
	state := Dictionary new.
	sequence
		do: [:parallel | parallel
				do: [:pair | 
					id := pair first.
					command := pair second.
					(state includesKey: id)
						ifFalse: [state at: id put: command]]].
	^ state! !

!KSODFAnimation methodsFor: 'script' stamp: 'tak 3/31/2011 14:52'!
prologueState
	"Reverse the first state, and convert to DBJr's command"
	| state |
	state := Dictionary new.
	self firstState
		keysAndValuesDo: [:id :command | state
				at: id
				put: (command caseOf: {
						['visible'] -> ['hide'].
						['hidden'] -> ['show']}
						 otherwise: [command])].
	^ state! !

!KSODFAnimation methodsFor: 'script' stamp: 'yo 2/14/2013 19:58'!
script
	^ PPElement head: #script elements: (self scriptPrologue , self scriptBody , {self scriptEpilogue}) asArray! !

!KSODFAnimation methodsFor: 'script' stamp: 'tak 3/31/2011 14:35'!
scriptBody
	^ Array
		streamContents: [:stream | sequence
				do: [:each | stream
						nextPutAll: (self scriptBodyParalell: each)]]! !

!KSODFAnimation methodsFor: 'script' stamp: 'bf 10/7/2011 15:31'!
scriptBodyParalell: lines 
	| par |
	par := lines collect: [:line | self scriptLine: line].
	par first attributeAt: #trigger put: 'space'.
	^par! !

!KSODFAnimation methodsFor: 'script' stamp: 'yo 2/14/2013 19:56'!
scriptEpilogue
	"This keeps the final state of the animation until the screen is clicked."
	^ {#scriptLine.
			#trigger. 'space'.
			#selector. 'nextPage'.
			{#literal.
				#type. 'box'.
				#name. 'stack'}} asPPElement! !

!KSODFAnimation methodsFor: 'script' stamp: 'yo 2/14/2013 19:56'!
scriptLine: pair 
	| id selector |
	id := pair first.
	selector := pair second = 'visible'
				ifTrue: ['show']
				ifFalse: ['hide'].
	^ {#scriptLine. #selector. selector. {#literal. #type. 'box'. #name. id}} asPPElement! !

!KSODFAnimation methodsFor: 'script' stamp: 'yo 2/14/2013 19:56'!
scriptPrologue
	| state |
	state := self prologueState.
	^ (state keys collect: [:id |
		{#scriptLine.
			#selector. (state at: id).
			{#literal.
				#type. 'box'.
				#name. id}} asPPElement]) asArray! !

!KSODFAnimation class methodsFor: 'instance creation' stamp: 'tak 5/9/2011 11:21'!
makeAnimation: xml
	| anim |
	anim := self read: xml.
	^ anim! !

!KSODFAnimation class methodsFor: 'instance creation' stamp: 'tak 3/31/2011 15:22'!
read: xml
	"Parse the xml element and return the animation. It returns only epilogue (stack nextPage) if xml is nil."
	| anim |
	anim := self new.
	anim read: xml.
	^ anim! !

!KSODFAnimation class methodsFor: 'instance creation' stamp: 'yo 10/5/2011 16:32'!
readFromFile: fileName 
	"Make animation objects from an ODP file. This is for debugging."
	"KSODFAnimation readFromFile: 'vanguard.odp'"
	| doc pages animations |
	doc := KSODFDocument readFromFile: fileName.
	pages := doc presentation elements.
	animations := pages
				collect: [:each | each / #anim:par
						ifNotNil: [:animation | self read: animation]].
	^ animations! !
