Object subclass: #KSODFDocument
	instanceVariableNames: 'meta content styles styleMap archive stream addedForms'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-ODFReader'!

!KSODFDocument commentStamp: 'tak 7/15/2011 21:29' prior: 0!
KSODFDocument represents an ODF file.

Structure:
 meta		XMLDocument -- meta.xml
 content	XMLDocument -- content.xml
 styles		XMLDocument -- styles.xml
 styleMap	IdentityDictionary -- map from style name to properties (also IdentityDictionary).
 archive	ZipArchive -- ODF zip file itself
 stream		FileStream -- A file stream which is included in the archive. It is only used to close the zip archive once importing is finished.
 addedForms	IdentityDictionary -- file name -> {form. byteArray} : is used as a cache of the archive.!

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 3/28/2011 14:15'!
archive
	^ archive! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 3/17/2011 17:28'!
close
	stream close! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 3/14/2011 15:31'!
content
	^ content! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 7/15/2011 21:29'!
initialize
	styleMap := IdentityDictionary new.
	addedForms := IdentityDictionary new.! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 7/12/2011 10:28'!
masterStyleNamed: aString 
	"Return an xml element in the master styles."
	^ (styles / #'office:document-styles' / #'office:master-styles') elements detect: [:each | each @ #style:name = aString]! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 3/14/2011 15:31'!
meta
	^ meta! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 3/18/2011 10:39'!
presentation
	^ self content / #'office:document-content' / #office:body / #office:presentation! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 7/15/2011 21:28'!
registerForms: aLWorldState
	"Add original file information to the top window"
	addedForms
		keysAndValuesDo: [:key :pair | aLWorldState
				addExternalForm: pair first
				name: key asString
				value: pair second]! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 4/18/2011 11:18'!
styleElementNamed: aString 
	"Return a node in style.xml whose name is the string"
	^ (self styles / #'office:document-styles' / #office:styles) elements
		detect: [:e | e @ 'draw:name' = aString]
		ifNone: [^ nil]! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 3/18/2011 14:35'!
styleMap	
	^ styleMap! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 4/22/2011 14:07'!
styleNamed: aString 
	"Return a dictionary which has style properties"
	^ styleMap
		at: aString asSymbol
		ifAbsent: [KSODFStyle empty]! !

!KSODFDocument methodsFor: 'accessing' stamp: 'tak 3/18/2011 11:04'!
styles
	^ styles! !

!KSODFDocument methodsFor: 'initialize' stamp: 'tak 4/22/2011 14:09'!
allAttributes: xml 
	"Enumerate all elements and gather all attribute as a
	Dictionary"
	| dictionary |
	dictionary := KSODFStyle empty.
	xml attributes
		keysAndValuesDo: [:key :value | dictionary at: key asSymbol put: value].
	xml
		elementsDo: [:each | dictionary
				addAll: (self allAttributes: each)].
	^ dictionary! !

!KSODFDocument methodsFor: 'initialize' stamp: 'tak 3/22/2011 14:39'!
meta: metaXML content: contentXML styles: stylesXML archive: aZipArchive stream: aStream
	meta := metaXML.
	content := contentXML.
	styles := stylesXML.
	archive := aZipArchive.
	stream := aStream.
	self readStyleMap.! !

!KSODFDocument methodsFor: 'initialize' stamp: 'tak 3/18/2011 15:19'!
readStyleFrom: xml 
	| key |
	key := xml localName caseOf: {
				[#style:style] -> [#style:name].
				[#draw:gradient] -> [#draw:name].
				[#'draw:fill-image'] -> [#draw:name].
				[#draw:marker] -> [#draw:name].
				[#'draw:stroke-dash'] -> [#draw:name].
				[#'style:page-layout'] -> [#style:name]}
				 otherwise: [^ self].
	styleMap
		at: (xml @ key) asSymbol
		put: (self allAttributes: xml)! !

!KSODFDocument methodsFor: 'initialize' stamp: 'tak 3/22/2011 14:55'!
readStyleMap
	self readStylesFrom: self content / #'office:document-content' / #'office:automatic-styles'.
	self readStylesFrom: self styles / #'office:document-styles' / #office:styles.
	self readStylesFrom: self styles / #'office:document-styles' / #'office:automatic-styles'.
	self readStylesFrom: self styles / #'office:document-styles' / #'office:master-styles'.
	self readStyleParent.! !

!KSODFDocument methodsFor: 'initialize' stamp: 'tak 4/14/2011 13:43'!
readStyleParent
	| newMap |
	newMap := IdentityDictionary new.
	styleMap
		keysAndValuesDo: [:key :value | 
			| parent | 
			parent := value
						at: #'style:parent-style-name'
						ifAbsent: [].
			newMap
				at: key
				put: (parent
						ifNil: [value]
						ifNotNil: [value
								withParent: (self styleNamed: parent)])].
	styleMap := newMap! !

!KSODFDocument methodsFor: 'initialize' stamp: 'tak 3/18/2011 15:37'!
readStylesFrom: xml 
	xml
		ifNil: [^ self].
	xml
		elementsDo: [:each | self readStyleFrom: each]! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 7/15/2011 21:29'!
readBitmap: node
	| href key src bytes form |
	href := node at: #xlink:href.
	key := (FileDirectory localNameFor: href) asSymbol.
	(addedForms includesKey: key)
		ifTrue: [^ (addedForms at: key) first].
	src := (archive memberNamed: href)
				ifNil: [^ nil].
	bytes := src contentStream contents.
	form := [ImageReadWriter formFromStream: bytes readStream]
		on: Error
			do: [:e | e messageText =  'image format not recognized'
				ifTrue: [^ nil]
				ifFalse: [e pass]].
	addedForms at: key put: {form. bytes}.
	^ form.! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 5/13/2011 15:26'!
readDrawTextAreas: xml viewBox: matrix interp: interp
	"Return a rectangle for drawing text areas"
	| aString aRectangle |
	aString := xml / #'draw:enhanced-geometry' @ #'draw:text-areas'.
	aString isEmpty ifTrue: [^nil].
	aRectangle := interp evalTextAreas: aString.
	^ matrix localBoundsToGlobalNoRound: aRectangle
	! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 5/12/2011 10:55'!
readFoClip: aString 
	"http://www.w3.org/TR/xsl/#clip
	In CSS2, the only valid <shape> value is: rect (<top>, <right>,
	<bottom>, <left>) where <top>, <bottom> <right>, and <left>
	specify offsets from the respective sides of the box."
	| aStream str tokens |
	aStream := aString readStream.
	aStream upTo: $(.
	str := aStream upTo: #')'.
	tokens := (str allButLast findTokens: ',')
				collect: [:each | each withBlanksTrimmed].
	^ (self class pixelsFromString: tokens fourth dpi: 96)
		@ (self class pixelsFromString: tokens first dpi: 96) corner: (self class pixelsFromString: tokens second dpi: 96)
			@ (self class pixelsFromString: tokens third dpi: 96)! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 7/12/2011 14:10'!
readStyle: xml
	"Return a KSODFStyle specified by draw:style-name"
	^ self styleNamed: xml @ #'draw:style-name'! !

!KSODFDocument methodsFor: 'render' stamp: 'yo 2/19/2013 14:38'!
renderAnimPar: xml on: box
	"Animation scripts are stored to #odfScript temporary,
	and they are moved to a DBJrPage's script"
	box at: #'__odfScript__' put: (KSODFAnimation makeAnimation: xml)! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 4/5/2011 15:19'!
renderDrawCircle: xml
	"todo: svg:cx, svg:cy, svg:r, and draw:kind are not implemented"
	^ self renderDrawEllipse: xml ! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:53'!
renderDrawCustomShape: xml 
	"Return a draw-path made from xml"
	| box interp points matrix style pathString fill styledShape path textAreas |
	box := KSBox new.
	style := self readStyle: xml.
	interp := KSODFFormulaInterpreter newFrom: xml style: style.
	pathString := interp evalPath: xml / #'draw:enhanced-geometry'  @ #'draw:enhanced-path'.
	points := KSSVGPathReader new readPath: pathString.
	matrix := self renderViewBox: xml.
	points isEmpty
		ifTrue: [^ self renderDrawEllipse: xml].
	path := points asGeziraPath transformedBy: matrix.
	box shape: (KSShape new elements: {path}).
	self renderDrawShapeWithTextAndStyles: xml on: box.
	"This is quite ugly, but shape is reconstructed by
	applying style again with GeziraFilledPath and
	GeziraStrokeShape."
	fill := style
				fillOn: self
				offset: box shape offset
				extent: box extent.
	styledShape := KSShape new
				elements: (path
						withFill: fill
						stroke: style stroke
						strokeColor: style borderColor).
	box shape: styledShape.
	self
		renderDrawTransform: xml
		offset: box shape offset negated
		on: box.
	textAreas := self readDrawTextAreas: xml viewBox: matrix interp: interp.
	self renderDrawText: xml style: style textAreas: textAreas on: box.

	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:53'!
renderDrawEllipse: xml 
	"Return a ellipse made from xml"
	| box shape drawStyle |
	box := KSBox new.
	self renderDrawPosition: xml on: box.
	self renderDrawSize: xml on: box.
	shape := KSShape new elements: {GeziraPath
					oval: (0 @ 0 extent: box extent)}.
	box shape: shape.
	self renderDrawShapeWithTextAndStyles: xml on: box.
	drawStyle := self readStyle: xml.
	self renderDrawText: xml style: drawStyle textAreas: nil on: box.
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:41'!
renderDrawFrame: xml 
	| box style |
	box := KSBox new.
	box fill: Color transparent.
	self renderDrawPosition: xml on: box.
	self renderDrawSize: xml on: box.
	self renderDrawShapeWithTextAndStyles: xml on: box.
	"Merge presentation:style-name, draw:style-name, and text:style-name. Needs to be cleanup (I even don't know what is the correct behavior)"
	style := (self readStyle: xml)
				withParent: (self styleNamed: xml @ #'presentation:style-name').
	style := (self styleNamed: xml @ #'text:style-name') withParent: style.
	xml
		elements do: [:each | each localName caseOf: {
				[#'draw:text-box'] -> [self renderDrawText: each style: style textAreas: nil on: box].
				[#'draw:image'] -> [self renderDrawImage: each style: style on: box].
		} otherwise: [self unsupported: 'draw frame content' on: each]].
	self renderDrawTransform: xml offset: 0@0 on: box. 
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:54'!
renderDrawG: xml
	| box |
	box := KSBox new.
	box fill: Color transparent.
	self renderDrawId: xml on: box.
	self renderDrawStyleName: xml on: box.
	self renderShapes: xml on: box.
	^ box.! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:46'!
renderDrawImage: xml style: style on: box 
	| form extent clipDelta originalArea clippedArea newArea |
	extent := box extent.
	form := (self readBitmap: xml) ifNil: [^ self].
	style at: #fo:clip ifPresent: [:foclip |
		clipDelta := self readFoClip: foclip.
true ifFalse: [
		originalArea :=  (0@0 corner: extent) expandBy: clipDelta.
		clippedArea := originalArea origin negated extent: extent.
		newArea := clippedArea scaleBy: form extent / originalArea extent].
	
		clipDelta isZero
			ifFalse: [newArea := (0@0 corner: form extent) insetBy: clipDelta.
				form := form copy: newArea]].
	box texture: form.
	box scale: extent / form extent.! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:54'!
renderDrawLine: xml 
	"Return a line made from xml"
	| box shape x1 y1 x2 y2 path paths |
	box := KSBox new.
	x1 := self class pixelsFromString: xml @ #svg:x1.
	y1 := self class pixelsFromString: xml @ #svg:y1.
	x2 := self class pixelsFromString: xml @ #svg:x2.
	y2 := self class pixelsFromString: xml @ #svg:y2.
	path := GeziraPath line: x1 @ y1 to: x2 @ y2.
	paths := self renderDrawMarker: xml path: path.
	shape := KSShape new elements: paths.
	box shape: shape.
	self renderDrawShapeWithTextAndStyles: xml on: box.
	self renderDrawTransform: xml offset: shape offset negated on: box.
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:55'!
renderDrawPath: xml 
	"Return a draw-path made from xml"
	| box shape points matrix path paths |
	box := KSBox new.
	points := KSSVGPathReader new readPath: xml @ #svg:d.
	matrix := self renderViewBox: xml.
	path := points asGeziraPath transformedBy: matrix.
	paths := self renderDrawMarker: xml path: path.
	shape := KSShape new elements: paths.
	box shape: shape.
	self renderDrawShapeWithTextAndStyles: xml on: box.
	self renderDrawTransform: xml offset: shape offset negated on: box.
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 4/5/2011 14:49'!
renderDrawPoints: xml
	"Return points for polygon / polyline"
	| points viewBoxMatrix |
	points := (xml @ #draw:points findTokens: ' ,')
				pairsCollect: [:px :py | px asNumber @ py asNumber].
	viewBoxMatrix := self renderViewBox: xml.
	^ points
		collect: [:p | viewBoxMatrix localPointToGlobal: p]! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:55'!
renderDrawPolygon: xml 
	"Return a polygon box made from xml"
	| box shape |
	box := KSBox new.
	shape := KSShape new elements: {GeziraPath
					polygon: (self renderDrawPoints: xml)}.
	box shape: shape.
	self renderDrawShapeWithTextAndStyles: xml on: box.
	self renderDrawTransform: xml offset: shape offset negated on: box.
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:55'!
renderDrawPolyline: xml 
	"Return a polygon box made from xml"
	| box shape path paths |
	box := KSBox new.
	path := GeziraPath
					polyline: (self renderDrawPoints: xml).
	paths := self renderDrawMarker: xml path: path.
	shape := KSShape new elements: paths.
	box shape: shape.
	self renderDrawShapeWithTextAndStyles: xml on: box.
	self renderDrawTransform: xml offset: shape offset negated on: box.
	box fill: GeziraFill transparent.
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:55'!
renderDrawRect: xml 
	"Return a polygon box made from ctx xml and ctx style"
	| box |
	box := KSBox new.
	self renderDrawPosition: xml on: box.
	self renderDrawSize: xml on: box.
	self renderDrawShapeWithTextAndStyles: xml on: box.
"	self renderDrawText: xml on: box."
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'bf 1/21/2013 15:36'!
renderMasterPage: xml 
	"Render background. Todo: This implies that background image (if
	exists) is 800x600 because style:repeat = stretch is not
	implemented yet."
	| masterPage pageLayout width height box |
	masterPage := self masterStyleNamed: xml @ #'draw:master-page-name'.
	pageLayout := self styleNamed: masterPage @ #'style:page-layout-name'.
	width := self class
				pixelsFromString: (pageLayout at: #'fo:page-width').
	height := self class
				pixelsFromString: (pageLayout at: #'fo:page-height').
	box := KSBox new.
	box extent: width @ height.
	box fill: Color white.
	((self readStyle: masterPage) at: #'draw:fill') = 'none'
		ifTrue: [^ box].
	self renderDrawStyleName: masterPage on: box.
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'yo 2/14/2013 19:53'!
renderPage: xml 
	"Convert one page to an LBox"
	| box |
	box := self renderMasterPage: xml.
	box name: xml @ #draw:name.
	box clipping: true.

	self renderShapes: xml on: box.
	self renderAnimPar: xml / #anim:par on: box.
	^ box! !

!KSODFDocument methodsFor: 'render' stamp: 'yo 8/16/2013 12:01'!
renderPages
	"Return a collection of LBoxes from the document"
	| boxes |
	boxes := OrderedCollection new.
	self presentation elements
		do: [:each | each localName = #'draw:page'
				ifTrue: [boxes
						add: (self renderPage: each)]]
"		displayingProgress: [:each | 'Importing: '
				, (each
						attributeAt: #'draw:name'
						ifAbsent: [each name])]".
	^ boxes! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 4/7/2011 14:37'!
renderShape: xml 
	^ xml localName caseOf: {
		[#draw:circle] -> [self renderDrawCircle: xml].
		[#'draw:custom-shape'] -> [self renderDrawCustomShape: xml].
		[#draw:ellipse] -> [self renderDrawEllipse: xml].
		[#draw:frame] -> [self renderDrawFrame: xml].
		[#draw:g] -> [self renderDrawG: xml].
		[#draw:line] -> [self renderDrawLine: xml].
		[#draw:path] -> [self renderDrawPath: xml].
		[#draw:polygon] -> [self renderDrawPolygon: xml].
		[#draw:polyline] -> [self renderDrawPolyline: xml].
		[#draw:rect] -> [self renderDrawRect: xml].
		[#anim:par] -> ["see sender of #renderAnimPar:on:". nil].
	} otherwise: [Transcript cr; show: 'Unsupported shape: ', xml localName. nil]! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 4/4/2011 15:45'!
renderShapes: xml on: container 
	| box |
	xml elements
		do: [:each | 
			box := self renderShape: each.
			box
				ifNotNil: [container addFirst: box]]! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 5/31/2011 11:53'!
renderViewBox: xml
	"Return a matrix which converts viewBox coordinates to real one.
	viewBox only affects points, but not other properties like border width."
	| x y viewBox scale width height |
	x := self class pixelsFromString: xml @ #svg:x.
	y := self class pixelsFromString: xml @ #svg:y.
	width := self class pixelsFromString: xml @ #svg:width.
	height := self class pixelsFromString: xml @ #svg:height.
	viewBox := self class readViewBox: xml.
	viewBox ifNil: [^ MatrixTransform2x3 identity].
	scale := (viewBox width isZero
						ifTrue: [1]
						ifFalse: [width / viewBox width])
				@ (viewBox height isZero
						ifTrue: [1]
						ifFalse: [height / viewBox height]).
	^ (MatrixTransform2x3 withScale: scale)
				offset: viewBox left @ viewBox top * scale + (x @ y)! !

!KSODFDocument methodsFor: 'render' stamp: 'tak 7/27/2011 14:13'!
unsupported: aString on: xml
true ifTrue: [^self]. "Remove this line when debugging"
	Transcript cr; show: 'Unsupported ', aString, ': ', xml localName! !

!KSODFDocument methodsFor: 'render-arrow' stamp: 'bf 1/21/2013 16:00'!
readDrawMarker: xml width: width style: style
	"Return a list of GeziraPath from the draw-marker description.
	The marker size is normalized as the width is the width."
	| points matrix origin viewBox scale |
	points := KSSVGPathReader new readPath: xml @ #svg:d.
	viewBox := self class readViewBox: xml.
	origin := viewBox topCenter.
	scale := 1 / viewBox height * width.
	"Offset to the top center and rotate 90 degrees" 
	matrix := MatrixTransform2x3 new
		a11: 0; a12: -1; a13: origin y;
		a21: 1; a22:  0; a23: origin x negated.
	matrix := (MatrixTransform2x3 withScale: scale) composedWithLocal: matrix.
	^  {(GeziraPath new
			points: points;
			fill: style borderColor;
			stroke: (GeziraStroke width: style borderWidth)) transformedBy: matrix.
		(GeziraPath new
			points: points;
			fill: style borderColor) transformedBy: matrix}! !

!KSODFDocument methodsFor: 'render-arrow' stamp: 'yo 10/5/2011 16:32'!
renderDrawMarker: xml path: path 
	"Return a list of GeziraPath with specified markers."
	| style |
	style := self readStyle: xml.
	^ Array
		streamContents: [:aStream | 
			aStream nextPut: path.
			(self
				renderDrawMarkerStart: xml
				path: path
				style: style)
				ifNotNil: [:ps | aStream nextPutAll: ps].	
			(self
				renderDrawMarkerEnd: xml
				path: path
				style: style)
				ifNotNil: [:ps | aStream nextPutAll: ps]]! !

!KSODFDocument methodsFor: 'render-arrow' stamp: 'tak 10/4/2011 16:30'!
renderDrawMarkerEnd: xml path: path style: style
	"Return a GeziraPath from the draw-maker description"
	| markerName marker matrix markerWidth |
	markerName := style
				at: #'draw:marker-end'
				ifAbsent: [^ nil].
	markerName isEmpty ifTrue: [^nil].
	matrix := path endTangentTransform.
	markerWidth := self class pixelsFromString: (style at: #'draw:marker-end-width').
	marker := self
				readDrawMarker: (self styleElementNamed: markerName) width: markerWidth style: style.
	^ marker collect: [:each | each transformedBy: matrix].! !

!KSODFDocument methodsFor: 'render-arrow' stamp: 'tak 10/4/2011 16:28'!
renderDrawMarkerStart: xml path: path style: style
	"Return a GeziraPath from the draw-maker description"
	| markerName marker matrix markerWidth |
	markerName := style
				at: #'draw:marker-start'
				ifAbsent: [^ nil].
	markerName isEmpty ifTrue: [^nil].
	matrix := path startTangentTransform.
	markerWidth := self class pixelsFromString: (style at: #'draw:marker-start-width').
	marker := self
				readDrawMarker: (self styleElementNamed: markerName) width: markerWidth style: style.
	^ marker collect: [:each | each transformedBy: matrix].! !

!KSODFDocument methodsFor: 'render-attribute' stamp: 'tak 4/5/2011 11:00'!
renderDrawId: xml on: box 
	"Read common-draw-id-attlist and set into the box"
	(xml @ #draw:id) notEmpty
		ifTrue: [box name: xml @ #draw:id]! !

!KSODFDocument methodsFor: 'render-attribute' stamp: 'tak 4/5/2011 11:25'!
renderDrawPosition: xml on: box 
	"Read common-draw-position-attlist and set into the box"
	| x y |
	x := self class pixelsFromString: xml @ #svg:x.
	y := self class pixelsFromString: xml @ #svg:y.
	box topLeft: x @ y! !

!KSODFDocument methodsFor: 'render-attribute' stamp: 'tak 4/5/2011 11:04'!
renderDrawShapeWithStyles: xml on: box 
	"Read common-draw-shape-with-styles-attlist and set
	into the box"
	self renderDrawId: xml on: box.
	self renderDrawStyleName: xml on: box.! !

!KSODFDocument methodsFor: 'render-attribute' stamp: 'tak 10/4/2011 11:24'!
renderDrawShapeWithTextAndStyles: xml on: box 
	"Read common-draw-shape-with-text-and-styles-attlist and set into the box"
	"NOTE: Before it is called, box's shape must be determined as extent and offset is used."
	self renderDrawShapeWithStyles: xml on: box.

	"common-draw-text-style-name-attlist is not implemented here because text style effects the child elements."
	"self renderDrawTextStyleName: xml on: box."! !

!KSODFDocument methodsFor: 'render-attribute' stamp: 'tak 4/5/2011 11:26'!
renderDrawSize: xml on: box 
	"Read common-draw-size-attlist and set into the box"
	| width height |
	width := self class pixelsFromString: xml @ #svg:width.
	height := self class pixelsFromString: xml @ #svg:height.
	box extent: width@height.! !

!KSODFDocument methodsFor: 'render-attribute' stamp: 'bf 1/21/2013 15:43'!
renderDrawStyleName: xml on: box 
	"Read common-draw-style-name-attlist and set into the box"
	"NOTE: Before it is called, box's shape must be determined as extent and offset is used."
	| style fill borderWidth borderFill |
	style := self readStyle: xml.
	fill := style fillOn: self offset: box shape offset extent: box extent.
	borderWidth := style borderWidth.
	borderFill := style borderColor.
	fill
		ifNotNil: [box fill: fill].
	borderFill
		ifNotNil: [box borderFill: borderFill].
	borderWidth
		ifNotNil: [box borderWidth: borderWidth]! !

!KSODFDocument methodsFor: 'render-attribute' stamp: 'tak 5/12/2011 11:18'!
renderDrawTransform: xml offset: offset on: box 
	"Read common-draw-transform-attlist and set into the box"
	"Note: this should be inside #renderDrawShapeWithStyles according to ODF specs, but it is called separately because the transform overwrite LBox's extent"
	box
		transformation: ((self convertTransform: xml @ #draw:transform)
				composedWithLocal: ((MatrixTransform2x3 withOffset: offset) 
					composedWithLocal: box transformation))! !

!KSODFDocument methodsFor: 'render-text' stamp: 'bf 1/23/2013 15:05'!
renderDrawText: xml style: style textAreas: aRectangle on: box 
	"Render draw-text"
	| width |
	box layout: KSVerticalLayout new.
	width := box width.
	"aRectangle ifNotNil: [
		layout leftMargin: aRectangle left - box left.
		layout topMargin: aRectangle top - box top.
		layout rightMargin: box right - aRectangle right.
		 bottomMargin: box bottom - aRectangle bottom.
		width := aRectangle width]."
	xml elements do: [:each | each localName caseOf: {
		[#text:p] -> [self renderTextP: each style: style width: width on: box].
		[#text:list] -> [self renderTextList: each style: style on: box]
		} otherwise: [self unsupported: 'draw text content' on: each]].! !

!KSODFDocument methodsFor: 'render-text' stamp: 'tak 6/16/2011 11:52'!
renderParagraphContent: xml style: style on: box 
	"Render paragraph-content"
	xml elementsAndContents
		do: [:each | each isText
				ifTrue: [self
						renderString: each string
						style: style
						on: box]
				ifFalse: [each localName caseOf: {
					[#text:span] -> [self renderTextSpan: each style: style on: box].
					[#'text:line-break'] -> [self renderTextLineBreak: each style: style on: box].
					[#'text:tab'] -> [self renderTextTab: each style: style on: box].
					[#text:s] -> [self renderTextS: each style: style on: box]
					} otherwise: [self unsupported: 'span element' on: each]]].
	"Make sure empty <p> makes enough height"
	box contents isEmpty
		ifTrue: [self renderString: ' ' style: style on: box]! !

!KSODFDocument methodsFor: 'render-text' stamp: 'bf 1/23/2013 15:48'!
renderParagraphLayout: box width: width marginBottom: marginBottom wrap: wrap justification: justification
	box width: width.
"	| layout |
	wrap
		ifTrue: [layout := LWordWrapLayoutF new.
			layout installTo: box.
			layout justification: justification.
			layout leading: 0.
			box
				shape: (LBoxShape extent: width @ 0 color: Color transparent).
			layout layOut: box.
			box height: (box contents inject: 0 into: [:max :each | each pivotPosition y + each shape font descent max: max]) + marginBottom.
			^ self].
	layout := LLineEditor new.
	box install: layout.
	layout justification: justification.
	box color: Color transparent.
	box width: width.
"! !

!KSODFDocument methodsFor: 'render-text' stamp: 'tk 3/4/2013 09:17'!
renderString: aString style: style on: box

	| align |
	box layout ksAt: #font 
		put: (style font fill: style fontColor). 
	align := style at: #'fo:text-align' ifAbsent: ['left'].
	align = 'end' ifTrue: [align := 'left'].
	box layout ksAt: #justification put: align.	
	box layout addAll: aString.
	"(aString beginsWith: 'Compli') ifTrue: [self halt]."
	! !

!KSODFDocument methodsFor: 'render-text' stamp: 'tak 5/16/2011 15:14'!
renderTextItem: xml style: style on: box 
	"Render text-list-item"
	xml
		elements do: [:each | each localName caseOf: {
				[#text:p] -> [self renderTextP: each style: style width: box width on: box].
				[#text:list] -> [self renderTextList: each style: style on: box]
				} otherwise: [self unsupported: 'text list item content' on: each
				]]! !

!KSODFDocument methodsFor: 'render-text' stamp: 'tak 4/14/2011 16:22'!
renderTextLineBreak: xml style: style on: parent 
	self
		renderString: String cr
		style: style
		on: parent! !

!KSODFDocument methodsFor: 'render-text' stamp: 'yo 8/16/2013 17:26'!
renderTextList: xml style: style on: box 
	"Render text-list"
	style at: #'fo:wrap-option' put: 'wrap' "quick hack".
	Transcript cr; show: 'TODO: '; show: thisContext.
	box
		layout: KSVerticalLayout new.
	xml
		elements do: [:each | each localName caseOf: {
				[#'text:list-item'] -> [self renderTextItem: each style: style on: box].
				[#'text:list-header'] -> [self renderTextItem: each style: style on: box].
				} otherwise: [self unsupported: 'text list item' on: each
				]]! !

!KSODFDocument methodsFor: 'render-text' stamp: 'ael 3/15/2013 12:19'!
renderTextP: xml style: parentStyle width: width on: parent 
	| style box marginBottom |
	style := (self styleNamed: xml @ #'text:style-name') withParent: parentStyle.
	box := KSFactory default newTextField.
	box borderWidth: 0.	"default is 1"
	box layout ksAt: #verticalShrink put: true.		
"	box fill: (Color black alpha: 0.2).   "
	box name: '(text:p)'.
	marginBottom := self class pixelsFromString: (style at: #'fo:margin-bottom' ifAbsent: ['']).
	parent add: box.
	self renderParagraphContent: xml style: style on: box.
	self renderParagraphLayout: box
		width: width
		marginBottom: marginBottom
		wrap: style wrap
		justification: style justification.! !

!KSODFDocument methodsFor: 'render-text' stamp: 'tak 5/5/2011 10:42'!
renderTextS: xml style: style on: box 
	| spaces |
	spaces := (xml @ #text:c) isEmpty
		ifTrue: [' ']
		ifFalse: [String new: (xml @ #text:c) asNumber withAll: $ ].
	self
		renderString: spaces
		style: style
		on: box! !

!KSODFDocument methodsFor: 'render-text' stamp: 'tak 4/22/2011 14:01'!
renderTextSpan: xml style: parentStyle on: box 
	| style |
	style := (self styleNamed: xml @ #'text:style-name') withParent: parentStyle.
	self renderParagraphContent: xml style: style on: box! !

!KSODFDocument methodsFor: 'render-text' stamp: 'tak 6/16/2011 11:52'!
renderTextTab: xml style: style on: parent 
	self
		renderString: String tab
		style: style
		on: parent! !

!KSODFDocument methodsFor: 'transform' stamp: 'tak 3/24/2011 13:22'!
convertTransform: aString
	"Convert draw:transform property to CDisplayTransform"
	| tokens trans command args argArray num argStream |
	tokens := Scanner new scanTokens: aString.
	trans := MatrixTransform2x3 identity.
	1
		to: tokens size
		by: 2
		do: [:i | 
			command := tokens at: i.
			argArray := tokens at: i + 1.
			args := OrderedCollection new.
			argStream := argArray readStream.
			[argStream atEnd]
				whileFalse: [num := argStream next.
					(argStream peek notNil
							and: [argStream peek isNumber not])
						ifTrue: [num := self class pixelsFromString: num asString , argStream next].
					args add: num].
			trans := (self processConvertTransform: command args: args) 
						composedWithLocal: trans].
	^ trans! !

!KSODFDocument methodsFor: 'transform' stamp: 'tak 4/15/2011 13:27'!
processConvertTransform: command args: args 
	| trans |
	command = 'rotate'
		ifTrue: [^ MatrixTransform2x3  withAngle: args first radiansToDegrees negated].
	command = 'matrix'
		ifTrue: [trans := MatrixTransform2x3 new.
			trans
				a11: (args at: 1).
			trans
				a12: (args at: 2).
			trans
				a13: (args at: 5).
			trans
				a21: (args at: 3).
			trans
				a22: (args at: 4).
			trans
				a23: (args at: 6).
			^ trans].
	command = 'skewX'
		ifTrue: ["not supported" ^ MatrixTransform2x3 identity].
	command = 'skewY'
		ifTrue: ["not supported" ^ MatrixTransform2x3 identity].
	^ MatrixTransform2x3 withOffset: args first @ args second! !

!KSODFDocument class methodsFor: 'examples' stamp: 'bf 1/21/2013 16:04'!
example1
	"KSODFDocument example1"
	| morph boxes |
	morph := KSMorph new openInWorld extent: 600@800.
	boxes := KSODFDocument renderPagesFromFile: 'Ted First Page.odp'.
	morph window add: boxes first.! !

!KSODFDocument class methodsFor: 'examples' stamp: 'yo 8/16/2013 10:20'!
example3
	"KSODFDocument example3"
	| boxes morph |
	morph := KSMorph new openInWorld extent: 600@800.
	self halt.
	boxes := KSODFDocument renderPagesFromFile: 'box2.odp'.
	morph window add: boxes first.
	^ boxes! !

!KSODFDocument class methodsFor: 'instance creation' stamp: 'tak 3/18/2011 11:02'!
meta: metaXML content: contentXML styles: stylesXML archive: aZipArchive stream: aStream
	^ self new meta: metaXML content: contentXML styles: stylesXML archive: aZipArchive stream: aStream! !

!KSODFDocument class methodsFor: 'instance creation' stamp: 'tak 4/19/2011 10:18'!
readFromFile: fileName
	| aStream |
	aStream := FileDirectory default readOnlyFileNamed: fileName.
	^ self readFromStream: aStream! !

!KSODFDocument class methodsFor: 'instance creation' stamp: 'tak 4/19/2011 10:17'!
readFromStream: aStream
	| zip meta content styles |
	zip := ZipArchive new readFrom: aStream.
	meta := XMLDOMParser parseDocumentFrom: ((zip memberNamed: 'meta.xml') contentStream text converter: UTF8TextConverter new).
	content := XMLDOMParser parseDocumentFrom: ((zip memberNamed: 'content.xml') contentStream text converter: UTF8TextConverter new).
	styles := XMLDOMParser parseDocumentFrom: ((zip memberNamed: 'styles.xml') contentStream text converter: UTF8TextConverter new).
	^ self meta: meta content: content styles: styles archive: zip stream: aStream! !

!KSODFDocument class methodsFor: 'instance creation' stamp: 'tak 3/22/2011 16:38'!
renderPage: idx fromFile: fileName 
	"Return a collection of LBoxes from the ODF presentation file"
	| doc box |
	doc := self readFromFile: fileName.
	box := doc renderPage: (doc presentation elements at: idx).
	doc close.
	^ box! !

!KSODFDocument class methodsFor: 'instance creation' stamp: 'tak 3/17/2011 17:30'!
renderPagesFromFile: fileName 
	"Return a collection of LBoxes from the ODF presentation file"
	| doc boxes |
	doc := self readFromFile: fileName.
	boxes := doc renderPages.
	doc close.
	^ boxes! !

!KSODFDocument class methodsFor: 'utilities' stamp: 'tak 7/12/2011 13:43'!
pixelsFromString: aString 
	"This renders a standard slide about 800 x 600. See #renderMasterPage:."
	^ self pixelsFromString: aString dpi: 72! !

!KSODFDocument class methodsFor: 'utilities' stamp: 'tak 6/14/2011 11:37'!
pixelsFromString: aString dpi: dpi
	"http://www.w3.org/TR/css3-values/#absolute0"
	"Convert css unit to pixel. If the postfix is %, return fraction."
	| number |
	aString isEmpty ifTrue: [^0].
	number := aString asNumber.
	((aString endsWith: 'in')
			or: [aString endsWith: 'inch'])
		ifTrue: [^ (number * dpi) rounded].
	(aString endsWith: 'pt')
		ifTrue: [^ (number / 72.0 * dpi)].
	(aString endsWith: 'pc')
		ifTrue: [^ (number / 6 * dpi) rounded].
	(aString endsWith: 'mm')
		ifTrue: [^ (number / 25.4 * dpi) rounded].
	(aString endsWith: 'cm')
		ifTrue: [^ (number / 2.54 * dpi) rounded].
	(aString endsWith: '%')
		ifTrue: [^ number / 100].
	^ number rounded! !

!KSODFDocument class methodsFor: 'utilities' stamp: 'tak 7/21/2011 11:03'!
readViewBox: xml 
	"Return a Rectangle from the xml. todo: cleanup a case
	of custom-shape (draw:enhanced-geometry)"
	| viewBox |
	viewBox := xml
				attributeAt: #svg:viewBox
				ifAbsent: [xml / #'draw:enhanced-geometry' @ #svg:viewBox].
	viewBox isEmpty ifTrue: [viewBox := '0 0 21600 21600'].
	^ (viewBox findTokens: ' ')
		in: [:q | q first asNumber @ q second asNumber corner: q third asNumber @ q fourth asNumber]! !
