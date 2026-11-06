# Intents (native-gen.k) to arm64's forms, matched as a tree, as stub-arm64.g lowers a stub's.  Registers s0, s1 … are
# abi.spec's scratch, an argument position its args, and the result its result; slots are offsets from SP.
<native-arm64> : <source-parser> ()
program	= intent*:l !. -> l ;
reg	= .:r -> (stub-reg 'arm64 r) ;
intent	= `( 'enter .:n )		-> `((STP X29 X30 (pre SP -16)) (ADD X29 SP 0) ,@(native-arm64-sp 'SUB n))
	| `( 'leave .:n )		-> `(,@(native-arm64-sp 'ADD n) (LDP X29 X30 (post SP 16)))
	| `( 'return )			-> '((RET))
	| `( 'arg .:i .:slot )		-> `((STR ,(native-arm64-arg i) (off SP ,slot)))
	| `( 'load .:slot reg:r )	-> `((LDR ,r (off SP ,slot)))
	| `( 'store .:slot reg:r )	-> `((STR ,r (off SP ,slot)))
	| `( 'constant reg:r .:v )	-> (arm64-constant r v)
	| `( 'result-from reg:r )	-> `((MOV ,(stub-reg 'arm64 'result) ,r))
	| `( 'op 'add reg:d reg:a reg:b )	-> `((ADD ,d ,a ,b))
	| `( 'op 'sub reg:d reg:a reg:b )	-> `((SUB ,d ,a ,b))
	;
