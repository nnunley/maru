KSUserEventHandler subclass: #KSRecognizer
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Demos'!

!KSRecognizer methodsFor: 'all' stamp: 'yo 9/7/2012 14:41'!
handleResult = (result, points) ->
	if result[0] == "rectangle"
		var rect = points[0].corner(Rectangle.encompassing(points).corner())
		var box = KSBox.withShape(this.newRectShape(rect))
		box.topLeft(rect.topLeft())
		@whole.addFirst(box)
	if result[0] == "circle"
		var rect = points[0].corner(Rectangle.encompassing(points).corner())
		var box = KSBox.withShape(this.newCircleShape(rect))
		box.topLeft(rect.topLeft())
		@whole.addFirst(box)! !

!KSRecognizer methodsFor: 'all' stamp: 'yo 10/4/2012 23:14'!
newRectShape  = (rect) ->
	var stroke = GeziraStrokedPath.sketchyRect(P(0, 0).extent(rect.extent())).fill(Color.gray(0.8)).stroke(GeziraStroke.width(2))
	var grad = GeziraFill._gradient_from_to(
	{0: Color.gray(0.6).alpha(0.6),
		0.85: Color.gray(0.6).alpha(0.6),
		0.90: Color.gray(0.5).alpha(0.9),
		0.95: Color.gray(0.6).alpha(0.6),
		1.0: Color.gray(0.6).alpha(0.6)}.associations().asSortedArray(),
	P(0, 0), rect.extent())
	KSShape.new().elements([
		stroke,
		GeziraFilledPath.new().floats(stroke.floats()).fill(grad)].asArray())! !

!KSRecognizer methodsFor: 'all' stamp: 'yo 9/5/2012 22:39'!
setStroke = (points) ->
	this.stroke.shape().elements()[0] = (GeziraStrokedPath.polyline(points).fill(Color.black()).stroke(GeziraStroke.width(3)))
	this.stroke.shape().computeBounds()
	this.stroke.shape()! !
