;;; The kernel's reader: eval3's readExpr, readList and readChar (eval3.c:584-884), its character classes (chartab.h),
;;; symbols interned in a sorted array (eval3.c:533), and the source position a list's pairs carry (beginSource,
;;; advanceSource, endSource, newPairFrom).  It reads wide characters from a FILE, as eval3 does.

(define (getwc		(int void *)			*)	(extern getwc))
(define (ungetwc	(int int void *)		*)	(extern ungetwc))
(define (wcstod		(double int32 * void *)		*)	(extern wcstod))
(define (wcstoul	(long int32 * void * int)	*)	(extern wcstoul))
(define (wcscmp		(int int32 * int32 *)		*)	(extern wcscmp))
(define (realloc	(void * void * long)		*)	(extern realloc))

;; the next wide character, or a negative at the end (WEOF), as a long
(define-function k_getc long ((fp void *))	(return (cast (getwc fp) long)))

;;; character classes: chartab.h's flags for 0 ... 127, each as the character '0' + its flags; 128 and above print, are
;;; alphabetic and are letters, as eval3 has them
(define-constant k_char_print	1)
(define-constant k_char_alpha	4)
(define-constant k_char_digit10	8)
(define-constant k_char_digit16	16)
(define-constant k_char_letter	32)

(define-function k_charClass long ((c long))
  (if (and (>= c 0) (<= c 127))
      (return (- (cast (indir "000000000030330000000000000000003Q1QQQQ111QQQQQQIIIIIIIIIIQ1QQQQQeeeeeeUUUUUUUUUUUUUUUUUUUU1Q1QQ1eeeeeeUUUUUUUUUUUUUUUUUUUU1Q1Q0" c) long) 48)))
  (return 0))

;; each answers ir2's truth value, an int
(define-function k_isPrint int ((c long))	(return (or (!= 0 (& k_char_print (k_charClass c))) (>= c 128))))
(define-function k_isAlpha int ((c long))	(return (or (!= 0 (& k_char_alpha (k_charClass c))) (>= c 128))))
(define-function k_isDigit10 int ((c long))	(return (!= 0 (& k_char_digit10 (k_charClass c)))))
(define-function k_isDigit16 int ((c long))	(return (!= 0 (& k_char_digit16 (k_charClass c)))))
(define-function k_isLetter int ((c long))	(return (or (!= 0 (& k_char_letter (k_charClass c))) (>= c 128))))

;;; a buffer of wide characters, grown as needed: eval3's struct buffer
(define (k_buffer	int32 *)	0)
(define (k_bufferSize	long)		0)
(define (k_bufferUsed	long)		0)

(define-function k_bufferReset void ()		(set k_bufferUsed 0))

(define-function k_bufferAppend void ((c long))
  (if (>= (+ k_bufferUsed 1) k_bufferSize)
      (let ()
	(set k_bufferSize (if k_bufferSize (* 2 k_bufferSize) 32))
	(set k_buffer (cast (realloc (cast k_buffer void *) (* k_bufferSize (sizeof int32))) int32 *))))
  (set (indir k_buffer k_bufferUsed) (cast c int32))
  (set k_bufferUsed (+ k_bufferUsed 1)))

(define-function k_bufferContents (int32 *) ()	; terminated, as wcs functions read it
  (k_bufferAppend 0)
  (set k_bufferUsed (- k_bufferUsed 1))
  (return k_buffer))

(define-function k_bufferLength long ()		(return k_bufferUsed))

;;; the roots the reader keeps: the symbol table, the symbols it reads specially, and the source being read
(define (k_symbols		oop)	0)
(define (s_quote		oop)	0)
(define (s_quasiquote		oop)	0)
(define (s_unquote		oop)	0)
(define (s_unquote_splicing	oop)	0)
(define (s_dot			oop)	0)
(define (s_bracket		oop)	0)
(define (s_brace		oop)	0)
(define (k_currentSource	oop)	0)
(define (k_currentPath		oop)	0)
(define (k_currentLine		oop)	0)

;; what readExpr answers at the end of its input, or at a list's closing delimiter: no object is ever at -4 (eval3's DONE)
(define (k_done oop) 0)

;; a symbol by its characters: found by binary search in the sorted table, or made and inserted there
(define-function k_intern oop ((string int32 *))
  (let (((lo long) 0)
	((hi long) (- (k_arrayLength k_symbols) 1))
	((m long) 0)
	((c int) 0)
	((s oop) (cast 0 oop)))
    (while (<= lo hi)
      (set m (/ (+ lo hi) 2))
      (set s (k_arrayAt k_symbols m))
      (set c (wcscmp string (<symbol>-bits s)))
      (if (< c 0)
	  (set hi (- m 1))
	(if (> c 0)
	    (set lo (+ m 1))
	  (return s))))
    (set s (k_newSymbol string))
    (gc-protect (s)
      (k_arrayInsert k_symbols lo s))
    (return s)))

(define-function k_internC oop ((cstr char *))
  (let (((len long) (strlen cstr)))
    (k_bufferReset)
    (while (> len 0)
      (k_bufferAppend (cast (indir cstr 0) long))
      (set cstr (+ cstr 1))	; ir2 steps a pointer in bytes, and a char is one
      (set len (- len 1)))
    (return (k_intern (k_bufferContents)))))

(define-function k_initReader void ()
  (set k_done (cast -4 oop))
  (gc_push_root (cast (addressof k_symbols) void *))
  (set k_symbols (k_newArray 0))
  (gc_push_root (cast (addressof s_quote) void *))		(set s_quote		(k_internC "quote"))
  (gc_push_root (cast (addressof s_quasiquote) void *))		(set s_quasiquote	(k_internC "quasiquote"))
  (gc_push_root (cast (addressof s_unquote) void *))		(set s_unquote		(k_internC "unquote"))
  (gc_push_root (cast (addressof s_unquote_splicing) void *))	(set s_unquote_splicing	(k_internC "unquote-splicing"))
  (gc_push_root (cast (addressof s_dot) void *))		(set s_dot		(k_internC "."))
  (gc_push_root (cast (addressof s_bracket) void *))		(set s_bracket		(k_internC "bracket"))
  (gc_push_root (cast (addressof s_brace) void *))		(set s_brace		(k_internC "brace"))
  (gc_push_root (cast (addressof k_currentSource) void *))
  (gc_push_root (cast (addressof k_currentPath) void *))
  (gc_push_root (cast (addressof k_currentLine) void *)))

;;; the source being read: a pair whose source is (path . line), stacked through its head as files nest

;; a pair whose source is source's: eval3's newPairFrom.  The source of nil is nil, where eval3 reads through nil (an
;; empty [] or {} crashed it)
(define-function k_newPairFrom oop ((head oop) (tail oop) (source oop))
  (let (((obj oop) (cast 0 oop)))
    (gc-protect (head tail source)
      (set obj (new <pair>)))
    (set (<pair>-head obj) head)
    (set (<pair>-tail obj) tail)
    (set (<pair>-source obj) (if (object-is <pair> source) (<pair>-source source) (cast 0 oop)))
    (return obj)))

(define-function k_setSource void ()		; the current source's position, from its path and line
  (let (((pos oop) (k_cons k_currentPath k_currentLine)))
    (set (<pair>-source k_currentSource) pos)))

(define-function k_beginSource void ((path char *))
  (set k_currentPath (k_newStringC path))
  (set k_currentLine (k_newLong 1))
  (set k_currentSource (k_cons k_currentSource (cast 0 oop)))
  (k_setSource))

(define-function k_advanceSource void ()
  (set k_currentLine (k_newLong (+ (k_getLong k_currentLine) 1)))
  (k_setSource))

(define-function k_endSource void ()
  (set k_currentSource (<pair>-head k_currentSource))
  (let (((src oop) (k_currentSource-source)))
    (set k_currentPath (k_car src))
    (set k_currentLine (k_cdr src))))

(define-function k_currentSource-source oop ()
  (if (object-is <pair> k_currentSource) (return (<pair>-source k_currentSource)))
  (return (cast 0 oop)))

;;; reading

(define-function k_readerFatal void ((message char *))
  (printf "\nerror: %s\n" message)
  (exit 1))

(define-function k_readList oop ((fp void *) (delim long))
  (let (((head oop) (cast 0 oop))
	((tail oop) (cast 0 oop))
	((obj oop) (cast 0 oop))
	((more long) 1)
	((c long) 0))
    (gc-protect (head obj)
      (set obj (k_readExpr fp))
      (if (!= obj k_done)
	  (let ()
	    (set head (k_newPairFrom obj (cast 0 oop) k_currentSource))
	    (set tail head)
	    (while more
	      (set obj (k_readExpr fp))
	      (if (= obj k_done)
		  (set more 0)
		(if (= obj s_dot)
		    (let ()
		      (set obj (k_readExpr fp))
		      (if (= obj k_done) (k_readerFatal "missing item after ."))
		      (set (<pair>-tail tail) obj)
		      (set obj (k_readExpr fp))
		      (if (!= obj k_done) (k_readerFatal "extra item after ."))
		      (set more 0))
		  (let ()
		    (set obj (k_newPairFrom obj (cast 0 oop) k_currentSource))
		    (set (<pair>-tail tail) obj)
		    (set tail obj))))))))
    (set c (k_getc fp))
    (if (!= c delim)
	(let ()
	  (if (< c 0) (k_readerFatal "EOF while reading list"))
	  (printf "\nerror: mismatched delimiter: expected '%c' found '%c'\n" (cast delim int) (cast c int))
	  (exit 1)))
    (return head)))

(define-function k_digitValue long ((c long))
  (if (and (>= c 48) (<= c 57)) (return (- c 48)))		; 0 ... 9
  (if (and (>= c 65) (<= c 90)) (return (+ (- c 65) 10)))	; A ... Z
  (if (and (>= c 97) (<= c 122)) (return (+ (- c 97) 10)))	; a ... z
  (k_readerFatal "illegal digit in character escape")
  (return 0))

(define-function k_isHexadecimal int ((c long))
  (return (or (and (>= c 48) (<= c 57)) (and (>= c 65) (<= c 70)) (and (>= c 97) (<= c 102)))))

(define-function k_isOctal int ((c long))	(return (and (>= c 48) (<= c 55))))

;; a character, after a backslash its escape: named, \u and four hex digits, \x and up to two, or up to three octal
(define-function k_readChar long ((c long) (fp void *))
  (if (!= c 92) (return c))					; not \
  (set c (k_getc fp))
  (if (= c 97)  (return 7))					; \a
  (if (= c 98)  (return 8))					; \b
  (if (= c 102) (return 12))					; \f
  (if (= c 110) (return 10))					; \n
  (if (= c 114) (return 13))					; \r
  (if (= c 116) (return 9))					; \t
  (if (= c 118) (return 11))					; \v
  (if (= c 117)							; \u
      (let* (((a long) (k_getc fp)) ((b long) (k_getc fp)) ((d long) (k_getc fp)) ((e long) (k_getc fp)))
	(return (+ (<< (k_digitValue a) 12) (+ (<< (k_digitValue b) 8) (+ (<< (k_digitValue d) 4) (k_digitValue e)))))))
  (if (= c 120)							; \x
      (let (((x long) 0))
	(set c (k_getc fp))
	(if (k_isHexadecimal c)
	    (let ()
	      (set x (k_digitValue c))
	      (set c (k_getc fp))
	      (if (k_isHexadecimal c)
		  (let ()
		    (set x (+ (* x 16) (k_digitValue c)))
		    (set c (k_getc fp))))))
	(ungetwc (cast c int) fp)
	(return x)))
  (if (k_isOctal c)
      (let (((x long) (k_digitValue c)))
	(set c (k_getc fp))
	(if (k_isOctal c)
	    (let ()
	      (set x (+ (* x 8) (k_digitValue c)))
	      (set c (k_getc fp))
	      (if (k_isOctal c)
		  (let ()
		    (set x (+ (* x 8) (k_digitValue c)))
		    (set c (k_getc fp))))))
	(ungetwc (cast c int) fp)
	(return x)))
  (if (or (k_isAlpha c) (k_isDigit10 c))
      (let ()
	(printf "\nerror: illegal character escape: \\%c\n" (cast c int))
	(exit 1)))
  (return c))

;; a number from its first character (a digit, or - before one): a double if a . or an e follows the digits, otherwise
;; a long, in hexadecimal after 0x or -0x
(define-function k_readNumber oop ((c long) (fp void *))
  (k_bufferReset)
  (k_bufferAppend c)
  (set c (k_getc fp))
  (while (k_isDigit10 c)
    (k_bufferAppend c)
    (set c (k_getc fp)))
  (if (or (= c 46) (= c 101))					; . or e
      (let ()
	(if (= c 46)
	    (let ()
	      (k_bufferAppend c)
	      (set c (k_getc fp))
	      (while (k_isDigit10 c)
		(k_bufferAppend c)
		(set c (k_getc fp)))))
	(if (= c 101)
	    (let ()
	      (k_bufferAppend c)
	      (set c (k_getc fp))
	      (if (= c 45)					; -
		  (let ()
		    (k_bufferAppend c)
		    (set c (k_getc fp))))
	      (while (k_isDigit10 c)
		(k_bufferAppend c)
		(set c (k_getc fp)))))
	(ungetwc (cast c int) fp)
	(return (k_newDouble (wcstod (k_bufferContents) (cast 0 void *))))))
  (if (and (= c 120)						; x, after 0 or -0
	   (or (= (k_bufferLength) 1) (and (= (k_bufferLength) 2) (= (indir k_buffer 0) 45))))
      (let ()
	(k_bufferAppend c)
	(set c (k_getc fp))
	(while (k_isDigit16 c)
	  (k_bufferAppend c)
	  (set c (k_getc fp)))))
  (ungetwc (cast c int) fp)
  (return (k_newLong (wcstoul (k_bufferContents) (cast 0 void *) 0))))

;; 'x, `x and ,x or ,@x as (quote x) and so on, or the symbol alone at the end of the input
(define-function k_readQuoted oop ((sym oop) (fp void *))
  (let (((obj oop) (k_readExpr fp)))
    (if (= obj k_done) (return sym))
    (gc-protect (obj)
      (set obj (k_newPairFrom obj (cast 0 oop) k_currentSource))
      (set obj (k_newPairFrom sym obj k_currentSource)))
    (return obj)))

;; [ ... ] and { ... }: the list read, headed by bracket or brace
(define-function k_readBracketed oop ((sym oop) (delim long) (fp void *))
  (let (((obj oop) (k_readList fp delim)))
    (gc-protect (obj)
      (set obj (k_newPairFrom sym obj obj)))
    (return obj)))

(define-function k_readSymbol oop ((c long) (fp void *))
  (k_bufferReset)
  (while (or (k_isLetter c) (k_isDigit10 c))
    (k_bufferAppend c)
    (set c (k_getc fp)))
  (ungetwc (cast c int) fp)
  (return (k_intern (k_bufferContents))))

;; the next datum, or k_done at the end of the input or before a closing delimiter
(define-function k_readExpr oop ((fp void *))
  (let (((c long) 0) ((d long) 0))
    (while 1
      (set c (k_getc fp))
      (if (< c 0) (return k_done))				; WEOF
      (if (= c 10)						; newline, and any carriage returns after it
	  (let ()
	    (set c (k_getc fp))
	    (while (= c 13) (set c (k_getc fp)))
	    (if (>= c 0) (ungetwc (cast c int) fp))
	    (k_advanceSource))
	(if (= c 13)						; carriage return, and any newlines after it
	    (let ()
	      (set c (k_getc fp))
	      (while (= c 10) (set c (k_getc fp)))
	      (ungetwc (cast c int) fp)
	      (k_advanceSource))
	  (if (= c 59)						; ; to the end of the line
	      (let (((more long) 1))
		(while more
		  (set c (k_getc fp))
		  (if (< c 0) (set more 0)
		    (if (or (= c 10) (= c 13))
			(let () (ungetwc (cast c int) fp) (set more 0))))))
	    (if (and (!= c 9) (!= c 32))			; not a tab or a space
		(let ()
		  (if (= c 34)					; "
		      (let (((more long) 1))
			(k_bufferReset)
			(while more
			  (set c (k_getc fp))
			  (if (= c 34)
			      (set more 0)
			    (let ()
			      (set c (k_readChar c fp))
			      (if (< c 0) (k_readerFatal "EOF in string literal"))
			      (k_bufferAppend c))))
			(return (k_newString (k_bufferContents)))))
		  (if (= c 63) (return (k_newLong (k_readChar (k_getc fp) fp))))	; ?
		  (if (= c 39) (return (k_readQuoted s_quote fp)))		; '
		  (if (= c 96) (return (k_readQuoted s_quasiquote fp)))		; `
		  (if (= c 44)							; , or ,@
		      (let ()
			(set d (k_getc fp))
			(if (= d 64) (return (k_readQuoted s_unquote_splicing fp)))
			(ungetwc (cast d int) fp)
			(return (k_readQuoted s_unquote fp))))
		  (if (k_isDigit10 c) (return (k_readNumber c fp)))
		  (if (= c 40) (return (k_readList fp 41)))			; ( ... )
		  (if (= c 91) (return (k_readBracketed s_bracket 93 fp)))	; [ ... ]
		  (if (= c 123) (return (k_readBracketed s_brace 125 fp)))	; { ... }
		  (if (or (= c 41) (= c 93) (= c 125))				; a closing delimiter
		      (let () (ungetwc (cast c int) fp) (return k_done)))
		  (if (= c 45)							; -, a number if a digit follows
		      (let ()
			(set d (k_getc fp))
			(ungetwc (cast d int) fp)
			(if (k_isDigit10 d) (return (k_readNumber c fp)))))
		  (if (k_isLetter c) (return (k_readSymbol c fp)))
		  (if (k_isPrint c)
		      (printf "\nerror: illegal character: 0x%02x '%c'\n" (cast c int) (cast c int))
		    (printf "\nerror: illegal character: 0x%02x\n" (cast c int)))
		  (exit 1))))))))
  (return k_done))
