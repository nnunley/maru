# Intents (native-gen.k) to arm64's forms, matched as a tree, as stub-arm64.g lowers a stub's.  Registers s0, s1 … are
# abi.spec's scratch, an argument position its args, and the result its result; slots are offsets from SP.  A branch's
# target is a (label L) operand and (at L) marks where L is; native-link.l patches them.  A conditional branch is a short
# branch over B, so its reach is B's.  An instruction a rule always means is an arm64-site (asm-arm64.l): its rows are
# chosen as the grammar loads, and it emits its bytes.
<native-arm64> : <source-parser> ()
program	= intent*:l !. -> l ;
reg	= .:r -> (stub-reg 'arm64 r) ;
intent	= `( 'enter .:n .:o )		-> (native-arm64-enter n o)
	| `( 'leave .:n )		-> '((ADD SP X29 0) (LDP X29 X30 (post SP 16)))
	| `( 'return )			-> '((RET))
	| `( 'params .:ps )		-> (native-arm64-params ps)
	| `( 'call .:slot .:nfixed .:args .:ret )	-> (native-arm64-call slot nfixed args ret)
	| `( 'result .:size .:slot .:kind )	-> (native-arm64-result size slot kind)
	| `( 'copy .:size .:from .:to )	-> (native-arm64-copy size from to)
	| `( 'function-address reg:r .:name )	-> `((ADR ,r (label ,(native-function-label name))))
	| `( 'load .:size .:slot reg:r )	-> (native-arm64-load size r 'SP slot)
	| `( 'store .:size .:slot reg:r )	-> (native-arm64-store size r 'SP slot)
	| `( 'load-at .:size reg:b reg:r )	-> (native-arm64-load size r b 0)
	| `( 'store-at .:size reg:b reg:r )	-> (native-arm64-store size r b 0)
	| `( 'address .:slot reg:r )	-> (native-arm64-address slot r)
	| `( 'constant reg:r .:v )	-> (arm64-constant r v)
	| `( 'op 'add reg:d reg:a reg:b )	-> (list (arm64-site ADD (x d) (x a) (x b)))
	| `( 'op 'sub reg:d reg:a reg:b )	-> (list (arm64-site SUB (x d) (x a) (x b)))
	| `( 'op 'mul reg:d reg:a reg:b )	-> (list (arm64-site MUL (x d) (x a) (x b)))
	| `( 'op 'div reg:d reg:a reg:b )	-> (list (arm64-site SDIV (x d) (x a) (x b)))
	| `( 'op 'mod reg:d reg:a reg:b )	-> (list (arm64-site SDIV X17 (x a) (x b)) (arm64-site MSUB (x d) X17 (x b) (x a)))
	| `( 'op 'and reg:d reg:a reg:b )	-> (list (arm64-site AND (x d) (x a) (x b)))
	| `( 'op 'or reg:d reg:a reg:b )	-> (list (arm64-site ORR (x d) (x a) (x b)))
	| `( 'op 'xor reg:d reg:a reg:b )	-> (list (arm64-site EOR (x d) (x a) (x b)))
	| `( 'op 'shl reg:d reg:a reg:b )	-> (list (arm64-site LSLV (x d) (x a) (x b)))
	| `( 'op 'shr reg:d reg:a reg:b )	-> (list (arm64-site ASRV (x d) (x a) (x b)))
	| `( 'op 'com reg:d reg:a .:_ )	-> (list (arm64-site MVN (x d) (x a)))
	| `( 'fop .:k .:w reg:d reg:a reg:b )	-> (native-arm64-fop k w d a b)
	| `( 'fcompare .:c .:w reg:d reg:a reg:b )	-> (native-arm64-fcompare c w d a b)
	| `( 'convert .:from .:to reg:d reg:s )	-> (native-arm64-convert from to d s)
	| `( 'compare .:c reg:d reg:a reg:b )	-> (list (arm64-site CMP (x a) (x b)) (arm64-site CSET (x d) (c (native-arm64-cond c))))
	| `( 'label .:l )		-> `((at ,l))
	| `( 'branch .:l )		-> `((B (label ,l)))
	| `( 'branch-to reg:r )	-> `((BR ,r))
	| `( 'label-address reg:r .:l )	-> `((ADR ,r (label ,l)))
	| `( 'branch-if reg:r .:l )	-> (native-arm64-branch 'CBZ r l)
	| `( 'branch-unless reg:r .:l )	-> (native-arm64-branch 'CBNZ r l)
	;
