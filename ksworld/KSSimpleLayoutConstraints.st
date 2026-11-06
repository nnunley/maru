Object subclass: #KSSimpleLayoutConstraints
	instanceVariableNames: 'constraints selector'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSSimpleLayoutConstraints methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
constraints: anArray
	| attr i |
	constraints := anArray.
	constraints size = 1 ifTrue: [
		"Rectangle's original left:, right:, top:, and bottom: methods resize instead if moving"
		attr := constraints first subjectAttribute.
		i := #(left right top bottom) indexOf: attr.
		i > 0 ifTrue: [
			selector := #(moveLeft: moveRight: moveTop: moveBottom:) at: i.
			^self]].

	"List selectors for finding senders ..."
	#(bottom:height: bottom:top: bottom:vcenter: hcenter:left: hcenter:right: hcenter:width: height: height:bottom: height:top: height:vcenter:  left:hcenter: left:right: left:width: right:hcenter: right:left: right:width: top:bottom: top:height: top:vcenter: vcenter:bottom: vcenter:height: vcenter:top: width: width:hcenter: width:left: width:right:).

	selector := (constraints inject: '' into: [:sel :each | sel, each subjectAttribute, ':']) asSymbol.! !

!KSSimpleLayoutConstraints methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
subjectAttribute
	^ constraints first subjectAttribute! !

!KSSimpleLayoutConstraints methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:13'!
subjectName
	^ constraints first subjectName! !

!KSSimpleLayoutConstraints methodsFor: 'layout' stamp: 'yo 8/28/2012 20:13'!
boundsOf: aName in: parentBox into: allBounds 
	^ allBounds at: aName
		ifAbsentPut: [(parentBox atName: aName)
			ifNotNilDo: [:box | box bounds]
			ifNil: [0@0 corner: 0@0]].! !

!KSSimpleLayoutConstraints methodsFor: 'layout' stamp: 'yo 8/28/2012 20:13'!
layOut: parentBox into: allBounds
	| currentValues old new |
	currentValues := constraints collect: [:each |
		self boundsOf: each referenceName in: parentBox into: allBounds.
		each currentValueIn: allBounds] as: Array.
	old := self boundsOf: self subjectName in: parentBox into: allBounds.
	new := old perform: selector withArguments: currentValues.
	allBounds at: self subjectName put: new.! !

!KSSimpleLayoutConstraints methodsFor: 'printing' stamp: 'yo 8/28/2012 20:13'!
printOn: aStream
	aStream nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: self subjectName;
		space;
		nextPutAll: selector;
		nextPutAll: ' ('.
	constraints do: [:each | each printReferenceExpressionOn: aStream]
		separatedBy: [aStream nextPutAll: '; '].
	aStream  nextPutAll: '))'! !
