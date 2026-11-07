"ometa2.st -- OMeta2, the class KSWorld's grammar classes inherit, in test-pepsi.l's form: matching runs on Maru's PEG (ometa2.l)"

OMeta2 : Object ()

OMeta2 class match: anObject with: aRule { (ometa2-match (<ks-class>-name self) aRule anObject ()) }
OMeta2 class match: anObject with: aRule withArgs: args { (ometa2-match (<ks-class>-name self) aRule anObject args) }

OMeta2 apply: aRule withArgs: args { (ks-send self (ks-selector-of aRule) args () self) }
OMeta2 apply: aRule                { (ks-send self (ks-selector-of aRule) () () self) }

"OMeta2Fail signal fails the alternative whose action signals it"
OMeta2Fail : Object ()
OMeta2Fail class signal            { (ometa2-fail) }
