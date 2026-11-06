KSUserEventHandler subclass: #KSExample
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSExample methodsFor: 'as yet unclassified' stamp: 'tk 5/23/2012 11:11'!
listTest = (stayUp) ->
	var listBox = JBox._new()
	listBox._layout(JVerticalLayout._new())
	listBox.eventHandler().beMenuHandler(stayUp, [["abc", "abc"], ["def", "def"], ["ghi", "ghi"]])
	var bBox = JBox._new()
	this.whole._add(listBox)
	this.whole._add(bBox)
	bBox._x(100)

	this.listBox = listBox._handler()
	this.bBox = bBox._handler()
	this.script = $$(@listBox.itemSelected.mapE((x) ->
		@bBox.whole._textContents(x.item._textContents())))

	var cBox = JBox._new()
	this.whole._add(cBox)
	cBox._x(200)
	cBox.eventHandler().attachButtonHandler()
	this.cBox = cBox._handler()
	this.script2 = $$(@cBox.fire.mapE((x) ->
		@listBox.listChangeRequest = [["jkl", "jkl"], ["mno", "mno"], ["pqr", "pqr"], ["stu", "stu"]]))
	this! !

!KSExample class methodsFor: 'as yet unclassified' stamp: 'yo 5/23/2012 11:45'!
test3
	<exampleSummary: 'A demo that shows a draggable text label and a menu that changes the color of the text label'>
	<exampleStatus: #active>
	<exampleInvocation: 'KSExample test3'>
	| ww |
	ww := JMorph new openInWorld.
	ww window handlerAs: self.	"has listTest defined"
	ww window handler eval: 'this.listTest(true)'.
	^ ww window! !
