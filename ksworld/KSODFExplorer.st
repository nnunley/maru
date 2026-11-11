ObjectExplorer subclass: #KSODFExplorer
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'KSObjects-ODFReader'!

!KSODFExplorer commentStamp: 'bf 1/9/2013 10:41' prior: 0!
KSODFExplorer shows an ODF document file in tree structure.
It makes useful information like style name and paragraph contents visible, and hides unnecessary like xmlns:.

KSODFExplorer open: 'Ted First Page.odp'.!

!KSODFExplorer methodsFor: 'accessing' stamp: 'tak 10/6/2011 15:34'!
getList
	^ Array with: (KSODFExplorerWrapper item: rootObject document: rootObject)! !

!KSODFExplorer class methodsFor: 'instance creation' stamp: 'tak 3/15/2011 10:42'!
open: fileName 
	"KSODFExplorer open: 'vanguardMini.odp'"
	^ self new openExplorerFor: (KSODFDocument readFromFile: fileName)! !
