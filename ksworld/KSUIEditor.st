KSUserEventHandler subclass: #KSUIEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSUIEditor methodsFor: 'all' stamp: 'yo 1/17/2013 20:25'!
layout
	^ KSSimpleLayout new
		keep: #topLeft of: 'Save' to: #topLeft offset: 5@5;
		keep: #topLeft of: 'Load' to: #topRight of: 'Save' offset: 10@0;
		keep: #topLeft of: 'Name' to: #topRight of: 'Load' offset: 10@0;
		keep: #center of: 'playfield' to: #center;
		yourself.! !

!KSUIEditor methodsFor: 'all' stamp: 'yo 2/27/2013 23:58'!
setup = () ->
	var whole = @whole
	var theme = whole.factory()
	@whole.fill(Color.gray(0.95))

	this.playfield = KSBox._extent_fill(@whole.extent()*0.75, Color.white())
	this.playfield.name("playfield")
	whole.add(this.playfield)

	var saveButton = theme.newButton("Save")
	var loadButton = theme.newButton("Load")
	var nameField = theme.newLabel("playfield")
	nameField.beLineEditor()
	nameField.name("Name")
	whole.addAsParts(saveButton)
	whole.addAsParts(loadButton)
	whole.addAsParts(nameField)
	this.saveButton = saveButton
	this.loadButton = loadButton
	this.nameField = nameField

	this.save = $$(@saveButton.fire.doE(() ->
		var name = @nameField.textContents()
		if !!name.endsWith(".ks")
			name = name.concat(".ks")
		this.fileList = KSBox.loadBoxFromDirectoryViaCacheFirst('http://tinlizzie.org/dbjr/fileList.ks')
		this.fileList.fileListSetup("Save to File", "Accept", name, "*.ks", P(400, 300), this.fileList.fileListDefaultShortcuts())
		@whole.topContainer().addAsParts(this.fileList)))

	this.doSave = $$(@fileList.fire.mapE((ev) ->
		@playfield.saveToDirectory(ev.dir.value().directoryNamed(ev.file))
		this.nameField.textContents(ev.file)
		this.fileList.delete()))

	this.load = $$(@loadButton.fire.doE(() ->
		var name = @nameField.textContents()
		if !!name.endsWith(".ks")
			name = name.concat(".ks")
		this.playfield.delete()
		this.playfield = KSBox.loadBoxFromDirectory(name)
		@whole.add(this.playfield)
		this.playfield.translation(P(0, 20))))
	this.whole.handleControlKey(false)
	this.whole.layout(this.layout())! !

!KSUIEditor class methodsFor: 'entry points' stamp: 'yo 1/18/2013 11:23'!
start
"
	KSUIEditor start
"
	| a b w |
	w := KSMorph new openInWorld extent: 800@600.
	b := self new.
	a := KSBox extent: 800@600 fill: Color gray.
	b installTo: a.
	w window add: a.
	b setup.
	^ b! !
