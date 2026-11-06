Object subclass: #KSFamily
	instanceVariableNames: 'name faces'
	classVariableNames: 'DefaultFontSize Families'
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSFamily methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/19/2012 14:11'!
ppExportSpecification
	"Public interface.  If it is not empty, only the instance variables or fields listed here will be written out."
	^ #(('name' #name))! !

!KSFamily methodsFor: 'all' stamp: 'yo 1/8/2013 16:31'!
initializeWithName: nameSymbol
	name := nameSymbol.
	faces := Array new: 8.	"underline | slanted | bold"! !

!KSFamily methodsFor: 'all' stamp: 'yo 7/26/2012 18:08'!
name
	^ name! !

!KSFamily methodsFor: 'all' stamp: 'yo 7/26/2012 18:08'!
printOn: aStream
	super printOn: aStream.
	aStream
		nextPut: $(;
		print: name;
		nextPut: $)! !

!KSFamily methodsFor: 'all' stamp: 'yo 1/8/2013 16:31'!
withStyle: styleIndex
	^ (faces at: styleIndex + 1) ifNil: [faces at: styleIndex + 1 put: (KSFace new initializeWithFamily: self style: styleIndex)]! !

!KSFamily class methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/19/2012 14:09'!
ppCreateInstanceFromSexp: sexp ref: ref from: from to: to
	^ self withName: (self fromPPSexp: sexp elements first from: from to: to).! !

!KSFamily class methodsFor: 'accessing' stamp: 'yo 7/26/2012 18:07'!
families
	^ Families! !

!KSFamily class methodsFor: 'defaults' stamp: 'yo 7/26/2012 18:07'!
defaultFontSize
	"Answer the default size of font to use; if not yet set, set it at this time to 13."
	^ DefaultFontSize ifNil: [DefaultFontSize := 13]! !

!KSFamily class methodsFor: 'defaults' stamp: 'yo 7/26/2012 18:07'!
defaultFontSize: aSize
	DefaultFontSize := aSize! !

!KSFamily class methodsFor: 'initialization' stamp: 'yo 7/26/2012 18:07'!
initialize
"
	KSFamily initialize
"
	Families := IdentityDictionary new.
	(TTFontDescription allInstances collect: [:e | e name]) asSet do: [:e |
		self withName: e asSymbol].
	DefaultFontSize := nil.! !

!KSFamily class methodsFor: 'instance creation' stamp: 'yo 7/26/2012 18:08'!
withName: nameString
	| nameSymbol |
    nameSymbol := (nameString copyWithout: Character space) asSymbol.
    ^Families at: nameSymbol ifAbsent: [Families at: nameSymbol put: (self new initializeWithName: nameSymbol)]! !
