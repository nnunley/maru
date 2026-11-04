# Stubs are written once, as intents (stub.l); this lowers them to arm64's forms, by matching the list of intents as a
# tree.  Registers are s0..s4 (scratch), a0 and a1 (arguments) and result, named by abi.spec.
<stub-arm64> : <source-parser> ()
program	= intent*:l !. -> l ;
reg	= .:r -> (stub-reg 'arm64 r) ;
intent	= `( 'constant reg:r .:v )	-> (arm64-constant r v)
	| `( 'load reg:r reg:base .:at )	-> `((LDR ,r (off ,base ,at)))
	| `( 'store reg:r reg:base .:at )	-> `((STR ,r (off ,base ,at)))
	| `( 'push2 reg:a reg:b )	-> `((STP ,a ,b (pre SP -16)))
	| `( 'pop2 reg:a reg:b )	-> `((LDP ,a ,b (post SP 16)))
	| `( 'sp-to reg:r )		-> `((ADD ,r SP 0))
	| `( 'sp-from reg:r )		-> `((ADD SP ,r 0))
	| `( 'call reg:r )		-> `((BLR ,r))
	| `( 'result-from-arg )		-> ()
	| `( 'save )			-> (arm64-pairs 'STP 'pre -16 (abi 'arm64 'saved) (abi 'arm64 'floats))
	| `( 'restore )			-> (reverse-pairs (arm64-pairs 'LDP 'post 16 (abi 'arm64 'saved) (abi 'arm64 'floats)))
	| `( 'return )			-> '((RET))
	;
