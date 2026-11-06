RectangleMorph subclass: #KSMorph
	instanceVariableNames: 'active hadEvent window surface lastCursorPosition fullscreen hostWindow gl'
	classVariableNames: ''
	poolDictionaries: 'OpenGLConstants'
	category: 'KSObjects-Boxes'!

!KSMorph methodsFor: 'access' stamp: 'yo 7/23/2012 12:08'!
boxClass
	^ KSBox! !

!KSMorph methodsFor: 'access' stamp: 'yo 8/30/2012 21:19'!
extent: aPoint
	super extent: aPoint.
	aPoint = surface extent ifFalse: [
		surface := Form extent: aPoint depth: 32.
		window extent: aPoint].! !

!KSMorph methodsFor: 'access' stamp: 'yo 7/23/2012 10:35'!
scaleBy: scaleAmount
	"Sets the LWindow's transform for full-screen vector scaling"
	| p t bnds |
	(window scale > 400 and: [scaleAmount > 1]) ifTrue: [^self].
	"zoom centered at mouse pointer"
	p := window transformation globalPointToLocal: ActiveHand position - self position.
	t := window transformation
		composedWithLocal: ((((MatrixTransform2x3 withOffset: p))
		composedWithLocal: (MatrixTransform2x3 withScale: scaleAmount))
		composedWithLocal: (MatrixTransform2x3 withOffset: p negated)).
	"constrain zoom"
	(t a11 @ t a12) r < 1
		ifTrue: [
			"Do not zoom out (scale < 1), only in"
			t := MatrixTransform2x3 identity]
		ifFalse: [
			"Move zoomed area into viewport"
			bnds := t localBoundsToGlobal: (0@0 corner: window extent).
			bnds left > 0 ifTrue: [t a13: 0].
			bnds top > 0 ifTrue: [t a23: 0].
			bnds right < window width ifTrue: [t a13: t a13 + window width - bnds right].
			bnds bottom < window height ifTrue: [t a23: t a23 + window height - bnds bottom]].
	"Apply transform"
	window transformation = t ifFalse: [window transformation: t].! !

!KSMorph methodsFor: 'access' stamp: 'yo 7/24/2012 19:36'!
window
	^ window! !

!KSMorph methodsFor: 'access' stamp: 'yo 7/23/2012 10:37'!
worldState
	^ window at: #worldState! !

!KSMorph methodsFor: 'active' stamp: 'yo 7/23/2012 10:35'!
active
	^ active == true.! !

!KSMorph methodsFor: 'active' stamp: 'yo 7/23/2012 10:35'!
active: aBoolean
	active := aBoolean! !

!KSMorph methodsFor: 'active' stamp: 'yo 7/23/2012 10:35'!
activeString
	"Answer a string characterizing whether the receiver is currently active; used by the debug menu associated with JesotericMorph."
	^ (active ifTrue: ['<yes>'] ifFalse: ['<no>']), 'active' translated! !

!KSMorph methodsFor: 'active' stamp: 'yo 7/23/2012 12:05'!
enliven
	"Called explicitly from debugging situations, after the receiver has been suspended because of an error."
	self comeToFront; active: true; startStepping.
	self worldState requestFullRepaint! !

!KSMorph methodsFor: 'active' stamp: 'yo 7/23/2012 10:35'!
toggleActive
	"Toggle whether the receiver is active."
	self active: self active not! !

!KSMorph methodsFor: 'display' stamp: 'bf 6/27/2012 19:29'!
drawOn: aCanvas
	(gl isNil or: [gl == #glSuspended]) ifTrue: [
		aCanvas drawImage: surface form at: self position sourceRect: (0@0 extent: surface extent)].! !

!KSMorph methodsFor: 'error handling' stamp: 'yo 7/23/2012 10:35'!
debug: morph process: process error: error
	morph delete.
	process debug: error signalerContext title: error description full: true.! !

!KSMorph methodsFor: 'error handling' stamp: 'yo 7/23/2012 10:35'!
dismissError: morph
	morph delete.
	self startStepping.! !

!KSMorph methodsFor: 'error handling' stamp: 'bf 4/11/2013 11:02'!
handleError: error
	| alarmTime |
	self stopStepping.
	self glSuspend.
	alarmTime := window worldState at: #alarmTime.
	window withAllContentsAndPartsDo: [:b | b clearEvents: alarmTime].
	window worldState at: #alarms put: OrderedCollection new.
	Transcript show: Processor activeProcess ksCurrentTime printString; cr.
	Preferences skipSadFrank
		ifTrue: [error pass]
		ifFalse: [
			self showSoftErrorDialog: error.
			"Suspend current process to use it later in debug:error:"
			Project spawnNewProcessIfThisIsUI: Processor activeProcess.
			Processor activeProcess suspend]! !

!KSMorph methodsFor: 'error handling' stamp: 'yo 1/17/2013 21:34'!
showSoftErrorDialog: error
	"Show a soft error dialog with Frank's head in Morphic."
	"[self error: 'test'] on: Error do: [:error | JesotericMorphMorph new openInWorld showSoftErrorDialog: error]"
	| form morph process dismissButton debugButton |
	form := ((KSFactory default graphicNamed: 'frankHead') thumbnailScale: 1) fill form.
	morph := SketchMorph withForm:  form.
	morph sticky: true.
	process := Processor activeProcess.
	dismissButton := SimpleButtonMorph new
		label: '';
		color: (Color white alpha: 0);
		borderWidth: 0;
		extent: 60 @ 60;
		topLeft: 205@257;
		target: self;
		actionSelector: #dismissError:;
		arguments: {morph};
		setBalloonText: 'Dismiss'.
		
	debugButton := SimpleButtonMorph new
		label: '';
		color: (Color white alpha: 0);
		borderWidth: 0;
		extent: 60 @ 60;
		topLeft: 286@242;
		target: self;
		actionSelector: #debug:process:error:;
		arguments: {morph. process. error};
		setBalloonText: error description, String cr, error signalerContext shortStack.

	morph addMorph: debugButton.
	morph addMorph: dismissButton.

	self addMorphCentered: morph.! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:37'!
acceptDroppingMorph: aMorph event: evt
	"This message is sent when a morph is dropped onto a morph that has agreed to accept the dropped morph by responding 'true' to the wantsDroppedMorph:event: message. This default implementation just adds the given morph to the receiver."
	(aMorph isKindOf: SketchMorph) ifFalse: [^ self].
	self worldState queueEvent: (self makeEvent: (evt as: DropFilesEvent)).
	aMorph delete.! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:37'!
dropFiles: anEvent
	self worldState queueEvent: (self makeEvent: anEvent).! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:35'!
handleMouseDown: anEvent
	"System level event handling."
	anEvent wasHandled ifTrue:[^self]. "not interested"
	anEvent hand removePendingBalloonFor: self.
	anEvent hand removePendingHaloFor: self.
	anEvent wasHandled: true.

	"Make me modal during mouse transitions"
	anEvent hand newMouseFocus: self event: anEvent.
	anEvent blueButtonChanged ifTrue:[^self blueButtonDown: anEvent].
	
	"this mouse down could be the start of a gesture, or the end of a gesture focus"
	(self isGestureStart: anEvent)
		ifTrue: [^ self gestureStart: anEvent].

	self mouseDown: anEvent.
	anEvent hand removeHaloFromClick: anEvent on: self.

	(self handlesMouseStillDown: anEvent) ifTrue:[
		self startStepping: #handleMouseStillDown: 
			at: Time millisecondClockValue + self mouseStillDownThreshold
			arguments: {anEvent copy resetHandlerFields}
			stepTime: self mouseStillDownStepRate ].! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:35'!
handleMouseUp: anEvent
	"System level event handling."
	anEvent wasHandled ifTrue:[^self]. "not interested"
	anEvent hand mouseFocus == self ifFalse:[^self]. "Not interested in other parties"
	anEvent hand releaseMouseFocus: self.
	anEvent wasHandled: true.
	false
		ifTrue:[self blueButtonUp: anEvent]
		ifFalse:[self mouseUp: anEvent.
				self stopSteppingSelector: #handleMouseStillDown:].! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:39'!
handlesKeyboard: evt
	^ self active! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:39'!
handlesMouseDown: event
	^ self active! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:39'!
keyDown: evt
	self worldState queueEvent: (self makeEvent: evt).! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:39'!
keyStroke: evt
	evt commandKeyPressed ifTrue: [evt keyValue caseOf: {
		[30] -> [^self scaleBy: 1.5].
		[31] -> [^self scaleBy: 1/1.5].
	} otherwise: []].

	self worldState queueEvent: (self makeEvent: evt).! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:39'!
keyUp: evt
	self worldState queueEvent: (self makeEvent: evt).! !

!KSMorph methodsFor: 'events' stamp: 'yo 3/6/2013 21:09'!
makeEvent: evt
	| n |
	hadEvent := true.
	n := evt asKSEventWithOffset: self position from: window.
	(n ksAt: #event) = 'dropFiles' ifTrue: [n at: #contents put: (self registerDroppedResourcesFrom: n)].
	^ n.! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 12:03'!
mouseDown: evt
	evt hand newKeyboardFocus: self.
	self worldState queueEvent: (self makeEvent: evt).! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 12:03'!
mouseMove: evt
	self worldState queueEvent: (self makeEvent: evt).! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 12:03'!
mouseUp: evt
	self worldState queueEvent: (self makeEvent: evt).! !

!KSMorph methodsFor: 'events' stamp: 'yo 3/6/2013 21:13'!
registerDroppedResourcesFrom: dropEvent
"
	When the system saves the external resources in a different way, this method or modified one keeps track of the type, name, and actual data.  (This method may well be on the class side along with loadTexture:.)"
	| cc numFiles stream form fileName bytes |
	cc := OrderedCollection new.
	numFiles := dropEvent at: #contents.
	numFiles isSketchMorph ifTrue: [
		cc add: {numFiles form. numFiles externalName}]
	ifFalse: [
		1 to: numFiles do: [:i |
			stream := FileStream requestDropStream: i.
			stream ifNotNil: [
				fileName := stream localName.
				(fileName asLowercase endsWith: '.svg')
					ifTrue: [cc add: {KSSVGReader new readFromStream: stream. fileName}]
					ifFalse: [
						[stream binary.
						bytes := stream contents.
						] ensure: [stream close].
						form := ImageReadWriter formFromStream: bytes readStream.
						cc add: {form. fileName}.
						]]]].
	^ cc.! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:35'!
wantsDropFiles: anEvent
	^ true! !

!KSMorph methodsFor: 'events' stamp: 'yo 7/23/2012 10:35'!
wantsDroppedMorph: aMorph event: evt
	"Allow drop into LBox world.  Expand later to more than images"
	^ aMorph isKindOf: SketchMorph! !

!KSMorph methodsFor: 'fullscreen' stamp: 'yo 7/23/2012 10:35'!
fullscreen
	^fullscreen == true! !

!KSMorph methodsFor: 'fullscreen' stamp: 'yo 7/23/2012 10:35'!
fullscreen: aBoolean 
	fullscreen := aBoolean.
	fullscreen
		ifTrue: [
			self setProperty: #fullScreenExtent toValue: self extent.
			self topLeft: 0@0; extent: owner extent.
			self comeToFront]
		ifFalse: [self extent:
			(self valueOfProperty: #fullScreenExtent ifAbsent: [800 @ 600])]! !

!KSMorph methodsFor: 'fullscreen' stamp: 'yo 7/23/2012 12:10'!
fullscreenString
	"Answer a string characterizing whether the receiver is currently fullscreen; used by the debug menu associated with JesotericMorph."
	^ (self fullscreen ifTrue: ['<yes>'] ifFalse: ['<no>']), 'fullscreen' translated! !

!KSMorph methodsFor: 'fullscreen' stamp: 'yo 7/23/2012 10:35'!
toggleFullScreen
	self fullscreen: self fullscreen not.! !

!KSMorph methodsFor: 'initialization' stamp: 'ael 3/28/2013 16:31'!
initialize
	| aName |
	super initialize.
	self ksCurrentTime: 1.	"not 0, because that confuses evaluation of streams that are created immediately (specifically, isEarlierThan: won't trigger because streams that have been given an initial value will have the same lastTime as streams that haven't)"
	KSClosure reset.
	active := true.
	hadEvent := false.
	super extent: 320 @ 240.
	surface := Form extent: self extent depth: 32.
	window := KSBox new.
	window initializeAsWorld: self extent.
	aName := thisContext sender sender selector.
	self setNameTo: aName.
	self setProperty: #precipitator toValue: aName.
	gl := #glSuspended! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 10:35'!
browseExampleCode
	"Open a window on the code that precipitated this example."
	| aName |
	(aName := self valueOfProperty: #precipitator) ifNil: [^ window inform: 'unknown' translated].
	SystemNavigation default browseMethod: aName asSymbol ofClass: self class class label: aName ! !

!KSMorph methodsFor: 'menu' stamp: 'bf 7/26/2012 18:19'!
buildDebugMenu: aHand
	"Build and answer the menu to be put up when the debug icon in the receiver's halo is pressed."

	| aMenu |
	aMenu := super buildDebugMenu: aHand.
	aMenu addLine.
	aMenu add: 'dismiss this example' action: #deleteJesotericWorldAndAncillaryWindows.
	aMenu add: 'restart stepping' action: #startStepping.
	aMenu addUpdating: #activeString action: #toggleActive.
	aMenu addUpdating: #fullscreenString action: #toggleFullScreen.
	aMenu addUpdating: #openGLString action: #toggleOpenGL.
	aMenu addUpdating: #showingWorldMenuString action: #toggleWorldMenu.
	aMenu addLine.
	aMenu add: 'browse example code' translated target: self selector: #browseExampleCode.
	aMenu add: 'explore window' translated target: self selector: #exploreWindow.

	aMenu addLine.
	aMenu add: 'edit menu definition' translated target: self class selector: #editDebugMenuDefinition.
	^ aMenu! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 10:35'!
deleteJesotericWorldAndAncillaryWindows
	"Delete the receiver as well any Inspectors and Explorers which may be looking at objects situated in the receiver's window.  This at the moment isn't quite perfect, but to me still useful after a flurry of debugging."

	| obj |
	(SystemWindow windowsIn: ActiveWorld satisfying:
		[:win |
			(win model isKindOf: Inspector orOf: ObjectExplorer) and:
				[(((obj := win model rootObject) isKindOf: self boxClass) and:
					[obj == window]) 
				or:
					[((obj := win model rootObject) isKindOf: SequenceableCollection)
						and:
							[obj notEmpty]
						and:
							[obj first isKindOf: self boxClass]
						and:
							[obj first topContainer == window]]]]) do:
					
			[:win | win delete].

	ActiveWorld submorphs do:
		[:m | ((m isKindOf: MenuMorph) and: [m defaultTarget == self])
			ifTrue:
				[m delete]].

	self delete
				! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 10:35'!
explore
	"Open an explorer on the receiver, and position the explorer window in a place conveniently adjacent to the receiver, i.e. to the Jesoteric being explored."

	self openNearby: (ObjectExplorer new explorerFor: self) withLabel: 'LesserphicMorph hosting an LWindow'! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 10:35'!
exploreAllBoxes
	"Open an explorer on all the pboxes in the containment hierarchy"

	| aWindow arr |
	aWindow := ObjectExplorer new explorerFor: (arr := window withAllContents).
	self openNearby: aWindow withLabel: ('all boxes' translated, ' [', arr size printString, ']').! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 10:35'!
exploreWindow
	"Open an explorer on the LWindow within the receiver, and position the explorer window in a place conveniently adjacent to the receiver, i.e. to the right of the object being explored."
	self openNearby: (ObjectExplorer new explorerFor: window) withLabel: (self valueOfProperty: #precipitator ifAbsent: ['']), ' ', 'window' translated! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 10:35'!
inspectWindowsContents
	"Open an Inspector on the contents of the BUI window."

	| anArray |
	anArray := Array streamContents: [:aStream |
		window contentsDo: [:anElement |
			aStream nextPut: anElement]].
	anArray inspectWithLabel: 'Contents of the window' translated! !

!KSMorph methodsFor: 'menu' stamp: 'bf 7/20/2012 16:09'!
openGLString
	^ (self isOpenGL ifTrue: ['<yes>'] ifFalse: ['<no>']), 'OpenGL'! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 12:10'!
openNearby: aWindow withLabel: aLabel
	"Open the morphic window, with the given name and position it conveniently adjacent to the receiver, i.e. to the BUIMorph being explored."

	|  putative |
	aWindow visible: false.
	aWindow openInWorld.
	aWindow setLabel: aLabel.

	"Try to fit it to right of bui window if possible."
	aWindow topLeft: (self topRight + (1@1)).
	putative := self topRight + (1@1).
	(putative x + aWindow width <= ActiveWorld width)  "fits to right?"
		ifFalse:
			[putative := self topLeft - (aWindow width + 1@1).  "fits to left?"
			putative x < 0
				ifTrue:
					["cannot fit to left or to right of me, so go below"
					putative := self bottomLeft + (1@1)]].

	aWindow topLeft: putative.
	aWindow visible: true! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 10:35'!
showingWorldMenu
	"Answer whether the LWindow currently bears a part named 'world menu'"
	^ (window atName: 'world menu') notNil! !

!KSMorph methodsFor: 'menu' stamp: 'yo 7/23/2012 12:05'!
showingWorldMenuString
	"Answer a string characterizing whether or not the receiver is currently showing a world menu."
	^ (self showingWorldMenu ifTrue: ['<yes>'] ifFalse: ['<no>']), 'show world menu' translated! !

!KSMorph methodsFor: 'menu' stamp: 'bf 7/20/2012 16:09'!
toggleOpenGL
	self isOpenGL
		ifFalse: [self glInit]
		ifTrue: [self glDone]! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 6/26/2012 18:33'!
areasRemainingToFill: aRectangle
	^aRectangle areasOutside: bounds! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 6/27/2012 22:50'!
forceToScreen
	"sent from Display via glDraw"! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 6/28/2012 20:24'!
glCheck
	"while some other morph is above us, fall back to normal rendering"
	| isGL wantsGL |
	gl ifNil: [^false].
	wantsGL := self isUnobscured.
	isGL := gl ~~ #glSuspended.
	wantsGL
		ifTrue: [
			isGL
				ifFalse: [self glInit]
				ifTrue: [	(gl origin ~= bounds origin or: [gl extent ~= bounds extent])
					ifTrue: [self glSetViewport]]]
		ifFalse: [
			isGL ifTrue: [self glSuspend. self changed]].
	^wantsGL! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 7/5/2012 21:36'!
glDone
	gl ifNotNil: [
		self glSuspend.
		gl := nil.
		window withAllContentsAndPartsDo: [:b | b glReleaseCaches]]! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 1/31/2013 20:38'!
glDraw
	self glCheck ifFalse: [^false].

	gl beginFrame.
	gl timeStamp: Time millisecondClockValue.
	gl glClear: GLColorBufferBit +  GLDepthBufferBit + GLStencilBufferBit.
	gl glPushMatrix.
	window glDrawOn: gl.
	gl glPopMatrix.
	gl endFrame.
	gl swapBuffers.
	(window ksAt: #glListID) asBoolean ifFalse: [
		gl textureManager deleteTexturesOlderThan: gl timeStamp].
	('Textures: ', gl textureManager memUsed asStringWithCommas, ' Bytes	') displayAt: 0@0. 
	Display addExtraRegion: bounds for: self. 
	self flag: #forceToScreen. "sent from Display later"

	self changed.
	^true! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 6/27/2012 01:13'!
glFlags
	^	1 "B3DSoftwareRenderer"
		+ 2 "B3DHardwareRenderer"
		+ 4 "B3DStencilBuffer" 
		+ 8 "B3DAntialiasing"! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 7/11/2012 18:48'!
glInit
	(gl := OpenGL newIn: bounds flags: self glFlags)
		glMatrixMode: GLProjection;
		glLoadIdentity;
		glMatrixMode: GLModelview;
		glDisable: GLDepthTest;
		glEnable: GLBlend;
		glBlendFunc: "src" GLOne with: "dst" GLOneMinusSrcAlpha;
		glClearColor: 0 with: 0 with: 0 with: 1;
		glEnable: GLStencilTest;
		glClearStencil: 16r0;
		yourself.
	self glSetViewport.! !

!KSMorph methodsFor: 'opengl' stamp: 'yo 9/4/2013 15:01'!
glScreenShot
	^ gl ifNotNil: [gl screenShot] ifNil: [nil]! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 6/26/2012 17:52'!
glSetViewport
	gl	bufferRect: bounds;
		glViewport: 0 with: 0 with: bounds width with: bounds height;
		glLoadIdentity;
		glTranslatef: -1.0 with: 1.0 with: 0.0;
		glScalef: (2.0 / bounds width) with: (-2.0 / bounds height) with: 1.0! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 6/28/2012 20:23'!
glSuspend
	(gl notNil and: [gl ~~ #glSuspended]) ifTrue: [
		gl future destroy.
		gl := #glSuspended.
		self changed].
	! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 7/13/2012 15:54'!
isOpenGL
	^gl notNil! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 6/26/2012 17:36'!
isUnobscured
	self owner submorphsInFrontOf: self do: [:m |
		(bounds intersects: m fullBounds) ifTrue: [^false]].
	^true! !

!KSMorph methodsFor: 'opengl' stamp: 'bf 6/27/2012 20:41'!
outOfWorld: w
	super outOfWorld: w.
	(gl notNil and: [gl ~~ #glSuspended]) ifTrue: [
		gl destroy.
		gl := #glSuspended].! !

!KSMorph methodsFor: 'stepping' stamp: 'yo 3/2/2013 00:13'!
step
	| ev currentCursorPosition canvas bb |
	self active ifFalse: [^ self].
	self fullscreen ifTrue: [self topLeft: 0@0; extent: owner extent].
	
	hostWindow ifNotNil: [
		hostWindow isOpen
			ifTrue: [^self stepHostWindow]
			ifFalse: [self toggleHostWindow]].

	(hadEvent not) ifTrue: [
		currentCursorPosition := Sensor peekMousePt.
		((self bounds containsPoint: currentCursorPosition) and: [lastCursorPosition ~= currentCursorPosition]) ifTrue: [
			ev := MouseMoveEvent new
					setType: #mouseMove 
					startPoint: currentCursorPosition endPoint: currentCursorPosition
					trail: nil buttons: Sensor ksPeekButtons hand: nil stamp: Time millisecondClockValue.
			self worldState queueEvent: (ev asKSEventWithOffset: self position from: window).
		].
		lastCursorPosition := currentCursorPosition].
	[
		hadEvent := self worldState processActions.
		self worldState ifNil: [self invalidRect: self bounds.  ^ hadEvent := false].

		window doLayout.
		bb := window extent.
		self worldState processActionsAgain.
		self glDraw not & self worldState needsRedraw ifTrue: [
			canvas := GeziraCanvas new setTarget: surface.
			canvas deferRendering: true.
			self worldState drawOn: canvas.
			canvas flush.
			self invalidRect: self bounds.
			(window at: #layoutChanged) set: nil.
		].
	] on: Error do: [:e | ^ self handleError: e]..
	hadEvent := false.! !

!KSMorph methodsFor: 'stepping' stamp: 'ael 2/21/2013 18:25'!
stepTime
	^(self containsPoint: World activeHand position) ifTrue: [ 0 ] ifFalse: [ 200 ]! !

!KSMorph methodsFor: 'submorphs' stamp: 'yo 9/10/2013 15:53'!
delete
	window delete.
	((window ksAt: #worldState) asBoolean and: [
		(window ksAt: #worldState) twinkler asBoolean]) ifTrue: [
			(window ksAt: #worldState) twinkler delete].
	super delete.! !

!KSMorph class methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/28/2013 22:39'!
loadWindowFromDirectory: dirName
	| ks obj |
	obj := KSBox loadBoxFromDirectory: dirName.
	obj initializeAsWorld: obj extent.
	ks := self new extent: obj extent.
	ks instVarNamed: 'window' put: obj.
	ks openInWorld.
	^ ks! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 9/11/2012 11:36'!
audioPitcher
	<exampleSummary: 'Change speed or pitch of audio'>
	<exampleStatus: #active>   "active broken obsolete"
	<exampleInvocation: 'KSMorph audioPitcher'>

	| m |
	Smalltalk vmParameterAt: 6 put: 20000. "survivor count tenuring threshold (read-write)"
	SoundPlayer stopReverb.
	m := self new openInWorld.
	m window eval: '
	this.pitchSlider = KSFactory._default().newSlider(P(200,20))
	this.pitchSlider.knobFraction.set(0.1)
	this.pitchSlider.knob.eval("
		this.doPointerMotion = $$(@pointerMotion.mapE((ev) ->
			var x = ev.position.x()
			var y = ev.position.y()
			x = x._detentBy_atMultiplesOf_snap(20, 120, false)
			ev.copyWith(''position'', P(x,y))
			).mapE(@moveFunc2))
	")
	this.speedSlider = KSFactory._default().newSlider(P(200,20))
	this.speedSlider.knobFraction.set(0.1)
	this.pitchLabel = KSBox.newLabel("pitch: 100%")
	this.speedLabel = KSBox.newLabel("speed: 100%")
	this.playButton = KSBox.newLabel("play")
	this.playButton.attachButtonHandler()

	this.pitchLabel.topLeft( P(20, 20))
	this.pitchSlider.topLeft(P(20, 40))
	this.speedLabel.topLeft( P(20, 80))
	this.speedSlider.topLeft(P(20,100))
	this.playButton.topLeft(P(160,160))

	this.add(this.pitchLabel)
	this.add(this.pitchSlider)
	this.add(this.speedLabel)
	this.add(this.speedSlider)
	this.add(this.playButton)

	this.pitch = $$(1 fby 4.raisedTo(@pitchSlider.sliderValue) / 2)
	this.speed = $$(1 fby 4.raisedTo(@speedSlider.sliderValue) / 2)

	this.updatePitchLabel = $$(@pitch.mapE((x) -> this.pitchLabel.textContents("pitch: ".concat((x*100).rounded()).concat("%"))))
	this.updateSpeedLabel = $$(@speed.mapE((x) -> this.speedLabel.textContents("speed: ".concat((x*100).rounded()).concat("%"))))

	this.original = KSBridge.soundFromCachedUrl("http://tinlizzie.org/~bert/orig1.wav")
	this.playAudio = $$(@playButton.fire.doE(() ->
		var chunksize = (100 * this.original.originalSamplingRate() / 1000).rounded()
		var length = (@pitch * chunksize / @speed).rounded()
		var inStream = this.original.samples().readStream()
		var outStream = SoundBuffer.new(length).writeStream()
		while (!!inStream.atEnd())
			var chunk = inStream.next(chunksize)
			var n = length
			while (n > 0)
				outStream.nextPutAll(chunk.first(n.min(chunk.size())))
				n = n - chunk.size()
		var sound = SampledSound._samples_samplingRate(outStream.contents(), @pitch * this.original.originalSamplingRate())
		sound.play()
		))
'.
	m window eval: '
	this.pitchSlider.setSliderCurrentValue(0.5)
	this.speedSlider.setSliderCurrentValue(0.5)'.
	^ m window! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 10/16/2012 15:00'!
layoutLetters
"
KSMorph layoutLetters
"
	| field ll |
	ll := self new openInWorld extent: 300@300.
	ll window add: (field := KSBox extent: 120@200 fill: Color white).
	field field.
	field topLeft: 32@32.
	^ field! !

!KSMorph class methodsFor: 'examples' stamp: 'bf 1/14/2013 16:37'!
test2
	<exampleSummary: 'Show how a button is hooked up with an action.'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph test2'>
	| ll |
	ll := self new openInWorld.
	ll window eval: 
'	var aBox = KSBox.new()
	var bBox = KSBox.new()
	aBox.cornerRadius(10)
	this.add(aBox)
	this.add(bBox)
	aBox.topLeft(P(60, 80))
	bBox.topLeft(P(160, 80))

	this.aBox = aBox.attachButtonHandler()
	aBox.name("button")
	this.bBox = bBox
	this.script = $$(@aBox.fire.doE(() -> @bBox.rotateBy(0.2)))
'.
	^ ll window! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 3/7/2013 15:02'!
test30
	<exampleSummary: 'two-dimensional visual scripting'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph test30'>

	| area head ll target handler |
	ll := self new openInWorld extent: 800@400.
	ll window add: (area := ll boxClass extent: 400@400 fill: Color white).

	ll window add: (target := ll boxClass extent: 400@400 fill: Color white).
	target name: 'page'.
	area topLeft: 400@0.
	handler := KSFrankScripting new.
	handler installTo: area.
	handler scriptingAreaLayout: area.
	area add: handler scriptingAreaButtons.
	handler scriptingAreaButtonsLayout: area.
	handler setupScriptingHead.
	(handler at: #scriptingTarget) set: target.
	handler actionsInScriptingArea.
	
	head := handler head.
	(head at: #handler) acceptDropOf: (
		(head at: #handler) deserializeScript: 
		#(script
			(scriptLine #trigger 'space' (literal name 'page' type 'box'))
			(scriptLine #selector 'show' (literal name 'a1' type 'box'))
			(scriptLine #trigger 'space' (literal name 'page' type 'box'))
			(scriptLine #selector 'hide' (literal name 'a1' type 'box'))) asPPElement).

	area add: (handler makeVerb: 'hide').

	target add: (ll boxClass new name: 'a1'; yourself).
	((target atName: 'a1') at: #visible) set: false.
	^ area.! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 8/30/2013 12:04'!
test31
	"
	KSMorph test31
	"
	| root tile |
	root := KSMorph new openInWorld.
	root extent: 740 @ 340.
	tile := KSFactory default makeAstTree: #(- (+ 1 (* 2 4)) 5).
"	tile := KSFactory default makeAstTree: #(* 2 4)."
	tile center: root window center.
	root window add: tile.
	^ root window! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 8/30/2012 13:25'!
test4
	<exampleSummary: 'A toggle button'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph test4'>
	| w |
	w := self new openInWorld.
	w window becomeUniClass.
	w window evalToMethod: 'toggle = () -> 
	var box = KSBox.new()
	box.beToggleButtonHandler(false)
	this.box = box
	
	this.add(box)
	box.selectedFill = Color.green()
	box.defaultFill = Color.red()
	this
'.
	w window eval: 'this.toggle()'.
	^ w window

	! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 1/9/2013 10:16'!
test8
	<exampleSummary: 'Test of a fill in the blank widget'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph test8'>
	| ll |
	ll := self new openInWorld extent: 500@400.

	ll window add: (ll window factory newFillInTheBlank: 'abc' with: 'def').
	ll window at: #aBox put: ll window last.
	ll window last topLeft: 20@200.
	ll window add: KSBox new.
	ll window at: #bBox put: ll window last.
	ll window last topLeft: 200@200.

	ll window eval:
'this.script3 = $$(@aBox.fire.mapE(((ans) -> @bBox.textContents(ans.result))))'.

	^ll window! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 5/8/2013 10:42'!
test9
	<exampleSummary: 'Test of a color picker chaning the color of a box'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph test9'>
	| ll |
	ll := self new openInWorld extent: 500@400.
	ll window eval:
'	this.addFirst(KSBox.new())
	this.foo = this.first()
	this.foo.topLeft(P(400, 10))
	this.invokeColorPicker(P(20, 20), this.foo.fill(), this.foo, (target, color) -> target.fill(color))
'.

	^ll window! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 1/27/2013 18:21'!
testBasicStack
	<exampleSummary: 'Create a new compact KSStack.  Make a KSObject world is there is none.'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph testBasicStack'>
	
	| ks stack |
	ks := (ActiveWorld submorphOfClass: KSMorph) ifNil: [
		ks := KSMorph new openInWorld extent: 580@680.
	"	KSBox addWorldMenuTo:  ks window.
		KSBox addDismissButtonTo:  ks window.
	"
		].
	stack := KSStack newStack.
	stack addNavBarAt: nil.  
	ks window addFirst: (stack at: #whole).
	^ ks! !

!KSMorph class methodsFor: 'examples' stamp: 'bf 1/31/2013 18:45'!
testClipping
	<exampleSummary: 'Test nested transforms'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph testClipping'>
	| ll |
	ll := self new extent: 300@300; openInWorld.
	ll window eval: 
'	var red = KSBox.new()
	red.name("red")
	red.fill(Color.red())
	red.extent(P(200,200))
	red.topLeft(P(50,50))
	red.rotateBy(20.degreesToRadians())
	red.clipping(true)
	this.add(red)

	var yellow = KSBox.new()
	yellow.name("yellow")
	yellow.fill(Color.yellow())
	yellow.extent(P(200,150))
	yellow.topLeft(P(0,20))
	yellow.rotateBy(60.degreesToRadians())
	yellow.clipping(true)
	red.add(yellow)

	var blue = KSBox.new()
	blue.name("blue")
	blue.fill(Color.blue())
	blue.extent(P(170,100))
	blue.topLeft(P(20,10))
	blue.rotateBy(60.degreesToRadians())
	blue.clipping(true)
	yellow.add(blue)

	var star = KSBox.new()
	star.name("star")
	star.shape(KSShape.new().elements([GeziraPath.path(GeziraCanvas.star())]))
	star.fill(Color.green())
	star.scale(0.5)
	blue.add(star)

	
'.
	^ ll window! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 1/9/2013 10:17'!
testRelaxHeights
	<exampleSummary: 'Slider sets goal height.  Boxes apportion it among themselves by relaxation.'>
	<exampleStatus: #active>   "active broken obsolete"
	<exampleInvocation: 'KSMorph testRelaxHeights'>

	| w aa bb dd ee cc |
	w := self new openInWorld.
w window add: (aa := (w window factory newSlider: 20@200)).
aa topLeft: 50@20.
w window at: #a put: aa.
(aa at: #knobFraction) set: 0.05.

w window add: (bb := KSBox new).
bb topLeft: 100@20.
bb extent: 10@0.
w window at: #b put: bb.

w window eval: 'this.script1 = $$(@a.sliderValue.mapE((val) -> @b.height(val*200)))'.

w window add: (dd := (w window factory newSlider: 20@200)).
dd topLeft: (250@20).
w window at: #d put: dd.
(dd at: #knobFraction) set: 0.05.

w window add: (ee := KSBox new).
ee topLeft: (200@20).
ee extent: (10@0).
w window at: #e put: ee.

w window eval: 'this.script2 = $$(@d.sliderValue.mapE((val) -> @e.height(val*200)))'.
	
	w window add: (cc := KSBox new).
	cc extent: (10@0).
	"(cc at: #shape) fill: Color red."
	cc topLeft: 150@20.
	w window at: #leftBox put: bb.
	w window at: #rightBox put: ee.
	w window at: #c put: cc.
w window eval: 'this.script3 = $$(mergeE(@rightBox.extent, @leftBox.extent).doE(() ->
						@c.height((@rightBox.extent.y() + @leftBox.extent.y() + @c.extent.y()) / 3)))'.

	"cc ksInspect."
	^ w window! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 1/9/2013 10:18'!
testSliderForHeight
	<exampleSummary: 'Sliders changing the height of another widget.  Move the knobs.'>
	<exampleStatus: #active>   "active broken obsolete"
	<exampleInvocation: 'KSMorph testSliderForHeight'>

	| w a b |
w := KSMorph new openInWorld.
w window add: (a := (w window factory newSlider: 20@200)).
a topLeft: (100@20).
w window at: #a put: a.
(a at: #knobFraction) set: 0.05.

w window add: (b := KSBox new).
b topLeft: (190@20).
b extent: (20@200).
w window at: #b put: b.

w window eval: 'this.script = $$(@a.sliderValue.mapE((val) -> @b.height(val*200)))'.
^ w! !

!KSMorph class methodsFor: 'examples' stamp: 'tk 2/5/2013 10:41'!
testStack2Fields
	<exampleSummary: 'Create a new compact KSStack.  Make a KSObject world if there is none.'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph testStack2Fields'>

	| ks stack |
	ks := KSMorph new openInWorld extent: 580@680.
	stack := KSStack exampleWith2Fields.
	ks window addFirst: (stack at: #whole).
	stack addNavBarToAll: nil.
	^ ks! !

!KSMorph class methodsFor: 'examples' stamp: 'tk 1/28/2013 14:03'!
testStackNoFields
	<exampleSummary: 'Create a new compact KSStack.  Make a KSObject world is there is none.'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph testStackNoFields'>

	| ks stack |
	ks := KSMorph new openInWorld extent: 580@680.
	stack := KSStack exampleNoFields.
	ks window addFirst: (stack at: #whole).
	stack addNavBarToAll: nil.
	^ ks! !

!KSMorph class methodsFor: 'examples' stamp: 'yo 3/15/2013 18:08'!
testTextField
	<exampleSummary: 'Create a text field of using KSTextLayout'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph testTextField'>

	| ex columnBox txt les lay |
	les := self new openInWorld extent: (ex := 480@580).
	les extent: ex + (40@40).
	txt := 'The goal is to create a text field and arrange its letters in an area of the screen.  The letters have an order from first to last.  The main problem is to do "word wrap" so that each word is entirely on one line.  
We don''t want half the word at the end of one line and the other half on the next line.' withCRs.
	columnBox := KSFactory default newTextField.  "sets up layout"
	columnBox extent: ex.
	columnBox borderWidth: 1.
	"columnBox name: 'text'; property: #inset put: 4@5."
	lay := columnBox layout.
	lay ksAt: #font put: ((lay  ksAt: #font) withSize: 20).
	columnBox layout addAll: txt.
	columnBox topLeft: 15@40.
	
	les window add: columnBox.
	^ les! !

!KSMorph class methodsFor: 'examples' stamp: 'tk 4/4/2013 16:38'!
testTextFlow1
	<exampleSummary: 'First test of text flow in a stack.  Make a stack with a page-specific field.  Use a KSTextSpan as the field contents.  No other change.  add: adds at the end of this field.'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSMorph testTextFlow1'>

	| ks stack fldBox flow span txt |
	ks := KSMorph new openInWorld extent: 580@680.
	stack := KSStack exampleWith2Fields.
	ks window addFirst: (stack at: #whole).
	stack addNavBarToAll: nil.
	stack showPageNumber: 2.
	
	"set up KSTextSpan as the text collection"
	flow := KSTextFlow new.
	txt := 'A PageData in a stack no longer holds the per-page text for a box.'.
	fldBox :=  stack pageBox atName: 'specificFld'.
	span := flow newField: fldBox newString: ''.
	span flowKey: #textFlow1; pageNum: 2.
	stack ksAt: #textFlow1 put: flow.
	fldBox ksAt: #contents put: span.
	"make sure the container of each letter is right"
	fldBox textContents: txt.
	fldBox contents do: [:lbx | (lbx ksAt: #container) set: fldBox].
	
	"tests"
	fldBox first unicode = txt first asciiValue ifFalse: [self halt].
	fldBox last unicode = txt last asciiValue ifFalse: [self halt].
	fldBox contents size = txt size ifFalse: [self halt].
	"fldBox contents inspect."
	
	^ ks! !

!KSMorph class methodsFor: 'screenshots' stamp: 'yo 9/3/2013 14:12'!
current
	^  ActiveWorld submorphs detect: [:m | m isMemberOf: KSMorph] ifNone: [nil]! !

!KSMorph class methodsFor: 'screenshots' stamp: 'yo 2/27/2013 13:41'!
screenshot
	| ksMorph hand fName |
	ksMorph := ActiveWorld submorphs detect: [:m | m isMemberOf: KSMorph].
	hand := ksMorph window worldState at: #hand.
	(hand at: #parts) size > 0 ifTrue: [(hand at: #parts) first delete].
	hand addAsParts: (KSBox withShape: hand factory cursorIcon).
	fName := FillInTheBlank request: 'file name' initialAnswer: 'screenshot.png'
		centerAt: (ksMorph topRight + (150@100)).
	(fName endsWith: '.png') ifFalse: [fName := fName, '.png'].
[
		(Delay forSeconds: 3) wait.
		WorldState addDeferredUIMessage: [
			(ActiveWorld submorphs detect: [:m | m isMemberOf: KSMorph]) window printToFile: fName with: 100]] fork.! !
