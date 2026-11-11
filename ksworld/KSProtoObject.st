IdentityDictionary subclass: #KSProtoObject
	instanceVariableNames: ''
	classVariableNames: 'Undefined'
	poolDictionaries: ''
	category: 'KScript'!

!KSProtoObject methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/14/2012 10:55'!
ppContentsInto: newElem context: dictionary
	| cls |
	super ppContentsInto: newElem context: dictionary.
	self class isUniClass ifTrue: [
		cls := dictionary lookup: self class.
		cls ifNil: [^ self].
		newElem attributeAt: #uniclass put: cls ref.
	].! !

!KSProtoObject methodsFor: '*ksobjects-pushpull' stamp: 'yo 10/8/2012 13:15'!
ppIgnoreFieldNames
	^ #()! !

!KSProtoObject methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/13/2012 16:51'!
ppIndexFieldsInto: sexp context: dictionary
	| ind keys sorted |
	ind := 0.
	keys := self keys.
	sorted := [keys sorted]
				on: Error
				do: [:ex | keys].
	sexp attributeAt: #size put: self size printString.

	sexp addDictionaryElement: [:addBlock |
		ind := ind + 1.
		ind <= self size ifTrue: [
			| key |
			key := sorted at: ind.
			addBlock value: ind value: key value: (self at: key).
			true]
		ifFalse: [false]]
	context: dictionary.! !

!KSProtoObject methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/14/2012 23:20'!
ppInitializeFrom: sexp from: from to: to
	sexp elements do: [:each |
		to readSlot: each into: self from: from to: to].! !

!KSProtoObject methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/14/2012 23:24'!
ppIsDictionary
	^ true! !

!KSProtoObject methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/20/2012 00:28'!
ppStoreString
	^ 'undefined'! !

!KSProtoObject methodsFor: 'printing' stamp: 'yo 8/31/2012 14:00'!
printOn: aStream
	| sorted |
	self == Undefined
		ifTrue: [aStream nextPutAll: 'undefined']
		ifFalse: [
			aStream
				nextPutAll: self class name;
				nextPutAll: '('.
				sorted := self keys.
				sorted := [sorted sorted] on: Error do: [sorted].
				sorted do: [:k |
					aStream nextPutAll: k printString; nextPutAll: '->'.
					((self at: k) isLiteral or: [(self at: k) == self class undefined or: [(self at: k) isPoint]]) ifTrue: [
						aStream nextPutAll: (self at: k) asString]
					ifFalse: [
						aStream nextPutAll: '...']] separatedBy: [aStream nextPutAll: ', '].
			aStream nextPutAll: ')']! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 7/6/2012 10:57'!
= other
	^ other == self! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 4/11/2012 15:39'!
asBoolean
	^ self ~~ Undefined and: [super asBoolean]! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 7/6/2012 10:57'!
becomeUniClass
	"Make the receiver an instance of a unique class"
	self class isUniClass ifTrue: [^ self].
	[(self class newUniClass) adoptInstance: self]
 		on: Error do:[:ex| ex resume: true].! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 9/5/2013 16:48'!
eval2: aString
	^ self evalSqueakString: (self class compileToString2: aString)! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 1/21/2013 16:20'!
eval: aString
	^ self evalSqueakString: (self class compileToString: aString)! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 1/21/2013 16:19'!
evalSqueakString: aString
	^ Compiler new evaluate: aString in: nil to: self.! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 4/12/2013 13:43'!
evalToMethod: aString
	| source |
	(KSParser2 isKScript2: aString) ifTrue: [
		source := self class compileMethodToString2: aString]
	ifFalse: [
		source := self class compileMethodToString: aString].


	^ self class compile: source classified: '*generated'.! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 7/6/2012 10:57'!
hash
	^ self identityHash! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 4/11/2012 15:49'!
ifNotExist: aBlock
	^ self == Undefined ifTrue: [aBlock value] ifFalse: [self]! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 4/17/2012 10:08'!
ksAt: key
"	(KSThrow new value: ({#error->'undefined has no properties'. #key->key} as: KSObject)) signal."
	^ KSProtoObject undefined! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'ael 4/10/2012 23:46'!
ksAt: key put: val 
	self error: 'undefined cannot have fields'.
	^ self at: key put: val! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 7/6/2012 10:57'!
ksKeys
	| obj keys |
	obj := self.
	keys := IdentitySet new.
	[
		obj keys do: [:k | (k isSymbol and: [(k beginsWith: '__') and: [k endsWith: '__']]) ifFalse: [keys add: k]].
		obj == self class undefined ifTrue: [false] ifFalse: [obj := obj ksAt: #'__proto__'. true]
	] whileTrue.
	^ keys asArray! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 7/6/2012 10:58'!
ksLocalKeys
	^ self keys! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 7/6/2012 10:58'!
ksNot
	^ self == Undefined or: [super ksNot]! !

!KSProtoObject methodsFor: 'squeak interface' stamp: 'yo 7/6/2012 10:58'!
makeChild
	^ self class new
		at: #'__proto__' put: self;
		yourself! !

!KSProtoObject class methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/20/2012 00:32'!
ppInstanceIsLiteral
	^ self == KSProtoObject! !

!KSProtoObject class methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/20/2012 00:10'!
ppNewWithSexp: sexp
	^ self undefined! !

!KSProtoObject class methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/20/2012 10:04'!
ppReadFromString: aString
	^ Undefined! !

!KSProtoObject class methodsFor: 'accessing' stamp: 'yo 7/12/2012 10:09'!
keys: anObject
	^ anObject ksKeys! !

!KSProtoObject class methodsFor: 'accessing' stamp: 'yo 7/12/2012 10:09'!
localKeys: anObject
	^ anObject ksLocalKeys! !

!KSProtoObject class methodsFor: 'accessing' stamp: 'yo 7/12/2012 10:08'!
undefined
	^ Undefined! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 4/12/2013 13:37'!
compileMethodToString2: aStringOrStream
	^ self compileMethodToString2: aStringOrStream forClass: self.! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 4/12/2013 19:26'!
compileMethodToString2: aStringOrStream forClass: cls
	| stream tree attrs decled fields |
	stream := aStringOrStream isString ifTrue: [aStringOrStream readStream] ifFalse: [aStringOrStream].
	tree := KSParser2 matchStream: stream with: #method withArgs: #() withPlaybackDebugging: false.
	decled := KSDeclVisitor match: tree with: #methodDecls.
	fields := KSVariableAttributor2 match: decled with: #start.
	attrs := KSQuoteAttributor2 match: fields with: #start.
	^ OMeta2Flattener match: (
			KSCompiler match: (
				KSBlockSimplifier match: (
					KSReturnVisitor2 match: (
						KSQuoteTranslator2 match: fields with: #start withArgs: {attrs})
					with: #markEnd)
				with: #simplify)
			with: #compileForClass withArgs: {cls})
		with: #flatten.! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 1/18/2013 10:57'!
compileMethodToString: aStringOrStream
	^ self compileMethodToString: aStringOrStream forClass: self.! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 1/18/2013 11:07'!
compileMethodToString: aStringOrStream forClass: cls
	| stream tree attrs |
	stream := aStringOrStream isString ifTrue: [aStringOrStream readStream] ifFalse: [aStringOrStream].
	tree := KSParser matchStream: stream with: #method withArgs: #() withPlaybackDebugging: false.
	attrs := KSQuoteAttributor match: tree with: #start.
	^ OMeta2Flattener match: (
			KSCompiler match: (
				KSBlockSimplifier match: (
					KSReturnVisitor match: (
						KSDeclVisitor match: (
							KSQuoteTranslator match: tree with: #start withArgs: {attrs})
						with: #methodDecls)
					with: #markEnd)
				with: #simplify)
			with: #compileForClass withArgs: {cls})
		with: #flatten.! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 4/12/2013 13:01'!
compileToString2: aString
	^ self compileToString2: aString forClass: self! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 4/12/2013 13:05'!
compileToString2: aString forClass: cls
	| attrs tree decled fields |
	tree := KSParser2 matchAll: aString with: #start.
	decled := KSDeclVisitor match: tree with: #decls.
	fields := KSVariableAttributor2 match: decled with: #start.
	attrs := KSQuoteAttributor2 match: fields with: #start.
	^ OMeta2Flattener match: (
			KSCompiler match: (
				KSBlockSimplifier match: (
					KSReturnVisitor2 match: (
						KSQuoteTranslator2 match: fields with: #start withArgs: {attrs})
					with: #markEnd)
				with: #simplify)
			with: #compileForClass withArgs: {cls})
		with: #flatten.! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 1/18/2013 10:58'!
compileToString: aString
	^ self compileToString: aString forClass: self! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 1/18/2013 11:07'!
compileToString: aString forClass: cls
	| attrs tree |
	tree := KSParser matchAll: aString with: #start.
	attrs := KSQuoteAttributor match: tree with: #start.
	^ OMeta2Flattener match: (
			KSCompiler match: (
				KSBlockSimplifier match: (
					KSReturnVisitor match: (
						KSDeclVisitor match: (
							KSQuoteTranslator match: tree with: #start withArgs: {attrs})
						with: #decls)
					with: #markEnd)
				with: #simplify)
			with: #compileForClass withArgs: {cls})
		with: #flatten.! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 7/12/2012 10:09'!
compilerClass
        ^ KSSqueakCompiler! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 9/5/2013 16:47'!
eval2: aString
	^ Compiler evaluate: (self compileToString2: aString) notifying: nil logged: false! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 7/12/2012 10:09'!
eval: aString
	^ Compiler evaluate: (self compileToString: aString) notifying: nil logged: false! !

!KSProtoObject class methodsFor: 'compilation' stamp: 'yo 7/12/2012 10:09'!
parserClass
        ^ KSSqueakParser! !

!KSProtoObject class methodsFor: 'initialization' stamp: 'ael 1/10/2013 16:17'!
initialize
"
	KSProtoObject initialize. 
"
	Undefined := self new.! !

!KSProtoObject class methodsFor: 'instance creation' stamp: 'yo 1/10/2013 22:10'!
new
	^ super new initialize; yourself! !

!KSProtoObject class methodsFor: 'queries' stamp: 'bf 1/24/2013 10:14'!
eventStreamClass
	^ Smalltalk at: #KSNewEventStream! !

!KSProtoObject class methodsFor: 'uniclass' stamp: 'yo 7/12/2012 10:09'!
acceptsLoggingOfCompilation
	"Log changes for LObject base classes, but, if the #logUniclassCode preference is turned off, not for automatically-created subclasses like LDBJrPage5SP2"
	^ self isUniClass not or: [Preferences logUniclassCode]! !

!KSProtoObject class methodsFor: 'uniclass' stamp: 'yo 9/12/2012 15:56'!
newUniClass
	"Make a new uni class just like me"
	| baseClass newClass |
	baseClass := self.
	"Create a new anonymous subclass"
	newClass := ClassBuilder new
		newSubclassOf: baseClass
		type: baseClass typeOfClass
		instanceVariables: '' substrings
		from: (self == baseClass ifFalse:[self]).
	baseClass removeSubclass: newClass.
	^newClass! !

!KSProtoObject class methodsFor: 'workaround' stamp: 'yo 3/13/2012 11:13'!
inspectorClass
	"Answer the class of the inspector to be used on the receiver.  Called by inspect; 
	use basicInspect to get a normal (less useful) type of inspector."

	^ Inspector! !

!KSProtoObject class methodsFor: 'workaround' stamp: 'yo 3/23/2012 16:30'!
isUniClass

	^ name isNil! !
