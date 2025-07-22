## defn main
main
	.text
	.globl _main
_main:
## frame 32 32 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__1__core_2Feval_2El__1558:
	movl $0,%eax
	movl %eax,32(%esp)
	.data
___L__2__core_2Feval_2El__1558:
	.asciz "r"
	.text
	movl $___L__2__core_2Feval_2El__1558,%eax
	movl %eax,36(%esp)
	movl _fdopen_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_stdin
___L__3__core_2Feval_2El__1559:
	movl $1,%eax
	movl %eax,36(%esp)
	.data
___L__4__core_2Feval_2El__1559:
	.asciz "a"
	.text
	movl $___L__4__core_2Feval_2El__1559,%eax
	movl %eax,32(%esp)
	movl _fdopen_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_stdout
___L__5__core_2Feval_2El__1560:
	movl $2,%eax
	movl %eax,32(%esp)
	.data
___L__6__core_2Feval_2El__1560:
	.asciz "a"
	.text
	movl $___L__6__core_2Feval_2El__1560,%eax
	movl %eax,36(%esp)
	movl _fdopen_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_stderr
___L__7__core_2Feval_2El__1562:
	movl _gc__initialise,%eax
	call *%eax
	movl $0,%eax
___L__8__core_2Feval_2El__1564:
	movl $0,%eax
	movl %eax,36(%esp)
	movl _new_2D_3Carray_3E,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_symbols
	movl $_symbols,%eax
	movl %eax,36(%esp)
	movl _gc__push__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__9__core_2Feval_2El__1566:
	.data
___L__10__core_2Feval_2El__1566:
	.asciz "t"
	.text
	movl $___L__10__core_2Feval_2El__1566,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__t
___L__11__core_2Feval_2El__1567:
	.data
___L__12__core_2Feval_2El__1567:
	.asciz "."
	.text
	movl $___L__12__core_2Feval_2El__1567,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__dot
___L__13__core_2Feval_2El__1568:
	.data
___L__14__core_2Feval_2El__1568:
	.asciz "set"
	.text
	movl $___L__14__core_2Feval_2El__1568,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__set
___L__15__core_2Feval_2El__1569:
	.data
___L__16__core_2Feval_2El__1569:
	.asciz "define"
	.text
	movl $___L__16__core_2Feval_2El__1569,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__define
___L__17__core_2Feval_2El__1570:
	.data
___L__18__core_2Feval_2El__1570:
	.asciz "lambda"
	.text
	movl $___L__18__core_2Feval_2El__1570,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__lambda
___L__19__core_2Feval_2El__1571:
	.data
___L__20__core_2Feval_2El__1571:
	.asciz "let"
	.text
	movl $___L__20__core_2Feval_2El__1571,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__let
___L__21__core_2Feval_2El__1572:
	.data
___L__22__core_2Feval_2El__1572:
	.asciz "quote"
	.text
	movl $___L__22__core_2Feval_2El__1572,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__quote
___L__23__core_2Feval_2El__1573:
	.data
___L__24__core_2Feval_2El__1573:
	.asciz "quasiquote"
	.text
	movl $___L__24__core_2Feval_2El__1573,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__quasiquote
___L__25__core_2Feval_2El__1574:
	.data
___L__26__core_2Feval_2El__1574:
	.asciz "unquote"
	.text
	movl $___L__26__core_2Feval_2El__1574,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__unquote
___L__27__core_2Feval_2El__1575:
	.data
___L__28__core_2Feval_2El__1575:
	.asciz "unquote-splicing"
	.text
	movl $___L__28__core_2Feval_2El__1575,%eax
	movl %eax,36(%esp)
	movl _intern,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_s__unquote__splicing
___L__29__core_2Feval_2El__1577:
	movl $_globals,%eax
	movl %eax,36(%esp)
	movl _gc__push__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__30__core_2Feval_2El__1579:
	movl $0,%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl _new_2D_3Cenv_3E,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,_globals
___L__31__core_2Feval_2El__1580:
	movl _globals,%eax
	movl %eax,40(%esp)
	.data
___L__32__core_2Feval_2El__1580:
	.asciz "*globals*"
	.text
	movl $___L__32__core_2Feval_2El__1580,%eax
	movl %eax,32(%esp)
	movl _intern,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl _globals,%eax
	movl %eax,36(%esp)
	movl _k__env__define,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,_globals
___L__33__core_2Feval_2El__1582:
	movl _globals,%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	.data
___L__34__core_2Feval_2El__1582:
	.asciz "*input*"
	.text
	movl $___L__34__core_2Feval_2El__1582,%eax
	movl %eax,32(%esp)
	movl _intern,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl %eax,44(%esp)
	movl _k__env__define,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 44(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,_input
	movl $_input,%eax
	movl %eax,44(%esp)
	movl _gc__push__root,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__35__core_2Feval_2El__1583:
	movl _globals,%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,36(%esp)
	movl 44(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
	.data
___L__36__core_2Feval_2El__1583:
	.asciz "*expanders*"
	.text
	movl $___L__36__core_2Feval_2El__1583,%eax
	movl %eax,32(%esp)
	movl _intern,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl _k__env__define,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,_expanders
	movl $_expanders,%eax
	movl %eax,40(%esp)
	movl _gc__push__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__37__core_2Feval_2El__1584:
	movl _globals,%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,44(%esp)
	movl 40(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	.data
___L__38__core_2Feval_2El__1584:
	.asciz "*encoders*"
	.text
	movl $___L__38__core_2Feval_2El__1584,%eax
	movl %eax,32(%esp)
	movl _intern,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
	movl _k__env__define,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,_encoders
	movl $_encoders,%eax
	movl %eax,36(%esp)
	movl _gc__push__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__39__core_2Feval_2El__1585:
	movl _globals,%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	.data
___L__40__core_2Feval_2El__1585:
	.asciz "*evaluators*"
	.text
	movl $___L__40__core_2Feval_2El__1585,%eax
	movl %eax,32(%esp)
	movl _intern,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl %eax,44(%esp)
	movl _k__env__define,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 44(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,_evaluators
	movl $_evaluators,%eax
	movl %eax,44(%esp)
	movl _gc__push__root,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__41__core_2Feval_2El__1586:
	movl _globals,%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,36(%esp)
	movl 44(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
	.data
___L__42__core_2Feval_2El__1586:
	.asciz "*applicators*"
	.text
	movl $___L__42__core_2Feval_2El__1586,%eax
	movl %eax,32(%esp)
	movl _intern,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl _k__env__define,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,_applicators
	movl $_applicators,%eax
	movl %eax,40(%esp)
	movl _gc__push__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__43__core_2Feval_2El__1588:
	.data
___L__44__core_2Feval_2El__1588:
	.asciz "define"
	.text
	movl $___L__44__core_2Feval_2El__1588,%eax
	movl %eax,40(%esp)
	movl _subr__define,%eax
	movl %eax,32(%esp)
	movl _define_2Dfsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__45__core_2Feval_2El__1589:
	.data
___L__46__core_2Feval_2El__1589:
	.asciz "lambda"
	.text
	movl $___L__46__core_2Feval_2El__1589,%eax
	movl %eax,32(%esp)
	movl _subr__lambda,%eax
	movl %eax,40(%esp)
	movl _define_2Dfsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__47__core_2Feval_2El__1590:
	.data
___L__48__core_2Feval_2El__1590:
	.asciz "let"
	.text
	movl $___L__48__core_2Feval_2El__1590,%eax
	movl %eax,40(%esp)
	movl _subr__let,%eax
	movl %eax,32(%esp)
	movl _define_2Dfsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__49__core_2Feval_2El__1591:
	.data
___L__50__core_2Feval_2El__1591:
	.asciz "set"
	.text
	movl $___L__50__core_2Feval_2El__1591,%eax
	movl %eax,32(%esp)
	movl _subr__set,%eax
	movl %eax,40(%esp)
	movl _define_2Dfsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__51__core_2Feval_2El__1592:
	.data
___L__52__core_2Feval_2El__1592:
	.asciz "while"
	.text
	movl $___L__52__core_2Feval_2El__1592,%eax
	movl %eax,40(%esp)
	movl _subr__while,%eax
	movl %eax,32(%esp)
	movl _define_2Dfsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__53__core_2Feval_2El__1593:
	.data
___L__54__core_2Feval_2El__1593:
	.asciz "if"
	.text
	movl $___L__54__core_2Feval_2El__1593,%eax
	movl %eax,32(%esp)
	movl _subr__if,%eax
	movl %eax,40(%esp)
	movl _define_2Dfsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__55__core_2Feval_2El__1594:
	.data
___L__56__core_2Feval_2El__1594:
	.asciz "or"
	.text
	movl $___L__56__core_2Feval_2El__1594,%eax
	movl %eax,40(%esp)
	movl _subr__or,%eax
	movl %eax,32(%esp)
	movl _define_2Dfsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__57__core_2Feval_2El__1595:
	.data
___L__58__core_2Feval_2El__1595:
	.asciz "and"
	.text
	movl $___L__58__core_2Feval_2El__1595,%eax
	movl %eax,32(%esp)
	movl _subr__and,%eax
	movl %eax,40(%esp)
	movl _define_2Dfsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__59__core_2Feval_2El__1596:
	.data
___L__60__core_2Feval_2El__1596:
	.asciz "quote"
	.text
	movl $___L__60__core_2Feval_2El__1596,%eax
	movl %eax,40(%esp)
	movl _subr__quote,%eax
	movl %eax,32(%esp)
	movl _define_2Dfsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__61__core_2Feval_2El__1597:
	.data
___L__62__core_2Feval_2El__1597:
	.asciz "defined?"
	.text
	movl $___L__62__core_2Feval_2El__1597,%eax
	movl %eax,32(%esp)
	movl _subr__definedP,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__63__core_2Feval_2El__1598:
	.data
___L__64__core_2Feval_2El__1598:
	.asciz "not"
	.text
	movl $___L__64__core_2Feval_2El__1598,%eax
	movl %eax,40(%esp)
	movl _subr__not,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__65__core_2Feval_2El__1599:
	.data
___L__66__core_2Feval_2El__1599:
	.asciz "&"
	.text
	movl $___L__66__core_2Feval_2El__1599,%eax
	movl %eax,32(%esp)
	movl _subr__bitand,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__67__core_2Feval_2El__1600:
	.data
___L__68__core_2Feval_2El__1600:
	.asciz "|"
	.text
	movl $___L__68__core_2Feval_2El__1600,%eax
	movl %eax,40(%esp)
	movl _subr__bitor,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__69__core_2Feval_2El__1601:
	.data
___L__70__core_2Feval_2El__1601:
	.asciz "^"
	.text
	movl $___L__70__core_2Feval_2El__1601,%eax
	movl %eax,32(%esp)
	movl _subr__bitxor,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__71__core_2Feval_2El__1602:
	.data
___L__72__core_2Feval_2El__1602:
	.asciz "+"
	.text
	movl $___L__72__core_2Feval_2El__1602,%eax
	movl %eax,40(%esp)
	movl _subr__add,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__73__core_2Feval_2El__1603:
	.data
___L__74__core_2Feval_2El__1603:
	.asciz "-"
	.text
	movl $___L__74__core_2Feval_2El__1603,%eax
	movl %eax,32(%esp)
	movl _subr__sub,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__75__core_2Feval_2El__1604:
	.data
___L__76__core_2Feval_2El__1604:
	.asciz "*"
	.text
	movl $___L__76__core_2Feval_2El__1604,%eax
	movl %eax,40(%esp)
	movl _subr__mul,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__77__core_2Feval_2El__1605:
	.data
___L__78__core_2Feval_2El__1605:
	.asciz "/"
	.text
	movl $___L__78__core_2Feval_2El__1605,%eax
	movl %eax,32(%esp)
	movl _subr__div,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__79__core_2Feval_2El__1606:
	.data
___L__80__core_2Feval_2El__1606:
	.asciz "<<"
	.text
	movl $___L__80__core_2Feval_2El__1606,%eax
	movl %eax,40(%esp)
	movl _subr__shl,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__81__core_2Feval_2El__1607:
	.data
___L__82__core_2Feval_2El__1607:
	.asciz ">>"
	.text
	movl $___L__82__core_2Feval_2El__1607,%eax
	movl %eax,32(%esp)
	movl _subr__shr,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__83__core_2Feval_2El__1608:
	.data
___L__84__core_2Feval_2El__1608:
	.asciz "<"
	.text
	movl $___L__84__core_2Feval_2El__1608,%eax
	movl %eax,40(%esp)
	movl _subr__lt,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__85__core_2Feval_2El__1609:
	.data
___L__86__core_2Feval_2El__1609:
	.asciz "<="
	.text
	movl $___L__86__core_2Feval_2El__1609,%eax
	movl %eax,32(%esp)
	movl _subr__le,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__87__core_2Feval_2El__1610:
	.data
___L__88__core_2Feval_2El__1610:
	.asciz "!="
	.text
	movl $___L__88__core_2Feval_2El__1610,%eax
	movl %eax,40(%esp)
	movl _subr__ne,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__89__core_2Feval_2El__1611:
	.data
___L__90__core_2Feval_2El__1611:
	.asciz "="
	.text
	movl $___L__90__core_2Feval_2El__1611,%eax
	movl %eax,32(%esp)
	movl _subr__eq,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__91__core_2Feval_2El__1612:
	.data
___L__92__core_2Feval_2El__1612:
	.asciz ">="
	.text
	movl $___L__92__core_2Feval_2El__1612,%eax
	movl %eax,40(%esp)
	movl _subr__ge,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__93__core_2Feval_2El__1613:
	.data
___L__94__core_2Feval_2El__1613:
	.asciz ">"
	.text
	movl $___L__94__core_2Feval_2El__1613,%eax
	movl %eax,32(%esp)
	movl _subr__gt,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__95__core_2Feval_2El__1614:
	.data
___L__96__core_2Feval_2El__1614:
	.asciz "abort"
	.text
	movl $___L__96__core_2Feval_2El__1614,%eax
	movl %eax,40(%esp)
	movl _subr__abort,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__97__core_2Feval_2El__1615:
	.data
___L__98__core_2Feval_2El__1615:
	.asciz "exit"
	.text
	movl $___L__98__core_2Feval_2El__1615,%eax
	movl %eax,32(%esp)
	movl _subr__exit,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__99__core_2Feval_2El__1616:
	.data
___L__100__core_2Feval_2El__1616:
	.asciz "format"
	.text
	movl $___L__100__core_2Feval_2El__1616,%eax
	movl %eax,40(%esp)
	movl _subr__format,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__101__core_2Feval_2El__1617:
	.data
___L__102__core_2Feval_2El__1617:
	.asciz "dump"
	.text
	movl $___L__102__core_2Feval_2El__1617,%eax
	movl %eax,32(%esp)
	movl _subr__dump,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__103__core_2Feval_2El__1618:
	.data
___L__104__core_2Feval_2El__1618:
	.asciz "print"
	.text
	movl $___L__104__core_2Feval_2El__1618,%eax
	movl %eax,40(%esp)
	movl _subr__print,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__105__core_2Feval_2El__1619:
	.data
___L__106__core_2Feval_2El__1619:
	.asciz "warn"
	.text
	movl $___L__106__core_2Feval_2El__1619,%eax
	movl %eax,32(%esp)
	movl _subr__warn,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__107__core_2Feval_2El__1620:
	.data
___L__108__core_2Feval_2El__1620:
	.asciz "apply"
	.text
	movl $___L__108__core_2Feval_2El__1620,%eax
	movl %eax,40(%esp)
	movl _subr__apply,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__109__core_2Feval_2El__1621:
	.data
___L__110__core_2Feval_2El__1621:
	.asciz "eval"
	.text
	movl $___L__110__core_2Feval_2El__1621,%eax
	movl %eax,32(%esp)
	movl _subr__eval,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__111__core_2Feval_2El__1622:
	.data
___L__112__core_2Feval_2El__1622:
	.asciz "encode"
	.text
	movl $___L__112__core_2Feval_2El__1622,%eax
	movl %eax,40(%esp)
	movl _subr__encode,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__113__core_2Feval_2El__1623:
	.data
___L__114__core_2Feval_2El__1623:
	.asciz "expand"
	.text
	movl $___L__114__core_2Feval_2El__1623,%eax
	movl %eax,32(%esp)
	movl _subr__expand,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__115__core_2Feval_2El__1624:
	.data
___L__116__core_2Feval_2El__1624:
	.asciz "cons"
	.text
	movl $___L__116__core_2Feval_2El__1624,%eax
	movl %eax,40(%esp)
	movl _subr__cons,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__117__core_2Feval_2El__1625:
	.data
___L__118__core_2Feval_2El__1625:
	.asciz "string"
	.text
	movl $___L__118__core_2Feval_2El__1625,%eax
	movl %eax,32(%esp)
	movl _subr__string,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__119__core_2Feval_2El__1626:
	.data
___L__120__core_2Feval_2El__1626:
	.asciz "array"
	.text
	movl $___L__120__core_2Feval_2El__1626,%eax
	movl %eax,40(%esp)
	movl _subr__array,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__121__core_2Feval_2El__1627:
	.data
___L__122__core_2Feval_2El__1627:
	.asciz "form"
	.text
	movl $___L__122__core_2Feval_2El__1627,%eax
	movl %eax,32(%esp)
	movl _subr__form,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__123__core_2Feval_2El__1628:
	.data
___L__124__core_2Feval_2El__1628:
	.asciz "open"
	.text
	movl $___L__124__core_2Feval_2El__1628,%eax
	movl %eax,40(%esp)
	movl _subr__open,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__125__core_2Feval_2El__1629:
	.data
___L__126__core_2Feval_2El__1629:
	.asciz "close"
	.text
	movl $___L__126__core_2Feval_2El__1629,%eax
	movl %eax,32(%esp)
	movl _subr__close,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__127__core_2Feval_2El__1630:
	.data
___L__128__core_2Feval_2El__1630:
	.asciz "getc"
	.text
	movl $___L__128__core_2Feval_2El__1630,%eax
	movl %eax,40(%esp)
	movl _subr__getc,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__129__core_2Feval_2El__1631:
	.data
___L__130__core_2Feval_2El__1631:
	.asciz "putc"
	.text
	movl $___L__130__core_2Feval_2El__1631,%eax
	movl %eax,32(%esp)
	movl _subr__putc,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__131__core_2Feval_2El__1632:
	.data
___L__132__core_2Feval_2El__1632:
	.asciz "allocate"
	.text
	movl $___L__132__core_2Feval_2El__1632,%eax
	movl %eax,40(%esp)
	movl _subr__allocate,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__133__core_2Feval_2El__1633:
	.data
___L__134__core_2Feval_2El__1633:
	.asciz "type-of"
	.text
	movl $___L__134__core_2Feval_2El__1633,%eax
	movl %eax,32(%esp)
	movl _subr__type__of,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__135__core_2Feval_2El__1634:
	.data
___L__136__core_2Feval_2El__1634:
	.asciz "string?"
	.text
	movl $___L__136__core_2Feval_2El__1634,%eax
	movl %eax,40(%esp)
	movl _subr__stringP,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__137__core_2Feval_2El__1635:
	.data
___L__138__core_2Feval_2El__1635:
	.asciz "symbol?"
	.text
	movl $___L__138__core_2Feval_2El__1635,%eax
	movl %eax,32(%esp)
	movl _subr__symbolP,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__139__core_2Feval_2El__1636:
	.data
___L__140__core_2Feval_2El__1636:
	.asciz "pair?"
	.text
	movl $___L__140__core_2Feval_2El__1636,%eax
	movl %eax,40(%esp)
	movl _subr__pairP,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__141__core_2Feval_2El__1637:
	.data
___L__142__core_2Feval_2El__1637:
	.asciz "array?"
	.text
	movl $___L__142__core_2Feval_2El__1637,%eax
	movl %eax,32(%esp)
	movl _subr__arrayP,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__143__core_2Feval_2El__1638:
	.data
___L__144__core_2Feval_2El__1638:
	.asciz "car"
	.text
	movl $___L__144__core_2Feval_2El__1638,%eax
	movl %eax,40(%esp)
	movl _subr__car,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__145__core_2Feval_2El__1639:
	.data
___L__146__core_2Feval_2El__1639:
	.asciz "cdr"
	.text
	movl $___L__146__core_2Feval_2El__1639,%eax
	movl %eax,32(%esp)
	movl _subr__cdr,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__147__core_2Feval_2El__1640:
	.data
___L__148__core_2Feval_2El__1640:
	.asciz "set-car"
	.text
	movl $___L__148__core_2Feval_2El__1640,%eax
	movl %eax,40(%esp)
	movl _subr__set__car,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__149__core_2Feval_2El__1641:
	.data
___L__150__core_2Feval_2El__1641:
	.asciz "set-cdr"
	.text
	movl $___L__150__core_2Feval_2El__1641,%eax
	movl %eax,32(%esp)
	movl _subr__set__cdr,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__151__core_2Feval_2El__1642:
	.data
___L__152__core_2Feval_2El__1642:
	.asciz "oop-at"
	.text
	movl $___L__152__core_2Feval_2El__1642,%eax
	movl %eax,40(%esp)
	movl _subr__oop__at,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__153__core_2Feval_2El__1643:
	.data
___L__154__core_2Feval_2El__1643:
	.asciz "set-oop-at"
	.text
	movl $___L__154__core_2Feval_2El__1643,%eax
	movl %eax,32(%esp)
	movl _subr__set__oop__at,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__155__core_2Feval_2El__1644:
	.data
___L__156__core_2Feval_2El__1644:
	.asciz "array-length"
	.text
	movl $___L__156__core_2Feval_2El__1644,%eax
	movl %eax,40(%esp)
	movl _subr__array__length,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__157__core_2Feval_2El__1645:
	.data
___L__158__core_2Feval_2El__1645:
	.asciz "array-at"
	.text
	movl $___L__158__core_2Feval_2El__1645,%eax
	movl %eax,32(%esp)
	movl _subr__array__at,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__159__core_2Feval_2El__1646:
	.data
___L__160__core_2Feval_2El__1646:
	.asciz "set-array-at"
	.text
	movl $___L__160__core_2Feval_2El__1646,%eax
	movl %eax,40(%esp)
	movl _subr__set__array__at,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__161__core_2Feval_2El__1647:
	.data
___L__162__core_2Feval_2El__1647:
	.asciz "string-length"
	.text
	movl $___L__162__core_2Feval_2El__1647,%eax
	movl %eax,32(%esp)
	movl _subr__string__length,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__163__core_2Feval_2El__1648:
	.data
___L__164__core_2Feval_2El__1648:
	.asciz "string-at"
	.text
	movl $___L__164__core_2Feval_2El__1648,%eax
	movl %eax,40(%esp)
	movl _subr__string__at,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__165__core_2Feval_2El__1649:
	.data
___L__166__core_2Feval_2El__1649:
	.asciz "set-string-at"
	.text
	movl $___L__166__core_2Feval_2El__1649,%eax
	movl %eax,32(%esp)
	movl _subr__set__string__at,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__167__core_2Feval_2El__1650:
	.data
___L__168__core_2Feval_2El__1650:
	.asciz "string->symbol"
	.text
	movl $___L__168__core_2Feval_2El__1650,%eax
	movl %eax,40(%esp)
	movl _subr__string__symbol,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__169__core_2Feval_2El__1651:
	.data
___L__170__core_2Feval_2El__1651:
	.asciz "symbol->string"
	.text
	movl $___L__170__core_2Feval_2El__1651,%eax
	movl %eax,32(%esp)
	movl _subr__symbol__string,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__171__core_2Feval_2El__1652:
	.data
___L__172__core_2Feval_2El__1652:
	.asciz "long->string"
	.text
	movl $___L__172__core_2Feval_2El__1652,%eax
	movl %eax,40(%esp)
	movl _subr__long__string,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__173__core_2Feval_2El__1653:
	.data
___L__174__core_2Feval_2El__1653:
	.asciz "verbose"
	.text
	movl $___L__174__core_2Feval_2El__1653,%eax
	movl %eax,32(%esp)
	movl _subr__verbose,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__175__core_2Feval_2El__1654:
	.data
___L__176__core_2Feval_2El__1654:
	.asciz "optimised"
	.text
	movl $___L__176__core_2Feval_2El__1654,%eax
	movl %eax,40(%esp)
	movl _subr__optimised,%eax
	movl %eax,32(%esp)
	movl _define_2Dsubr,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__177__core_2Feval_2El__1655:
	.data
___L__178__core_2Feval_2El__1655:
	.asciz "read"
	.text
	movl $___L__178__core_2Feval_2El__1655,%eax
	movl %eax,32(%esp)
	movl _subr__read,%eax
	movl %eax,40(%esp)
	movl _define_2Dsubr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__179__core_2Feval_2El__1657:
	movl $0,%eax
	movl %eax,40(%esp)
___L__180__core_2Feval_2El__1658:
	leal 40(%esp),%eax
	movl %eax,32(%esp)
	movl _gc__push__root,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__181__core_2Feval_2El__1659:
	jmp ___L__183__core_2Feval_2El__1659
___L__182__core_2Feval_2El__1659:
___L__184__core_2Feval_2El__1660:
	movl $0,%eax
	movl %eax,32(%esp)
	movl 40(%esp),%eax
	movl %eax,44(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,40(%esp)
___L__185__core_2Feval_2El__1661:
	movl 80(%esp),%eax
	movl %eax,44(%esp)
	movl 84(%esp),%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
	movl _new_2D_3Cstring_3E,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl 40(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 44(%esp),%eax
	movl %eax,(%ecx)
___L__183__core_2Feval_2El__1659:
___L__186__core_2Feval_2El__1659:
	movl $1,%eax
	movl %eax,44(%esp)
	movl 80(%esp),%eax
	subl 44(%esp),%eax
	movl %eax,80(%esp)
	movl %eax,44(%esp)
	movl $0,%eax
	cmpl 44(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__182__core_2Feval_2El__1659
___L__187__core_2Feval_2El__1662:
	movl _globals,%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,36(%esp)
	movl 44(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
	.data
___L__188__core_2Feval_2El__1662:
	.asciz "*arguments*"
	.text
	movl $___L__188__core_2Feval_2El__1662,%eax
	movl %eax,32(%esp)
	movl _intern,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl 40(%esp),%eax
	movl %eax,48(%esp)
	movl _k__env__define,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 48(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,_arguments
	movl %eax,48(%esp)
___L__189__core_2Feval_2El__1658:
	leal 40(%esp),%eax
	movl %eax,32(%esp)
	movl _gc__pop__root,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 48(%esp),%eax
___L__190__core_2Feval_2El__1664:
	movl _globals,%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,48(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 40(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl _s__set,%eax
	movl %eax,48(%esp)
	movl _k__env__lookup,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_f__set
	movl $_f__set,%eax
	movl %eax,48(%esp)
	movl _gc__push__root,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__191__core_2Feval_2El__1665:
	movl _globals,%eax
	movl %eax,48(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,44(%esp)
	movl 48(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
	movl _s__quote,%eax
	movl %eax,40(%esp)
	movl _k__env__lookup,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_f__quote
	movl $_f__quote,%eax
	movl %eax,40(%esp)
	movl _gc__push__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__192__core_2Feval_2El__1666:
	movl _globals,%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,48(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 40(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl _s__lambda,%eax
	movl %eax,48(%esp)
	movl _k__env__lookup,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_f__lambda
	movl $_f__lambda,%eax
	movl %eax,48(%esp)
	movl _gc__push__root,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__193__core_2Feval_2El__1667:
	movl _globals,%eax
	movl %eax,48(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,44(%esp)
	movl 48(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
	movl _s__let,%eax
	movl %eax,40(%esp)
	movl _k__env__lookup,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_f__let
	movl $_f__let,%eax
	movl %eax,40(%esp)
	movl _gc__push__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__194__core_2Feval_2El__1668:
	movl _globals,%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,48(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 40(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl _s__define,%eax
	movl %eax,48(%esp)
	movl _k__env__lookup,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_f__define
	movl $_f__define,%eax
	movl %eax,48(%esp)
	movl _gc__push__root,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__195__core_2Feval_2El__1670:
	movl $32,%eax
	movl %eax,48(%esp)
	movl _new_2D_3Carray_3E,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,_trace__stack
	movl $_trace__stack,%eax
	movl %eax,48(%esp)
	movl _gc__push__root,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__196__core_2Feval_2El__1672:
	movl _globals,%eax
	movl %eax,48(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,44(%esp)
	movl 48(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
	.data
___L__197__core_2Feval_2El__1672:
	.asciz "*backtrace*"
	.text
	movl $___L__197__core_2Feval_2El__1672,%eax
	movl %eax,40(%esp)
	movl _intern,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl _k__env__define,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__198__core_2Feval_2El__1674:
	jmp ___L__200__core_2Feval_2El__1674
___L__199__core_2Feval_2El__1674:
___L__201__core_2Feval_2El__1675:
	movl _arguments,%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,48(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
___L__202__core_2Feval_2El__1676:
	movl $0,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
___L__203__core_2Feval_2El__1675:
___L__204__core_2Feval_2El__1677:
	movl 40(%esp),%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,48(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,36(%esp)
	movl 44(%esp),%eax
	movl %eax,52(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 52(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
___L__205__core_2Feval_2El__1678:
	leal 40(%esp),%eax
	movl %eax,48(%esp)
	movl _gc__push__root,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__206__core_2Feval_2El__1679:
	movl _arguments,%eax
	movl %eax,48(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,52(%esp)
	movl 32(%esp),%eax
	movl 52(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,52(%esp)
	movl $1,%eax
	movl %eax,36(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,56(%esp)
	movl 48(%esp),%eax
	movl %eax,60(%esp)
	movl __25typecheck,%eax
	movl 56(%esp),%ecx
	movl %ecx,0(%esp)
	movl 60(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 52(%esp),%eax
	movl %eax,(%ecx)
___L__207__core_2Feval_2El__1680:
___L__210__core_2Feval_2El__1681:
	movl 44(%esp),%eax
	movl %eax,48(%esp)
	.data
___L__211__core_2Feval_2El__1681:
	.asciz "-v"
	.text
	movl $___L__211__core_2Feval_2El__1681,%eax
	movl %eax,52(%esp)
	movl _strcmp_24stub,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 52(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	cmpl $0,%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__208__core_2Feval_2El__1680
	movl _opt__verbose,%eax
	movl %eax,52(%esp)
	movl $1,%eax
	addl 52(%esp),%eax
	movl %eax,_opt__verbose
	jmp ___L__209__core_2Feval_2El__1680
___L__208__core_2Feval_2El__1680:
___L__212__core_2Feval_2El__1680:
___L__215__core_2Feval_2El__1682:
	movl 44(%esp),%eax
	movl %eax,52(%esp)
	.data
___L__216__core_2Feval_2El__1682:
	.asciz "-O"
	.text
	movl $___L__216__core_2Feval_2El__1682,%eax
	movl %eax,48(%esp)
	movl _strcmp_24stub,%eax
	movl 52(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	cmpl $0,%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__213__core_2Feval_2El__1680
	movl _opt__optimised,%eax
	movl %eax,48(%esp)
	movl $1,%eax
	addl 48(%esp),%eax
	movl %eax,_opt__optimised
	jmp ___L__214__core_2Feval_2El__1680
___L__213__core_2Feval_2El__1680:
___L__217__core_2Feval_2El__1680:
___L__220__core_2Feval_2El__1683:
	movl 44(%esp),%eax
	movl %eax,48(%esp)
	.data
___L__221__core_2Feval_2El__1683:
	.asciz "-"
	.text
	movl $___L__221__core_2Feval_2El__1683,%eax
	movl %eax,52(%esp)
	movl _strcmp_24stub,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 52(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	cmpl $0,%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__218__core_2Feval_2El__1680
	movl _stdin,%eax
	movl %eax,52(%esp)
	movl _repl__stream,%eax
	movl 52(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__219__core_2Feval_2El__1680
___L__218__core_2Feval_2El__1680:
___L__222__core_2Feval_2El__1684:
	movl 44(%esp),%eax
	movl %eax,52(%esp)
	.data
___L__223__core_2Feval_2El__1684:
	.asciz "r"
	.text
	movl $___L__223__core_2Feval_2El__1684,%eax
	movl %eax,48(%esp)
	movl _fopen_24stub,%eax
	movl 52(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,48(%esp)
___L__224__core_2Feval_2El__1685:
	movl 48(%esp),%eax
	cmpl $0,%eax
	jne ___L__225__core_2Feval_2El__1685
	.data
___L__226__core_2Feval_2El__1685:
	.asciz "no such file: %s"
	.text
	movl $___L__226__core_2Feval_2El__1685,%eax
	movl %eax,52(%esp)
	movl 44(%esp),%eax
	movl %eax,36(%esp)
	movl _fatal1,%eax
	movl 52(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__225__core_2Feval_2El__1685:
___L__227__core_2Feval_2El__1686:
	movl 48(%esp),%eax
	movl %eax,36(%esp)
	movl _repl__stream,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__228__core_2Feval_2El__1687:
	movl 48(%esp),%eax
	movl %eax,36(%esp)
	movl _fclose_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__219__core_2Feval_2El__1680:
___L__214__core_2Feval_2El__1680:
___L__209__core_2Feval_2El__1680:
	movl %eax,48(%esp)
___L__229__core_2Feval_2El__1678:
	leal 40(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 48(%esp),%eax
___L__200__core_2Feval_2El__1674:
___L__230__core_2Feval_2El__1674:
	movl _arguments,%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,44(%esp)
	movl 32(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__231__core_2Feval_2El__1674
	movl $1,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__233__core_2Feval_2El__1674
	movl __3Clong_3E,%eax
	jmp ___L__234__core_2Feval_2El__1674
___L__233__core_2Feval_2El__1674:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__234__core_2Feval_2El__1674:
	jmp ___L__232__core_2Feval_2El__1674
___L__231__core_2Feval_2El__1674:
	movl __3Cundefined_3E,%eax
___L__232__core_2Feval_2El__1674:
	movl %eax,32(%esp)
	movl __3Cpair_3E,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__199__core_2Feval_2El__1674
___L__235__core_2Feval_2El__1689:
	movl $0,%eax
	movl %eax,32(%esp)
	movl _opt__verbose,%eax
	cmpl 32(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__236__core_2Feval_2El__1689
___L__237__core_2Feval_2El__1690:
___L__238__core_2Feval_2El__1691:
	movl _gc__gcollect,%eax
	call *%eax
___L__239__core_2Feval_2El__1692:
	.data
___L__240__core_2Feval_2El__1692:
	.asciz "GC: %d objects in %d bytes, %d free\012"
	.text
	movl $___L__240__core_2Feval_2El__1692,%eax
	movl %eax,32(%esp)
	movl _gc__objects__live,%eax
	movl %eax,40(%esp)
	movl _gc__bytes__used,%eax
	movl %eax,48(%esp)
	movl _gc__bytes__free,%eax
	movl %eax,44(%esp)
	movl _printf_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	movl 48(%esp),%ecx
	movl %ecx,8(%esp)
	movl 44(%esp),%ecx
	movl %ecx,12(%esp)
	call *%eax
___L__236__core_2Feval_2El__1689:
___L__241__core_2Feval_2El__1694:
	movl _stderr,%eax
	movl %eax,44(%esp)
	.data
___L__242__core_2Feval_2El__1694:
	.asciz "%d objects in %d bytes, %d free\012"
	.text
	movl $___L__242__core_2Feval_2El__1694,%eax
	movl %eax,48(%esp)
	movl _gc__objects__live,%eax
	movl %eax,40(%esp)
	movl _gc__bytes__used,%eax
	movl %eax,32(%esp)
	movl _gc__bytes__free,%eax
	movl %eax,36(%esp)
	movl _fprintf_24stub,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	movl 32(%esp),%ecx
	movl %ecx,12(%esp)
	movl 36(%esp),%ecx
	movl %ecx,16(%esp)
	call *%eax
	movl $0,%eax
	addl $72,%esp
	leave
	ret
## defn define-fsubr
define-fsubr
	.text
___L__243__core_2Feval_2El__1694:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__244__core_2Feval_2El__1552:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Csubr_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__245__core_2Feval_2El__1553:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__246__core_2Feval_2El__1554:
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl _new_2D_3Cfixed_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__247__core_2Feval_2El__1555:
	movl _globals,%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _intern,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl _k__env__define,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__248__core_2Feval_2El__1553:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 32(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn define-subr
define-subr
	.text
___L__249__core_2Feval_2El__1553:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__250__core_2Feval_2El__1547:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Csubr_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__251__core_2Feval_2El__1548:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__252__core_2Feval_2El__1549:
	movl _globals,%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _intern,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl _k__env__define,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__253__core_2Feval_2El__1548:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 32(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn repl_stream
repl_stream
	.text
___L__254__core_2Feval_2El__1548:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__255__core_2Feval_2El__1524:
	movl _input,%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
___L__256__core_2Feval_2El__1525:
	movl $0,%eax
	movl %eax,16(%esp)
___L__257__core_2Feval_2El__1526:
	leal 16(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__push__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__258__core_2Feval_2El__1527:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _stdin,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__259__core_2Feval_2El__1527
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	.data
___L__260__core_2Feval_2El__1527:
	.asciz "#!%*[^\012\015]"
	.text
	movl $___L__260__core_2Feval_2El__1527,%eax
	movl %eax,24(%esp)
	movl _fscanf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__259__core_2Feval_2El__1527:
___L__261__core_2Feval_2El__1528:
	jmp ___L__263__core_2Feval_2El__1528
___L__262__core_2Feval_2El__1528:
___L__264__core_2Feval_2El__1531:
	movl _globals,%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cenv_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__265__core_2Feval_2El__1532:
	leal 28(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__push__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__266__core_2Feval_2El__1533:
	movl $0,%eax
	movl %eax,20(%esp)
	movl _opt__verbose,%eax
	cmpl 20(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__267__core_2Feval_2El__1533
	.data
___L__268__core_2Feval_2El__1533:
	.asciz ";;; "
	.text
	movl $___L__268__core_2Feval_2El__1533,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__267__core_2Feval_2El__1533
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__dumpln,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__267__core_2Feval_2El__1533:
___L__269__core_2Feval_2El__1534:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 28(%esp),%eax
	movl %eax,24(%esp)
	movl _k__expand,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl _opt__verbose,%eax
	cmpl 24(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__270__core_2Feval_2El__1534
	.data
___L__271__core_2Feval_2El__1534:
	.asciz "expd--> "
	.text
	movl $___L__271__core_2Feval_2El__1534,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__270__core_2Feval_2El__1534
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__dumpln,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__270__core_2Feval_2El__1534:
___L__272__core_2Feval_2El__1535:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	movl %eax,20(%esp)
	movl _k__encode,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $2,%eax
	movl %eax,20(%esp)
	movl _opt__verbose,%eax
	cmpl 20(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__273__core_2Feval_2El__1535
	.data
___L__274__core_2Feval_2El__1535:
	.asciz "encd--> "
	.text
	movl $___L__274__core_2Feval_2El__1535,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__273__core_2Feval_2El__1535
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__dumpln,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__273__core_2Feval_2El__1535:
___L__275__core_2Feval_2El__1536:
	movl $0,%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl _new_2Dbase_2D_3Ccontext_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__276__core_2Feval_2El__1537:
	leal 32(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__push__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__277__core_2Feval_2El__1538:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 32(%esp),%eax
	movl %eax,20(%esp)
	movl _k__eval,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl _opt__verbose,%eax
	cmpl 20(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__278__core_2Feval_2El__1538
	.data
___L__279__core_2Feval_2El__1538:
	.asciz "eval--> "
	.text
	movl $___L__279__core_2Feval_2El__1538,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__278__core_2Feval_2El__1538
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__dumpln,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__278__core_2Feval_2El__1538:
___L__280__core_2Feval_2El__1539:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _stdin,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__281__core_2Feval_2El__1539
___L__283__core_2Feval_2El__1540:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__dumpln,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__282__core_2Feval_2El__1539
___L__281__core_2Feval_2El__1539:
___L__284__core_2Feval_2El__1541:
	movl $0,%eax
	movl %eax,20(%esp)
	movl _opt__verbose,%eax
	cmpl 20(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__285__core_2Feval_2El__1541
	.data
___L__286__core_2Feval_2El__1541:
	.asciz ";;; => "
	.text
	movl $___L__286__core_2Feval_2El__1541,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__285__core_2Feval_2El__1541
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__dumpln,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__285__core_2Feval_2El__1541:
___L__282__core_2Feval_2El__1539:
	movl %eax,20(%esp)
___L__287__core_2Feval_2El__1537:
	leal 32(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,32(%esp)
___L__288__core_2Feval_2El__1532:
	leal 28(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__pop__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 32(%esp),%eax
___L__263__core_2Feval_2El__1528:
___L__289__core_2Feval_2El__1528:
___L__290__core_2Feval_2El__1529:
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl _stdin,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__291__core_2Feval_2El__1529
	movl _stdout,%eax
	movl %eax,28(%esp)
	.data
___L__292__core_2Feval_2El__1529:
	.asciz "."
	.text
	movl $___L__292__core_2Feval_2El__1529,%eax
	movl %eax,32(%esp)
	movl _fprintf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__291__core_2Feval_2El__1529
	movl _stdout,%eax
	movl %eax,32(%esp)
	movl _fflush_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__291__core_2Feval_2El__1529:
___L__293__core_2Feval_2El__1530:
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl _k__read,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl %eax,32(%esp)
	movl _DONE,%eax
	cmpl 32(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__262__core_2Feval_2El__1528
___L__294__core_2Feval_2El__1542:
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl _stdin,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__295__core_2Feval_2El__1542
___L__296__core_2Feval_2El__1543:
	.data
___L__297__core_2Feval_2El__1543:
	.asciz "\012morituri te salutant\012"
	.text
	movl $___L__297__core_2Feval_2El__1543,%eax
	movl %eax,32(%esp)
	movl _printf_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__295__core_2Feval_2El__1542:
	movl %eax,32(%esp)
___L__298__core_2Feval_2El__1526:
	leal 16(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__pop__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 32(%esp),%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn subr_read
subr_read
	.text
___L__299__core_2Feval_2El__1526:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__300__core_2Feval_2El__1502:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__301__core_2Feval_2El__1502
___L__303__core_2Feval_2El__1503:
	movl _stdin,%eax
	movl %eax,16(%esp)
	movl _k__read,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__304__core_2Feval_2El__1504:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _DONE,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__305__core_2Feval_2El__1504
	movl $0,%eax
	movl %eax,16(%esp)
___L__305__core_2Feval_2El__1504:
	movl 16(%esp),%eax
	jmp ___L__302__core_2Feval_2El__1502
___L__301__core_2Feval_2El__1502:
___L__306__core_2Feval_2El__1506:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__307__core_2Feval_2El__1507:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__309__core_2Feval_2El__1507
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__311__core_2Feval_2El__1507
	movl __3Clong_3E,%eax
	jmp ___L__312__core_2Feval_2El__1507
___L__311__core_2Feval_2El__1507:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__312__core_2Feval_2El__1507:
	jmp ___L__310__core_2Feval_2El__1507
___L__309__core_2Feval_2El__1507:
	movl __3Cundefined_3E,%eax
___L__310__core_2Feval_2El__1507:
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__308__core_2Feval_2El__1507
	.data
___L__313__core_2Feval_2El__1507:
	.asciz "read: non-String argument: "
	.text
	movl $___L__313__core_2Feval_2El__1507,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _fatal1,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__308__core_2Feval_2El__1507:
___L__314__core_2Feval_2El__1508:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__315__core_2Feval_2El__1509:
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	.data
___L__316__core_2Feval_2El__1509:
	.asciz "r"
	.text
	movl $___L__316__core_2Feval_2El__1509,%eax
	movl %eax,32(%esp)
	movl _fopen_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__317__core_2Feval_2El__1510:
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__318__core_2Feval_2El__1510
___L__320__core_2Feval_2El__1511:
	movl $0,%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
	movl 28(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
___L__321__core_2Feval_2El__1514:
	leal 28(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__push__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 36(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__push__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__322__core_2Feval_2El__1515:
	jmp ___L__324__core_2Feval_2El__1515
___L__323__core_2Feval_2El__1515:
___L__325__core_2Feval_2El__1516:
	movl 36(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl %eax,44(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,44(%esp)
	movl $1,%eax
	movl %eax,40(%esp)
	movl 20(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 44(%esp),%eax
	movl %eax,(%ecx)
	movl %eax,20(%esp)
___L__324__core_2Feval_2El__1515:
___L__326__core_2Feval_2El__1515:
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl _k__read,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,36(%esp)
	movl %eax,44(%esp)
	movl _DONE,%eax
	cmpl 44(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__323__core_2Feval_2El__1515
	movl %eax,44(%esp)
___L__327__core_2Feval_2El__1514:
	leal 36(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__pop__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 28(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__pop__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 44(%esp),%eax
___L__328__core_2Feval_2El__1517:
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl _fclose_24stub,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__329__core_2Feval_2El__1518:
	movl $1,%eax
	movl %eax,44(%esp)
	movl 28(%esp),%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	jmp ___L__319__core_2Feval_2El__1510
___L__318__core_2Feval_2El__1510:
	movl $0,%eax
___L__319__core_2Feval_2El__1510:
___L__302__core_2Feval_2El__1502:
	addl $56,%esp
	leave
	ret
## defn subr_optimised
subr_optimised
	.text
___L__330__core_2Feval_2El__1518:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__331__core_2Feval_2El__1496:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__332__core_2Feval_2El__1497:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__335__core_2Feval_2El__1497
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__337__core_2Feval_2El__1497
	movl __3Clong_3E,%eax
	jmp ___L__338__core_2Feval_2El__1497
___L__337__core_2Feval_2El__1497:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__338__core_2Feval_2El__1497:
	jmp ___L__336__core_2Feval_2El__1497
___L__335__core_2Feval_2El__1497:
	movl __3Cundefined_3E,%eax
___L__336__core_2Feval_2El__1497:
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__333__core_2Feval_2El__1497
___L__339__core_2Feval_2El__1498:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,_opt__optimised
	jmp ___L__334__core_2Feval_2El__1497
___L__333__core_2Feval_2El__1497:
___L__340__core_2Feval_2El__1499:
	movl _opt__optimised,%eax
	movl %eax,20(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__334__core_2Feval_2El__1497:
	addl $56,%esp
	leave
	ret
## defn subr_verbose
subr_verbose
	.text
___L__341__core_2Feval_2El__1499:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__342__core_2Feval_2El__1490:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__343__core_2Feval_2El__1491:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__346__core_2Feval_2El__1491
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__348__core_2Feval_2El__1491
	movl __3Clong_3E,%eax
	jmp ___L__349__core_2Feval_2El__1491
___L__348__core_2Feval_2El__1491:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__349__core_2Feval_2El__1491:
	jmp ___L__347__core_2Feval_2El__1491
___L__346__core_2Feval_2El__1491:
	movl __3Cundefined_3E,%eax
___L__347__core_2Feval_2El__1491:
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__344__core_2Feval_2El__1491
___L__350__core_2Feval_2El__1492:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,_opt__verbose
	jmp ___L__345__core_2Feval_2El__1491
___L__344__core_2Feval_2El__1491:
___L__351__core_2Feval_2El__1493:
	movl _opt__verbose,%eax
	movl %eax,20(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__345__core_2Feval_2El__1491:
	addl $56,%esp
	leave
	ret
## defn subr_long_string
subr_long_string
	.text
___L__352__core_2Feval_2El__1493:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__353__core_2Feval_2El__1479:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__354__core_2Feval_2El__1480:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__357__core_2Feval_2El__1480
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__359__core_2Feval_2El__1480
	movl __3Clong_3E,%eax
	jmp ___L__360__core_2Feval_2El__1480
___L__359__core_2Feval_2El__1480:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__360__core_2Feval_2El__1480:
	jmp ___L__358__core_2Feval_2El__1480
___L__357__core_2Feval_2El__1480:
	movl __3Cundefined_3E,%eax
___L__358__core_2Feval_2El__1480:
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__355__core_2Feval_2El__1480
	movl 16(%esp),%eax
	jmp ___L__356__core_2Feval_2El__1480
___L__355__core_2Feval_2El__1480:
___L__361__core_2Feval_2El__1482:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__363__core_2Feval_2El__1482
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__365__core_2Feval_2El__1482
	movl __3Clong_3E,%eax
	jmp ___L__366__core_2Feval_2El__1482
___L__365__core_2Feval_2El__1482:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__366__core_2Feval_2El__1482:
	jmp ___L__364__core_2Feval_2El__1482
___L__363__core_2Feval_2El__1482:
	movl __3Cundefined_3E,%eax
___L__364__core_2Feval_2El__1482:
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__362__core_2Feval_2El__1482
___L__367__core_2Feval_2El__1483:
	movl $32,%eax
	movl %eax,20(%esp)
	movl _malloc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__368__core_2Feval_2El__1484:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	.data
___L__369__core_2Feval_2El__1484:
	.asciz "%ld"
	.text
	movl $___L__369__core_2Feval_2El__1484,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl _sprintf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__370__core_2Feval_2El__1485:
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl _new_2D_3Cstring_3E,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__371__core_2Feval_2El__1486:
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl _free_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 32(%esp),%eax
___L__362__core_2Feval_2El__1482:
___L__356__core_2Feval_2El__1480:
	addl $56,%esp
	leave
	ret
## defn subr_symbol_string
subr_symbol_string
	.text
___L__372__core_2Feval_2El__1486:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__373__core_2Feval_2El__1472:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__374__core_2Feval_2El__1473:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__377__core_2Feval_2El__1473
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__379__core_2Feval_2El__1473
	movl __3Clong_3E,%eax
	jmp ___L__380__core_2Feval_2El__1473
___L__379__core_2Feval_2El__1473:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__380__core_2Feval_2El__1473:
	jmp ___L__378__core_2Feval_2El__1473
___L__377__core_2Feval_2El__1473:
	movl __3Cundefined_3E,%eax
___L__378__core_2Feval_2El__1473:
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__375__core_2Feval_2El__1473
	movl 16(%esp),%eax
	jmp ___L__376__core_2Feval_2El__1473
___L__375__core_2Feval_2El__1473:
___L__381__core_2Feval_2El__1475:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__383__core_2Feval_2El__1475
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__385__core_2Feval_2El__1475
	movl __3Clong_3E,%eax
	jmp ___L__386__core_2Feval_2El__1475
___L__385__core_2Feval_2El__1475:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__386__core_2Feval_2El__1475:
	jmp ___L__384__core_2Feval_2El__1475
___L__383__core_2Feval_2El__1475:
	movl __3Cundefined_3E,%eax
___L__384__core_2Feval_2El__1475:
	movl %eax,20(%esp)
	movl __3Csymbol_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__382__core_2Feval_2El__1475
___L__387__core_2Feval_2El__1476:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Cstring_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__382__core_2Feval_2El__1475:
___L__376__core_2Feval_2El__1473:
	addl $56,%esp
	leave
	ret
## defn subr_string_symbol
subr_string_symbol
	.text
___L__388__core_2Feval_2El__1476:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__389__core_2Feval_2El__1465:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__390__core_2Feval_2El__1466:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__393__core_2Feval_2El__1466
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__395__core_2Feval_2El__1466
	movl __3Clong_3E,%eax
	jmp ___L__396__core_2Feval_2El__1466
___L__395__core_2Feval_2El__1466:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__396__core_2Feval_2El__1466:
	jmp ___L__394__core_2Feval_2El__1466
___L__393__core_2Feval_2El__1466:
	movl __3Cundefined_3E,%eax
___L__394__core_2Feval_2El__1466:
	movl %eax,20(%esp)
	movl __3Csymbol_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__391__core_2Feval_2El__1466
	movl 16(%esp),%eax
	jmp ___L__392__core_2Feval_2El__1466
___L__391__core_2Feval_2El__1466:
___L__397__core_2Feval_2El__1468:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__399__core_2Feval_2El__1468
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__401__core_2Feval_2El__1468
	movl __3Clong_3E,%eax
	jmp ___L__402__core_2Feval_2El__1468
___L__401__core_2Feval_2El__1468:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__402__core_2Feval_2El__1468:
	jmp ___L__400__core_2Feval_2El__1468
___L__399__core_2Feval_2El__1468:
	movl __3Cundefined_3E,%eax
___L__400__core_2Feval_2El__1468:
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__398__core_2Feval_2El__1468
___L__403__core_2Feval_2El__1469:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl _intern,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__398__core_2Feval_2El__1468:
___L__392__core_2Feval_2El__1466:
	addl $56,%esp
	leave
	ret
## defn subr_set_string_at
subr_set_string_at
	.text
___L__404__core_2Feval_2El__1469:
## frame 16 40 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__405__core_2Feval_2El__1453:
	.data
___L__406__core_2Feval_2El__1453:
	.asciz "set-string-at"
	.text
	movl $___L__406__core_2Feval_2El__1453,%eax
	movl %eax,16(%esp)
	movl 80(%esp),%eax
	movl %eax,20(%esp)
	movl _arity3,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__407__core_2Feval_2El__1454:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 80(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__408__core_2Feval_2El__1455:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 80(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__409__core_2Feval_2El__1456:
	movl $0,%eax
	movl %eax,24(%esp)
	movl $1,%eax
	movl %eax,28(%esp)
	movl $1,%eax
	movl %eax,32(%esp)
	movl 80(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__410__core_2Feval_2El__1457:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__412__core_2Feval_2El__1457
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__414__core_2Feval_2El__1457
	movl __3Clong_3E,%eax
	jmp ___L__415__core_2Feval_2El__1457
___L__414__core_2Feval_2El__1457:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__415__core_2Feval_2El__1457:
	jmp ___L__413__core_2Feval_2El__1457
___L__412__core_2Feval_2El__1457:
	movl __3Cundefined_3E,%eax
___L__413__core_2Feval_2El__1457:
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__411__core_2Feval_2El__1457
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__416__core_2Feval_2El__1457
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__418__core_2Feval_2El__1457
	movl __3Clong_3E,%eax
	jmp ___L__419__core_2Feval_2El__1457
___L__418__core_2Feval_2El__1457:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__419__core_2Feval_2El__1457:
	jmp ___L__417__core_2Feval_2El__1457
___L__416__core_2Feval_2El__1457:
	movl __3Cundefined_3E,%eax
___L__417__core_2Feval_2El__1457:
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__411__core_2Feval_2El__1457
___L__420__core_2Feval_2El__1458:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
___L__421__core_2Feval_2El__1459:
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	cmpl 32(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__422__core_2Feval_2El__1459
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl _k__string__length,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	cmpl 32(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__422__core_2Feval_2El__1459
___L__423__core_2Feval_2El__1460:
___L__424__core_2Feval_2El__1461:
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl 20(%esp),%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,36(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,48(%esp)
	movl 44(%esp),%eax
	movl %eax,52(%esp)
	movl __25typecheck,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 52(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx),%ecx
	movl 32(%esp),%eax
	movb %al,(%ecx)
	movl 24(%esp),%eax
___L__422__core_2Feval_2El__1459:
___L__411__core_2Feval_2El__1457:
	addl $72,%esp
	leave
	ret
## defn subr_string_at
subr_string_at
	.text
___L__425__core_2Feval_2El__1461:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__426__core_2Feval_2El__1444:
	.data
___L__427__core_2Feval_2El__1444:
	.asciz "string-at"
	.text
	movl $___L__427__core_2Feval_2El__1444,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__428__core_2Feval_2El__1445:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__429__core_2Feval_2El__1446:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__430__core_2Feval_2El__1447:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__432__core_2Feval_2El__1447
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__434__core_2Feval_2El__1447
	movl __3Clong_3E,%eax
	jmp ___L__435__core_2Feval_2El__1447
___L__434__core_2Feval_2El__1447:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__435__core_2Feval_2El__1447:
	jmp ___L__433__core_2Feval_2El__1447
___L__432__core_2Feval_2El__1447:
	movl __3Cundefined_3E,%eax
___L__433__core_2Feval_2El__1447:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__431__core_2Feval_2El__1447
___L__436__core_2Feval_2El__1448:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__437__core_2Feval_2El__1449:
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	cmpl 28(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__438__core_2Feval_2El__1449
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl _k__string__length,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	cmpl 28(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__438__core_2Feval_2El__1449
___L__439__core_2Feval_2El__1450:
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx),%ecx
	xorl %eax,%eax
	movb (%ecx),%al
	movl %eax,28(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__438__core_2Feval_2El__1449:
___L__431__core_2Feval_2El__1447:
	addl $56,%esp
	leave
	ret
## defn subr_string_length
subr_string_length
	.text
___L__440__core_2Feval_2El__1450:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__441__core_2Feval_2El__1439:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__442__core_2Feval_2El__1440:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__444__core_2Feval_2El__1440
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__446__core_2Feval_2El__1440
	movl __3Clong_3E,%eax
	jmp ___L__447__core_2Feval_2El__1440
___L__446__core_2Feval_2El__1440:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__447__core_2Feval_2El__1440:
	jmp ___L__445__core_2Feval_2El__1440
___L__444__core_2Feval_2El__1440:
	movl __3Cundefined_3E,%eax
___L__445__core_2Feval_2El__1440:
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__443__core_2Feval_2El__1440
___L__448__core_2Feval_2El__1441:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__443__core_2Feval_2El__1440:
	addl $56,%esp
	leave
	ret
## defn subr_set_array_at
subr_set_array_at
	.text
___L__449__core_2Feval_2El__1441:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__450__core_2Feval_2El__1431:
	.data
___L__451__core_2Feval_2El__1431:
	.asciz "set-array-at"
	.text
	movl $___L__451__core_2Feval_2El__1431,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity3,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__452__core_2Feval_2El__1432:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__453__core_2Feval_2El__1433:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__454__core_2Feval_2El__1434:
	movl $0,%eax
	movl %eax,24(%esp)
	movl $1,%eax
	movl %eax,28(%esp)
	movl $1,%eax
	movl %eax,32(%esp)
	movl 64(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__455__core_2Feval_2El__1435:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__457__core_2Feval_2El__1435
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__459__core_2Feval_2El__1435
	movl __3Clong_3E,%eax
	jmp ___L__460__core_2Feval_2El__1435
___L__459__core_2Feval_2El__1435:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__460__core_2Feval_2El__1435:
	jmp ___L__458__core_2Feval_2El__1435
___L__457__core_2Feval_2El__1435:
	movl __3Cundefined_3E,%eax
___L__458__core_2Feval_2El__1435:
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__456__core_2Feval_2El__1435
___L__461__core_2Feval_2El__1436:
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl _k__set__array__at,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__456__core_2Feval_2El__1435:
	addl $56,%esp
	leave
	ret
## defn subr_array_at
subr_array_at
	.text
___L__462__core_2Feval_2El__1436:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__463__core_2Feval_2El__1424:
	.data
___L__464__core_2Feval_2El__1424:
	.asciz "array-at"
	.text
	movl $___L__464__core_2Feval_2El__1424,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__465__core_2Feval_2El__1425:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__466__core_2Feval_2El__1426:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__467__core_2Feval_2El__1427:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__469__core_2Feval_2El__1427
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__471__core_2Feval_2El__1427
	movl __3Clong_3E,%eax
	jmp ___L__472__core_2Feval_2El__1427
___L__471__core_2Feval_2El__1427:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__472__core_2Feval_2El__1427:
	jmp ___L__470__core_2Feval_2El__1427
___L__469__core_2Feval_2El__1427:
	movl __3Cundefined_3E,%eax
___L__470__core_2Feval_2El__1427:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__468__core_2Feval_2El__1427
___L__473__core_2Feval_2El__1428:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl _k__array__at,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__468__core_2Feval_2El__1427:
	addl $56,%esp
	leave
	ret
## defn subr_array_length
subr_array_length
	.text
___L__474__core_2Feval_2El__1428:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__475__core_2Feval_2El__1421:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _k__array__length,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_set_oop_at
subr_set_oop_at
	.text
___L__476__core_2Feval_2El__1421:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__477__core_2Feval_2El__1411:
	.data
___L__478__core_2Feval_2El__1411:
	.asciz "set-oop-at"
	.text
	movl $___L__478__core_2Feval_2El__1411,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity3,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__479__core_2Feval_2El__1412:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__480__core_2Feval_2El__1413:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__481__core_2Feval_2El__1414:
	movl $0,%eax
	movl %eax,24(%esp)
	movl $1,%eax
	movl %eax,28(%esp)
	movl $1,%eax
	movl %eax,32(%esp)
	movl 64(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__482__core_2Feval_2El__1415:
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__483__core_2Feval_2El__1415
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__484__core_2Feval_2El__1415
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__486__core_2Feval_2El__1415
	movl __3Clong_3E,%eax
	jmp ___L__487__core_2Feval_2El__1415
___L__486__core_2Feval_2El__1415:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__487__core_2Feval_2El__1415:
	jmp ___L__485__core_2Feval_2El__1415
___L__484__core_2Feval_2El__1415:
	movl __3Cundefined_3E,%eax
___L__485__core_2Feval_2El__1415:
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__483__core_2Feval_2El__1415
___L__488__core_2Feval_2El__1416:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__489__core_2Feval_2El__1416
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__491__core_2Feval_2El__1416
	movl __3Clong_3E,%eax
	jmp ___L__492__core_2Feval_2El__1416
___L__491__core_2Feval_2El__1416:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__492__core_2Feval_2El__1416:
	jmp ___L__490__core_2Feval_2El__1416
___L__489__core_2Feval_2El__1416:
	movl __3Cundefined_3E,%eax
___L__490__core_2Feval_2El__1416:
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__483__core_2Feval_2El__1415
___L__493__core_2Feval_2El__1417:
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 28(%esp),%eax
	movl %eax,(%ecx)
___L__483__core_2Feval_2El__1415:
	movl 24(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn subr_oop_at
subr_oop_at
	.text
___L__494__core_2Feval_2El__1417:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__495__core_2Feval_2El__1403:
	.data
___L__496__core_2Feval_2El__1403:
	.asciz "oop-at"
	.text
	movl $___L__496__core_2Feval_2El__1403,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__497__core_2Feval_2El__1404:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__498__core_2Feval_2El__1405:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__499__core_2Feval_2El__1406:
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__500__core_2Feval_2El__1406
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__501__core_2Feval_2El__1406
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__503__core_2Feval_2El__1406
	movl __3Clong_3E,%eax
	jmp ___L__504__core_2Feval_2El__1406
___L__503__core_2Feval_2El__1406:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__504__core_2Feval_2El__1406:
	jmp ___L__502__core_2Feval_2El__1406
___L__501__core_2Feval_2El__1406:
	movl __3Cundefined_3E,%eax
___L__502__core_2Feval_2El__1406:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__500__core_2Feval_2El__1406
___L__505__core_2Feval_2El__1407:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__506__core_2Feval_2El__1407
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__508__core_2Feval_2El__1407
	movl __3Clong_3E,%eax
	jmp ___L__509__core_2Feval_2El__1407
___L__508__core_2Feval_2El__1407:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__509__core_2Feval_2El__1407:
	jmp ___L__507__core_2Feval_2El__1407
___L__506__core_2Feval_2El__1407:
	movl __3Cundefined_3E,%eax
___L__507__core_2Feval_2El__1407:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__500__core_2Feval_2El__1406
___L__510__core_2Feval_2El__1408:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__500__core_2Feval_2El__1406:
	addl $56,%esp
	leave
	ret
## defn subr_set_cdr
subr_set_cdr
	.text
___L__511__core_2Feval_2El__1408:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__512__core_2Feval_2El__1398:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__513__core_2Feval_2El__1399:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__515__core_2Feval_2El__1399
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__517__core_2Feval_2El__1399
	movl __3Clong_3E,%eax
	jmp ___L__518__core_2Feval_2El__1399
___L__517__core_2Feval_2El__1399:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__518__core_2Feval_2El__1399:
	jmp ___L__516__core_2Feval_2El__1399
___L__515__core_2Feval_2El__1399:
	movl __3Cundefined_3E,%eax
___L__516__core_2Feval_2El__1399:
	movl %eax,20(%esp)
	movl __3Cpair_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__514__core_2Feval_2El__1399
___L__519__core_2Feval_2El__1400:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _k__cadr,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cpair_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 24(%esp),%eax
	movl %eax,(%ecx)
___L__514__core_2Feval_2El__1399:
	addl $56,%esp
	leave
	ret
## defn subr_set_car
subr_set_car
	.text
___L__520__core_2Feval_2El__1400:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__521__core_2Feval_2El__1393:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__522__core_2Feval_2El__1394:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__524__core_2Feval_2El__1394
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__526__core_2Feval_2El__1394
	movl __3Clong_3E,%eax
	jmp ___L__527__core_2Feval_2El__1394
___L__526__core_2Feval_2El__1394:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__527__core_2Feval_2El__1394:
	jmp ___L__525__core_2Feval_2El__1394
___L__524__core_2Feval_2El__1394:
	movl __3Cundefined_3E,%eax
___L__525__core_2Feval_2El__1394:
	movl %eax,20(%esp)
	movl __3Cpair_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__523__core_2Feval_2El__1394
___L__528__core_2Feval_2El__1395:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _k__cadr,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Cpair_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 24(%esp),%eax
	movl %eax,(%ecx)
___L__523__core_2Feval_2El__1394:
	addl $56,%esp
	leave
	ret
## defn subr_cdr
subr_cdr
	.text
___L__529__core_2Feval_2El__1395:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__530__core_2Feval_2El__1390:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _k__cdr,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_car
subr_car
	.text
___L__531__core_2Feval_2El__1390:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__532__core_2Feval_2El__1389:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_arrayP
subr_arrayP
	.text
___L__533__core_2Feval_2El__1389:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__534__core_2Feval_2El__1388:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__536__core_2Feval_2El__1388
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__538__core_2Feval_2El__1388
	movl __3Clong_3E,%eax
	jmp ___L__539__core_2Feval_2El__1388
___L__538__core_2Feval_2El__1388:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__539__core_2Feval_2El__1388:
	jmp ___L__537__core_2Feval_2El__1388
___L__536__core_2Feval_2El__1388:
	movl __3Cundefined_3E,%eax
___L__537__core_2Feval_2El__1388:
	movl %eax,16(%esp)
	movl __3Carray_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__535__core_2Feval_2El__1388
	movl _s__t,%eax
___L__535__core_2Feval_2El__1388:
	addl $40,%esp
	leave
	ret
## defn subr_pairP
subr_pairP
	.text
___L__540__core_2Feval_2El__1388:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__541__core_2Feval_2El__1387:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__543__core_2Feval_2El__1387
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__545__core_2Feval_2El__1387
	movl __3Clong_3E,%eax
	jmp ___L__546__core_2Feval_2El__1387
___L__545__core_2Feval_2El__1387:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__546__core_2Feval_2El__1387:
	jmp ___L__544__core_2Feval_2El__1387
___L__543__core_2Feval_2El__1387:
	movl __3Cundefined_3E,%eax
___L__544__core_2Feval_2El__1387:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__542__core_2Feval_2El__1387
	movl _s__t,%eax
___L__542__core_2Feval_2El__1387:
	addl $40,%esp
	leave
	ret
## defn subr_symbolP
subr_symbolP
	.text
___L__547__core_2Feval_2El__1387:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__548__core_2Feval_2El__1386:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__550__core_2Feval_2El__1386
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__552__core_2Feval_2El__1386
	movl __3Clong_3E,%eax
	jmp ___L__553__core_2Feval_2El__1386
___L__552__core_2Feval_2El__1386:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__553__core_2Feval_2El__1386:
	jmp ___L__551__core_2Feval_2El__1386
___L__550__core_2Feval_2El__1386:
	movl __3Cundefined_3E,%eax
___L__551__core_2Feval_2El__1386:
	movl %eax,16(%esp)
	movl __3Csymbol_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__549__core_2Feval_2El__1386
	movl _s__t,%eax
___L__549__core_2Feval_2El__1386:
	addl $40,%esp
	leave
	ret
## defn subr_stringP
subr_stringP
	.text
___L__554__core_2Feval_2El__1386:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__555__core_2Feval_2El__1385:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__557__core_2Feval_2El__1385
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__559__core_2Feval_2El__1385
	movl __3Clong_3E,%eax
	jmp ___L__560__core_2Feval_2El__1385
___L__559__core_2Feval_2El__1385:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__560__core_2Feval_2El__1385:
	jmp ___L__558__core_2Feval_2El__1385
___L__557__core_2Feval_2El__1385:
	movl __3Cundefined_3E,%eax
___L__558__core_2Feval_2El__1385:
	movl %eax,16(%esp)
	movl __3Cstring_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__556__core_2Feval_2El__1385
	movl _s__t,%eax
___L__556__core_2Feval_2El__1385:
	addl $40,%esp
	leave
	ret
## defn subr_type_of
subr_type_of
	.text
___L__561__core_2Feval_2El__1385:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__562__core_2Feval_2El__1384:
	movl 48(%esp),%eax
	cmpl $0,%eax
	je ___L__563__core_2Feval_2El__1384
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__564__core_2Feval_2El__1384
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__566__core_2Feval_2El__1384
	movl __3Clong_3E,%eax
	jmp ___L__567__core_2Feval_2El__1384
___L__566__core_2Feval_2El__1384:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__567__core_2Feval_2El__1384:
	jmp ___L__565__core_2Feval_2El__1384
___L__564__core_2Feval_2El__1384:
	movl __3Cundefined_3E,%eax
___L__565__core_2Feval_2El__1384:
	movl %eax,16(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__563__core_2Feval_2El__1384:
	addl $40,%esp
	leave
	ret
## defn subr_allocate
subr_allocate
	.text
___L__568__core_2Feval_2El__1384:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__569__core_2Feval_2El__1378:
	.data
___L__570__core_2Feval_2El__1378:
	.asciz "allocate"
	.text
	movl $___L__570__core_2Feval_2El__1378,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__571__core_2Feval_2El__1379:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__572__core_2Feval_2El__1380:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__573__core_2Feval_2El__1381:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__575__core_2Feval_2El__1381
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__577__core_2Feval_2El__1381
	movl __3Clong_3E,%eax
	jmp ___L__578__core_2Feval_2El__1381
___L__577__core_2Feval_2El__1381:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__578__core_2Feval_2El__1381:
	jmp ___L__576__core_2Feval_2El__1381
___L__575__core_2Feval_2El__1381:
	movl __3Cundefined_3E,%eax
___L__576__core_2Feval_2El__1381:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__574__core_2Feval_2El__1381
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__579__core_2Feval_2El__1381
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__581__core_2Feval_2El__1381
	movl __3Clong_3E,%eax
	jmp ___L__582__core_2Feval_2El__1381
___L__581__core_2Feval_2El__1381:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__582__core_2Feval_2El__1381:
	jmp ___L__580__core_2Feval_2El__1381
___L__579__core_2Feval_2El__1381:
	movl __3Cundefined_3E,%eax
___L__580__core_2Feval_2El__1381:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__574__core_2Feval_2El__1381
___L__583__core_2Feval_2El__1382:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $4,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Clong_3E,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	mull 28(%esp)
	movl %eax,28(%esp)
	movl _new_2Doops,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__574__core_2Feval_2El__1381:
	addl $56,%esp
	leave
	ret
## defn subr_form
subr_form
	.text
___L__584__core_2Feval_2El__1382:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__585__core_2Feval_2El__1375:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl _new_2D_3Cform_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_array
subr_array
	.text
___L__586__core_2Feval_2El__1375:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__587__core_2Feval_2El__1374:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__589__core_2Feval_2El__1374
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__591__core_2Feval_2El__1374
	movl __3Clong_3E,%eax
	jmp ___L__592__core_2Feval_2El__1374
___L__591__core_2Feval_2El__1374:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__592__core_2Feval_2El__1374:
	jmp ___L__590__core_2Feval_2El__1374
___L__589__core_2Feval_2El__1374:
	movl __3Cundefined_3E,%eax
___L__590__core_2Feval_2El__1374:
	movl %eax,16(%esp)
	movl __3Clong_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__588__core_2Feval_2El__1374
	movl $0,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__588__core_2Feval_2El__1374:
	movl %eax,16(%esp)
	movl _new_2D_3Carray_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_string
subr_string
	.text
___L__593__core_2Feval_2El__1374:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__594__core_2Feval_2El__1373:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__596__core_2Feval_2El__1373
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__598__core_2Feval_2El__1373
	movl __3Clong_3E,%eax
	jmp ___L__599__core_2Feval_2El__1373
___L__598__core_2Feval_2El__1373:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__599__core_2Feval_2El__1373:
	jmp ___L__597__core_2Feval_2El__1373
___L__596__core_2Feval_2El__1373:
	movl __3Cundefined_3E,%eax
___L__597__core_2Feval_2El__1373:
	movl %eax,16(%esp)
	movl __3Clong_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__595__core_2Feval_2El__1373
	movl $0,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__595__core_2Feval_2El__1373:
	movl %eax,16(%esp)
	movl ___new_2D_3Cstring_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_cons
subr_cons
	.text
___L__600__core_2Feval_2El__1373:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__601__core_2Feval_2El__1372:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_expand
subr_expand
	.text
___L__602__core_2Feval_2El__1372:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__603__core_2Feval_2El__1368:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__604__core_2Feval_2El__1369:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__605__core_2Feval_2El__1369
___L__606__core_2Feval_2El__1370:
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__605__core_2Feval_2El__1369:
	movl %eax,20(%esp)
	movl _k__expand,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	addl $56,%esp
	leave
	ret
## defn subr_encode
subr_encode
	.text
___L__607__core_2Feval_2El__1370:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__608__core_2Feval_2El__1363:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__609__core_2Feval_2El__1364:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__610__core_2Feval_2El__1364
___L__611__core_2Feval_2El__1365:
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__610__core_2Feval_2El__1364:
	movl %eax,20(%esp)
	movl _k__encode,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	addl $56,%esp
	leave
	ret
## defn subr_eval
subr_eval
	.text
___L__612__core_2Feval_2El__1365:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__613__core_2Feval_2El__1353:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__614__core_2Feval_2El__1354:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__615__core_2Feval_2El__1354
	movl _globals,%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl _new_2D_3Cenv_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__615__core_2Feval_2El__1354:
	movl %eax,32(%esp)
___L__616__core_2Feval_2El__1355:
	leal 16(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__push__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 32(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__push__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__617__core_2Feval_2El__1356:
	movl $0,%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
	movl 32(%esp),%eax
	movl %eax,28(%esp)
	movl _new_2Dbase_2D_3Ccontext_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__618__core_2Feval_2El__1357:
	leal 28(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__push__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__619__core_2Feval_2El__1358:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 32(%esp),%eax
	movl %eax,24(%esp)
	movl _k__expand,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__620__core_2Feval_2El__1359:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 32(%esp),%eax
	movl %eax,20(%esp)
	movl _k__encode,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__621__core_2Feval_2El__1360:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 28(%esp),%eax
	movl %eax,24(%esp)
	movl _k__eval,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__622__core_2Feval_2El__1357:
	leal 28(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__pop__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 24(%esp),%eax
	movl %eax,28(%esp)
___L__623__core_2Feval_2El__1355:
	leal 32(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 16(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn subr_apply
subr_apply
	.text
___L__624__core_2Feval_2El__1355:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__625__core_2Feval_2El__1350:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _k__apply,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 24(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_warn
subr_warn
	.text
___L__626__core_2Feval_2El__1350:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__627__core_2Feval_2El__1341:
	jmp ___L__629__core_2Feval_2El__1341
___L__628__core_2Feval_2El__1341:
___L__630__core_2Feval_2El__1342:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__631__core_2Feval_2El__1343:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__632__core_2Feval_2El__1343
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__634__core_2Feval_2El__1343
	movl __3Clong_3E,%eax
	jmp ___L__635__core_2Feval_2El__1343
___L__634__core_2Feval_2El__1343:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__635__core_2Feval_2El__1343:
	jmp ___L__633__core_2Feval_2El__1343
___L__632__core_2Feval_2El__1343:
	movl __3Cundefined_3E,%eax
___L__633__core_2Feval_2El__1343:
	movl %eax,20(%esp)
___L__636__core_2Feval_2El__1344:
___L__639__core_2Feval_2El__1345:
	movl __3Cstring_3E,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__637__core_2Feval_2El__1344
	movl _stderr,%eax
	movl %eax,24(%esp)
	.data
___L__640__core_2Feval_2El__1345:
	.asciz "%s"
	.text
	movl $___L__640__core_2Feval_2El__1345,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,36(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl _fprintf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	jmp ___L__638__core_2Feval_2El__1344
___L__637__core_2Feval_2El__1344:
___L__641__core_2Feval_2El__1344:
___L__644__core_2Feval_2El__1346:
	movl __3Csymbol_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__642__core_2Feval_2El__1344
	movl _stderr,%eax
	movl %eax,32(%esp)
	.data
___L__645__core_2Feval_2El__1346:
	.asciz "%s"
	.text
	movl $___L__645__core_2Feval_2El__1346,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,44(%esp)
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl _fprintf_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 24(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	jmp ___L__643__core_2Feval_2El__1344
___L__642__core_2Feval_2El__1344:
	movl $0,%eax
___L__643__core_2Feval_2El__1344:
___L__638__core_2Feval_2El__1344:
___L__646__core_2Feval_2El__1347:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,64(%esp)
___L__629__core_2Feval_2El__1341:
___L__647__core_2Feval_2El__1341:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__648__core_2Feval_2El__1341
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__650__core_2Feval_2El__1341
	movl __3Clong_3E,%eax
	jmp ___L__651__core_2Feval_2El__1341
___L__650__core_2Feval_2El__1341:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__651__core_2Feval_2El__1341:
	jmp ___L__649__core_2Feval_2El__1341
___L__648__core_2Feval_2El__1341:
	movl __3Cundefined_3E,%eax
___L__649__core_2Feval_2El__1341:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__628__core_2Feval_2El__1341
	addl $56,%esp
	leave
	ret
## defn subr_print
subr_print
	.text
___L__652__core_2Feval_2El__1341:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__653__core_2Feval_2El__1336:
	jmp ___L__655__core_2Feval_2El__1336
___L__654__core_2Feval_2El__1336:
___L__656__core_2Feval_2El__1337:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl _k__print,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__657__core_2Feval_2El__1338:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
___L__655__core_2Feval_2El__1336:
___L__658__core_2Feval_2El__1336:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__659__core_2Feval_2El__1336
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__661__core_2Feval_2El__1336
	movl __3Clong_3E,%eax
	jmp ___L__662__core_2Feval_2El__1336
___L__661__core_2Feval_2El__1336:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__662__core_2Feval_2El__1336:
	jmp ___L__660__core_2Feval_2El__1336
___L__659__core_2Feval_2El__1336:
	movl __3Cundefined_3E,%eax
___L__660__core_2Feval_2El__1336:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__654__core_2Feval_2El__1336
	addl $40,%esp
	leave
	ret
## defn subr_dump
subr_dump
	.text
___L__663__core_2Feval_2El__1336:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__664__core_2Feval_2El__1331:
	jmp ___L__666__core_2Feval_2El__1331
___L__665__core_2Feval_2El__1331:
___L__667__core_2Feval_2El__1332:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl _k__dump,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__668__core_2Feval_2El__1333:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
___L__666__core_2Feval_2El__1331:
___L__669__core_2Feval_2El__1331:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__670__core_2Feval_2El__1331
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__672__core_2Feval_2El__1331
	movl __3Clong_3E,%eax
	jmp ___L__673__core_2Feval_2El__1331
___L__672__core_2Feval_2El__1331:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__673__core_2Feval_2El__1331:
	jmp ___L__671__core_2Feval_2El__1331
___L__670__core_2Feval_2El__1331:
	movl __3Cundefined_3E,%eax
___L__671__core_2Feval_2El__1331:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__665__core_2Feval_2El__1331
	addl $40,%esp
	leave
	ret
## defn subr_format
subr_format
	.text
___L__674__core_2Feval_2El__1331:
## frame 16 48 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__675__core_2Feval_2El__1302:
	.data
___L__676__core_2Feval_2El__1302:
	.asciz "format"
	.text
	movl $___L__676__core_2Feval_2El__1302,%eax
	movl %eax,16(%esp)
	movl 80(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__677__core_2Feval_2El__1303:
	movl 80(%esp),%eax
	movl %eax,20(%esp)
	movl _k__car,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__678__core_2Feval_2El__1304:
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl _k__cadr,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__679__core_2Feval_2El__1305:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__681__core_2Feval_2El__1305
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__683__core_2Feval_2El__1305
	movl __3Clong_3E,%eax
	jmp ___L__684__core_2Feval_2El__1305
___L__683__core_2Feval_2El__1305:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__684__core_2Feval_2El__1305:
	jmp ___L__682__core_2Feval_2El__1305
___L__681__core_2Feval_2El__1305:
	movl __3Cundefined_3E,%eax
___L__682__core_2Feval_2El__1305:
	movl %eax,24(%esp)
	movl __3Cstring_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__680__core_2Feval_2El__1305
	.data
___L__685__core_2Feval_2El__1305:
	.asciz "non-string format"
	.text
	movl $___L__685__core_2Feval_2El__1305,%eax
	movl %eax,24(%esp)
	movl _fatal,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__680__core_2Feval_2El__1305:
___L__686__core_2Feval_2El__1306:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__687__core_2Feval_2El__1307:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__688__core_2Feval_2El__1307
	movl $1,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	andl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__690__core_2Feval_2El__1307
	movl __3Clong_3E,%eax
	jmp ___L__691__core_2Feval_2El__1307
___L__690__core_2Feval_2El__1307:
	movl $-1,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__691__core_2Feval_2El__1307:
	jmp ___L__689__core_2Feval_2El__1307
___L__688__core_2Feval_2El__1307:
	movl __3Cundefined_3E,%eax
___L__689__core_2Feval_2El__1307:
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
___L__692__core_2Feval_2El__1309:
___L__695__core_2Feval_2El__1310:
	movl __3Cundefined_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__693__core_2Feval_2El__1309
	movl $0,%eax
	jmp ___L__694__core_2Feval_2El__1309
___L__693__core_2Feval_2El__1309:
___L__696__core_2Feval_2El__1309:
___L__699__core_2Feval_2El__1311:
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__697__core_2Feval_2El__1309
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Clong_3E,%eax
	movl %eax,44(%esp)
	movl 32(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	jmp ___L__698__core_2Feval_2El__1309
___L__697__core_2Feval_2El__1309:
___L__700__core_2Feval_2El__1309:
___L__703__core_2Feval_2El__1312:
	movl __3Cstring_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__701__core_2Feval_2El__1309
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,48(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	jmp ___L__702__core_2Feval_2El__1309
___L__701__core_2Feval_2El__1309:
___L__704__core_2Feval_2El__1309:
___L__707__core_2Feval_2El__1313:
	movl __3Csymbol_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__705__core_2Feval_2El__1309
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,44(%esp)
	movl 32(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	jmp ___L__706__core_2Feval_2El__1309
___L__705__core_2Feval_2El__1309:
___L__708__core_2Feval_2El__1314:
	movl 16(%esp),%eax
	movl %eax,36(%esp)
___L__706__core_2Feval_2El__1309:
___L__702__core_2Feval_2El__1309:
___L__698__core_2Feval_2El__1309:
___L__694__core_2Feval_2El__1309:
___L__709__core_2Feval_2El__1315:
	movl $100,%eax
	movl %eax,32(%esp)
	movl %eax,40(%esp)
	movl %eax,48(%esp)
___L__710__core_2Feval_2El__1316:
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl _malloc_24stub,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,40(%esp)
___L__711__core_2Feval_2El__1316:
___L__712__core_2Feval_2El__1317:
	jmp ___L__714__core_2Feval_2El__1317
___L__713__core_2Feval_2El__1317:
___L__715__core_2Feval_2El__1318:
	movl 40(%esp),%eax
	movl %eax,44(%esp)
	movl 32(%esp),%eax
	movl %eax,52(%esp)
	movl 24(%esp),%eax
	movl %eax,56(%esp)
	movl 36(%esp),%eax
	movl %eax,60(%esp)
	movl _snprintf_24stub,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 52(%esp),%ecx
	movl %ecx,4(%esp)
	movl 56(%esp),%ecx
	movl %ecx,8(%esp)
	movl 60(%esp),%ecx
	movl %ecx,12(%esp)
	call *%eax
	movl %eax,60(%esp)
___L__716__core_2Feval_2El__1319:
	movl 60(%esp),%eax
	movl %eax,56(%esp)
	movl $0,%eax
	cmpl 56(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__717__core_2Feval_2El__1319
	movl 32(%esp),%eax
	movl %eax,56(%esp)
	movl 60(%esp),%eax
	cmpl 56(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__717__core_2Feval_2El__1319
___L__718__core_2Feval_2El__1320:
	movl 40(%esp),%eax
	movl %eax,56(%esp)
	movl _new_2D_3Cstring_3E,%eax
	movl 56(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,56(%esp)
___L__719__core_2Feval_2El__1321:
	movl 40(%esp),%eax
	movl %eax,52(%esp)
	movl _free_24stub,%eax
	movl 52(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__720__core_2Feval_2El__1322:
	movl 56(%esp),%eax
	jmp ___L__721__core_2Feval_2El__1322
___L__717__core_2Feval_2El__1319:
___L__722__core_2Feval_2El__1323:
	movl $2,%eax
	movl %eax,56(%esp)
	movl 32(%esp),%eax
	mull 56(%esp)
	movl %eax,32(%esp)
___L__723__core_2Feval_2El__1324:
	movl 40(%esp),%eax
	movl %eax,60(%esp)
	movl 32(%esp),%eax
	movl %eax,56(%esp)
	movl _realloc_24stub,%eax
	movl 60(%esp),%ecx
	movl %ecx,0(%esp)
	movl 56(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,48(%esp)
	cmpl $0,%eax
	jne ___L__724__core_2Feval_2El__1324
___L__725__core_2Feval_2El__1325:
___L__726__core_2Feval_2El__1326:
	movl 40(%esp),%eax
	movl %eax,56(%esp)
	movl _free_24stub,%eax
	movl 56(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__727__core_2Feval_2El__1327:
	.data
___L__728__core_2Feval_2El__1327:
	.asciz "out of memory"
	.text
	movl $___L__728__core_2Feval_2El__1327,%eax
	jmp ___L__721__core_2Feval_2El__1322
___L__724__core_2Feval_2El__1324:
___L__729__core_2Feval_2El__1328:
	movl 48(%esp),%eax
	movl %eax,40(%esp)
___L__714__core_2Feval_2El__1317:
	movl $1,%eax
	cmpl $0,%eax
	jne ___L__713__core_2Feval_2El__1317
___L__721__core_2Feval_2El__1322:
	addl $72,%esp
	leave
	ret
## defn subr_putc
subr_putc
	.text
___L__730__core_2Feval_2El__1328:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__731__core_2Feval_2El__1294:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__732__core_2Feval_2El__1295:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__733__core_2Feval_2El__1296:
	movl 16(%esp),%eax
	cmpl $0,%eax
	jne ___L__734__core_2Feval_2El__1296
	movl _input,%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__734__core_2Feval_2El__1296:
___L__735__core_2Feval_2El__1297:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__737__core_2Feval_2El__1297
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__739__core_2Feval_2El__1297
	movl __3Clong_3E,%eax
	jmp ___L__740__core_2Feval_2El__1297
___L__739__core_2Feval_2El__1297:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__740__core_2Feval_2El__1297:
	jmp ___L__738__core_2Feval_2El__1297
___L__737__core_2Feval_2El__1297:
	movl __3Cundefined_3E,%eax
___L__738__core_2Feval_2El__1297:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__736__core_2Feval_2El__1297
	.data
___L__741__core_2Feval_2El__1297:
	.asciz "non-integer stream id in putc"
	.text
	movl $___L__741__core_2Feval_2El__1297,%eax
	movl %eax,24(%esp)
	movl _fatal,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__736__core_2Feval_2El__1297:
___L__742__core_2Feval_2El__1298:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__744__core_2Feval_2El__1298
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__746__core_2Feval_2El__1298
	movl __3Clong_3E,%eax
	jmp ___L__747__core_2Feval_2El__1298
___L__746__core_2Feval_2El__1298:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__747__core_2Feval_2El__1298:
	jmp ___L__745__core_2Feval_2El__1298
___L__744__core_2Feval_2El__1298:
	movl __3Cundefined_3E,%eax
___L__745__core_2Feval_2El__1298:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__743__core_2Feval_2El__1298
	.data
___L__748__core_2Feval_2El__1298:
	.asciz "non-integer character in putc"
	.text
	movl $___L__748__core_2Feval_2El__1298,%eax
	movl %eax,24(%esp)
	movl _fatal,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__743__core_2Feval_2El__1298:
___L__749__core_2Feval_2El__1299:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl _putc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $56,%esp
	leave
	ret
## defn subr_getc
subr_getc
	.text
___L__750__core_2Feval_2El__1299:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__751__core_2Feval_2El__1286:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__752__core_2Feval_2El__1287:
	movl 16(%esp),%eax
	cmpl $0,%eax
	jne ___L__753__core_2Feval_2El__1287
	movl _input,%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__753__core_2Feval_2El__1287:
___L__754__core_2Feval_2El__1288:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__756__core_2Feval_2El__1288
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__758__core_2Feval_2El__1288
	movl __3Clong_3E,%eax
	jmp ___L__759__core_2Feval_2El__1288
___L__758__core_2Feval_2El__1288:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__759__core_2Feval_2El__1288:
	jmp ___L__757__core_2Feval_2El__1288
___L__756__core_2Feval_2El__1288:
	movl __3Cundefined_3E,%eax
___L__757__core_2Feval_2El__1288:
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__755__core_2Feval_2El__1288
	.data
___L__760__core_2Feval_2El__1288:
	.asciz "non-integer stream id in getc"
	.text
	movl $___L__760__core_2Feval_2El__1288,%eax
	movl %eax,20(%esp)
	movl _fatal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__755__core_2Feval_2El__1288:
___L__761__core_2Feval_2El__1289:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__762__core_2Feval_2El__1290:
	movl $0,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	cmpl 24(%esp),%eax
	setge %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__763__core_2Feval_2El__1290
___L__764__core_2Feval_2El__1291:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__763__core_2Feval_2El__1290:
	addl $56,%esp
	leave
	ret
## defn subr_close
subr_close
	.text
___L__765__core_2Feval_2El__1291:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__766__core_2Feval_2El__1280:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__767__core_2Feval_2El__1281:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__769__core_2Feval_2El__1281
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__771__core_2Feval_2El__1281
	movl __3Clong_3E,%eax
	jmp ___L__772__core_2Feval_2El__1281
___L__771__core_2Feval_2El__1281:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__772__core_2Feval_2El__1281:
	jmp ___L__770__core_2Feval_2El__1281
___L__769__core_2Feval_2El__1281:
	movl __3Cundefined_3E,%eax
___L__770__core_2Feval_2El__1281:
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__768__core_2Feval_2El__1281
	.data
___L__773__core_2Feval_2El__1281:
	.asciz "non-integer argument in close"
	.text
	movl $___L__773__core_2Feval_2El__1281,%eax
	movl %eax,20(%esp)
	movl _fatal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__768__core_2Feval_2El__1281:
___L__774__core_2Feval_2El__1282:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl _fclose_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn subr_open
subr_open
	.text
___L__775__core_2Feval_2El__1282:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__776__core_2Feval_2El__1274:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__777__core_2Feval_2El__1275:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__779__core_2Feval_2El__1275
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__781__core_2Feval_2El__1275
	movl __3Clong_3E,%eax
	jmp ___L__782__core_2Feval_2El__1275
___L__781__core_2Feval_2El__1275:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__782__core_2Feval_2El__1275:
	jmp ___L__780__core_2Feval_2El__1275
___L__779__core_2Feval_2El__1275:
	movl __3Cundefined_3E,%eax
___L__780__core_2Feval_2El__1275:
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__778__core_2Feval_2El__1275
	.data
___L__783__core_2Feval_2El__1275:
	.asciz "non-string argument in open"
	.text
	movl $___L__783__core_2Feval_2El__1275,%eax
	movl %eax,20(%esp)
	movl _fatal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__778__core_2Feval_2El__1275:
___L__784__core_2Feval_2El__1276:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	.data
___L__785__core_2Feval_2El__1276:
	.asciz "rb"
	.text
	movl $___L__785__core_2Feval_2El__1276,%eax
	movl %eax,24(%esp)
	movl _fopen_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__786__core_2Feval_2El__1277:
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__787__core_2Feval_2El__1277
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__787__core_2Feval_2El__1277:
	addl $56,%esp
	leave
	ret
## defn subr_exit
subr_exit
	.text
___L__788__core_2Feval_2El__1277:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__789__core_2Feval_2El__1270:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__791__core_2Feval_2El__1270
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__793__core_2Feval_2El__1270
	movl __3Clong_3E,%eax
	jmp ___L__794__core_2Feval_2El__1270
___L__793__core_2Feval_2El__1270:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__794__core_2Feval_2El__1270:
	jmp ___L__792__core_2Feval_2El__1270
___L__791__core_2Feval_2El__1270:
	movl __3Cundefined_3E,%eax
___L__792__core_2Feval_2El__1270:
	movl %eax,16(%esp)
	movl __3Clong_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__790__core_2Feval_2El__1270
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__790__core_2Feval_2El__1270:
	movl %eax,16(%esp)
___L__795__core_2Feval_2El__1271:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _exit_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_abort
subr_abort
	.text
___L__796__core_2Feval_2El__1271:
## frame 0 0 0 16
	pushl %ebp
	movl %esp,%ebp
	subl $8,%esp
___L__797__core_2Feval_2El__1267:
	movl _abort_24stub,%eax
	call *%eax
	addl $8,%esp
	leave
	ret
## defn subr_ne
subr_ne
	.text
___L__798__core_2Feval_2El__1267:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__799__core_2Feval_2El__1257:
	.data
___L__800__core_2Feval_2El__1257:
	.asciz "!="
	.text
	movl $___L__800__core_2Feval_2El__1257,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__801__core_2Feval_2El__1258:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__802__core_2Feval_2El__1259:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__803__core_2Feval_2El__1258:
___L__804__core_2Feval_2El__1260:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__805__core_2Feval_2El__1260
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__807__core_2Feval_2El__1260
	movl __3Clong_3E,%eax
	jmp ___L__808__core_2Feval_2El__1260
___L__807__core_2Feval_2El__1260:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__808__core_2Feval_2El__1260:
	jmp ___L__806__core_2Feval_2El__1260
___L__805__core_2Feval_2El__1260:
	movl __3Cundefined_3E,%eax
___L__806__core_2Feval_2El__1260:
	movl %eax,24(%esp)
___L__809__core_2Feval_2El__1261:
___L__812__core_2Feval_2El__1262:
	movl __3Clong_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__810__core_2Feval_2El__1261
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__814__core_2Feval_2El__1262
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__816__core_2Feval_2El__1262
	movl __3Clong_3E,%eax
	jmp ___L__817__core_2Feval_2El__1262
___L__816__core_2Feval_2El__1262:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__817__core_2Feval_2El__1262:
	jmp ___L__815__core_2Feval_2El__1262
___L__814__core_2Feval_2El__1262:
	movl __3Cundefined_3E,%eax
___L__815__core_2Feval_2El__1262:
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__813__core_2Feval_2El__1262
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 28(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__813__core_2Feval_2El__1262
	movl _s__t,%eax
___L__813__core_2Feval_2El__1262:
	jmp ___L__811__core_2Feval_2El__1261
___L__810__core_2Feval_2El__1261:
___L__818__core_2Feval_2El__1261:
___L__821__core_2Feval_2El__1263:
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__819__core_2Feval_2El__1261
___L__822__core_2Feval_2El__1261:
___L__823__core_2Feval_2El__1263:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__825__core_2Feval_2El__1263
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__827__core_2Feval_2El__1263
	movl __3Clong_3E,%eax
	jmp ___L__828__core_2Feval_2El__1263
___L__827__core_2Feval_2El__1263:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__828__core_2Feval_2El__1263:
	jmp ___L__826__core_2Feval_2El__1263
___L__825__core_2Feval_2El__1263:
	movl __3Cundefined_3E,%eax
___L__826__core_2Feval_2El__1263:
	movl %eax,28(%esp)
	movl __3Cstring_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__824__core_2Feval_2El__1263
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,44(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl _strcmp_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__824__core_2Feval_2El__1263:
	movl _s__t,%eax
	jmp ___L__820__core_2Feval_2El__1261
___L__819__core_2Feval_2El__1261:
___L__829__core_2Feval_2El__1264:
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	cmpl 32(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__830__core_2Feval_2El__1264
	movl _s__t,%eax
___L__830__core_2Feval_2El__1264:
___L__820__core_2Feval_2El__1261:
___L__811__core_2Feval_2El__1261:
	addl $56,%esp
	leave
	ret
## defn subr_eq
subr_eq
	.text
___L__831__core_2Feval_2El__1264:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__832__core_2Feval_2El__1247:
	.data
___L__833__core_2Feval_2El__1247:
	.asciz "="
	.text
	movl $___L__833__core_2Feval_2El__1247,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__834__core_2Feval_2El__1248:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__835__core_2Feval_2El__1249:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__836__core_2Feval_2El__1248:
___L__837__core_2Feval_2El__1250:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__838__core_2Feval_2El__1250
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__840__core_2Feval_2El__1250
	movl __3Clong_3E,%eax
	jmp ___L__841__core_2Feval_2El__1250
___L__840__core_2Feval_2El__1250:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__841__core_2Feval_2El__1250:
	jmp ___L__839__core_2Feval_2El__1250
___L__838__core_2Feval_2El__1250:
	movl __3Cundefined_3E,%eax
___L__839__core_2Feval_2El__1250:
	movl %eax,24(%esp)
___L__842__core_2Feval_2El__1251:
___L__845__core_2Feval_2El__1252:
	movl __3Clong_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__843__core_2Feval_2El__1251
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__847__core_2Feval_2El__1252
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__849__core_2Feval_2El__1252
	movl __3Clong_3E,%eax
	jmp ___L__850__core_2Feval_2El__1252
___L__849__core_2Feval_2El__1252:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__850__core_2Feval_2El__1252:
	jmp ___L__848__core_2Feval_2El__1252
___L__847__core_2Feval_2El__1252:
	movl __3Cundefined_3E,%eax
___L__848__core_2Feval_2El__1252:
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__846__core_2Feval_2El__1252
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__846__core_2Feval_2El__1252
	movl _s__t,%eax
___L__846__core_2Feval_2El__1252:
	jmp ___L__844__core_2Feval_2El__1251
___L__843__core_2Feval_2El__1251:
___L__851__core_2Feval_2El__1251:
___L__854__core_2Feval_2El__1253:
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__852__core_2Feval_2El__1251
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__856__core_2Feval_2El__1253
	movl $1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	andl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__858__core_2Feval_2El__1253
	movl __3Clong_3E,%eax
	jmp ___L__859__core_2Feval_2El__1253
___L__858__core_2Feval_2El__1253:
	movl $-1,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__859__core_2Feval_2El__1253:
	jmp ___L__857__core_2Feval_2El__1253
___L__856__core_2Feval_2El__1253:
	movl __3Cundefined_3E,%eax
___L__857__core_2Feval_2El__1253:
	movl %eax,28(%esp)
	movl __3Cstring_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__855__core_2Feval_2El__1253
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,44(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl _strcmp_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	cmpl $0,%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__855__core_2Feval_2El__1253
	movl _s__t,%eax
___L__855__core_2Feval_2El__1253:
	jmp ___L__853__core_2Feval_2El__1251
___L__852__core_2Feval_2El__1251:
___L__860__core_2Feval_2El__1254:
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__861__core_2Feval_2El__1254
	movl _s__t,%eax
___L__861__core_2Feval_2El__1254:
___L__853__core_2Feval_2El__1251:
___L__844__core_2Feval_2El__1251:
	addl $56,%esp
	leave
	ret
## defn subr_gt
subr_gt
	.text
___L__862__core_2Feval_2El__1254:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__863__core_2Feval_2El__1244:
	.data
___L__864__core_2Feval_2El__1244:
	.asciz "gt"
	.text
	movl $___L__864__core_2Feval_2El__1244,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__868__core_2Feval_2El__1244
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__870__core_2Feval_2El__1244
	movl __3Clong_3E,%eax
	jmp ___L__871__core_2Feval_2El__1244
___L__870__core_2Feval_2El__1244:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__871__core_2Feval_2El__1244:
	jmp ___L__869__core_2Feval_2El__1244
___L__868__core_2Feval_2El__1244:
	movl __3Cundefined_3E,%eax
___L__869__core_2Feval_2El__1244:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__867__core_2Feval_2El__1244
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__872__core_2Feval_2El__1244
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__874__core_2Feval_2El__1244
	movl __3Clong_3E,%eax
	jmp ___L__875__core_2Feval_2El__1244
___L__874__core_2Feval_2El__1244:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__875__core_2Feval_2El__1244:
	jmp ___L__873__core_2Feval_2El__1244
___L__872__core_2Feval_2El__1244:
	movl __3Cundefined_3E,%eax
___L__873__core_2Feval_2El__1244:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__867__core_2Feval_2El__1244:
	cmpl $0,%eax
	je ___L__865__core_2Feval_2El__1244
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 24(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__876__core_2Feval_2El__1244
	movl _s__t,%eax
___L__876__core_2Feval_2El__1244:
	jmp ___L__866__core_2Feval_2El__1244
___L__865__core_2Feval_2El__1244:
	.data
___L__877__core_2Feval_2El__1244:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__877__core_2Feval_2El__1244,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__878__core_2Feval_2El__1244:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__878__core_2Feval_2El__1244,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__879__core_2Feval_2El__1244:
	.asciz "gt"
	.text
	movl $___L__879__core_2Feval_2El__1244,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__880__core_2Feval_2El__1244:
	.asciz " "
	.text
	movl $___L__880__core_2Feval_2El__1244,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__881__core_2Feval_2El__1244:
	.asciz " "
	.text
	movl $___L__881__core_2Feval_2El__1244,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__882__core_2Feval_2El__1244:
	.asciz ")"
	.text
	movl $___L__882__core_2Feval_2El__1244,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__883__core_2Feval_2El__1244:
	.asciz "\012"
	.text
	movl $___L__883__core_2Feval_2El__1244,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__866__core_2Feval_2El__1244:
	addl $56,%esp
	leave
	ret
## defn subr_ge
subr_ge
	.text
___L__884__core_2Feval_2El__1244:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__885__core_2Feval_2El__1243:
	.data
___L__886__core_2Feval_2El__1243:
	.asciz "ge"
	.text
	movl $___L__886__core_2Feval_2El__1243,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__890__core_2Feval_2El__1243
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__892__core_2Feval_2El__1243
	movl __3Clong_3E,%eax
	jmp ___L__893__core_2Feval_2El__1243
___L__892__core_2Feval_2El__1243:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__893__core_2Feval_2El__1243:
	jmp ___L__891__core_2Feval_2El__1243
___L__890__core_2Feval_2El__1243:
	movl __3Cundefined_3E,%eax
___L__891__core_2Feval_2El__1243:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__889__core_2Feval_2El__1243
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__894__core_2Feval_2El__1243
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__896__core_2Feval_2El__1243
	movl __3Clong_3E,%eax
	jmp ___L__897__core_2Feval_2El__1243
___L__896__core_2Feval_2El__1243:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__897__core_2Feval_2El__1243:
	jmp ___L__895__core_2Feval_2El__1243
___L__894__core_2Feval_2El__1243:
	movl __3Cundefined_3E,%eax
___L__895__core_2Feval_2El__1243:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__889__core_2Feval_2El__1243:
	cmpl $0,%eax
	je ___L__887__core_2Feval_2El__1243
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 24(%esp),%eax
	setge %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__898__core_2Feval_2El__1243
	movl _s__t,%eax
___L__898__core_2Feval_2El__1243:
	jmp ___L__888__core_2Feval_2El__1243
___L__887__core_2Feval_2El__1243:
	.data
___L__899__core_2Feval_2El__1243:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__899__core_2Feval_2El__1243,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__900__core_2Feval_2El__1243:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__900__core_2Feval_2El__1243,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__901__core_2Feval_2El__1243:
	.asciz "ge"
	.text
	movl $___L__901__core_2Feval_2El__1243,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__902__core_2Feval_2El__1243:
	.asciz " "
	.text
	movl $___L__902__core_2Feval_2El__1243,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__903__core_2Feval_2El__1243:
	.asciz " "
	.text
	movl $___L__903__core_2Feval_2El__1243,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__904__core_2Feval_2El__1243:
	.asciz ")"
	.text
	movl $___L__904__core_2Feval_2El__1243,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__905__core_2Feval_2El__1243:
	.asciz "\012"
	.text
	movl $___L__905__core_2Feval_2El__1243,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__888__core_2Feval_2El__1243:
	addl $56,%esp
	leave
	ret
## defn subr_le
subr_le
	.text
___L__906__core_2Feval_2El__1243:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__907__core_2Feval_2El__1242:
	.data
___L__908__core_2Feval_2El__1242:
	.asciz "le"
	.text
	movl $___L__908__core_2Feval_2El__1242,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__912__core_2Feval_2El__1242
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__914__core_2Feval_2El__1242
	movl __3Clong_3E,%eax
	jmp ___L__915__core_2Feval_2El__1242
___L__914__core_2Feval_2El__1242:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__915__core_2Feval_2El__1242:
	jmp ___L__913__core_2Feval_2El__1242
___L__912__core_2Feval_2El__1242:
	movl __3Cundefined_3E,%eax
___L__913__core_2Feval_2El__1242:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__911__core_2Feval_2El__1242
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__916__core_2Feval_2El__1242
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__918__core_2Feval_2El__1242
	movl __3Clong_3E,%eax
	jmp ___L__919__core_2Feval_2El__1242
___L__918__core_2Feval_2El__1242:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__919__core_2Feval_2El__1242:
	jmp ___L__917__core_2Feval_2El__1242
___L__916__core_2Feval_2El__1242:
	movl __3Cundefined_3E,%eax
___L__917__core_2Feval_2El__1242:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__911__core_2Feval_2El__1242:
	cmpl $0,%eax
	je ___L__909__core_2Feval_2El__1242
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 24(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__920__core_2Feval_2El__1242
	movl _s__t,%eax
___L__920__core_2Feval_2El__1242:
	jmp ___L__910__core_2Feval_2El__1242
___L__909__core_2Feval_2El__1242:
	.data
___L__921__core_2Feval_2El__1242:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__921__core_2Feval_2El__1242,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__922__core_2Feval_2El__1242:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__922__core_2Feval_2El__1242,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__923__core_2Feval_2El__1242:
	.asciz "le"
	.text
	movl $___L__923__core_2Feval_2El__1242,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__924__core_2Feval_2El__1242:
	.asciz " "
	.text
	movl $___L__924__core_2Feval_2El__1242,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__925__core_2Feval_2El__1242:
	.asciz " "
	.text
	movl $___L__925__core_2Feval_2El__1242,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__926__core_2Feval_2El__1242:
	.asciz ")"
	.text
	movl $___L__926__core_2Feval_2El__1242,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__927__core_2Feval_2El__1242:
	.asciz "\012"
	.text
	movl $___L__927__core_2Feval_2El__1242,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__910__core_2Feval_2El__1242:
	addl $56,%esp
	leave
	ret
## defn subr_lt
subr_lt
	.text
___L__928__core_2Feval_2El__1242:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__929__core_2Feval_2El__1241:
	.data
___L__930__core_2Feval_2El__1241:
	.asciz "lt"
	.text
	movl $___L__930__core_2Feval_2El__1241,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__934__core_2Feval_2El__1241
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__936__core_2Feval_2El__1241
	movl __3Clong_3E,%eax
	jmp ___L__937__core_2Feval_2El__1241
___L__936__core_2Feval_2El__1241:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__937__core_2Feval_2El__1241:
	jmp ___L__935__core_2Feval_2El__1241
___L__934__core_2Feval_2El__1241:
	movl __3Cundefined_3E,%eax
___L__935__core_2Feval_2El__1241:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__933__core_2Feval_2El__1241
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__938__core_2Feval_2El__1241
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__940__core_2Feval_2El__1241
	movl __3Clong_3E,%eax
	jmp ___L__941__core_2Feval_2El__1241
___L__940__core_2Feval_2El__1241:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__941__core_2Feval_2El__1241:
	jmp ___L__939__core_2Feval_2El__1241
___L__938__core_2Feval_2El__1241:
	movl __3Cundefined_3E,%eax
___L__939__core_2Feval_2El__1241:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__933__core_2Feval_2El__1241:
	cmpl $0,%eax
	je ___L__931__core_2Feval_2El__1241
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 24(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__942__core_2Feval_2El__1241
	movl _s__t,%eax
___L__942__core_2Feval_2El__1241:
	jmp ___L__932__core_2Feval_2El__1241
___L__931__core_2Feval_2El__1241:
	.data
___L__943__core_2Feval_2El__1241:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__943__core_2Feval_2El__1241,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__944__core_2Feval_2El__1241:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__944__core_2Feval_2El__1241,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__945__core_2Feval_2El__1241:
	.asciz "lt"
	.text
	movl $___L__945__core_2Feval_2El__1241,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__946__core_2Feval_2El__1241:
	.asciz " "
	.text
	movl $___L__946__core_2Feval_2El__1241,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__947__core_2Feval_2El__1241:
	.asciz " "
	.text
	movl $___L__947__core_2Feval_2El__1241,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__948__core_2Feval_2El__1241:
	.asciz ")"
	.text
	movl $___L__948__core_2Feval_2El__1241,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__949__core_2Feval_2El__1241:
	.asciz "\012"
	.text
	movl $___L__949__core_2Feval_2El__1241,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__932__core_2Feval_2El__1241:
	addl $56,%esp
	leave
	ret
## defn define-relation
define-relation
## defn subr_shr
subr_shr
	.text
___L__950__core_2Feval_2El__1241:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__951__core_2Feval_2El__1230:
	.data
___L__952__core_2Feval_2El__1230:
	.asciz "shr"
	.text
	movl $___L__952__core_2Feval_2El__1230,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__956__core_2Feval_2El__1230
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__958__core_2Feval_2El__1230
	movl __3Clong_3E,%eax
	jmp ___L__959__core_2Feval_2El__1230
___L__958__core_2Feval_2El__1230:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__959__core_2Feval_2El__1230:
	jmp ___L__957__core_2Feval_2El__1230
___L__956__core_2Feval_2El__1230:
	movl __3Cundefined_3E,%eax
___L__957__core_2Feval_2El__1230:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__955__core_2Feval_2El__1230
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__960__core_2Feval_2El__1230
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__962__core_2Feval_2El__1230
	movl __3Clong_3E,%eax
	jmp ___L__963__core_2Feval_2El__1230
___L__962__core_2Feval_2El__1230:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__963__core_2Feval_2El__1230:
	jmp ___L__961__core_2Feval_2El__1230
___L__960__core_2Feval_2El__1230:
	movl __3Cundefined_3E,%eax
___L__961__core_2Feval_2El__1230:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__955__core_2Feval_2El__1230:
	cmpl $0,%eax
	je ___L__953__core_2Feval_2El__1230
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 24(%esp),%ecx
	sarl %cl,%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__954__core_2Feval_2El__1230
___L__953__core_2Feval_2El__1230:
	.data
___L__964__core_2Feval_2El__1230:
	.asciz "%p %p\012"
	.text
	movl $___L__964__core_2Feval_2El__1230,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__965__core_2Feval_2El__1230:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__965__core_2Feval_2El__1230,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__966__core_2Feval_2El__1230:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__966__core_2Feval_2El__1230,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__967__core_2Feval_2El__1230:
	.asciz "shr"
	.text
	movl $___L__967__core_2Feval_2El__1230,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__968__core_2Feval_2El__1230:
	.asciz " "
	.text
	movl $___L__968__core_2Feval_2El__1230,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__969__core_2Feval_2El__1230:
	.asciz " "
	.text
	movl $___L__969__core_2Feval_2El__1230,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__970__core_2Feval_2El__1230:
	.asciz ")"
	.text
	movl $___L__970__core_2Feval_2El__1230,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__971__core_2Feval_2El__1230:
	.asciz "\012"
	.text
	movl $___L__971__core_2Feval_2El__1230,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__954__core_2Feval_2El__1230:
	addl $56,%esp
	leave
	ret
## defn subr_shl
subr_shl
	.text
___L__972__core_2Feval_2El__1230:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__973__core_2Feval_2El__1229:
	.data
___L__974__core_2Feval_2El__1229:
	.asciz "shl"
	.text
	movl $___L__974__core_2Feval_2El__1229,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__978__core_2Feval_2El__1229
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__980__core_2Feval_2El__1229
	movl __3Clong_3E,%eax
	jmp ___L__981__core_2Feval_2El__1229
___L__980__core_2Feval_2El__1229:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__981__core_2Feval_2El__1229:
	jmp ___L__979__core_2Feval_2El__1229
___L__978__core_2Feval_2El__1229:
	movl __3Cundefined_3E,%eax
___L__979__core_2Feval_2El__1229:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__977__core_2Feval_2El__1229
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__982__core_2Feval_2El__1229
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__984__core_2Feval_2El__1229
	movl __3Clong_3E,%eax
	jmp ___L__985__core_2Feval_2El__1229
___L__984__core_2Feval_2El__1229:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__985__core_2Feval_2El__1229:
	jmp ___L__983__core_2Feval_2El__1229
___L__982__core_2Feval_2El__1229:
	movl __3Cundefined_3E,%eax
___L__983__core_2Feval_2El__1229:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__977__core_2Feval_2El__1229:
	cmpl $0,%eax
	je ___L__975__core_2Feval_2El__1229
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 24(%esp),%ecx
	shll %cl,%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__976__core_2Feval_2El__1229
___L__975__core_2Feval_2El__1229:
	.data
___L__986__core_2Feval_2El__1229:
	.asciz "%p %p\012"
	.text
	movl $___L__986__core_2Feval_2El__1229,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__987__core_2Feval_2El__1229:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__987__core_2Feval_2El__1229,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__988__core_2Feval_2El__1229:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__988__core_2Feval_2El__1229,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__989__core_2Feval_2El__1229:
	.asciz "shl"
	.text
	movl $___L__989__core_2Feval_2El__1229,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__990__core_2Feval_2El__1229:
	.asciz " "
	.text
	movl $___L__990__core_2Feval_2El__1229,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__991__core_2Feval_2El__1229:
	.asciz " "
	.text
	movl $___L__991__core_2Feval_2El__1229,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__992__core_2Feval_2El__1229:
	.asciz ")"
	.text
	movl $___L__992__core_2Feval_2El__1229,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__993__core_2Feval_2El__1229:
	.asciz "\012"
	.text
	movl $___L__993__core_2Feval_2El__1229,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__976__core_2Feval_2El__1229:
	addl $56,%esp
	leave
	ret
## defn subr_div
subr_div
	.text
___L__994__core_2Feval_2El__1229:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__995__core_2Feval_2El__1228:
	.data
___L__996__core_2Feval_2El__1228:
	.asciz "div"
	.text
	movl $___L__996__core_2Feval_2El__1228,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1000__core_2Feval_2El__1228
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1002__core_2Feval_2El__1228
	movl __3Clong_3E,%eax
	jmp ___L__1003__core_2Feval_2El__1228
___L__1002__core_2Feval_2El__1228:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1003__core_2Feval_2El__1228:
	jmp ___L__1001__core_2Feval_2El__1228
___L__1000__core_2Feval_2El__1228:
	movl __3Cundefined_3E,%eax
___L__1001__core_2Feval_2El__1228:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__999__core_2Feval_2El__1228
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1004__core_2Feval_2El__1228
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1006__core_2Feval_2El__1228
	movl __3Clong_3E,%eax
	jmp ___L__1007__core_2Feval_2El__1228
___L__1006__core_2Feval_2El__1228:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1007__core_2Feval_2El__1228:
	jmp ___L__1005__core_2Feval_2El__1228
___L__1004__core_2Feval_2El__1228:
	movl __3Cundefined_3E,%eax
___L__1005__core_2Feval_2El__1228:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__999__core_2Feval_2El__1228:
	cmpl $0,%eax
	je ___L__997__core_2Feval_2El__1228
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl $0,%edx
	divl 24(%esp)
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__998__core_2Feval_2El__1228
___L__997__core_2Feval_2El__1228:
	.data
___L__1008__core_2Feval_2El__1228:
	.asciz "%p %p\012"
	.text
	movl $___L__1008__core_2Feval_2El__1228,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__1009__core_2Feval_2El__1228:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1009__core_2Feval_2El__1228,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1010__core_2Feval_2El__1228:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__1010__core_2Feval_2El__1228,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1011__core_2Feval_2El__1228:
	.asciz "div"
	.text
	movl $___L__1011__core_2Feval_2El__1228,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1012__core_2Feval_2El__1228:
	.asciz " "
	.text
	movl $___L__1012__core_2Feval_2El__1228,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1013__core_2Feval_2El__1228:
	.asciz " "
	.text
	movl $___L__1013__core_2Feval_2El__1228,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1014__core_2Feval_2El__1228:
	.asciz ")"
	.text
	movl $___L__1014__core_2Feval_2El__1228,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1015__core_2Feval_2El__1228:
	.asciz "\012"
	.text
	movl $___L__1015__core_2Feval_2El__1228,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__998__core_2Feval_2El__1228:
	addl $56,%esp
	leave
	ret
## defn subr_mul
subr_mul
	.text
___L__1016__core_2Feval_2El__1228:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1017__core_2Feval_2El__1227:
	.data
___L__1018__core_2Feval_2El__1227:
	.asciz "mul"
	.text
	movl $___L__1018__core_2Feval_2El__1227,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1022__core_2Feval_2El__1227
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1024__core_2Feval_2El__1227
	movl __3Clong_3E,%eax
	jmp ___L__1025__core_2Feval_2El__1227
___L__1024__core_2Feval_2El__1227:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1025__core_2Feval_2El__1227:
	jmp ___L__1023__core_2Feval_2El__1227
___L__1022__core_2Feval_2El__1227:
	movl __3Cundefined_3E,%eax
___L__1023__core_2Feval_2El__1227:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1021__core_2Feval_2El__1227
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1026__core_2Feval_2El__1227
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1028__core_2Feval_2El__1227
	movl __3Clong_3E,%eax
	jmp ___L__1029__core_2Feval_2El__1227
___L__1028__core_2Feval_2El__1227:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1029__core_2Feval_2El__1227:
	jmp ___L__1027__core_2Feval_2El__1227
___L__1026__core_2Feval_2El__1227:
	movl __3Cundefined_3E,%eax
___L__1027__core_2Feval_2El__1227:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1021__core_2Feval_2El__1227:
	cmpl $0,%eax
	je ___L__1019__core_2Feval_2El__1227
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	mull 24(%esp)
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1020__core_2Feval_2El__1227
___L__1019__core_2Feval_2El__1227:
	.data
___L__1030__core_2Feval_2El__1227:
	.asciz "%p %p\012"
	.text
	movl $___L__1030__core_2Feval_2El__1227,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__1031__core_2Feval_2El__1227:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1031__core_2Feval_2El__1227,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1032__core_2Feval_2El__1227:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__1032__core_2Feval_2El__1227,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1033__core_2Feval_2El__1227:
	.asciz "mul"
	.text
	movl $___L__1033__core_2Feval_2El__1227,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1034__core_2Feval_2El__1227:
	.asciz " "
	.text
	movl $___L__1034__core_2Feval_2El__1227,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1035__core_2Feval_2El__1227:
	.asciz " "
	.text
	movl $___L__1035__core_2Feval_2El__1227,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1036__core_2Feval_2El__1227:
	.asciz ")"
	.text
	movl $___L__1036__core_2Feval_2El__1227,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1037__core_2Feval_2El__1227:
	.asciz "\012"
	.text
	movl $___L__1037__core_2Feval_2El__1227,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1020__core_2Feval_2El__1227:
	addl $56,%esp
	leave
	ret
## defn subr_add
subr_add
	.text
___L__1038__core_2Feval_2El__1227:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1039__core_2Feval_2El__1226:
	.data
___L__1040__core_2Feval_2El__1226:
	.asciz "add"
	.text
	movl $___L__1040__core_2Feval_2El__1226,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1044__core_2Feval_2El__1226
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1046__core_2Feval_2El__1226
	movl __3Clong_3E,%eax
	jmp ___L__1047__core_2Feval_2El__1226
___L__1046__core_2Feval_2El__1226:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1047__core_2Feval_2El__1226:
	jmp ___L__1045__core_2Feval_2El__1226
___L__1044__core_2Feval_2El__1226:
	movl __3Cundefined_3E,%eax
___L__1045__core_2Feval_2El__1226:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1043__core_2Feval_2El__1226
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1048__core_2Feval_2El__1226
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1050__core_2Feval_2El__1226
	movl __3Clong_3E,%eax
	jmp ___L__1051__core_2Feval_2El__1226
___L__1050__core_2Feval_2El__1226:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1051__core_2Feval_2El__1226:
	jmp ___L__1049__core_2Feval_2El__1226
___L__1048__core_2Feval_2El__1226:
	movl __3Cundefined_3E,%eax
___L__1049__core_2Feval_2El__1226:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1043__core_2Feval_2El__1226:
	cmpl $0,%eax
	je ___L__1041__core_2Feval_2El__1226
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	addl 24(%esp),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1042__core_2Feval_2El__1226
___L__1041__core_2Feval_2El__1226:
	.data
___L__1052__core_2Feval_2El__1226:
	.asciz "%p %p\012"
	.text
	movl $___L__1052__core_2Feval_2El__1226,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__1053__core_2Feval_2El__1226:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1053__core_2Feval_2El__1226,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1054__core_2Feval_2El__1226:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__1054__core_2Feval_2El__1226,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1055__core_2Feval_2El__1226:
	.asciz "add"
	.text
	movl $___L__1055__core_2Feval_2El__1226,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1056__core_2Feval_2El__1226:
	.asciz " "
	.text
	movl $___L__1056__core_2Feval_2El__1226,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1057__core_2Feval_2El__1226:
	.asciz " "
	.text
	movl $___L__1057__core_2Feval_2El__1226,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1058__core_2Feval_2El__1226:
	.asciz ")"
	.text
	movl $___L__1058__core_2Feval_2El__1226,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1059__core_2Feval_2El__1226:
	.asciz "\012"
	.text
	movl $___L__1059__core_2Feval_2El__1226,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1042__core_2Feval_2El__1226:
	addl $56,%esp
	leave
	ret
## defn subr_bitxor
subr_bitxor
	.text
___L__1060__core_2Feval_2El__1226:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1061__core_2Feval_2El__1225:
	.data
___L__1062__core_2Feval_2El__1225:
	.asciz "bitxor"
	.text
	movl $___L__1062__core_2Feval_2El__1225,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1066__core_2Feval_2El__1225
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1068__core_2Feval_2El__1225
	movl __3Clong_3E,%eax
	jmp ___L__1069__core_2Feval_2El__1225
___L__1068__core_2Feval_2El__1225:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1069__core_2Feval_2El__1225:
	jmp ___L__1067__core_2Feval_2El__1225
___L__1066__core_2Feval_2El__1225:
	movl __3Cundefined_3E,%eax
___L__1067__core_2Feval_2El__1225:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1065__core_2Feval_2El__1225
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1070__core_2Feval_2El__1225
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1072__core_2Feval_2El__1225
	movl __3Clong_3E,%eax
	jmp ___L__1073__core_2Feval_2El__1225
___L__1072__core_2Feval_2El__1225:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1073__core_2Feval_2El__1225:
	jmp ___L__1071__core_2Feval_2El__1225
___L__1070__core_2Feval_2El__1225:
	movl __3Cundefined_3E,%eax
___L__1071__core_2Feval_2El__1225:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1065__core_2Feval_2El__1225:
	cmpl $0,%eax
	je ___L__1063__core_2Feval_2El__1225
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	xorl 24(%esp),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1064__core_2Feval_2El__1225
___L__1063__core_2Feval_2El__1225:
	.data
___L__1074__core_2Feval_2El__1225:
	.asciz "%p %p\012"
	.text
	movl $___L__1074__core_2Feval_2El__1225,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__1075__core_2Feval_2El__1225:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1075__core_2Feval_2El__1225,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1076__core_2Feval_2El__1225:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__1076__core_2Feval_2El__1225,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1077__core_2Feval_2El__1225:
	.asciz "bitxor"
	.text
	movl $___L__1077__core_2Feval_2El__1225,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1078__core_2Feval_2El__1225:
	.asciz " "
	.text
	movl $___L__1078__core_2Feval_2El__1225,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1079__core_2Feval_2El__1225:
	.asciz " "
	.text
	movl $___L__1079__core_2Feval_2El__1225,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1080__core_2Feval_2El__1225:
	.asciz ")"
	.text
	movl $___L__1080__core_2Feval_2El__1225,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1081__core_2Feval_2El__1225:
	.asciz "\012"
	.text
	movl $___L__1081__core_2Feval_2El__1225,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1064__core_2Feval_2El__1225:
	addl $56,%esp
	leave
	ret
## defn subr_bitor
subr_bitor
	.text
___L__1082__core_2Feval_2El__1225:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1083__core_2Feval_2El__1224:
	.data
___L__1084__core_2Feval_2El__1224:
	.asciz "bitor"
	.text
	movl $___L__1084__core_2Feval_2El__1224,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1088__core_2Feval_2El__1224
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1090__core_2Feval_2El__1224
	movl __3Clong_3E,%eax
	jmp ___L__1091__core_2Feval_2El__1224
___L__1090__core_2Feval_2El__1224:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1091__core_2Feval_2El__1224:
	jmp ___L__1089__core_2Feval_2El__1224
___L__1088__core_2Feval_2El__1224:
	movl __3Cundefined_3E,%eax
___L__1089__core_2Feval_2El__1224:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1087__core_2Feval_2El__1224
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1092__core_2Feval_2El__1224
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1094__core_2Feval_2El__1224
	movl __3Clong_3E,%eax
	jmp ___L__1095__core_2Feval_2El__1224
___L__1094__core_2Feval_2El__1224:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1095__core_2Feval_2El__1224:
	jmp ___L__1093__core_2Feval_2El__1224
___L__1092__core_2Feval_2El__1224:
	movl __3Cundefined_3E,%eax
___L__1093__core_2Feval_2El__1224:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1087__core_2Feval_2El__1224:
	cmpl $0,%eax
	je ___L__1085__core_2Feval_2El__1224
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	orl 24(%esp),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1086__core_2Feval_2El__1224
___L__1085__core_2Feval_2El__1224:
	.data
___L__1096__core_2Feval_2El__1224:
	.asciz "%p %p\012"
	.text
	movl $___L__1096__core_2Feval_2El__1224,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__1097__core_2Feval_2El__1224:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1097__core_2Feval_2El__1224,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1098__core_2Feval_2El__1224:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__1098__core_2Feval_2El__1224,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1099__core_2Feval_2El__1224:
	.asciz "bitor"
	.text
	movl $___L__1099__core_2Feval_2El__1224,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1100__core_2Feval_2El__1224:
	.asciz " "
	.text
	movl $___L__1100__core_2Feval_2El__1224,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1101__core_2Feval_2El__1224:
	.asciz " "
	.text
	movl $___L__1101__core_2Feval_2El__1224,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1102__core_2Feval_2El__1224:
	.asciz ")"
	.text
	movl $___L__1102__core_2Feval_2El__1224,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1103__core_2Feval_2El__1224:
	.asciz "\012"
	.text
	movl $___L__1103__core_2Feval_2El__1224,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1086__core_2Feval_2El__1224:
	addl $56,%esp
	leave
	ret
## defn subr_bitand
subr_bitand
	.text
___L__1104__core_2Feval_2El__1224:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1105__core_2Feval_2El__1223:
	.data
___L__1106__core_2Feval_2El__1223:
	.asciz "bitand"
	.text
	movl $___L__1106__core_2Feval_2El__1223,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _arity2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1110__core_2Feval_2El__1223
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1112__core_2Feval_2El__1223
	movl __3Clong_3E,%eax
	jmp ___L__1113__core_2Feval_2El__1223
___L__1112__core_2Feval_2El__1223:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1113__core_2Feval_2El__1223:
	jmp ___L__1111__core_2Feval_2El__1223
___L__1110__core_2Feval_2El__1223:
	movl __3Cundefined_3E,%eax
___L__1111__core_2Feval_2El__1223:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1109__core_2Feval_2El__1223
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1114__core_2Feval_2El__1223
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1116__core_2Feval_2El__1223
	movl __3Clong_3E,%eax
	jmp ___L__1117__core_2Feval_2El__1223
___L__1116__core_2Feval_2El__1223:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1117__core_2Feval_2El__1223:
	jmp ___L__1115__core_2Feval_2El__1223
___L__1114__core_2Feval_2El__1223:
	movl __3Cundefined_3E,%eax
___L__1115__core_2Feval_2El__1223:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1109__core_2Feval_2El__1223:
	cmpl $0,%eax
	je ___L__1107__core_2Feval_2El__1223
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	andl 24(%esp),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1108__core_2Feval_2El__1223
___L__1107__core_2Feval_2El__1223:
	.data
___L__1118__core_2Feval_2El__1223:
	.asciz "%p %p\012"
	.text
	movl $___L__1118__core_2Feval_2El__1223,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__1119__core_2Feval_2El__1223:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1119__core_2Feval_2El__1223,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1120__core_2Feval_2El__1223:
	.asciz "non-numeric argument: ("
	.text
	movl $___L__1120__core_2Feval_2El__1223,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1121__core_2Feval_2El__1223:
	.asciz "bitand"
	.text
	movl $___L__1121__core_2Feval_2El__1223,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1122__core_2Feval_2El__1223:
	.asciz " "
	.text
	movl $___L__1122__core_2Feval_2El__1223,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1123__core_2Feval_2El__1223:
	.asciz " "
	.text
	movl $___L__1123__core_2Feval_2El__1223,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1124__core_2Feval_2El__1223:
	.asciz ")"
	.text
	movl $___L__1124__core_2Feval_2El__1223,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1125__core_2Feval_2El__1223:
	.asciz "\012"
	.text
	movl $___L__1125__core_2Feval_2El__1223,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1108__core_2Feval_2El__1223:
	addl $56,%esp
	leave
	ret
## defn define-binary
define-binary
## defn subr_sub
subr_sub
	.text
___L__1126__core_2Feval_2El__1223:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1127__core_2Feval_2El__1200:
	movl 64(%esp),%eax
	cmpl $0,%eax
	jne ___L__1128__core_2Feval_2El__1200
	.data
___L__1129__core_2Feval_2El__1200:
	.asciz "-: expected 1 or 2 arguments"
	.text
	movl $___L__1129__core_2Feval_2El__1200,%eax
	movl %eax,16(%esp)
	movl _fatal,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1128__core_2Feval_2El__1200:
___L__1130__core_2Feval_2El__1201:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__1131__core_2Feval_2El__1202:
	movl $1,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1132__core_2Feval_2El__1203:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1136__core_2Feval_2El__1203
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1138__core_2Feval_2El__1203
	movl __3Clong_3E,%eax
	jmp ___L__1139__core_2Feval_2El__1203
___L__1138__core_2Feval_2El__1203:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1139__core_2Feval_2El__1203:
	jmp ___L__1137__core_2Feval_2El__1203
___L__1136__core_2Feval_2El__1203:
	movl __3Cundefined_3E,%eax
___L__1137__core_2Feval_2El__1203:
	movl %eax,24(%esp)
	movl __3Cpair_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1135__core_2Feval_2El__1203:
	cmpl $0,%eax
	je ___L__1133__core_2Feval_2El__1203
___L__1140__core_2Feval_2El__1204:
___L__1141__core_2Feval_2El__1205:
	movl $0,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1142__core_2Feval_2El__1206:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1146__core_2Feval_2El__1206
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1148__core_2Feval_2El__1206
	movl __3Clong_3E,%eax
	jmp ___L__1149__core_2Feval_2El__1206
___L__1148__core_2Feval_2El__1206:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1149__core_2Feval_2El__1206:
	jmp ___L__1147__core_2Feval_2El__1206
___L__1146__core_2Feval_2El__1206:
	movl __3Cundefined_3E,%eax
___L__1147__core_2Feval_2El__1206:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1145__core_2Feval_2El__1206
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1150__core_2Feval_2El__1206
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1152__core_2Feval_2El__1206
	movl __3Clong_3E,%eax
	jmp ___L__1153__core_2Feval_2El__1206
___L__1152__core_2Feval_2El__1206:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1153__core_2Feval_2El__1206:
	jmp ___L__1151__core_2Feval_2El__1206
___L__1150__core_2Feval_2El__1206:
	movl __3Cundefined_3E,%eax
___L__1151__core_2Feval_2El__1206:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1145__core_2Feval_2El__1206:
	cmpl $0,%eax
	je ___L__1143__core_2Feval_2El__1206
___L__1154__core_2Feval_2El__1207:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	subl 24(%esp),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1144__core_2Feval_2El__1206
___L__1143__core_2Feval_2El__1206:
___L__1155__core_2Feval_2El__1208:
	.data
___L__1156__core_2Feval_2El__1208:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1156__core_2Feval_2El__1208,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1157__core_2Feval_2El__1208:
	.asciz "non-numeric argument: (- "
	.text
	movl $___L__1157__core_2Feval_2El__1208,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1158__core_2Feval_2El__1208:
	.asciz " "
	.text
	movl $___L__1158__core_2Feval_2El__1208,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1159__core_2Feval_2El__1208:
	.asciz ")"
	.text
	movl $___L__1159__core_2Feval_2El__1208,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1160__core_2Feval_2El__1208:
	.asciz "\012"
	.text
	movl $___L__1160__core_2Feval_2El__1208,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1144__core_2Feval_2El__1206:
	jmp ___L__1134__core_2Feval_2El__1203
___L__1133__core_2Feval_2El__1203:
___L__1161__core_2Feval_2El__1209:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1165__core_2Feval_2El__1209
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1167__core_2Feval_2El__1209
	movl __3Clong_3E,%eax
	jmp ___L__1168__core_2Feval_2El__1209
___L__1167__core_2Feval_2El__1209:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1168__core_2Feval_2El__1209:
	jmp ___L__1166__core_2Feval_2El__1209
___L__1165__core_2Feval_2El__1209:
	movl __3Cundefined_3E,%eax
___L__1166__core_2Feval_2El__1209:
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1164__core_2Feval_2El__1209:
	cmpl $0,%eax
	je ___L__1162__core_2Feval_2El__1209
___L__1169__core_2Feval_2El__1210:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	negl %eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1163__core_2Feval_2El__1209
___L__1162__core_2Feval_2El__1209:
___L__1170__core_2Feval_2El__1211:
	.data
___L__1171__core_2Feval_2El__1211:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1171__core_2Feval_2El__1211,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1172__core_2Feval_2El__1211:
	.asciz "non-numeric argument: (- "
	.text
	movl $___L__1172__core_2Feval_2El__1211,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1173__core_2Feval_2El__1211:
	.asciz ")"
	.text
	movl $___L__1173__core_2Feval_2El__1211,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1174__core_2Feval_2El__1211:
	.asciz "\012"
	.text
	movl $___L__1174__core_2Feval_2El__1211,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1163__core_2Feval_2El__1209:
___L__1134__core_2Feval_2El__1203:
	addl $56,%esp
	leave
	ret
## defn arity3
arity3
	.text
___L__1175__core_2Feval_2El__1211:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1176__core_2Feval_2El__1193:
	movl 52(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1179__core_2Feval_2El__1193
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1181__core_2Feval_2El__1193
	movl __3Clong_3E,%eax
	jmp ___L__1182__core_2Feval_2El__1193
___L__1181__core_2Feval_2El__1193:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1182__core_2Feval_2El__1193:
	jmp ___L__1180__core_2Feval_2El__1193
___L__1179__core_2Feval_2El__1193:
	movl __3Cundefined_3E,%eax
___L__1180__core_2Feval_2El__1193:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1178__core_2Feval_2El__1193
___L__1183__core_2Feval_2El__1194:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1184__core_2Feval_2El__1194
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1186__core_2Feval_2El__1194
	movl __3Clong_3E,%eax
	jmp ___L__1187__core_2Feval_2El__1194
___L__1186__core_2Feval_2El__1194:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1187__core_2Feval_2El__1194:
	jmp ___L__1185__core_2Feval_2El__1194
___L__1184__core_2Feval_2El__1194:
	movl __3Cundefined_3E,%eax
___L__1185__core_2Feval_2El__1194:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1178__core_2Feval_2El__1193
___L__1188__core_2Feval_2El__1195:
	movl $1,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1189__core_2Feval_2El__1195
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1191__core_2Feval_2El__1195
	movl __3Clong_3E,%eax
	jmp ___L__1192__core_2Feval_2El__1195
___L__1191__core_2Feval_2El__1195:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1192__core_2Feval_2El__1195:
	jmp ___L__1190__core_2Feval_2El__1195
___L__1189__core_2Feval_2El__1195:
	movl __3Cundefined_3E,%eax
___L__1190__core_2Feval_2El__1195:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1178__core_2Feval_2El__1193
___L__1193__core_2Feval_2El__1196:
	movl $1,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 52(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1178__core_2Feval_2El__1193:
	cmpl $0,%eax
	jne ___L__1177__core_2Feval_2El__1193
___L__1194__core_2Feval_2El__1197:
	.data
___L__1195__core_2Feval_2El__1197:
	.asciz "%s: expected 3 arguments"
	.text
	movl $___L__1195__core_2Feval_2El__1197,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _fatal1,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1177__core_2Feval_2El__1193:
	addl $40,%esp
	leave
	ret
## defn arity2
arity2
	.text
___L__1196__core_2Feval_2El__1197:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1197__core_2Feval_2El__1187:
	movl 52(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1200__core_2Feval_2El__1187
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1202__core_2Feval_2El__1187
	movl __3Clong_3E,%eax
	jmp ___L__1203__core_2Feval_2El__1187
___L__1202__core_2Feval_2El__1187:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1203__core_2Feval_2El__1187:
	jmp ___L__1201__core_2Feval_2El__1187
___L__1200__core_2Feval_2El__1187:
	movl __3Cundefined_3E,%eax
___L__1201__core_2Feval_2El__1187:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1199__core_2Feval_2El__1187
___L__1204__core_2Feval_2El__1188:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1205__core_2Feval_2El__1188
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1207__core_2Feval_2El__1188
	movl __3Clong_3E,%eax
	jmp ___L__1208__core_2Feval_2El__1188
___L__1207__core_2Feval_2El__1188:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1208__core_2Feval_2El__1188:
	jmp ___L__1206__core_2Feval_2El__1188
___L__1205__core_2Feval_2El__1188:
	movl __3Cundefined_3E,%eax
___L__1206__core_2Feval_2El__1188:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1199__core_2Feval_2El__1187
___L__1209__core_2Feval_2El__1189:
	movl $1,%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1199__core_2Feval_2El__1187:
	cmpl $0,%eax
	jne ___L__1198__core_2Feval_2El__1187
___L__1210__core_2Feval_2El__1190:
	.data
___L__1211__core_2Feval_2El__1190:
	.asciz "%s: expected 2 arguments"
	.text
	movl $___L__1211__core_2Feval_2El__1190,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _fatal1,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1198__core_2Feval_2El__1187:
	addl $40,%esp
	leave
	ret
## defn subr_not
subr_not
	.text
___L__1212__core_2Feval_2El__1190:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1213__core_2Feval_2El__1184:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1214__core_2Feval_2El__1184
	movl $0,%eax
	jmp ___L__1215__core_2Feval_2El__1184
___L__1214__core_2Feval_2El__1184:
	movl _s__t,%eax
___L__1215__core_2Feval_2El__1184:
	addl $40,%esp
	leave
	ret
## defn subr_quote
subr_quote
	.text
___L__1216__core_2Feval_2El__1184:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1217__core_2Feval_2El__1181:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_and
subr_and
	.text
___L__1218__core_2Feval_2El__1181:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1219__core_2Feval_2El__1173:
	movl _s__t,%eax
	movl %eax,16(%esp)
___L__1220__core_2Feval_2El__1174:
	jmp ___L__1222__core_2Feval_2El__1174
___L__1221__core_2Feval_2El__1174:
___L__1223__core_2Feval_2El__1175:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _k__eval,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	cmpl $0,%eax
	jne ___L__1224__core_2Feval_2El__1175
___L__1225__core_2Feval_2El__1176:
	movl $0,%eax
	jmp ___L__1226__core_2Feval_2El__1176
___L__1224__core_2Feval_2El__1175:
___L__1227__core_2Feval_2El__1177:
	movl $1,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
___L__1222__core_2Feval_2El__1174:
___L__1228__core_2Feval_2El__1174:
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1229__core_2Feval_2El__1174
	movl $1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1231__core_2Feval_2El__1174
	movl __3Clong_3E,%eax
	jmp ___L__1232__core_2Feval_2El__1174
___L__1231__core_2Feval_2El__1174:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1232__core_2Feval_2El__1174:
	jmp ___L__1230__core_2Feval_2El__1174
___L__1229__core_2Feval_2El__1174:
	movl __3Cundefined_3E,%eax
___L__1230__core_2Feval_2El__1174:
	movl %eax,24(%esp)
	movl __3Cpair_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1221__core_2Feval_2El__1174
	movl 16(%esp),%eax
___L__1226__core_2Feval_2El__1176:
	addl $40,%esp
	leave
	ret
## defn subr_or
subr_or
	.text
___L__1233__core_2Feval_2El__1174:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1234__core_2Feval_2El__1166:
	movl $0,%eax
	movl %eax,16(%esp)
___L__1235__core_2Feval_2El__1167:
	jmp ___L__1237__core_2Feval_2El__1167
___L__1236__core_2Feval_2El__1167:
___L__1238__core_2Feval_2El__1168:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _k__eval,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	cmpl $0,%eax
	je ___L__1239__core_2Feval_2El__1168
___L__1240__core_2Feval_2El__1169:
	movl 16(%esp),%eax
	jmp ___L__1241__core_2Feval_2El__1169
___L__1239__core_2Feval_2El__1168:
___L__1242__core_2Feval_2El__1170:
	movl $1,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
___L__1237__core_2Feval_2El__1167:
___L__1243__core_2Feval_2El__1167:
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1244__core_2Feval_2El__1167
	movl $1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1246__core_2Feval_2El__1167
	movl __3Clong_3E,%eax
	jmp ___L__1247__core_2Feval_2El__1167
___L__1246__core_2Feval_2El__1167:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1247__core_2Feval_2El__1167:
	jmp ___L__1245__core_2Feval_2El__1167
___L__1244__core_2Feval_2El__1167:
	movl __3Cundefined_3E,%eax
___L__1245__core_2Feval_2El__1167:
	movl %eax,24(%esp)
	movl __3Cpair_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1236__core_2Feval_2El__1167
___L__1241__core_2Feval_2El__1169:
	addl $40,%esp
	leave
	ret
## defn subr_if
subr_if
	.text
___L__1248__core_2Feval_2El__1167:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1249__core_2Feval_2El__1157:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _k__eval,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1250__core_2Feval_2El__1157
___L__1252__core_2Feval_2El__1158:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,16(%esp)
	movl _k__eval,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 16(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1251__core_2Feval_2El__1157
___L__1250__core_2Feval_2El__1157:
___L__1253__core_2Feval_2El__1159:
	movl $0,%eax
	movl %eax,16(%esp)
___L__1254__core_2Feval_2El__1160:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cdr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,48(%esp)
___L__1255__core_2Feval_2El__1161:
	jmp ___L__1257__core_2Feval_2El__1161
___L__1256__core_2Feval_2El__1161:
___L__1258__core_2Feval_2El__1162:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _k__eval,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1257__core_2Feval_2El__1161:
___L__1259__core_2Feval_2El__1161:
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _k__cdr,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,48(%esp)
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1260__core_2Feval_2El__1161
	movl $1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1262__core_2Feval_2El__1161
	movl __3Clong_3E,%eax
	jmp ___L__1263__core_2Feval_2El__1161
___L__1262__core_2Feval_2El__1161:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1263__core_2Feval_2El__1161:
	jmp ___L__1261__core_2Feval_2El__1161
___L__1260__core_2Feval_2El__1161:
	movl __3Cundefined_3E,%eax
___L__1261__core_2Feval_2El__1161:
	movl %eax,24(%esp)
	movl __3Cpair_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1256__core_2Feval_2El__1161
	movl 16(%esp),%eax
___L__1251__core_2Feval_2El__1157:
	addl $40,%esp
	leave
	ret
## defn subr_while
subr_while
	.text
___L__1264__core_2Feval_2El__1161:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1265__core_2Feval_2El__1149:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
___L__1266__core_2Feval_2El__1151:
	jmp ___L__1268__core_2Feval_2El__1151
___L__1267__core_2Feval_2El__1151:
___L__1269__core_2Feval_2El__1152:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
___L__1270__core_2Feval_2El__1153:
	jmp ___L__1272__core_2Feval_2El__1153
___L__1271__core_2Feval_2El__1153:
___L__1273__core_2Feval_2El__1154:
	movl $0,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl _k__eval,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1272__core_2Feval_2El__1153:
___L__1274__core_2Feval_2El__1153:
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl _k__cdr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl %eax,32(%esp)
	movl $0,%eax
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__1275__core_2Feval_2El__1153
	movl $1,%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1277__core_2Feval_2El__1153
	movl __3Clong_3E,%eax
	jmp ___L__1278__core_2Feval_2El__1153
___L__1277__core_2Feval_2El__1153:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1278__core_2Feval_2El__1153:
	jmp ___L__1276__core_2Feval_2El__1153
___L__1275__core_2Feval_2El__1153:
	movl __3Cundefined_3E,%eax
___L__1276__core_2Feval_2El__1153:
	movl %eax,32(%esp)
	movl __3Cpair_3E,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1271__core_2Feval_2El__1153
___L__1268__core_2Feval_2El__1151:
___L__1279__core_2Feval_2El__1151:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl _k__eval,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__1267__core_2Feval_2El__1151
	addl $56,%esp
	leave
	ret
## defn subr_set
subr_set
	.text
___L__1280__core_2Feval_2El__1151:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1281__core_2Feval_2El__1132:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1282__core_2Feval_2El__1133:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1284__core_2Feval_2El__1133
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1286__core_2Feval_2El__1133
	movl __3Clong_3E,%eax
	jmp ___L__1287__core_2Feval_2El__1133
___L__1286__core_2Feval_2El__1133:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1287__core_2Feval_2El__1133:
	jmp ___L__1285__core_2Feval_2El__1133
___L__1284__core_2Feval_2El__1133:
	movl __3Cundefined_3E,%eax
___L__1285__core_2Feval_2El__1133:
	movl %eax,20(%esp)
	movl __3Cvariable_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1283__core_2Feval_2El__1133
___L__1288__core_2Feval_2El__1134:
___L__1289__core_2Feval_2El__1135:
	.data
___L__1290__core_2Feval_2El__1135:
	.asciz "\012cannot set undefined variable: "
	.text
	movl $___L__1290__core_2Feval_2El__1135,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1291__core_2Feval_2El__1136:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__dumpln,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1292__core_2Feval_2El__1137:
	.data
___L__1293__core_2Feval_2El__1137:
	.asciz "aborting"
	.text
	movl $___L__1293__core_2Feval_2El__1137,%eax
	movl %eax,20(%esp)
	movl _fatal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1283__core_2Feval_2El__1133:
___L__1294__core_2Feval_2El__1138:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _k__eval,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1295__core_2Feval_2El__1139:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _is__global,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1296__core_2Feval_2El__1139
___L__1298__core_2Feval_2El__1140:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 28(%esp),%eax
	movl %eax,(%ecx)
	jmp ___L__1297__core_2Feval_2El__1139
___L__1296__core_2Feval_2El__1139:
___L__1299__core_2Feval_2El__1141:
___L__1300__core_2Feval_2El__1142:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,40(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1301__core_2Feval_2El__1141:
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	subl 20(%esp),%eax
	movl %eax,20(%esp)
___L__1302__core_2Feval_2El__1143:
	jmp ___L__1304__core_2Feval_2El__1143
___L__1303__core_2Feval_2El__1143:
___L__1305__core_2Feval_2El__1144:
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,68(%esp)
___L__1306__core_2Feval_2El__1145:
	movl $1,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	subl 28(%esp),%eax
	movl %eax,20(%esp)
___L__1304__core_2Feval_2El__1143:
___L__1307__core_2Feval_2El__1143:
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	cmpl 28(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1303__core_2Feval_2El__1143
___L__1308__core_2Feval_2El__1146:
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,40(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,36(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 40(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,44(%esp)
	movl 40(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl _k__set__array__at,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1297__core_2Feval_2El__1139:
	addl $56,%esp
	leave
	ret
## defn subr_let
subr_let
	.text
___L__1309__core_2Feval_2El__1146:
## frame 16 48 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__1310__core_2Feval_2El__1108:
	movl $0,%eax
	movl %eax,16(%esp)
___L__1311__core_2Feval_2El__1109:
	movl 80(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1312__core_2Feval_2El__1108:
___L__1313__core_2Feval_2El__1110:
	movl 84(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__1314__core_2Feval_2El__1108:
___L__1315__core_2Feval_2El__1111:
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl _k__cddr,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__1316__core_2Feval_2El__1112:
	leal 16(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__push__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1317__core_2Feval_2El__1113:
	jmp ___L__1319__core_2Feval_2El__1113
___L__1318__core_2Feval_2El__1113:
___L__1320__core_2Feval_2El__1114:
	movl $0,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
___L__1321__core_2Feval_2El__1115:
	movl 36(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__1324__core_2Feval_2El__1115
	movl $1,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1326__core_2Feval_2El__1115
	movl __3Clong_3E,%eax
	jmp ___L__1327__core_2Feval_2El__1115
___L__1326__core_2Feval_2El__1115:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1327__core_2Feval_2El__1115:
	jmp ___L__1325__core_2Feval_2El__1115
___L__1324__core_2Feval_2El__1115:
	movl __3Cundefined_3E,%eax
___L__1325__core_2Feval_2El__1115:
	movl %eax,32(%esp)
	movl __3Cpair_3E,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1322__core_2Feval_2El__1115
___L__1328__core_2Feval_2El__1116:
	movl $0,%eax
	movl %eax,32(%esp)
	movl 36(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
___L__1329__core_2Feval_2El__1117:
	movl $1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
___L__1330__core_2Feval_2El__1118:
	movl $0,%eax
	movl %eax,16(%esp)
___L__1331__core_2Feval_2El__1119:
	jmp ___L__1333__core_2Feval_2El__1119
___L__1332__core_2Feval_2El__1119:
___L__1334__core_2Feval_2El__1120:
	movl $0,%eax
	movl %eax,44(%esp)
	movl 40(%esp),%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
	movl 84(%esp),%eax
	movl %eax,48(%esp)
	movl _k__eval,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1335__core_2Feval_2El__1121:
	movl $1,%eax
	movl %eax,48(%esp)
	movl 40(%esp),%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
___L__1333__core_2Feval_2El__1119:
___L__1336__core_2Feval_2El__1119:
	movl 40(%esp),%eax
	movl %eax,48(%esp)
	movl $0,%eax
	movl 48(%esp),%eax
	cmpl $0,%eax
	je ___L__1337__core_2Feval_2El__1119
	movl $1,%eax
	movl %eax,44(%esp)
	movl 48(%esp),%eax
	andl 44(%esp),%eax
	cmpl $0,%eax
	je ___L__1339__core_2Feval_2El__1119
	movl __3Clong_3E,%eax
	jmp ___L__1340__core_2Feval_2El__1119
___L__1339__core_2Feval_2El__1119:
	movl $-1,%eax
	movl %eax,44(%esp)
	movl 48(%esp),%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1340__core_2Feval_2El__1119:
	jmp ___L__1338__core_2Feval_2El__1119
___L__1337__core_2Feval_2El__1119:
	movl __3Cundefined_3E,%eax
___L__1338__core_2Feval_2El__1119:
	movl %eax,48(%esp)
	movl __3Cpair_3E,%eax
	cmpl 48(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1332__core_2Feval_2El__1119
___L__1341__core_2Feval_2El__1122:
	movl 24(%esp),%eax
	movl %eax,48(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,52(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,56(%esp)
	movl 44(%esp),%eax
	movl %eax,60(%esp)
	movl __25typecheck,%eax
	movl 56(%esp),%ecx
	movl %ecx,0(%esp)
	movl 60(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 52(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,52(%esp)
	movl __3Clong_3E,%eax
	movl %eax,60(%esp)
	movl 44(%esp),%eax
	movl %eax,56(%esp)
	movl __25typecheck,%eax
	movl 60(%esp),%ecx
	movl %ecx,0(%esp)
	movl 56(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 52(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
	movl 16(%esp),%eax
	movl %eax,52(%esp)
	movl _k__set__array__at,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	movl 52(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	jmp ___L__1323__core_2Feval_2El__1115
___L__1322__core_2Feval_2El__1115:
___L__1323__core_2Feval_2El__1115:
___L__1342__core_2Feval_2El__1123:
	movl $1,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1319__core_2Feval_2El__1113:
___L__1343__core_2Feval_2El__1113:
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1344__core_2Feval_2El__1113
	movl $1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1346__core_2Feval_2El__1113
	movl __3Clong_3E,%eax
	jmp ___L__1347__core_2Feval_2El__1113
___L__1346__core_2Feval_2El__1113:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1347__core_2Feval_2El__1113:
	jmp ___L__1345__core_2Feval_2El__1113
___L__1344__core_2Feval_2El__1113:
	movl __3Cundefined_3E,%eax
___L__1345__core_2Feval_2El__1113:
	movl %eax,36(%esp)
	movl __3Cpair_3E,%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1318__core_2Feval_2El__1113
___L__1348__core_2Feval_2El__1124:
	movl $0,%eax
	movl %eax,16(%esp)
___L__1349__core_2Feval_2El__1125:
	jmp ___L__1351__core_2Feval_2El__1125
___L__1350__core_2Feval_2El__1125:
___L__1352__core_2Feval_2El__1126:
	movl $0,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl 84(%esp),%eax
	movl %eax,40(%esp)
	movl _k__eval,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1353__core_2Feval_2El__1127:
	movl $1,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
___L__1351__core_2Feval_2El__1125:
___L__1354__core_2Feval_2El__1125:
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1355__core_2Feval_2El__1125
	movl $1,%eax
	movl %eax,36(%esp)
	movl 40(%esp),%eax
	andl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1357__core_2Feval_2El__1125
	movl __3Clong_3E,%eax
	jmp ___L__1358__core_2Feval_2El__1125
___L__1357__core_2Feval_2El__1125:
	movl $-1,%eax
	movl %eax,36(%esp)
	movl 40(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1358__core_2Feval_2El__1125:
	jmp ___L__1356__core_2Feval_2El__1125
___L__1355__core_2Feval_2El__1125:
	movl __3Cundefined_3E,%eax
___L__1356__core_2Feval_2El__1125:
	movl %eax,40(%esp)
	movl __3Cpair_3E,%eax
	cmpl 40(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1350__core_2Feval_2El__1125
	movl %eax,40(%esp)
___L__1359__core_2Feval_2El__1112:
	leal 16(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 40(%esp),%eax
	movl 16(%esp),%eax
	addl $72,%esp
	leave
	ret
## defn subr_lambda
subr_lambda
	.text
___L__1360__core_2Feval_2El__1112:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1361__core_2Feval_2El__1105:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Cexpr_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn subr_definedP
subr_definedP
	.text
___L__1362__core_2Feval_2El__1105:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1363__core_2Feval_2El__1100:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1364__core_2Feval_2El__1101:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__1365__core_2Feval_2El__1101
	movl _globals,%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1365__core_2Feval_2El__1101:
	movl %eax,20(%esp)
___L__1366__core_2Feval_2El__1102:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl _k__env__find__variable,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	addl $56,%esp
	leave
	ret
## defn subr_define
subr_define
	.text
___L__1367__core_2Feval_2El__1102:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1368__core_2Feval_2El__1090:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1369__core_2Feval_2El__1091:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1371__core_2Feval_2El__1091
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1373__core_2Feval_2El__1091
	movl __3Clong_3E,%eax
	jmp ___L__1374__core_2Feval_2El__1091
___L__1373__core_2Feval_2El__1091:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1374__core_2Feval_2El__1091:
	jmp ___L__1372__core_2Feval_2El__1091
___L__1371__core_2Feval_2El__1091:
	movl __3Cundefined_3E,%eax
___L__1372__core_2Feval_2El__1091:
	movl %eax,20(%esp)
	movl __3Cvariable_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1370__core_2Feval_2El__1091
___L__1375__core_2Feval_2El__1092:
___L__1376__core_2Feval_2El__1093:
	.data
___L__1377__core_2Feval_2El__1093:
	.asciz "\012error: non-variable in define: "
	.text
	movl $___L__1377__core_2Feval_2El__1093,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1378__core_2Feval_2El__1094:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__dumpln,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1379__core_2Feval_2El__1095:
	.data
___L__1380__core_2Feval_2El__1095:
	.asciz "aborting"
	.text
	movl $___L__1380__core_2Feval_2El__1095,%eax
	movl %eax,20(%esp)
	movl _fatal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1370__core_2Feval_2El__1091:
___L__1381__core_2Feval_2El__1096:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _k__cadr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _k__eval,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1382__core_2Feval_2El__1097:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 28(%esp),%eax
	movl %eax,(%ecx)
	addl $56,%esp
	leave
	ret
## defn evlist
evlist
	.text
___L__1383__core_2Feval_2El__1097:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1384__core_2Feval_2El__1044:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1387__core_2Feval_2El__1044
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1389__core_2Feval_2El__1044
	movl __3Clong_3E,%eax
	jmp ___L__1390__core_2Feval_2El__1044
___L__1389__core_2Feval_2El__1044:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1390__core_2Feval_2El__1044:
	jmp ___L__1388__core_2Feval_2El__1044
___L__1387__core_2Feval_2El__1044:
	movl __3Cundefined_3E,%eax
___L__1388__core_2Feval_2El__1044:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1385__core_2Feval_2El__1044
___L__1391__core_2Feval_2El__1045:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _k__eval,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1392__core_2Feval_2El__1046:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1393__core_2Feval_2El__1047:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _evlist,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1394__core_2Feval_2El__1048:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1395__core_2Feval_2El__1049:
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__1396__core_2Feval_2El__1048:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__pop__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
	movl %eax,24(%esp)
___L__1397__core_2Feval_2El__1046:
	leal 20(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__pop__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 24(%esp),%eax
	jmp ___L__1386__core_2Feval_2El__1044
___L__1385__core_2Feval_2El__1044:
	movl 48(%esp),%eax
___L__1386__core_2Feval_2El__1044:
	addl $40,%esp
	leave
	ret
## defn k_encode
k_encode
	.text
___L__1398__core_2Feval_2El__1046:
## frame 16 36 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__1399__core_2Feval_2El__980:
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1402__core_2Feval_2El__980
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1404__core_2Feval_2El__980
	movl __3Clong_3E,%eax
	jmp ___L__1405__core_2Feval_2El__980
___L__1404__core_2Feval_2El__980:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1405__core_2Feval_2El__980:
	jmp ___L__1403__core_2Feval_2El__980
___L__1402__core_2Feval_2El__980:
	movl __3Cundefined_3E,%eax
___L__1403__core_2Feval_2El__980:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1400__core_2Feval_2El__980
___L__1406__core_2Feval_2El__981:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 80(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 84(%esp),%eax
	movl %eax,20(%esp)
	movl _k__encode,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1407__core_2Feval_2El__982:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 80(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__1408__core_2Feval_2El__983:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__push__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 16(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__push__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1409__core_2Feval_2El__984:
___L__1412__core_2Feval_2El__985:
	movl _f__let,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1410__core_2Feval_2El__984
	movl 80(%esp),%eax
	movl %eax,24(%esp)
	movl _k__cadr,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1413__core_2Feval_2El__986:
	leal 84(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__push__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1414__core_2Feval_2El__987:
	movl 84(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl 84(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,40(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,44(%esp)
	movl 36(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Clong_3E,%eax
	movl %eax,48(%esp)
	movl 36(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl _new_2D_3Cenv_3E,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,84(%esp)
___L__1415__core_2Feval_2El__988:
	jmp ___L__1417__core_2Feval_2El__988
___L__1416__core_2Feval_2El__988:
___L__1418__core_2Feval_2El__989:
	movl $0,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
___L__1419__core_2Feval_2El__990:
	movl 36(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__1421__core_2Feval_2El__990
	movl $1,%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1423__core_2Feval_2El__990
	movl __3Clong_3E,%eax
	jmp ___L__1424__core_2Feval_2El__990
___L__1423__core_2Feval_2El__990:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1424__core_2Feval_2El__990:
	jmp ___L__1422__core_2Feval_2El__990
___L__1421__core_2Feval_2El__990:
	movl __3Cundefined_3E,%eax
___L__1422__core_2Feval_2El__990:
	movl %eax,32(%esp)
	movl __3Cpair_3E,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1420__core_2Feval_2El__990
	movl $0,%eax
	movl %eax,32(%esp)
	movl 36(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
___L__1420__core_2Feval_2El__990:
___L__1425__core_2Feval_2El__991:
	movl 84(%esp),%eax
	movl %eax,32(%esp)
	movl 36(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl _k__env__define,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1426__core_2Feval_2El__992:
	movl $1,%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__1417__core_2Feval_2El__988:
___L__1427__core_2Feval_2El__988:
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1428__core_2Feval_2El__988
	movl $1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1430__core_2Feval_2El__988
	movl __3Clong_3E,%eax
	jmp ___L__1431__core_2Feval_2El__988
___L__1430__core_2Feval_2El__988:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1431__core_2Feval_2El__988:
	jmp ___L__1429__core_2Feval_2El__988
___L__1428__core_2Feval_2El__988:
	movl __3Cundefined_3E,%eax
___L__1429__core_2Feval_2El__988:
	movl %eax,36(%esp)
	movl __3Cpair_3E,%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1416__core_2Feval_2El__988
___L__1432__core_2Feval_2El__993:
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl 84(%esp),%eax
	movl %eax,40(%esp)
	movl _enlist,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1433__core_2Feval_2El__994:
	movl 84(%esp),%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl %eax,36(%esp)
___L__1434__core_2Feval_2El__986:
	leal 84(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__pop__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 36(%esp),%eax
	jmp ___L__1411__core_2Feval_2El__984
___L__1410__core_2Feval_2El__984:
___L__1435__core_2Feval_2El__984:
___L__1438__core_2Feval_2El__995:
	movl _f__lambda,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1436__core_2Feval_2El__984
	movl 80(%esp),%eax
	movl %eax,24(%esp)
	movl _k__cadr,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1439__core_2Feval_2El__996:
	leal 84(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__push__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1440__core_2Feval_2El__997:
	movl 84(%esp),%eax
	movl %eax,36(%esp)
	movl $1,%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cenv_3E,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,84(%esp)
___L__1441__core_2Feval_2El__998:
	jmp ___L__1443__core_2Feval_2El__998
___L__1442__core_2Feval_2El__998:
___L__1444__core_2Feval_2El__999:
	movl 84(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
	movl _k__env__define,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1445__core_2Feval_2El__1000:
	movl $1,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__1443__core_2Feval_2El__998:
___L__1446__core_2Feval_2El__998:
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1447__core_2Feval_2El__998
	movl $1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1449__core_2Feval_2El__998
	movl __3Clong_3E,%eax
	jmp ___L__1450__core_2Feval_2El__998
___L__1449__core_2Feval_2El__998:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1450__core_2Feval_2El__998:
	jmp ___L__1448__core_2Feval_2El__998
___L__1447__core_2Feval_2El__998:
	movl __3Cundefined_3E,%eax
___L__1448__core_2Feval_2El__998:
	movl %eax,36(%esp)
	movl __3Cpair_3E,%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1442__core_2Feval_2El__998
___L__1451__core_2Feval_2El__1001:
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1452__core_2Feval_2El__1001
	movl 84(%esp),%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl _k__env__define,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1452__core_2Feval_2El__1001:
___L__1453__core_2Feval_2El__1002:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl 84(%esp),%eax
	movl %eax,40(%esp)
	movl _enlist,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1454__core_2Feval_2El__1003:
	movl 84(%esp),%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl %eax,28(%esp)
___L__1455__core_2Feval_2El__996:
	leal 84(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__pop__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
	jmp ___L__1437__core_2Feval_2El__984
___L__1436__core_2Feval_2El__984:
___L__1456__core_2Feval_2El__984:
___L__1459__core_2Feval_2El__1004:
	movl _f__define,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1457__core_2Feval_2El__984
	movl _globals,%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _k__car,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
	movl _k__env__define,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,36(%esp)
___L__1460__core_2Feval_2El__1005:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _k__cdr,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,28(%esp)
	movl 84(%esp),%eax
	movl %eax,24(%esp)
	movl _enlist,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1461__core_2Feval_2El__1006:
	movl 36(%esp),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	jmp ___L__1458__core_2Feval_2El__984
___L__1457__core_2Feval_2El__984:
___L__1462__core_2Feval_2El__984:
___L__1465__core_2Feval_2El__1007:
	movl _f__set,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1463__core_2Feval_2El__984
	movl 84(%esp),%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _k__car,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,28(%esp)
	movl _k__env__find__variable,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__1466__core_2Feval_2El__1008:
	movl 28(%esp),%eax
	cmpl $0,%eax
	jne ___L__1467__core_2Feval_2El__1008
	.data
___L__1468__core_2Feval_2El__1008:
	.asciz "set: undefined variable: %s"
	.text
	movl $___L__1468__core_2Feval_2El__1008,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__car,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl _fatal1,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1467__core_2Feval_2El__1008:
___L__1469__core_2Feval_2El__1009:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _k__cdr,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl 84(%esp),%eax
	movl %eax,36(%esp)
	movl _enlist,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1470__core_2Feval_2El__1010:
	movl 28(%esp),%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	jmp ___L__1464__core_2Feval_2El__984
___L__1463__core_2Feval_2El__984:
___L__1471__core_2Feval_2El__984:
___L__1474__core_2Feval_2El__1011:
	movl _f__quote,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	cmpl 28(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1472__core_2Feval_2El__984
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl 84(%esp),%eax
	movl %eax,24(%esp)
	movl _enlist,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	jmp ___L__1473__core_2Feval_2El__984
___L__1472__core_2Feval_2El__984:
	movl $0,%eax
___L__1473__core_2Feval_2El__984:
___L__1464__core_2Feval_2El__984:
___L__1458__core_2Feval_2El__984:
___L__1437__core_2Feval_2El__984:
___L__1411__core_2Feval_2El__984:
___L__1475__core_2Feval_2El__1012:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,80(%esp)
	movl %eax,28(%esp)
___L__1476__core_2Feval_2El__983:
	leal 16(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
	jmp ___L__1401__core_2Feval_2El__980
___L__1400__core_2Feval_2El__980:
___L__1477__core_2Feval_2El__1013:
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1480__core_2Feval_2El__1013
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1482__core_2Feval_2El__1013
	movl __3Clong_3E,%eax
	jmp ___L__1483__core_2Feval_2El__1013
___L__1482__core_2Feval_2El__1013:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1483__core_2Feval_2El__1013:
	jmp ___L__1481__core_2Feval_2El__1013
___L__1480__core_2Feval_2El__1013:
	movl __3Cundefined_3E,%eax
___L__1481__core_2Feval_2El__1013:
	movl %eax,16(%esp)
	movl __3Csymbol_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1478__core_2Feval_2El__1013
___L__1484__core_2Feval_2El__1014:
	movl 84(%esp),%eax
	movl %eax,16(%esp)
	movl 80(%esp),%eax
	movl %eax,20(%esp)
	movl _k__env__find__variable,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1485__core_2Feval_2El__1015:
	movl 20(%esp),%eax
	cmpl $0,%eax
	jne ___L__1486__core_2Feval_2El__1015
	.data
___L__1487__core_2Feval_2El__1015:
	.asciz "undefined variable: %s"
	.text
	movl $___L__1487__core_2Feval_2El__1015,%eax
	movl %eax,16(%esp)
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl _fatal1,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1486__core_2Feval_2El__1015:
___L__1488__core_2Feval_2El__1016:
	movl 20(%esp),%eax
	movl %eax,80(%esp)
___L__1489__core_2Feval_2El__1017:
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl _is__global,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1490__core_2Feval_2El__1017
___L__1492__core_2Feval_2El__1018:
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,16(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
___L__1493__core_2Feval_2El__1019:
	movl 28(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1496__core_2Feval_2El__1019
	movl $1,%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1498__core_2Feval_2El__1019
	movl __3Clong_3E,%eax
	jmp ___L__1499__core_2Feval_2El__1019
___L__1498__core_2Feval_2El__1019:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1499__core_2Feval_2El__1019:
	jmp ___L__1497__core_2Feval_2El__1019
___L__1496__core_2Feval_2El__1019:
	movl __3Cundefined_3E,%eax
___L__1497__core_2Feval_2El__1019:
	movl %eax,16(%esp)
	movl __3Cform_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1495__core_2Feval_2El__1019
	movl 28(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1500__core_2Feval_2El__1019
	movl $1,%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1502__core_2Feval_2El__1019
	movl __3Clong_3E,%eax
	jmp ___L__1503__core_2Feval_2El__1019
___L__1502__core_2Feval_2El__1019:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1503__core_2Feval_2El__1019:
	jmp ___L__1501__core_2Feval_2El__1019
___L__1500__core_2Feval_2El__1019:
	movl __3Cundefined_3E,%eax
___L__1501__core_2Feval_2El__1019:
	movl %eax,16(%esp)
	movl __3Cfixed_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__1495__core_2Feval_2El__1019:
	cmpl $0,%eax
	je ___L__1494__core_2Feval_2El__1019
___L__1504__core_2Feval_2El__1020:
	movl 28(%esp),%eax
	movl %eax,80(%esp)
___L__1494__core_2Feval_2El__1019:
	jmp ___L__1491__core_2Feval_2El__1017
___L__1490__core_2Feval_2El__1017:
___L__1505__core_2Feval_2El__1021:
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,16(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
___L__1506__core_2Feval_2El__1022:
	movl 84(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 28(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Clong_3E,%eax
	movl %eax,44(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1507__core_2Feval_2El__1022
___L__1508__core_2Feval_2El__1023:
	movl 28(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl _s__t,%eax
	movl %eax,24(%esp)
	movl $4,%eax
	movl %eax,40(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 24(%esp),%eax
	movl %eax,(%ecx)
___L__1507__core_2Feval_2El__1022:
___L__1491__core_2Feval_2El__1017:
	jmp ___L__1479__core_2Feval_2El__1013
___L__1478__core_2Feval_2El__1013:
___L__1509__core_2Feval_2El__1024:
	movl _encoders,%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1510__core_2Feval_2El__1024
	movl $1,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1512__core_2Feval_2El__1024
	movl __3Clong_3E,%eax
	jmp ___L__1513__core_2Feval_2El__1024
___L__1512__core_2Feval_2El__1024:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1513__core_2Feval_2El__1024:
	jmp ___L__1511__core_2Feval_2El__1024
___L__1510__core_2Feval_2El__1024:
	movl __3Cundefined_3E,%eax
___L__1511__core_2Feval_2El__1024:
	movl %eax,28(%esp)
	movl _k__array__at,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__1514__core_2Feval_2El__1025:
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1515__core_2Feval_2El__1025
	.data
___L__1516__core_2Feval_2El__1025:
	.asciz "APPLY GOT ENCODER\012... "
	.text
	movl $___L__1516__core_2Feval_2El__1025,%eax
	movl %eax,20(%esp)
	movl 28(%esp),%eax
	movl %eax,24(%esp)
	movl _k__println,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl $1,%eax
	movl %eax,16(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 16(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1515__core_2Feval_2El__1025:
___L__1517__core_2Feval_2El__1026:
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1518__core_2Feval_2El__1026
___L__1519__core_2Feval_2El__1027:
	movl 84(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1520__core_2Feval_2El__1028:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1521__core_2Feval_2El__1029:
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1522__core_2Feval_2El__1030:
	.data
___L__1523__core_2Feval_2El__1030:
	.asciz "APPLY ENCODER\012... "
	.text
	movl $___L__1523__core_2Feval_2El__1030,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
	movl %eax,20(%esp)
	movl _k__print,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1524__core_2Feval_2El__1030:
	.asciz " "
	.text
	movl $___L__1524__core_2Feval_2El__1030,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl _k__print,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1525__core_2Feval_2El__1030:
	.asciz " "
	.text
	movl $___L__1525__core_2Feval_2El__1030,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 84(%esp),%eax
	movl %eax,20(%esp)
	movl _k__println,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1526__core_2Feval_2El__1031:
	movl 28(%esp),%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl _k__apply,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 16(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,80(%esp)
	movl %eax,40(%esp)
___L__1527__core_2Feval_2El__1028:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__pop__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 40(%esp),%eax
___L__1518__core_2Feval_2El__1026:
___L__1479__core_2Feval_2El__1013:
___L__1401__core_2Feval_2El__980:
	movl 80(%esp),%eax
	addl $72,%esp
	leave
	ret
## defn enlist
enlist
	.text
___L__1528__core_2Feval_2El__1028:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1529__core_2Feval_2El__1035:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1532__core_2Feval_2El__1035
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1534__core_2Feval_2El__1035
	movl __3Clong_3E,%eax
	jmp ___L__1535__core_2Feval_2El__1035
___L__1534__core_2Feval_2El__1035:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1535__core_2Feval_2El__1035:
	jmp ___L__1533__core_2Feval_2El__1035
___L__1532__core_2Feval_2El__1035:
	movl __3Cundefined_3E,%eax
___L__1533__core_2Feval_2El__1035:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1530__core_2Feval_2El__1035
___L__1536__core_2Feval_2El__1036:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _k__encode,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1537__core_2Feval_2El__1037:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1538__core_2Feval_2El__1038:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _enlist,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1539__core_2Feval_2El__1039:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1540__core_2Feval_2El__1040:
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__1541__core_2Feval_2El__1039:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__pop__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
	movl %eax,24(%esp)
___L__1542__core_2Feval_2El__1037:
	leal 20(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__pop__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 24(%esp),%eax
	jmp ___L__1531__core_2Feval_2El__1035
___L__1530__core_2Feval_2El__1035:
___L__1543__core_2Feval_2El__1041:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _k__encode,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1531__core_2Feval_2El__1035:
	addl $40,%esp
	leave
	ret
## defn k_expand
k_expand
	.text
___L__1544__core_2Feval_2El__1041:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1545__core_2Feval_2El__921:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1548__core_2Feval_2El__921
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1550__core_2Feval_2El__921
	movl __3Clong_3E,%eax
	jmp ___L__1551__core_2Feval_2El__921
___L__1550__core_2Feval_2El__921:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1551__core_2Feval_2El__921:
	jmp ___L__1549__core_2Feval_2El__921
___L__1548__core_2Feval_2El__921:
	movl __3Cundefined_3E,%eax
___L__1549__core_2Feval_2El__921:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1546__core_2Feval_2El__921
___L__1552__core_2Feval_2El__922:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _k__expand,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1553__core_2Feval_2El__923:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1554__core_2Feval_2El__924:
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1557__core_2Feval_2El__924
	movl $1,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1559__core_2Feval_2El__924
	movl __3Clong_3E,%eax
	jmp ___L__1560__core_2Feval_2El__924
___L__1559__core_2Feval_2El__924:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1560__core_2Feval_2El__924:
	jmp ___L__1558__core_2Feval_2El__924
___L__1557__core_2Feval_2El__924:
	movl __3Cundefined_3E,%eax
___L__1558__core_2Feval_2El__924:
	movl %eax,16(%esp)
	movl __3Csymbol_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1555__core_2Feval_2El__924
___L__1561__core_2Feval_2El__925:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _k__env__find__variable,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1562__core_2Feval_2El__926:
	movl 24(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1564__core_2Feval_2El__926
	movl $1,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1566__core_2Feval_2El__926
	movl __3Clong_3E,%eax
	jmp ___L__1567__core_2Feval_2El__926
___L__1566__core_2Feval_2El__926:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1567__core_2Feval_2El__926:
	jmp ___L__1565__core_2Feval_2El__926
___L__1564__core_2Feval_2El__926:
	movl __3Cundefined_3E,%eax
___L__1565__core_2Feval_2El__926:
	movl %eax,16(%esp)
	movl __3Cvariable_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1563__core_2Feval_2El__926
	movl 24(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__1563__core_2Feval_2El__926:
___L__1568__core_2Feval_2El__927:
	movl 24(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1570__core_2Feval_2El__927
	movl $1,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1572__core_2Feval_2El__927
	movl __3Clong_3E,%eax
	jmp ___L__1573__core_2Feval_2El__927
___L__1572__core_2Feval_2El__927:
	movl $-1,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1573__core_2Feval_2El__927:
	jmp ___L__1571__core_2Feval_2El__927
___L__1570__core_2Feval_2El__927:
	movl __3Cundefined_3E,%eax
___L__1571__core_2Feval_2El__927:
	movl %eax,16(%esp)
	movl __3Cform_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1569__core_2Feval_2El__927
___L__1574__core_2Feval_2El__928:
	movl 24(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Cform_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__1575__core_2Feval_2El__929:
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1576__core_2Feval_2El__929
___L__1577__core_2Feval_2El__930:
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl $1,%eax
	movl %eax,32(%esp)
	movl 64(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__1578__core_2Feval_2El__931:
	leal 32(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__push__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1579__core_2Feval_2El__932:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl _k__apply,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1580__core_2Feval_2El__933:
	movl 20(%esp),%eax
	movl %eax,40(%esp)
	movl 68(%esp),%eax
	movl %eax,36(%esp)
	movl _k__expand,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl %eax,36(%esp)
___L__1581__core_2Feval_2El__931:
	leal 32(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__pop__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 36(%esp),%eax
___L__1582__core_2Feval_2El__934:
	leal 20(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1583__core_2Feval_2El__935:
	movl 20(%esp),%eax
	jmp ___L__1584__core_2Feval_2El__935
___L__1576__core_2Feval_2El__929:
___L__1569__core_2Feval_2El__927:
	jmp ___L__1556__core_2Feval_2El__924
___L__1555__core_2Feval_2El__924:
___L__1556__core_2Feval_2El__924:
___L__1585__core_2Feval_2El__936:
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__1586__core_2Feval_2El__937:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1587__core_2Feval_2El__938:
	movl _s__quote,%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1588__core_2Feval_2El__938
	movl 24(%esp),%eax
	movl %eax,16(%esp)
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl _exlist,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1588__core_2Feval_2El__938:
___L__1589__core_2Feval_2El__939:
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl _s__set,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1590__core_2Feval_2El__939
___L__1591__core_2Feval_2El__940:
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl _k__car,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__1592__core_2Feval_2El__940
	movl $1,%eax
	movl %eax,16(%esp)
	movl 32(%esp),%eax
	andl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1594__core_2Feval_2El__940
	movl __3Clong_3E,%eax
	jmp ___L__1595__core_2Feval_2El__940
___L__1594__core_2Feval_2El__940:
	movl $-1,%eax
	movl %eax,16(%esp)
	movl 32(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1595__core_2Feval_2El__940:
	jmp ___L__1593__core_2Feval_2El__940
___L__1592__core_2Feval_2El__940:
	movl __3Cundefined_3E,%eax
___L__1593__core_2Feval_2El__940:
	movl %eax,32(%esp)
	movl __3Cpair_3E,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1590__core_2Feval_2El__939
___L__1596__core_2Feval_2El__941:
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl _k__caar,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__1597__core_2Feval_2El__941
	movl $1,%eax
	movl %eax,16(%esp)
	movl 32(%esp),%eax
	andl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1599__core_2Feval_2El__941
	movl __3Clong_3E,%eax
	jmp ___L__1600__core_2Feval_2El__941
___L__1599__core_2Feval_2El__941:
	movl $-1,%eax
	movl %eax,16(%esp)
	movl 32(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1600__core_2Feval_2El__941:
	jmp ___L__1598__core_2Feval_2El__941
___L__1597__core_2Feval_2El__941:
	movl __3Cundefined_3E,%eax
___L__1598__core_2Feval_2El__941:
	movl %eax,32(%esp)
	movl __3Csymbol_3E,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1590__core_2Feval_2El__939
___L__1601__core_2Feval_2El__942:
	movl _new__buffer,%eax
	call *%eax
	movl %eax,32(%esp)
___L__1602__core_2Feval_2El__943:
	movl 32(%esp),%eax
	movl %eax,16(%esp)
	.data
___L__1603__core_2Feval_2El__943:
	.asciz "set-"
	.text
	movl $___L__1603__core_2Feval_2El__943,%eax
	movl %eax,36(%esp)
	movl _buffer__append__all,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1604__core_2Feval_2El__944:
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl _buffer__append__all,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 16(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1605__core_2Feval_2El__945:
	movl 32(%esp),%eax
	movl %eax,16(%esp)
	movl _buffer__contents,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _intern,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1606__core_2Feval_2El__946:
	movl $1,%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl _k__concat,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1590__core_2Feval_2El__939:
___L__1607__core_2Feval_2El__947:
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,64(%esp)
___L__1608__core_2Feval_2El__948:
	leal 24(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1609__core_2Feval_2El__949:
	leal 20(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1547__core_2Feval_2El__921
___L__1546__core_2Feval_2El__921:
___L__1610__core_2Feval_2El__950:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1613__core_2Feval_2El__950
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1615__core_2Feval_2El__950
	movl __3Clong_3E,%eax
	jmp ___L__1616__core_2Feval_2El__950
___L__1615__core_2Feval_2El__950:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1616__core_2Feval_2El__950:
	jmp ___L__1614__core_2Feval_2El__950
___L__1613__core_2Feval_2El__950:
	movl __3Cundefined_3E,%eax
___L__1614__core_2Feval_2El__950:
	movl %eax,20(%esp)
	movl __3Csymbol_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1611__core_2Feval_2El__950
___L__1617__core_2Feval_2El__951:
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _k__env__find__variable,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1618__core_2Feval_2El__952:
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1620__core_2Feval_2El__952
	movl $1,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	andl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1622__core_2Feval_2El__952
	movl __3Clong_3E,%eax
	jmp ___L__1623__core_2Feval_2El__952
___L__1622__core_2Feval_2El__952:
	movl $-1,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1623__core_2Feval_2El__952:
	jmp ___L__1621__core_2Feval_2El__952
___L__1620__core_2Feval_2El__952:
	movl __3Cundefined_3E,%eax
___L__1621__core_2Feval_2El__952:
	movl %eax,20(%esp)
	movl __3Cvariable_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1619__core_2Feval_2El__952
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,36(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 16(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__1619__core_2Feval_2El__952:
___L__1624__core_2Feval_2El__953:
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1626__core_2Feval_2El__953
	movl $1,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	andl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1628__core_2Feval_2El__953
	movl __3Clong_3E,%eax
	jmp ___L__1629__core_2Feval_2El__953
___L__1628__core_2Feval_2El__953:
	movl $-1,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1629__core_2Feval_2El__953:
	jmp ___L__1627__core_2Feval_2El__953
___L__1626__core_2Feval_2El__953:
	movl __3Cundefined_3E,%eax
___L__1627__core_2Feval_2El__953:
	movl %eax,20(%esp)
	movl __3Cform_3E,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1625__core_2Feval_2El__953
___L__1630__core_2Feval_2El__954:
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,36(%esp)
	movl __3Cform_3E,%eax
	movl %eax,16(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1631__core_2Feval_2El__955:
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1632__core_2Feval_2El__955
___L__1633__core_2Feval_2El__956:
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__1634__core_2Feval_2El__957:
	leal 32(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__push__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1635__core_2Feval_2El__958:
	movl 68(%esp),%eax
	movl %eax,36(%esp)
	movl 32(%esp),%eax
	movl %eax,16(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 16(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__1636__core_2Feval_2El__959:
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl _k__apply,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__1637__core_2Feval_2El__960:
	movl 32(%esp),%eax
	movl %eax,40(%esp)
	movl 68(%esp),%eax
	movl %eax,36(%esp)
	movl _k__expand,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,64(%esp)
	movl %eax,36(%esp)
___L__1638__core_2Feval_2El__957:
	leal 32(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__pop__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 36(%esp),%eax
___L__1632__core_2Feval_2El__955:
___L__1625__core_2Feval_2El__953:
	jmp ___L__1612__core_2Feval_2El__950
___L__1611__core_2Feval_2El__950:
___L__1639__core_2Feval_2El__961:
	movl _expanders,%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1640__core_2Feval_2El__961
	movl $1,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	andl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1642__core_2Feval_2El__961
	movl __3Clong_3E,%eax
	jmp ___L__1643__core_2Feval_2El__961
___L__1642__core_2Feval_2El__961:
	movl $-1,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1643__core_2Feval_2El__961:
	jmp ___L__1641__core_2Feval_2El__961
___L__1640__core_2Feval_2El__961:
	movl __3Cundefined_3E,%eax
___L__1641__core_2Feval_2El__961:
	movl %eax,20(%esp)
	movl _k__array__at,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1644__core_2Feval_2El__962:
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1645__core_2Feval_2El__962
___L__1646__core_2Feval_2El__963:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,36(%esp)
___L__1647__core_2Feval_2El__964:
	leal 36(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__push__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1648__core_2Feval_2El__965:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl 36(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl _k__apply,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,64(%esp)
	movl %eax,40(%esp)
___L__1649__core_2Feval_2El__964:
	leal 36(%esp),%eax
	movl %eax,32(%esp)
	movl _gc__pop__root,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 40(%esp),%eax
___L__1645__core_2Feval_2El__962:
___L__1612__core_2Feval_2El__950:
___L__1547__core_2Feval_2El__921:
	movl 64(%esp),%eax
___L__1584__core_2Feval_2El__935:
	addl $56,%esp
	leave
	ret
## defn exlist
exlist
	.text
___L__1650__core_2Feval_2El__964:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1651__core_2Feval_2El__969:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1654__core_2Feval_2El__969
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1656__core_2Feval_2El__969
	movl __3Clong_3E,%eax
	jmp ___L__1657__core_2Feval_2El__969
___L__1656__core_2Feval_2El__969:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1657__core_2Feval_2El__969:
	jmp ___L__1655__core_2Feval_2El__969
___L__1654__core_2Feval_2El__969:
	movl __3Cundefined_3E,%eax
___L__1655__core_2Feval_2El__969:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1652__core_2Feval_2El__969
___L__1658__core_2Feval_2El__970:
	movl $0,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _k__expand,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1659__core_2Feval_2El__971:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1660__core_2Feval_2El__972:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _exlist,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1661__core_2Feval_2El__973:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1662__core_2Feval_2El__974:
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__1663__core_2Feval_2El__973:
	leal 24(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__pop__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
	movl %eax,24(%esp)
___L__1664__core_2Feval_2El__971:
	leal 20(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__pop__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 24(%esp),%eax
	jmp ___L__1653__core_2Feval_2El__969
___L__1652__core_2Feval_2El__969:
___L__1665__core_2Feval_2El__975:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _k__expand,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1653__core_2Feval_2El__969:
	addl $40,%esp
	leave
	ret
## defn k_apply
k_apply
	.text
___L__1666__core_2Feval_2El__975:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1667__core_2Feval_2El__903:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1668__core_2Feval_2El__903
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1670__core_2Feval_2El__903
	movl __3Clong_3E,%eax
	jmp ___L__1671__core_2Feval_2El__903
___L__1670__core_2Feval_2El__903:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1671__core_2Feval_2El__903:
	jmp ___L__1669__core_2Feval_2El__903
___L__1668__core_2Feval_2El__903:
	movl __3Cundefined_3E,%eax
___L__1669__core_2Feval_2El__903:
	movl %eax,16(%esp)
___L__1672__core_2Feval_2El__904:
___L__1675__core_2Feval_2El__905:
	movl __3Cexpr_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1673__core_2Feval_2El__904
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl 72(%esp),%eax
	movl %eax,28(%esp)
	movl _k__apply__expr,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	jmp ___L__1674__core_2Feval_2El__904
___L__1673__core_2Feval_2El__904:
___L__1676__core_2Feval_2El__904:
___L__1679__core_2Feval_2El__906:
	movl __3Cfixed_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1677__core_2Feval_2El__904
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cfixed_3E,%eax
	movl %eax,20(%esp)
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl 72(%esp),%eax
	movl %eax,32(%esp)
	movl _k__apply,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	jmp ___L__1678__core_2Feval_2El__904
___L__1677__core_2Feval_2El__904:
___L__1680__core_2Feval_2El__904:
___L__1683__core_2Feval_2El__907:
	movl __3Csubr_3E,%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1681__core_2Feval_2El__904
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl 72(%esp),%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Csubr_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	movl 40(%esp),%ecx
	movl %ecx,12(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1682__core_2Feval_2El__904
___L__1681__core_2Feval_2El__904:
___L__1684__core_2Feval_2El__908:
	movl _applicators,%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__1685__core_2Feval_2El__908
	movl $1,%eax
	movl %eax,20(%esp)
	movl 32(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1687__core_2Feval_2El__908
	movl __3Clong_3E,%eax
	jmp ___L__1688__core_2Feval_2El__908
___L__1687__core_2Feval_2El__908:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 32(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1688__core_2Feval_2El__908:
	jmp ___L__1686__core_2Feval_2El__908
___L__1685__core_2Feval_2El__908:
	movl __3Cundefined_3E,%eax
___L__1686__core_2Feval_2El__908:
	movl %eax,32(%esp)
	movl _k__array__at,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__1689__core_2Feval_2El__909:
	movl 32(%esp),%eax
	cmpl $0,%eax
	je ___L__1690__core_2Feval_2El__909
___L__1692__core_2Feval_2El__910:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
___L__1693__core_2Feval_2El__911:
	leal 24(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__push__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1694__core_2Feval_2El__912:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1695__core_2Feval_2El__913:
	movl 32(%esp),%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl 72(%esp),%eax
	movl %eax,40(%esp)
	movl _k__apply,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,40(%esp)
___L__1696__core_2Feval_2El__911:
	leal 24(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__pop__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 40(%esp),%eax
	jmp ___L__1691__core_2Feval_2El__909
___L__1690__core_2Feval_2El__909:
___L__1697__core_2Feval_2El__914:
	.data
___L__1698__core_2Feval_2El__914:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1698__core_2Feval_2El__914,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1699__core_2Feval_2El__914:
	.asciz "cannot apply: "
	.text
	movl $___L__1699__core_2Feval_2El__914,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _k__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1700__core_2Feval_2El__914:
	.asciz "\012"
	.text
	movl $___L__1700__core_2Feval_2El__914,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1691__core_2Feval_2El__909:
___L__1682__core_2Feval_2El__904:
___L__1678__core_2Feval_2El__904:
___L__1674__core_2Feval_2El__904:
	addl $56,%esp
	leave
	ret
## defn counter
counter
## defn k_apply_expr
k_apply_expr
	.text
___L__1701__core_2Feval_2El__914:
## frame 16 40 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__1702__core_2Feval_2El__874:
	movl _opt__verbose,%eax
	movl %eax,16(%esp)
	movl $2,%eax
	cmpl 16(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1703__core_2Feval_2El__874
	.data
___L__1704__core_2Feval_2El__874:
	.asciz "  A  "
	.text
	movl $___L__1704__core_2Feval_2El__874,%eax
	movl %eax,16(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl _k__dump,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1705__core_2Feval_2El__874:
	.asciz " "
	.text
	movl $___L__1705__core_2Feval_2El__874,%eax
	movl %eax,16(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 84(%esp),%eax
	movl %eax,16(%esp)
	movl _k__dump,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1706__core_2Feval_2El__874:
	.asciz " "
	.text
	movl $___L__1706__core_2Feval_2El__874,%eax
	movl %eax,16(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 88(%esp),%eax
	movl %eax,16(%esp)
	movl _k__dumpln,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _stdout,%eax
	movl %eax,16(%esp)
	movl _fflush_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1703__core_2Feval_2El__874:
___L__1707__core_2Feval_2El__875:
	movl 84(%esp),%eax
	movl %eax,16(%esp)
___L__1708__core_2Feval_2El__876:
	movl 80(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cexpr_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1709__core_2Feval_2El__875:
___L__1710__core_2Feval_2El__877:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _k__car,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1711__core_2Feval_2El__875:
___L__1712__core_2Feval_2El__878:
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl _k__cadr,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__1713__core_2Feval_2El__879:
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,36(%esp)
	movl __3Cexpr_3E,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 88(%esp),%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,44(%esp)
	movl _new_2D_3Ccontext_3E,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	movl 44(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,88(%esp)
___L__1714__core_2Feval_2El__880:
	movl 88(%esp),%eax
	movl %eax,44(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,36(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 44(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,44(%esp)
___L__1715__core_2Feval_2El__881:
	leal 20(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__push__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 88(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__push__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1716__core_2Feval_2El__882:
	jmp ___L__1718__core_2Feval_2El__882
___L__1717__core_2Feval_2El__882:
___L__1719__core_2Feval_2El__883:
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1721__core_2Feval_2El__883
	movl $1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1723__core_2Feval_2El__883
	movl __3Clong_3E,%eax
	jmp ___L__1724__core_2Feval_2El__883
___L__1723__core_2Feval_2El__883:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1724__core_2Feval_2El__883:
	jmp ___L__1722__core_2Feval_2El__883
___L__1721__core_2Feval_2El__883:
	movl __3Cundefined_3E,%eax
___L__1722__core_2Feval_2El__883:
	movl %eax,36(%esp)
	movl __3Cpair_3E,%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1720__core_2Feval_2El__883
	.data
___L__1725__core_2Feval_2El__883:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1725__core_2Feval_2El__883,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1726__core_2Feval_2El__883:
	.asciz "too few arguments: ("
	.text
	movl $___L__1726__core_2Feval_2El__883,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 80(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1727__core_2Feval_2El__883:
	.asciz " "
	.text
	movl $___L__1727__core_2Feval_2El__883,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 84(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1728__core_2Feval_2El__883:
	.asciz ")"
	.text
	movl $___L__1728__core_2Feval_2El__883,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1729__core_2Feval_2El__883:
	.asciz "\012"
	.text
	movl $___L__1729__core_2Feval_2El__883,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1720__core_2Feval_2El__883:
___L__1730__core_2Feval_2El__884:
	movl 44(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,28(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,48(%esp)
	movl 40(%esp),%eax
	movl %eax,52(%esp)
	movl __25typecheck,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 52(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,52(%esp)
	movl 40(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 52(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl _k__set__array__at,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1731__core_2Feval_2El__885:
	movl $1,%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
___L__1732__core_2Feval_2El__886:
	movl $1,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__1718__core_2Feval_2El__882:
___L__1733__core_2Feval_2El__882:
	movl 32(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1734__core_2Feval_2El__882
	movl $1,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1736__core_2Feval_2El__882
	movl __3Clong_3E,%eax
	jmp ___L__1737__core_2Feval_2El__882
___L__1736__core_2Feval_2El__882:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1737__core_2Feval_2El__882:
	jmp ___L__1735__core_2Feval_2El__882
___L__1734__core_2Feval_2El__882:
	movl __3Cundefined_3E,%eax
___L__1735__core_2Feval_2El__882:
	movl %eax,28(%esp)
	movl __3Cpair_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1717__core_2Feval_2El__882
___L__1738__core_2Feval_2El__887:
	movl 32(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 28(%esp),%eax
	cmpl $0,%eax
	je ___L__1740__core_2Feval_2El__887
	movl $1,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1742__core_2Feval_2El__887
	movl __3Clong_3E,%eax
	jmp ___L__1743__core_2Feval_2El__887
___L__1742__core_2Feval_2El__887:
	movl $-1,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1743__core_2Feval_2El__887:
	jmp ___L__1741__core_2Feval_2El__887
___L__1740__core_2Feval_2El__887:
	movl __3Cundefined_3E,%eax
___L__1741__core_2Feval_2El__887:
	movl %eax,28(%esp)
	movl __3Cvariable_3E,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1739__core_2Feval_2El__887
___L__1744__core_2Feval_2El__888:
___L__1745__core_2Feval_2El__889:
	movl 44(%esp),%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,36(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,48(%esp)
	movl 40(%esp),%eax
	movl %eax,52(%esp)
	movl __25typecheck,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 52(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,52(%esp)
	movl 40(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 52(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _k__set__array__at,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1746__core_2Feval_2El__890:
	movl $0,%eax
	movl %eax,16(%esp)
___L__1739__core_2Feval_2El__887:
___L__1747__core_2Feval_2El__891:
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1748__core_2Feval_2El__891
	.data
___L__1749__core_2Feval_2El__891:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1749__core_2Feval_2El__891,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1750__core_2Feval_2El__891:
	.asciz "too many arguments: ("
	.text
	movl $___L__1750__core_2Feval_2El__891,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 80(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1751__core_2Feval_2El__891:
	.asciz " "
	.text
	movl $___L__1751__core_2Feval_2El__891,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 84(%esp),%eax
	movl %eax,36(%esp)
	movl _k__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1752__core_2Feval_2El__891:
	.asciz ")"
	.text
	movl $___L__1752__core_2Feval_2El__891,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1753__core_2Feval_2El__891:
	.asciz "\012"
	.text
	movl $___L__1753__core_2Feval_2El__891,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
___L__1748__core_2Feval_2El__891:
___L__1754__core_2Feval_2El__892:
	movl $1,%eax
	movl %eax,36(%esp)
	movl $1,%eax
	movl %eax,40(%esp)
	movl 20(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1755__core_2Feval_2El__893:
	jmp ___L__1757__core_2Feval_2El__893
___L__1756__core_2Feval_2El__893:
___L__1758__core_2Feval_2El__894:
	movl $0,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl 88(%esp),%eax
	movl %eax,40(%esp)
	movl _k__eval,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1759__core_2Feval_2El__895:
	movl $1,%eax
	movl %eax,40(%esp)
	movl 20(%esp),%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1757__core_2Feval_2El__893:
___L__1760__core_2Feval_2El__893:
	movl 20(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__1761__core_2Feval_2El__893
	movl $1,%eax
	movl %eax,36(%esp)
	movl 40(%esp),%eax
	andl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1763__core_2Feval_2El__893
	movl __3Clong_3E,%eax
	jmp ___L__1764__core_2Feval_2El__893
___L__1763__core_2Feval_2El__893:
	movl $-1,%eax
	movl %eax,36(%esp)
	movl 40(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1764__core_2Feval_2El__893:
	jmp ___L__1762__core_2Feval_2El__893
___L__1761__core_2Feval_2El__893:
	movl __3Cundefined_3E,%eax
___L__1762__core_2Feval_2El__893:
	movl %eax,40(%esp)
	movl __3Cpair_3E,%eax
	cmpl 40(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1756__core_2Feval_2El__893
___L__1765__core_2Feval_2El__896:
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $4,%eax
	movl %eax,36(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,28(%esp)
	movl 40(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl $0,%eax
	je ___L__1766__core_2Feval_2El__896
	movl 88(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl $3,%eax
	movl %eax,48(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 40(%esp),%eax
	movl %eax,52(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 52(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 36(%esp),%eax
	movl %eax,(%ecx)
___L__1766__core_2Feval_2El__896:
	movl 16(%esp),%eax
	movl %eax,40(%esp)
___L__1767__core_2Feval_2El__881:
	leal 88(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 20(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 40(%esp),%eax
	addl $72,%esp
	leave
	ret
## defn k_eval
k_eval
	.text
___L__1768__core_2Feval_2El__881:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1769__core_2Feval_2El__1053:
	movl _opt__verbose,%eax
	movl %eax,16(%esp)
	movl $2,%eax
	cmpl 16(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1770__core_2Feval_2El__1053
	.data
___L__1771__core_2Feval_2El__1053:
	.asciz "  E  "
	.text
	movl $___L__1771__core_2Feval_2El__1053,%eax
	movl %eax,16(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__dump,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1772__core_2Feval_2El__1053:
	.asciz " "
	.text
	movl $___L__1772__core_2Feval_2El__1053,%eax
	movl %eax,16(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl _k__dumpln,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _stdout,%eax
	movl %eax,16(%esp)
	movl _fflush_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1770__core_2Feval_2El__1053:
___L__1773__core_2Feval_2El__1054:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__1774__core_2Feval_2El__1054
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1776__core_2Feval_2El__1054
	movl __3Clong_3E,%eax
	jmp ___L__1777__core_2Feval_2El__1054
___L__1776__core_2Feval_2El__1054:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1777__core_2Feval_2El__1054:
	jmp ___L__1775__core_2Feval_2El__1054
___L__1774__core_2Feval_2El__1054:
	movl __3Cundefined_3E,%eax
___L__1775__core_2Feval_2El__1054:
	movl %eax,16(%esp)
___L__1778__core_2Feval_2El__1055:
___L__1781__core_2Feval_2El__1056:
	movl __3Cundefined_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1779__core_2Feval_2El__1055
	movl 64(%esp),%eax
	jmp ___L__1780__core_2Feval_2El__1055
___L__1779__core_2Feval_2El__1055:
___L__1782__core_2Feval_2El__1055:
___L__1785__core_2Feval_2El__1057:
	movl __3Clong_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1783__core_2Feval_2El__1055
	movl 64(%esp),%eax
	jmp ___L__1784__core_2Feval_2El__1055
___L__1783__core_2Feval_2El__1055:
___L__1786__core_2Feval_2El__1055:
___L__1789__core_2Feval_2El__1058:
	movl __3Cstring_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1787__core_2Feval_2El__1055
	movl 64(%esp),%eax
	jmp ___L__1788__core_2Feval_2El__1055
___L__1787__core_2Feval_2El__1055:
___L__1790__core_2Feval_2El__1055:
___L__1793__core_2Feval_2El__1059:
	movl __3Cvariable_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1791__core_2Feval_2El__1055
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _is__global,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1794__core_2Feval_2El__1059
___L__1796__core_2Feval_2El__1060:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	jmp ___L__1795__core_2Feval_2El__1059
___L__1794__core_2Feval_2El__1059:
___L__1797__core_2Feval_2El__1061:
___L__1798__core_2Feval_2El__1062:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__1799__core_2Feval_2El__1061:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	subl 20(%esp),%eax
	movl %eax,20(%esp)
___L__1800__core_2Feval_2El__1063:
	jmp ___L__1802__core_2Feval_2El__1063
___L__1801__core_2Feval_2El__1063:
___L__1803__core_2Feval_2El__1064:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,68(%esp)
___L__1804__core_2Feval_2El__1065:
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	subl 24(%esp),%eax
	movl %eax,20(%esp)
___L__1802__core_2Feval_2El__1063:
___L__1805__core_2Feval_2El__1063:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	cmpl 24(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1801__core_2Feval_2El__1063
___L__1806__core_2Feval_2El__1066:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,36(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Clong_3E,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl _k__array__at,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1795__core_2Feval_2El__1059:
	jmp ___L__1792__core_2Feval_2El__1055
___L__1791__core_2Feval_2El__1055:
___L__1807__core_2Feval_2El__1055:
___L__1810__core_2Feval_2El__1067:
	movl __3Cpair_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1808__core_2Feval_2El__1055
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl _k__eval,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__1811__core_2Feval_2El__1068:
	leal 28(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__push__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1812__core_2Feval_2El__1069:
	movl _trace__stack,%eax
	movl %eax,20(%esp)
	movl _trace__depth,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl _k__set__array__at,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1813__core_2Feval_2El__1070:
	movl $1,%eax
	movl %eax,36(%esp)
	movl _trace__depth,%eax
	addl 36(%esp),%eax
	movl %eax,_trace__depth
___L__1814__core_2Feval_2El__1071:
	movl 28(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1817__core_2Feval_2El__1071
	movl $1,%eax
	movl %eax,24(%esp)
	movl 36(%esp),%eax
	andl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1819__core_2Feval_2El__1071
	movl __3Clong_3E,%eax
	jmp ___L__1820__core_2Feval_2El__1071
___L__1819__core_2Feval_2El__1071:
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 36(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1820__core_2Feval_2El__1071:
	jmp ___L__1818__core_2Feval_2El__1071
___L__1817__core_2Feval_2El__1071:
	movl __3Cundefined_3E,%eax
___L__1818__core_2Feval_2El__1071:
	movl %eax,36(%esp)
	movl __3Cfixed_3E,%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1815__core_2Feval_2El__1071
___L__1821__core_2Feval_2El__1072:
	movl 28(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cfixed_3E,%eax
	movl %eax,20(%esp)
	movl 36(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl _k__apply,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	jmp ___L__1816__core_2Feval_2El__1071
___L__1815__core_2Feval_2El__1071:
___L__1822__core_2Feval_2El__1073:
	movl $1,%eax
	movl %eax,32(%esp)
	movl 64(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _evlist,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1823__core_2Feval_2El__1074:
	leal 24(%esp),%eax
	movl %eax,32(%esp)
	movl _gc__push__root,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1824__core_2Feval_2El__1075:
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _k__apply,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	movl 20(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1825__core_2Feval_2El__1074:
	leal 24(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
___L__1816__core_2Feval_2El__1071:
	movl %eax,28(%esp)
___L__1826__core_2Feval_2El__1076:
	movl $1,%eax
	movl %eax,24(%esp)
	movl _trace__depth,%eax
	subl 24(%esp),%eax
	movl %eax,_trace__depth
	movl 28(%esp),%eax
	movl %eax,24(%esp)
___L__1827__core_2Feval_2El__1068:
	leal 28(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__pop__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 24(%esp),%eax
	jmp ___L__1809__core_2Feval_2El__1055
___L__1808__core_2Feval_2El__1055:
___L__1828__core_2Feval_2El__1055:
___L__1831__core_2Feval_2El__1078:
	movl __3Csymbol_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1829__core_2Feval_2El__1055
	.data
___L__1832__core_2Feval_2El__1078:
	.asciz "\012eval.k: error: "
	.text
	movl $___L__1832__core_2Feval_2El__1078,%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1833__core_2Feval_2El__1078:
	.asciz "symbol in eval?"
	.text
	movl $___L__1833__core_2Feval_2El__1078,%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	.data
___L__1834__core_2Feval_2El__1078:
	.asciz "\012"
	.text
	movl $___L__1834__core_2Feval_2El__1078,%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
	jmp ___L__1830__core_2Feval_2El__1055
___L__1829__core_2Feval_2El__1055:
___L__1835__core_2Feval_2El__1079:
	movl _evaluators,%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,20(%esp)
	movl 28(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1836__core_2Feval_2El__1079
	movl $1,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	andl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__1838__core_2Feval_2El__1079
	movl __3Clong_3E,%eax
	jmp ___L__1839__core_2Feval_2El__1079
___L__1838__core_2Feval_2El__1079:
	movl $-1,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__1839__core_2Feval_2El__1079:
	jmp ___L__1837__core_2Feval_2El__1079
___L__1836__core_2Feval_2El__1079:
	movl __3Cundefined_3E,%eax
___L__1837__core_2Feval_2El__1079:
	movl %eax,24(%esp)
	movl _k__array__at,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1840__core_2Feval_2El__1080:
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__1841__core_2Feval_2El__1080
___L__1842__core_2Feval_2El__1081:
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,36(%esp)
___L__1843__core_2Feval_2El__1082:
	leal 36(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__push__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1844__core_2Feval_2El__1083:
	movl _trace__stack,%eax
	movl %eax,28(%esp)
	movl _trace__depth,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl _k__set__array__at,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__1845__core_2Feval_2El__1084:
	movl $1,%eax
	movl %eax,32(%esp)
	movl _trace__depth,%eax
	addl 32(%esp),%eax
	movl %eax,_trace__depth
___L__1846__core_2Feval_2El__1085:
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl 36(%esp),%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl _k__apply,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,64(%esp)
___L__1847__core_2Feval_2El__1086:
	movl $1,%eax
	movl %eax,28(%esp)
	movl _trace__depth,%eax
	subl 28(%esp),%eax
	movl %eax,_trace__depth
	movl %eax,28(%esp)
___L__1848__core_2Feval_2El__1082:
	leal 36(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__pop__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
___L__1841__core_2Feval_2El__1080:
	movl 64(%esp),%eax
___L__1830__core_2Feval_2El__1055:
___L__1809__core_2Feval_2El__1055:
___L__1792__core_2Feval_2El__1055:
___L__1788__core_2Feval_2El__1055:
___L__1784__core_2Feval_2El__1055:
___L__1780__core_2Feval_2El__1055:
	addl $56,%esp
	leave
	ret
## defn k_env_define
k_env_define
	.text
___L__1849__core_2Feval_2El__1082:
## frame 16 36 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__1850__core_2Feval_2El__855:
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,20(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__1851__core_2Feval_2El__856:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__array__length,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1852__core_2Feval_2El__857:
	jmp ___L__1854__core_2Feval_2El__857
___L__1853__core_2Feval_2El__857:
___L__1855__core_2Feval_2El__858:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl _k__array__at,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1856__core_2Feval_2El__859:
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 84(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1857__core_2Feval_2El__859
___L__1858__core_2Feval_2El__860:
___L__1859__core_2Feval_2El__861:
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl 88(%esp),%eax
	movl %eax,32(%esp)
	movl $1,%eax
	movl %eax,40(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 32(%esp),%eax
	movl %eax,(%ecx)
___L__1860__core_2Feval_2El__862:
	movl 24(%esp),%eax
	jmp ___L__1861__core_2Feval_2El__862
___L__1857__core_2Feval_2El__859:
___L__1854__core_2Feval_2El__857:
___L__1862__core_2Feval_2El__857:
	movl $0,%eax
	movl %eax,24(%esp)
	movl $1,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	subl 28(%esp),%eax
	movl %eax,20(%esp)
	cmpl 24(%esp),%eax
	setge %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1853__core_2Feval_2El__857
___L__1863__core_2Feval_2El__863:
	movl 80(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__1864__core_2Feval_2El__864:
	movl 84(%esp),%eax
	movl %eax,28(%esp)
	movl 88(%esp),%eax
	movl %eax,32(%esp)
	movl 80(%esp),%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl %eax,44(%esp)
	movl _new_2D_3Cvariable_3E,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	movl 44(%esp),%ecx
	movl %ecx,12(%esp)
	call *%eax
	movl %eax,44(%esp)
___L__1865__core_2Feval_2El__865:
	leal 44(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__push__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1866__core_2Feval_2El__866:
	movl 80(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	addl 32(%esp),%eax
	movl %eax,32(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,36(%esp)
	movl 40(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 32(%esp),%eax
	movl %eax,(%ecx)
___L__1867__core_2Feval_2El__867:
	movl 16(%esp),%eax
	movl %eax,40(%esp)
	movl 44(%esp),%eax
	movl %eax,32(%esp)
	movl _k__array__append,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__1868__core_2Feval_2El__865:
	leal 44(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__pop__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 32(%esp),%eax
___L__1861__core_2Feval_2El__862:
	addl $72,%esp
	leave
	ret
## defn k_env_lookup
k_env_lookup
	.text
___L__1869__core_2Feval_2El__865:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1870__core_2Feval_2El__849:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _k__env__find__variable,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1871__core_2Feval_2El__850:
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__1872__core_2Feval_2El__850
___L__1874__core_2Feval_2El__851:
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	jmp ___L__1873__core_2Feval_2El__850
___L__1872__core_2Feval_2El__850:
___L__1875__core_2Feval_2El__852:
	.data
___L__1876__core_2Feval_2El__852:
	.asciz "undefined variable: %s"
	.text
	movl $___L__1876__core_2Feval_2El__852,%eax
	movl %eax,16(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl _fatal1,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1873__core_2Feval_2El__850:
	addl $56,%esp
	leave
	ret
## defn k_env_find_variable
k_env_find_variable
	.text
___L__1877__core_2Feval_2El__852:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1878__core_2Feval_2El__838:
	jmp ___L__1880__core_2Feval_2El__838
___L__1879__core_2Feval_2El__838:
___L__1881__core_2Feval_2El__839:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,20(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__1882__core_2Feval_2El__840:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__array__length,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1883__core_2Feval_2El__839:
___L__1884__core_2Feval_2El__841:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Carray_3E,%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
___L__1885__core_2Feval_2El__842:
	jmp ___L__1887__core_2Feval_2El__842
___L__1886__core_2Feval_2El__842:
___L__1888__core_2Feval_2El__843:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__1889__core_2Feval_2El__844:
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,40(%esp)
	movl 36(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl 68(%esp),%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1890__core_2Feval_2El__844
___L__1891__core_2Feval_2El__845:
	movl 24(%esp),%eax
	jmp ___L__1892__core_2Feval_2El__845
___L__1890__core_2Feval_2El__844:
___L__1887__core_2Feval_2El__842:
___L__1893__core_2Feval_2El__842:
	movl $1,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	subl 24(%esp),%eax
	movl %eax,20(%esp)
	movl %eax,24(%esp)
	movl $0,%eax
	cmpl 24(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__1886__core_2Feval_2El__842
___L__1894__core_2Feval_2El__846:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,64(%esp)
___L__1880__core_2Feval_2El__838:
	movl 64(%esp),%eax
	cmpl $0,%eax
	jne ___L__1879__core_2Feval_2El__838
___L__1892__core_2Feval_2El__845:
	addl $56,%esp
	leave
	ret
## defn read_quote
read_quote
	.text
___L__1895__core_2Feval_2El__846:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1896__core_2Feval_2El__800:
	movl 52(%esp),%eax
	movl %eax,16(%esp)
	movl _k__read,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1897__core_2Feval_2El__801:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _DONE,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1898__core_2Feval_2El__801
	.data
___L__1899__core_2Feval_2El__801:
	.asciz "EOF while reading quoted literal"
	.text
	movl $___L__1899__core_2Feval_2El__801,%eax
	movl %eax,20(%esp)
	movl _fatal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1898__core_2Feval_2El__801:
___L__1900__core_2Feval_2El__802:
	leal 16(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__push__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1901__core_2Feval_2El__803:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1902__core_2Feval_2El__804:
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl 16(%esp),%eax
	movl %eax,20(%esp)
___L__1903__core_2Feval_2El__802:
	leal 16(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 20(%esp),%eax
	addl $40,%esp
	leave
	ret
## defn read_list
read_list
	.text
___L__1904__core_2Feval_2El__802:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__1905__core_2Feval_2El__786:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
___L__1906__core_2Feval_2El__789:
	leal 20(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__push__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 24(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__push__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1907__core_2Feval_2El__790:
	jmp ___L__1909__core_2Feval_2El__790
___L__1908__core_2Feval_2El__790:
___L__1910__core_2Feval_2El__791:
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__1911__core_2Feval_2El__792:
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl $1,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 32(%esp),%eax
	movl %eax,(%ecx)
	movl %eax,16(%esp)
___L__1909__core_2Feval_2El__790:
___L__1912__core_2Feval_2El__790:
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl _k__read,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl %eax,32(%esp)
	movl _DONE,%eax
	cmpl 32(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1913__core_2Feval_2El__790
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl _s__dot,%eax
	cmpl 32(%esp),%eax
	setne %al
	movzbl %al,%eax
___L__1913__core_2Feval_2El__790:
	cmpl $0,%eax
	jne ___L__1908__core_2Feval_2El__790
___L__1914__core_2Feval_2El__793:
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl _s__dot,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1915__core_2Feval_2El__793
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl _k__read,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
	movl $1,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 32(%esp),%eax
	movl %eax,(%ecx)
___L__1915__core_2Feval_2El__793:
	movl %eax,32(%esp)
___L__1916__core_2Feval_2El__789:
	leal 24(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__pop__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	leal 20(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__pop__root,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 32(%esp),%eax
___L__1917__core_2Feval_2El__794:
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl _getc_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__1918__core_2Feval_2El__795:
	movl 32(%esp),%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1919__core_2Feval_2El__795
___L__1921__core_2Feval_2El__796:
	movl $1,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	jmp ___L__1920__core_2Feval_2El__795
___L__1919__core_2Feval_2El__795:
___L__1922__core_2Feval_2El__797:
	.data
___L__1923__core_2Feval_2El__797:
	.asciz "missing closing '%c' delimiter while reading list"
	.text
	movl $___L__1923__core_2Feval_2El__797,%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl _fatal1,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1920__core_2Feval_2El__795:
	addl $56,%esp
	leave
	ret
## defn k_read
k_read
	.text
___L__1924__core_2Feval_2El__797:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__1925__core_2Feval_2El__808:
	jmp ___L__1927__core_2Feval_2El__808
___L__1926__core_2Feval_2El__808:
___L__1928__core_2Feval_2El__809:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _getc_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__1929__core_2Feval_2El__810:
___L__1932__core_2Feval_2El__811:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _is__blank,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1930__core_2Feval_2El__810
	movl $0,%eax
	jmp ___L__1931__core_2Feval_2El__810
___L__1930__core_2Feval_2El__810:
___L__1933__core_2Feval_2El__810:
___L__1936__core_2Feval_2El__812:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $63,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1934__core_2Feval_2El__810
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _read__char,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1935__core_2Feval_2El__810
___L__1934__core_2Feval_2El__810:
___L__1938__core_2Feval_2El__810:
___L__1941__core_2Feval_2El__813:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $45,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1939__core_2Feval_2El__810
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _getc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _ungetc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl _is__digit10,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1942__core_2Feval_2El__813
___L__1944__core_2Feval_2El__814:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _read__number,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1943__core_2Feval_2El__813
___L__1942__core_2Feval_2El__813:
___L__1945__core_2Feval_2El__815:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _read__symbol,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1943__core_2Feval_2El__813:
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1940__core_2Feval_2El__810
___L__1939__core_2Feval_2El__810:
___L__1946__core_2Feval_2El__810:
___L__1949__core_2Feval_2El__816:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $39,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1947__core_2Feval_2El__810
	movl _s__quote,%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _read__quote,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1948__core_2Feval_2El__810
___L__1947__core_2Feval_2El__810:
___L__1950__core_2Feval_2El__810:
___L__1953__core_2Feval_2El__817:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $96,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1951__core_2Feval_2El__810
	movl _s__quasiquote,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _read__quote,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1952__core_2Feval_2El__810
___L__1951__core_2Feval_2El__810:
___L__1954__core_2Feval_2El__810:
___L__1957__core_2Feval_2El__818:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $44,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1955__core_2Feval_2El__810
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__1958__core_2Feval_2El__819:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl $64,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1959__core_2Feval_2El__819
___L__1961__core_2Feval_2El__820:
	movl _s__unquote__splicing,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,28(%esp)
	movl _read__quote,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1960__core_2Feval_2El__819
___L__1959__core_2Feval_2El__819:
___L__1962__core_2Feval_2El__821:
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _ungetc_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__1963__core_2Feval_2El__822:
	movl _s__unquote,%eax
	movl %eax,24(%esp)
	movl _read__quote,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__1960__core_2Feval_2El__819:
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1956__core_2Feval_2El__810
___L__1955__core_2Feval_2El__810:
___L__1964__core_2Feval_2El__810:
___L__1967__core_2Feval_2El__823:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _is__letter,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1965__core_2Feval_2El__810
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _read__symbol,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1966__core_2Feval_2El__810
___L__1965__core_2Feval_2El__810:
___L__1968__core_2Feval_2El__810:
___L__1971__core_2Feval_2El__824:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $40,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1969__core_2Feval_2El__810
	movl $41,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _read__list,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1970__core_2Feval_2El__810
___L__1969__core_2Feval_2El__810:
___L__1972__core_2Feval_2El__810:
___L__1975__core_2Feval_2El__824:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $41,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1973__core_2Feval_2El__810
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _ungetc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl _DONE,%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1974__core_2Feval_2El__810
___L__1973__core_2Feval_2El__810:
___L__1976__core_2Feval_2El__810:
___L__1979__core_2Feval_2El__825:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $91,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1977__core_2Feval_2El__810
	movl $93,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _read__list,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1978__core_2Feval_2El__810
___L__1977__core_2Feval_2El__810:
___L__1980__core_2Feval_2El__810:
___L__1983__core_2Feval_2El__825:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $93,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1981__core_2Feval_2El__810
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _ungetc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl _DONE,%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1982__core_2Feval_2El__810
___L__1981__core_2Feval_2El__810:
___L__1984__core_2Feval_2El__810:
___L__1987__core_2Feval_2El__826:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $123,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1985__core_2Feval_2El__810
	movl $125,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _read__list,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1986__core_2Feval_2El__810
___L__1985__core_2Feval_2El__810:
___L__1988__core_2Feval_2El__810:
___L__1991__core_2Feval_2El__826:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $125,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1989__core_2Feval_2El__810
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _ungetc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl _DONE,%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1990__core_2Feval_2El__810
___L__1989__core_2Feval_2El__810:
___L__1992__core_2Feval_2El__810:
___L__1995__core_2Feval_2El__827:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _is__digit10,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__1993__core_2Feval_2El__810
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _read__number,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__1994__core_2Feval_2El__810
___L__1993__core_2Feval_2El__810:
___L__1996__core_2Feval_2El__810:
___L__1999__core_2Feval_2El__828:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $59,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__1997__core_2Feval_2El__810
	jmp ___L__2001__core_2Feval_2El__828
___L__2000__core_2Feval_2El__828:
___L__2001__core_2Feval_2El__828:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl %eax,20(%esp)
	movl $10,%eax
	cmpl 20(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2002__core_2Feval_2El__828
___L__2003__core_2Feval_2El__829:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $13,%eax
	cmpl 20(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2002__core_2Feval_2El__828
___L__2004__core_2Feval_2El__830:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _EOF,%eax
	cmpl 20(%esp),%eax
	setne %al
	movzbl %al,%eax
___L__2002__core_2Feval_2El__828:
	cmpl $0,%eax
	jne ___L__2000__core_2Feval_2El__828
	jmp ___L__1998__core_2Feval_2El__810
___L__1997__core_2Feval_2El__810:
___L__2005__core_2Feval_2El__810:
___L__2008__core_2Feval_2El__831:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $34,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2006__core_2Feval_2El__810
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _read__string,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__2007__core_2Feval_2El__810
___L__2006__core_2Feval_2El__810:
___L__2009__core_2Feval_2El__810:
___L__2012__core_2Feval_2El__832:
	movl $0,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	cmpl 24(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2010__core_2Feval_2El__810
	movl _DONE,%eax
	jmp ___L__1937__core_2Feval_2El__812
	jmp ___L__2011__core_2Feval_2El__810
___L__2010__core_2Feval_2El__810:
___L__2013__core_2Feval_2El__833:
	.data
___L__2014__core_2Feval_2El__833:
	.asciz "illegal character: %c"
	.text
	movl $___L__2014__core_2Feval_2El__833,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _fatal1,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2011__core_2Feval_2El__810:
___L__2007__core_2Feval_2El__810:
___L__1998__core_2Feval_2El__810:
___L__1994__core_2Feval_2El__810:
___L__1990__core_2Feval_2El__810:
___L__1986__core_2Feval_2El__810:
___L__1982__core_2Feval_2El__810:
___L__1978__core_2Feval_2El__810:
___L__1974__core_2Feval_2El__810:
___L__1970__core_2Feval_2El__810:
___L__1966__core_2Feval_2El__810:
___L__1956__core_2Feval_2El__810:
___L__1952__core_2Feval_2El__810:
___L__1948__core_2Feval_2El__810:
___L__1940__core_2Feval_2El__810:
___L__1935__core_2Feval_2El__810:
___L__1931__core_2Feval_2El__810:
___L__1927__core_2Feval_2El__808:
	movl $1,%eax
	cmpl $0,%eax
	jne ___L__1926__core_2Feval_2El__808
___L__1937__core_2Feval_2El__812:
	addl $40,%esp
	leave
	ret
## defn read_string
read_string
	.text
___L__2015__core_2Feval_2El__833:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2016__core_2Feval_2El__773:
	movl _new__buffer,%eax
	call *%eax
	movl %eax,16(%esp)
___L__2017__core_2Feval_2El__774:
	jmp ___L__2019__core_2Feval_2El__774
___L__2018__core_2Feval_2El__774:
___L__2020__core_2Feval_2El__775:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _read__char,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,48(%esp)
___L__2021__core_2Feval_2El__776:
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _EOF,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2022__core_2Feval_2El__776
	.data
___L__2023__core_2Feval_2El__776:
	.asciz "unterminated string literal"
	.text
	movl $___L__2023__core_2Feval_2El__776,%eax
	movl %eax,24(%esp)
	movl _fatal,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2022__core_2Feval_2El__776:
___L__2024__core_2Feval_2El__777:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _buffer__append,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2019__core_2Feval_2El__774:
___L__2025__core_2Feval_2El__774:
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,48(%esp)
	movl %eax,20(%esp)
	movl $34,%eax
	cmpl 20(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2018__core_2Feval_2El__774
___L__2026__core_2Feval_2El__778:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl _buffer__append,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2027__core_2Feval_2El__779:
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Cstring_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__2028__core_2Feval_2El__780:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _buffer__delete,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 24(%esp),%eax
	addl $40,%esp
	leave
	ret
## defn read_symbol
read_symbol
	.text
___L__2029__core_2Feval_2El__780:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2030__core_2Feval_2El__762:
	movl _new__buffer,%eax
	call *%eax
	movl %eax,16(%esp)
___L__2031__core_2Feval_2El__763:
	jmp ___L__2033__core_2Feval_2El__763
___L__2032__core_2Feval_2El__763:
___L__2034__core_2Feval_2El__764:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _buffer__append,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2035__core_2Feval_2El__765:
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _getc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,48(%esp)
___L__2033__core_2Feval_2El__763:
___L__2036__core_2Feval_2El__763:
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _is__letter,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__2037__core_2Feval_2El__763
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl _is__digit10,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2037__core_2Feval_2El__763:
	cmpl $0,%eax
	jne ___L__2032__core_2Feval_2El__763
___L__2038__core_2Feval_2El__766:
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _ungetc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2039__core_2Feval_2El__767:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl _buffer__append,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2040__core_2Feval_2El__768:
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl _intern,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__2041__core_2Feval_2El__769:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _buffer__delete,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 24(%esp),%eax
	addl $40,%esp
	leave
	ret
## defn read_number
read_number
	.text
___L__2042__core_2Feval_2El__769:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2043__core_2Feval_2El__747:
	movl _new__buffer,%eax
	call *%eax
	movl %eax,16(%esp)
___L__2044__core_2Feval_2El__748:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $45,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	movl %eax,20(%esp)
___L__2045__core_2Feval_2El__749:
	movl 20(%esp),%eax
	cmpl $0,%eax
	jne ___L__2046__core_2Feval_2El__749
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl _buffer__append,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2046__core_2Feval_2El__749:
___L__2047__core_2Feval_2El__750:
	jmp ___L__2049__core_2Feval_2El__750
___L__2048__core_2Feval_2El__750:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _buffer__append,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2049__core_2Feval_2El__750:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _getc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
	movl %eax,24(%esp)
	movl _is__digit10,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__2048__core_2Feval_2El__750
___L__2050__core_2Feval_2El__751:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $120,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2051__core_2Feval_2El__751
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $1,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2051__core_2Feval_2El__751
___L__2052__core_2Feval_2El__752:
___L__2053__core_2Feval_2El__753:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl _buffer__append,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2054__core_2Feval_2El__754:
	jmp ___L__2056__core_2Feval_2El__754
___L__2055__core_2Feval_2El__754:
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _buffer__append,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2056__core_2Feval_2El__754:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _getc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
	movl %eax,24(%esp)
	movl _is__digit16,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__2055__core_2Feval_2El__754
___L__2051__core_2Feval_2El__751:
___L__2057__core_2Feval_2El__755:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl _ungetc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2058__core_2Feval_2El__756:
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl _buffer__append,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2059__core_2Feval_2El__757:
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl _strtoul_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__2060__core_2Feval_2El__758:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _buffer__delete,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2061__core_2Feval_2El__759:
	movl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__2062__core_2Feval_2El__759
	movl 32(%esp),%eax
	negl %eax
	jmp ___L__2063__core_2Feval_2El__759
___L__2062__core_2Feval_2El__759:
	movl 32(%esp),%eax
___L__2063__core_2Feval_2El__759:
	movl %eax,28(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $56,%esp
	leave
	ret
## defn read_char
read_char
	.text
___L__2064__core_2Feval_2El__759:
## frame 16 28 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2065__core_2Feval_2El__702:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $92,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2066__core_2Feval_2El__702
___L__2068__core_2Feval_2El__703:
___L__2069__core_2Feval_2El__704:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl _getc_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
___L__2070__core_2Feval_2El__705:
___L__2073__core_2Feval_2El__706:
	movl $97,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2071__core_2Feval_2El__705
	movl $7,%eax
	jmp ___L__2072__core_2Feval_2El__705
___L__2071__core_2Feval_2El__705:
___L__2074__core_2Feval_2El__705:
___L__2077__core_2Feval_2El__707:
	movl $98,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2075__core_2Feval_2El__705
	movl $8,%eax
	jmp ___L__2076__core_2Feval_2El__705
___L__2075__core_2Feval_2El__705:
___L__2078__core_2Feval_2El__705:
___L__2081__core_2Feval_2El__708:
	movl $102,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2079__core_2Feval_2El__705
	movl $12,%eax
	jmp ___L__2080__core_2Feval_2El__705
___L__2079__core_2Feval_2El__705:
___L__2082__core_2Feval_2El__705:
___L__2085__core_2Feval_2El__709:
	movl $110,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2083__core_2Feval_2El__705
	movl $10,%eax
	jmp ___L__2084__core_2Feval_2El__705
___L__2083__core_2Feval_2El__705:
___L__2086__core_2Feval_2El__705:
___L__2089__core_2Feval_2El__710:
	movl $114,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2087__core_2Feval_2El__705
	movl $13,%eax
	jmp ___L__2088__core_2Feval_2El__705
___L__2087__core_2Feval_2El__705:
___L__2090__core_2Feval_2El__705:
___L__2093__core_2Feval_2El__711:
	movl $116,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2091__core_2Feval_2El__705
	movl $9,%eax
	jmp ___L__2092__core_2Feval_2El__705
___L__2091__core_2Feval_2El__705:
___L__2094__core_2Feval_2El__705:
___L__2097__core_2Feval_2El__712:
	movl $118,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2095__core_2Feval_2El__705
	movl $11,%eax
	jmp ___L__2096__core_2Feval_2El__705
___L__2095__core_2Feval_2El__705:
___L__2098__core_2Feval_2El__705:
___L__2101__core_2Feval_2El__713:
	movl $117,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2099__core_2Feval_2El__705
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl _getc_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2102__core_2Feval_2El__714:
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2103__core_2Feval_2El__715:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _getc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__2104__core_2Feval_2El__716:
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl _getc_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__2105__core_2Feval_2El__717:
___L__2106__core_2Feval_2El__718:
___L__2107__core_2Feval_2El__719:
___L__2108__core_2Feval_2El__720:
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl _digit__value,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__2109__core_2Feval_2El__719:
	movl $8,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl _digit__value,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 36(%esp),%ecx
	shll %cl,%eax
	addl 32(%esp),%eax
	movl %eax,32(%esp)
___L__2110__core_2Feval_2El__718:
	movl $16,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl %eax,40(%esp)
	movl _digit__value,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 36(%esp),%ecx
	shll %cl,%eax
	addl 32(%esp),%eax
	movl %eax,32(%esp)
___L__2111__core_2Feval_2El__717:
	movl $24,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,40(%esp)
	movl _digit__value,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 36(%esp),%ecx
	shll %cl,%eax
	addl 32(%esp),%eax
	jmp ___L__2100__core_2Feval_2El__705
___L__2099__core_2Feval_2El__705:
___L__2112__core_2Feval_2El__705:
___L__2115__core_2Feval_2El__721:
	movl $120,%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2113__core_2Feval_2El__705
	movl $0,%eax
	movl %eax,28(%esp)
___L__2116__core_2Feval_2El__722:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _getc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
	movl %eax,24(%esp)
	movl _is__hexadecimal,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__2117__core_2Feval_2El__722
___L__2119__core_2Feval_2El__723:
___L__2120__core_2Feval_2El__724:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _digit__value,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__2121__core_2Feval_2El__725:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _getc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
	movl %eax,24(%esp)
	movl _is__hexadecimal,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__2122__core_2Feval_2El__725
___L__2124__core_2Feval_2El__726:
___L__2125__core_2Feval_2El__727:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _digit__value,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	movl $16,%eax
	movl %eax,20(%esp)
	movl 28(%esp),%eax
	mull 20(%esp)
	addl 24(%esp),%eax
	movl %eax,28(%esp)
___L__2126__core_2Feval_2El__728:
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _getc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
	jmp ___L__2123__core_2Feval_2El__725
___L__2122__core_2Feval_2El__725:
___L__2123__core_2Feval_2El__725:
	jmp ___L__2118__core_2Feval_2El__722
___L__2117__core_2Feval_2El__722:
___L__2118__core_2Feval_2El__722:
___L__2127__core_2Feval_2El__729:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _ungetc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%eax
	jmp ___L__2114__core_2Feval_2El__705
___L__2113__core_2Feval_2El__705:
___L__2128__core_2Feval_2El__705:
___L__2131__core_2Feval_2El__731:
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl $48,%eax
	cmpl 28(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2132__core_2Feval_2El__731
	movl $55,%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	cmpl 28(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2132__core_2Feval_2El__731:
	cmpl $0,%eax
	je ___L__2129__core_2Feval_2El__705
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl _digit__value,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__2133__core_2Feval_2El__732:
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
	movl %eax,20(%esp)
	movl _is__octal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__2134__core_2Feval_2El__732
___L__2136__core_2Feval_2El__733:
___L__2137__core_2Feval_2El__734:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _digit__value,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl $8,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	mull 24(%esp)
	addl 20(%esp),%eax
	movl %eax,28(%esp)
___L__2138__core_2Feval_2El__735:
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
	movl %eax,20(%esp)
	movl _is__octal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	je ___L__2139__core_2Feval_2El__735
___L__2141__core_2Feval_2El__736:
___L__2142__core_2Feval_2El__737:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _digit__value,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl $8,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	mull 24(%esp)
	addl 20(%esp),%eax
	movl %eax,28(%esp)
___L__2143__core_2Feval_2El__738:
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _getc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,64(%esp)
	jmp ___L__2140__core_2Feval_2El__735
___L__2139__core_2Feval_2El__735:
___L__2140__core_2Feval_2El__735:
	jmp ___L__2135__core_2Feval_2El__732
___L__2134__core_2Feval_2El__732:
___L__2135__core_2Feval_2El__732:
___L__2144__core_2Feval_2El__739:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _ungetc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%eax
	jmp ___L__2130__core_2Feval_2El__705
___L__2129__core_2Feval_2El__705:
___L__2145__core_2Feval_2El__741:
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl _is__alpha,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	cmpl $0,%eax
	jne ___L__2148__core_2Feval_2El__741
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl _is__digit10,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2148__core_2Feval_2El__741:
	cmpl $0,%eax
	je ___L__2146__core_2Feval_2El__741
___L__2149__core_2Feval_2El__742:
	.data
___L__2150__core_2Feval_2El__742:
	.asciz "illegal character escape: \\%c"
	.text
	movl $___L__2150__core_2Feval_2El__742,%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _fatal1,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__2147__core_2Feval_2El__741
___L__2146__core_2Feval_2El__741:
	movl 64(%esp),%eax
___L__2147__core_2Feval_2El__741:
___L__2130__core_2Feval_2El__705:
___L__2114__core_2Feval_2El__705:
___L__2100__core_2Feval_2El__705:
___L__2096__core_2Feval_2El__705:
___L__2092__core_2Feval_2El__705:
___L__2088__core_2Feval_2El__705:
___L__2084__core_2Feval_2El__705:
___L__2080__core_2Feval_2El__705:
___L__2076__core_2Feval_2El__705:
___L__2072__core_2Feval_2El__705:
	jmp ___L__2067__core_2Feval_2El__702
___L__2066__core_2Feval_2El__702:
	movl 64(%esp),%eax
___L__2067__core_2Feval_2El__702:
	addl $56,%esp
	leave
	ret
## defn digit_value
digit_value
	.text
___L__2151__core_2Feval_2El__742:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2152__core_2Feval_2El__695:
___L__2155__core_2Feval_2El__696:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $48,%eax
	cmpl 16(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2156__core_2Feval_2El__696
	movl $57,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	cmpl 16(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2156__core_2Feval_2El__696:
	cmpl $0,%eax
	je ___L__2153__core_2Feval_2El__695
	movl $48,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	subl 16(%esp),%eax
	jmp ___L__2154__core_2Feval_2El__695
___L__2153__core_2Feval_2El__695:
___L__2157__core_2Feval_2El__695:
___L__2160__core_2Feval_2El__697:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $97,%eax
	cmpl 16(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2161__core_2Feval_2El__697
	movl $122,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	cmpl 16(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2161__core_2Feval_2El__697:
	cmpl $0,%eax
	je ___L__2158__core_2Feval_2El__695
	movl $10,%eax
	movl %eax,16(%esp)
	movl $97,%eax
	subl 16(%esp),%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	subl 16(%esp),%eax
	jmp ___L__2159__core_2Feval_2El__695
___L__2158__core_2Feval_2El__695:
___L__2162__core_2Feval_2El__695:
___L__2165__core_2Feval_2El__698:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $65,%eax
	cmpl 16(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2166__core_2Feval_2El__698
	movl $90,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	cmpl 16(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2166__core_2Feval_2El__698:
	cmpl $0,%eax
	je ___L__2163__core_2Feval_2El__695
	movl $10,%eax
	movl %eax,16(%esp)
	movl $65,%eax
	subl 16(%esp),%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	subl 16(%esp),%eax
	jmp ___L__2164__core_2Feval_2El__695
___L__2163__core_2Feval_2El__695:
___L__2167__core_2Feval_2El__699:
	.data
___L__2168__core_2Feval_2El__699:
	.asciz "illegal digit in character escape"
	.text
	movl $___L__2168__core_2Feval_2El__699,%eax
	movl %eax,16(%esp)
	movl _fatal,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2164__core_2Feval_2El__695:
___L__2159__core_2Feval_2El__695:
___L__2154__core_2Feval_2El__695:
	addl $40,%esp
	leave
	ret
## defn is_hexadecimal
is_hexadecimal
	.text
___L__2169__core_2Feval_2El__699:
## frame 0 4 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2170__core_2Feval_2El__690:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $48,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2172__core_2Feval_2El__690
	movl $57,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2172__core_2Feval_2El__690:
	cmpl $0,%eax
	jne ___L__2171__core_2Feval_2El__690
___L__2173__core_2Feval_2El__691:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $97,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2174__core_2Feval_2El__691
	movl $102,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2174__core_2Feval_2El__691:
	cmpl $0,%eax
	jne ___L__2171__core_2Feval_2El__690
___L__2175__core_2Feval_2El__692:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $65,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2176__core_2Feval_2El__692
	movl $70,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2176__core_2Feval_2El__692:
___L__2171__core_2Feval_2El__690:
	addl $24,%esp
	leave
	ret
## defn is_octal
is_octal
	.text
___L__2177__core_2Feval_2El__692:
## frame 0 4 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2178__core_2Feval_2El__688:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $48,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2179__core_2Feval_2El__688
	movl $55,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2179__core_2Feval_2El__688:
	addl $24,%esp
	leave
	ret
## defn intern
intern
	.text
___L__2180__core_2Feval_2El__688:
## frame 16 36 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__2181__core_2Feval_2El__675:
	movl $0,%eax
	movl %eax,16(%esp)
___L__2182__core_2Feval_2El__676:
	movl $1,%eax
	movl %eax,20(%esp)
	movl _symbols,%eax
	movl %eax,24(%esp)
	movl _k__array__length,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	subl 20(%esp),%eax
	movl %eax,20(%esp)
___L__2183__core_2Feval_2El__677:
	jmp ___L__2185__core_2Feval_2El__677
___L__2184__core_2Feval_2El__677:
___L__2186__core_2Feval_2El__678:
	movl $2,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	addl 28(%esp),%eax
	movl $0,%edx
	divl 24(%esp)
	movl %eax,24(%esp)
___L__2187__core_2Feval_2El__679:
	movl _symbols,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl _k__array__at,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__2188__core_2Feval_2El__678:
___L__2189__core_2Feval_2El__680:
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,44(%esp)
	movl 36(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl _strcmp_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,36(%esp)
___L__2190__core_2Feval_2El__681:
___L__2193__core_2Feval_2El__682:
	movl $0,%eax
	movl %eax,28(%esp)
	movl 36(%esp),%eax
	cmpl 28(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2191__core_2Feval_2El__681
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	subl 28(%esp),%eax
	movl %eax,20(%esp)
	jmp ___L__2192__core_2Feval_2El__681
___L__2191__core_2Feval_2El__681:
___L__2194__core_2Feval_2El__681:
___L__2197__core_2Feval_2El__683:
	movl $0,%eax
	movl %eax,28(%esp)
	movl 36(%esp),%eax
	cmpl 28(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2195__core_2Feval_2El__681
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	addl 28(%esp),%eax
	movl %eax,16(%esp)
	jmp ___L__2196__core_2Feval_2El__681
___L__2195__core_2Feval_2El__681:
___L__2198__core_2Feval_2El__684:
	movl 32(%esp),%eax
	jmp ___L__2199__core_2Feval_2El__684
___L__2196__core_2Feval_2El__681:
___L__2192__core_2Feval_2El__681:
___L__2185__core_2Feval_2El__677:
___L__2200__core_2Feval_2El__677:
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	cmpl 24(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2184__core_2Feval_2El__677
___L__2201__core_2Feval_2El__685:
	movl 80(%esp),%eax
	movl %eax,24(%esp)
	movl _new_2D_3Csymbol_3E,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
	leal 24(%esp),%eax
	movl %eax,32(%esp)
	movl _gc__push__root,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2202__core_2Feval_2El__686:
	movl _symbols,%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl _k__array__insert,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,28(%esp)
___L__2203__core_2Feval_2El__685:
	leal 24(%esp),%eax
	movl %eax,36(%esp)
	movl _gc__pop__root,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
___L__2199__core_2Feval_2El__684:
	addl $72,%esp
	leave
	ret
## defn buffer_contents
buffer_contents
	.text
___L__2204__core_2Feval_2El__685:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2205__core_2Feval_2El__670:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
	movl _buffer__append,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2206__core_2Feval_2El__671:
	movl $1,%eax
	movl %eax,20(%esp)
	movl $2,%eax
	movl %eax,16(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	subl 20(%esp),%eax
	movl %eax,20(%esp)
	movl $2,%eax
	movl %eax,16(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,28(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
___L__2207__core_2Feval_2El__672:
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	addl $40,%esp
	leave
	ret
## defn buffer_append_all
buffer_append_all
	.text
___L__2208__core_2Feval_2El__672:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2209__core_2Feval_2El__663:
	movl $0,%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
___L__2210__core_2Feval_2El__665:
	jmp ___L__2212__core_2Feval_2El__665
___L__2211__core_2Feval_2El__665:
___L__2213__core_2Feval_2El__666:
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl _buffer__append,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2214__core_2Feval_2El__667:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $1,%eax
	addl 28(%esp),%eax
	movl %eax,16(%esp)
___L__2212__core_2Feval_2El__665:
___L__2215__core_2Feval_2El__665:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl 52(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx),%ecx
	xorl %eax,%eax
	movb (%ecx),%al
	movl %eax,20(%esp)
	cmpl $0,%eax
	jne ___L__2211__core_2Feval_2El__665
	addl $40,%esp
	leave
	ret
## defn buffer_append
buffer_append
	.text
___L__2216__core_2Feval_2El__665:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2217__core_2Feval_2El__656:
	movl $1,%eax
	movl %eax,16(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2218__core_2Feval_2El__656
___L__2219__core_2Feval_2El__657:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _buffer__grow,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2218__core_2Feval_2El__656:
___L__2220__core_2Feval_2El__658:
	movl $2,%eax
	movl %eax,16(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__2221__core_2Feval_2El__659:
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,32(%esp)
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx),%ecx
	movl 28(%esp),%eax
	movb %al,(%ecx)
___L__2222__core_2Feval_2El__660:
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $1,%eax
	addl 28(%esp),%eax
	movl %eax,28(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 28(%esp),%eax
	movl %eax,(%ecx)
	addl $56,%esp
	leave
	ret
## defn buffer_grow
buffer_grow
	.text
___L__2223__core_2Feval_2El__660:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2224__core_2Feval_2El__648:
	movl $1,%eax
	movl %eax,16(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__2225__core_2Feval_2El__649:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $2,%eax
	mull 24(%esp)
	movl %eax,24(%esp)
	movl _malloc_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__2226__core_2Feval_2El__650:
	movl 24(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,32(%esp)
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _memcpy_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__2227__core_2Feval_2El__651:
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl _free_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2228__core_2Feval_2El__652:
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,28(%esp)
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 36(%esp),%eax
	movl %eax,(%ecx)
___L__2229__core_2Feval_2El__653:
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl $2,%eax
	mull 36(%esp)
	movl %eax,36(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,32(%esp)
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 36(%esp),%eax
	movl %eax,(%ecx)
	addl $56,%esp
	leave
	ret
## defn buffer_delete
buffer_delete
	.text
___L__2230__core_2Feval_2El__653:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2231__core_2Feval_2El__644:
	movl $0,%eax
	movl %eax,16(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl _free_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2232__core_2Feval_2El__645:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _free_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn new_buffer
new_buffer
	.text
___L__2233__core_2Feval_2El__645:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2234__core_2Feval_2El__637:
	movl $12,%eax
	movl %eax,16(%esp)
	movl _malloc_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2235__core_2Feval_2El__638:
	movl $32,%eax
	movl %eax,20(%esp)
	movl _malloc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
___L__2236__core_2Feval_2El__639:
	movl $32,%eax
	movl %eax,20(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
___L__2237__core_2Feval_2El__640:
	movl $0,%eax
	movl %eax,20(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cbuffer_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn is_letter
is_letter
	.text
___L__2238__core_2Feval_2El__640:
## frame 0 4 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2239__core_2Feval_2El__623:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $33,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2241__core_2Feval_2El__624:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $35,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2242__core_2Feval_2El__624
	movl $38,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2242__core_2Feval_2El__624:
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2243__core_2Feval_2El__625:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $42,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2244__core_2Feval_2El__625
	movl $47,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2244__core_2Feval_2El__625:
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2245__core_2Feval_2El__626:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $58,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2246__core_2Feval_2El__627:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $60,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2247__core_2Feval_2El__627
	movl $90,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2247__core_2Feval_2El__627:
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2248__core_2Feval_2El__628:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $92,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2249__core_2Feval_2El__629:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $94,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2250__core_2Feval_2El__630:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $95,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2251__core_2Feval_2El__631:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $97,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2252__core_2Feval_2El__631
	movl $122,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2252__core_2Feval_2El__631:
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2253__core_2Feval_2El__632:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $124,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2254__core_2Feval_2El__633:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $126,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2240__core_2Feval_2El__623
___L__2255__core_2Feval_2El__634:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $128,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2240__core_2Feval_2El__623:
	addl $24,%esp
	leave
	ret
## defn is_alpha
is_alpha
	.text
___L__2256__core_2Feval_2El__634:
## frame 0 4 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2257__core_2Feval_2El__620:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $97,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2259__core_2Feval_2El__620
	movl $122,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2259__core_2Feval_2El__620:
	cmpl $0,%eax
	jne ___L__2258__core_2Feval_2El__620
___L__2260__core_2Feval_2El__621:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $65,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2261__core_2Feval_2El__621
	movl $90,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2261__core_2Feval_2El__621:
___L__2258__core_2Feval_2El__620:
	addl $24,%esp
	leave
	ret
## defn is_digit16
is_digit16
	.text
___L__2262__core_2Feval_2El__621:
## frame 0 4 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2263__core_2Feval_2El__616:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $48,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2265__core_2Feval_2El__616
	movl $57,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2265__core_2Feval_2El__616:
	cmpl $0,%eax
	jne ___L__2264__core_2Feval_2El__616
___L__2266__core_2Feval_2El__617:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $97,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2267__core_2Feval_2El__617
	movl $102,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2267__core_2Feval_2El__617:
	cmpl $0,%eax
	jne ___L__2264__core_2Feval_2El__616
___L__2268__core_2Feval_2El__618:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $65,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2269__core_2Feval_2El__618
	movl $70,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2269__core_2Feval_2El__618:
___L__2264__core_2Feval_2El__616:
	addl $24,%esp
	leave
	ret
## defn is_digit10
is_digit10
	.text
___L__2270__core_2Feval_2El__618:
## frame 0 4 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2271__core_2Feval_2El__614:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $48,%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2272__core_2Feval_2El__614
	movl $57,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2272__core_2Feval_2El__614:
	addl $24,%esp
	leave
	ret
## defn is_blank
is_blank
	.text
___L__2273__core_2Feval_2El__614:
## frame 0 4 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2274__core_2Feval_2El__607:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $32,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2275__core_2Feval_2El__607
___L__2276__core_2Feval_2El__608:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $9,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2275__core_2Feval_2El__607
___L__2277__core_2Feval_2El__609:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $10,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2275__core_2Feval_2El__607
___L__2278__core_2Feval_2El__610:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $11,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2275__core_2Feval_2El__607
___L__2279__core_2Feval_2El__611:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $12,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2275__core_2Feval_2El__607
___L__2280__core_2Feval_2El__612:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $13,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__2275__core_2Feval_2El__607:
	addl $24,%esp
	leave
	ret
## defn k_dumpln
k_dumpln
	.text
___L__2281__core_2Feval_2El__612:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2282__core_2Feval_2El__596:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl _do__print,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	.data
___L__2283__core_2Feval_2El__596:
	.asciz "\012"
	.text
	movl $___L__2283__core_2Feval_2El__596,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn k_dump
k_dump
	.text
___L__2284__core_2Feval_2El__596:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl _do__print,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn k_println
k_println
	.text
___L__2285__core_2Feval_2El__596:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2286__core_2Feval_2El__595:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
	movl _do__print,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	.data
___L__2287__core_2Feval_2El__595:
	.asciz "\012"
	.text
	movl $___L__2287__core_2Feval_2El__595,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn k_print
k_print
	.text
___L__2288__core_2Feval_2El__595:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
	movl _do__print,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn do_print
do_print
	.text
___L__2289__core_2Feval_2El__595:
## frame 16 32 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
	movl $0,%eax
___L__2290__core_2Feval_2El__530:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__2291__core_2Feval_2El__530
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__2293__core_2Feval_2El__530
	movl __3Clong_3E,%eax
	jmp ___L__2294__core_2Feval_2El__530
___L__2293__core_2Feval_2El__530:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2294__core_2Feval_2El__530:
	jmp ___L__2292__core_2Feval_2El__530
___L__2291__core_2Feval_2El__530:
	movl __3Cundefined_3E,%eax
___L__2292__core_2Feval_2El__530:
	movl %eax,16(%esp)
___L__2295__core_2Feval_2El__531:
___L__2298__core_2Feval_2El__532:
	movl __3Cundefined_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2296__core_2Feval_2El__531
	.data
___L__2299__core_2Feval_2El__532:
	.asciz "nil"
	.text
	movl $___L__2299__core_2Feval_2El__532,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2297__core_2Feval_2El__531
___L__2296__core_2Feval_2El__531:
___L__2300__core_2Feval_2El__531:
___L__2303__core_2Feval_2El__533:
	movl __3Clong_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2301__core_2Feval_2El__531
	.data
___L__2304__core_2Feval_2El__533:
	.asciz "%d"
	.text
	movl $___L__2304__core_2Feval_2El__533,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__2302__core_2Feval_2El__531
___L__2301__core_2Feval_2El__531:
___L__2305__core_2Feval_2El__531:
___L__2308__core_2Feval_2El__534:
	movl __3Cstring_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2306__core_2Feval_2El__531
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__2309__core_2Feval_2El__535:
	movl 68(%esp),%eax
	cmpl $0,%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2310__core_2Feval_2El__535
___L__2312__core_2Feval_2El__536:
	.data
___L__2313__core_2Feval_2El__536:
	.asciz "%s"
	.text
	movl $___L__2313__core_2Feval_2El__536,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__2311__core_2Feval_2El__535
___L__2310__core_2Feval_2El__535:
___L__2314__core_2Feval_2El__537:
	movl $0,%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
___L__2315__core_2Feval_2El__539:
	.data
___L__2316__core_2Feval_2El__539:
	.asciz "\""
	.text
	movl $___L__2316__core_2Feval_2El__539,%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2317__core_2Feval_2El__540:
	jmp ___L__2319__core_2Feval_2El__540
___L__2318__core_2Feval_2El__540:
___L__2320__core_2Feval_2El__541:
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl $32,%eax
	cmpl 28(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2323__core_2Feval_2El__541
	movl $126,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	cmpl 28(%esp),%eax
	setle %al
	movzbl %al,%eax
___L__2323__core_2Feval_2El__541:
	cmpl $0,%eax
	je ___L__2321__core_2Feval_2El__541
___L__2324__core_2Feval_2El__542:
___L__2327__core_2Feval_2El__543:
	movl $34,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2325__core_2Feval_2El__542
	.data
___L__2328__core_2Feval_2El__543:
	.asciz "\\\""
	.text
	movl $___L__2328__core_2Feval_2El__543,%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2326__core_2Feval_2El__542
___L__2325__core_2Feval_2El__542:
___L__2329__core_2Feval_2El__542:
___L__2332__core_2Feval_2El__544:
	movl $92,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2330__core_2Feval_2El__542
	.data
___L__2333__core_2Feval_2El__544:
	.asciz "\\\\"
	.text
	movl $___L__2333__core_2Feval_2El__544,%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2331__core_2Feval_2El__542
___L__2330__core_2Feval_2El__542:
___L__2334__core_2Feval_2El__545:
	.data
___L__2335__core_2Feval_2El__545:
	.asciz "%c"
	.text
	movl $___L__2335__core_2Feval_2El__545,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2331__core_2Feval_2El__542:
___L__2326__core_2Feval_2El__542:
	jmp ___L__2322__core_2Feval_2El__541
___L__2321__core_2Feval_2El__541:
___L__2336__core_2Feval_2El__546:
	.data
___L__2337__core_2Feval_2El__546:
	.asciz "\\%03o"
	.text
	movl $___L__2337__core_2Feval_2El__546,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2322__core_2Feval_2El__541:
___L__2338__core_2Feval_2El__547:
	movl 36(%esp),%eax
	movl %eax,28(%esp)
	movl $1,%eax
	addl 28(%esp),%eax
	movl %eax,36(%esp)
___L__2319__core_2Feval_2El__540:
___L__2339__core_2Feval_2El__540:
	movl 36(%esp),%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx),%ecx
	xorl %eax,%eax
	movb (%ecx),%al
	movl %eax,20(%esp)
	cmpl $0,%eax
	jne ___L__2318__core_2Feval_2El__540
___L__2340__core_2Feval_2El__548:
	.data
___L__2341__core_2Feval_2El__548:
	.asciz "\""
	.text
	movl $___L__2341__core_2Feval_2El__548,%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2311__core_2Feval_2El__535:
	jmp ___L__2307__core_2Feval_2El__531
___L__2306__core_2Feval_2El__531:
___L__2342__core_2Feval_2El__531:
___L__2345__core_2Feval_2El__549:
	movl __3Csymbol_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2343__core_2Feval_2El__531
	.data
___L__2346__core_2Feval_2El__549:
	.asciz "%s"
	.text
	movl $___L__2346__core_2Feval_2El__549,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__2344__core_2Feval_2El__531
___L__2343__core_2Feval_2El__531:
___L__2347__core_2Feval_2El__531:
___L__2350__core_2Feval_2El__550:
	movl __3Cpair_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2348__core_2Feval_2El__531
___L__2351__core_2Feval_2El__551:
	.data
___L__2352__core_2Feval_2El__551:
	.asciz "("
	.text
	movl $___L__2352__core_2Feval_2El__551,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2353__core_2Feval_2El__552:
	jmp ___L__2355__core_2Feval_2El__552
___L__2354__core_2Feval_2El__552:
___L__2356__core_2Feval_2El__553:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl _do__print,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2357__core_2Feval_2El__554:
	movl $1,%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,64(%esp)
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__2359__core_2Feval_2El__554
	movl $1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__2361__core_2Feval_2El__554
	movl __3Clong_3E,%eax
	jmp ___L__2362__core_2Feval_2El__554
___L__2361__core_2Feval_2El__554:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2362__core_2Feval_2El__554:
	jmp ___L__2360__core_2Feval_2El__554
___L__2359__core_2Feval_2El__554:
	movl __3Cundefined_3E,%eax
___L__2360__core_2Feval_2El__554:
	movl %eax,24(%esp)
	movl __3Cpair_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2358__core_2Feval_2El__554
	.data
___L__2363__core_2Feval_2El__554:
	.asciz " "
	.text
	movl $___L__2363__core_2Feval_2El__554,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2358__core_2Feval_2El__554:
___L__2355__core_2Feval_2El__552:
___L__2364__core_2Feval_2El__552:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__2366__core_2Feval_2El__552
	movl $1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__2368__core_2Feval_2El__552
	movl __3Clong_3E,%eax
	jmp ___L__2369__core_2Feval_2El__552
___L__2368__core_2Feval_2El__552:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2369__core_2Feval_2El__552:
	jmp ___L__2367__core_2Feval_2El__552
___L__2366__core_2Feval_2El__552:
	movl __3Cundefined_3E,%eax
___L__2367__core_2Feval_2El__552:
	movl %eax,24(%esp)
	movl __3Cpair_3E,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2365__core_2Feval_2El__552
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _globals,%eax
	cmpl 24(%esp),%eax
	setne %al
	movzbl %al,%eax
___L__2365__core_2Feval_2El__552:
	cmpl $0,%eax
	jne ___L__2354__core_2Feval_2El__552
___L__2370__core_2Feval_2El__555:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl _globals,%eax
	cmpl 24(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2371__core_2Feval_2El__555
___L__2373__core_2Feval_2El__556:
	.data
___L__2374__core_2Feval_2El__556:
	.asciz "<globals>"
	.text
	movl $___L__2374__core_2Feval_2El__556,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2372__core_2Feval_2El__555
___L__2371__core_2Feval_2El__555:
___L__2375__core_2Feval_2El__557:
	movl 64(%esp),%eax
	cmpl $0,%eax
	je ___L__2376__core_2Feval_2El__557
___L__2377__core_2Feval_2El__558:
___L__2378__core_2Feval_2El__559:
	.data
___L__2379__core_2Feval_2El__559:
	.asciz " . "
	.text
	movl $___L__2379__core_2Feval_2El__559,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2380__core_2Feval_2El__560:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _do__print,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2376__core_2Feval_2El__557:
___L__2372__core_2Feval_2El__555:
___L__2381__core_2Feval_2El__561:
	.data
___L__2382__core_2Feval_2El__561:
	.asciz ")"
	.text
	movl $___L__2382__core_2Feval_2El__561,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2349__core_2Feval_2El__531
___L__2348__core_2Feval_2El__531:
___L__2383__core_2Feval_2El__531:
___L__2386__core_2Feval_2El__562:
	movl __3Carray_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2384__core_2Feval_2El__531
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _k__array__length,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2387__core_2Feval_2El__563:
	.data
___L__2388__core_2Feval_2El__563:
	.asciz "Array("
	.text
	movl $___L__2388__core_2Feval_2El__563,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2389__core_2Feval_2El__564:
	movl $0,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	jmp ___L__2391__core_2Feval_2El__564
___L__2390__core_2Feval_2El__564:
___L__2392__core_2Feval_2El__565:
	movl 24(%esp),%eax
	cmpl $0,%eax
	je ___L__2393__core_2Feval_2El__565
	.data
___L__2394__core_2Feval_2El__565:
	.asciz " "
	.text
	movl $___L__2394__core_2Feval_2El__565,%eax
	movl %eax,32(%esp)
	movl _printf_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2393__core_2Feval_2El__565:
___L__2395__core_2Feval_2El__566:
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl _k__array__at,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
	movl _do__print,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2396__core_2Feval_2El__564:
	movl $1,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	addl 28(%esp),%eax
	movl %eax,24(%esp)
___L__2391__core_2Feval_2El__564:
	movl 36(%esp),%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	cmpl 28(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2390__core_2Feval_2El__564
___L__2397__core_2Feval_2El__567:
	.data
___L__2398__core_2Feval_2El__567:
	.asciz ")"
	.text
	movl $___L__2398__core_2Feval_2El__567,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2385__core_2Feval_2El__531
___L__2384__core_2Feval_2El__531:
___L__2399__core_2Feval_2El__531:
___L__2402__core_2Feval_2El__568:
	movl __3Cexpr_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2400__core_2Feval_2El__531
___L__2403__core_2Feval_2El__569:
	.data
___L__2404__core_2Feval_2El__569:
	.asciz "Expr("
	.text
	movl $___L__2404__core_2Feval_2El__569,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2405__core_2Feval_2El__570:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,36(%esp)
	movl __3Cexpr_3E,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl _k__car,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,36(%esp)
	movl _do__print,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2406__core_2Feval_2El__571:
	.data
___L__2407__core_2Feval_2El__571:
	.asciz ")"
	.text
	movl $___L__2407__core_2Feval_2El__571,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2401__core_2Feval_2El__531
___L__2400__core_2Feval_2El__531:
___L__2408__core_2Feval_2El__531:
___L__2411__core_2Feval_2El__572:
	movl __3Cform_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2409__core_2Feval_2El__531
___L__2412__core_2Feval_2El__573:
	.data
___L__2413__core_2Feval_2El__573:
	.asciz "Form("
	.text
	movl $___L__2413__core_2Feval_2El__573,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2414__core_2Feval_2El__574:
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Cform_3E,%eax
	movl %eax,28(%esp)
	movl 36(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _do__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2415__core_2Feval_2El__575:
	.data
___L__2416__core_2Feval_2El__575:
	.asciz ","
	.text
	movl $___L__2416__core_2Feval_2El__575,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2417__core_2Feval_2El__576:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,36(%esp)
	movl __3Cform_3E,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,36(%esp)
	movl _do__print,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2418__core_2Feval_2El__577:
	.data
___L__2419__core_2Feval_2El__577:
	.asciz ")"
	.text
	movl $___L__2419__core_2Feval_2El__577,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2410__core_2Feval_2El__531
___L__2409__core_2Feval_2El__531:
___L__2420__core_2Feval_2El__531:
___L__2423__core_2Feval_2El__578:
	movl __3Cfixed_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2421__core_2Feval_2El__531
___L__2424__core_2Feval_2El__579:
	.data
___L__2425__core_2Feval_2El__579:
	.asciz "Fixed("
	.text
	movl $___L__2425__core_2Feval_2El__579,%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2426__core_2Feval_2El__580:
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Cfixed_3E,%eax
	movl %eax,28(%esp)
	movl 36(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl _do__print,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2427__core_2Feval_2El__581:
	.data
___L__2428__core_2Feval_2El__581:
	.asciz ")"
	.text
	movl $___L__2428__core_2Feval_2El__581,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2422__core_2Feval_2El__531
___L__2421__core_2Feval_2El__531:
___L__2429__core_2Feval_2El__531:
___L__2432__core_2Feval_2El__582:
	movl __3Csubr_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2430__core_2Feval_2El__531
	.data
___L__2433__core_2Feval_2El__582:
	.asciz "Subr(%s)"
	.text
	movl $___L__2433__core_2Feval_2El__582,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Csubr_3E,%eax
	movl %eax,28(%esp)
	movl 36(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__2431__core_2Feval_2El__531
___L__2430__core_2Feval_2El__531:
___L__2434__core_2Feval_2El__531:
___L__2437__core_2Feval_2El__583:
	movl __3Cvariable_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2435__core_2Feval_2El__531
	movl 64(%esp),%eax
	movl %eax,36(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,20(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,24(%esp)
	movl 36(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,36(%esp)
___L__2438__core_2Feval_2El__584:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl _do__print,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2439__core_2Feval_2El__585:
	movl 36(%esp),%eax
	cmpl $0,%eax
	je ___L__2440__core_2Feval_2El__585
___L__2441__core_2Feval_2El__586:
	.data
___L__2442__core_2Feval_2El__586:
	.asciz ".%d+%d"
	.text
	movl $___L__2442__core_2Feval_2El__586,%eax
	movl %eax,20(%esp)
___L__2443__core_2Feval_2El__587:
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,24(%esp)
	movl 32(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,24(%esp)
	movl 32(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
___L__2444__core_2Feval_2El__588:
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,40(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Clong_3E,%eax
	movl %eax,44(%esp)
	movl 28(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__2440__core_2Feval_2El__585:
	jmp ___L__2436__core_2Feval_2El__531
___L__2435__core_2Feval_2El__531:
___L__2445__core_2Feval_2El__531:
___L__2448__core_2Feval_2El__589:
	movl __3Cenv_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	cmpl 36(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2446__core_2Feval_2El__531
___L__2449__core_2Feval_2El__590:
	.data
___L__2450__core_2Feval_2El__590:
	.asciz "Env<%d>"
	.text
	movl $___L__2450__core_2Feval_2El__590,%eax
	movl %eax,36(%esp)
	movl 64(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,20(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Clong_3E,%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	movl %eax,20(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	jmp ___L__2447__core_2Feval_2El__531
___L__2446__core_2Feval_2El__531:
___L__2451__core_2Feval_2El__531:
___L__2454__core_2Feval_2El__591:
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2452__core_2Feval_2El__531
___L__2455__core_2Feval_2El__592:
	.data
___L__2456__core_2Feval_2El__592:
	.asciz "Context<>"
	.text
	movl $___L__2456__core_2Feval_2El__592,%eax
	movl %eax,28(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	jmp ___L__2453__core_2Feval_2El__531
___L__2452__core_2Feval_2El__531:
___L__2457__core_2Feval_2El__593:
	.data
___L__2458__core_2Feval_2El__593:
	.asciz "<type:%d>"
	.text
	movl $___L__2458__core_2Feval_2El__593,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl _printf_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2453__core_2Feval_2El__531:
___L__2447__core_2Feval_2El__531:
___L__2436__core_2Feval_2El__531:
___L__2431__core_2Feval_2El__531:
___L__2422__core_2Feval_2El__531:
___L__2410__core_2Feval_2El__531:
___L__2401__core_2Feval_2El__531:
___L__2385__core_2Feval_2El__531:
___L__2349__core_2Feval_2El__531:
___L__2344__core_2Feval_2El__531:
___L__2307__core_2Feval_2El__531:
___L__2302__core_2Feval_2El__531:
___L__2297__core_2Feval_2El__531:
	addl $56,%esp
	leave
	ret
## defn k_array_insert
k_array_insert
	.text
___L__2459__core_2Feval_2El__593:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2460__core_2Feval_2El__520:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _k__array__length,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2461__core_2Feval_2El__521:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl 72(%esp),%eax
	movl %eax,24(%esp)
	movl _k__array__append,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2462__core_2Feval_2El__522:
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl 68(%esp),%eax
	cmpl 24(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2463__core_2Feval_2El__522
___L__2464__core_2Feval_2El__523:
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Carray_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
___L__2465__core_2Feval_2El__524:
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl $4,%eax
	mull 20(%esp)
	movl %eax,20(%esp)
	movl 24(%esp),%eax
	addl 20(%esp),%eax
	movl %eax,20(%esp)
___L__2466__core_2Feval_2El__525:
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl $4,%eax
	addl 32(%esp),%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 68(%esp),%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	subl 36(%esp),%eax
	movl %eax,36(%esp)
	movl $4,%eax
	mull 36(%esp)
	movl %eax,36(%esp)
	movl _memmove_24stub,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	movl 36(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__2463__core_2Feval_2El__522:
___L__2467__core_2Feval_2El__526:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl 72(%esp),%eax
	movl %eax,20(%esp)
	movl _k__set__array__at,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 20(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	addl $56,%esp
	leave
	ret
## defn k_array_append
k_array_append
	.text
___L__2468__core_2Feval_2El__526:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2469__core_2Feval_2El__517:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _k__array__length,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _k__set__array__at,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 24(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn k_set_array_at
k_set_array_at
	.text
___L__2470__core_2Feval_2El__517:
## frame 16 36 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__2471__core_2Feval_2El__501:
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__2473__core_2Feval_2El__501
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__2475__core_2Feval_2El__501
	movl __3Clong_3E,%eax
	jmp ___L__2476__core_2Feval_2El__501
___L__2475__core_2Feval_2El__501:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2476__core_2Feval_2El__501:
	jmp ___L__2474__core_2Feval_2El__501
___L__2473__core_2Feval_2El__501:
	movl __3Cundefined_3E,%eax
___L__2474__core_2Feval_2El__501:
	movl %eax,16(%esp)
	movl __3Carray_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2472__core_2Feval_2El__501
___L__2477__core_2Feval_2El__502:
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Carray_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__2478__core_2Feval_2El__503:
	movl 80(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Carray_3E,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__2479__core_2Feval_2El__504:
	movl 84(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	cmpl 28(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2480__core_2Feval_2El__504
___L__2481__core_2Feval_2El__505:
___L__2482__core_2Feval_2El__506:
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 84(%esp),%eax
	cmpl 28(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2483__core_2Feval_2El__506
___L__2484__core_2Feval_2El__507:
	movl $4,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__size,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl $0,%edx
	divl 28(%esp)
	movl %eax,28(%esp)
___L__2485__core_2Feval_2El__508:
	jmp ___L__2487__core_2Feval_2El__508
___L__2486__core_2Feval_2El__508:
	movl $2,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	mull 24(%esp)
	movl %eax,28(%esp)
___L__2487__core_2Feval_2El__508:
	movl 84(%esp),%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	cmpl 24(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2486__core_2Feval_2El__508
___L__2488__core_2Feval_2El__509:
	leal 80(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__push__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2489__core_2Feval_2El__510:
	movl __3C__array_3E,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl $4,%eax
	mull 32(%esp)
	movl %eax,32(%esp)
	movl _new_2Doops,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,32(%esp)
___L__2490__core_2Feval_2El__511:
	movl 32(%esp),%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl $4,%eax
	movl %eax,40(%esp)
	movl 20(%esp),%eax
	mull 40(%esp)
	movl %eax,40(%esp)
	movl _memcpy_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__2491__core_2Feval_2El__512:
	movl 80(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Carray_3E,%eax
	movl %eax,44(%esp)
	movl 40(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 36(%esp),%eax
	movl %eax,(%ecx)
	movl %eax,16(%esp)
___L__2492__core_2Feval_2El__513:
	movl 80(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl 84(%esp),%eax
	movl %eax,40(%esp)
	movl $1,%eax
	addl 40(%esp),%eax
	movl %eax,40(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
	movl __3Carray_3E,%eax
	movl %eax,24(%esp)
	movl 32(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 36(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 40(%esp),%eax
	movl %eax,(%ecx)
	movl %eax,32(%esp)
___L__2493__core_2Feval_2El__509:
	leal 80(%esp),%eax
	movl %eax,40(%esp)
	movl _gc__pop__root,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 32(%esp),%eax
___L__2483__core_2Feval_2El__506:
___L__2494__core_2Feval_2El__514:
	movl 88(%esp),%eax
	movl %eax,28(%esp)
	movl 84(%esp),%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 28(%esp),%eax
	movl %eax,(%ecx)
___L__2480__core_2Feval_2El__504:
___L__2472__core_2Feval_2El__501:
	addl $72,%esp
	leave
	ret
## defn k_array_at
k_array_at
	.text
___L__2495__core_2Feval_2El__514:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2496__core_2Feval_2El__494:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__2498__core_2Feval_2El__494
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__2500__core_2Feval_2El__494
	movl __3Clong_3E,%eax
	jmp ___L__2501__core_2Feval_2El__494
___L__2500__core_2Feval_2El__494:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2501__core_2Feval_2El__494:
	jmp ___L__2499__core_2Feval_2El__494
___L__2498__core_2Feval_2El__494:
	movl __3Cundefined_3E,%eax
___L__2499__core_2Feval_2El__494:
	movl %eax,16(%esp)
	movl __3Carray_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2497__core_2Feval_2El__494
___L__2502__core_2Feval_2El__495:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Carray_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__2503__core_2Feval_2El__496:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Carray_3E,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
___L__2504__core_2Feval_2El__497:
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	cmpl 28(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2505__core_2Feval_2El__497
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl 68(%esp),%eax
	cmpl 28(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2505__core_2Feval_2El__497
___L__2506__core_2Feval_2El__498:
	movl 68(%esp),%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2505__core_2Feval_2El__497:
___L__2497__core_2Feval_2El__494:
	addl $56,%esp
	leave
	ret
## defn k_array_length
k_array_length
	.text
___L__2507__core_2Feval_2El__498:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2508__core_2Feval_2El__491:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Carray_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	addl $40,%esp
	leave
	ret
## defn k_concat
k_concat
	.text
___L__2509__core_2Feval_2El__491:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2510__core_2Feval_2El__483:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__2513__core_2Feval_2El__483
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	andl 20(%esp),%eax
	cmpl $0,%eax
	je ___L__2515__core_2Feval_2El__483
	movl __3Clong_3E,%eax
	jmp ___L__2516__core_2Feval_2El__483
___L__2515__core_2Feval_2El__483:
	movl $-1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2516__core_2Feval_2El__483:
	jmp ___L__2514__core_2Feval_2El__483
___L__2513__core_2Feval_2El__483:
	movl __3Cundefined_3E,%eax
___L__2514__core_2Feval_2El__483:
	movl %eax,16(%esp)
	movl __3Cpair_3E,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2511__core_2Feval_2El__483
___L__2517__core_2Feval_2El__484:
___L__2518__core_2Feval_2El__485:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _k__concat,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,52(%esp)
___L__2519__core_2Feval_2El__486:
	leal 52(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__push__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2520__core_2Feval_2El__487:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 48(%esp),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,16(%esp)
	movl _new_2D_3Cpair_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 16(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2521__core_2Feval_2El__486:
	leal 52(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__pop__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	jmp ___L__2512__core_2Feval_2El__483
___L__2511__core_2Feval_2El__483:
	movl 52(%esp),%eax
___L__2512__core_2Feval_2El__483:
	addl $40,%esp
	leave
	ret
## defn k_string_length
k_string_length
	.text
___L__2522__core_2Feval_2El__486:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2523__core_2Feval_2El__480:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,20(%esp)
	movl __3Clong_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	addl $40,%esp
	leave
	ret
## defn k_caddr
k_caddr
	.text
___L__2524__core_2Feval_2El__480:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2525__core_2Feval_2El__478:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__cdr,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _k__cdr,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn k_cddr
k_cddr
	.text
___L__2526__core_2Feval_2El__478:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2527__core_2Feval_2El__476:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__cdr,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _k__cdr,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn k_cadr
k_cadr
	.text
___L__2528__core_2Feval_2El__476:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2529__core_2Feval_2El__475:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__cdr,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn k_caar
k_caar
	.text
___L__2530__core_2Feval_2El__475:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2531__core_2Feval_2El__474:
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl _k__car,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn k_cdr
k_cdr
	.text
___L__2532__core_2Feval_2El__474:
## frame 0 8 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2533__core_2Feval_2El__472:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $0,%eax
	movl 0(%esp),%eax
	cmpl $0,%eax
	je ___L__2535__core_2Feval_2El__472
	movl $1,%eax
	movl %eax,4(%esp)
	movl 0(%esp),%eax
	andl 4(%esp),%eax
	cmpl $0,%eax
	je ___L__2537__core_2Feval_2El__472
	movl __3Clong_3E,%eax
	jmp ___L__2538__core_2Feval_2El__472
___L__2537__core_2Feval_2El__472:
	movl $-1,%eax
	movl %eax,4(%esp)
	movl 0(%esp),%eax
	movl 4(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2538__core_2Feval_2El__472:
	jmp ___L__2536__core_2Feval_2El__472
___L__2535__core_2Feval_2El__472:
	movl __3Cundefined_3E,%eax
___L__2536__core_2Feval_2El__472:
	movl %eax,0(%esp)
	movl __3Cpair_3E,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2534__core_2Feval_2El__472
	movl $1,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	movl 0(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2534__core_2Feval_2El__472:
	addl $24,%esp
	leave
	ret
## defn k_car
k_car
	.text
___L__2539__core_2Feval_2El__472:
## frame 0 8 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2540__core_2Feval_2El__471:
	movl 32(%esp),%eax
	movl %eax,0(%esp)
	movl $0,%eax
	movl 0(%esp),%eax
	cmpl $0,%eax
	je ___L__2542__core_2Feval_2El__471
	movl $1,%eax
	movl %eax,4(%esp)
	movl 0(%esp),%eax
	andl 4(%esp),%eax
	cmpl $0,%eax
	je ___L__2544__core_2Feval_2El__471
	movl __3Clong_3E,%eax
	jmp ___L__2545__core_2Feval_2El__471
___L__2544__core_2Feval_2El__471:
	movl $-1,%eax
	movl %eax,4(%esp)
	movl 0(%esp),%eax
	movl 4(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2545__core_2Feval_2El__471:
	jmp ___L__2543__core_2Feval_2El__471
___L__2542__core_2Feval_2El__471:
	movl __3Cundefined_3E,%eax
___L__2543__core_2Feval_2El__471:
	movl %eax,0(%esp)
	movl __3Cpair_3E,%eax
	cmpl 0(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2541__core_2Feval_2El__471
	movl $0,%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	movl 0(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
___L__2541__core_2Feval_2El__471:
	addl $24,%esp
	leave
	ret
## defn is_global
is_global
	.text
___L__2546__core_2Feval_2El__471:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2547__core_2Feval_2El__466:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl $2,%eax
	movl %eax,20(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__2548__core_2Feval_2El__467:
	movl 16(%esp),%eax
	cmpl $0,%eax
	je ___L__2549__core_2Feval_2El__467
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,24(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Clong_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	cmpl 20(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__2549__core_2Feval_2El__467:
	addl $56,%esp
	leave
	ret
## defn new-<context>
new-<context>
	.text
___L__2550__core_2Feval_2El__467:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2551__core_2Feval_2El__456:
	movl $0,%eax
	movl %eax,16(%esp)
___L__2552__core_2Feval_2El__457:
	movl 68(%esp),%eax
	cmpl $0,%eax
	je ___L__2555__core_2Feval_2El__457
	movl 68(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $3,%eax
	movl %eax,24(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
___L__2555__core_2Feval_2El__457:
	cmpl $0,%eax
	je ___L__2553__core_2Feval_2El__457
___L__2556__core_2Feval_2El__458:
___L__2557__core_2Feval_2El__459:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 24(%esp),%eax
	movl %eax,(%ecx)
___L__2558__core_2Feval_2El__460:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl 72(%esp),%eax
	movl %eax,24(%esp)
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,36(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 24(%esp),%eax
	movl %eax,(%ecx)
	jmp ___L__2554__core_2Feval_2El__457
___L__2553__core_2Feval_2El__457:
___L__2559__core_2Feval_2El__461:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl 68(%esp),%eax
	movl %eax,24(%esp)
	movl 72(%esp),%eax
	movl %eax,32(%esp)
	movl _new_2Dbase_2D_3Ccontext_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 32(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2560__core_2Feval_2El__462:
	movl 68(%esp),%eax
	cmpl $0,%eax
	je ___L__2561__core_2Feval_2El__462
	movl 68(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl $3,%eax
	movl %eax,20(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 24(%esp),%eax
	movl %eax,(%ecx)
___L__2561__core_2Feval_2El__462:
___L__2554__core_2Feval_2El__457:
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-base-<context>
new-base-<context>
	.text
___L__2562__core_2Feval_2El__462:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2563__core_2Feval_2El__440:
	movl __3Ccontext_3E,%eax
	movl %eax,16(%esp)
	movl $20,%eax
	movl %eax,20(%esp)
	movl _new_2Doops,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2564__core_2Feval_2El__441:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2565__core_2Feval_2El__442:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2566__core_2Feval_2El__443:
	movl 72(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2567__core_2Feval_2El__444:
	movl $0,%eax
	movl %eax,16(%esp)
	movl _new_2D_3Carray_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Ccontext_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
___L__2568__core_2Feval_2El__441:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<env>
new-<env>
	.text
___L__2569__core_2Feval_2El__441:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2570__core_2Feval_2El__431:
	movl __3Cenv_3E,%eax
	movl %eax,16(%esp)
	movl $20,%eax
	movl %eax,20(%esp)
	movl _new_2Doops,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2571__core_2Feval_2El__432:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2572__core_2Feval_2El__433:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2573__core_2Feval_2El__434:
	movl 64(%esp),%eax
	cmpl $0,%eax
	je ___L__2574__core_2Feval_2El__434
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,28(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl $0,%eax
	movl %eax,32(%esp)
	movl __3Clong_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	addl 16(%esp),%eax
	jmp ___L__2575__core_2Feval_2El__434
___L__2574__core_2Feval_2El__434:
	movl $0,%eax
___L__2575__core_2Feval_2El__434:
	movl %eax,16(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2576__core_2Feval_2El__435:
	movl 72(%esp),%eax
	movl %eax,16(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2577__core_2Feval_2El__436:
	movl $0,%eax
	movl %eax,16(%esp)
	movl _new_2D_3Carray_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $3,%eax
	movl %eax,24(%esp)
	movl __3Cenv_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
___L__2578__core_2Feval_2El__432:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn set_tail
set_tail
## defn set_head
set_head
## defn get_tail
get_tail
## defn get_head
get_head
## defn get_long
get_long
## defn is_long
is_long
## defn put
put
## defn get
get
## defn type_check_fail
type_check_fail
	.text
___L__2579__core_2Feval_2El__432:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2580__core_2Feval_2El__410:
	.data
___L__2581__core_2Feval_2El__410:
	.asciz "illegal type: expected %d got %d"
	.text
	movl $___L__2581__core_2Feval_2El__410,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl 52(%esp),%eax
	movl %eax,24(%esp)
	movl _fatal2,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 24(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn is
is
## defn get-type
get-type
## defn new-<variable>
new-<variable>
	.text
___L__2582__core_2Feval_2El__410:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2583__core_2Feval_2El__387:
	movl __3Cvariable_3E,%eax
	movl %eax,16(%esp)
	movl $20,%eax
	movl %eax,20(%esp)
	movl _new_2Doops,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2584__core_2Feval_2El__388:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2585__core_2Feval_2El__389:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2586__core_2Feval_2El__390:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2587__core_2Feval_2El__391:
	movl 72(%esp),%eax
	movl %eax,16(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2588__core_2Feval_2El__392:
	movl 76(%esp),%eax
	movl %eax,16(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $3,%eax
	movl %eax,24(%esp)
	movl __3Cvariable_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
___L__2589__core_2Feval_2El__388:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<subr>
new-<subr>
	.text
___L__2590__core_2Feval_2El__388:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2591__core_2Feval_2El__380:
	movl __3Csubr_3E,%eax
	movl %eax,16(%esp)
	movl $16,%eax
	movl %eax,20(%esp)
	movl _new_2Dbits,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2592__core_2Feval_2El__381:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2593__core_2Feval_2El__382:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Csubr_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2594__core_2Feval_2El__383:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Csubr_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
___L__2595__core_2Feval_2El__381:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<fixed>
new-<fixed>
	.text
___L__2596__core_2Feval_2El__381:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2597__core_2Feval_2El__374:
	movl __3Cfixed_3E,%eax
	movl %eax,16(%esp)
	movl $4,%eax
	movl %eax,20(%esp)
	movl _new_2Doops,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2598__core_2Feval_2El__375:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2599__core_2Feval_2El__376:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cfixed_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
___L__2600__core_2Feval_2El__375:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<form>
new-<form>
	.text
___L__2601__core_2Feval_2El__375:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2602__core_2Feval_2El__367:
	movl __3Cform_3E,%eax
	movl %eax,16(%esp)
	movl $8,%eax
	movl %eax,20(%esp)
	movl _new_2Doops,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2603__core_2Feval_2El__368:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2604__core_2Feval_2El__369:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cform_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2605__core_2Feval_2El__370:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cform_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
___L__2606__core_2Feval_2El__368:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<expr>
new-<expr>
	.text
___L__2607__core_2Feval_2El__368:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2608__core_2Feval_2El__361:
	movl __3Cexpr_3E,%eax
	movl %eax,16(%esp)
	movl $16,%eax
	movl %eax,20(%esp)
	movl _new_2Doops,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2609__core_2Feval_2El__362:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cexpr_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2610__core_2Feval_2El__363:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cexpr_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<array>
new-<array>
	.text
___L__2611__core_2Feval_2El__363:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2612__core_2Feval_2El__353:
	movl 64(%esp),%eax
	cmpl $0,%eax
	je ___L__2613__core_2Feval_2El__353
	movl 64(%esp),%eax
	jmp ___L__2614__core_2Feval_2El__353
___L__2613__core_2Feval_2El__353:
	movl $1,%eax
___L__2614__core_2Feval_2El__353:
	movl %eax,16(%esp)
___L__2615__core_2Feval_2El__354:
	movl __3Carray_3E,%eax
	movl %eax,20(%esp)
	movl $8,%eax
	movl %eax,24(%esp)
	movl _new_2Doops,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,24(%esp)
___L__2616__core_2Feval_2El__355:
	leal 24(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__push__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2617__core_2Feval_2El__356:
	movl 64(%esp),%eax
	movl %eax,20(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Carray_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
___L__2618__core_2Feval_2El__357:
	movl __3C__array_3E,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl $4,%eax
	mull 28(%esp)
	movl %eax,28(%esp)
	movl _new_2Doops,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,28(%esp)
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Carray_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 28(%esp),%eax
	movl %eax,(%ecx)
	movl 24(%esp),%eax
	movl %eax,28(%esp)
___L__2619__core_2Feval_2El__355:
	leal 24(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__pop__root,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 28(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<pair>
new-<pair>
	.text
___L__2620__core_2Feval_2El__355:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2621__core_2Feval_2El__347:
	movl __3Cpair_3E,%eax
	movl %eax,16(%esp)
	movl $12,%eax
	movl %eax,20(%esp)
	movl _new_2Doops,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2622__core_2Feval_2El__348:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cpair_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2623__core_2Feval_2El__349:
	movl 68(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cpair_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<symbol>
new-<symbol>
	.text
___L__2624__core_2Feval_2El__349:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2625__core_2Feval_2El__342:
	movl __3Csymbol_3E,%eax
	movl %eax,16(%esp)
	movl $4,%eax
	movl %eax,20(%esp)
	movl _new_2Dbits,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2626__core_2Feval_2El__343:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _strdup_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Csymbol_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<string>
new-<string>
	.text
___L__2627__core_2Feval_2El__343:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2628__core_2Feval_2El__336:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _strlen_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2629__core_2Feval_2El__337:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl ___new_2D_3Cstring_3E,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2630__core_2Feval_2El__338:
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl _memcpy_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	movl 20(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn _new-<string>
_new-<string>
	.text
___L__2631__core_2Feval_2El__338:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2632__core_2Feval_2El__329:
	movl __3Cstring_3E,%eax
	movl %eax,16(%esp)
	movl $8,%eax
	movl %eax,20(%esp)
	movl _new_2Doops,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2633__core_2Feval_2El__330:
	leal 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__push__root,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2634__core_2Feval_2El__331:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _new_2D_3Clong_3E,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
___L__2635__core_2Feval_2El__332:
	movl $1,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	addl 16(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__malloc__atomic,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cstring_3E,%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	movl %eax,16(%esp)
___L__2636__core_2Feval_2El__330:
	leal 20(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__pop__root,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-<long>
new-<long>
	.text
___L__2637__core_2Feval_2El__330:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2638__core_2Feval_2El__324:
	movl __3Clong_3E,%eax
	movl %eax,16(%esp)
	movl $4,%eax
	movl %eax,20(%esp)
	movl _new_2Dbits,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2639__core_2Feval_2El__325:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Clong_3E,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 16(%esp),%eax
	movl %eax,(%ecx)
	movl 20(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn new-oops
new-oops
	.text
___L__2640__core_2Feval_2El__325:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2641__core_2Feval_2El__317:
	movl 52(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__malloc,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2642__core_2Feval_2El__318:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
	movl 16(%esp),%eax
	addl $40,%esp
	leave
	ret
## defn new-bits
new-bits
	.text
___L__2643__core_2Feval_2El__318:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2644__core_2Feval_2El__312:
	movl 52(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__malloc__atomic,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2645__core_2Feval_2El__313:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl $-1,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
	movl 16(%esp),%eax
	addl $40,%esp
	leave
	ret
## defn opt_optimised
opt_optimised
## defn opt_verbose
opt_verbose
## defn f_define
f_define
## defn f_let
f_let
## defn f_lambda
f_lambda
## defn f_quote
f_quote
## defn f_set
f_set
## defn s_applicators
s_applicators
## defn s_evaluators
s_evaluators
## defn s_encoders
s_encoders
## defn s_expanders
s_expanders
## defn s_unquote_splicing
s_unquote_splicing
## defn s_unquote
s_unquote
## defn s_quasiquote
s_quasiquote
## defn s_quote
s_quote
## defn s_let
s_let
## defn s_lambda
s_lambda
## defn s_set
s_set
## defn s_define
s_define
## defn s_dot
s_dot
## defn s_t
s_t
## defn applicators
applicators
## defn evaluators
evaluators
## defn encoders
encoders
## defn expanders
expanders
## defn globals
globals
## defn symbols
symbols
## defn <context>
<context>
## defn <env>
<env>
## defn <variable>
<variable>
## defn <subr>
<subr>
## defn <fixed>
<fixed>
## defn <form>
<form>
## defn <expr>
<expr>
## defn <array>
<array>
## defn <_array>
<_array>
## defn <pair>
<pair>
## defn <symbol>
<symbol>
## defn <string>
<string>
## defn <double>
<double>
## defn <long>
<long>
## defn <data>
<data>
## defn <undefined>
<undefined>
## defn DONE
DONE
## defn EOF
EOF
## defn fscanf
fscanf
## defn fflush
fflush
## defn fclose
fclose
## defn fdopen
fdopen
## defn fopen
fopen
## defn ungetc
ungetc
## defn getc
getc
## defn putc
putc
## defn strtoul
strtoul
## defn strdup
strdup
## defn strcmp
strcmp
## defn strlen
strlen
## defn gc_malloc_atomic
gc_malloc_atomic
	.text
___L__2646__core_2Feval_2El__313:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2647__core_2Feval_2El__243:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__malloc,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2648__core_2Feval_2El__244:
	movl $3,%eax
	movl %eax,20(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,28(%esp)
	movl $16,%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	subl 32(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn gc_malloc
gc_malloc
	.text
___L__2649__core_2Feval_2El__244:
## frame 16 36 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
___L__2650__core_2Feval_2El__203:
	movl 80(%esp),%eax
	movl %eax,16(%esp)
	movl $3,%eax
	addl 16(%esp),%eax
	movl %eax,16(%esp)
	movl $-4,%eax
	andl 16(%esp),%eax
	movl %eax,80(%esp)
___L__2651__core_2Feval_2El__204:
	movl _gc__frequency,%eax
	movl %eax,16(%esp)
	movl _gc__alloc__count,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2652__core_2Feval_2El__204
	movl _gc__gcollect,%eax
	call *%eax
___L__2652__core_2Feval_2El__204:
___L__2653__core_2Feval_2El__205:
	movl $2,%eax
	movl %eax,16(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,20(%esp)
	movl _gc__memory__last,%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
___L__2654__core_2Feval_2El__207:
	movl $16,%eax
	movl %eax,20(%esp)
	movl 80(%esp),%eax
	addl 20(%esp),%eax
	movl %eax,20(%esp)
___L__2655__core_2Feval_2El__208:
	jmp ___L__2657__core_2Feval_2El__208
___L__2656__core_2Feval_2El__208:
___L__2658__core_2Feval_2El__209:
	jmp ___L__2660__core_2Feval_2El__209
___L__2659__core_2Feval_2El__209:
___L__2660__core_2Feval_2El__209:
___L__2661__core_2Feval_2El__210:
	movl $0,%eax
___L__2662__core_2Feval_2El__212:
	movl $1,%eax
	movl %eax,28(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
	movl $0,%eax
	cmpl 28(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2663__core_2Feval_2El__212
___L__2665__core_2Feval_2El__213:
	movl $0,%eax
	movl %eax,28(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,28(%esp)
___L__2666__core_2Feval_2El__214:
	jmp ___L__2668__core_2Feval_2El__214
___L__2667__core_2Feval_2El__214:
___L__2669__core_2Feval_2El__216:
	movl $2,%eax
	movl %eax,32(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
___L__2670__core_2Feval_2El__217:
	movl $2,%eax
	movl %eax,40(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 32(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl $2,%eax
	movl %eax,44(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 40(%esp),%eax
	movl %eax,(%ecx)
___L__2671__core_2Feval_2El__218:
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,44(%esp)
	movl 32(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl $16,%eax
	addl 40(%esp),%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	addl 40(%esp),%eax
	movl %eax,40(%esp)
	movl $0,%eax
	movl %eax,48(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,44(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 40(%esp),%eax
	movl %eax,(%ecx)
	movl %eax,28(%esp)
___L__2672__core_2Feval_2El__219:
	movl _gc__memory__last,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	cmpl 40(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2673__core_2Feval_2El__219
	movl 24(%esp),%eax
	movl %eax,_gc__memory__last
___L__2673__core_2Feval_2El__219:
___L__2668__core_2Feval_2El__214:
___L__2674__core_2Feval_2El__214:
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,40(%esp)
	movl $2,%eax
	movl %eax,48(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
	movl $0,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2675__core_2Feval_2El__214
___L__2676__core_2Feval_2El__215:
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl $16,%eax
	addl 32(%esp),%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	addl 32(%esp),%eax
	movl %eax,32(%esp)
	movl $2,%eax
	movl %eax,48(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__2675__core_2Feval_2El__214:
	cmpl $0,%eax
	jne ___L__2667__core_2Feval_2El__214
___L__2677__core_2Feval_2El__220:
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl 20(%esp),%eax
	cmpl 32(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2680__core_2Feval_2El__220
	movl 28(%esp),%eax
	movl %eax,32(%esp)
	movl 80(%esp),%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
___L__2680__core_2Feval_2El__220:
	cmpl $0,%eax
	je ___L__2678__core_2Feval_2El__220
___L__2681__core_2Feval_2El__221:
	movl $0,%eax
___L__2682__core_2Feval_2El__223:
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl 28(%esp),%eax
	cmpl 32(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2683__core_2Feval_2El__223
___L__2684__core_2Feval_2El__224:
	movl 20(%esp),%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	addl 32(%esp),%eax
	movl %eax,32(%esp)
	movl $0,%eax
___L__2685__core_2Feval_2El__226:
	movl $16,%eax
	movl %eax,48(%esp)
	movl 80(%esp),%eax
	addl 48(%esp),%eax
	movl %eax,48(%esp)
	movl 28(%esp),%eax
	subl 48(%esp),%eax
	movl %eax,48(%esp)
	movl $0,%eax
	movl %eax,44(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 48(%esp),%eax
	movl %eax,(%ecx)
___L__2686__core_2Feval_2El__227:
	movl $0,%eax
	movl %eax,48(%esp)
	movl $1,%eax
	movl %eax,44(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 32(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 48(%esp),%eax
	movl %eax,(%ecx)
___L__2687__core_2Feval_2El__228:
	movl $2,%eax
	movl %eax,48(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,44(%esp)
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,48(%esp)
	movl $2,%eax
	movl %eax,40(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,44(%esp)
	movl 32(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 48(%esp),%eax
	movl %eax,(%ecx)
___L__2688__core_2Feval_2El__229:
	movl 80(%esp),%eax
	movl %eax,48(%esp)
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 24(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 48(%esp),%eax
	movl %eax,(%ecx)
___L__2689__core_2Feval_2El__230:
	movl 32(%esp),%eax
	movl %eax,48(%esp)
	movl $2,%eax
	movl %eax,40(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,44(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 48(%esp),%eax
	movl %eax,(%ecx)
___L__2690__core_2Feval_2El__231:
	movl 80(%esp),%eax
	movl %eax,28(%esp)
___L__2683__core_2Feval_2El__223:
___L__2691__core_2Feval_2El__232:
	movl $1,%eax
	movl %eax,32(%esp)
	movl $1,%eax
	movl %eax,48(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 32(%esp),%eax
	movl %eax,(%ecx)
___L__2692__core_2Feval_2El__233:
	movl 24(%esp),%eax
	movl %eax,_gc__memory__last
	movl $0,%eax
___L__2693__core_2Feval_2El__235:
	movl $16,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	addl 32(%esp),%eax
	movl %eax,32(%esp)
___L__2694__core_2Feval_2El__236:
	movl 32(%esp),%eax
	movl %eax,48(%esp)
	movl $0,%eax
	movl %eax,36(%esp)
	movl 28(%esp),%eax
	movl %eax,40(%esp)
	movl _memset_24stub,%eax
	movl 48(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	movl 40(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__2695__core_2Feval_2El__237:
	movl $1,%eax
	movl %eax,40(%esp)
	movl _gc__alloc__count,%eax
	addl 40(%esp),%eax
	movl %eax,_gc__alloc__count
___L__2696__core_2Feval_2El__238:
	movl 32(%esp),%eax
	jmp ___L__2697__core_2Feval_2El__238
	jmp ___L__2679__core_2Feval_2El__220
___L__2678__core_2Feval_2El__220:
___L__2679__core_2Feval_2El__220:
	jmp ___L__2664__core_2Feval_2El__212
___L__2663__core_2Feval_2El__212:
___L__2664__core_2Feval_2El__212:
___L__2698__core_2Feval_2El__239:
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,32(%esp)
	movl 24(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	cmpl 28(%esp),%eax
	setne %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2659__core_2Feval_2El__209
___L__2699__core_2Feval_2El__240:
	movl 80(%esp),%eax
	movl %eax,28(%esp)
	movl $16,%eax
	addl 28(%esp),%eax
	movl %eax,28(%esp)
	movl _gc__quantum,%eax
	movl %eax,40(%esp)
	movl _max,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,40(%esp)
	movl _gc__grow__memory,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2657__core_2Feval_2El__208:
	movl $1,%eax
	cmpl $0,%eax
	jne ___L__2656__core_2Feval_2El__208
___L__2697__core_2Feval_2El__238:
	addl $72,%esp
	leave
	ret
## defn gc_gcollect
gc_gcollect
	.text
___L__2700__core_2Feval_2El__240:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
	movl $0,%eax
___L__2701__core_2Feval_2El__194:
	movl $0,%eax
	movl %eax,16(%esp)
___L__2702__core_2Feval_2El__195:
	jmp ___L__2704__core_2Feval_2El__195
___L__2703__core_2Feval_2El__195:
	movl $0,%eax
___L__2705__core_2Feval_2El__197:
	movl $0,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _gc__roots,%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl _gc__mark__and__trace,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2706__core_2Feval_2El__198:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $1,%eax
	addl 20(%esp),%eax
	movl %eax,16(%esp)
___L__2704__core_2Feval_2El__195:
___L__2707__core_2Feval_2El__195:
	movl _gc__root__count,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	cmpl 20(%esp),%eax
	setl %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2703__core_2Feval_2El__195
___L__2708__core_2Feval_2El__199:
	movl _gc__sweep,%eax
	call *%eax
___L__2709__core_2Feval_2El__200:
	movl $0,%eax
	movl %eax,_gc__alloc__count
	addl $40,%esp
	leave
	ret
## defn gc_mark_and_trace
gc_mark_and_trace
	.text
___L__2710__core_2Feval_2El__200:
## frame 16 24 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2711__core_2Feval_2El__173:
	movl 64(%esp),%eax
	cmpl $0,%eax
	je ___L__2712__core_2Feval_2El__173
___L__2713__core_2Feval_2El__174:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl $1,%eax
	andl 16(%esp),%eax
	cmpl $0,%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2712__core_2Feval_2El__173
___L__2714__core_2Feval_2El__175:
	movl $16,%eax
	movl %eax,16(%esp)
	movl 64(%esp),%eax
	subl 16(%esp),%eax
	movl %eax,16(%esp)
___L__2715__core_2Feval_2El__176:
	movl $1,%eax
	movl %eax,20(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl $0,%eax
___L__2716__core_2Feval_2El__179:
	movl $4,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	jne ___L__2717__core_2Feval_2El__179
___L__2718__core_2Feval_2El__180:
___L__2719__core_2Feval_2El__181:
	movl $4,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	orl 28(%esp),%eax
	movl %eax,28(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 28(%esp),%eax
	movl %eax,(%ecx)
___L__2720__core_2Feval_2El__182:
	movl $2,%eax
	movl %eax,28(%esp)
	movl 20(%esp),%eax
	andl 28(%esp),%eax
	cmpl $0,%eax
	jne ___L__2721__core_2Feval_2El__182
___L__2722__core_2Feval_2El__183:
	movl $2,%eax
	movl %eax,28(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl 28(%esp),%ecx
	sarl %cl,%eax
	movl %eax,28(%esp)
	movl $0,%eax
___L__2723__core_2Feval_2El__185:
	jmp ___L__2725__core_2Feval_2El__185
___L__2724__core_2Feval_2El__185:
___L__2726__core_2Feval_2El__186:
	movl $1,%eax
	movl %eax,24(%esp)
	movl 28(%esp),%eax
	subl 24(%esp),%eax
	movl %eax,28(%esp)
	movl $0,%eax
___L__2727__core_2Feval_2El__188:
	movl 28(%esp),%eax
	movl %eax,24(%esp)
	movl 64(%esp),%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,24(%esp)
	movl _gc__mark__and__trace,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2725__core_2Feval_2El__185:
	movl 28(%esp),%eax
	cmpl $0,%eax
	jne ___L__2724__core_2Feval_2El__185
___L__2721__core_2Feval_2El__182:
___L__2717__core_2Feval_2El__179:
___L__2712__core_2Feval_2El__173:
	addl $56,%esp
	leave
	ret
## defn gc_sweep
gc_sweep
	.text
___L__2728__core_2Feval_2El__188:
## frame 16 36 64 80
	pushl %ebp
	movl %esp,%ebp
	subl $72,%esp
	movl $0,%eax
___L__2729__core_2Feval_2El__149:
	movl _gc__memory__base,%eax
	movl %eax,16(%esp)
	movl $0,%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl $0,%eax
	movl %eax,28(%esp)
___L__2730__core_2Feval_2El__153:
	jmp ___L__2732__core_2Feval_2El__153
___L__2731__core_2Feval_2El__153:
	movl $0,%eax
___L__2733__core_2Feval_2El__155:
	movl $1,%eax
	movl %eax,32(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,40(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 40(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,32(%esp)
___L__2734__core_2Feval_2El__156:
	movl $4,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	andl 40(%esp),%eax
	cmpl $0,%eax
	je ___L__2735__core_2Feval_2El__156
___L__2737__core_2Feval_2El__157:
___L__2738__core_2Feval_2El__158:
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,44(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 44(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl 24(%esp),%eax
	addl 40(%esp),%eax
	movl %eax,24(%esp)
___L__2739__core_2Feval_2El__159:
	movl $1,%eax
	movl %eax,40(%esp)
	movl 20(%esp),%eax
	addl 40(%esp),%eax
	movl %eax,20(%esp)
___L__2740__core_2Feval_2El__160:
	movl $4,%eax
	movl %eax,40(%esp)
	movl 32(%esp),%eax
	xorl 40(%esp),%eax
	movl %eax,40(%esp)
	movl $1,%eax
	movl %eax,44(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,36(%esp)
	movl 16(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 36(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 44(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 40(%esp),%eax
	movl %eax,(%ecx)
	jmp ___L__2736__core_2Feval_2El__156
___L__2735__core_2Feval_2El__156:
	movl $0,%eax
___L__2741__core_2Feval_2El__162:
	movl $0,%eax
	movl %eax,40(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,44(%esp)
	movl 16(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 40(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,40(%esp)
	movl 28(%esp),%eax
	addl 40(%esp),%eax
	movl %eax,28(%esp)
___L__2742__core_2Feval_2El__163:
	movl $0,%eax
	movl %eax,40(%esp)
	movl $1,%eax
	movl %eax,48(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,44(%esp)
	movl 16(%esp),%eax
	movl %eax,36(%esp)
	movl __25typecheck,%eax
	movl 44(%esp),%ecx
	movl %ecx,0(%esp)
	movl 36(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 48(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 40(%esp),%eax
	movl %eax,(%ecx)
___L__2736__core_2Feval_2El__156:
___L__2743__core_2Feval_2El__164:
	movl $2,%eax
	movl %eax,32(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,40(%esp)
	movl 16(%esp),%eax
	movl %eax,48(%esp)
	movl __25typecheck,%eax
	movl 40(%esp),%ecx
	movl %ecx,0(%esp)
	movl 48(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 32(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl %eax,32(%esp)
	movl _gc__memory__base,%eax
	cmpl 32(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2744__core_2Feval_2El__164
___L__2745__core_2Feval_2El__165:
	movl $0,%eax
	movl %eax,16(%esp)
___L__2744__core_2Feval_2El__164:
___L__2732__core_2Feval_2El__153:
	movl 16(%esp),%eax
	cmpl $0,%eax
	jne ___L__2731__core_2Feval_2El__153
___L__2746__core_2Feval_2El__166:
	movl 20(%esp),%eax
	movl %eax,_gc__objects__live
___L__2747__core_2Feval_2El__167:
	movl 24(%esp),%eax
	movl %eax,_gc__bytes__used
___L__2748__core_2Feval_2El__168:
	movl 28(%esp),%eax
	movl %eax,_gc__bytes__free
	movl $0,%eax
	addl $72,%esp
	leave
	ret
## defn gc_size
gc_size
	.text
___L__2749__core_2Feval_2El__168:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2750__core_2Feval_2El__145:
	movl $0,%eax
	movl %eax,16(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,20(%esp)
	movl $16,%eax
	movl %eax,24(%esp)
	movl 48(%esp),%eax
	subl 24(%esp),%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	addl $40,%esp
	leave
	ret
## defn gc_grow_memory
gc_grow_memory
	.text
___L__2751__core_2Feval_2El__145:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2752__core_2Feval_2El__141:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _new__memory__block,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2753__core_2Feval_2El__142:
	movl $2,%eax
	movl %eax,20(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,24(%esp)
	movl _gc__memory__last,%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 20(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,20(%esp)
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
___L__2754__core_2Feval_2El__143:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $2,%eax
	movl %eax,28(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,32(%esp)
	movl _gc__memory__last,%eax
	movl %eax,24(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
	addl $56,%esp
	leave
	ret
## defn gc_pop_root
gc_pop_root
	.text
___L__2755__core_2Feval_2El__143:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2756__core_2Feval_2El__135:
	movl _gc__root__count,%eax
	cmpl $0,%eax
	jne ___L__2757__core_2Feval_2El__135
	.data
___L__2758__core_2Feval_2El__135:
	.asciz "root table underflow"
	.text
	movl $___L__2758__core_2Feval_2El__135,%eax
	movl %eax,16(%esp)
	movl _fatal,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2757__core_2Feval_2El__135:
___L__2759__core_2Feval_2El__136:
	movl $1,%eax
	movl %eax,16(%esp)
	movl _gc__root__count,%eax
	subl 16(%esp),%eax
	movl %eax,_gc__root__count
	movl $0,%eax
___L__2760__core_2Feval_2El__138:
	movl _gc__root__count,%eax
	movl %eax,16(%esp)
	movl _gc__roots,%eax
	movl 16(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl (%ecx),%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2761__core_2Feval_2El__138
	.data
___L__2762__core_2Feval_2El__138:
	.asciz "non-lifo root"
	.text
	movl $___L__2762__core_2Feval_2El__138,%eax
	movl %eax,16(%esp)
	movl _fatal,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2761__core_2Feval_2El__138:
	addl $40,%esp
	leave
	ret
## defn gc_push_root
gc_push_root
	.text
___L__2763__core_2Feval_2El__138:
## frame 16 16 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2764__core_2Feval_2El__125:
	movl _gc__root__max,%eax
	movl %eax,16(%esp)
	movl _gc__root__count,%eax
	cmpl 16(%esp),%eax
	sete %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2765__core_2Feval_2El__125
___L__2766__core_2Feval_2El__126:
	movl $32,%eax
	movl %eax,16(%esp)
	movl _gc__root__max,%eax
	movl %eax,20(%esp)
	movl $2,%eax
	mull 20(%esp)
	movl %eax,20(%esp)
	movl _max,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,_gc__root__max
	movl %eax,20(%esp)
	movl $4,%eax
	mull 20(%esp)
	movl %eax,20(%esp)
	movl _malloc_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,20(%esp)
___L__2767__core_2Feval_2El__127:
	movl 20(%esp),%eax
	movl %eax,16(%esp)
	movl _gc__roots,%eax
	movl %eax,24(%esp)
	movl _gc__root__count,%eax
	movl %eax,28(%esp)
	movl $4,%eax
	mull 28(%esp)
	movl %eax,28(%esp)
	movl _memcpy_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	movl 28(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
___L__2768__core_2Feval_2El__128:
	movl _gc__roots,%eax
	cmpl $0,%eax
	je ___L__2769__core_2Feval_2El__128
	movl _gc__roots,%eax
	movl %eax,28(%esp)
	movl _free_24stub,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2769__core_2Feval_2El__128:
___L__2770__core_2Feval_2El__129:
	movl 20(%esp),%eax
	movl %eax,_gc__roots
___L__2765__core_2Feval_2El__125:
___L__2771__core_2Feval_2El__130:
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _gc__root__count,%eax
	movl %eax,28(%esp)
	movl _gc__roots,%eax
	movl 28(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
	movl $0,%eax
___L__2772__core_2Feval_2El__132:
	movl _gc__root__count,%eax
	movl %eax,20(%esp)
	movl $1,%eax
	addl 20(%esp),%eax
	movl %eax,_gc__root__count
	addl $40,%esp
	leave
	ret
## defn gc_initialise
gc_initialise
	.text
___L__2773__core_2Feval_2El__132:
## frame 16 4 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2774__core_2Feval_2El__120:
	movl _gc__quantum,%eax
	movl %eax,16(%esp)
	movl _new__memory__block,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2775__core_2Feval_2El__121:
	movl 16(%esp),%eax
	movl %eax,_gc__memory__base
___L__2776__core_2Feval_2El__122:
	movl 16(%esp),%eax
	movl %eax,_gc__memory__last
	addl $40,%esp
	leave
	ret
## defn new_memory_block
new_memory_block
	.text
___L__2777__core_2Feval_2El__122:
## frame 16 20 48 64
	pushl %ebp
	movl %esp,%ebp
	subl $56,%esp
___L__2778__core_2Feval_2El__111:
	movl 64(%esp),%eax
	movl %eax,16(%esp)
	movl _malloc_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl %eax,16(%esp)
___L__2779__core_2Feval_2El__112:
	movl 16(%esp),%eax
	cmpl $0,%eax
	jne ___L__2780__core_2Feval_2El__112
	.data
___L__2781__core_2Feval_2El__112:
	.asciz "out of memory"
	.text
	movl $___L__2781__core_2Feval_2El__112,%eax
	movl %eax,20(%esp)
	movl _fatal,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2780__core_2Feval_2El__112:
___L__2782__core_2Feval_2El__113:
	movl $16,%eax
	movl %eax,20(%esp)
	movl 64(%esp),%eax
	subl 20(%esp),%eax
	movl %eax,20(%esp)
	movl $0,%eax
	movl %eax,24(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
___L__2783__core_2Feval_2El__114:
	movl $0,%eax
	movl %eax,20(%esp)
	movl $1,%eax
	movl %eax,24(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,32(%esp)
	movl 16(%esp),%eax
	movl %eax,28(%esp)
	movl __25typecheck,%eax
	movl 32(%esp),%ecx
	movl %ecx,0(%esp)
	movl 28(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
___L__2784__core_2Feval_2El__115:
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl $2,%eax
	movl %eax,24(%esp)
	movl __3Cheader_3E,%eax
	movl %eax,28(%esp)
	movl 16(%esp),%eax
	movl %eax,32(%esp)
	movl __25typecheck,%eax
	movl 28(%esp),%ecx
	movl %ecx,0(%esp)
	movl 32(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl 24(%esp),%ecx
	leal (%eax,%ecx,4),%ecx
	movl 20(%esp),%eax
	movl %eax,(%ecx)
	movl $0,%eax
	movl 16(%esp),%eax
	addl $56,%esp
	leave
	ret
## defn k_error
k_error
## defn fatal2
fatal2
	.text
___L__2785__core_2Feval_2El__115:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2786__core_2Feval_2El__101:
	.data
___L__2787__core_2Feval_2El__101:
	.asciz "\012eval.k: "
	.text
	movl $___L__2787__core_2Feval_2El__101,%eax
	movl %eax,16(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl 56(%esp),%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	movl 24(%esp),%ecx
	movl %ecx,8(%esp)
	call *%eax
	.data
___L__2788__core_2Feval_2El__101:
	.asciz "\012"
	.text
	movl $___L__2788__core_2Feval_2El__101,%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
	addl $40,%esp
	leave
	ret
## defn fatal1
fatal1
	.text
___L__2789__core_2Feval_2El__101:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2790__core_2Feval_2El__100:
	.data
___L__2791__core_2Feval_2El__100:
	.asciz "\012eval.k: "
	.text
	movl $___L__2791__core_2Feval_2El__100,%eax
	movl %eax,16(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl 48(%esp),%eax
	movl %eax,16(%esp)
	movl 52(%esp),%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	.data
___L__2792__core_2Feval_2El__100:
	.asciz "\012"
	.text
	movl $___L__2792__core_2Feval_2El__100,%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	movl _die,%eax
	call *%eax
	addl $40,%esp
	leave
	ret
## defn fatal
fatal
	.text
___L__2793__core_2Feval_2El__100:
## frame 16 8 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2794__core_2Feval_2El__98:
	.data
___L__2795__core_2Feval_2El__98:
	.asciz "\012eval.k: %s\012"
	.text
	movl $___L__2795__core_2Feval_2El__98,%eax
	movl %eax,16(%esp)
	movl 48(%esp),%eax
	movl %eax,20(%esp)
	movl _printf_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl $1,%eax
	movl %eax,20(%esp)
	movl _exit_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn die
die
	.text
___L__2796__core_2Feval_2El__98:
## frame 16 12 32 48
	pushl %ebp
	movl %esp,%ebp
	subl $40,%esp
___L__2797__core_2Feval_2El__599:
	movl _trace__depth,%eax
	movl %eax,16(%esp)
___L__2798__core_2Feval_2El__600:
	jmp ___L__2800__core_2Feval_2El__600
___L__2799__core_2Feval_2El__600:
___L__2801__core_2Feval_2El__601:
	.data
___L__2802__core_2Feval_2El__601:
	.asciz "%3d: "
	.text
	movl $___L__2802__core_2Feval_2El__601,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	movl %eax,24(%esp)
	movl _printf_24stub,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	movl 24(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
___L__2803__core_2Feval_2El__602:
	movl _trace__stack,%eax
	movl %eax,24(%esp)
	movl 16(%esp),%eax
	movl %eax,20(%esp)
	movl _k__array__at,%eax
	movl 24(%esp),%ecx
	movl %ecx,0(%esp)
	movl 20(%esp),%ecx
	movl %ecx,4(%esp)
	call *%eax
	movl %eax,20(%esp)
	movl _k__dumpln,%eax
	movl 20(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
___L__2800__core_2Feval_2El__600:
___L__2804__core_2Feval_2El__600:
	movl $1,%eax
	movl %eax,20(%esp)
	movl 16(%esp),%eax
	subl 20(%esp),%eax
	movl %eax,16(%esp)
	movl %eax,20(%esp)
	movl $0,%eax
	cmpl 20(%esp),%eax
	setle %al
	movzbl %al,%eax
	cmpl $0,%eax
	jne ___L__2799__core_2Feval_2El__600
___L__2805__core_2Feval_2El__603:
	movl $1,%eax
	movl %eax,16(%esp)
	movl _exit_24stub,%eax
	movl 16(%esp),%ecx
	movl %ecx,0(%esp)
	call *%eax
	addl $40,%esp
	leave
	ret
## defn trace_depth
trace_depth
## defn trace_stack
trace_stack
## defn max
max
	.text
___L__2806__core_2Feval_2El__603:
## frame 0 4 16 32
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp
___L__2807__core_2Feval_2El__91:
	movl 36(%esp),%eax
	movl %eax,0(%esp)
	movl 32(%esp),%eax
	cmpl 0(%esp),%eax
	setg %al
	movzbl %al,%eax
	cmpl $0,%eax
	je ___L__2808__core_2Feval_2El__91
	movl 32(%esp),%eax
	jmp ___L__2809__core_2Feval_2El__91
___L__2808__core_2Feval_2El__91:
	movl 36(%esp),%eax
___L__2809__core_2Feval_2El__91:
	addl $24,%esp
	leave
	ret
## defn <header>-flags-used+atom
<header>-flags-used+atom
## defn <header>-flags-mark
<header>-flags-mark
## defn <header>-flags-atom
<header>-flags-atom
## defn <header>-flags-used
<header>-flags-used
## defn size-of-structure
size-of-structure
## defn gc_collection_count
gc_collection_count
## defn gc_alloc_count
gc_alloc_count
## defn gc_memory_last
gc_memory_last
## defn gc_memory_base
gc_memory_base
## defn gc_root_max
gc_root_max
## defn gc_root_count
gc_root_count
## defn gc_roots
gc_roots
## defn gc_bytes_free
gc_bytes_free
## defn gc_bytes_used
gc_bytes_used
## defn gc_objects_live
gc_objects_live
## defn gc_frequency
gc_frequency
## defn gc_quantum
gc_quantum
## defn stderr
stderr
## defn stdout
stdout
## defn stdin
stdin
## defn input
input
## defn arguments
arguments
## defn isatty
isatty
## defn snprintf
snprintf
## defn sprintf
sprintf
## defn fprintf
fprintf
## defn printf
printf
## defn memmove
memmove
## defn memcpy
memcpy
## defn memset
memset
## defn free
free
## defn realloc
realloc
## defn malloc
malloc
## defn exit
exit
## defn abort
abort
	.data
	.globl _define_2Dfsubr
_define_2Dfsubr:
	.long ___L__243__core_2Feval_2El__1694
	.text
	.data
	.globl _define_2Dsubr
_define_2Dsubr:
	.long ___L__249__core_2Feval_2El__1553
	.text
	.data
	.globl _repl__stream
_repl__stream:
	.long ___L__254__core_2Feval_2El__1548
	.text
	.data
	.globl _subr__read
_subr__read:
	.long ___L__299__core_2Feval_2El__1526
	.text
	.data
	.globl _subr__optimised
_subr__optimised:
	.long ___L__330__core_2Feval_2El__1518
	.text
	.data
	.globl _subr__verbose
_subr__verbose:
	.long ___L__341__core_2Feval_2El__1499
	.text
	.data
	.globl _subr__long__string
_subr__long__string:
	.long ___L__352__core_2Feval_2El__1493
	.text
	.data
	.globl _subr__symbol__string
_subr__symbol__string:
	.long ___L__372__core_2Feval_2El__1486
	.text
	.data
	.globl _subr__string__symbol
_subr__string__symbol:
	.long ___L__388__core_2Feval_2El__1476
	.text
	.data
	.globl _subr__set__string__at
_subr__set__string__at:
	.long ___L__404__core_2Feval_2El__1469
	.text
	.data
	.globl _subr__string__at
_subr__string__at:
	.long ___L__425__core_2Feval_2El__1461
	.text
	.data
	.globl _subr__string__length
_subr__string__length:
	.long ___L__440__core_2Feval_2El__1450
	.text
	.data
	.globl _subr__set__array__at
_subr__set__array__at:
	.long ___L__449__core_2Feval_2El__1441
	.text
	.data
	.globl _subr__array__at
_subr__array__at:
	.long ___L__462__core_2Feval_2El__1436
	.text
	.data
	.globl _subr__array__length
_subr__array__length:
	.long ___L__474__core_2Feval_2El__1428
	.text
	.data
	.globl _subr__set__oop__at
_subr__set__oop__at:
	.long ___L__476__core_2Feval_2El__1421
	.text
	.data
	.globl _subr__oop__at
_subr__oop__at:
	.long ___L__494__core_2Feval_2El__1417
	.text
	.data
	.globl _subr__set__cdr
_subr__set__cdr:
	.long ___L__511__core_2Feval_2El__1408
	.text
	.data
	.globl _subr__set__car
_subr__set__car:
	.long ___L__520__core_2Feval_2El__1400
	.text
	.data
	.globl _subr__cdr
_subr__cdr:
	.long ___L__529__core_2Feval_2El__1395
	.text
	.data
	.globl _subr__car
_subr__car:
	.long ___L__531__core_2Feval_2El__1390
	.text
	.data
	.globl _subr__arrayP
_subr__arrayP:
	.long ___L__533__core_2Feval_2El__1389
	.text
	.data
	.globl _subr__pairP
_subr__pairP:
	.long ___L__540__core_2Feval_2El__1388
	.text
	.data
	.globl _subr__symbolP
_subr__symbolP:
	.long ___L__547__core_2Feval_2El__1387
	.text
	.data
	.globl _subr__stringP
_subr__stringP:
	.long ___L__554__core_2Feval_2El__1386
	.text
	.data
	.globl _subr__type__of
_subr__type__of:
	.long ___L__561__core_2Feval_2El__1385
	.text
	.data
	.globl _subr__allocate
_subr__allocate:
	.long ___L__568__core_2Feval_2El__1384
	.text
	.data
	.globl _subr__form
_subr__form:
	.long ___L__584__core_2Feval_2El__1382
	.text
	.data
	.globl _subr__array
_subr__array:
	.long ___L__586__core_2Feval_2El__1375
	.text
	.data
	.globl _subr__string
_subr__string:
	.long ___L__593__core_2Feval_2El__1374
	.text
	.data
	.globl _subr__cons
_subr__cons:
	.long ___L__600__core_2Feval_2El__1373
	.text
	.data
	.globl _subr__expand
_subr__expand:
	.long ___L__602__core_2Feval_2El__1372
	.text
	.data
	.globl _subr__encode
_subr__encode:
	.long ___L__607__core_2Feval_2El__1370
	.text
	.data
	.globl _subr__eval
_subr__eval:
	.long ___L__612__core_2Feval_2El__1365
	.text
	.data
	.globl _subr__apply
_subr__apply:
	.long ___L__624__core_2Feval_2El__1355
	.text
	.data
	.globl _subr__warn
_subr__warn:
	.long ___L__626__core_2Feval_2El__1350
	.text
	.data
	.globl _subr__print
_subr__print:
	.long ___L__652__core_2Feval_2El__1341
	.text
	.data
	.globl _subr__dump
_subr__dump:
	.long ___L__663__core_2Feval_2El__1336
	.text
	.data
	.globl _subr__format
_subr__format:
	.long ___L__674__core_2Feval_2El__1331
	.text
	.data
	.globl _subr__putc
_subr__putc:
	.long ___L__730__core_2Feval_2El__1328
	.text
	.data
	.globl _subr__getc
_subr__getc:
	.long ___L__750__core_2Feval_2El__1299
	.text
	.data
	.globl _subr__close
_subr__close:
	.long ___L__765__core_2Feval_2El__1291
	.text
	.data
	.globl _subr__open
_subr__open:
	.long ___L__775__core_2Feval_2El__1282
	.text
	.data
	.globl _subr__exit
_subr__exit:
	.long ___L__788__core_2Feval_2El__1277
	.text
	.data
	.globl _subr__abort
_subr__abort:
	.long ___L__796__core_2Feval_2El__1271
	.text
	.data
	.globl _subr__ne
_subr__ne:
	.long ___L__798__core_2Feval_2El__1267
	.text
	.data
	.globl _subr__eq
_subr__eq:
	.long ___L__831__core_2Feval_2El__1264
	.text
	.data
	.globl _subr__gt
_subr__gt:
	.long ___L__862__core_2Feval_2El__1254
	.text
	.data
	.globl _subr__ge
_subr__ge:
	.long ___L__884__core_2Feval_2El__1244
	.text
	.data
	.globl _subr__le
_subr__le:
	.long ___L__906__core_2Feval_2El__1243
	.text
	.data
	.globl _subr__lt
_subr__lt:
	.long ___L__928__core_2Feval_2El__1242
	.text
## form define-relation
	.data
	.globl _subr__shr
_subr__shr:
	.long ___L__950__core_2Feval_2El__1241
	.text
	.data
	.globl _subr__shl
_subr__shl:
	.long ___L__972__core_2Feval_2El__1230
	.text
	.data
	.globl _subr__div
_subr__div:
	.long ___L__994__core_2Feval_2El__1229
	.text
	.data
	.globl _subr__mul
_subr__mul:
	.long ___L__1016__core_2Feval_2El__1228
	.text
	.data
	.globl _subr__add
_subr__add:
	.long ___L__1038__core_2Feval_2El__1227
	.text
	.data
	.globl _subr__bitxor
_subr__bitxor:
	.long ___L__1060__core_2Feval_2El__1226
	.text
	.data
	.globl _subr__bitor
_subr__bitor:
	.long ___L__1082__core_2Feval_2El__1225
	.text
	.data
	.globl _subr__bitand
_subr__bitand:
	.long ___L__1104__core_2Feval_2El__1224
	.text
## form define-binary
	.data
	.globl _subr__sub
_subr__sub:
	.long ___L__1126__core_2Feval_2El__1223
	.text
	.data
	.globl _arity3
_arity3:
	.long ___L__1175__core_2Feval_2El__1211
	.text
	.data
	.globl _arity2
_arity2:
	.long ___L__1196__core_2Feval_2El__1197
	.text
	.data
	.globl _subr__not
_subr__not:
	.long ___L__1212__core_2Feval_2El__1190
	.text
	.data
	.globl _subr__quote
_subr__quote:
	.long ___L__1216__core_2Feval_2El__1184
	.text
	.data
	.globl _subr__and
_subr__and:
	.long ___L__1218__core_2Feval_2El__1181
	.text
	.data
	.globl _subr__or
_subr__or:
	.long ___L__1233__core_2Feval_2El__1174
	.text
	.data
	.globl _subr__if
_subr__if:
	.long ___L__1248__core_2Feval_2El__1167
	.text
	.data
	.globl _subr__while
_subr__while:
	.long ___L__1264__core_2Feval_2El__1161
	.text
	.data
	.globl _subr__set
_subr__set:
	.long ___L__1280__core_2Feval_2El__1151
	.text
	.data
	.globl _subr__let
_subr__let:
	.long ___L__1309__core_2Feval_2El__1146
	.text
	.data
	.globl _subr__lambda
_subr__lambda:
	.long ___L__1360__core_2Feval_2El__1112
	.text
	.data
	.globl _subr__definedP
_subr__definedP:
	.long ___L__1362__core_2Feval_2El__1105
	.text
	.data
	.globl _subr__define
_subr__define:
	.long ___L__1367__core_2Feval_2El__1102
	.text
	.data
	.globl _evlist
_evlist:
	.long ___L__1383__core_2Feval_2El__1097
	.text
	.data
	.globl _k__encode
_k__encode:
	.long ___L__1398__core_2Feval_2El__1046
	.text
	.data
	.globl _enlist
_enlist:
	.long ___L__1528__core_2Feval_2El__1028
	.text
	.data
	.globl _k__expand
_k__expand:
	.long ___L__1544__core_2Feval_2El__1041
	.text
	.data
	.globl _exlist
_exlist:
	.long ___L__1650__core_2Feval_2El__964
	.text
	.data
	.globl _k__apply
_k__apply:
	.long ___L__1666__core_2Feval_2El__975
	.text
	.data
_counter:
	.long 0
	.text
	.data
	.globl _k__apply__expr
_k__apply__expr:
	.long ___L__1701__core_2Feval_2El__914
	.text
	.data
	.globl _k__eval
_k__eval:
	.long ___L__1768__core_2Feval_2El__881
	.text
	.data
	.globl _k__env__define
_k__env__define:
	.long ___L__1849__core_2Feval_2El__1082
	.text
	.data
	.globl _k__env__lookup
_k__env__lookup:
	.long ___L__1869__core_2Feval_2El__865
	.text
	.data
	.globl _k__env__find__variable
_k__env__find__variable:
	.long ___L__1877__core_2Feval_2El__852
	.text
	.data
	.globl _read__quote
_read__quote:
	.long ___L__1895__core_2Feval_2El__846
	.text
	.data
	.globl _read__list
_read__list:
	.long ___L__1904__core_2Feval_2El__802
	.text
	.data
	.globl _k__read
_k__read:
	.long ___L__1924__core_2Feval_2El__797
	.text
	.data
	.globl _read__string
_read__string:
	.long ___L__2015__core_2Feval_2El__833
	.text
	.data
	.globl _read__symbol
_read__symbol:
	.long ___L__2029__core_2Feval_2El__780
	.text
	.data
	.globl _read__number
_read__number:
	.long ___L__2042__core_2Feval_2El__769
	.text
	.data
	.globl _read__char
_read__char:
	.long ___L__2064__core_2Feval_2El__759
	.text
	.data
	.globl _digit__value
_digit__value:
	.long ___L__2151__core_2Feval_2El__742
	.text
	.data
	.globl _is__hexadecimal
_is__hexadecimal:
	.long ___L__2169__core_2Feval_2El__699
	.text
	.data
	.globl _is__octal
_is__octal:
	.long ___L__2177__core_2Feval_2El__692
	.text
	.data
	.globl _intern
_intern:
	.long ___L__2180__core_2Feval_2El__688
	.text
	.data
	.globl _buffer__contents
_buffer__contents:
	.long ___L__2204__core_2Feval_2El__685
	.text
	.data
	.globl _buffer__append__all
_buffer__append__all:
	.long ___L__2208__core_2Feval_2El__672
	.text
	.data
	.globl _buffer__append
_buffer__append:
	.long ___L__2216__core_2Feval_2El__665
	.text
	.data
	.globl _buffer__grow
_buffer__grow:
	.long ___L__2223__core_2Feval_2El__660
	.text
	.data
	.globl _buffer__delete
_buffer__delete:
	.long ___L__2230__core_2Feval_2El__653
	.text
	.data
	.globl _new__buffer
_new__buffer:
	.long ___L__2233__core_2Feval_2El__645
	.text
	.data
	.globl _is__letter
_is__letter:
	.long ___L__2238__core_2Feval_2El__640
	.text
	.data
	.globl _is__alpha
_is__alpha:
	.long ___L__2256__core_2Feval_2El__634
	.text
	.data
	.globl _is__digit16
_is__digit16:
	.long ___L__2262__core_2Feval_2El__621
	.text
	.data
	.globl _is__digit10
_is__digit10:
	.long ___L__2270__core_2Feval_2El__618
	.text
	.data
	.globl _is__blank
_is__blank:
	.long ___L__2273__core_2Feval_2El__614
	.text
	.data
	.globl _k__dumpln
_k__dumpln:
	.long ___L__2281__core_2Feval_2El__612
	.text
	.data
	.globl _k__dump
_k__dump:
	.long ___L__2284__core_2Feval_2El__596
	.text
	.data
	.globl _k__println
_k__println:
	.long ___L__2285__core_2Feval_2El__596
	.text
	.data
	.globl _k__print
_k__print:
	.long ___L__2288__core_2Feval_2El__595
	.text
	.data
	.globl _do__print
_do__print:
	.long ___L__2289__core_2Feval_2El__595
	.text
	.data
	.globl _k__array__insert
_k__array__insert:
	.long ___L__2459__core_2Feval_2El__593
	.text
	.data
	.globl _k__array__append
_k__array__append:
	.long ___L__2468__core_2Feval_2El__526
	.text
	.data
	.globl _k__set__array__at
_k__set__array__at:
	.long ___L__2470__core_2Feval_2El__517
	.text
	.data
	.globl _k__array__at
_k__array__at:
	.long ___L__2495__core_2Feval_2El__514
	.text
	.data
	.globl _k__array__length
_k__array__length:
	.long ___L__2507__core_2Feval_2El__498
	.text
	.data
	.globl _k__concat
_k__concat:
	.long ___L__2509__core_2Feval_2El__491
	.text
	.data
	.globl _k__string__length
_k__string__length:
	.long ___L__2522__core_2Feval_2El__486
	.text
	.data
	.globl _k__caddr
_k__caddr:
	.long ___L__2524__core_2Feval_2El__480
	.text
	.data
	.globl _k__cddr
_k__cddr:
	.long ___L__2526__core_2Feval_2El__478
	.text
	.data
	.globl _k__cadr
_k__cadr:
	.long ___L__2528__core_2Feval_2El__476
	.text
	.data
	.globl _k__caar
_k__caar:
	.long ___L__2530__core_2Feval_2El__475
	.text
	.data
	.globl _k__cdr
_k__cdr:
	.long ___L__2532__core_2Feval_2El__474
	.text
	.data
	.globl _k__car
_k__car:
	.long ___L__2539__core_2Feval_2El__472
	.text
	.data
	.globl _is__global
_is__global:
	.long ___L__2546__core_2Feval_2El__471
	.text
	.data
	.globl _new_2D_3Ccontext_3E
_new_2D_3Ccontext_3E:
	.long ___L__2550__core_2Feval_2El__467
	.text
	.data
	.globl _new_2Dbase_2D_3Ccontext_3E
_new_2Dbase_2D_3Ccontext_3E:
	.long ___L__2562__core_2Feval_2El__462
	.text
	.data
	.globl _new_2D_3Cenv_3E
_new_2D_3Cenv_3E:
	.long ___L__2569__core_2Feval_2El__441
	.text
## form set_tail
## form set_head
## form get_tail
## form get_head
## form get_long
## form is_long
## form put
## form get
	.data
	.globl _type__check__fail
_type__check__fail:
	.long ___L__2579__core_2Feval_2El__432
	.text
## form is
## form get-type
	.data
	.globl _new_2D_3Cvariable_3E
_new_2D_3Cvariable_3E:
	.long ___L__2582__core_2Feval_2El__410
	.text
	.data
	.globl _new_2D_3Csubr_3E
_new_2D_3Csubr_3E:
	.long ___L__2590__core_2Feval_2El__388
	.text
	.data
	.globl _new_2D_3Cfixed_3E
_new_2D_3Cfixed_3E:
	.long ___L__2596__core_2Feval_2El__381
	.text
	.data
	.globl _new_2D_3Cform_3E
_new_2D_3Cform_3E:
	.long ___L__2601__core_2Feval_2El__375
	.text
	.data
	.globl _new_2D_3Cexpr_3E
_new_2D_3Cexpr_3E:
	.long ___L__2607__core_2Feval_2El__368
	.text
	.data
	.globl _new_2D_3Carray_3E
_new_2D_3Carray_3E:
	.long ___L__2611__core_2Feval_2El__363
	.text
	.data
	.globl _new_2D_3Cpair_3E
_new_2D_3Cpair_3E:
	.long ___L__2620__core_2Feval_2El__355
	.text
	.data
	.globl _new_2D_3Csymbol_3E
_new_2D_3Csymbol_3E:
	.long ___L__2624__core_2Feval_2El__349
	.text
	.data
	.globl _new_2D_3Cstring_3E
_new_2D_3Cstring_3E:
	.long ___L__2627__core_2Feval_2El__343
	.text
	.data
	.globl ___new_2D_3Cstring_3E
___new_2D_3Cstring_3E:
	.long ___L__2631__core_2Feval_2El__338
	.text
	.data
	.globl _new_2D_3Clong_3E
_new_2D_3Clong_3E:
	.long ___L__2637__core_2Feval_2El__330
	.text
	.data
	.globl _new_2Doops
_new_2Doops:
	.long ___L__2640__core_2Feval_2El__325
	.text
	.data
	.globl _new_2Dbits
_new_2Dbits:
	.long ___L__2643__core_2Feval_2El__318
	.text
	.data
_opt__optimised:
	.long 0
	.text
	.data
_opt__verbose:
	.long 0
	.text
	.data
_f__define:
	.long 0
	.text
	.data
_f__let:
	.long 0
	.text
	.data
_f__lambda:
	.long 0
	.text
	.data
_f__quote:
	.long 0
	.text
	.data
_f__set:
	.long 0
	.text
	.data
_s__applicators:
	.long 0
	.text
	.data
_s__evaluators:
	.long 0
	.text
	.data
_s__encoders:
	.long 0
	.text
	.data
_s__expanders:
	.long 0
	.text
	.data
_s__unquote__splicing:
	.long 0
	.text
	.data
_s__unquote:
	.long 0
	.text
	.data
_s__quasiquote:
	.long 0
	.text
	.data
_s__quote:
	.long 0
	.text
	.data
_s__let:
	.long 0
	.text
	.data
_s__lambda:
	.long 0
	.text
	.data
_s__set:
	.long 0
	.text
	.data
_s__define:
	.long 0
	.text
	.data
_s__dot:
	.long 0
	.text
	.data
_s__t:
	.long 0
	.text
	.data
_applicators:
	.long 0
	.text
	.data
_evaluators:
	.long 0
	.text
	.data
_encoders:
	.long 0
	.text
	.data
_expanders:
	.long 0
	.text
	.data
_globals:
	.long 0
	.text
	.data
_symbols:
	.long 0
	.text
	.data
__3Ccontext_3E:
	.long 15
	.text
	.data
__3Cenv_3E:
	.long 14
	.text
	.data
__3Cvariable_3E:
	.long 13
	.text
	.data
__3Csubr_3E:
	.long 12
	.text
	.data
__3Cfixed_3E:
	.long 11
	.text
	.data
__3Cform_3E:
	.long 10
	.text
	.data
__3Cexpr_3E:
	.long 9
	.text
	.data
__3Carray_3E:
	.long 8
	.text
	.data
__3C__array_3E:
	.long 7
	.text
	.data
__3Cpair_3E:
	.long 6
	.text
	.data
__3Csymbol_3E:
	.long 5
	.text
	.data
__3Cstring_3E:
	.long 4
	.text
	.data
__3Cdouble_3E:
	.long 3
	.text
	.data
__3Clong_3E:
	.long 2
	.text
	.data
__3Cdata_3E:
	.long 1
	.text
	.data
__3Cundefined_3E:
	.long 0
	.text
	.data
_DONE:
	.long -4
	.text
	.data
_EOF:
	.long -1
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_fscanf_24stub:
	.indirect_symbol _fscanf
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_fflush_24stub:
	.indirect_symbol _fflush
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_fclose_24stub:
	.indirect_symbol _fclose
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_fdopen_24stub:
	.indirect_symbol _fdopen
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_fopen_24stub:
	.indirect_symbol _fopen
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_ungetc_24stub:
	.indirect_symbol _ungetc
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_getc_24stub:
	.indirect_symbol _getc
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_putc_24stub:
	.indirect_symbol _putc
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_strtoul_24stub:
	.indirect_symbol _strtoul
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_strdup_24stub:
	.indirect_symbol _strdup
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_strcmp_24stub:
	.indirect_symbol _strcmp
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_strlen_24stub:
	.indirect_symbol _strlen
	.long 0
	.text
	.data
	.globl _gc__malloc__atomic
_gc__malloc__atomic:
	.long ___L__2646__core_2Feval_2El__313
	.text
	.data
	.globl _gc__malloc
_gc__malloc:
	.long ___L__2649__core_2Feval_2El__244
	.text
	.data
	.globl _gc__gcollect
_gc__gcollect:
	.long ___L__2700__core_2Feval_2El__240
	.text
	.data
	.globl _gc__mark__and__trace
_gc__mark__and__trace:
	.long ___L__2710__core_2Feval_2El__200
	.text
	.data
	.globl _gc__sweep
_gc__sweep:
	.long ___L__2728__core_2Feval_2El__188
	.text
	.data
	.globl _gc__size
_gc__size:
	.long ___L__2749__core_2Feval_2El__168
	.text
	.data
	.globl _gc__grow__memory
_gc__grow__memory:
	.long ___L__2751__core_2Feval_2El__145
	.text
	.data
	.globl _gc__pop__root
_gc__pop__root:
	.long ___L__2755__core_2Feval_2El__143
	.text
	.data
	.globl _gc__push__root
_gc__push__root:
	.long ___L__2763__core_2Feval_2El__138
	.text
	.data
	.globl _gc__initialise
_gc__initialise:
	.long ___L__2773__core_2Feval_2El__132
	.text
	.data
	.globl _new__memory__block
_new__memory__block:
	.long ___L__2777__core_2Feval_2El__122
	.text
## form k_error
	.data
	.globl _fatal2
_fatal2:
	.long ___L__2785__core_2Feval_2El__115
	.text
	.data
	.globl _fatal1
_fatal1:
	.long ___L__2789__core_2Feval_2El__101
	.text
	.data
	.globl _fatal
_fatal:
	.long ___L__2793__core_2Feval_2El__100
	.text
	.data
	.globl _die
_die:
	.long ___L__2796__core_2Feval_2El__98
	.text
	.data
_trace__depth:
	.long 0
	.text
	.data
_trace__stack:
	.long 0
	.text
	.data
	.globl _max
_max:
	.long ___L__2806__core_2Feval_2El__603
	.text
## form <header>-flags-used+atom
## form <header>-flags-mark
## form <header>-flags-atom
## form <header>-flags-used
## form size-of-structure
	.data
_gc__collection__count:
	.long 0
	.text
	.data
_gc__alloc__count:
	.long 0
	.text
	.data
_gc__memory__last:
	.long 0
	.text
	.data
_gc__memory__base:
	.long 0
	.text
	.data
_gc__root__max:
	.long 0
	.text
	.data
_gc__root__count:
	.long 0
	.text
	.data
_gc__roots:
	.long 0
	.text
	.data
_gc__bytes__free:
	.long 0
	.text
	.data
_gc__bytes__used:
	.long 0
	.text
	.data
_gc__objects__live:
	.long 0
	.text
	.data
_gc__frequency:
	.long 32768
	.text
	.data
_gc__quantum:
	.long 51200
	.text
	.data
_stderr:
	.long 0
	.text
	.data
_stdout:
	.long 0
	.text
	.data
_stdin:
	.long 0
	.text
	.data
_input:
	.long 0
	.text
	.data
_arguments:
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_isatty_24stub:
	.indirect_symbol _isatty
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_snprintf_24stub:
	.indirect_symbol _snprintf
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_sprintf_24stub:
	.indirect_symbol _sprintf
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_fprintf_24stub:
	.indirect_symbol _fprintf
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_printf_24stub:
	.indirect_symbol _printf
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_memmove_24stub:
	.indirect_symbol _memmove
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_memcpy_24stub:
	.indirect_symbol _memcpy
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_memset_24stub:
	.indirect_symbol _memset
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_free_24stub:
	.indirect_symbol _free
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_realloc_24stub:
	.indirect_symbol _realloc
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_malloc_24stub:
	.indirect_symbol _malloc
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_exit_24stub:
	.indirect_symbol _exit
	.long 0
	.text
	.section __IMPORT,__pointers,non_lazy_symbol_pointers
_abort_24stub:
	.indirect_symbol _abort
	.long 0
	.text
