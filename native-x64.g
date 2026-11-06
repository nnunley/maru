# Intents (native-gen.k) to x86-64's forms, matched as a tree, as stub-x64.g lowers a stub's; native-x64.l's actions
# follow System V.  Registers s0, s1 … are abi.spec's scratch; slots are offsets from RSP.  A branch's target is a
# (label L) operand, a label's address a RIP-relative LEA whose displacement is one, and (at L) marks where L is;
# native-link.l patches them.
<native-x64> : <source-parser> ()
program	= intent*:l !. -> l ;
reg	= .:r -> (stub-reg 'x64 r) ;
intent	= `( 'enter .:n .:o )		-> (native-x64-enter n o)
	| `( 'leave .:n )		-> '((MOV RSP RBP) (POP RBP))
	| `( 'return )			-> '((RET))
	| `( 'params .:ps )		-> (native-x64-params ps)
	| `( 'call .:slot .:nfixed .:args .:ret )	-> (native-x64-call slot nfixed args ret)
	| `( 'result .:size .:slot .:kind )	-> (native-x64-result size slot kind)
	| `( 'copy .:size .:from .:to )	-> (native-x64-copy size from to)
	| `( 'function-address reg:r .:name )	-> `((LEA ,r (m (label ,(native-function-label name)) RIP () 1)))
	| `( 'load .:size .:slot reg:r )	-> (native-x64-load size r 'RSP slot)
	| `( 'store .:size .:slot reg:r )	-> (native-x64-store size r 'RSP slot)
	| `( 'load-at .:size reg:b reg:r )	-> (native-x64-load size r b 0)
	| `( 'store-at .:size reg:b reg:r )	-> (native-x64-store size r b 0)
	| `( 'address .:slot reg:r )	-> `((LEA ,r (m ,slot RSP () 1)))
	| `( 'constant reg:r .:v )	-> `((MOV ,r ,v))
	| `( 'op .:k reg:d reg:a reg:b )	-> (native-x64-op k d a b)
	| `( 'fop .:k .:w reg:d reg:a reg:b )	-> (native-x64-fop k w d a b)
	| `( 'fcompare .:c .:w reg:d reg:a reg:b )	-> (native-x64-fcompare c w d a b)
	| `( 'convert .:from .:to reg:d reg:s )	-> (native-x64-convert from to d s)
	| `( 'compare .:c reg:d reg:a reg:b )	-> (native-x64-compare c d a b)
	| `( 'label .:l )		-> `((at ,l))
	| `( 'branch .:l )		-> `((JMP (label ,l)))
	| `( 'branch-to reg:r )	-> `((JMP ,r))
	| `( 'label-address reg:r .:l )	-> `((LEA ,r (m (label ,l) RIP () 1)))
	| `( 'branch-if reg:r .:l )	-> (native-x64-branch 'JNE r l)
	| `( 'branch-unless reg:r .:l )	-> (native-x64-branch 'JE r l)
	;
