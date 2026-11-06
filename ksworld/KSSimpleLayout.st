Object subclass: #KSSimpleLayout
	instanceVariableNames: 'constraints resolved whole'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Boxes'!

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:08'!
checkDefined: subjAttr of: subjName
	| count subjAxis |
	count := 0.
	subjAxis := self axisOf: subjAttr.
	constraints do: [:each | 
		(each defines: subjAttr of: subjName)
			ifTrue: [^self error: ('{1} of {2} already defined' format: {subjAttr. subjName})].
		(each definesAxis: subjAxis of: subjName)
			ifTrue: [count := count + 1.
				count > 1 ifTrue: [
					^self error: ('{1}-axis of {2} already defined' format: {subjAxis. subjName})]]]! !

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:08'!
constraints

	^ constraints! !

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:08'!
keep: subjectAttr of: subjectName to: attrOrValue
	^attrOrValue isSymbol
		ifTrue: [self keep: subjectAttr of: subjectName to: attrOrValue of: nil scale: 1 offset: 0]
		ifFalse: [self keep: subjectAttr of: subjectName to: subjectAttr of: nil scale: 0 offset: attrOrValue]! !

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:08'!
keep: subjectAttr of: subjectName to: refAttr of: refName
	^self keep: subjectAttr of: subjectName to: refAttr of: refName scale: 1 offset: 0! !

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:08'!
keep: subjectAttr of: subjectName to: refAttr of: refName offset: refOffset
	^self keep: subjectAttr of: subjectName to: refAttr of: refName scale: 1 offset: refOffset! !

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 10/12/2012 11:01'!
keep: subjectAttr of: subject to: referenceAttr of: reference scale: refScale offset: refOffset
	| referenceName subjectName normalizedSubjs normalizedRefs |
	referenceName := reference isString ifTrue: [reference]
		ifFalse: [reference ifNotNil: [reference name]].
	subjectName := subject isString ifTrue: [subject]
		ifFalse: [subject ifNotNil: [subject name]].
	normalizedSubjs := self perform: subjectAttr.
	normalizedRefs := self perform: referenceAttr.
	normalizedSubjs size = normalizedRefs size
		ifFalse: [^self error: ('{1} cannot reference {2}' format: {subjectAttr. referenceAttr})].

	constraints ifNil: [constraints := OrderedCollection new].

	normalizedSubjs with: normalizedRefs do: [:subjAttr :refAttr |
		self checkDefined: subjAttr of: subjectName.
		constraints add: (KSSimpleLayoutConstraint new
			subjectName: subjectName
			attribute: subjAttr
			referenceName: referenceName
			attribute: refAttr
			scale: (refScale asPoint perform: (self axisOf: refAttr))
			offset: (refOffset asPoint perform: (self axisOf: refAttr)))].

	resolved := nil.! !

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:08'!
keep: subjectAttr of: subjectName to: refAttr offset: refOffset
	^self keep: subjectAttr of: subjectName to: refAttr of: nil scale: 1 offset: refOffset! !

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:08'!
keep: subjectAttr of: subjectName to: refAttr scale: refScale
	^self keep: subjectAttr of: subjectName to: refAttr of: nil scale: refScale offset: 0! !

!KSSimpleLayout methodsFor: 'accessing' stamp: 'yo 8/28/2012 20:08'!
keep: subjectAttr of: subjectName to: refAttr scale: refScale offset: refOffset
	^self keep: subjectAttr of: subjectName to: refAttr of: nil scale: refScale offset: refOffset! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
bottom
	^#(bottom)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
bottomCenter
	^#(hcenter bottom)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
bottomLeft
	^#(left bottom)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
bottomRight
	^#(right bottom)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
center
	^#(hcenter vcenter)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
extent
	^#(width height)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
hcenter
	^#(hcenter)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
height
	^#(height)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
left
	^#(left)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
leftCenter
	^#(left vcenter)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
right
	^#(right)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
rightCenter
	^#(right vcenter)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
top
	^#(top)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
topCenter
	^#(hcenter top)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
topLeft
	^#(left top)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
topRight
	^#(right top)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
vcenter
	^#(vcenter)! !

!KSSimpleLayout methodsFor: 'decomposing' stamp: 'yo 8/28/2012 20:08'!
width
	^#(width)! !

!KSSimpleLayout methodsFor: 'editing' stamp: 'yo 8/28/2012 20:08'!
move: subject by: aPoint
	"add aPoint to all constraint offsets for subject (except for width/height constraints)"
	| subjectName |
	subjectName := subject isString
		ifTrue: [subject]
		ifFalse: [subject name].
	constraints do: [:constraint |
		constraint subjectName = subjectName
			ifTrue: [constraint moveBy: aPoint]].! !

!KSSimpleLayout methodsFor: 'editing' stamp: 'yo 8/28/2012 20:08'!
move: subject to: aPoint
	"set all constraint offsets to aPoint for subject (except for width/height constraints)"
	| subjectName |
	subjectName := subject isString
		ifTrue: [subject]
		ifFalse: [subject name].
	constraints do: [:constraint |
		constraint subjectName = subjectName
			ifTrue: [constraint moveBy: (aPoint - constraint offset)]].! !

!KSSimpleLayout methodsFor: 'editing' stamp: 'yo 8/28/2012 20:08'!
set: attribute of: boxName offset: value
	"Change the value of an existing attribute of a constraint.
	dialogBox layout set: #width of: 'accept' offset: 120   "
	
	 constraints do: [:con |
		con subjectName = boxName ifTrue: [
			con subjectAttribute = attribute ifTrue: [
				^ con offset: value]]].
	^ nil	"not found"! !

!KSSimpleLayout methodsFor: 'layout' stamp: 'yo 8/29/2012 10:53'!
layOut: parentBox 
	| allBounds |
	allBounds := Dictionary new.
	allBounds at: nil put: (0@0 corner: parentBox extent).
	self resolvedConstraints do: [:each |
		each layOut: parentBox into: allBounds].
	allBounds keysAndValuesDo: [:name :new |
		(parentBox atName: name) ifNotNil: [:box |
			box bounds: new]]! !

!KSSimpleLayout methodsFor: 'layout' stamp: 'yo 1/17/2013 10:15'!
ppSerializer
	^ whole! !

!KSSimpleLayout methodsFor: 'layout protocol' stamp: 'yo 8/28/2012 20:17'!
canInclude: aBox
	"Return true if this layout can deal with this kind box in its contents"
	 ^ true! !

!KSSimpleLayout methodsFor: 'layout protocol' stamp: 'yo 8/30/2012 12:59'!
ksAt: key
	key == #whole ifTrue: [
		^ whole].
	self error: 'cannot get any other value than #whole'.! !

!KSSimpleLayout methodsFor: 'layout protocol' stamp: 'yo 10/9/2012 10:55'!
ksAt: key put: val
	key == #whole ifTrue: [
		^ whole := val].
	self error: 'cannot set any other value than #whole'.! !

!KSSimpleLayout methodsFor: 'layout protocol' stamp: 'yo 8/28/2012 20:17'!
layoutChildrenFirst
	^ false! !

!KSSimpleLayout methodsFor: 'printing' stamp: 'yo 8/28/2012 20:08'!
storeOn: aStream
	aStream nextPutAll: '(', self class name, ' new'; crtab.
	constraints do: [:each |
		each storeConstraintOn: aStream.
		aStream nextPut: $;; crtab].
	aStream nextPutAll: 'yourself)'.! !

!KSSimpleLayout methodsFor: 'resolving' stamp: 'yo 8/28/2012 20:08'!
axisOf: anAttribute
	^(#(left right width hcenter) pointsTo: anAttribute)
		ifTrue: [#x]
		ifFalse: [#y]! !

!KSSimpleLayout methodsFor: 'resolving' stamp: 'yo 10/12/2012 11:01'!
initialGivens
	"we know the parent box"

	^#(left right top bottom) collect: [:attr |
		KSSimpleLayoutConstraint new
			subjectName: nil attribute: attr
			referenceName: nil attribute: attr scale: 1 offset: 0]! !

!KSSimpleLayout methodsFor: 'resolving' stamp: 'yo 8/28/2012 20:08'!
orderedConstraints
	"Order constraints so dependent ones come later"

	| given ordered resolvable axisConstraints unresolvedAxes unresolvedByAxis |
	ordered := OrderedCollection new.
	given := Dictionary new.
	self initialGivens do: [:known | known addGivensTo: given].

	"Since constraints will eventually be resolved in pairs on a given axis (e.g. left-right, top-bottom),
	don't assume we can resolve any single constraint unless we can resolve all other outstanding
	constraints for the same subject and axis."
	unresolvedByAxis := Dictionary new.
	constraints do: [ :each |
		(unresolvedByAxis at: each subjectNameAndAxis ifAbsentPut: [ OrderedCollection new ]) add: each.
		].
	
	[	"a constraint is resolvable if
		    (a) we already have as 'given' at least two known values on the relevant axis of its reference attribute [in practice more than two means being over-specified, which shouldn't happen]
		or (b) at this stage there are no unresolved constraints on that axis (e.g., the constraint depends on foo #bottom, and there are no foo #y values outstanding)
		"
		resolvable := OrderedCollection new.
		unresolvedAxes := unresolvedByAxis keys.		"a snapshot of those considered unresolvable up to now"
		unresolvedAxes do: [ :nameAndAxis |
			axisConstraints := unresolvedByAxis at: nameAndAxis.
			(axisConstraints allSatisfy: [:each |
				(each isResolvableIn: given)
				  or: [(unresolvedAxes includes: each referenceNameAndAxis) not]])
			  ifTrue: [
				resolvable addAll: axisConstraints.
				unresolvedByAxis removeKey: nameAndAxis ] ].
		
		"If none of the axes appears resolvable, pick a single arbitrary constraint - though if possible find an axis with a singleton"
		(resolvable isEmpty and: [unresolvedByAxis isEmpty not])
		  ifTrue: [
			axisConstraints := unresolvedByAxis detect: [ :coll | coll size = 1 ] ifNone: [ unresolvedByAxis anyOne ].
			resolvable := { axisConstraints removeFirst }.
			axisConstraints ifEmpty: [ unresolvedByAxis removeKey: (unresolvedByAxis keyAtValue: axisConstraints) ] ].
		
		resolvable isEmpty
	] whileFalse: [
		resolvable do: [:each | each addGivensTo: given].
		ordered addAll: resolvable].
	^ordered! !

!KSSimpleLayout methodsFor: 'resolving' stamp: 'yo 10/12/2012 11:01'!
resolvedConstraints
	"First resolve order of individual constraints, then group them by subject and axis"
	| ordered subjName defs subjAxis |
	resolved ifNotNil: [^resolved].
	resolved := OrderedCollection new.
	ordered := self orderedConstraints.
	[ordered isEmpty] whileFalse: [
		"Go back to front so dependencies come first"
		subjName := ordered last subjectName.
		subjAxis := self axisOf: ordered last subjectAttribute.
		defs := ordered select: [:each | each definesAxis: subjAxis of: subjName].
		ordered removeAll: defs.
		resolved addFirst: (KSSimpleLayoutConstraints new constraints: defs)].
	^resolved! !
