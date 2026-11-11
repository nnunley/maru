KSObject subclass: #KSTextLineInfo
	instanceVariableNames: 'firstInd lastInd ascent descent flow upToDate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSTextLineInfo commentStamp: 'tk 4/4/2013 15:07' prior: 0!
A KSTextLineInfo is the text span of one line of text.  I Do not know what field I am in, since that changes often as text moves down.

Instance Variables
firstInd
	- index into the charBoxes or a KSTextFlow

lastInd
	- index into the charBoxes or a KSTextFlow

ascent
	- pixels above the baseline (pivotOffset) of the tallest letter in this line

descent
	- pixels below the baseline (pivotOffset) of the largest descending letter in this line

flow
	- the textFlow I am in.  (so I can get and put glyphs)

upToDate
	- flag saying changes from the end of the previous box has been propagated to this box.  The changes could be removing or adding letters from my front.!

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
ascent

	^ ascent! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
ascent: anObject

	ascent := anObject! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
descent

	^ descent! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
descent: anObject

	descent := anObject! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
firstInd

	^ firstInd! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
firstInd: anObject

	firstInd := anObject! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
lastInd

	^ lastInd! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
lastInd: anObject

	lastInd := anObject! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
upToDate

	^ upToDate! !

!KSTextLineInfo methodsFor: 'accessing' stamp: 'tk 4/2/2013 15:07'!
upToDate: anObject

	upToDate := anObject! !

!KSTextLineInfo methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 15:05'!
add: newObject afterIndex: index
	"Add the argument, newObject, as an element of the receiver. Put it in the sequence just after index. Answer newObject.
	Lengthen this line to include it."

	flow add: newObject afterIndex: index + firstInd - 1.
	lastInd := lastInd + 1.
	^ newObject! !

!KSTextLineInfo methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 15:04'!
newFrom: stind to: endind in: textFlow
	"initialize this line"
	
| charBox |
firstInd := stind.
lastInd := endind.
flow := textFlow.
ascent := 0.
descent := 0.
firstInd to: lastInd do: [:ind | 
	charBox := textFlow charBoxes at: ind.
	ascent := charBox ascent max: ascent.
	descent := charBox descent max: descent].

"fieldInd  set later"
upToDate := false.! !

!KSTextLineInfo methodsFor: 'as yet unclassified' stamp: 'tk 4/4/2013 14:41'!
size
	^ lastInd - firstInd + 1! !
