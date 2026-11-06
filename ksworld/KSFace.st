Object subclass: #KSFace
	instanceVariableNames: 'family style fonts'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSFace methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/19/2012 14:11'!
ppExportSpecification
	^ #(('family' #family)
		('style' #style))! !

!KSFace methodsFor: 'accessing' stamp: 'yo 7/26/2012 18:10'!
family
	^ family! !

!KSFace methodsFor: 'accessing' stamp: 'yo 7/26/2012 18:10'!
style
	^ style! !

!KSFace methodsFor: 'family' stamp: 'yo 7/26/2012 18:10'!
bold
	^ family withStyle: (style bitOr: 1)! !

!KSFace methodsFor: 'family' stamp: 'yo 7/26/2012 18:10'!
italic
	^ family withStyle: (style bitOr: 2)! !

!KSFace methodsFor: 'family' stamp: 'yo 1/8/2013 16:30'!
normal
	^ family withStyle: 0! !

!KSFace methodsFor: 'family' stamp: 'yo 3/15/2013 18:19'!
unBold
	^ family withStyle: (style bitAnd: 15 - 1)! !

!KSFace methodsFor: 'family' stamp: 'yo 3/15/2013 18:20'!
unItalic
	^ family withStyle: (style bitAnd: 15 - 2)! !

!KSFace methodsFor: 'family' stamp: 'yo 3/15/2013 18:21'!
unUnderlined
	^family withStyle: (style bitAnd: 15 - 4)! !

!KSFace methodsFor: 'family' stamp: 'yo 1/8/2013 16:30'!
underlined
	^family withStyle: (style bitOr: 4)! !

!KSFace methodsFor: 'initialization' stamp: 'yo 1/8/2013 16:29'!
initializeWithFamily: fontFamily style: styleIndex
	family := fontFamily.
	style := styleIndex.
	fonts := Dictionary new.! !

!KSFace methodsFor: 'initialization' stamp: 'yo 7/26/2012 19:42'!
withSize: pointSize
	^fonts at: pointSize ifAbsent: [fonts at: pointSize put: (KSFont new withFace: self size: pointSize)]! !

!KSFace methodsFor: 'printing' stamp: 'yo 7/26/2012 18:10'!
printOn: aStream
	super printOn: aStream.
	aStream
		nextPut: $(;
		print: family;
	space; print: style;
	nextPut: $)! !

!KSFace class methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/19/2012 14:13'!
ppCreateInstanceFromSexp: sexp ref: ref from: from to: to
	| family style |
	family := self fromPPSexp: sexp elements first from: from to: to.
	style := self fromPPSexp: sexp elements second from: from to: to.
	^ family withStyle: style! !
