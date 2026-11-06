Object subclass: #KSShape
	instanceVariableNames: 'whole fill extent borderFill borderWidth infinite isRectangle cornerRadius shadowFill shadowOffset shadowBlur elements transform offset drawingBounds hBearing'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 16:57'!
ascent
	^ whole pivotPosition currentValue y - whole topLeft currentValue y ! !

!KSShape methodsFor: 'accessing' stamp: 'bf 1/23/2013 15:19'!
borderFill
	^ self borderElement
		ifNil: [GeziraFill r: 0 g: 0 b: 0]
		ifNotNil: [:path | path fill]! !

!KSShape methodsFor: 'accessing' stamp: 'bf 1/18/2013 15:18'!
borderFill: anObject
	| hadStroke path |
	hadStroke := self borderElement notNil.
	path := self ensureBorderElement fill: anObject.
	hadStroke ifFalse: [self resetBounds]! !

!KSShape methodsFor: 'accessing' stamp: 'bf 1/18/2013 15:21'!
borderWidth
	^ self borderElement
		ifNil: [0]
		ifNotNil: [:path | path stroke width]! !

!KSShape methodsFor: 'accessing' stamp: 'bf 1/23/2013 15:21'!
borderWidth: aNumber
	| oldWidth |
	oldWidth := self borderWidth.
	(isRectangle and: [aNumber = 0 and: [self borderFill asColor = Color black]])
		ifTrue: [self deleteBorderElement]
		ifFalse: [self ensureBorderElement stroke width: aNumber].
	oldWidth = aNumber
		ifFalse: [self resetBounds]! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 18:23'!
cornerRadius
	^cornerRadius ifNil: [0]! !

!KSShape methodsFor: 'accessing' stamp: 'yo 1/18/2013 21:10'!
cornerRadius: aNumber
	cornerRadius := aNumber max: 0.
	isRectangle ifTrue: [
		elements at: 1 put: ((GeziraPath rect: (0@0 extent: self extent) radius: cornerRadius) fill: elements first fill).
		elements size > 1 ifTrue: [
			elements at: 2 put: ((GeziraPath rect: (0@0 extent: self extent) radius: cornerRadius) stroke: elements second stroke; fill: elements second fill)].
		self computeBounds].! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 19:03'!
elements
	^elements! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/26/2012 12:21'!
elements: anArray
	elements := anArray.
	self resetBounds.! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 19:03'!
extent
	drawingBounds ifNil: [self computeBounds].
	^extent! !

!KSShape methodsFor: 'accessing' stamp: 'yo 1/18/2013 21:12'!
extent: aPoint
	isRectangle ifTrue: [
		elements at: 1 put: ((GeziraPath rect: (0@0 extent: aPoint) radius: self cornerRadius) fill: elements first fill).
		elements size > 1 ifTrue: [
			elements at: 2 put: ((GeziraPath rect: (0@0 extent: aPoint) radius: self cornerRadius) stroke: elements second stroke; fill: elements second fill)].
		self resetBounds]! !

!KSShape methodsFor: 'accessing' stamp: 'bf 1/18/2013 15:28'!
fill
	^self fillElement
		ifNil: [GeziraFill transparent]
		ifNotNil: [:path | path fill
			ifNil: [GeziraFill transparent]]! !

!KSShape methodsFor: 'accessing' stamp: 'bf 1/18/2013 15:29'!
fill: aFill
	self ensureFillElement fill: aFill! !

!KSShape methodsFor: 'accessing' stamp: 'yo 8/30/2012 20:08'!
hBearing
	^ hBearing! !

!KSShape methodsFor: 'accessing' stamp: 'yo 8/27/2012 15:50'!
height
	^ self extent y! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 18:24'!
infinite
	^ infinite! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 18:25'!
infinite: aBoolean
	infinite := aBoolean! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 19:04'!
offset
	drawingBounds ifNil: [self computeBounds].
	^offset! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 19:04'!
offset: aPoint
	offset := aPoint! !

!KSShape methodsFor: 'accessing' stamp: 'bf 1/18/2013 15:13'!
stroke
	^self borderElement ifNotNil: [:path | path stroke]! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 18:25'!
texture
	"Answer the receiver's texture, a Form; answer nil if the fill-style is not a GezireFillImage."
	^ (self fill isKindOf: GeziraFillImage)
		ifTrue: [self fill form]
		ifFalse: [nil]! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 18:25'!
texture: aForm
	self fill: (GeziraFill image: aForm).
	self extent: aForm extent.! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 19:04'!
transform
	^transform ifNil: [MatrixTransform2x3 identity]! !

!KSShape methodsFor: 'accessing' stamp: 'yo 7/25/2012 19:04'!
transform: aMatrix
	transform := aMatrix.
	self resetBounds.! !

!KSShape methodsFor: 'accessing' stamp: 'yo 8/27/2012 15:50'!
width
	^ self extent x! !

!KSShape methodsFor: 'drawing' stamp: 'bf 1/18/2013 15:36'!
drawOn: aCanvas
	aCanvas preserveStateDuring: [
		offset ifNotNil: [aCanvas translateBy: offset].
		transform ifNotNil: [aCanvas transformBy: transform].
		elements do: [:path |
			aCanvas stroke: nil.
			path drawOn: aCanvas]].! !

!KSShape methodsFor: 'drawing' stamp: 'yo 7/25/2012 19:03'!
drawingBounds
	"Actual bounds when drawing the shape. E.g. the border is usually outside the shape extent"
	drawingBounds ifNil: [self computeBounds].
	^drawingBounds! !

!KSShape methodsFor: 'enumaration' stamp: 'yo 2/1/2013 13:02'!
allElementsDo: aBlock
	elements do: [:e | aBlock value: e].! !

!KSShape methodsFor: 'font' stamp: 'yo 3/15/2013 18:32'!
withFont: aFont index: glyphIndex fill: c
	| glyphI ttGlyph scale sqFont |
	glyphI := glyphIndex asInteger.
	glyphIndex == 10 ifTrue: [glyphI := 13].
	sqFont := TTCFont familyName: aFont family name pointSize: aFont pointSize emphasis: aFont style.
	sqFont isTTCFont ifFalse: [
		sqFont := (TTCFont familyName: 'DejaVuSans' pointSize: aFont pointSize emphasis: aFont style)].
	sqFont := sqFont ttcDescription.
	scale := aFont scale.
	glyphI >= sqFont size ifTrue: [glyphI := 0].
	ttGlyph := sqFont at: glyphI.

	hBearing := (ttGlyph leftSideBearing * scale)@(ttGlyph bounds corner y * scale) negated.
	elements := {(GeziraPath path: ttGlyph asGeziraPath) fill: c}.
	transform := ttGlyph transformFor: scale.
	self computeBounds.
	offset := 0@0. "hBearing."
	extent := (ttGlyph advanceWidth * scale)@(ttGlyph bounds extent y * scale).! !

!KSShape methodsFor: 'geometry' stamp: 'bf 1/18/2013 15:34'!
containsPoint: aPoint
	| p t |
	(self infinite or: [self drawingBounds includesPoint: aPoint])
		ifFalse: [^false].
	p := aPoint - self offset.
	t := self transform.
	^elements anySatisfy: [:path | path containsPoint: p withTransform: t]! !

!KSShape methodsFor: 'geometry' stamp: 'bf 1/18/2013 15:38'!
leftAtY: yy
	^ self borderWidth! !

!KSShape methodsFor: 'geometry' stamp: 'bf 1/18/2013 15:38'!
rightAtY: yy
	"Return the right edge at this y value.  Constant for a box shape."
	^ self extent x - self borderWidth! !

!KSShape methodsFor: 'initialization' stamp: 'bf 1/18/2013 15:31'!
extent: aPoint fill: aFill
	elements := {(GeziraPath rect: (0@0 extent: aPoint) radius: self cornerRadius) fill: aFill}.
	isRectangle := true! !

!KSShape methodsFor: 'initialization' stamp: 'bf 1/18/2013 15:36'!
initialize
	super initialize.
	infinite := false.
	elements := #().
	extent := 0@0.
	isRectangle := false.! !

!KSShape methodsFor: 'printing' stamp: 'yo 1/18/2013 21:29'!
printOn: aStream
	"Print the receiver on a stream."
	aStream nextPutAll: 'Shape: '.
	elements do:
		[:e | aStream nextPutAll: e class name; space]! !

!KSShape methodsFor: 'private' stamp: 'bf 1/18/2013 11:22'!
borderElement
	^elements reverse
		detect: [:path | path stroke notNil]
		ifNone: [nil]! !

!KSShape methodsFor: 'private' stamp: 'yo 7/25/2012 19:05'!
computeBounds
	| e minMax |
	elements ifEmpty: [
		offset ifNil: [offset := 0@0].
		extent ifNil: [extent := 0@0].
		drawingBounds ifNil: [drawingBounds := offset extent: extent].
		^self].
	drawingBounds := nil.
	minMax := nil.
	elements do: [:path |
		e := path boundsWithTransform: self transform stroke: self stroke.
		drawingBounds := drawingBounds ifNil: [e] ifNotNil: [drawingBounds merge: e].
		minMax := minMax ifNil: [path minMaxWithTransform: self transform]
			ifNotNil: [minMax merge: (path minMaxWithTransform: self transform)]].
	offset := minMax origin negated.
	extent := minMax extent.
	drawingBounds := drawingBounds translatedBy: offset.! !

!KSShape methodsFor: 'private' stamp: 'yo 9/4/2013 16:01'!
copyFillElements
	elements := elements collect: [:e | e copy]! !

!KSShape methodsFor: 'private' stamp: 'bf 1/23/2013 15:22'!
deleteBorderElement
	elements last stroke ifNotNil: [
		elements := elements allButLast].! !

!KSShape methodsFor: 'private' stamp: 'bf 1/23/2013 14:17'!
ensureBorderElement
	^self borderElement ifNil: [
		| new |
		new := elements first copy
			stroke: (GeziraStroke width: 1);
			fill: (GeziraFill r: 0 g: 0 b: 0).
		elements := elements, {new}.
		new]! !

!KSShape methodsFor: 'private' stamp: 'bf 1/18/2013 15:33'!
ensureFillElement
	^self fillElement ifNil: [
		| new |
		new := elements first copy asClosedPath stroke: nil.
		elements := {new}, elements.
		new]! !

!KSShape methodsFor: 'private' stamp: 'bf 1/18/2013 11:23'!
fillElement
	^elements
		detect: [:path | path stroke isNil]
		ifNone: [nil]! !

!KSShape methodsFor: 'private' stamp: 'yo 7/25/2012 19:05'!
resetBounds
	drawingBounds := nil.! !

!KSShape methodsFor: 'testing' stamp: 'bf 1/18/2013 15:37'!
hasBorder
	^ self borderWidth > 0 and: [self infinite not]! !

!KSShape methodsFor: 'testing' stamp: 'bf 1/14/2013 16:47'!
isRectangular
	^isRectangle and: [self cornerRadius = 0]! !

!KSShape methodsFor: 'testing' stamp: 'bf 1/17/2013 11:29'!
needsToBeDrawn
	^self drawingBounds area > 0! !

!KSShape class methodsFor: 'instance creation' stamp: 'yo 7/25/2012 19:22'!
extent: aPoint fill: aFill
	^ self new extent: aPoint fill: aFill! !
