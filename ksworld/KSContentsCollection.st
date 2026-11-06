Object subclass: #KSContentsCollection
	instanceVariableNames: 'array firstIndex lastIndex indexCache'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSContentsCollection methodsFor: '*ksobjects-pushpull' stamp: 'yo 9/19/2012 23:19'!
ppInitializeFrom: sexp from: from to: to
	sexp elements do: [:elem |
		self add: (self fromPPSexp: elem from: from to: to)].! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:15'!
after: target ifAbsent: exceptionBlock
	"Answer the element after target.  Answer the result of evaluation
	the exceptionBlock if target is not in the receiver, or if there are 
	no elements after it."
	| index |
	index := self indexOf: target.
	^ (index = 0 or: [index = self size])
		ifTrue: [exceptionBlock value]
		ifFalse: [self at: index + 1]! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:08'!
asArray
	^ (self arrayClass new: self size) replaceFrom: 1 to: self size with: array startingAt: firstIndex.! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
at: anInteger 
	"Answer my element at index anInteger. at: is used by a knowledgeable
	client to access an existing element"
	(anInteger < 1 or: [anInteger + firstIndex - 1 > lastIndex])
		ifTrue: [self errorNoSuchElement]
		ifFalse: [self updateIndexCache: anInteger.
				^ array at: anInteger + firstIndex - 1].! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:15'!
at: index ifAbsent: exceptionBlock 
	"Answer the element at my position index. If I do not contain an element at index, answer the result of evaluating the argument, exceptionBlock."
	(index between: 1 and: self size) ifTrue: [^ self at: index].
	^ exceptionBlock value! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:15'!
at: anInteger put: anObject 
	"Put anObject at element index anInteger. at:put: cannot be used to
	append, front or back, to an ordered collection; it is used by a
	knowledgeable client to replace an element."
	| index |
	index := anInteger.
	(index < 1 or: [index + firstIndex - 1 > lastIndex])
		ifTrue: [self errorNoSuchElement. ^ anObject]
		ifFalse: [^ array at: index + firstIndex - 1 put: anObject].! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
atPin: index 
	"Return the index'th element of me if possible.
	Return the first or last element if index is out of bounds."
	index < 1 ifTrue: [^ self first].
	index > self size ifTrue: [^ self last].
	^ self at: index! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
atWrap: index 
	"Answer the index'th element of the receiver.  If index is out of bounds,
	let it wrap around from the end to the beginning until it is in bounds."
	^ self at: index - 1 \\ self size + 1! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
atWrap: index put: value
	"Store value into the index'th element of the receiver.  If index is out
	of bounds, let it wrap around from the end to the beginning until it 
	is in bounds. Answer value."
	^ self at: index  - 1 \\ self size + 1 put: value! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
before: target ifAbsent: exceptionBlock
	"Answer the receiver's element immediately before target. Answer
	the result of evaluating the exceptionBlock if target is not an element
	of the receiver, or if there are no elements before it."
	| index |
	index _ self indexOf: target.
	^ index <= 1
		ifTrue: [exceptionBlock value]
		ifFalse: [self at: index - 1]! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
capacity
	"Answer the current capacity of the receiver."
	^ array size! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
first
	^ self at: 1! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:08'!
identityIndexOf: anElement ifAbsent: exceptionBlock
	"Answer the index of anElement within the receiver. If the receiver does 
	not contain anElement, answer the result of evaluating the argument, 
	exceptionBlock."
	1 to: self size do:
		[:i | (self at: i) == anElement ifTrue: [^ i]].
	^ exceptionBlock value! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
indexOf: x
	^ self indexOf: x ifAbsent: [0].! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
indexOf: anElement ifAbsent: aBlock
	"Assume anElement is near an element that we have accessed recently."
	| indSlow cIndex ind |
	self size = 0 ifTrue: [^ aBlock value].
	cIndex := indexCache size.
	[cIndex > 0 and: [(ind := indexCache at: cIndex) notNil]] whileTrue: [
		(ind <= self size and: [(array at: ind + firstIndex - 1) == anElement]) ifTrue: [^ ind].
		(ind < self size and: [(array at: ind+1 + firstIndex - 1) == anElement]) ifTrue: [
			self updateIndexCache: ind+1. ^ ind+1].
		(ind-1 <= self size and: [ind > 1 and: [(array at: ind-1 + firstIndex - 1) == anElement]]) ifTrue: [
			self updateIndexCache: ind-1. ^ ind-1].
		cIndex := cIndex - 1.
	].
	indSlow :=  self identityIndexOf: anElement ifAbsent: [0]. "exhaustive search"
	indSlow = 0
		ifTrue: [aBlock value]
		ifFalse: [self updateIndexCache: indSlow].
	^ indSlow! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
last
	self size = 0 ifTrue: [^ self errorNoSuchElement].
	^ self at: self size! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:17'!
second
	^ self at: 2! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:39'!
size
	^ lastIndex - firstIndex + 1! !

!KSContentsCollection methodsFor: 'accessing' stamp: 'yo 7/17/2012 10:39'!
third
	^ self at: 3! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:10'!
add: newObject
	^self addLast: newObject! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
add: newObject after: oldObject 
	"Add the argument, newObject, as an element of the receiver. Put it in 
	the sequence just succeeding oldObject. Answer newObject."
	^ self insert: newObject before: (self find: oldObject) + 1.! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
add: newObject afterIndex: index
	"Add the argument, newObject, as an element of the receiver. Put it in 
	the sequence just after index. Answer newObject."
	^ self insert: newObject before: firstIndex + index.! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
add: newObject before: oldObject 
	"Add the argument, newObject, as an element of the receiver. Put it in 
	the sequence just preceding oldObject. Answer newObject."
	^ self insert: newObject before: (self find: oldObject).! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
add: newObject beforeIndex: index 
	"Add the argument, newObject, as an element of the receiver. Put it in 
	the sequence just before index. Answer newObject."
	^ self add: newObject afterIndex: index - 1.! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
addAll: aCollection 
	"Add each element of aCollection at my end. Answer aCollection."
	^ self addAllLast: aCollection! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:14'!
addAllLast: col
	"Add newObject to the end of the receiver. Answer newObject."
	lastIndex + col size > array size ifTrue: [self makeRoomAtLastFor: col size].
	array replaceFrom: lastIndex + 1 to: col size + lastIndex with: col startingAt: 1.
	lastIndex := lastIndex + col size.
	^ col! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:14'!
addFirst: newObject 
	"Add newObject to the beginning of the receiver. Answer newObject."
	firstIndex = 1 ifTrue: [self makeRoomAtFirst].
	firstIndex := firstIndex - 1.
	array at: firstIndex put: newObject.
	^ newObject! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:14'!
addLast: newObject 
	"Add newObject to the end of the receiver. Answer newObject."
	lastIndex = array size ifTrue: [self makeRoomAtLast].
	lastIndex := lastIndex + 1.
	^ array at: lastIndex put: newObject.! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:14'!
at: index ifAbsentPut: block
	"Return value at index, however, if value does not exist (nil or out of bounds) then add block's value at index (growing self if necessary)"
	| v |
	index <= self size ifTrue: [
		^ (v := self at: index)
			ifNotNil: [v]
			ifNil: [self at: index put: block value]
	].
	[self size < index] whileTrue: [self add: nil].
	^ self at: index put: block value! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:15'!
emptyCheck
	self isEmpty ifTrue: [self errorEmptyCollection]! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
grow
	"Become larger. Typically, a subclass has to override this if the subclass
	adds instance variables."
	| newArray |
	newArray := self arrayClass new: self size + self growSize.
	newArray replaceFrom: 1 to: array size with: array startingAt: 1.
	array := newArray! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
grow: n
	"Become larger. Typically, a subclass has to override this if the subclass
	adds instance variables."
	| newArray |
	newArray := self arrayClass new: self size + (self growSize: n).
	newArray replaceFrom: 1 to: array size with: array startingAt: 1.
	array := newArray! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
growSize
	^ array size max: 2! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:08'!
growSize: n
	^ (array size + n) max: 2! !

!KSContentsCollection methodsFor: 'adding' stamp: 'yo 7/17/2012 10:15'!
reorder: anElement beAt: nth
	"Move anElement so that it becomes the nth element in the collection."
	| oldRawInd |
	oldRawInd := self find: anElement.
	oldRawInd - firstIndex + 1 = nth ifTrue: [^ self]. 	"already there"
	self removeIndex: oldRawInd.
	self insert: anElement before: firstIndex + nth - 1.! !

!KSContentsCollection methodsFor: 'converting' stamp: 'yo 7/17/2012 10:53'!
asSet
	^ self asSet! !

!KSContentsCollection methodsFor: 'copying' stamp: 'yo 7/17/2012 10:57'!
copyEmpty
	"Answer a copy of the receiver that contains no elements."
	^self species new! !

!KSContentsCollection methodsFor: 'copying' stamp: 'yo 7/17/2012 10:08'!
copyFrom: startIndex to: endIndex 
	"Answer a copy of the receiver that contains elements from position
	startIndex to endIndex."
	^self shallowCopy postCopyFrom: startIndex to: endIndex! !

!KSContentsCollection methodsFor: 'copying' stamp: 'yo 7/17/2012 10:57'!
copyReplaceFrom: start to: stop with: replacementCollection 
	"Answer a copy of the receiver with replacementCollection's elements in
	place of the receiver's start'th to stop'th elements. This does not expect
	a 1-1 map from replacementCollection to the start to stop elements, so it
	will do an insert or append."
	| newOrderedCollection delta startIndex stopIndex |
	"if start is less than 1, ignore stop and assume this is inserting at the front. 
	if start greater than self size, ignore stop and assume this is appending. 
	otherwise, it is replacing part of me and start and stop have to be within my 
	bounds. "
	delta _ 0.
	startIndex _ start.
	stopIndex _ stop.
	start < 1
		ifTrue: [startIndex _ stopIndex _ 0]
		ifFalse: [startIndex > self size
				ifTrue: [startIndex _ stopIndex _ self size + 1]
				ifFalse: 
					[(stopIndex < (startIndex - 1) or: [stopIndex > self size])
						ifTrue: [self errorOutOfBounds].
					delta _ stopIndex - startIndex + 1]].
	newOrderedCollection _ 
		self species new: self size + replacementCollection size - delta.
	1 to: startIndex - 1 do: [:index | newOrderedCollection add: (self at: index)].
	1 to: replacementCollection size do: 
		[:index | newOrderedCollection add: (replacementCollection at: index)].
	stopIndex + 1 to: self size do: [:index | newOrderedCollection add: (self at: index)].
	^newOrderedCollection! !

!KSContentsCollection methodsFor: 'copying' stamp: 'yo 7/17/2012 10:57'!
copyWith: newElement 
	"Answer a copy of the receiver that is 1 bigger than the receiver and 
	includes the argument, newElement, at the end."
	| newCollection |
	newCollection := self copy.
	newCollection add: newElement.
	^newCollection! !

!KSContentsCollection methodsFor: 'copying' stamp: 'yo 7/17/2012 10:57'!
newFrom: anObject
	"we are inside the new clone"
	array := array copy.
	indexCache := indexCache copy.! !

!KSContentsCollection methodsFor: 'copying' stamp: 'yo 7/17/2012 10:08'!
postCopy
	array := array copy.
	indexCache := indexCache copy.! !

!KSContentsCollection methodsFor: 'copying' stamp: 'yo 7/17/2012 10:58'!
postCopyFrom: startIndex to: endIndex 
	"finish copying the array in a certain range."
	endIndex < startIndex ifFalse: [
		"Because actual size of the array may be greater than used size,
		postCopyFrom:to: may fail to fail and answer an incorrect result
		if this sanity check were not applied"
		(startIndex between: 1 and: self size) ifFalse: [^self error: 'startIndex is out of bounds'].
		(endIndex between: 1 and: self size) ifFalse: [^self error: 'endIndex is out of bounds']].
	
	"Add a protection that lacks in Array>>postcopy"
	array := array copyFrom: startIndex + firstIndex - 1 to: (endIndex max: startIndex - 1) + firstIndex - 1.
	firstIndex := 1.
	lastIndex := array size.
	indexCache := self arrayClass new: 4.! !

!KSContentsCollection methodsFor: 'copying' stamp: 'yo 7/17/2012 10:08'!
reversed
	"Answer a copy of the receiver with element order reversed.  "
	| newCol |
	newCol _ self species new.
	self reverseDo:
		[:elem | newCol addLast: elem].
	^ newCol

"#(2 3 4 'fred') reversed"! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:56'!
collect: aBlock 
	"Evaluate aBlock with each of my elements as the argument. Collect the 
	resulting values into a collection that is like me. Answer the new 
	collection. Override superclass in order to use addLast:, not at:put:."
	| newCollection |
	newCollection _ self species new: self size.
	firstIndex to: lastIndex do:
		[:index |
		newCollection addLast: (aBlock value: (array at: index))].
	^ newCollection! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:08'!
collect: aBlock from: fromIndex to: toIndex
	"Override superclass in order to use addLast:, not at:put:."
	| result |
	(fromIndex < 1 or:[toIndex + firstIndex - 1 > lastIndex])
		ifTrue: [^self errorNoSuchElement].
	result := self copyFrom: fromIndex to: toIndex.
	result withIndexDo: [:e :i |
		result at: i put: (aBlock value: e)].
	^ result! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:56'!
detect: aBlock ifNone: exceptionBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Answer the first element for which aBlock evaluates to true. If none  
	evaluate to true, then evaluate the argument, exceptionBlock."
	self do: [:each | (aBlock value: each) ifTrue: [^ each]].
	^ exceptionBlock value! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:08'!
do: aBlock 
	"Override the superclass for performance reasons."
	| index |
	index := firstIndex.
	[index <= lastIndex]
		whileTrue: 
			[aBlock value: (array at: index).
			index := index + 1]! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:56'!
do: elementBlock separatedBy: separatorBlock
	"Evaluate the elementBlock for all elements in the receiver,
	and evaluate the separatorBlock between."
	| beforeFirst | 
	beforeFirst := true.
	self do:
		[:each |
		beforeFirst
			ifTrue: [beforeFirst := false]
			ifFalse: [separatorBlock value].
		elementBlock value: each]! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:56'!
findFirst: aBlock
	"Return the index of my first element for which aBlock evaluates as true."
	| index |
	index := 0.
	[(index := index + 1) <= self size] whileTrue:
		[(aBlock value: (self at: index)) ifTrue: [^index]].
	^ 0! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:08'!
findSubstring: key in: body startingAt: start
	"Answer the index in the string body at which the substring key first occurs, at or beyond start.  The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches.  If no match is found, zero will be returned."
	| index |
	key size = 0 ifTrue: [^ 0].
	start to: body size - key size + 1 do:
		[:startIndex |
		index _ 1.
			[(body at: startIndex+index-1) shape unicode
				= (key at: index) asciiValue]
				whileTrue:
				[index = key size ifTrue: [^ startIndex].
				index _ index+1]].
	^ 0! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:56'!
findWordStart: key startingAt: start
	| ind prev goAgain |
	"HyperCard style searching.  Answer the index in self of the substring key, when that key is preceeded by a separator character (any non letter or digit).  Must occur at or beyond start.  The match is case-insensitive.  If no match is found, zero will be returned."
	ind := start.
	[ind := self findSubstring: key in: self startingAt: ind.
	ind = 0 ifTrue: [^ 0].	"not found"
	ind = 1 ifTrue: [^ 1].	"First char is the start of a word"
	prev _ self at: ind-1.
	goAgain _ prev shape isAlphaNumeric.
	goAgain ifFalse: [
		(prev = $. and: [(self at: ind) shape isDigit]) ifTrue: [
			ind = 2 ifTrue: [^ ind].	"string begins .456"
			(self at: ind-2) shape isDigit 
				ifTrue: [goAgain := true]  "123.456 should not find 456"
				ifFalse: [^ ind]. "abc.456  Yes, found"
			]].
	goAgain] 
		whileTrue: [ind := ind + 1].
	^ ind	"is a word start"! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:08'!
includes: anElement 
	"Return true if the element is in the collection"
	firstIndex to: lastIndex do:
		[:index |
		(array at: index) == anElement ifTrue: [^ true]].
	^ false! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:57'!
inject: thisValue into: binaryBlock 
	"Accumulate a running value associated with evaluating the argument, 
	binaryBlock, with the current value of the argument, thisValue, and the 
	receiver as block arguments. For instance, to sum the numeric elements 
	of a collection, aCollection inject: 0 into: [:subTotal :next | subTotal + 
	next]."
	| nextValue |
	nextValue := thisValue.
	self do: [:each | nextValue := binaryBlock value: nextValue value: each].
	^nextValue! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:57'!
keysAndValuesDo: aBlock
	"Enumerate the receiver with all the keys (aka indices) and values."
	1 to: self size do: [:index | aBlock value: index value: (self at: index)]! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:08'!
reverseDo: aBlock 
	"Override the superclass for performance reasons."
	| index |
	index := lastIndex.
	[index >= firstIndex]
		whileTrue: 
			[aBlock value: (array at: index).
			index := index - 1]! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:57'!
select: aBlock 
	"Evaluate aBlock with each of my elements as the argument. Collect into
	a new collection like the receiver, only those elements for which aBlock
	evaluates to true."
	| newCollection element |
	newCollection := self copyEmpty.
	firstIndex to: lastIndex do:
		[:index |
		(aBlock value: (element := array at: index))
			ifTrue: [newCollection addLast: element]].
	^ newCollection! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:08'!
with: otherCollection collect: twoArgBlock 
	"Collect and return the result of evaluating twoArgBlock with 
	corresponding elements from this collection and otherCollection."
	| result |
	otherCollection size = self size ifFalse: [self error: 'otherCollection must be the same size'].
	result := self species new: self size.
	1 to: self size do:
		[:index | result addLast: (twoArgBlock value: (self at: index)
									value: (otherCollection at: index))].
	^ result! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:57'!
with: otherCollection do: twoArgBlock 
	"Evaluate twoArgBlock with corresponding elements from this collection and otherCollection."
	otherCollection size = self size ifFalse: [self error: 'otherCollection must be the same size'].
	1 to: self size do:
		[:index | twoArgBlock value: (self at: index)
									value: (otherCollection at: index)].
	^ self! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:57'!
withIndexCollect: elementAndIndexBlock 
	"Just like with:collect: except that the iteration index supplies the second argument to the block. Override superclass in order to use addLast:, not at:put:."
	| newCollection |
	newCollection := self species new: self size.
	firstIndex to: lastIndex do:
		[:index |
		newCollection addLast: (elementAndIndexBlock
			value: (array at: index)
			value: index - firstIndex + 1)].
	^ newCollection! !

!KSContentsCollection methodsFor: 'enumerating' stamp: 'yo 7/17/2012 10:57'!
withIndexDo: elementAndIndexBlock 
	"Just like do: except that the iteration index supplies the second argument to the block.  Override superclass in order to use addLast:, not at:put:."
	firstIndex to: lastIndex do:
		[:index |
		elementAndIndexBlock
			value: (array at: index)
			value: index - firstIndex + 1].
	^ self! !

!KSContentsCollection methodsFor: 'explorer' stamp: 'yo 7/17/2012 10:08'!
explorerContents
	^ (self as: OrderedCollection) explorerContents! !

!KSContentsCollection methodsFor: 'inspecting' stamp: 'yo 7/17/2012 11:05'!
inspectorClass 
	"Answer the class of the inspector to be used on the receiver.  Called by inspect; 
	use basicInspect to get a normal (less useful) type of inspector."
	^OrderedCollectionInspector! !

!KSContentsCollection methodsFor: 'kscript' stamp: 'yo 7/17/2012 10:21'!
concat: arg
	^ self, arg! !

!KSContentsCollection methodsFor: 'kscript' stamp: 'yo 7/17/2012 10:21'!
contains: anElement
	self do: [:e | e = anElement ifTrue: [^ true]].
	^ false.! !

!KSContentsCollection methodsFor: 'kscript' stamp: 'yo 7/17/2012 10:20'!
ksAt: key
	^ self at: key + 1! !

!KSContentsCollection methodsFor: 'kscript' stamp: 'yo 7/17/2012 10:22'!
ksAt: key put: val
	^ self at: key + 1 put: val! !

!KSContentsCollection methodsFor: 'kscript' stamp: 'yo 7/17/2012 10:23'!
ksKeys
	^ (0 to: self size - 1) asArray! !

!KSContentsCollection methodsFor: 'kscript' stamp: 'yo 7/17/2012 10:22'!
ksLocalKeys
	^ self ksKeys! !

!KSContentsCollection methodsFor: 'kscript' stamp: 'yo 7/17/2012 10:22'!
slice: from
	from > self size ifTrue: [^ self species new: 0].
	^ self copyFrom: from + 1 to: self size.! !

!KSContentsCollection methodsFor: 'printing' stamp: 'yo 7/17/2012 10:08'!
printElementsOn: aStream
	aStream nextPut: $(.
	(firstIndex to: lastIndex) do: [:i | aStream print: (array at: i)] separatedBy: [aStream space].
	aStream nextPut: $)! !

!KSContentsCollection methodsFor: 'printing' stamp: 'yo 7/17/2012 10:08'!
printNameOn: aStream
	super printOn: aStream! !

!KSContentsCollection methodsFor: 'printing' stamp: 'yo 7/17/2012 11:05'!
printOn: aStream 
	"Append a sequence of characters that identify the receiver to aStream."
	self printNameOn: aStream.
	self printElementsOn: aStream! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
arrayClass
	^ Array! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
collector  "Private"
	^ array! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:48'!
errorNoSuchElement
	self error: 'attempt to index non-existent element in an ordered collection'! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:48'!
find: oldObject
  "  This method answers an index in the range firstIndex .. lastIndex, which is meant for internal use only.
     Never use this method in your code, the methods for public use are:
        #indexOf:
        #indexOf:ifAbsent: "
	| index |
	index := firstIndex.
	[index <= lastIndex]
		whileTrue:
			[(array at: index) == oldObject ifTrue: [^ index].
			index _ index + 1].
	self errorNotFound: oldObject! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:49'!
insert: anObject before: spot
	"spot is an index in the range firstIndex ... lastIndex, such an index is not known from outside the collection. 
     Never use this method in your code, it is meant for private use by OrderedCollection only.
     The methods for use are:
        #add:before:   to insert an object before another object
        #add:beforeIndex:   to insert an object before a given position."
	| "index" delta spotIndex |
	spotIndex := spot.
	delta := spotIndex - firstIndex.
	firstIndex = 1
		ifTrue: 
			[self makeRoomAtFirst.
			spotIndex := firstIndex + delta].
	firstIndex := firstIndex - 1.
	array
		replaceFrom: firstIndex
		to: spotIndex - 2
		with: array
		startingAt: firstIndex + 1.
	^ array at: spotIndex - 1 put: anObject.! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
makeRoomAtFirst
	| delta index |
	delta := array size - self size.
	delta = 0 ifTrue: 
			[self grow.
			delta := array size - self size].
	lastIndex = array size ifTrue: [^ self]. "just in case we got lucky"
	index _ array size.
	[index > delta]
		whileTrue: 
			[array at: index put: (array at: index - delta + firstIndex - 1).
			array at: index - delta + firstIndex - 1 put: nil.
			index _ index - 1].
	firstIndex := delta + 1.
	lastIndex := array size! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
makeRoomAtLast
	| newLast delta |
	newLast := self size.
	array size - self size = 0 ifTrue: [self grow].
	(delta := firstIndex - 1) = 0 ifTrue: [^ self].
	"we might be here under false premises or grow did the job for us"
	1 to: newLast do:
		[:index |
		array at: index put: (array at: index + delta).
		array at: index + delta put: nil].
	firstIndex := 1.
	lastIndex := newLast! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
makeRoomAtLastFor: n
	| newLast delta |
	newLast := self size.
	array size - self size < n ifTrue: [self grow: n].
	(delta := firstIndex - 1) = 0 ifTrue: [^ self].
	"we might be here under false premises or grow did the job for us"
	1 to: newLast do:
		[:index |
		array at: index put: (array at: index + delta).
		array at: index + delta put: nil].
	firstIndex _ 1.
	lastIndex _ newLast! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:52'!
removeIndex: removedIndex
  "  removedIndex is an index in the range firstIndex .. lastIndex, such an index is not known from outside the collection.
    Never use this method in your code, it is meant for private use by OrderedCollection only.
     The method for public use is: #removeAt:"
	array 
		replaceFrom: removedIndex 
		to: lastIndex - 1 
		with: array 
		startingAt: removedIndex+1.
	array at: lastIndex put: nil.
	lastIndex := lastIndex - 1.! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
reset
	firstIndex := array size // 3 max: 1.
	lastIndex := firstIndex - 1.
	indexCache := Array new: 4.! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
resetTo: index
	firstIndex := index.
	lastIndex := firstIndex - 1! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
setCollection: anArray
	array := anArray.
	self reset! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:08'!
setContents: anArray
	array := anArray.
	firstIndex := 1.
	lastIndex := array size.
	indexCache := Array new: 4.! !

!KSContentsCollection methodsFor: 'private' stamp: 'yo 7/17/2012 10:52'!
updateIndexCache: ind
	| cacheSize |
	cacheSize := indexCache size.
	(indexCache at: cacheSize) = ind ifTrue: [^ self].
	indexCache replaceFrom: 1 to: cacheSize - 1 with: indexCache startingAt: 2.
	indexCache at: cacheSize put: ind.! !

!KSContentsCollection methodsFor: 'removing' stamp: 'yo 7/17/2012 11:05'!
remove: oldObject 
	"Remove oldObject from the receiver's elements. Answer oldObject 
	unless no element is equal to oldObject, in which case, raise an error.
	ArrayedCollections cannot respond to this message."
	^ self remove: oldObject ifAbsent: [self errorNotFound: oldObject]! !

!KSContentsCollection methodsFor: 'removing' stamp: 'yo 7/17/2012 11:05'!
remove: oldObject ifAbsent: absentBlock
	| index |
	index := firstIndex.
	[index <= lastIndex]
		whileTrue: 
			[oldObject == (array at: index)
				ifTrue: 
					[self removeIndex: index.
					^ oldObject]
				ifFalse: [index := index + 1]].
	^ absentBlock value! !

!KSContentsCollection methodsFor: 'removing' stamp: 'yo 7/17/2012 11:05'!
removeAll
	[self isEmpty] whileFalse: [self removeLast] ! !

!KSContentsCollection methodsFor: 'removing' stamp: 'yo 7/17/2012 10:08'!
removeAt: index
	| removed |
	removed := self at: index.
	self removeIndex: index + firstIndex - 1.
	^removed! !

!KSContentsCollection methodsFor: 'removing' stamp: 'yo 7/17/2012 10:08'!
removeFirst
	"Remove the first element of the receiver and answer it. If the receiver is 
	empty, create an error notification."
	| firstObject |
	self emptyCheck.
	firstObject := array at: firstIndex.
	array at: firstIndex put: nil.
	firstIndex := firstIndex + 1.
	^ firstObject! !

!KSContentsCollection methodsFor: 'removing' stamp: 'yo 7/17/2012 11:05'!
removeFirst: n
	"Remove first n object into an array"
	| list |
	list := self arrayClass new: n.
	1 to: n do: [:i | list at: i put: self removeFirst].
	^ list! !

!KSContentsCollection methodsFor: 'removing' stamp: 'yo 7/17/2012 10:08'!
removeLast
	"Remove the last element of the receiver and answer it. If the receiver is 
	empty, create an error notification."
	| lastObject |
	self emptyCheck.
	lastObject := array at: lastIndex.
	array at: lastIndex put: nil.
	lastIndex := lastIndex - 1.
	^ lastObject! !

!KSContentsCollection methodsFor: 'removing' stamp: 'yo 7/17/2012 11:06'!
removeLast: n
	"Remove last n object into an array with last in last position"

	| list |
	list := self arrayClass new: n.
	n to: 1 by: -1 do: [:i | list at: i put: self removeLast].
	^ list! !

!KSContentsCollection methodsFor: 'testing' stamp: 'yo 7/17/2012 11:01'!
hasContentsInExplorer
	^self isEmpty not! !

!KSContentsCollection methodsFor: 'testing' stamp: 'yo 7/17/2012 11:01'!
ifNotEmpty: aBlock
	self isNotEmpty ifTrue: [aBlock value].! !

!KSContentsCollection methodsFor: 'testing' stamp: 'yo 9/19/2012 23:21'!
isCollection
	^ true! !

!KSContentsCollection methodsFor: 'testing' stamp: 'yo 7/17/2012 11:01'!
isEmpty
	^ self size = 0! !

!KSContentsCollection methodsFor: 'testing' stamp: 'yo 7/17/2012 11:05'!
isNotEmpty
	^ self size ~= 0! !

!KSContentsCollection class methodsFor: 'instance creation' stamp: 'yo 7/17/2012 10:08'!
new
	^ self new: 10! !

!KSContentsCollection class methodsFor: 'instance creation' stamp: 'yo 7/17/2012 10:08'!
new: anInteger
	| r |
	r := super basicNew.
	^ r setCollection: (r arrayClass new: anInteger)! !

!KSContentsCollection class methodsFor: 'instance creation' stamp: 'yo 7/17/2012 10:09'!
newFrom: aCollection 
	"Answer an instance of me containing the same elements as aCollection."
	| newCollection |
	newCollection := self new: aCollection size.
	newCollection addAll: aCollection.
	^newCollection

"	KSContentsCollection newFrom: {1. 2. 3}
"! !
