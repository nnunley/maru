Compiler subclass: #KSSqueakCompiler
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KScript'!

!KSSqueakCompiler methodsFor: 'squeak compatibility' stamp: 'yo 4/12/2013 21:07'!
compile: textOrStream in: aClass classified: aCategory notifying: aRequestor ifFail: failBlock
	"Answer a MethodNode for the argument, textOrStream. If the 
	MethodNode can not be created, notify the argument, aRequestor; if 
	aRequestor is nil, evaluate failBlock instead. The MethodNode is the root 
	of a parse tree. It can be told to generate a CompiledMethod to be 
	installed in the method dictionary of the argument, aClass."
	| source origCodeStream |
	source := textOrStream contents asString.
	origCodeStream := source readStream.
	self from: origCodeStream class: aClass context: nil notifying: aRequestor.
	[
		(KSParser2 isKScript2: source) ifTrue: [
			source := aClass compileMethodToString2: origCodeStream]
		ifFalse: [
			(KSParser isKScript: source) ifTrue: [
				source := aClass compileMethodToString: origCodeStream]]
	] on: OM2Fail do: [
		self notify: '<-- parse error around here -->' at: origCodeStream position.
		^ failBlock value
	].	
	^ super compile: source in: aClass classified: aCategory notifying: aRequestor ifFail: failBlock.! !

!KSSqueakCompiler methodsFor: 'squeak compatibility' stamp: 'yo 7/6/2012 10:59'!
compile: textOrStream in: aClass notifying: aRequestor ifFail: failBlock
	^ self compile: textOrStream in: aClass classified: nil notifying: aRequestor ifFail: failBlock! !

!KSSqueakCompiler methodsFor: 'squeak compatibility' stamp: 'yo 7/6/2012 10:59'!
parse: aStream class: aClass noPattern: noPattern context: ctxt notifying: req ifFail: aBlock
	^ self parse: aStream class: aClass category: nil noPattern: noPattern context: ctxt notifying: req ifFail: aBlock ! !

!KSSqueakCompiler methodsFor: 'squeak compatibility' stamp: 'yo 3/6/2012 15:16'!
parser
	^ self parserClass new! !

!KSSqueakCompiler methodsFor: 'squeak compatibility' stamp: 'yo 7/6/2012 10:59'!
parserClass
	^ KSSqueakParser! !
