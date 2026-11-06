TestCase subclass: #KSBoxTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-Tests'!

!KSBoxTest methodsFor: 'as yet unclassified' stamp: 'tk 2/4/2013 12:36'!
testTextCreation
	"Test the KSWorldState fromText: method
	(KSBoxTest  new setTestSelector: #testTextCreation) runCase
	"
	| txt answ attrs boxes | 
	txt :=  (Text string: 'pppbbbiiibibi' runs: (RunArray runs: #(3 3 3 4 ) values: ((Array new: 4) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 0; yourself); yourself); at: 2 put: ((Array new: 2) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 0; yourself); at: 2 put: (TextEmphasis basicNew instVarAt: 1 put: 1; instVarAt: 2 put: true; yourself); yourself); at: 3 put: ((Array new: 2) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 0; yourself); at: 2 put: (TextEmphasis basicNew instVarAt: 1 put: 2; instVarAt: 2 put: true; yourself); yourself); at: 4 put: ((Array new: 3) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 0; yourself); at: 2 put: (TextEmphasis basicNew instVarAt: 1 put: 1; instVarAt: 2 put: true; yourself); at: 3 put: (TextEmphasis basicNew instVarAt: 1 put: 2; instVarAt: 2 put: true; yourself); yourself); yourself))).
	txt := txt, 'Red'.
"	txt addAttribute: TextEmphasis bold from: 4 to: 6.
	txt addAttribute: TextEmphasis bold from: 10 to: 13.
	txt addAttribute: TextEmphasis italic from: 7 to: 13.
"
	txt addAttribute: (TextColor color: Color red) from: 14 to: 16.
	boxes := KSWorldState new fromText: txt.
	attrs := #(
		isNormal isBold isItalic
		isNormal isBold isItalic
		isNormal isBold isItalic
		isNormal isBold isItalic isBold ).
	answ := {
		true. false. false.
		false. true. false.
		false. false. true. 
		false. true. true. true.
		}.
	1 to: 13 do: [:ii |
		self assert: (((boxes at: ii) perform: (attrs at: ii)) = (answ at: ii))].
	
	self assert: ((boxes at: 14) fill = (Color red)).! !
