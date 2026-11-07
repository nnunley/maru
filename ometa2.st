"ometa2.st -- OMeta2, the class KSWorld's grammar classes inherit, in test-pepsi.l's form: matching runs on Maru's PEG (ometa2.l)"

OMeta2 : Object ()

OMeta2 class match: anObject with: aRule { (ometa2-match (<ks-class>-name self) aRule anObject ()) }
OMeta2 class match: anObject with: aRule withArgs: args { (ometa2-match (<ks-class>-name self) aRule anObject args) }
