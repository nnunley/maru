Object subclass: #KSSimpleLayoutConstraint
	instanceVariableNames: 'subjectName subjectAttribute referenceName referenceAttribute scale offset'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
moveBy: aPoint
	"Add aPoint's x or y to my offset, unless this is a width/height constraint."
	(#(width height) includes: subjectAttribute) ifFalse: [
		| axis |
		axis := self axisOf: subjectAttribute.
		offset := offset + (aPoint perform: axis)].! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
offset
	^offset! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
offset: refOffset

	offset := refOffset.! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
referenceAttribute
	^referenceAttribute! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
referenceName
	^referenceName! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
referenceNameAndAxis
	^ { referenceName.  self axisOf: referenceAttribute }! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
scale
	^scale! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
subjectAttribute
	^subjectAttribute! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
subjectName
	^subjectName! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
subjectName: subjName attribute: subjAttr referenceName: refName attribute: refAttr scale: refScale offset: refOffset
	subjectName := subjName.
	subjectAttribute := subjAttr.
	referenceName := refName.
	referenceAttribute := refAttr.
	scale := refScale.
	offset := refOffset.! !

!KSSimpleLayoutConstraint methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
subjectNameAndAxis
	^ { subjectName.  self axisOf: subjectAttribute }! !

!KSSimpleLayoutConstraint methodsFor: 'layout' stamp: 'yo 8/28/2012 20:13'!
currentValueIn: allBounds
	| referenceBounds referenceValue |
	scale = 0 ifTrue: [^offset].
	referenceBounds := allBounds at: referenceName.
	referenceValue := referenceBounds perform: referenceAttribute.
	^referenceValue * scale + offset! !

!KSSimpleLayoutConstraint methodsFor: 'printing' stamp: 'yo 8/28/2012 20:13'!
printOn: aStream
	aStream
		nextPutAll: self class name;
		nextPut: $(.
	self printSubjectExpressionOn: aStream.
	aStream nextPutAll: ' := '.
	self printReferenceExpressionOn: aStream.
	aStream nextPut: $)! !

!KSSimpleLayoutConstraint methodsFor: 'printing' stamp: 'yo 8/28/2012 20:13'!
printReferenceExpressionOn: aStream
	scale isZero
		ifTrue: [
			aStream print: offset]
		ifFalse: [
			aStream
				nextPutAll: (referenceName ifNil: ['[]']);
				space;
				nextPutAll: referenceAttribute.
			scale = 1 ifFalse: [
				aStream nextPutAll: ' * '; print: scale].
			offset isZero ifFalse: [
				offset negative
					ifTrue: [aStream nextPutAll: ' - '; print: offset negated]
					ifFalse: [aStream nextPutAll: ' + '; print: offset]]].! !

!KSSimpleLayoutConstraint methodsFor: 'printing' stamp: 'yo 8/28/2012 20:13'!
printSubjectExpressionOn: aStream
	aStream
		nextPutAll: (subjectName ifNil: ['[]']);
		space;
		nextPutAll: subjectAttribute.! !

!KSSimpleLayoutConstraint methodsFor: 'printing' stamp: 'yo 8/28/2012 20:13'!
storeConstraintOn: aStream
	"write as keep:of:to:of:scale:offset:"
	aStream
		nextPutAll: 'keep: '; print: subjectAttribute;
		nextPutAll: ' of: '; print: subjectName; 
		nextPutAll: ' to: ';  print: referenceAttribute.
 	referenceName ifNotNil: [
		aStream nextPutAll: ' of: ';  print: referenceName].
	scale = 1 ifFalse: [
		aStream nextPutAll: ' scale: '; print: scale].
	offset = 0 ifFalse: [
		aStream nextPutAll: ' offset: '; print: offset].! !

!KSSimpleLayoutConstraint methodsFor: 'resolving' stamp: 'yo 8/28/2012 20:13'!
addGivensTo: givens
	"Assuming I'm resolvable (see isResolvableIn:), add my definition to the givens"
	((givens at: subjectName ifAbsentPut: [Dictionary new])
		at: (self axisOf: subjectAttribute) ifAbsentPut: [Set new])
			add: subjectAttribute! !

!KSSimpleLayoutConstraint methodsFor: 'resolving' stamp: 'yo 8/28/2012 20:13'!
axisOf: anAttribute
	^(#(left right width hcenter) pointsTo: anAttribute)
		ifTrue: [#x]
		ifFalse: [#y]! !

!KSSimpleLayoutConstraint methodsFor: 'resolving' stamp: 'yo 8/28/2012 20:13'!
defines: attr of: subject
	^subjectName = subject and: [subjectAttribute = attr]! !

!KSSimpleLayoutConstraint methodsFor: 'resolving' stamp: 'yo 8/28/2012 20:13'!
definesAxis: axis of: subject
	^subjectName = subject and: [(self axisOf: subjectAttribute) = axis]! !

!KSSimpleLayoutConstraint methodsFor: 'resolving' stamp: 'yo 8/28/2012 20:13'!
isResolvableIn: givens
	"I'm resolvable if either my reference atribute is known already, or there are at least two other attributes on the same axis so it can be inferred"
	| known |
	known := (givens at: referenceName ifAbsent: [^false])
		at: (self axisOf: referenceAttribute) ifAbsent: [^false].
	^(known includes: referenceAttribute) or: [known size >= 2]! !
