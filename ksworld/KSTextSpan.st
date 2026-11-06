KSContentsCollection subclass: #KSTextSpan
	instanceVariableNames: 'firstInd lastInd pageNum field flowKey upToDate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:23'!
field

	^ field! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:23'!
field: anObject

	field := anObject! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
firstInd

	^ firstInd! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
firstInd: anObject

	firstInd := anObject! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
flowKey

	^ flowKey! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
flowKey: anObject

	flowKey := anObject! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
lastInd

	^ lastInd! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
lastInd: anObject

	lastInd := anObject! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
pageNum

	^ pageNum! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
pageNum: anObject

	pageNum := anObject! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
upToDate

	^ upToDate! !

!KSTextSpan methodsFor: 'accessing' stamp: 'tk 4/3/2013 11:17'!
upToDate: anObject

	upToDate := anObject! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 14:58'!
add: newObject afterIndex: index
	"Add the argument, newObject, as an element of the receiver. Put it in the sequence just after index. Answer newObject."

	| pair |
	pair := self linePairOfMyIndex: index.	"text line.  sum of chars in lines before it"
	"insert value.  Line puts it into charBoxes."
	pair first add: newObject afterIndex: index - pair second.
	^ newObject! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/3/2013 14:00'!
addLast: value

	self charBoxes addLast: value.
	(self textLines at: lastInd) lastInd: (self textLines at: lastInd) lastInd + 1.! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 16:37'!
asArray
	"Return my span of letters as an Array."

	| copy lines master sum thisLine |
	copy :=  self arrayClass new: self size.
	sum := 0.
	master := self charBoxes.
	lines := self textLines.
	firstInd to: lastInd do: [:lineInd |
		thisLine := lines at: lineInd.
		copy replaceFrom: sum+1 to: sum + thisLine size with: master startingAt: thisLine firstInd.
		sum := sum + thisLine size.
		].
	^ copy! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/3/2013 11:28'!
at: index

	^ self charBoxes at: (self textLines at: firstInd) firstInd + index - 1! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/3/2013 11:30'!
at: index put: value

	^ self charBoxes at: (self textLines at: firstInd) firstInd + index - 1 put: value! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/3/2013 16:55'!
charBoxes

	^ (field stackHandler ksAt: flowKey) charBoxes! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 14:51'!
flow

	^ field stackHandler ksAt: flowKey! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 14:55'!
lineOfMyIndex: index
	"Return the TextLineInfo that contains the indexed letter in me"
	
	| fl line |
	fl := self flow.
	"Find the line"
	(firstInd to: lastInd) inject: 0 into: [:sum :ind |
		line := fl textLines at: ind.
		sum + line size >= index ifTrue: [^ line].
		sum + line size].
	"off the end"
	^ fl textLines at: lastInd! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 14:55'!
linePairOfMyIndex: index
	"Return the {aTextLineInfo. index in me of first char in line} that contains the indexed letter in me"
	
	| fl line sump |
	fl := self flow.
	"Find the line"
	(firstInd to: lastInd) inject: 0 into: [:sum :ind |
		line := fl textLines at: ind.
		sum + line size >= index ifTrue: [^ {line. sum}].
		sump := sum + line size].
	"off the end"
	^ {fl textLines at: lastInd. sump}! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/3/2013 16:30'!
newFrom: stind to: endind in: fldBox
	"initialize this span -- the text in one text field"
	
firstInd := stind.
lastInd := endind.
field := fldBox.

"still need pageNum and flowKey"
upToDate := false.! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/3/2013 14:01'!
size
	"number of chars in the span"
	
	^ (self textLines at: lastInd) lastInd - (self textLines at: firstInd) firstInd + 1! !

!KSTextSpan methodsFor: 'as yet unclassified' stamp: 'tk 4/3/2013 16:56'!
textLines

	^ (field stackHandler ksAt: flowKey) textLines! !
