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
