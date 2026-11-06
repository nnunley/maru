Object subclass: #KSSVGReader
	instanceVariableNames: 'paths definitions transform attributes bounds'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-SVG'!

!KSSVGReader methodsFor: 'attributes' stamp: 'yo 10/12/2012 11:14'!
parseD: aString
	^KSSVGPathReader new
		readPath: aString! !

!KSSVGReader methodsFor: 'attributes' stamp: 'yo 10/12/2012 10:57'!
parseFill: fillString opacity: opacityString
	fillString = 'none' ifTrue: [^Color transparent].
	(fillString beginsWith: 'url(') ifTrue: [
		^self readElement: (self urlRef: fillString)].
	^(Color fromString: fillString) alpha: (Number readFrom: opacityString)! !

!KSSVGReader methodsFor: 'attributes' stamp: 'yo 10/12/2012 10:57'!
parsePoints: aString
	^Array streamContents: [:out |
		| in x y p |
		in := aString readStream.
		[in skipSeparators; atEnd] whileFalse: [
			x := Number readFrom: in.
			(in skipSeparatorsAndPeekNext = $,)
				ifTrue: [in next; skipSeparators].
			y := Number readFrom: in.
			out nextPut: x@y]]! !

!KSSVGReader methodsFor: 'attributes' stamp: 'yo 10/12/2012 10:57'!
parseStroke: style
	| width limit joints caps |
	width := (style at: 'stroke-width' ifAbsent: ['1']) asNumber.
	width := width * transform scale2D x. "hack"
	limit := (style at: 'stroke-miterlimit' ifAbsent: ['4']) asNumber.
	joints := (style at: 'stroke-linejoin' ifAbsent: ['miter']) caseOf: {
		['miter'] -> [GeziraStroke miter: limit].
		['round'] -> [GeziraStroke round].
		['bevel'] -> [GeziraStroke miter: 0]}.
	caps := (style at: 'stroke-linecap' ifAbsent: ['butt']) caseOf: {
		['butt'] -> [GeziraStroke miter: 0].
		['round'] -> [GeziraStroke round].
		['square'] -> [GeziraStroke miter: width]}.
	^GeziraStroke width: width joints: joints caps: caps! !

!KSSVGReader methodsFor: 'attributes' stamp: 'yo 10/12/2012 10:57'!
parseStyle: aString
	| style pair |
	style := Dictionary new.
	aString ifNotNil: [
		(aString findTokens: ';') do: [:item |
			pair := item findTokens: ':'.
			style at: pair first withBlanksTrimmed put: pair second withBlanksTrimmed]].
	^style! !

!KSSVGReader methodsFor: 'attributes' stamp: 'yo 10/12/2012 10:57'!
parseTransform: transforms
	| coords xform trimmed |
	transforms ifNil: [^nil].
	xform := MatrixTransform2x3 identity.

	(transforms findTokens: ')') do: [:each | 
		trimmed := each withBlanksTrimmed.

		(trimmed beginsWith: 'translate')
			ifTrue: [
				coords := trimmed findTokens: 'translate(, )'.
				xform := xform composedWithLocal:
					(MatrixTransform2x3 withOffset: coords first asNumber
						@ coords second asNumber)] ifFalse: [
		(trimmed beginsWith: 'scale')
			ifTrue: [
				coords := trimmed findTokens: 'scale(, )'.
				xform := xform composedWithLocal:
					(MatrixTransform2x3 withScale: 
					 coords first asNumber
						@ (coords at: 2 ifAbsent: [coords first]) asNumber)] ifFalse: [
		(trimmed beginsWith: 'rotate')
			ifTrue: [
				coords := trimmed findTokens: 'rotate(, )'.
				coords size > 1 ifTrue: [self error: 'rotate around not yet implemented'].
				xform := xform composedWithLocal:
					(MatrixTransform2x3 withAngle: coords first asNumber)] ifFalse: [
		(trimmed beginsWith: 'matrix')
			ifTrue: [
				coords := trimmed findTokens: 'matrix(, )'.
				xform := xform composedWithLocal:
					(MatrixTransform2x3 new
						a11: coords first asNumber;
						a21: coords second asNumber;
						a12: coords third asNumber;
						a22: coords fourth asNumber;
						a13: coords fifth asNumber;
						a23: coords sixth asNumber)] ifFalse: [
		self error: 'unknown transform: ', trimmed]]]].
	].
	^xform! !

!KSSVGReader methodsFor: 'initialization' stamp: 'yo 10/12/2012 10:57'!
initialize
	paths := OrderedCollection new.
	definitions := Dictionary new.
	transform := MatrixTransform2x3 identity.
	attributes := Dictionary new.
	attributes
		at: 'fill' put: '#000000';
		at: 'fill-opacity' put: '1';
		at: 'stroke' put: 'none';
		at: 'stroke-opacity' put: '1'! !

!KSSVGReader methodsFor: 'misc' stamp: 'bf 1/17/2013 16:30'!
addPath: aPath
	| fillColor strokeColor stroke transformed path |
	transformed := GeziraPath new points: (aPath asGeziraPath points collect: [:vertices | 
		vertices collect: [:p | transform transformPoint: p]]).
	transformed size \\ 6 = 0 ifFalse: [self error: 'path size should be a multiple of 6'].
	bounds := transformed minMax.

	fillColor := self parseFill: (attributes at: 'fill')
		opacity: (attributes at: 'fill-opacity').
	fillColor isTransparent ifFalse: [
		paths add: ((GeziraPath path: transformed) withClosedContours fill: fillColor)].

	attributes at: 'stroke' ifPresent: [:strokePaint |
		strokeColor := self parseFill: strokePaint opacity: (attributes at: 'stroke-opacity').
		stroke := self parseStroke: attributes.
		(stroke width > 0 and: [strokeColor isTransparent not]) ifTrue: [
			transformed points do: [:contour |
				path := GeziraPath new points: {contour}.
				paths add: ((GeziraPath path: path) fill: strokeColor; stroke: stroke)]]].! !

!KSSVGReader methodsFor: 'misc' stamp: 'yo 10/12/2012 10:57'!
colorStopsFrom: xmlNodes
	| stops style offset color |
	stops := OrderedCollection new.
	xmlNodes do: [:node |
		node name = #stop ifTrue: [
			offset := (node attributeAt: 'offset') asNumber.
			style := self parseStyle: (node attributeAt: 'style').
			style addAll: node attributes.
			color := self parseFill: (style at: 'stop-color' ifAbsent: ['#000000'])
				opacity: (style at: 'stop-opacity' ifAbsent: ['1']).
			stops add: offset -> color]].
	stops first key > 0 ifTrue: [
		stops add: 0 -> stops first value].
	stops last key < 1 ifTrue: [
		stops add: 1 -> stops last value].
	^stops! !

!KSSVGReader methodsFor: 'misc' stamp: 'yo 10/12/2012 10:57'!
deepLinks: aNode elements: aCollection attributes: aDictionary
	"follow xlink:href"
	| href |
	href := aNode attributeAt: 'xlink:href'.
	href ifNotNil: [
		self deepLinks: (self href: href) elements: aCollection attributes: aDictionary].
	aCollection addAll: aNode elements.
	aDictionary addAll: aNode attributes.! !

!KSSVGReader methodsFor: 'misc' stamp: 'yo 10/12/2012 10:57'!
href: aString
	| id |
	(aString beginsWith: '#')
		ifFalse: [self error].
	id := aString allButFirst.
	^definitions at: id ! !

!KSSVGReader methodsFor: 'misc' stamp: 'yo 10/12/2012 10:57'!
inNode: aNode do: aBlock
	| oldTransform newTransform oldAttributes |
	oldTransform := transform.
	oldAttributes := attributes.
	[attributes := oldAttributes copy.
	attributes addAll: (self parseStyle: (aNode attributeAt: 'style')).
	attributes addAll: aNode attributes.
	attributes at: 'display' ifPresent: [:display |
		display = 'none' ifTrue: [^nil]].
	newTransform := self parseTransform: (aNode attributeAt: 'transform').
	newTransform ifNotNil: [
		transform := oldTransform composedWithLocal: newTransform].
	^aBlock value] ensure: [
		transform := oldTransform.
		attributes := oldAttributes].
	! !

!KSSVGReader methodsFor: 'misc' stamp: 'yo 10/12/2012 10:57'!
urlRef: aString
	| url |
	url := (aString copyAfter: $() copyUpTo: $).
	^self href: url.! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readCircle: circleNode
	self inNode: circleNode do: [
		| x y r oval |
		x := (attributes at: 'cx') asNumber.
		y := (attributes at: 'cy') asNumber.
		r := (attributes at: 'r') asNumber.
		oval := (x@y) - r corner: (x@y) + r. 
		self addPath: (GeziraPath oval: oval)]! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readDefs: defsNode 
	defsNode elementsDo: [:node |
		definitions at: (node attributeAt: 'id') put: node]! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readG: groupNode
	self inNode: groupNode
		do: [self readElements: groupNode elements]! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readLine: lineNode
	| x1 x2 y1 y2 |
	^self inNode: lineNode
		do: [
			x1 := (attributes at: 'x1') asNumber.
			y1 := (attributes at: 'y1') asNumber.
			x2 := (attributes at: 'x2') asNumber.
			y2 := (attributes at: 'y2') asNumber.
			self addPath: (GeziraPath line: x1@y1 to: x2@y2)]! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readLinearGradient: linearGradientNode
	| elems attribs stops gradient units from to gradientTransform |
	elems := OrderedCollection new.
	attribs := Dictionary new.
	#('x1' '0' 'y1' '0' 'x2' '1' 'x2' '1') pairsDo: [:k :v | attribs at: k put: v].
	self deepLinks: linearGradientNode elements: elems attributes: attribs.
	stops := self colorStopsFrom: elems.
	from := (attribs at: 'x1') asNumber @ (attribs at: 'y1') asNumber.
	to := (attribs at: 'x2') asNumber @ (attribs at: 'y2') asNumber.
	units := attribs at: 'gradientUnits' ifAbsent: ['objectBoundingBox'].
	units = 'objectBoundingBox'
		ifTrue: [
			from := bounds origin + (from * bounds extent).
			to := bounds origin + (to * bounds extent).]
		ifFalse: [
			from := transform transformPoint: from.
			to := transform transformPoint: to].
	attribs at: 'gradientTransform' ifPresent: [:trans |
		gradientTransform := self parseTransform: trans.
		from := gradientTransform transformPoint: from.
		to := gradientTransform transformPoint: to].
	gradient := GeziraFillLinearGradient new
		from: from to: to;
		stops: stops.
	^gradient! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readPath: pathNode
	self inNode: pathNode do: [
		self addPath: (self parseD: (attributes at: 'd'))]! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readPolygon: polylineNode
	self inNode: polylineNode 
		do: [
			| points path p1 p2 |
			points := self parsePoints: (attributes at: 'points').
			self addPath: (GeziraPath polygon: points)].! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readPolyline: polylineNode
	self inNode: polylineNode 
		do: [
			| points path p1 p2 |
			points := self parsePoints: (attributes at: 'points').
			self addPath: (GeziraPath polyline: points)].! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readRadialGradient: radialGradientNode 
	| elems attribs stops gradient center radius units gradientTransform |
	elems := OrderedCollection new.
	attribs := Dictionary new.
	#('cx' 0.5 'cy' 0.5 'r' 0.5) pairsDo: [:k :v | attribs at: k put: v].
	self deepLinks: radialGradientNode elements: elems attributes: attribs.
	stops := self colorStopsFrom: elems.
	center := (attribs at: 'cx') asNumber @ (attribs at: 'cy') asNumber.
	radius := (attribs at: 'r') asNumber.
	units := attribs at: 'gradientUnits' ifAbsent: ['objectBoundingBox'].
	units = 'objectBoundingBox'
		ifTrue: [
			center := bounds origin + (center * bounds extent).
			radius := radius * (bounds width max: bounds height)]
		ifFalse: [
			center := transform transformPoint: center.
			radius := (transform transformDirection: radius@0) x].
	attribs at: 'gradientTransform' ifPresent: [:trans |
		gradientTransform := self parseTransform: trans.
		center := gradientTransform transformPoint: center.
		radius := (gradientTransform transformDirection: radius@0) x].
	gradient := GeziraFillRadialGradient new
		center: center radius: radius;
		stops: stops.
	^gradient! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 10:57'!
readRect: pathNode
	| x y w h |
	^self inNode: pathNode
		do: [
			x := (attributes at: 'x') asNumber.
			y := (attributes at: 'y') asNumber.
			w := (attributes at: 'width') asNumber.
			h := (attributes at: 'height') asNumber.
			self addPath: (x@y extent: w@h)]! !

!KSSVGReader methodsFor: 'nodes' stamp: 'yo 10/12/2012 11:13'!
readSvg: svgNode
	self inNode: svgNode do: [
		self readElements: svgNode elements].
	^KSShape new
		elements: paths! !

!KSSVGReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:57'!
readElement: anXMLNode
	| sel |
	(anXMLNode attributeAt: 'id') ifNotNil: [:id |
		definitions at: id put: anXMLNode].
	sel := ('read', anXMLNode name capitalized, ':') asSymbol.
	(self respondsTo: sel)
		ifFalse: [Transcript show: 'Skipping SVG element: ', anXMLNode name; cr.
			^nil].
	^self perform: sel with: anXMLNode
	! !

!KSSVGReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:57'!
readElements: someXMLNodes
	someXMLNodes do: [:each | 
		self readElement: each].! !

!KSSVGReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:57'!
readFromFileNamed: aString
	^self readFromStream: (FileStream readOnlyFileNamed: aString)! !

!KSSVGReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:57'!
readFromStream: aStream
	| xml |
	[xml := XMLDOMParser parseDocumentFrom: aStream]
		ensure: [aStream close].
	^self readFromXML: xml! !

!KSSVGReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:57'!
readFromXML: anXMLDocument
	^self readSvg: anXMLDocument elements first.! !
