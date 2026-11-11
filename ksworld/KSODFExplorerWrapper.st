ObjectExplorerWrapper subclass: #KSODFExplorerWrapper
	instanceVariableNames: 'document'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-ODFReader'!

!KSODFExplorerWrapper commentStamp: 'tak 3/25/2011 09:49' prior: 0!
See class comment of KSODFExplorer.!

!KSODFExplorerWrapper methodsFor: 'accessing' stamp: 'tak 10/6/2011 16:00'!
attributeContents
	"Return explorerContents of the XML attributes. Ignore xmlns "
	item isTag ifFalse: [^ #()]. "In case of XMLDocument, etc."
	^ self itemAttributes explorerContents
		reject: [:each | each itemName beginsWith: '''xmlns:']! !

!KSODFExplorerWrapper methodsFor: 'accessing' stamp: 'tak 3/14/2011 11:30'!
contentString: xml 
	^ String
		streamContents: [:aStream | xml elementsAndContents
				do: [:each | aStream
						nextPutAll: (each isText
								ifTrue: [each string]
								ifFalse: [self contentString: each])]]! !

!KSODFExplorerWrapper methodsFor: 'accessing' stamp: 'tak 10/6/2011 15:34'!
contents
	| contents |
	item class = KSODFDocument
		ifTrue: [^ Array
				with: (self class item: item meta name: 'meta' document: document)
				with: (self class item: item content name: 'content' document: document)
				with: (self class item: item styles name: 'styles' document: document)].
	contents := item elementsAndContents
				collect: [:each | each isText
						ifTrue: [self class item: each document: document]
						ifFalse: [self class item: each document: document]].
	^ self attributeContents , contents! !

!KSODFExplorerWrapper methodsFor: 'accessing' stamp: 'tak 3/14/2011 15:51'!
hasContents
	^ item isText not! !

!KSODFExplorerWrapper methodsFor: 'accessing' stamp: 'tak 10/6/2011 16:17'!
isStyle: aString
	"Return true if the argument is a key for style"
	^ #('text:style-name' 'draw:style-name' 'draw:text-style-name') includes: aString! !

!KSODFExplorerWrapper methodsFor: 'accessing' stamp: 'tak 10/6/2011 16:07'!
itemAttributes
	"Return a dictionary of attributes of the item.
	If a key represents a style, actual style element is set as the value"
	| dict |
	dict := Dictionary new.
	item attributes
		keysAndValuesDo: [:key :value | 
			(self isStyle: key)
						ifTrue: [dict at: key, '=', value put: (document styleNamed: value)]
						ifFalse: [dict at: key put: value]].
	^ dict! !

!KSODFExplorerWrapper methodsFor: 'converting' stamp: 'tak 3/31/2011 09:55'!
asString
	itemName
		ifNotNil: [^ itemName].
	item isText
		ifTrue: [^ item printString].
	item class = KSODFDocument
		ifTrue: [^ 'Document'].
	item class = XMLDocument
		ifTrue: [^ 'Document'].
	item localName caseOf: {
		[#text:p] -> [^ item localName asString , '('
			, (self contentString: item) , ')'].
		[#draw:page] -> [^ self asStringWith: #draw:name].
		[#style:style] -> [^ self asStringWith: #style:name].
		[#draw:gradient] -> [^ self asStringWith: #draw:name].
		[#'draw:fill-image'] -> [^ self asStringWith: #draw:name].
		[#draw:marker] -> [^ self asStringWith: #draw:name].
		[#'draw:stroke-dash'] -> [^ self asStringWith: #draw:name].
		[#'style:page-layout'] -> [^ self asStringWith: #style:name].
		[#'style:presentation-page-layout'] -> [^ self asStringWith: #style:name].
		[#'text:list-style'] -> [^ self asStringWith: #style:name]}
		 otherwise: [^ self nameBase]! !

!KSODFExplorerWrapper methodsFor: 'converting' stamp: 'tak 3/31/2011 09:55'!
asStringWith: aSymbol 
	^ self nameBase , '('
		, (item attributeAt: aSymbol) , ')'! !

!KSODFExplorerWrapper methodsFor: 'converting' stamp: 'tak 3/31/2011 10:00'!
nameBase
	| id |
	id := item @ #draw:id.
	^ item localName asString
		, (id isEmpty
				ifTrue: ['']
				ifFalse: ['(' , id, ')'])! !

!KSODFExplorerWrapper methodsFor: 'initialize-release' stamp: 'tak 10/6/2011 15:54'!
item: anObject name: aString document: anODFDocument
	self setItem: anObject name: aString model: nil.
	document := anODFDocument.! !

!KSODFExplorerWrapper class methodsFor: 'instance creation' stamp: 'tak 10/6/2011 15:32'!
item: item document: anODFDocument
	^ self item: item name: nil document: anODFDocument! !

!KSODFExplorerWrapper class methodsFor: 'instance creation' stamp: 'tak 10/6/2011 15:53'!
item: item name: itemName document: anODFDocument
	^ self new
		item: item
		name: itemName
		document: anODFDocument.! !
