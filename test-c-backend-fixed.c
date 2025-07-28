main
define-fsubr
define-subr
repl_stream
subr_read
subr_optimised
subr_verbose
subr_long_string
subr_symbol_string
subr_string_symbol
subr_set_string_at
subr_string_at
subr_string_length
subr_set_array_at
subr_array_at
subr_array_length
subr_set_oop_at
subr_oop_at
subr_set_cdr
subr_set_car
subr_cdr
subr_car
subr_arrayP
subr_pairP
subr_symbolP
subr_stringP
subr_type_of
subr_allocate
subr_form
subr_array
subr_string
subr_cons
subr_expand
subr_encode
subr_eval
subr_apply
subr_warn
subr_print
subr_dump
subr_format
subr_putc
subr_getc
subr_close
subr_open
subr_exit
subr_abort
subr_ne
subr_eq
subr_gt
subr_ge
subr_le
subr_lt
define-relation
subr_shr
subr_shl
subr_div
subr_mul
subr_add
subr_bitxor
subr_bitor
subr_bitand
define-binary
subr_sub
arity3
arity2
subr_not
subr_quote
subr_and
subr_or
subr_if
subr_while
subr_set
subr_let
subr_lambda
subr_definedP
subr_define
evlist
k_encode
enlist
k_expand
exlist
k_apply
counter
k_apply_expr
k_eval
k_env_define
k_env_lookup
k_env_find_variable
read_quote
read_list
k_read
read_string
read_symbol
read_number
read_char
digit_value
is_hexadecimal
is_octal
intern
buffer_contents
buffer_append_all
buffer_append
buffer_grow
buffer_delete
new_buffer
is_letter
is_alpha
is_digit16
is_digit10
is_blank
k_dumpln
k_dump
k_println
k_print
do_print
k_array_insert
k_array_append
k_set_array_at
k_array_at
k_array_length
k_concat
k_string_length
k_caddr
k_cddr
k_cadr
k_caar
k_cdr
k_car
is_global
new-<context>
new-base-<context>
new-<env>
set_tail
set_head
get_tail
get_head
get_long
is_long
put
get
type_check_fail
is
get-type
new-<variable>
new-<subr>
new-<fixed>
new-<form>
new-<expr>
new-<array>
new-<pair>
new-<symbol>
new-<string>
_new-<string>
new-<long>
new-oops
new-bits
opt_optimised
opt_verbose
f_define
f_let
f_lambda
f_quote
f_set
s_applicators
s_evaluators
s_encoders
s_expanders
s_unquote_splicing
s_unquote
s_quasiquote
s_quote
s_let
s_lambda
s_set
s_define
s_dot
s_t
applicators
evaluators
encoders
expanders
globals
symbols
<context>
<env>
<variable>
<subr>
<fixed>
<form>
<expr>
<array>
<_array>
<pair>
<symbol>
<string>
<double>
<long>
<data>
<undefined>
DONE
EOF
fscanf
fflush
fclose
fdopen
fopen
ungetc
getc
putc
strtoul
strdup
strcmp
strlen
gc_malloc_atomic
gc_malloc
gc_gcollect
gc_mark_and_trace
gc_sweep
gc_size
gc_grow_memory
gc_pop_root
gc_push_root
gc_initialise
new_memory_block
k_error
fatal2
fatal1
fatal
die
trace_depth
trace_stack
max
<header>-flags-used+atom
<header>-flags-mark
<header>-flags-atom
<header>-flags-used
size-of-structure
gc_collection_count
gc_alloc_count
gc_memory_last
gc_memory_base
gc_root_max
gc_root_count
gc_roots
gc_bytes_free
gc_bytes_used
gc_objects_live
gc_frequency
gc_quantum
stderr
stdout
stdin
input
arguments
isatty
snprintf
sprintf
fprintf
printf
memmove
memcpy
memset
free
realloc
malloc
exit
abort
	# form define-relation
	# form define-binary
	.data
_counter:
	.long 0
	.text
	# form set_tail
	# form set_head
	# form get_tail
	# form get_head
	# form get_long
	# form is_long
	# form put
	# form get
	# form is
	# form get-type
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
	# form k_error
	.data
_trace__depth:
	.long 0
	.text
	.data
_trace__stack:
	.long 0
	.text
	# form <header>-flags-used+atom
	# form <header>-flags-mark
	# form <header>-flags-atom
	# form <header>-flags-used
	# form size-of-structure
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
