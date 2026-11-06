TestCase subclass: #KSODFReaderTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-ODFReader'!

!KSODFReaderTest methodsFor: 'running' stamp: 'bf 1/9/2013 10:26'!
setUp
	"Processor activeProcess lWindow ifNil: [Processor activeProcess lWindow: LWindow new]."! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 5/13/2011 10:00'!
testAnimation
	"self debug: #testAnimation"
	| anim |
	anim := KSODFAnimation read:
   '<anim:par presentation:node-type="timing-root">
     <anim:seq presentation:node-type="main-sequence">
      <anim:par smil:begin="next">
       <anim:par smil:begin="0s">
        <anim:par smil:begin="0s" smil:fill="hold" presentation:node-type="on-click" presentation:preset-class="entrance" presentation:preset-id="ooo-entrance-appear">
         <anim:set smil:begin="0s" smil:dur="0.001s" smil:fill="hold" smil:targetElement="id1" smil:attributeName="visibility" smil:to="visible"/>
        </anim:par>
       </anim:par>
      </anim:par>
     </anim:seq>
    </anim:par>' asXml elements first.
	self assert: anim arrayedSequence  = {{{'id1'. 'visible'}}}.
	anim scriptPrologue first prettyString =
'(scriptLine :selector "hide"
	(literal :type "box" :name "id1"))'.
	self assert: anim script first prettyString =
'(script
	(scriptLine :selector "hide"
		(literal :type "box" :name "id1"))
	(scriptLine :selector "show" :trigger "space"
		(literal :type "box" :name "id1"))
	(scriptLine :trigger "space" :selector "nextPage"
		(literal :type "box" :name "stack")))'! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 3/31/2011 14:48'!
testAnimationParallel
	"self debug: #testAnimationParallel"
	| anim |
	anim := KSODFAnimation read:
   '<anim:seq>
	  <anim:set smil:targetElement="id1" smil:to="visible"/>
	</anim:seq>' asXml elements first.
	self assert: anim arrayedSequence = #((('id1' 'visible'))).

	anim := KSODFAnimation read:
   '<anim:seq><anim:par>
	  <anim:set smil:targetElement="id1" smil:to="visible"/>
	  <anim:set smil:targetElement="id2" smil:to="hidden"/>
	 </anim:par></anim:seq>' asXml elements first.
	self assert: anim arrayedSequence = {{{'id1'. 'visible'}. {'id2'. 'hidden'}}}.

	anim := KSODFAnimation read:
   '<anim:seq><anim:par>
	  <anim:set smil:targetElement="id1" smil:to="visible"/>
	  <anim:par>
	   <anim:set smil:targetElement="id2" smil:to="hidden"/>
	  </anim:par>
	 </anim:par></anim:seq>' asXml elements first.
	self assert: anim arrayedSequence = {{{'id1'. 'visible'}. {'id2'. 'hidden'}}}.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 3/31/2011 14:51'!
testAnimationState
	"self debug: #testAnimationParallel"
	| anim |
	anim := KSODFAnimation new sequence:
		#((('id1' 'visible'))
		(('id2' 'hidden'))
		(('id2' 'visible'))).
	self assert: (anim firstState at: 'id1') = 'visible'.
	self assert: (anim firstState at: 'id2') = 'hidden'.
	self assert: (anim prologueState at: 'id1') = 'hide'.
	self assert: (anim prologueState at: 'id2') = 'show'.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 10/4/2011 16:40'!
testDrawMaker
	"self debug: #testDrawMaker"
	| xml path |
	xml := '<draw:marker draw:name="Arrow" svg:d="m1 0-1 4h2z" svg:viewBox="0 0 2 4"/>' asXml elements first.
	path := KSODFDocument new readDrawMarker: xml width: 1 style: KSODFStyle empty.
	self assert: path first points asArray = {{0@0. 0@0. -1.0@ -0.25. -1.0@ -0.25. -1.0@ -0.25. -1.0@0.25. -1.0@0.25. -1.0@0.25. 0@0}}.

	path := GeziraPath polyline: {-10@0. 10@0. 10@10}.
	self assert: (path endTangentTransform localPointToGlobal: 1@0) = (10@11).
	self assert: (path startTangentTransform localPointToGlobal: 1@0) = (-11@0).! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 4/4/2011 15:21'!
testEllipse
	"self debug: #testEllipse"
	| xml box style doc |
	xml := '<draw:ellipse
		draw:id="id3"
		draw:layer="layout"
		draw:style-name="gr11"
		draw:text-style-name="P1"
		svg:width="100"
		svg:height="50"
		svg:x="20"
		svg:y="10">
	</draw:ellipse>' asXml elements first.

	style := {#draw:stroke -> 'solid'.
		#'svg:stroke-color' -> '#ff0000'.
		#'svg:stroke-width' -> '3'} as: KSODFStyle.
	doc := KSODFDocument new.
	doc styleMap at: #gr11 put: style.
	box := doc renderDrawEllipse: xml.

	self assert: box extent = (100 @ 50).
	self assert: box topLeft = (20 @ 10).
	self assert: box borderWidth = 3.
	self assert: box borderColor = Color red.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 10/7/2011 13:39'!
testFont
	"self debug: #testFont"
	self assert: KSODFStyle empty fontFamily =  'DejaVuSans'.
	self assert: ({ #'fo:font-family' -> 'DejaVu Sans' } as: KSODFStyle) fontFamily =  'DejaVuSans'.
	self assert: ({ #'fo:font-family' -> 'DejaVu Sans Condensed' } as: KSODFStyle) fontFamily =  'DejaVuSansCondensed'.
	self assert: ({ #'fo:font-family' -> 'Unknown' } as: KSODFStyle) fontFamily =  'DejaVuSans'! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 5/20/2011 10:46'!
testGradientLinear
	"self debug: #testGradientLinear"
	| style gradient |
	style := {#draw:angle->'450'.
		#draw:border->'0%'.
		#draw:name->'Gradient_20_7'.
		#'draw:start-color'->'#008000'.
		#'draw:start-intensity'->'100%'.
		#'draw:end-color'->'#FFFFFF'.
		#'draw:end-intensity'->'100%'.
		#draw:style->'linear'.
		} as: KSODFStyle.
	gradient := style fillGradientLinearOn: KSODFDocument new offset: 0@0 extent: 200@100.
	self assert: (gradient direction - (150 @ 150)) r < 0.001.
	self assert: gradient stops first key = 0.
	self assert: (Color fromArray: gradient stops first value) asHTMLColor = '#008000'.
	self assert: gradient stops second key = 1.
	self assert: (Color fromArray: gradient stops second value) asHTMLColor = '#FFFFFF'.

	style := {#draw:angle->'450'.
		#draw:border->'50%'.
		#draw:name->'Gradient_20_7'.
		#'draw:start-color'->'#008000'.
		#'draw:start-intensity'->'100%'.
		#'draw:end-color'->'#FFFFFF'.
		#'draw:end-intensity'->'100%'.
		#draw:style->'linear'.
		} as: KSODFStyle.
	gradient := style fillGradientLinearOn: KSODFDocument new offset: 0@0 extent: 200@100.
	self assert: (gradient direction - (75 @ 75)) r < 0.001.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 5/19/2011 16:51'!
testGradientLinearDirection
	"self debug: #testGradientLinearDirection"

	self assert: (KSODFStyle new readAngle: 0 extent: 300 @ 400) = {150 @ 0. 150 @ 400}.
	self assert: ((KSODFStyle new readAngle: 450 extent: 400 @ 400) first - (0 @ 0)) r < 0.01.
	self assert: ((KSODFStyle new readAngle: 450 extent: 400 @ 400) second - (400 @ 400)) r < 0.01.
	self assert: (KSODFStyle new readAngle: 900 extent: 300 @ 400) = {0 @ 200. 300 @ 200}.
	self assert: ((KSODFStyle new readAngle: 1350 extent: 400 @ 400) first - (0 @ 400)) r < 0.01.
	self assert: ((KSODFStyle new readAngle: 1350 extent: 400 @ 400) second - (400 @ 0)) r < 0.01.
	self assert: (KSODFStyle new readAngle: 1800 extent: 300 @ 400) = {150 @ 400. 150 @ 0}.
	self assert: ((KSODFStyle new readAngle: 2250 extent: 400 @ 400) first - (400 @ 400)) r < 0.01.
	self assert: ((KSODFStyle new readAngle: 2250 extent: 400 @ 400) second - (0 @ 0)) r < 0.01.
	self assert: (KSODFStyle new readAngle: 2700 extent: 300 @ 400) = {300 @ 200. 0 @ 200}.
	self assert: ((KSODFStyle new readAngle: 3150 extent: 400 @ 400) first - (400 @ 0)) r < 0.01.
	self assert: ((KSODFStyle new readAngle: 3150 extent: 400 @ 400) second - (0 @ 400)) r < 0.01.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 4/12/2011 14:06'!
testGradientRadial
	"self debug: #testGradientRadial"
	| style gradient |
	style := {#draw:angle->'450'.
		#draw:border->'5%'.
		#draw:cx->'50%'.
		#draw:cy->'50%'.
		#'draw:display-name'->'Title Grad'.
		#'draw:end-color'->'#e6e6e6'.
		#'draw:end-intensity'->'100%'.
		#draw:name->'Title_20_Grad'.
		#'draw:start-color'->'#999999'.
		#'draw:start-intensity'->'100%'.
		#draw:style->'radial'
	} as: KSODFStyle.
	gradient := style fillGradientRadialOn: KSODFDocument new offset: 0@0 extent: 200@100.
	self assert: gradient center = (100@50).
	self assert: gradient stops first key = 0.
	self assert: (Color fromArray: gradient stops first value) asHTMLColor = '#E6E6E6'.
	self assert: gradient stops second key = 1.
	self assert: (Color fromArray: gradient stops second value) asHTMLColor = '#999999'.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 4/4/2011 15:22'!
testLine
	"self debug: #testLine"
	| xml box style doc |
	xml := '<draw:line
		draw:layer="layout"
		draw:style-name="line"
		draw:text-style-name="P1"
		svg:x1="10"
		svg:y1="20"
		svg:x2="100"
		svg:y2="200">
	</draw:line>' asXml elements first.

	style := {#draw:stroke -> 'solid'.
		#'svg:stroke-color' -> '#ff0000'.
		#'svg:stroke-width' -> '3'} as: KSODFStyle.
	doc := KSODFDocument new.
	doc styleMap at: #line put: style.
	box := doc renderDrawLine: xml.

	self assert: box shape elements first points = {{10@20. 10@20. 100@200}}.
	self assert: box extent = (90 @ 180).
	self assert: box topLeft = (10 @ 20).
	self assert: box borderWidth = 3.
	self assert: box borderColor = Color red.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 4/4/2011 15:24'!
testPolygon
	"self debug: #testPolygon"
	| xml box |
	xml := '<draw:polygon draw:layer="layout"
		draw:points="0,17158 0,21000 28000,21000 28000,0 22903,0 22903,17746 4811,17745 4810,17158"
		draw:style-name="gr1"
		draw:text-style-name="P1"
		svg:width="280"
		svg:height="210"
		svg:viewBox="0 0 28000 21000"
		svg:x="0cm"
		svg:y="0cm">
	</draw:polygon>' asXml elements first.

	box := KSODFDocument new renderDrawPolygon: xml.
	self assert: box extent = (280@210).
	self assert: (box shape elements first points first collect: [:p | p rounded]) = {0@172. 0@210. 0@210. 0@210. 280@210. 280@210. 280@210. 280@0. 280@0. 280@0. 229@0. 229@0. 229@0. 229@177. 229@177. 229@177. 48@177. 48@177. 48@177. 48@172. 48@172. 48@172. 0@172. 0@172}! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 3/22/2011 11:44'!
testReadStyle
	"self debug: #testReadStyle"
	| doc |
	doc := KSODFDocument
				meta: '<meta/>' asXml
				content: '<office:document-content>
  <office:automatic-styles>
    <style:style style:name="dp1">
      <style:drawing-page-properties key1="value1" />
    </style:style>
  </office:automatic-styles>
</office:document-content>
' asXml
				styles: '<office:document-styles>
  <office:styles>
    <draw:gradient draw:name="Gradient1" key1="value1" />
  </office:styles>
</office:document-styles>
' asXml
				archive: nil
				stream: nil.
	self assert: ((doc styleMap at: #dp1) at: #key1) = 'value1'.
	self assert: ((doc styleMap at: #Gradient1) at: #key1) = 'value1'.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 4/4/2011 15:24'!
testRect
	"self debug: #testRect"
	| xml box |
	xml := '<draw:rect
		draw:style-name="gr32"
		svg:width="200"	svg:height="100"
		svg:x="20"			svg:y="10">
	</draw:rect>' asXml elements first.

	box := KSODFDocument new renderDrawRect: xml.
	self assert: box extent = (200@100).
	self assert: box topLeft = (20@10).! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'bf 1/21/2013 16:00'!
testSVGPathB
	"self debug: #testSVGPathB"
	"KSSVGPathReader drawD: 'B 40 40 200 200 200 120 120 200 Z'"
	| points |
	points := KSSVGPathReader new readPath: 'B 40 40 200 200 200 120 120 200 Z'.
	self assert: ((points first at: 1) - (200 @ 120)) r < 0.001.
	self assert: ((points first at: 6) - (120 @ 40)) r < 0.001.
	self assert: ((points first at: 12) - (40 @ 120)) r < 0.001.
	self assert: ((points first at: 18) - (120 @ 200)) r < 0.001.
	self assert: (points first at: 21) = (points first at: 1).! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'bf 1/21/2013 16:00'!
testSVGPathEllipticalquatrant
	"self debug: #testSVGPathEllipticalquatrant"
	| d ps |
	d := 1 / 2 sqrt.
	ps := KSSVGPathReader new ellipticalquatrant: 1 @ 1 to: 2 @ 2.
	self assert: (ps first - (1 @ 1)) r < 0.001.
	self assert: (ps third - (1 @ 2 + (d @ d negated))) r < 0.001.
	self assert: (ps sixth - (2 @ 2)) r < 0.001.

	ps := KSSVGPathReader new ellipticalquatrant: 1 @ 1 to: 0 @ 2.
	self assert: (ps first - (1 @ 1)) r < 0.001.
	self assert: (ps third - (0 @ 1 + (d @ d))) r < 0.001.
	self assert: (ps sixth - (0 @ 2)) r < 0.001.

	ps := KSSVGPathReader new ellipticalquatrant: 1 @ 1 to: 0 @ 0.
	self assert: (ps first - (1 @ 1)) r < 0.001.
	self assert: (ps third - (1 @ 0 + (d negated @ d))) r < 0.001.
	self assert: (ps sixth - (0 @ 0)) r < 0.001.

	ps := KSSVGPathReader new ellipticalquatrant: 1 @ 1 to: 2 @ 0.
	self assert: (ps first - (1 @ 1)) r < 0.001.
	self assert: (ps third - (2 @ 1 + (d negated @ d negated))) r < 0.001.
	self assert: (ps sixth - (2 @ 0)) r < 0.001.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'bf 1/21/2013 16:01'!
testSVGPathU
	"self debug: #testSVGPathU"
	"KSSVGPathReader drawD: 'U 100 100 100 100 0 270 Z'"
	| points |
	points := KSSVGPathReader new readPath: 'U 100 100 100 100 0 270 Z'.
	self assert: points first first = (200 @ 100).
	self assert: ((points first at: 6) - (100 @ 200)) r < 0.000001.
	self assert: ((points first at: 12) - (0 @ 100)) r < 0.000001.
	self assert: ((points first at: 18) - (100 @ 0)) r < 0.000001.
	self assert: points first last = (200 @ 100).

	points := KSSVGPathReader new readPath: 'U 100 100 100 100 0 360 Z'.
	self assert: points first first = (200 @ 100).
	self assert: ((points first at: 6) - (100 @ 200)) r < 0.000001.
	self assert: ((points first at: 12) - (0 @ 100)) r < 0.000001.
	self assert: ((points first at: 18) - (100 @ 0)) r < 0.000001.
	self assert: points first last = (200 @ 100).! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'bf 1/21/2013 16:01'!
testSVGPathW
	"self debug: #testSVGPathW"
	"See KSSVGPathReader >> clockwisearcto:corner:from:to:"
	"KSSVGPathReader drawD: 'W 40 40 200 200 200 120 120 200 Z'"
	| points |
	points := KSSVGPathReader new readPath: 'W 40 40 200 200 200 120 120 200 Z'.
	self assert: ((points first at: 1) - (200 @ 120)) r < 0.001.
	self assert: ((points first at: 6) - (120 @ 200)) r < 0.001.
	self assert: ((points first at: 9) - (200 @ 120)) r < 0.001.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 3/24/2011 09:58'!
testStroke
	"self debug: #testStroke"
	| style1 style2 style3 |

	style1 := {#'draw:stroke' -> 'solid'.
		#'svg:stroke-color' -> '#ff0000'.
		#'svg:stroke-width' -> '3'} as: KSODFStyle.

	self assert: style1 borderWidth = 3.
	self assert: style1 borderColor = Color red.

	style2 := {#'draw:stroke' -> 'none'.
		#'svg:stroke-color' -> '#ff0000'.
		#'svg:stroke-width' -> '3'} as: KSODFStyle.

	self assert: style2 borderWidth = nil.
	self assert: style2 borderColor = nil.

	style3 := {#'draw:stroke' -> 'solid'.
		#'svg:stroke-color' -> '#ff0000'.
		#'svg:stroke-width' -> '0'} as: KSODFStyle.

	self assert: style3 borderWidth = 1.
	self assert: style3 borderColor = Color red.! !

!KSODFReaderTest methodsFor: 'testing' stamp: 'tak 4/22/2011 13:57'!
testStyle
	"self debug: #testStyle"
	| parent child child2 |
	parent := { #key1 -> 'parent1'.
		#key2 -> 'parent2' } as: KSODFStyle.
	child := ({ #key1 -> 'child1' } as: KSODFStyle) withParent: parent.
	child2 := child withParent: ({ #key3 -> 'grandParent' } as: KSODFStyle).
	self assert: (child at: #key1) = 'child1'.
	self assert: (child at: #key2) = 'parent2'.
	self assert: (child2 at: #key1) = 'child1'.
	self assert: (child2 at: #key2) = 'parent2'.
	self assert: (child2 at: #key3) = 'grandParent'.! !

!KSODFReaderTest methodsFor: 'testing-formula' stamp: 'tak 5/23/2011 16:16'!
testFormulaEnhancedGeometry
	"self debug: #testFormulaEnhancedGeometry"
	| xml interpreter |
	xml := '<draw:enhanced-geometry
	  svg:viewBox="0 0 1000 500"
	  draw:modifiers="0 10">
	 <draw:equation draw:name="f0" draw:formula="($0 + right) / 2"/>
	 <draw:equation draw:name="f1" draw:formula="($1 + bottom) / 2"/>
	 <draw:equation draw:name="f2" draw:formula="2*(bottom - top) / 3"/>
	</draw:enhanced-geometry>' asXml elements first.
	interpreter := KSODFFormulaInterpreter newFrom: xml style: nil.

	self assert: interpreter width = 1000.
	self assert: (interpreter eval: #(f f0)) = 500.
	self assert: (interpreter eval: #(f f1)) = 255.
	self assert: (interpreter eval: #(f f2)) = 333.3333333333333.
	self assert: (interpreter eval: #(m 0)) = 0.
	self assert: (interpreter eval: #(m 1)) = 10.

	self assert: (interpreter evalPath: 'M 0 1000 L $0 $1 1000 1000 Z N M 0 1000 L ?f0 ?f1 F N') =
													'M 0 1000 L 0 10 1000 1000 Z N M 0 1000 L 500.0 255.0 F N'.! !

!KSODFReaderTest methodsFor: 'testing-formula' stamp: 'tak 4/7/2011 10:39'!
testFormulaEquations
	"self debug: #testFormulaEquations"
	| xml formulas |
	xml := '<draw:enhanced-geometry>
	 <draw:equation draw:name="f0" draw:formula="($0 + right) / 2"/>
	 <draw:equation draw:name="f1" draw:formula="($1 + bottom) / 2"/>
	 <draw:equation draw:name="f2" draw:formula="2*(bottom - top) / 3"/>
	</draw:enhanced-geometry>' asXml elements first.
	formulas := KSODFFormulaInterpreter renderDrawEquations: xml.
	self assert: (formulas at: #f0) = #(/ (+ (m 0) right) 2).
	self assert: (formulas at: #f1) = #(/ (+ (m 1) bottom) 2).
	self assert: (formulas at: #f2) = #(/ (* 2 (- bottom top)) 3).! !

!KSODFReaderTest methodsFor: 'testing-formula' stamp: 'tak 5/12/2011 16:20'!
testFormulaInterpreter
	"self debug: #testFormulaInterpreter"
	| interpreter modifiers functions viewBox style |
	viewBox := 100 @ 200 corner: 200 @ 400.
	style := { #draw:stroke -> 'solid' } as: KSODFStyle.
	modifiers := #(10 20 30).
	functions := { #func -> #(+ 3 4) } as: KSODFStyle.
	interpreter := KSODFFormulaInterpreter modifiers: modifiers functions: functions viewBox: viewBox stretchpoint: 50 @ 60 style: style.
	self assert: (interpreter eval: 7) = 7.
	self assert: (interpreter eval: #(negated 7)) = -7.
	self assert: (interpreter eval: #(+ 3 4)) = 7.

	self assert: (interpreter eval: #pi) = Float pi.
	self assert: (interpreter eval: #left) = 100.
	self assert: (interpreter eval: #top) = 200.
	self assert: (interpreter eval: #right) = 200.
	self assert: (interpreter eval: #bottom) = 400.
	self assert: (interpreter eval: #xstretch) = 50.
	self assert: (interpreter eval: #ystretch) = 60.
	self assert: (interpreter eval: #hasstroke) = 1.
	self assert: (interpreter eval: #hasfill) = 0.
	self assert: (interpreter eval: #width) = 100.
	self assert: (interpreter eval: #height) = 200.
	self assert: (interpreter eval: #logwidth) = 10000.
	self assert: (interpreter eval: #logheight) = 20000.

	self assert: (interpreter eval: #(abs (negated 7))) = 7.
	self assert: (interpreter eval: #(sqrt 9)) = 3.
	self assert: (interpreter eval: #(sin (/ pi 2))) = 1.
	self assert: (interpreter eval: #(cos 0)) = 1.
	self assert: (interpreter eval: #(tan (/ pi 4))) - 1 < 0.001.
	self assert: (interpreter eval: #(atan (tan 1))) = 1.
	self assert: (interpreter eval: #(atan2 (sqrt 3) 1)) - (Float pi / 3) < 0.001.

	self assert: (interpreter eval: #(min 1 2)) = 1.
	self assert: (interpreter eval: #(max 1 2)) = 2.
	self assert: (interpreter eval: #(if 2 2 3)) = 2.
	self assert: (interpreter eval: #(if 0 2 3)) = 3.

	self assert: (interpreter eval: #(m 2)) = 30.
	self assert: (interpreter eval: #(f func)) = 7.! !

!KSODFReaderTest methodsFor: 'testing-formula' stamp: 'tak 4/7/2011 10:26'!
testFormulaParser
	"self debug: #testFormulaParser"
	self assert: (KSODFFormulaParser matchAll: '234' with: #number) == 234.
	self assert: (KSODFFormulaParser matchAll: 'logheight' with: #identifier) == #logheight.
	self assert: (KSODFFormulaParser matchAll: 'atan' with: #unaryFunction) == #atan.
	self assert: (KSODFFormulaParser matchAll: 'max' with: #binaryFunction) == #max.
	self assert: (KSODFFormulaParser matchAll: 'atan2' with: #binaryFunction) == #atan2.
	self assert: (KSODFFormulaParser matchAll: 'if' with: #ternaryFunction) == #if.
	self assert: (KSODFFormulaParser matchAll: '?aA0 ' with: #functionReference) = #(f aA0).
	self assert: (KSODFFormulaParser matchAll: '$999 ' with: #modifierReference) = #(m 999).

	self assert: (KSODFFormulaParser matchAll: '234' with: #basicExpression) = 234.
	self assert: (KSODFFormulaParser matchAll: '?aA0 ' with: #basicExpression) = #(f aA0).
	self assert: (KSODFFormulaParser matchAll: '$999 ' with: #basicExpression) = #(m 999).
	self assert: (KSODFFormulaParser matchAll: 'logheight' with: #basicExpression) = #logheight.
	self assert: (KSODFFormulaParser matchAll: 'atan(1)' with: #basicExpression) = #(atan 1).
	self assert: (KSODFFormulaParser matchAll: 'atan2(1,2)' with: #basicExpression) = #(atan2 1 2).
	self assert: (KSODFFormulaParser matchAll: 'min(1,2)' with: #basicExpression) = #(min 1 2).
	self assert: (KSODFFormulaParser matchAll: 'if(1,2,3)' with: #basicExpression) = #(if 1 2 3).
	self assert: (KSODFFormulaParser matchAll: '(7)' with: #basicExpression) = 7.
	self assert: (KSODFFormulaParser matchAll: '(3+4)' with: #basicExpression) = #(+ 3 4).
	self assert: (KSODFFormulaParser matchAll: '(3+4+5)' with: #basicExpression) = #(+ (+ 3 4) 5).
	self assert: (KSODFFormulaParser matchAll: '(3*4*5)' with: #basicExpression) = #(* (* 3 4) 5).
	self assert: (KSODFFormulaParser matchAll: '(3+4*5)' with: #basicExpression) = #(+3 (* 4 5)).
	self assert: (KSODFFormulaParser matchAll: '7' with: #unaryExpression) = 7.
	self assert: (KSODFFormulaParser matchAll: '-7' with: #unaryExpression) = #(negated 7).
	self assert: (KSODFFormulaParser matchAll: '-(1+2*sin(3))' with: #unaryExpression) = #(negated (+ 1 (* 2 (sin 3)))).
	self assert: (KSODFFormulaParser parse: '7') = 7.
	self assert: (KSODFFormulaParser parse: '-7') = #(negated 7).
	self assert: (KSODFFormulaParser parse: '3 + 4') = #(+ 3 4).
	self assert: (KSODFFormulaParser parse: '( 7 )') = 7.
	self assert: (KSODFFormulaParser parse: 'min ( 1 , 2 ) ') = #(min 1 2).
	self assert: (KSODFFormulaParser parse: '?aA0 ') = #(f aA0).
	self assert: (KSODFFormulaParser parse: '$999 ') = #(m 999).! !

!KSODFReaderTest methodsFor: 'testing-formula' stamp: 'tak 4/7/2011 14:13'!
testFormulaPathParser
	"self debug: #testFormulaPathParser"
	self assert: (KSODFFormulaParser matchAll: '1 23' with: #path) asArray = {$1. $ . $2. $3}.
	self assert: (KSODFFormulaParser matchAll: '1 $2 3 ' with: #path) asArray = {$1. $ . #(m 2). $3. $ }.
	self assert: (KSODFFormulaParser matchAll: '1 ?func 3' with: #path) asArray = {$1. $ . #(f func). $3}.! !

!KSODFReaderTest methodsFor: 'testing-formula' stamp: 'tak 5/13/2011 15:20'!
testFormulaTextAreas
	"self debug: #testFormulaTextAreas"
	| functions interpreter modifiers |
	modifiers := #(10 20 30 ).
	functions := {#func -> #(#+ 3 4 )} as: KSODFStyle.
	interpreter := KSODFFormulaInterpreter
				modifiers: modifiers
				functions: functions
				viewBox: nil
				stretchpoint: 50 @ 60
				style: nil.
	self assert: (interpreter evalTextAreas: '$0 $1 $2 ?func')
			= (10 @ 20 corner: 30 @ 7)! !

!KSODFReaderTest methodsFor: 'testing-geometry' stamp: 'tak 3/24/2011 13:53'!
testDrawTransform
	"self debug: #testDrawTransform"
	| frame trans1 trans2 trans3 trans4 trans5 trans6 |
	frame := KSODFDocument new.
	self assert: (frame convertTransform: '')
			= MatrixTransform2x3 identity.
	trans1 := frame convertTransform: 'translate (200px 100px)'.
	self assert: (trans1 localPointToGlobal: 100 @ 0)
			= (300 @ 100).
	trans2 := frame convertTransform: 'rotate (1.570796326794897)'.
	self assert: ((trans2 localPointToGlobal: 100 @ 0) - (0 @ -100)) r < 0.001.
	trans3 := frame convertTransform: 'rotate (1.570796326794897) translate (200px 100px)'.
	self assert: (trans3 localPointToGlobal: 0 @ 0)
			= (200 @ 100).
	self assert: ((trans3 localPointToGlobal: 100 @ 0) - (200 @ 0)) r < 0.001.
	trans4 := frame convertTransform: 'matrix (1.0 0.0 0.0 1.0 0.0pt 0.0pt)'.
	self assert: (trans4 localPointToGlobal: 100 @ 200)
			= (100 @ 200).
	trans5 := frame convertTransform: 'matrix (1.0 0.0 0.0 1.0 200.0pt 100.0pt)'.
	self assert: (trans5 localPointToGlobal: 100 @ 200)
			= (300 @ 300).
	trans6 := frame convertTransform: 'matrix (0.0 1.0 -1.0 0.0 200.0pt 100.0pt)'.
	self assert: (trans6 localPointToGlobal: 100 @ 0)
			= (200 @ 0)! !

!KSODFReaderTest methodsFor: 'testing-geometry' stamp: 'bf 1/21/2013 15:56'!
testDrawTransformOffset
	"self debug: #testDrawTransformOffset"
	| src box |
	src :=
'<draw:path draw:transform="translate(200px 100px)" />' asXml elements first.
	box := KSBox new.
	KSODFDocument new renderDrawTransform: src offset: 20@10 on: box.
	self assert: box transformation offset = (220 @ 110).

	! !

!KSODFReaderTest methodsFor: 'testing-geometry' stamp: 'tak 5/12/2011 10:56'!
testFoClip
	"self debug: #testFoClip"
	self assert: (KSODFDocument new readFoClip: 'rect(10px, 20px, 30px, 40px)')
			= (40 @ 10 corner: 20 @ 30).
	self assert: (KSODFDocument new readFoClip: 'rect(1in, 2in, 3in, 4in)')
			= (384@96 corner: 192@288).
	self assert: ((100 @ 200 corner: 300 @ 400)
			insetBy: (KSODFDocument new readFoClip: 'rect(10px, 20px, 30px, 40px)'))
			= (140 @ 210 corner: 280 @ 370)! !

!KSODFReaderTest methodsFor: 'testing-geometry' stamp: 'tak 6/14/2011 13:13'!
testUnit
	"self debug: #testUnit"
	self assert: (KSODFDocument pixelsFromString: '') = 0.
	self assert: (KSODFDocument pixelsFromString: '100px') = 100.
	self assert: (KSODFDocument pixelsFromString: '100pt') = 100.
	self assert: (KSODFDocument pixelsFromString: '100pc') = 1200.
	self assert: (KSODFDocument pixelsFromString: '100mm') = 283.
	self assert: (KSODFDocument pixelsFromString: '100cm') = 2835.
	self assert: (KSODFDocument pixelsFromString: '100in') = 7200.
	self assert: (KSODFDocument pixelsFromString: '50%') = 0.5.
	"72 dpi"
	self assert: (KSODFDocument pixelsFromString: '' dpi: 72) = 0.
	self assert: (KSODFDocument pixelsFromString: '100px' dpi: 72) = 100.
	self assert: (KSODFDocument pixelsFromString: '100pt' dpi: 72) = 100.
	self assert: (KSODFDocument pixelsFromString: '100pc' dpi: 72) = 1200.
	self assert: (KSODFDocument pixelsFromString: '100mm' dpi: 72) = 283.
	self assert: (KSODFDocument pixelsFromString: '100cm' dpi: 72) = 2835.
	self assert: (KSODFDocument pixelsFromString: '100in' dpi: 72) = 7200.
	self assert: (KSODFDocument pixelsFromString: '50%' dpi: 72) = 0.5.
	"96 dpi"
	self assert: (KSODFDocument pixelsFromString: '' dpi: 96) = 0.
	self assert: (KSODFDocument pixelsFromString: '100px' dpi: 96) = 100.
	self assert: (KSODFDocument pixelsFromString: '100pt' dpi: 96) =? 133.33.
	self assert: (KSODFDocument pixelsFromString: '100pc' dpi: 96) = 1600.
	self assert: (KSODFDocument pixelsFromString: '100mm' dpi: 96) = 378.
	self assert: (KSODFDocument pixelsFromString: '100cm' dpi: 96) = 3780.
	self assert: (KSODFDocument pixelsFromString: '100in' dpi: 96) = 9600.
	self assert: (KSODFDocument pixelsFromString: '50%' dpi: 96) = 0.5.! !
