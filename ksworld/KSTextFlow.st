KSObject subclass: #KSTextFlow
	instanceVariableNames: 'charBoxes textLines fields fieldHint'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSTextFlow methodsFor: 'accessing' stamp: 'tk 4/2/2013 12:29'!
charBoxes

	^ charBoxes! !

!KSTextFlow methodsFor: 'accessing' stamp: 'tk 4/2/2013 12:29'!
charBoxes: anObject

	charBoxes := anObject! !

!KSTextFlow methodsFor: 'accessing' stamp: 'tk 4/2/2013 12:29'!
fieldHint

	^ fieldHint! !

!KSTextFlow methodsFor: 'accessing' stamp: 'tk 4/2/2013 12:29'!
fieldHint: anObject

	fieldHint := anObject! !

!KSTextFlow methodsFor: 'accessing' stamp: 'tk 4/2/2013 12:29'!
fields

	^ fields! !

!KSTextFlow methodsFor: 'accessing' stamp: 'tk 4/2/2013 12:29'!
fields: anObject

	fields := anObject! !

!KSTextFlow methodsFor: 'accessing' stamp: 'tk 4/2/2013 12:29'!
textLines

	^ textLines! !

!KSTextFlow methodsFor: 'accessing' stamp: 'tk 4/2/2013 12:29'!
textLines: anObject

	textLines := anObject! !

!KSTextFlow methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 15:08'!
add: newObject afterIndex: index
	"Add the argument, newObject, as an element of the receiver. Put it in the sequence just after index. Answer newObject."
	
	charBoxes add: newObject afterIndex: index.
	^ newObject! !

!KSTextFlow methodsFor: 'as yet unclassified' stamp: 'tk 4/2/2013 12:29'!
initialize

	charBoxes := LargeOrderedCollection new.
	textLines := LargeOrderedCollection new.
	fields := OrderedCollection new.
	! !

!KSTextFlow methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 14:25'!
newField: fldBox newString: asciiString
	"Add this initial text, make letter boxes, make one line, and make a KSTextSpan for the field."
	
	| tl kspan |
	tl := KSTextLineInfo new.
	tl newFrom: 1 to: charBoxes size in: self.
	textLines addLast: tl.
	kspan := KSTextSpan new.
	kspan newFrom: 1 to: textLines size in: fldBox.
	fields addLast: kspan.
	tl fieldInd: fields size.
	
	"fieldHint"
	
	^ kspan! !
