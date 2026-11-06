Object subclass: #KSFont
	instanceVariableNames: 'face pointSize height ascent descent lineSkip isFixedWidth glyphs fill filledFonts'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSFont methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/19/2012 14:20'!
ppExportSpecification
	^ #(('face' #face)
		('pointSize' #pointSize)
		('fill' #fill))! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:27'!
ascent
	^ ascent! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:27'!
baseFont
	^ self! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:27'!
descent
	^ descent! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:27'!
face
	^ face! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:27'!
family
	^ face family! !

!KSFont methodsFor: 'all' stamp: 'yo 3/15/2013 18:17'!
familyName
	^ self family name! !

!KSFont methodsFor: 'all' stamp: 'yo 1/8/2013 16:31'!
fill
	^ fill! !

!KSFont methodsFor: 'all' stamp: 'yo 1/8/2013 16:31'!
glyphAt: char
	| glyphIndex |
	glyphIndex := char asInteger.
	^glyphs at: glyphIndex + 1 ifAbsent: [glyphs at: glyphIndex + 1 put: (self newGlyphAt: glyphIndex)]! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:28'!
height
	^ ascent + descent! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:28'!
isFixedWidth
	^ isFixedWidth! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:28'!
lineSkip
	^  self height! !

!KSFont methodsFor: 'all' stamp: 'yo 3/15/2013 18:17'!
name
	^ self family name! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:58'!
newGlyphAt: glyphIndex
	^ KSShape new withFont: self index: glyphIndex fill: (fill ifNil: [Color black])! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:28'!
pointSize
	^ pointSize! !

!KSFont methodsFor: 'all' stamp: 'yo 1/8/2013 16:31'!
printOn: aStream
	| fillString |
	super printOn: aStream.
	fillString := (fill isNil ifTrue: [Color black] ifFalse: [
		(fill asColor ~= Color transparent) ifTrue: [fill asColor] ifFalse: [fill]]) printString.
	aStream
		nextPut: $(;
		print: face;
		space; print: pointSize;
		space; print: ascent;
		space; print: descent;
		space; print: lineSkip;
		space; print: isFixedWidth;
		space; nextPutAll: fillString;
		nextPut: $)! !

!KSFont methodsFor: 'all' stamp: 'yo 3/15/2013 18:17'!
scale
	| sqFont |
	sqFont := TTCFont familyName: self familyName pointSize: pointSize emphasis: self style.
	sqFont := sqFont ttcDescription.
	^ (pointSize * (72.0/72.0)) / sqFont unitsPerEm.! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:59'!
style
	^ face style! !

!KSFont methodsFor: 'all' stamp: 'yo 1/8/2013 16:32'!
uncacheGlyphAt: glyphIndex
	glyphs removeKey: glyphIndex + 1! !

!KSFont methodsFor: 'all' stamp: 'yo 7/26/2012 19:29'!
withFace: typeFace size: size
	| name1 size1 sqFont scale |
	face := typeFace.
	pointSize := size.
	name1  := face family name.
	size1  := size.
	sqFont := TTCFont familyName: name1 pointSize: size1 emphasis: typeFace style.
	sqFont := sqFont ttcDescription.
	scale := self scale.
	ascent := sqFont ascender * scale.
	descent := sqFont descender negated * scale.
	isFixedWidth := false.
	glyphs := IdentityDictionary new.! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:37'!
bold
	^ (self face bold withSize: self pointSize) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 7/26/2012 19:27'!
fill: aFill
	| key |
	(aFill isNil or: [aFill asColor = Color black]) ifTrue: [^ self].
	aFill isColor ifTrue: [key := aFill] ifFalse: [
		(fill class == GeziraFillUniform)
			ifTrue: [key := aFill asColor]
			ifFalse: [key := aFill]].
	
	filledFonts ifNil: [filledFonts := Dictionary new].
	^ filledFonts at: key ifAbsentPut: [(KSFilledFont new withFace: face size: pointSize) withBaseFont: self fill: aFill asGeziraFill].! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:38'!
italic
	^ (self face italic withSize: self pointSize) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:38'!
normal
	^ (self face normal withSize: self pointSize) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:38'!
unBold
	^ (self face unBold withSize: self pointSize) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:38'!
unItalic
	^ (self face unItalic withSize: self pointSize) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:39'!
unUnderlined
	^ (self face unUnderlined withSize: self pointSize) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:39'!
underlined
	^ (self face underlined withSize: self pointSize) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:15'!
withFamily: aString
	^ (((KSFamily withName: aString) withStyle: self style) withSize: self pointSize) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:15'!
withSize: anInteger
	^ ((self family withStyle: self style) withSize: anInteger) fill: self fill! !

!KSFont methodsFor: 'new font' stamp: 'yo 3/15/2013 18:04'!
withStyle: anInteger
	^ ((self family withStyle: anInteger) withSize: self pointSize) fill: self fill! !

!KSFont class methodsFor: '*ksobjects-pushpull' stamp: 'yo 1/11/2013 13:22'!
ppCreateInstanceFromSexp: sexp ref: ref from: from to: to
	| face pointSize fill |
	face := self fromPPSexp: sexp elements first from: from to: to.
	pointSize := self fromPPSexp: sexp elements second from: from to: to.
	sexp elements size > 2 ifTrue: [
		fill := self fromPPSexp: sexp elements third from: from to: to.
		^ (face withSize: pointSize) fill: fill]
	ifFalse: [
		^ (face withSize: pointSize)].! !

!KSFont class methodsFor: 'defaults' stamp: 'yo 7/26/2012 19:43'!
defaultFont
	^ ((KSFamily withName: #DejaVuSans) withStyle: 0) withSize: KSFamily defaultFontSize! !

!KSFont class methodsFor: 'defaults' stamp: 'yo 1/28/2013 15:37'!
scriptingCaptionFont
	^ ((KSFamily withName: 'Calibri') withStyle: 1) withSize: 11.! !

!KSFont class methodsFor: 'defaults' stamp: 'yo 1/28/2013 10:44'!
scriptingFont
	^ ((KSFamily withName: 'Calibri') withStyle: 1) withSize: 16.! !
