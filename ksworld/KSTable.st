KSUserEventHandler subclass: #KSTable
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects'!

!KSTable methodsFor: 'accessing' stamp: 'yo 3/8/2013 19:42'!
addFormula = (key, value) ->
	if !!this.columnNames
		return this
	this[key] = if value.isEventStream() then value else this.streamOf(value)
	var max = 0
	for i in [0 .. this.columnNames.size()]
		var e = this.columnNames[i]
		var column = this.columnAt(i+1)
		var j = this.findMaxRowFor(e)
		max = if max > j + 1 then max else j + 1
		for x in [column.contentsSize() .. max]
			var cell = this.newCell(e.concat(x.printString()))
			column.add(cell)
	var numbers = this.cells().contentsAt(1)
	numbers.removeAll()
	for ii in [0 .. max]
		cell = this.newCell(null)
		cell.width(20)
		if ii > 0
			cell.textContents(ii.printString())
		numbers.add(cell)! !

!KSTable methodsFor: 'accessing' stamp: 'yo 9/5/2013 21:42'!
addFormulaString = (key, aString) ->
	this.addFormula(key, this.eval2(key.concat("<-").concat(aString)))! !

!KSTable methodsFor: 'accessing' stamp: 'ael 3/5/2013 16:13'!
addFormulae = (aString) ->
	this.eval(aString)
	if !!this.columnNames
		return this
	var max = 0
	for i in [0 .. this.columnNames.size()]
		var e = this.columnNames[i]
		var column = this.columnAt(i+1)
		var j = this.findMaxRowFor(e)
		max = if max > j + 1 then max else j + 1
		for x in [column.contentsSize() ... j]
			var cell = this.newCell(e.concat(x.printString()))
			column.add(cell)
	var numbers = this.cells().contentsAt(1)
	numbers.removeAll()
	for ii in [0 ... max]
		cell = this.newCell(null)
		cell.width(20)
		if ii > 0
			cell.textContents(ii.printString())
		numbers.add(cell)! !

!KSTable methodsFor: 'accessing' stamp: 'yo 9/5/2013 21:16'!
behavior = () ->
	this.focus = $$(switchColE(@allCells, "buttonDown"))
	this.focusChanged = $$(@focus.mapE((ev) ->
		if ev.handler.cellName
			this.cellLabel.textContents(ev.handler.cellName)
			var v = this[ev.handler.cellName]
			if v.isEventStream()
				this.formulaEditor.textContents(v.code().asString())
			else
				this.formulaEditor.textContents(v.asString())))
	this.acceptFormula = $$(@formulaEditor.contentsAccepted.mapE((ev) ->
		this.addFormulaString(this.cellLabel.textContents(), ev.handler.textContents())))! !

!KSTable methodsFor: 'accessing' stamp: 'yo 3/8/2013 19:15'!
columnNames = (aCollection, label) ->
	var whole = this.whole
	this.columnNames = aCollection
	whole.removeAll()
	whole.add(this.newTitlePane(label))
	whole.add(KSBox._extent_fill(whole.extent() - P(0, 25), Color.white()))
	whole.add(this.newFormulaPane())
	whole.layout(KSVerticalLayout.new())
	whole.layout().inset(2)
	this.cells().layout(KSHorizontalLayout.new())
	var box = KSBox.new()
	box.name("numbers")
	this.cells().add(box) // the left-most numbers
	box.borderWidth(1)
	box.borderFill(Color.black())
	box.layout(KSVerticalLayout.new())
	for c in aCollection
		box = KSBox.new()
		box.name(c)
		box.borderWidth(1)
		box.borderFill(Color.black())
		box.layout(KSVerticalLayout.new())
		var header = this.newCell(nil)
		header.textContents(c)
		box.add(header)
		this.cells().add(box)
	this.behavior()! !

!KSTable methodsFor: 'accessing' stamp: 'yo 3/11/2013 13:46'!
suppressUpdates = () ->
	for cell in this.allCells()
		cell.suppressUpdate = true! !

!KSTable methodsFor: 'private' stamp: 'yo 3/8/2013 16:41'!
allCells = () ->
	if !!this.allCells
		this.allCells = []
	return this.allCells! !

!KSTable methodsFor: 'private' stamp: 'yo 1/7/2013 16:03'!
cells = () ->
	return this.whole.contentsAt(2)! !

!KSTable methodsFor: 'private' stamp: 'yo 1/7/2013 16:04'!
columnAt = (index) ->
	return this.cells().contentsAt(index+1)! !

!KSTable methodsFor: 'private' stamp: 'yo 7/6/2012 01:07'!
findMaxRowFor = (columnName) ->
	var i = 1
	while true
		if !!this.hasOwnProperty(columnName.concat(i.printString()))
			return i - 1
		i += 1! !

!KSTable methodsFor: 'private' stamp: 'yo 1/7/2013 16:04'!
formulaPane = () ->
	return this.whole.contentsAt(3).contentsAt(2)! !

!KSTable methodsFor: 'private' stamp: 'yo 8/29/2013 16:15'!
newCell = (name) ->
	var cell = this.whole.factory().newLineEditor(80, Color.white(), KSFont.defaultFont().withSize(14))
	cell.beOptimizedField()
	cell.fill(Color.white())
	cell.extent(P(80, 20))
	cell.borderWidth(1)
	cell.clipping(true)
	cell.borderFill(Color.gray())
	if name
		cell.name(name)
		cell.beCell(this, name)
		cell.listen(["buttonDown"])
		this.allCells().add(cell)
	return cell! !

!KSTable methodsFor: 'private' stamp: 'yo 9/5/2013 21:07'!
newFormulaPane = () ->
	var row = KSBox._extent_fill(P(this.whole.extent().x(), 20), Color.white())
	row.layout(KSHorizontalLayout.new())
	row.layout().space = 4
	this.cellLabel = @whole.factory().newLineEditor(100, Color.white(), KSFont.defaultFont().withStyle(1).withSize(14))
	this.cellLabel.layout().beReadOnly(true)
	this.cellLabel.layout().minimumWidth = 10
	this.cellLabel.borderWidth(1)
	this.cellLabel.borderFill(Color.gray())
	row.add(this.cellLabel)
	this.cellLabel.name("cellLabel")
	var equal = @whole.factory().newLabel("<-", Color.white(), KSFont.defaultFont().withStyle(1).withSize(14).fill(Color.blue()))
	row.add(equal)
	equal.name("equal")
	this.formulaEditor = @whole.factory().newLineEditor(@whole.width(), Color.white(), KSFont.defaultFont().withStyle(1).withSize(14))
	this.formulaEditor.borderWidth(1)
	this.formulaEditor.layout().minimumWidth = 10
	this.formulaEditor.borderFill(Color.gray())
	this.formulaEditor.extent(P(this.whole.extent().x() - row.first().extent().x(), 20))
	row.add(this.formulaEditor)
	this.formulaEditor.name("formulaEditor")
//	var s = @whole.factory().newLabel("S", Color.white(), KSFont.defaultFont().withStyle(1).withSize(14).fill(Color.blue()))
//	s.attachButtonHandler()
//	row.add(s)
//	s.name("source")
	var layout = KSSimpleLayout.new()
	layout._keep_of_to(#"topLeft", "cellLabel", #"topLeft")
	layout._keep_of_to_of(#"topLeft", "equal", #"topRight", "cellLabel")
	layout._keep_of_to_of(#"topLeft", "formulaEditor", #"topRight", "equal")
	layout._keep_of_to_of(#"right", "formulaEditor", #"left", "source")
	layout._keep_of_to(#"topRight", "source", #"topRight")
	row.layout(layout)
	return row! !

!KSTable methodsFor: 'private' stamp: 'yo 7/6/2012 01:08'!
newSummaryPane = () ->
	return this! !

!KSTable methodsFor: 'private' stamp: 'yo 3/15/2013 18:14'!
newTitlePane = (label) ->
	var titlePane = KSBox._extent_fill(P(this.whole.extent().x(), 20), Color.black())
	titlePane.add(@whole.factory().newLabel(label, Color.transparent(), KSFont.defaultFont().withStyle(3).withSize(14).fill(Color.white())))
	titlePane.attachGenericMoveHandler()
	titlePane.sliderTarget.set(this.whole)
	return titlePane! !

!KSTable class methodsFor: 'examples' stamp: 'yo 7/13/2012 14:35'!
citiesExample1
"
KSTable citiesExample1
"
	| ll table cellName data numCols numRows tableData value weights expr summedData cityData weightsRow columnNames box |
	ll := JMorph new openInWorld extent: 900@500.
	ll window add: (table := JBox extent: 850@400 fill: Color white).
	
	data := self cityData.
	columnNames := {'name'. 'stability'. 'healthcare'. 'culture'. 'education'. 'infrastructure'. 'total'. 'foo'}.
	weights := (data at: 2) copyFrom: 3 to: 7.
	weightsRow := { '(weights)' }, weights, { weights sum }.
	cityData := (data allButFirst: 2) collect: [ :t | { t first }, (t copyFrom: 3 to: 7) ].
	summedData := cityData collect: [ :t | t, { ((t copyFrom: 2 to: 6) with: weights collect: [ :s :w | s * w * 0.01 ]) sum printShowingMaxDecimalPlaces: 2 } ].
	tableData := { weightsRow }, (summedData sort: [ :x :y | x last >= y last ]).

	numRows := 5.
	numCols := 7.
	table handlerAs: KSTable.
	table handler columnNames: columnNames with: 'Liveability'.
	1 to: numRows do: [ :dataRow |
		1 to: numCols do: [ :dataCol |
			value := (tableData at: dataRow) at: dataCol.
			value isString ifTrue: [ value := '"', value, '"' ].
			cellName := (columnNames at: dataCol), dataRow asString.
			expr := 'this.', cellName, ' = ', value asString.
"Transcript cr; show: expr."
			table handler addFormulae: expr.
			]
		].

	table handler addFormulae: 'this.foo1 = ""'.
	numRows + 1 to: numRows + 5 do: [:row |
		columnNames allButLast do: [:col |
			table handler addFormulae: 'this.', col, row asString, ' = ""']].

	table contents second contents last height: table contents second contents last height + 1.
	ActiveWorld doOneCycleNow.
	table contents second contents last delete.
	ll extent: 765@245.
	ActiveWorld doOneCycleNow.

	box := ((table handler columnAt: 3) at: 4).
	box contentsDo: [:c | c fill: Color blue].

	FileDirectory default deleteFileNamed: 'table1.bmp'.
	ll imageForm writeBMPfileNamed: 'table1.bmp'.
	"CommandShell command: 'convert ', (FileDirectory default fullPathFor: 'table1.bmp'), ' ',  (FileDirectory default fullPathFor: 'table1.bmp')"! !

!KSTable class methodsFor: 'examples' stamp: 'yo 7/13/2012 12:46'!
cityData
	| csv f results |
	f := FileDirectory default oldFileNamed: 'liveability.csv'.
	[ csv := f upToEnd ] ensure: [ f close ].
	results := ((1 to: 142) collect: [ :x |  Array new: 8 ]) asArray.
	(CSVReader matchAll: csv with: #start) first withIndexDo: [:rec :recIndex |
			rec withIndexDo: [:field :fieldIndex |
				(field notEmpty and: [ field first isDigit ]) ifTrue: [ field := field asNumber ].
				(results at: fieldIndex) at: recIndex put: field
			] ].
	^results! !

!KSTable class methodsFor: 'examples' stamp: 'yo 3/8/2013 19:36'!
example1
"
KSTable example1
"
	| ll table handler |
	ll := KSMorph new openInWorld extent: 500@500.
	ll window add: (table := KSBox extent: 400@400 fill: Color white).
	handler := self new.
	handler installTo: table.
	handler columnNames: {'A'. 'B'. 'C'} with: 'some title'.
	handler addFormulaString: 'A1' with: '40'.
	handler addFormulaString: 'A2' with: '$$(@A1 + 1)'.

	handler addFormulaString: 'A3' with: '$$(@A2 + 1)'.
	handler addFormulaString: 'B1' with: '$$(@A2 + 1)'.
	handler addFormulaString: 'A1' with: '$$(timerE(100))'.
	^ handler! !

!KSTable class methodsFor: 'examples' stamp: 'yo 3/8/2013 19:35'!
newTable
	| table handler |
	table := KSBox extent: 400@400 fill: Color white.
	handler := self new.
	handler installTo: table.
	handler columnNames: {'A'. 'B'. 'C'} with: 'Table'.
	handler addFormulaString: 'A1' with: '0'.
	handler addFormulaString: 'B1' with: '0'.
	handler addFormulaString: 'C1' with: '0'.
	^ table! !
