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
