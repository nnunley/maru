main
	.text
	.globl _main
_main:
	# frame 32 32 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__1__core_2Feval_2El__1558:
	movl $0,%eax
	movl %eax,32(%ebp)
	.data
___L__2__core_2Feval_2El__1558:
	.asciz "r"
	.text
	movl ___L__2__core_2Feval_2El__1558,%eax
	movl %eax,36(%ebp)
	movl _fdopen_24stub,%eax
	movl 32(%ebp),%eax
	movl %eax,0(%ebp)
	movl 36(%ebp),%eax
	movl %eax,4(%ebp)
	call %eax
	movl %eax,_stdin
___L__3__core_2Feval_2El__1559:
	movl $1,%eax
	movl %eax,36(%ebp)
	.data
___L__4__core_2Feval_2El__1559:
	.asciz "a"
	.text
	movl ___L__4__core_2Feval_2El__1559,%eax
	movl %eax,32(%ebp)
	movl _fdopen_24stub,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	movl 32(%ebp),%eax
	movl %eax,4(%ebp)
	call %eax
	movl %eax,_stdout
___L__5__core_2Feval_2El__1560:
	movl $2,%eax
	movl %eax,32(%ebp)
	.data
___L__6__core_2Feval_2El__1560:
	.asciz "a"
	.text
	movl ___L__6__core_2Feval_2El__1560,%eax
	movl %eax,36(%ebp)
	movl _fdopen_24stub,%eax
	movl 32(%ebp),%eax
	movl %eax,0(%ebp)
	movl 36(%ebp),%eax
	movl %eax,4(%ebp)
	call %eax
	movl %eax,_stderr
___L__7__core_2Feval_2El__1562:
	movl _gc__initialise,%eax
	call %eax
	movl $0,%eax
___L__8__core_2Feval_2El__1564:
	movl $0,%eax
	movl %eax,36(%ebp)
	movl _new_2D_3Carray_3E,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_symbols
	movl $_symbols,%eax
	movl %eax,36(%ebp)
	movl _gc__push__root,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
___L__9__core_2Feval_2El__1566:
	.data
___L__10__core_2Feval_2El__1566:
	.asciz "t"
	.text
	movl ___L__10__core_2Feval_2El__1566,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__t
___L__11__core_2Feval_2El__1567:
	.data
___L__12__core_2Feval_2El__1567:
	.asciz "."
	.text
	movl ___L__12__core_2Feval_2El__1567,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__dot
___L__13__core_2Feval_2El__1568:
	.data
___L__14__core_2Feval_2El__1568:
	.asciz "set"
	.text
	movl ___L__14__core_2Feval_2El__1568,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__set
___L__15__core_2Feval_2El__1569:
	.data
___L__16__core_2Feval_2El__1569:
	.asciz "define"
	.text
	movl ___L__16__core_2Feval_2El__1569,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__define
___L__17__core_2Feval_2El__1570:
	.data
___L__18__core_2Feval_2El__1570:
	.asciz "lambda"
	.text
	movl ___L__18__core_2Feval_2El__1570,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__lambda
___L__19__core_2Feval_2El__1571:
	.data
___L__20__core_2Feval_2El__1571:
	.asciz "let"
	.text
	movl ___L__20__core_2Feval_2El__1571,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__let
___L__21__core_2Feval_2El__1572:
	.data
___L__22__core_2Feval_2El__1572:
	.asciz "quote"
	.text
	movl ___L__22__core_2Feval_2El__1572,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__quote
___L__23__core_2Feval_2El__1573:
	.data
___L__24__core_2Feval_2El__1573:
	.asciz "quasiquote"
	.text
	movl ___L__24__core_2Feval_2El__1573,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__quasiquote
___L__25__core_2Feval_2El__1574:
	.data
___L__26__core_2Feval_2El__1574:
	.asciz "unquote"
	.text
	movl ___L__26__core_2Feval_2El__1574,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__unquote
___L__27__core_2Feval_2El__1575:
	.data
___L__28__core_2Feval_2El__1575:
	.asciz "unquote-splicing"
	.text
	movl ___L__28__core_2Feval_2El__1575,%eax
	movl %eax,36(%ebp)
	movl _intern,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,_s__unquote__splicing
___L__29__core_2Feval_2El__1577:
	movl $_globals,%eax
	movl %eax,36(%ebp)
	movl _gc__push__root,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
___L__30__core_2Feval_2El__1579:
	movl $0,%eax
	movl %eax,36(%ebp)
	movl $0,%eax
	movl %eax,32(%ebp)
	movl $0,%eax
	movl %eax,40(%ebp)
	movl _new_2D_3Cenv_3E,%eax
	movl 36(%ebp),%eax
	movl %eax,0(%ebp)
	movl 32(%ebp),%eax
	movl %eax,4(%ebp)
	movl 40(%ebp),%eax
	movl %eax,8(%ebp)
	call %eax
	movl %eax,_globals
___L__31__core_2Feval_2El__1580:
	movl _globals,%eax
	movl %eax,40(%ebp)
	.data
___L__32__core_2Feval_2El__1580:
	.asciz "*globals*"
	.text
	movl ___L__32__core_2Feval_2El__1580,%eax
	movl %eax,32(%ebp)
	movl _intern,%eax
	movl 32(%ebp),%eax
	movl %eax,0(%ebp)
	call %eax
	movl %eax,32(%ebp)
	movl _globals,%eax
	movl %eax,36(%ebp)
	movl _k__env__define,%eax
	movl 40(%ebp),%eax
	movl %eax,0(%ebp)
	movl 32(%ebp),%eax
	movl %eax,4(%ebp)
	movl 36(%ebp),%eax
	movl %eax,8(%ebp)
	call %eax
	movl %eax,_globals
___L__33__core_2Feval_2El__1582:
	movl _globals,%eax
	movl %eax,36(%ebp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%ebp)
	movl __3Cvariable_3E,%eax
	movl %eax,40(%ebp)
	movl 36(%ebp),%eax
	movl %eax,44(%ebp)
	movl __25typecheck,%eax
	movl 40(%ebp),%eax
	movl %eax,0(%ebp)
	movl 44(%ebp),%eax
	movl %eax,4(%ebp)
	call %eax

emit: illegal instruction: (OOP-AT 32)
[31;1merror: aborted[m
[32m[?7lboot.l:24   [0m (abort)
[?7h[32m[?7lcore/compiler/emit.l:70[0m (error "aborted")
[?7h[32m[?7lboot.l:707             [0m (apply default arguments)
[?7h[32m[?7lboot.l:706             [0m (Fixed<if> default (apply default arguments) (error "no method in " (oop-at (%typecheck <generic> self) 0) " corresponding to " arguments))
[?7h[32m[?7lboot.l:705             [0m (Fixed<let> ((default (oop-at (%typecheck <generic> self) 2))) (Fixed<if> default (apply default arguments) (error "no method in " (oop-at (%typecheck <generic> self) 0) " corresponding to " arguments)))
[?7h[32m[?7lboot.l:703             [0m (Fixed<if> (Fixed<and> method (not (array? method))) (apply method arguments) (Fixed<let> ((default (oop-at (%typecheck <generic> self) 2))) (Fixed<if> default (apply default arguments) (error "no method in " (oop-at (%typecheck <generic> self) 0) " corresponding to " arguments))))
[?7h[32m[?7lboot.l:698             [0m (Fixed<let> ((method (oop-at (%typecheck <generic> self) 1)) (arg arguments)) (Fixed<while> arg (Fixed<set> method (array-at method (type-of (car arg)))) (Fixed<set> arg (cdr arg))) (Fixed<if> (Fixed<and> method (not (array? method))) (apply method arguments) (Fixed<let> ((default (oop-at (%typecheck <generic> self) 2))) (Fixed<if> default (apply default arguments) (error "no method in " (oop-at (%typecheck <generic> self) 0) " corresponding to " arguments)))))
[?7h[32m[?7lcore/compiler/emit.l:784[0m (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i))
[?7h[32m[?7lcore/compiler/emit.l:784[0m (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))
[?7h[32m[?7lcore/compiler/emit.l:784[0m (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1))))
[?7h[32m[?7lcore/compiler/emit.l:774[0m (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8)))
[?7h[32m[?7lcore/compiler/emit.l:774[0m (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))
[?7h[32m[?7lcore/compiler/emit.l:774[0m (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8)))))
[?7h[32m[?7lcore/compiler/emit.l:766[0m (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT))))
[?7h[32m[?7lcore/compiler/emit.l:766[0m (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT)))))
[?7h[32m[?7lcore/compiler/emit.l:766[0m (Fixed<let> ((tnam (Fixed<if> main (LABEL name) (LABEL (temp-label-name))))) (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT))))))
[?7h[32m[?7lcore/compiler/emit.l:766[0m (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((tnam (Fixed<if> main (LABEL name) (LABEL (temp-label-name))))) (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT)))))))
[?7h[32m[?7lcore/compiler/emit.l:766[0m (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((tnam (Fixed<if> main (LABEL name) (LABEL (temp-label-name))))) (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT))))))))
[?7h[32m[?7lcore/compiler/emit.l:766[0m (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((tnam (Fixed<if> main (LABEL name) (LABEL (temp-label-name))))) (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT)))))))))
[?7h[32m[?7lcore/compiler/emit.l:766[0m (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((tnam (Fixed<if> main (LABEL name) (LABEL (temp-label-name))))) (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT))))))))))
[?7h[32m[?7lcore/compiler/emit.l:721[0m (Fixed<if> (Fixed<and> (defined? (Fixed<quote> *c-backend-active*)) *c-backend-active*) (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((params (cadr defn))) (Fixed<let> ((body (cddr defn))) (set-oop-at (%typecheck <c-generator> *c-gen*) 5 name) (print "static oop " (mangle-label name) "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<if> first (Fixed<set> first ()) (print ", ")) (print "oop " (mangle-label (oop-at (%typecheck <variable> param) 0)))) (Fixed<set> _list_ (cdr _list_))))) (Fixed<if> (= 0 (list-length params)) (print "void")) (println ")") (println "{") (set-oop-at (%typecheck <c-generator> *c-gen*) 0 (+ (oop-at (%typecheck <c-generator> *c-gen*) 0) 1)) (c-indent) (print "return ") (c-gen-expr (car body)) (println ";") (set-oop-at (%typecheck <c-generator> *c-gen*) 0 (- (oop-at (%typecheck <c-generator> *c-gen*) 0) 1)) (println "}") (println) (set-oop-at (%typecheck <c-generator> *c-gen*) 2 (cons name (oop-at (%typecheck <c-generator> *c-gen*) 2))) (Fixed<or> main (Fixed<let> () (println "static oop v_" (mangle-label name) " = (oop)" (mangle-label name) ";") (set-oop-at (%typecheck <c-generator> *c-gen*) 3 (cons name (oop-at (%typecheck <c-generator> *c-gen*) 3))))))))) (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((tnam (Fixed<if> main (LABEL name) (LABEL (temp-label-name))))) (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT)))))))))))
[?7h[32m[?7l...                     [0m (Fixed<let> () (Fixed<if> (Fixed<and> (defined? (Fixed<quote> *c-backend-active*)) *c-backend-active*) (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((params (cadr defn))) (Fixed<let> ((body (cddr defn))) (set-oop-at (%typecheck <c-generator> *c-gen*) 5 name) (print "static oop " (mangle-label name) "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<if> first (Fixed<set> first ()) (print ", ")) (print "oop " (mangle-label (oop-at (%typecheck <variable> param) 0)))) (Fixed<set> _list_ (cdr _list_))))) (Fixed<if> (= 0 (list-length params)) (print "void")) (println ")") (println "{") (set-oop-at (%typecheck <c-generator> *c-gen*) 0 (+ (oop-at (%typecheck <c-generator> *c-gen*) 0) 1)) (c-indent) (print "return ") (c-gen-expr (car body)) (println ";") (set-oop-at (%typecheck <c-generator> *c-gen*) 0 (- (oop-at (%typecheck <c-generator> *c-gen*) 0) 1)) (println "}") (println) (set-oop-at (%typecheck <c-generator> *c-gen*) 2 (cons name (oop-at (%typecheck <c-generator> *c-gen*) 2))) (Fixed<or> main (Fixed<let> () (println "static oop v_" (mangle-label name) " = (oop)" (mangle-label name) ";") (set-oop-at (%typecheck <c-generator> *c-gen*) 3 (cons name (oop-at (%typecheck <c-generator> *c-gen*) 3))))))))) (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((tnam (Fixed<if> main (LABEL name) (LABEL (temp-label-name))))) (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT))))))))))))
[?7h[32m[?7l...                     [0m (Fixed<let> () (Fixed<let> () (Fixed<if> (Fixed<and> (defined? (Fixed<quote> *c-backend-active*)) *c-backend-active*) (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((params (cadr defn))) (Fixed<let> ((body (cddr defn))) (set-oop-at (%typecheck <c-generator> *c-gen*) 5 name) (print "static oop " (mangle-label name) "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<if> first (Fixed<set> first ()) (print ", ")) (print "oop " (mangle-label (oop-at (%typecheck <variable> param) 0)))) (Fixed<set> _list_ (cdr _list_))))) (Fixed<if> (= 0 (list-length params)) (print "void")) (println ")") (println "{") (set-oop-at (%typecheck <c-generator> *c-gen*) 0 (+ (oop-at (%typecheck <c-generator> *c-gen*) 0) 1)) (c-indent) (print "return ") (c-gen-expr (car body)) (println ";") (set-oop-at (%typecheck <c-generator> *c-gen*) 0 (- (oop-at (%typecheck <c-generator> *c-gen*) 0) 1)) (println "}") (println) (set-oop-at (%typecheck <c-generator> *c-gen*) 2 (cons name (oop-at (%typecheck <c-generator> *c-gen*) 2))) (Fixed<or> main (Fixed<let> () (println "static oop v_" (mangle-label name) " = (oop)" (mangle-label name) ";") (set-oop-at (%typecheck <c-generator> *c-gen*) 3 (cons name (oop-at (%typecheck <c-generator> *c-gen*) 3))))))))) (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((tnam (Fixed<if> main (LABEL name) (LABEL (temp-label-name))))) (Fixed<let> ((vnam (Fixed<if> main () (LABEL name)))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((arg-size (align 16 (oop-at (%typecheck <compiler> comp) 3)))) (Fixed<let> ((tmp-size (align 16 (+ arg-size (oop-at (%typecheck <compiler> comp) 5))))) (Fixed<let> ((frm-size (align 16 (+ tmp-size 8)))) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ arg-size (oop-at (%typecheck <TI32> tmp) 0)))) (oop-at (%typecheck <compiler> comp) 6)) (map (Fixed<lambda> (tmp) (set-oop-at (%typecheck <TI32> tmp) 0 (+ frm-size (oop-at (%typecheck <TI32> tmp) 0)))) params) (emit TEXT) (Fixed<and> main (emit GLOBAL tnam)) (emit DEFLABEL tnam) (emit COMMENT (list "frame " arg-size " " (oop-at (%typecheck <compiler> comp) 5) " " tmp-size " " frm-size)) (emit ENTER (- frm-size 8)) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (emit DEFLABEL (oop-at (%typecheck <compiler> comp) 7))) (emit LEAVE (- frm-size 8))))) (Fixed<or> main (Fixed<let> () (gen ocomp DATA) (gen ocomp GLOBAL vnam) (gen ocomp DEFLABEL vnam) (gen ocomp LONG tnam) (gen ocomp TEXT)))))))))))))
[?7h[32m[?7lboot.l:517              [0m (apply (Fixed<or> (array-at (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (<selector>-inherit (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (oop-at (%typecheck <selector> self) 2)) arguments)
[?7h[32m[?7lcore/compiler/emit.l:510[0m (gen-definition value name comp)
[?7h[32m[?7lcore/compiler/emit.l:505[0m (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (warn name "\012") (gen-definition value name comp))
[?7h[32m[?7lcore/compiler/emit.l:504[0m (Fixed<while> (<= 0 (Fixed<set> index (- index 1))) (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (warn name "\012") (gen-definition value name comp)))
[?7h[32m[?7lcore/compiler/emit.l:501[0m (Fixed<let> ((index (array-length vars))) (Fixed<while> (<= 0 (Fixed<set> index (- index 1))) (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (warn name "\012") (gen-definition value name comp))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))))
[?7h[32m[?7lcore/compiler/emit.l:501[0m (Fixed<let> ((comp (compiler 0))) (Fixed<let> ((index (array-length vars))) (Fixed<while> (<= 0 (Fixed<set> index (- index 1))) (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (warn name "\012") (gen-definition value name comp))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1))))))
[?7h[32m[?7lcore/compiler/emit.l:501[0m (Fixed<let> ((vars (oop-at (%typecheck <env> env) 3))) (Fixed<let> ((comp (compiler 0))) (Fixed<let> ((index (array-length vars))) (Fixed<while> (<= 0 (Fixed<set> index (- index 1))) (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (warn name "\012") (gen-definition value name comp))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))))))
[?7h[32m[?7lcore/compiler/emit.l:518[0m (gen-env env)
[?7h[32m[?7lcore/compiler/emit.l:516[0m (Fixed<let> ((env *globals*)) (Fixed<set> *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env))
[?7h