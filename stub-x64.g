# Stubs are written once, as intents (stub.l); this lowers them to x86-64's forms, by matching the list of intents as a
# tree.  Registers are s0..s4 (scratch), a0 and a1 (arguments) and result, named by abi.spec.
<stub-x64> : <source-parser> ()
program	= intent*:l !. -> l ;
reg	= .:r -> (stub-reg 'x64 r) ;
intent	= `( 'constant reg:r .:v )	-> `((MOV ,r ,v))
	| `( 'load reg:r reg:base .:at )	-> `((MOV ,r (m64 ,at ,base () 1)))
	| `( 'store reg:r reg:base .:at )	-> `((MOV (m64 ,at ,base () 1) ,r))
	| `( 'push2 reg:a reg:b )	-> `((PUSH ,b) (PUSH ,a))
	| `( 'pop2 reg:a reg:b )	-> `((POP ,a) (POP ,b))
	| `( 'sp-to reg:r )		-> `((MOV ,r RSP))
	| `( 'sp-from reg:r )		-> `((MOV RSP ,r))
	| `( 'call reg:r )		-> `((CALL ,r))
	| `( 'result-from-arg )		-> '((MOV RAX RDI))
	| `( 'save )			-> (x64-save)
	| `( 'restore )			-> (x64-restore)
	| `( 'return )			-> '((RET))
	;
