KSUserEventHandler subclass: #KSCircuitEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CooperatingLanguages-Demos'!

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:49'!
options
	^ #(debug true)"setLogic AUFNIRA)"! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:50'!
readFrom = (env) ->
	for thingBox in this.whole.contents()
		var handler = thingBox.handler
		if handler.thing
			for k, v of env[thingBox.name()]
				if handler.attributes[k] && !!handler.readOnly[k]
					handler.attributes[k] = v
	this.showAllProperties()! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 11/2/2012 10:16'!
readOnlyAttributes = () ->
	return ["Node.leads",
			"Lead.node",
			"Resistor.resistance",
			"Resistor.lead1",
			"Resistor.lead2",
			"Battery.voltage", 
			"Battery.lead1",
			"Battery.lead2",
			"Wire.lead1",
			"Wire.lead2",
			"Wire.resistance",
			"TwoLeadedThing.lead1",
			"TwoLeadedThing.lead2"]! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:50'!
readOnlyObjectNames = () ->
	var result = []
	var leadLine = WriteStream.on("")
	for c in this.whole.contents()
		if c.handler.thing
			var objReadOnly = true
			for k, v of c.handler.readOnly
				objReadOnly = objReadOnly && v
			if objReadOnly
				result.push(c.name())
	return result! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:51'!
readOnlyObjects = () ->
	var result = this.readOnlyObjectNames()
	return (this.environment[v] for v in result)! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:51'!
solve = () ->
	var p1 = this.environment._hostProgram_in_readOnlyObjects_readOnlyAttributes_options(
"
	true
", "OCassowary".asSymbol(), this.readOnlyObjects(), this.readOnlyAttributes(), this.options())
	p1.runAndCommit()
	this.readFrom(this.environment)! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:53'!
variables = () ->
	var result = ""
	var vars = {}
	var leadLine = WriteStream.on("")
	for c in this.whole.contents()
		if c.handler.thing
			(vars[c.handler.thing] ?= []).push(c.handler)

	var firstLead = true
	for k, v of vars
		var line = WriteStream.on("")
		line.nextPutAll("var ")
		var firstTime = true
		for elem in v
			if !!firstTime
				line.nextPutAll(", ")
			line.nextPutAll(elem.name)
			firstTime = false
			if ["Resistor", "Wire", "Battery"].includes(k)
				if !!firstLead
					leadLine.nextPutAll(", ")
				else
					firstLead = false
					leadLine.nextPutAll("var ")
				leadLine.nextPutAll(elem.name)
				leadLine.nextPutAll("a")
				leadLine.nextPutAll(", ")
				leadLine.nextPutAll(elem.name)
				leadLine.nextPutAll("b")
		line.nextPutAll(": ")
		line.nextPutAll(k)
		result = result.concat(line.contents())
		result = result.concat("\r")

	if !!firstLead
		leadLine.nextPutAll(": Lead\r")
		result = result.concat(leadLine.contents())
	return result! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:55'!
writeInto = (env) ->
	var result = []
	var vars = {}
	for c in this.whole.contents()
		if c.handler.thing
			if !!(vars[c.handler.thing])
				vars[c.handler.thing] = []
			vars[c.handler.thing].push(c.handler)

	for battery in vars["Battery"]
		var name = battery.name
		var l1 = env[name.concat("a")] = (env.getClass("Lead".asSymbol()))._new()
		var l2 = env[name.concat("b")] = (env.getClass("Lead".asSymbol()))._new()
		env[battery.name] = (env.getClass("Battery".asSymbol())).ksNew({lead1: l1, lead2: l2, voltage: battery.attributes.voltage})

	for resistor in vars["Resistor"]
		var name = resistor.name
		var l1 = env[name.concat("a")] = (env.getClass("Lead".asSymbol()))._new()
		var l2 = env[name.concat("b")] = (env.getClass("Lead".asSymbol()))._new()
		env[resistor.name] = env.getClass("Resistor".asSymbol()).ksNew({lead1: l1, lead2: l2, resistance: resistor.attributes.resistance})

	for wire in vars["Wire"]
		var name = wire.name
		var l1 = env[name.concat("a")] = (env.getClass("Lead".asSymbol()))._new()
		var l2 = env[name.concat("b")] = (env.getClass("Lead".asSymbol()))._new()
		env[wire.name] = env.getClass("Wire".asSymbol()).ksNew({lead1: l1, lead2: l2})

	for node in vars["Node"]
		var n = (env.getClass("Node".asSymbol()))._new()
		env[node.name] = n
		var leads = []
		for c in node.connections
			var suffix = if c.handler.start.handler == node then "a" else "b"
			env[c.handler.name.concat(suffix)].node = n
			leads.push(env[c.handler.name.concat(suffix)])
		env[node.name].leads = leads! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:55'!
writeReadOnlysIntoField = (listStr) ->
	var stream = WriteStream.on("")
	var firstTime = true
	for elem in listStr
		if !!firstTime
			stream.nextPutAll(", ")
		stream.nextPutAll(elem)
		firstTime = false
	stream.nextPutAll(": ReadOnly")

	var field = this.variablesField
	var pos = field.last().bottomLeft()
	var box = JBox.newLabel(stream.contents())
	box.position(pos)
	field.add(box)! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:56'!
writeVariables = () ->
	var variables = this.variables()
	this.writeVariablesIntoField(variables)
	this.writeReadOnlysIntoField(this.readOnlyObjectNames())
	this.environment.problem(variables)
	this.writeInto(this.environment)! !

!KSCircuitEditor methodsFor: 'coop env interface' stamp: 'yo 7/5/2012 21:56'!
writeVariablesIntoField = (variables) ->
	var field = this.variablesField
	field.removeAll()
	var pos = P(0, 0)
	for line in variables.lines()
		var box = JBox.newLabel(line)
		box.position(pos)
		field.add(box)
		pos = box.bottomLeft()! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 14:35'!
beEditor = () ->
	this.environment = CoopLangs.newModel(CoopLangsLibrary.ElectricalComponents())
	this.whole.name("field")
	var field = this.whole
	field.attachDropAcceptor()
	field.addAsParts(this.newList())
	var firstNode = this.newNode()
	firstNode.center(field.extent()/2)
	field.addFirst(firstNode)
	field.dropRequest = field.streamOf(undefined)

	field.addConnection = (thing, end, endPos) ->
		if end.isConnectorEnd
			var newNode = this.newNode()
			newNode.center(field.localPointFor(endPos))
			this.whole.addFirst(newNode)
			thing.end.droppedInto.set({box: end, target: newNode})

	this.setUpShapes()
	this.variablesField = this.setUpVariablesField()! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 16:18'!
beNode = (field, obj) ->
	var box = this.whole
	this.thing = "Node"
	this.field = field
	box.attachDropAcceptor()
	box.attachGenericMoveHandler()
	this.doButtonDown = $$(@whole.buttonDown.mapE((ev) ->
		if ev.buttons.anyMask(8) then undefined else ev).mapE(@whole.downFunc2))
	this.doShiftButtonDown = $$(@whole.buttonDown.mapE((ev) ->
		if ev.buttons.anyMask(8) then ev else undefined).mapE((ev1) ->
			this.field.newTwoLeadedThingFrom(box, ev1)))
	box.addConnection = (x) -> (this.whole.connections ?= {})[x] = x
	box.removeConnection = (x) -> delete (this.whole.connections ?= {})[x]

	box.listen(["buttonDown"])
	this.attributes = obj
	this.readOnly = {}! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 15:54'!
beTwoLeadedThing = (type, obj, path, fill) ->
	var box = this.whole
	box.beConnectorHandler(null, null)
	box.pathFromTo.set(path)
	box.borderFill(fill)
	this.attributes = obj
	this.readOnly = {}
	for k, v of obj
		this.readOnly[k] = false
	this.thing = type! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 15:46'!
newBattery = (voltage) ->
	var box = KSBox.new()
	box.name(this.nextId("Battery"))
	var handler = this.class().new()
	handler.installTo(box)
	handler.beTwoLeadedThing("Battery", {voltage: voltage ? 1.0}, this.batteryShape, Color.black())
	return box! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 15:38'!
newList = () ->
	var listBox = KSBox.new()
	listBox.fill(Color.transparent())

	var newBox = KSBox.new()
	newBox.fill(Color.transparent())
	newBox.layout(KSVerticalLayout.new())
	newBox.layout().space(3)
	newBox.beMenuHandler(true, [["newBattery", "Battery"], ["newResistor", "Resistor"], ["newWire", "Wire"]])
	for item in newBox.items
		item.highlightEnabled = false
		item.selectedFill = Color._r_g_b(0.533, 0.784, 0.972)
		item.borderWidth(1)
		item.borderFill(Color.black())
		item.cornerRadius(4)
	this.newBox = newBox
	this.selection = "newBattery"
	this.script = $$(@newBox.itemSelected.mapE((x) ->
		this.selection = x.item.menuAction))
//	listBox.first().handler.doFire()
//	Hmm, I don't know any better way for now
	newBox.first().fill(Color._r_g_b(0.533, 0.784, 0.972))
	listBox.add(newBox)

	var propBox = KSBox.newLabel("Property")
	propBox.beToggleButtonHandler(false)
	propBox.selectedFill = Color._r_g_b(1.0, 0.634, 0.819)
	propBox.defaultFill = Color.transparent()
	propBox.borderWidth(1)
	propBox.borderFill(Color.black())
	propBox.cornerRadius(4)
	this.propBox = propBox
	this.showProperty = $$(@propBox.selected.mapE((v) ->
		if v
			this.showAllProperties()
		else
			this.removeAllProperties()))

	propBox.topLeft(P(0, 130))
	listBox.add(propBox)

	var problemBox = KSBox.newLabel("Problem")
	problemBox.attachButtonHandler()
	problemBox.borderWidth(1)
	problemBox.borderFill(Color.black())
	problemBox.cornerRadius(4)
	this.problemBox = problemBox
	this.writeProblem = $$(@problemBox.fire.mapE((x) ->
		this.writeVariables()))

	problemBox._topLeft(P(0, 170))
	listBox.add(problemBox)

	var solveBox = KSBox.newLabel("Go")
	solveBox.borderWidth(1)
	solveBox.borderFill(Color.black())
	solveBox.cornerRadius(4)
	solveBox.attachButtonHandler()
	this.solveBox = solveBox
	this.solveButtonAction = $$(@solveBox.fire.mapE((x) ->
		this.solve()))

	solveBox.topLeft(P(0, 192))
	listBox.add(solveBox)

	return listBox! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 11:07'!
newNode = () ->
	var box = KSBox.withShape(KSShape.new().elements([GeziraFilledPath.oval(
		P(0, 0).corner(P(12, 12))).fill(Color.gray())]))
	box.name(this.nextId("Node"))
	var handler = this.class().new()
	handler.installTo(box)
	handler.beNode(this, {voltage: 0.0})
	return box! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 11:07'!
newResistor = (resistance) ->
	var box = KSBox.new().name(this.nextId("Resistor"))
	var handler = this.class().new()
	handler.installTo(box)
	handler.beTwoLeadedThing("Resistor", {resistance: resistance ? 1.0}, this.resistorShape, Color.black())
	return box! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 6/7/2012 16:15'!
newTwoLeadedThing = (type, obj, sel, fill) ->
	var box = JBox._new()
	box._handlerAs(this._class())
	box.handler().beConnectorHandler()
	box.handler().pathFromTo = this[sel]
	box.handler().fill = fill
	box.handler().attributes = obj
	box.handler().readOnly = {}
	for k, v of obj
		box.handler().readOnly[k] = true
	box.handler().thing = type
	box._name(this.nextId(box.handler().thing))

	box.handler().listen("pointerEnter", "pointerLeave", "motionQuery")

	box.handler().mayBePopUp = $$(extractE(box, "pointerEnter").mapE((ev) ->
		if this.showProperty.currentValue()
			this.showPropertyFor(box)))

	box.handler().mayBePopDown = $$(extractE(box, "pointerLeave").delayE(1000).mapE((ev) ->
		if !!(ev.to && ev.to._hasContainer(box))
			this.hidePropertyFor(box)))

	return box! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 16:28'!
newTwoLeadedThingFrom = (box, evt) ->
	if !!this.selection
		return this
	var thing = this.ksPerform(this.selection, [null])
	thing.start.droppedInto.set({box: thing.start, target: box})
	thing.end.startTracking(evt)
	thing.topLeft(P(100, 100))  // for now
	this.whole.addFirst(thing)! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 11:12'!
newWire = (dummy) ->
	var box = KSBox.new().name(this.nextId("Wire"))
	var handler = this.class().new()
	handler.installTo(box)
	handler.beTwoLeadedThing("Wire", {}, this.wireShape, Color.black())
	return box! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 7/17/2012 10:23'!
nextId = (thingName) ->
	var things = (x.name().allButFirst(thingName.size()) for x in this.whole.contents() when x.handler.thing == thingName)
	if things.size() == 0
		return thingName.concat("1")
	return thingName.concat(((t.asNumber() for t in things).max() + 1).asString())! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 11:16'!
setUpShapes = () ->
	this.width = 3
	var field = this.whole

	this.batteryShape = (from, to) ->
		var col = this._batteryPathFrom_to(from, to)
		for elem in col
			elem.stroke(GeziraStroke.width(this.width ? 2)).fill(this.fill ? Color.black())
		KSShape.new().elements(col)

	this.resistorShape = (from, to) ->
		KSShape.new().elements([this._resistorPathFrom_to(from, to).stroke(GeziraStroke.width(this.width ? 2)).fill(this.fill ? Color.black())])

	this.wireShape = (from, to) ->
		KSShape.new().elements([this._wirePathFrom_to(from, to).stroke(GeziraStroke.width(this.width ? 2)).fill(this.fill ? Color.black())])! !

!KSCircuitEditor methodsFor: 'initialization and creation' stamp: 'yo 11/2/2012 11:16'!
setUpVariablesField= () ->
	var box = KSBox._extent_fill(P(this.whole.width(), 200), Color.gray(0.92))
	box.bottomLeft(this.whole.bottomLeft())
	this.whole.addAsParts(box)
	box.name("variables")! !

!KSCircuitEditor methodsFor: 'property sheet' stamp: 'yo 11/2/2012 11:20'!
hidePropertyFor = (box) ->
	if box.contents().size() == 0
		return this
	box.contents().first().delete()! !

!KSCircuitEditor methodsFor: 'property sheet' stamp: 'tk 2/27/2013 15:01'!
newTypeableLabel = (obj, attr) ->
	var label = KSBox.newLabel(obj.attributes[attr].asString())
	KSTextLayout.new().installTo(label)
	label.beLineEditor()
	label.attribute = attr
	label.object = obj
	label.fill(Color.white())

	label.getFocus = $$(@buttonDown.mapE((x) ->
		x.hand.keyboardFocus(label)))
	label.handler.stroke = $$(@keyStroke.mapE((x) ->
		if x.keyValue == 8
			label.layout().charTyped08()
		else
			if x.keyValue >= 32
				label.insertChar(x.keyValue)
		var v = this.parseNumber(label.textContents())
		label.object.attributes[label.attribute] = v))

	label.listen(["keyStroke", "buttonDown"])
	return label! !

!KSCircuitEditor methodsFor: 'property sheet' stamp: 'yo 7/5/2012 21:48'!
parseNumber: arg
	^ [arg asNumber] on: Error do: [0.0]! !

!KSCircuitEditor methodsFor: 'property sheet' stamp: 'yo 7/5/2012 21:46'!
propertyRow = (obj, name) ->
	var box = JBox._new()
	box.layout(JHorizontalLayout._new())
	box.fill(Color.transparent())
	box.borderWidth(1)
	box.borderFill(Color.gray())

	var anchor = JBox.graphicNamed("anchor")
	anchor.scale(0.07)
	var anchorBox = JBox._extent_fill(P(20, 20), Color.white())
	anchor.center(anchorBox.extent()/2)
	anchorBox.add(anchor)
	anchorBox.eventHandler().beToggleButtonHandler(obj.readOnly[name])
	anchorBox.handler.anchor = anchor.handler
	anchorBox.handler.toggleAnchor = $$(@selected.mapE((selected) ->
		anchor.visible(selected)
		obj.readOnly[name] = selected))
	box.add(anchorBox)

	var label = JBox.newLabel(name)
	label.borderFill(Color.gray())
	label.fill(Color._white())
	label.borderWidth(1)
	box.add(label)

	var value = this.newTypeableLabel(obj, name)
	box._add(value)
	return box! !

!KSCircuitEditor methodsFor: 'property sheet' stamp: 'yo 7/5/2012 21:46'!
removeAllProperties = () ->
	for old in this.propertySheets
		old._delete()! !

!KSCircuitEditor methodsFor: 'property sheet' stamp: 'yo 7/5/2012 21:47'!
showAllProperties = () ->
	this.removeAllProperties()
	this.propertySheets = (thingBox.handler.showPropertyFor(thingBox) for thingBox in this.whole.contents() when thingBox.handler.thing.asBoolean())! !

!KSCircuitEditor methodsFor: 'property sheet' stamp: 'yo 7/5/2012 21:48'!
showPropertyFor = (box) ->
	if box.contents().size() > 0
		return this

	var handler = box.handler
	var table = JBox._new()
	table.layout(JVerticalLayout._new())
	table.fill(Color.transparent())

	for k, v of handler.attributes
		table.add(this.propertyRow(handler, k))

	table.topLeft(box.extent()/2.0)
	box.add(table)
	return table! !

!KSCircuitEditor methodsFor: 'property sheet' stamp: 'yo 6/6/2012 23:46'!
togglePropertyFor = (box) ->
	if box._contents()._size() > 0
		box._contents()._first()._delete()
		return this

	var handler = box.handler()
	var table = JBox._new()
	table._layout(JVerticalLayout._new())
	table._fill(Color._transparent())

	for k, v of handler.attributes
		table._add(this.propertyRow(handler, k))

	table._topLeft(box._extent()/2.0)
	box._add(table)
	! !

!KSCircuitEditor methodsFor: 'shapes' stamp: 'yo 6/5/2012 21:12'!
batteryPathFrom: from0 to: to0
	| dir diff remaining dist scale cur first fourth pDir second third |
	diff := to0 - from0.
	dist := from0 dist: to0.
	dist =? 0 ifTrue: [
		^ {GeziraStrokedPath new points: {{0@0. 0@0. 0@0}}}].
	dir := diff / dist.
	pDir := dir y@dir x negated.
	dist > 10 ifTrue: [
		remaining := dist - 10.
		scale := 1.0]
	ifFalse: [
		remaining := 0.
		scale := dist / 10].

	first := {0@0. 0@0. (cur := dir * (remaining/2.0))}.
	second := {cur + (pDir negated * 10). cur + (pDir negated * 10). cur + (pDir * 10)}.
	cur := cur + (dir * 10).
	third := {cur + (pDir negated * 6). cur + (pDir negated * 6). cur + (pDir * 6)}.
	fourth := {cur. cur. cur + (dir * (remaining/ 2.0))}.
	^ {first. second. third. fourth} collect: [: e | GeziraStrokedPath new points: {e}].! !

!KSCircuitEditor methodsFor: 'shapes' stamp: 'yo 6/6/2012 16:08'!
resistorPathFrom: from0 to: to0
	| dir diff remaining dist qpi scale dirs lens |
	diff := to0 - from0.
	dist := from0 dist: to0.
	dist =? 0 ifTrue: [
		^ GeziraStrokedPath new points: {{0@0. 0@0. 0@0}}].
	dir := diff / dist.
	dist > 50 ifTrue: [
		remaining := dist - 50.
		scale := 1.0]
	ifFalse: [
		remaining := 0.
		scale := dist / 50].

	qpi := Float pi / 3.
	lens := #(1 8 16 16 16 16 16 8 1) * scale.
	dirs := {qpi. qpi * -2.0. qpi * 2. qpi * -2.0. qpi * 2. qpi * -2.0. qpi * 2. qpi * -1.0. 0}.

	^ GeziraStrokedPath build: [:b |
		b pos: 0@0 dir: dir.
		b line: remaining/2.0.
		lens with: dirs do: [:len :d |
			b line: len.
			b turn: d].
		b line: remaining/2.0].! !

!KSCircuitEditor methodsFor: 'shapes' stamp: 'yo 6/6/2012 16:14'!
wirePathFrom: from0 to: to0
	^ GeziraStrokedPath new points: {{0@0. 0@0. to0 - from0}}.! !

!KSCircuitEditor class methodsFor: 'examples' stamp: 'yo 7/5/2012 21:38'!
example1
"
	KSCircuitEditor example1
"
	| editor handler n0 n1 r n2 |
	editor := self open.
	handler := editor handler.
	n0 := editor first.

	n1 := (handler newNode) center: 250@150.
	editor add: n1.
	r := handler newResistor: 1.0.
	(r handler at: #start) handler ksSet: #droppedBy put: ({#target -> n0} as: KSObject).
	(r handler at: #end) handler ksSet: #droppedBy put: ({#target -> n1} as: KSObject).
	(r handler at: #readOnly) at: #resistance put: true.
	editor add: r.

	n2 := (handler newNode) center: 550@100.
	editor add: n2.
	r := handler newResistor: 1.0.
	(r handler at: #start) handler ksSet: #droppedBy put: ({#target -> n0} as: KSObject).
	(r handler at: #end) handler ksSet: #droppedBy put: ({#target -> n2} as: KSObject).
	(r handler at: #readOnly) at: #resistance put: true.
	editor add: r.

	r := handler newBattery: 3.0.
	(r handler at: #start) handler ksSet: #droppedBy put: ({#target -> n1} as: KSObject).
	(r handler at: #end) handler ksSet: #droppedBy put: ({#target -> n2} as: KSObject).
	(r handler at: #readOnly) at: #voltage put: true.
	editor add: r.

	10 timesRepeat: [editor topContainer worldState processActions].
	^ handler! !

!KSCircuitEditor class methodsFor: 'examples' stamp: 'yo 11/2/2012 16:30'!
open
"
KSCircuitEditor open
"
	| env j field handler |
	env := CoopLangs newModel: CoopLangsLibrary ElectricalComponents.
	j := KSMorph new openInWorld extent: 800@600.
	j window add: (field := KSBox extent: 800@600 fill: Color white).
	handler := self new.
	handler installTo: field.
	handler beEditor.
	^ j! !
