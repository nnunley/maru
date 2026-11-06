# Intents (native-gen.k) to arm64's forms, matched as a tree, as stub-arm64.g lowers a stub's.  Registers s0, s1 … are
# abi.spec's scratch, an argument position its args, and the result its result; slots are offsets from SP.  A branch's
# target is a (label L) operand and (at L) marks where L is; native-link.l patches them.  A conditional branch is a short
# branch over B, so its reach is B's.
<native-arm64> : <source-parser> ()
program	= intent*:l !. -> l ;
reg	= .:r -> (stub-reg 'arm64 r) ;
intent	= `( 'enter .:n )		-> `((STP X29 X30 (pre SP -16)) (ADD X29 SP 0) ,@(native-arm64-sp 'SUB n))
	| `( 'leave .:n )		-> `(,@(native-arm64-sp 'ADD n) (LDP X29 X30 (post SP 16)))
	| `( 'return )			-> '((RET))
	| `( 'arg .:i .:slot .:size )	-> (list (native-arm64-store size (native-arm64-arg i) slot))
	| `( 'load .:size .:slot reg:r )	-> (list (native-arm64-load size r slot))
	| `( 'store .:size .:slot reg:r )	-> (list (native-arm64-store size r slot))
	| `( 'constant reg:r .:v )	-> (arm64-constant r v)
	| `( 'result-from reg:r )	-> `((MOV ,(stub-reg 'arm64 'result) ,r))
	| `( 'op 'add reg:d reg:a reg:b )	-> `((ADD ,d ,a ,b))
	| `( 'op 'sub reg:d reg:a reg:b )	-> `((SUB ,d ,a ,b))
	| `( 'compare .:c reg:d reg:a reg:b )	-> `((CMP ,a ,b) (CSET ,d ,(native-arm64-cond c)))
	| `( 'label .:l )		-> `((at ,l))
	| `( 'branch .:l )		-> `((B (label ,l)))
	| `( 'branch-if reg:r .:l )	-> (native-arm64-branch 'CBZ r l)
	| `( 'branch-unless reg:r .:l )	-> (native-arm64-branch 'CBNZ r l)
	;
