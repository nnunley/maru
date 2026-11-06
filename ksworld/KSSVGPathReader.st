Object subclass: #KSSVGPathReader
	instanceVariableNames: 'stream paths command currentPoint previousPoint firstPoint currentPath'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-SVG'!

!KSSVGPathReader methodsFor: 'accessing' stamp: 'yo 10/12/2012 10:58'!
currentPoint
	^currentPoint! !

!KSSVGPathReader methodsFor: 'accessing' stamp: 'yo 10/12/2012 10:58'!
smoothPoint
	"mirror previous point at current point"
	^currentPoint * 2 - previousPoint! !

!KSSVGPathReader methodsFor: 'building' stamp: 'yo 10/12/2012 10:58'!
newPath
	(currentPath notNil and: [currentPath position > 0])
		ifTrue: [paths add: currentPath contents].
	currentPath := (Array new: 20) writeStream.
	firstPoint := previousPoint := currentPoint.! !

!KSSVGPathReader methodsFor: 'commands' stamp: 'yo 10/12/2012 10:58'!
arc: from radius: ellipseRadii rotate: angle large: moreThan180 sweep: counterClockWise to: to
	"http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes"
	self flag: #todo.
Transcript show: 'Skipping SVG arc'; cr.
	self line: from to: to.! !

!KSSVGPathReader methodsFor: 'commands' stamp: 'yo 10/12/2012 10:58'!
bezier: a via: b and: c to: d
	"Approximate this cubic bezier by a quadratic one. If necessary, subdivide it first."
	| ab abc abcd bc bcd cd error pts range s t |
	pts := {a. b. c. d}.
	range := pts max - pts min.
	"based on http://www.caffeineowl.com/graphics/2d/vectorial/cubic2quad01.html"
	s := 3 * b - a.
	t := 3 * c - d.
	error := (s - t) abs.
	(error r / range r) < 0.05
		ifTrue: [self bezier: a via: (s + t) / 4.0 to: d]
		ifFalse: [
			ab := (a + b) / 2.0.
			bc := (b + c) / 2.0.
			cd := (c + d) / 2.0.
			abc := (ab + bc) / 2.0.
			bcd := (bc + cd) / 2.0.
			abcd := (abc + bcd) / 2.0.
			self bezier: a via: ab and: abc to: abcd.
			self bezier: abcd via: bcd and: cd to: d].
	previousPoint := c.
	currentPoint := d.! !

!KSSVGPathReader methodsFor: 'commands' stamp: 'yo 10/12/2012 10:58'!
bezier: p1 via: p2 to: p3
	currentPath nextPut: p1; nextPut: p2; nextPut: p3.
	previousPoint := p2.
	currentPoint := p3.! !

!KSSVGPathReader methodsFor: 'commands' stamp: 'yo 10/12/2012 10:58'!
closePath
	firstPoint = currentPoint ifFalse: [
		self line: currentPoint to: firstPoint.
		currentPoint := firstPoint].
	self newPath.! !

!KSSVGPathReader methodsFor: 'commands' stamp: 'yo 10/12/2012 10:58'!
line: p1 to: p2
	currentPath nextPut: p1; nextPut: p1; nextPut: p2.
	currentPoint := previousPoint := p2.! !

!KSSVGPathReader methodsFor: 'commands' stamp: 'yo 10/12/2012 10:58'!
moveTo: aPoint
	currentPoint := aPoint.
	command := command isUppercase
		ifTrue: [$L]
		ifFalse: [$l].
	self newPath! !

!KSSVGPathReader methodsFor: 'commands' stamp: 'yo 10/12/2012 10:58'!
privateMoveTo: aPoint
	"Same as moveTo: but it doen't imply subsequent command is line."
	currentPoint := aPoint.
	self newPath! !

!KSSVGPathReader methodsFor: 'commands' stamp: 'yo 10/12/2012 10:58'!
unsupported: aString 
true ifTrue: [^self]. "Remove this line when debugging"
	Transcript cr; show: 'Unsupported path: ' , aString! !

!KSSVGPathReader methodsFor: 'commans-arc' stamp: 'yo 10/12/2012 10:58'!
addPoints: points
	previousPoint := points at: (points size - 1).
	currentPoint := points last.
	currentPath nextPutAll: points.! !

!KSSVGPathReader methodsFor: 'commans-arc' stamp: 'yo 10/12/2012 10:58'!
arc: topLeft corner: bottomRight from: begin to: end 
	"B command: Draw arc counter clockwise"
	| rect begin0 end0 points |
	rect := topLeft corner: bottomRight.
	begin0 := (begin - rect center) theta.
	end0 := (end - rect center) theta.
	end0 > begin0
		ifTrue: [begin0 := Float pi * 2 + begin0].
	points := (GeziraPath
				arcPoints: end0
				to: begin0
				center: rect center
				radius: rect extent / 2) reversed.
	self privateMoveTo: points first.
	self addPoints: points.! !

!KSSVGPathReader methodsFor: 'commans-arc' stamp: 'yo 10/12/2012 10:58'!
arc: center extent: extent from: start to: end 
	"Draw an arc clockwise"
	"extent is actually radius, this is an error of the
	specification "
	| points start1 end0 end1 |
	"OOo has a bug that end angle can be 360 * some big number,"
	start1 := start \\ 360.
	end0 := end \\ 360.
	end1 := start1 >= end0
				ifTrue: [end0 + 360]
				ifFalse: [end0].
	points := GeziraPath
				arcPoints: start1 degreesToRadians
				to: end1 degreesToRadians
				center: center
				radius: extent.
	self privateMoveTo: points first.
	self addPoints: points.! !

!KSSVGPathReader methodsFor: 'commans-arc' stamp: 'yo 10/12/2012 10:58'!
clockwisearcto: topLeft corner: bottomRight from: begin to: end 
	"W command: Draw arc clockwise"
	| rect begin0 end0 points |
	rect := topLeft corner: bottomRight.
	begin0 := (begin - rect center) theta.
	end0 := (end - rect center) theta.
	begin0 > end0
		ifTrue: [end0 := Float pi * 2 + end0].
	points := (GeziraPath
				arcPoints: begin0
				to: end0
				center: rect center
				radius: rect extent / 2).
"	self line: self currentPoint to: points first."
	self privateMoveTo: points first.
	self addPoints: points.! !

!KSSVGPathReader methodsFor: 'commans-arc' stamp: 'yo 10/12/2012 10:58'!
ellipticalquatrant: begin to: end
	"Return points to draw a quarter ellipse from begin to end clockwise."
	| center begin0 |
	center := (end - begin) x * (end - begin) y >= 0
		ifTrue: [begin x @ end y]
		ifFalse: [end x @ begin y].
	begin0 := (begin - center) theta.
	^GeziraPath
				arcPoints: begin0
				to: begin0 + (Float pi / 2)
				center: center
				radius: (end - begin) abs.! !

!KSSVGPathReader methodsFor: 'commans-arc' stamp: 'yo 10/12/2012 10:58'!
ellipticalquatrantx: aPoint 
	"Draws a quarter ellipse, whose initial segment is tangential to the
	x-axis, is drawn from the current point to (x, y)."
	"LSVGPathReader drawD: 'M 10 10 X 11 11 10 12 9 11 10 10'"
	| points |
	points := (aPoint - currentPoint) x * (aPoint - currentPoint) y >= 0
				ifTrue: [self ellipticalquatrant: currentPoint to: aPoint]
				ifFalse: [(self ellipticalquatrant: aPoint  to: currentPoint) reversed].
	self addPoints: points! !

!KSSVGPathReader methodsFor: 'commans-arc' stamp: 'yo 10/12/2012 10:58'!
ellipticalquatranty: aPoint 
	"Draws a quarter ellipse, whose initial segment is tangential to the
	y-axis, is drawn from the current point to (x, y)"
	"LSVGPathReader drawD: 'M 10 10 Y 11 11 10 12 9 11 10 10'"
	| points |
	points := (aPoint - currentPoint) x * (aPoint - currentPoint) y < 0
				ifTrue: [self ellipticalquatrant: currentPoint to: aPoint]
				ifFalse: [(self ellipticalquatrant: aPoint  to: currentPoint) reversed].
	self addPoints: points! !

!KSSVGPathReader methodsFor: 'initialize-release' stamp: 'yo 10/12/2012 10:58'!
initialize
	currentPoint := 0@0.
	paths := OrderedCollection new.
	self newPath.! !

!KSSVGPathReader methodsFor: 'public' stamp: 'yo 10/12/2012 10:58'!
readPath: aString
	stream := aString readStream.
	[stream skipSeparators; atEnd] whileFalse: [
		stream skipSeparatorsAndPeekNext isLetter
			ifTrue: [command := stream next].
		command asUppercase caseOf: {
			[$M] -> [self moveTo: self nextPoint].
			[$L] -> [self line: self currentPoint to: self nextPoint].
			[$H] -> [self line: self currentPoint to: self nextPointH].
			[$V] -> [self line: self currentPoint to: self nextPointV].
			[$C] -> [self bezier: self currentPoint via: self nextPoint and: self nextPoint to: self nextPoint].
			[$S] -> [self bezier: self currentPoint via: self smoothPoint and: self nextPoint to: self nextPoint].
			[$Q] -> [self bezier: self currentPoint via: self nextPoint to: self nextPoint].
			[$T] -> [self bezier: self currentPoint via: self smoothPoint to: self nextPoint].
			[$A] -> [self arc: self currentPoint radius: self readPoint rotate: self readNumber large: self readBool sweep: self readBool to: self nextPoint].
			[$Z] -> [self closePath].
			[$N] -> [self unsupported: 'N'. self closePath].
			[$F] -> [self unsupported: 'F'. self closePath].
			[$U] -> [self arc: self nextPoint extent: self nextPoint from: self readNumber to: self readNumber].
			[$B] -> [self arc: self nextPoint corner: self nextPoint from: self nextPoint to: self nextPoint].
			[$W] -> [self clockwisearcto: self nextPoint corner: self nextPoint from: self nextPoint to: self nextPoint].
			[$X] -> [self ellipticalquatrantx: self nextPoint].
			[$Y] -> [self ellipticalquatranty: self nextPoint].
		}].

	self newPath. "flush"

	^paths! !

!KSSVGPathReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:58'!
nextPoint
	| p |
	p := self readPoint.
	^command isUppercase
		ifTrue: [p]
		ifFalse: [currentPoint + p].! !

!KSSVGPathReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:58'!
nextPointH
	| x |
	x := self readNumber.
	command isUppercase
		ifFalse: [x := currentPoint x + x].
	^x @ currentPoint y.! !

!KSSVGPathReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:58'!
nextPointV
	| y |
	y := self readNumber.
	command isUppercase
		ifFalse: [y := currentPoint y + y].
	^currentPoint x @ y.! !

!KSSVGPathReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:58'!
readBool
	| flag |
	flag := self readNumber.
	flag = 0 ifTrue: [^false].
	flag = 1 ifTrue: [^true].
	self error: '0 or 1 expected'! !

!KSSVGPathReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:58'!
readNumber
	"In 'optimized' SVG, numbers follow each other without space. So we have to determine what's a numbe rhere and can't rely on Squeak's number parser, which would e.g. see an 's' as part of a scaled decimal"
	| pos len c |
	(stream skipSeparatorsAndPeekNext = $,)
		ifTrue: [stream next; skipSeparators].
	pos := stream position.
	('0123456789-' includes: (c := stream next)) ifFalse: [self error: 'digit expected'].
	['0123456789.' includes: (c := stream next)] whileTrue.
	c = $e ifTrue: [
		('0123456789-' includes: (c := stream next)) ifFalse: [self error: 'digit expected'].
		['0123456789' includes: (c := stream next)] whileTrue].
	len := stream position - pos - 1.
	c ifNil: [len := len + 1].
	stream position: pos.
	^(stream next: len) asNumber! !

!KSSVGPathReader methodsFor: 'reading' stamp: 'yo 10/12/2012 10:58'!
readPoint
	^self readNumber @ self readNumber! !

!KSSVGPathReader class methodsFor: 'debugging' stamp: 'bf 1/17/2013 16:27'!
drawD: aString 
	"Draw the description on the screen."
	"KSSVGPathReader drawD: 'M 0 5400 L 16200 5400 16200 0
	21600 10800 16200 21600 16200 16200 0 16200 Z N'"
	| points world box shape scaleExtent scale |
	world := KSMorph new.
	world openInWorld.
	world extent: 400 @ 300.
	world window fill: Color white.
	box := KSBox new.
	world window add: box.
	points := KSSVGPathReader new readPath: aString.
	shape := KSShape new elements: {(GeziraPath new points: points) fill: Color brown}.
	box shape: shape.
	scaleExtent := world extent / box extent.
	scale := scaleExtent x min: scaleExtent y.
	box fill: Color brown.
	box borderWidth: 1 / scale.
	box borderWidth: 0. "Comment out if you want to see the border."
	box scale: scale! !
