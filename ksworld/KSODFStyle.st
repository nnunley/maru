Object subclass: #KSODFStyle
	instanceVariableNames: 'map parent'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-ODFReader'!

!KSODFStyle commentStamp: 'tak 3/22/2011 11:43' prior: 0!
KSODFStyle has key value map for the style and parent pointer.
It has same protocol as Dictionary.

Structure:
 map		IdentityDictionary -- contents of this style
 parent	KSODFStyle -- parent style!

!KSODFStyle methodsFor: 'copying' stamp: 'tak 4/22/2011 14:01'!
withParent: anODFStyle 
	"Return a new KSODFStyle for the inside scope. If the
	receiver has already had a parent, the argument
	becomes grandparent."
	| newParent |
	newParent := parent
				ifNil: [anODFStyle]
				ifNotNil: [parent withParent: anODFStyle].
	^ self class map: map parent: newParent! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 3/22/2011 15:02'!
addAll: aKeyedCollection
	map addAll: aKeyedCollection! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 4/14/2011 14:00'!
associationsDo: aBlock 
	self
		keysAndValuesDo: [:key :value | aBlock value: key -> value]! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 3/23/2011 09:55'!
at: key 
	"Answer the value associated with the key."

	^ self at: key ifAbsent: [self error: 'key not found: ', key printString]! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 3/22/2011 14:26'!
at: aSymbol ifAbsent: aBlock 
	^ map
		at: aSymbol
		ifAbsent: [parent
				ifNil: [aBlock value]
				ifNotNil: [parent at: aSymbol ifAbsent: aBlock]]! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 3/22/2011 14:55'!
at: key ifPresent: aBlock
	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer nil."

	| v |
	v _ self at: key ifAbsent: [^ nil].
	^ aBlock value: v! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 3/22/2011 14:39'!
at: key put: value
	map at: key put: value! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 4/14/2011 13:57'!
keys
	^ map keys
		union: (parent
				ifNil: [#()]
				ifNotNil: [parent keys])! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 4/14/2011 14:01'!
keysAndValuesDo: aBlock 
	self keys
		do: [:key | aBlock
				value: key
				value: (self at: key)]! !

!KSODFStyle methodsFor: 'dictionary' stamp: 'tak 4/14/2011 13:58'!
size
	^ self keys size! !

!KSODFStyle methodsFor: 'printing' stamp: 'tak 4/14/2011 14:01'!
printOn: aStream 
	super printOn: aStream.
	(self as: IdentityDictionary)
		printElementsOn: aStream! !

!KSODFStyle methodsFor: 'private' stamp: 'tak 4/14/2011 12:15'!
map: anIdentityDictionary parent: anODFStyle
	map := anIdentityDictionary.
	parent := anODFStyle! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 4/18/2011 11:02'!
borderColor
	(self
			at: #draw:stroke
			ifAbsent: ['solid'])
			= 'none'
		ifTrue: [^ nil].
	^ Color
		fromString: (self
				at: #'svg:stroke-color'
				ifAbsent: [^ nil])! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 4/18/2011 10:51'!
borderWidth
	| width |
	(self
			at: #draw:stroke
			ifAbsent: ['solid'])
			= 'none'
		ifTrue: [^ nil].
	width := KSODFDocument
				pixelsFromString: (self
						at: #'svg:stroke-width'
						ifAbsent: [^ nil]).
	^ width isZero
		ifTrue: [1]
		ifFalse: [width]! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 10/7/2011 13:28'!
defaultFontName
	^ 'DejaVuSans'.! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 7/15/2011 18:34'!
fillBitmapOn: doc extent: aPoint 
	| form bStyle |
	bStyle := doc
				styleNamed: (self at: #'draw:fill-image-name').
	form := (doc readBitmap: bStyle) ifNil: [^nil].
	^ GeziraFill image: form! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 4/12/2011 15:41'!
fillGradientColors
	"Return an array of start color and stop color"
	| alpha startColor endColor |
	alpha := KSODFDocument
				pixelsFromString: (self
						at: #draw:opacity
						ifAbsent: ['100%']).
	startColor := (Color
				fromString: (self at: #'draw:start-color'))
				alpha: alpha.
	endColor := (Color
				fromString: (self at: #'draw:end-color'))
				alpha: alpha.
	^ Array with: startColor with: endColor! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 5/20/2011 10:49'!
fillGradientLinearOn: doc offset: offset extent: aPoint 
	| gradient points border colors from to from0 |
	points := self
				readAngle: (self at: #'draw:angle')
				extent: aPoint.
	border := KSODFDocument
				pixelsFromString: (self at: #'draw:border').
	to := points second - offset.
	from0 := points first - offset.
	from := to - from0 * border + from0.
	gradient := GeziraFillLinearGradient new from: from to: to.
	colors := self fillGradientColors.
	gradient addStop: colors first at: 0.
	gradient addStop: colors second at: 1.
	^ gradient! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 4/22/2011 14:01'!
fillGradientOn: doc offset: offset extent: aPoint 
	| gStyle |
	gStyle := (doc styleNamed: (self at: #'draw:fill-gradient-name')) withParent: self.
	^ (gStyle at: #draw:style) caseOf: {
		['linear'] -> [gStyle fillGradientLinearOn: doc offset: offset extent: aPoint].
		['rectangular'] -> [gStyle fillGradientRadialOn: doc offset: offset extent: aPoint].
		['radial'] -> [gStyle fillGradientRadialOn: doc offset: offset extent: aPoint]}
		 otherwise: [self error: 'unsupported gradient']! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 4/12/2011 15:44'!
fillGradientRadialOn: doc offset: offset extent: aPoint 
	| x y gradient colors |
	x := KSODFDocument
				pixelsFromString: (self at: #draw:cx).
	y := KSODFDocument
				pixelsFromString: (self at: #draw:cy).
	gradient := GeziraFillRadialGradient new center: aPoint * (x @ y) - offset radius: (aPoint x max: aPoint y)
					/ 2.
	colors := self fillGradientColors.
	gradient addStop: colors first at: 1.
	gradient addStop: colors second at: 0.
	^ gradient! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 7/15/2011 18:34'!
fillOn: doc offset: offset extent: aPoint 
	"Return a GeziraFill made from a dictionary.
	Return nil if the fill is not recognized"
	^ (self
		at: #draw:fill
		ifAbsent: [^ nil]) caseOf: {
		['solid'] -> [self fillSolid].
		['bitmap'] -> [self fillBitmapOn: doc extent: aPoint ].
		['gradient'] -> [self fillGradientOn: doc offset: offset extent: aPoint].
		['none'] -> [GeziraFill transparent]
	}! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 3/24/2011 15:13'!
fillSolid
	| color |
	color := Color
				colorFrom: (self at: #'draw:fill-color').
	self
		at: #draw:opacity
		ifPresent: [:alpha | color := color alpha: alpha asNumber / 100].
	^ color asGeziraFill! !

!KSODFStyle methodsFor: 'styles' stamp: 'bf 1/21/2013 15:57'!
font
	"Return an LFace"
	| isBold isItalic fontSize styleId |
	fontSize := KSODFDocument
				pixelsFromString: (self
						at: #'fo:font-size'
						ifAbsent: ['19']).
	isBold := (self
				at: #'fo:font-weight'
				ifAbsent: [])
				= 'bold'.
	isItalic := (self
				at: #'fo:font-style'
				ifAbsent: [])
				= 'italic'.
	styleId := (isBold
				ifTrue: [1]
				ifFalse: [0])
				bitOr: (isItalic
						ifTrue: [2]
						ifFalse: [0]).
	^ ((KSFamily withName: self fontFamily)
		withStyle: styleId)
		withSize: fontSize! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 3/23/2011 14:45'!
fontColor
	^ Color colorFrom: (self at: #'fo:color' ifAbsent: ['#000000'])! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 10/7/2011 13:35'!
fontFamily
	| familyName postscriptName |
	familyName := self
				at: #'fo:font-family'
				ifAbsent: [^ self defaultFontName].
	postscriptName := familyName withoutQuoting copyWithout: Character space.
	^ (TTFontDescription includesName: postscriptName)
		ifTrue: [postscriptName]
		ifFalse: [self defaultFontName]! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 10/6/2011 16:41'!
justification
	| align |
	align := self
				at: #'fo:text-align'
				ifAbsent: [^ nil].
	^ align caseOf: {
		['center'] -> [#center].
		['end'] -> [#right].
		['justify'] -> [#full].
	} otherwise: [#left].! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 5/19/2011 16:13'!
orthogonalTangent: rad edge: aPoint
	"It is used to calculate gradient points"
	| k |
	k := (aPoint x * rad cos) + (aPoint y * rad sin).
	^ (rad cos * k) @ (rad sin * k)! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 5/19/2011 16:54'!
readAngle: angle extent: extent 
	"Make the first point and the second point to fill the
	extent by linear gradient."
	"0 is top to bottom"
	"450 is top left to buttom right (45 degrees)"
	"900 is left to right"
	| center r v start |
	r := (angle / 10 \\ 90) degreesToRadians.
	center := extent / 2.
	start := (angle / 900) floor caseOf: {
		[0] ->  [v := self orthogonalTangent: r edge: center transposed.
				v y negated @ v x negated].
		[1] ->  [v := self orthogonalTangent: r edge: center.
				v x negated @ v y].
		[2] ->  [v := self orthogonalTangent: r edge: center transposed.
				v y @ v x].
		[3] ->  [v := self orthogonalTangent: r edge: center.
				v x @ v y negated]}.
	^ {center + start. center - start}! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 5/6/2011 13:52'!
stroke
	| width |
	width := self borderWidth.
	width
		ifNil: [^ nil].
	^ GeziraStroke width: width! !

!KSODFStyle methodsFor: 'styles' stamp: 'tak 7/27/2011 14:00'!
wrap
	"Default value:
		draw:auto-grow-width = 'true'
		fo:wrap-option = 'wrap'
	http://lists.oasis-open.org/archives/office/200708/msg00120.html"
	self
		at: #'draw:auto-grow-width'
		ifPresent: [:v | v = 'true'
				ifTrue: [^ false]
				ifFalse: [^ true]].
	self
		at: #'fo:wrap-option'
		ifPresent: [:v | v = 'wrap'
				ifTrue: [^ true]
				ifFalse: [^ false]].
	^ true! !

!KSODFStyle class methodsFor: 'instance creation' stamp: 'tak 4/22/2011 14:07'!
empty
	^ self map: IdentityDictionary new parent: nil! !

!KSODFStyle class methodsFor: 'instance creation' stamp: 'tak 4/14/2011 12:20'!
map: anIdentityDictionary parent: anODFStyleOrNil
	^ self new map: anIdentityDictionary parent: anODFStyleOrNil! !

!KSODFStyle class methodsFor: 'instance creation' stamp: 'tak 4/22/2011 14:05'!
newFrom: aDict
	"This constructor is used by as:"
	^ self map: (aDict as: IdentityDictionary) parent: nil! !
