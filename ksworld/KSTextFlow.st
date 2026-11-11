KSObject subclass: #KSTextFlow
	instanceVariableNames: 'charBoxes textLines fields fieldHint'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSTextFlow commentStamp: 'tk 4/1/2013 12:23' prior: 0!
A KSTextFlow is the datastructure for text that flows in many linked boxes (fields) on many pages of a stack.

The stack owns one or more TextFlows.
A TextFlow has:
charBoxes      a LargeOrderedCollection of letter boxes.  (each can be in the contents of a textBox on a page while also being here).

textLines     a LargeOrderedCollection of LineInfos, each with information about a line of text.

fields         an OrderedCollection of KSTextSpans, each with info about a text flow box on a page.

fieldHint    index of the most recently accessed box.

A PageData in a stack no longer holds the per-page text for a box.  Instead, a pageData goes to the stack, and looks up the record of a given box.  Using (pageNum, boxID) it can find the range of letter boxes, already divided into lines.  The positions of the boxes are already correct from the last time this page was layed out.  Just add the letter boxes to contents and display.

Layout and editing is done by a new version of KSTextLayout.  It manipulates rawText, LineInfos, and BoxInfos according to the insertions and deletions in the box.  It marks the first box and line on the next page as not upToDate if appropriate.   The page turn code does not need to do anything about recording text on a page it is leaving.  The stack's textFlow is already correct.

To do:
[ ] Use KSTextSpan as the field contents.  No other change.  'add:' adds at the end of this field.
[ ] Test case ignoring layout -- just put 100 chars into each field.  Let normal KSTextLayout lay them out.  Possibly just one line KSTextLineInfo per field.  
[ ] Move chars and lines between fields.
[ ] KSTextFlowLayout, keep the KSTextLineInfo up to date based on word wrap.
[ ] !

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
