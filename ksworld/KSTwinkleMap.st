Morph subclass: #KSTwinkleMap
	instanceVariableNames: 'paths window map overlay handStreams'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 19:00'!
addPathFrom: src to: elem
	| dict d s |
	s := self positionOf: src.
	d := self positionOf: elem.
	(s notNil and: [d notNil]) ifTrue: [
		src homeObject name = 'halo' ifFalse: [
			(src homeObject name = 'hand' or: [elem homeObject name = 'hand']) ifFalse: [
				dict := paths at: elem ifAbsentPut: [IdentityDictionary new].
				dict at: src put: (Array with: s with: d).
			] ifTrue: [
				handStreams add: {src. elem}]]]! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/9/2013 18:45'!
allEdgesDo: aBlock
	paths do: [:dict |
		dict do: [:pair |
			aBlock value: pair first value: pair second]].! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 13:59'!
bDraw
	| g |
	map fillColor: (Color black alpha: 0.5).
	g := BalloonCanvas on: map.
	self allEdgesDo: [:s :d |
		g line: s to: d width: 1 color: (self colorOf: s)].
	^ map! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 15:11'!
clearOverlay
	overlay fillColor: Color transparent.! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 17:43'!
colorOf: aStream
	^ (Color h: aStream name hash \\ 360 s: 0.2 v: 1) asGeziraFill! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 16:13'!
count
	| c |
	c := 0.
	self allEdgesDo: [:s :d |
		c := c + 1].
	^ c! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/11/2013 09:05'!
createMap: aWindow
	| arg |
	window := aWindow.
	map := Form extent: window extent depth: 32.
	overlay := Form extent: window extent depth: 32.
	aWindow withAllContentsDo: [:box |
		box do: [:elem |
			elem isEventStream ifTrue: [
				elem type = 'switchColE' ifFalse: [
					elem eventSourcesCache ifNotNilDo: [:cache |
						cache do: [:src |
							src isEventStream ifTrue: [
								self addPathFrom: src to: elem]]]]
				ifTrue: [
						| col |
						col := (elem lookup: elem argCollection) do: [:argObj |
							arg := argObj ksAt: elem streamName.
							arg isEventStream ifTrue: [
								self addPathFrom: arg to: elem]]]]]].
	self gDraw.! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 14:20'!
draw
	map displayOn: Display at: 0@400 rule: 34.
	overlay displayOn: Display at: 0@400 rule: 34.! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 15:33'!
drawOn: aCanvas
	aCanvas translucentImage: map at: bounds origin sourceRect: map boundingBox.
	aCanvas translucentImage: overlay at: bounds origin sourceRect: overlay boundingBox.
	! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 12:07'!
gDraw
	| g path grad |
	g := GeziraCanvas on: map.
	grad := GeziraFillRadialGradient new.
	grad center: map boundingBox center.
	grad radius: map boundingBox height / 2.0.
	grad stops: {0.0 -> (Color black alpha: 0.8). 1.0 -> (Color blue muchDarker alpha: 0.5)}.
	g fill: grad.
	g drawRectangle: map boundingBox.
	self allEdgesDo: [:s :d |
		path := GeziraPath line: s to: d.
			g fill: (self colorOf: s).
			g strokePath: path floats width: 1].
	^ map! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 18:58'!
initialize
	super initialize.
	paths := IdentityDictionary new.
	handStreams := OrderedCollection new.! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 14:38'!
map
	^ map! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 12:09'!
overlay
	^ overlay! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 17:58'!
positionOf: aStream
	aStream homeObject isBox ifTrue: [
		| hashRatio x y home center ext origin |
		home := aStream homeObject.
		center := home globalPointFor: home extent / 2.0.
		origin := home globalPointFor: 0@0.
		ext := center - origin.
		hashRatio := (aStream identityHash asFloat / 4096.0) * Float pi * 2.0.
		x := hashRatio cos * 10.0.
		y := hashRatio sin * 10.0.
		^ center + (x@y).
	].
	^ nil! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 16:09'!
update: src to: dst
	paths at: dst ifPresent: [:dict |
		dict at: src ifPresent: [:pair |
			| path g |
			path := GeziraPath line: pair first to: pair second.
			g := GeziraCanvas on: overlay.
			g fill: (self colorOf: src).
			g strokePath: path floats width: 2]].! !

!KSTwinkleMap methodsFor: 'all' stamp: 'yo 9/10/2013 19:03'!
updateHandStreams! !
