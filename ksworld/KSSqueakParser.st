Parser subclass: #KSSqueakParser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSSqueakParser methodsFor: 'squeak compatibility' stamp: 'yo 4/27/2012 14:07'!
parse: source class: aClass
	thisContext sender selector == #methodNode ifTrue: [
		(KSParser isKScript: source) ifTrue: [
			SyntaxErrorNotification signal]].
	^ super parse: source class: aClass! !

!KSSqueakParser methodsFor: 'squeak compatibility' stamp: 'yo 4/27/2012 14:03'!
parse: sourceStream class: class category: aCategory noPattern: noPattern context: ctxt notifying: req ifFail: aBlock
	| string |
	string := sourceStream contents.
	(KSParser isKScript: string) ifTrue: [
		string := KSProtoObject compileMethodToString: string asString].
	^ super parse: string readStream class: class category: aCategory noPattern: noPattern context: ctxt notifying: req ifFail: aBlock! !

!KSSqueakParser methodsFor: 'squeak compatibility' stamp: 'ael 2/25/2013 14:46'!
parseSelector: aString
	| n |
	(KSParser isKScript: aString) ifTrue: [
		n :=  (KSParser matcherOn: aString asString readStream) apply: #nameAndArgsAndDiscardRest.
		prevEnd := n third.
		^ (String streamContents: [:strm |
			strm nextPutAll: n first.
			n second size > 0 ifTrue: [
				strm nextPut: $:.
				n second size - 1 timesRepeat: [strm nextPutAll: 'with:']]]) asSymbol
	].
	^ super parseSelector: aString! !
