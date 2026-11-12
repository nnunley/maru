;;; The kernel's objects: eval3's thirteen built-in types (eval3.c:87), with boot2.l's fields (boot2.l:425-437), and
;;; eval3's constructors.  The ids are the kernel's own, in eval3's order; boot2.l declares its built-in types in the
;;; same order, which kernel-main.k checks after boot.  Every object is reached through the ir2 object level
;;; (doc/ir2-objects.md); a string's or symbol's characters are wchar_t (four bytes here), as eval3 keeps them.

(define-object <undefined>	 0 ())
(define-object <data>		 1 () atom)
(define-object <long>		 2 ((bits long)) atom)
(define-object <double>		 3 ((bits double)) atom)
(define-object <string>		 4 ((size oop) (bits int32 *)))			; bits: managed memory, gc_malloc_atomic
(define-object <symbol>		 5 ((bits int32 *) (flags int)) atom)		; bits: malloc'd, never freed (eval3's wcsdup)
(define-object <pair>		 6 ((head oop) (tail oop) (source oop)))
(define-object <_array>		 7 ())						; its slots follow: (new <_array> bytes)
(define-object <array>		 8 ((size oop) (_array oop)))
(define-object <expr>		 9 ((name oop) (definition oop) (environment oop) (profile oop)))
(define-object <form>		10 ((function oop) (symbol oop)))
(define-object <fixed>		11 ((function oop)))
(define-object <subr>		12 ((name int32 *) (imp (oop oop oop) *) (sig void *) (profile int)) atom)

(define (strlen	  (long char *)			*)	(extern strlen))
(define (mbstowcs (long int32 * char * long)	*)	(extern mbstowcs))
(define (wcslen	  (long int32 *)		*)	(extern wcslen))

;; eval3's typecheck failure is fatal (eval3.c:152); recoverable errors come with the REPL's error handling.  Each
;; failure is counted and its ids kept; a law's driver clears type_check_fatal, so get answers 0 and put writes nothing
(define (type_check_fatal	long)	1)
(define (type_check_failures	long)	0)
(define (type_check_expected	long)	0)
(define (type_check_actual	long)	0)

(define-function type_check_fail void ((expected long) (actual long))
  (set type_check_failures (+ type_check_failures 1))
  (set type_check_expected expected)
  (set type_check_actual actual)
  (if type_check_fatal
      (let ()
	(printf "\nerror: typecheck failed (%ld != %ld)\n" expected actual)
	(exit (cast 1 int)))))

(define-function k_newData oop ((len long))	(return (new <data> len)))

;; Integers are boxed, as eval3 is built, or tagged, as its TAG_INT makes them (eval3.c:207-214): kernel-tagged-int is 0
;; unless the build defines it 1 before kernel.k, and (if-tagged-int TAGGED BOXED) picks a branch when the kernel compiles,
;; as eval.l's if-tagged-int (eval.l:12) does
(define-form kernel-tagged-int-default () (if (defined? 'kernel-tagged-int) () '(define kernel-tagged-int 0)))
(kernel-tagged-int-default)
(define-form if-tagged-int (tagged boxed) (if (= 1 kernel-tagged-int) tagged boxed))

;; tagged, a value whose top two bits agree is (bits << 1) | 1, an odd word, and any other is boxed
(if-tagged-int
 (define-function k_newLong oop ((bits long))
   (if (>= (^ bits (<< bits 1)) 0) (return (cast (| (<< bits 1) 1) oop)))
   (return (k_boxLong bits)))
 (define-function k_newLong oop ((bits long))
   (return (k_boxLong bits))))

(define-function k_boxLong oop ((bits long))
  (let (((obj oop) (new <long>)))
    (set (<long>-bits obj) bits)
    (return obj)))

;; the object level reads an odd word's value itself (doc/ir2-objects.md)
(define-function k_getLong long ((x oop))	(return (get <long> bits x)))

(define-function k_isLong long ((x oop))	(if (object-is <long> x) (return 1)) (return 0))

(define-function k_newDouble oop ((bits double))
  (let (((obj oop) (new <double>)))
    (set (<double>-bits obj) bits)
    (return obj)))

(define-function k_getDouble double ((x oop))	(return (get <double> bits x)))

;; a string of len characters, as eval3's _newString: the characters (one more, for the terminator) in managed memory,
;; rooted while the string itself is made
(define-function k__newString oop ((len long))
  (let (((chars int32 *) (cast (gc_malloc_atomic (* (sizeof int32) (+ len 1))) int32 *))
	((obj oop) nil))
    (gc-protect (chars)
      (set obj (new <string>))
      (gc-protect (obj)
	(set (<string>-size obj) (k_newLong len))
	(set (<string>-bits obj) chars)))
    (return obj)))

;; from a C string, widened as eval3's mbs2wcs widens it
(define-function k_newStringC oop ((cstr char *))
  (let* (((len long) (strlen cstr))
	 ((obj oop) (k__newString len)))
    (mbstowcs (<string>-bits obj) cstr (+ len 1))
    (return obj)))

;; from wide characters, as eval3's newString and newSymbol take them (the reader's buffer, say)
(define-function k_newString oop ((wcs int32 *))
  (let* (((len long) (wcslen wcs))
	 ((obj oop) (k__newString len)))
    (memcpy (cast (<string>-bits obj) void *) (cast wcs void *) (* (+ len 1) (sizeof int32)))
    (return obj)))

(define-function k_newSymbol oop ((wcs int32 *))	; the characters copied, as eval3's wcsdup copies them
  (let* (((len long) (wcslen wcs))
	 ((chars int32 *) (cast (malloc (* (sizeof int32) (+ len 1))) int32 *))
	 ((obj oop) nil))
    (memcpy (cast chars void *) (cast wcs void *) (* (+ len 1) (sizeof int32)))
    (set obj (new <symbol>))
    (set (<symbol>-bits obj) chars)
    (set (<symbol>-flags obj) 0)
    (return obj)))

(define-function k_newSymbolC oop ((cstr char *))
  (let* (((len long) (strlen cstr))
	 ((chars int32 *) (cast (malloc (* (sizeof int32) (+ len 1))) int32 *))
	 ((obj oop) (new <symbol>)))
    (mbstowcs chars cstr (+ len 1))
    (set (<symbol>-bits obj) chars)
    (set (<symbol>-flags obj) 0)
    (return obj)))

;; head and tail are rooted while the pair is made: eval3 leaves that to its callers.  Every constructor writes every
;; field, nil where eval3 leaves its zeroed memory alone, so nothing the kernel reads was left as allocated
(define-function k_cons oop ((head oop) (tail oop))
  (let (((obj oop) nil))
    (gc-protect (head tail)
      (set obj (new <pair>)))
    (set (<pair>-head obj) head)
    (set (<pair>-tail obj) tail)
    (set (<pair>-source obj) nil)
    (return obj)))

;; elements from to below to of an <_array>, nil: eval3 has them from zeroed memory
(define-function k_nilFill void ((elts oop) (from long) (to long))
  (while (< from to)
    (set (indir (cast elts oop *) from) nil)
    (set from (+ from 1))))

(define-function k_newArray oop ((size long))
  (let (((cap long) (if size size 1))
	((elts oop) nil)
	((obj oop) nil))
    (set elts (new <_array> (* (sizeof oop) cap)))
    (k_nilFill elts 0 cap)
    (gc-protect (elts)
      (set obj (new <array>))
      (gc-protect (obj)
	(set (<array>-_array obj) elts)
	(set (<array>-size obj) (k_newLong size))))
    (return obj)))

(define-function k_newExpr oop ((defn oop) (env oop))
  (let (((obj oop) nil))
    (gc-protect (defn env)
      (set obj (new <expr>))
      (gc-protect (obj)
	(set (<expr>-name obj) nil)
	(set (<expr>-definition obj) defn)
	(set (<expr>-environment obj) env)
	(set (<expr>-profile obj) (k_newLong 0))))
    (return obj)))

(define-function k_newForm oop ((fn oop) (sym oop))
  (let (((obj oop) nil))
    (gc-protect (fn sym)
      (set obj (new <form>)))
    (set (<form>-function obj) fn)
    (set (<form>-symbol obj) sym)
    (return obj)))

(define-function k_newFixed oop ((function oop))
  (let (((obj oop) nil))
    (gc-protect (function)
      (set obj (new <fixed>)))
    (set (<fixed>-function obj) function)
    (return obj)))

;; a subr named by a C string; its imp a typed Maru function of (arguments env)
(define-function k_newSubrC oop ((name char *) (imp (oop oop oop) *))
  (let* (((len long) (strlen name))
	 ((chars int32 *) (cast (malloc (* (sizeof int32) (+ len 1))) int32 *))
	 ((obj oop) (new <subr>)))
    (mbstowcs chars name (+ len 1))
    (set (<subr>-name obj) chars)
    (set (<subr>-imp obj) imp)
    (set (<subr>-sig obj) (cast 0 void *))
    (set (<subr>-profile obj) 0)
    (return obj)))
