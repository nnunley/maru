;;; ksworld-pp.l -- Deserializer and object model for KSWorld / Frank (.pp bundles)

(require "st-classes.l")
;; an object's slots are a hash table (hash.l), keyed by identity, as an IdentityDictionary's (every KSWorld object is one),
;; or by equality for a Dictionary (and its subclasses); its class is a Maru type (st-classes.l)
(define-function ks-slots-table (class)
  (let ((c class) (kind ()))
    (while (and c (not kind))
      (cond ((= c 'IdentityDictionary)	(set kind 'identity))
	    ((= c 'Dictionary)		(set kind 'equal))
	    (else			(set c (and ks-superclass (ks-superclass c))))))
    (if (= kind 'equal) (equal-hash-table) (identity-hash-table))))
(define ks-set-slot)
(define ks-set-items)
;; what a document kept of an object that isn't one of its slots (its number, :ref, its home, a Form's file, a stream's
;; type and code, spans ...), and what the evaluator caches beside it: attributes, entries in its dictionary under their
;; keywords.  An object with no dictionary has none: a document's attribute for one is dropped (its number among them), and
;; anything else that sets one is refused, so nothing is lost without a word
(define-function ks-attr (obj key) (let ((t (ks-table obj))) (and t (hash-at t key))))
(define-function ks-set-attr (obj key value)
  (hash-at-put (or (ks-table obj) (error "KScript: a " (ks-class-of obj) " keeps no attributes, so none " key)) key value))
;; an object of class: each slot its field or its dictionary's entry, each attribute (a plist, :key value) an entry, data
;; its elements (items, a FloatArray's data, a KSContentsCollection's array), count a FloatArray's count; ref a document's
(define-function ks-new-object (class ref attrs slots data count)	; slots: ((name . value) ...), first first
  (let* ((type (ks-object-type class)) (o (new type)) (i (ks-field-index type 'slots)))
    (and i (set-oop-at o i (ks-slots-table class)))
    (when i	; a document's attributes, its number among them, where there is a dictionary to keep them
      (and ref (< 0 ref) (ks-set-attr o ':ref ref))
      (while attrs (ks-set-attr o (car attrs) (cadr attrs)) (set attrs (cddr attrs))))
    (list-do p slots (ks-set-slot o (car p) (cdr p)))
    (and data (ks-set-items o data))
    (and count (ks-field-index type 'count) (ks-set-slot o 'count count))
    o))
(define-structure <ks-point>  (x y))
(define-structure <ks-rect>   (left top right bottom))
(define-structure <ks-matrix> (a b c d e f))	; Gezira's: x' = a x + c y + e, y' = b x + d y + f
(define-structure <ks-color>  (r g b a))

(define-function ks-named-field (type key)	; the field a slot named key is, or (): a dictionary's own table is no slot
  (and (not (= key 'slots)) (ks-field-index type key)))
(define-function ks-slot-entry (obj key)	; (key . value), or () for a slot obj hasn't: its field, or its dictionary's entry
  (and (ks-object? obj)
       (let ((i (ks-named-field (type-of obj) key)))
	 (if i (cons key (oop-at obj i)) (let ((t (ks-table obj))) (and t (hash-entry t key)))))))
(define-function ks-slots-do (obj fn)	; (fn name value) for each of obj's slots: its fields, then its dictionary's entries
  (when (ks-object? obj)
    (let ((i 0))
      (list-do name (array-at %structure-fields (type-of obj))
	(or (= name 'slots) (fn name (oop-at obj i)))
	(set i (+ i 1))))
    (let ((t (ks-table obj))) (and t (hash-do t fn)))))
(define-function ks-point? (x)	(= <ks-point>  (type-of x)))
(define-method equal <ks-point> (b) (and (ks-point? b) (equal self.x (<ks-point>-x b)) (equal self.y (<ks-point>-y b))))	; by x and y
(define-method equal-hash <ks-point> () (+ (* 31 (equal-hash self.x)) (equal-hash self.y)))
(define-function ks-rect? (x)	(= <ks-rect>   (type-of x)))
(define-function ks-matrix? (x)	(= <ks-matrix> (type-of x)))
(define-function ks-color? (x)	(= <ks-color>  (type-of x)))

(define-function ks-point (x y)			(new <ks-point> (* 1.0 x) (* 1.0 y)))
(define-function ks-rect (l t r b)		(new <ks-rect> (* 1.0 l) (* 1.0 t) (* 1.0 r) (* 1.0 b)))
(define-function ks-matrix (a b c d e f)	(new <ks-matrix> (* 1.0 a) (* 1.0 b) (* 1.0 c) (* 1.0 d) (* 1.0 e) (* 1.0 f)))
;; a matrix as Squeak writes one, row by row (x' = a11 x + a12 y + a13, y' = a21 x + a22 y + a23): the documents' text, and
;; KScript's M(...), say it so; read once into Gezira's fields
(define-function ks-matrix-rows (a11 a12 a13 a21 a22 a23)	(ks-matrix a11 a21 a12 a22 a13 a23))
(define-function ks-color (r g b a)		(new <ks-color> (* 1.0 r) (* 1.0 g) (* 1.0 b) (* 1.0 a)))

;; (define-flags name a b c ...) defines a as 1, b as 2, c as 4, and so on, a bit each in order, and name as ((a . 1) ...)
(define-form define-flags (name . members)
  (let ((bit 1) (values ()))
    (list-do m members
      (push values `(define ,m ,bit))
      (set bit (<< bit 1)))
    `(let () ,@(list-reverse! values) (define ,name (list ,@(map (lambda (m) `(cons ',m ,m)) members))))))

;; a face's style, as a document stores it: a bit for each emphasis, plain when none is set
(define-flags ks-emphasis ks-bold ks-italic ks-underlined ks-narrow ks-struck-out)
(define ks-plain 0)
(define ks-bold-italic (| ks-bold ks-italic))

(define-method do-print <ks-point> ()	(print "(" self.x "@" self.y ")"))
(define-method do-print <ks-rect> ()	(print "(" self.left "@" self.top " corner: " self.right "@" self.bottom ")"))
(define-method do-print <ks-matrix> ()	(print "[M " self.a " " self.b " " self.c " " self.d " " self.e " " self.f "]"))
(define-method do-print <ks-color> ()	(print "[rgba " self.r " " self.g " " self.b " " self.a "]"))

(define-function ks-plist-get (pl key)
  (let ((res ()))
    (while pl
      (if (= (car pl) key)
	  (let () (set res (cadr pl)) (set pl ()))
	(set pl (cddr pl))))
    res))

(define-function ks-slot (obj key)
  (let ((p (ks-slot-entry obj key))) (and p (cdr p))))

(set ks-set-slot (lambda (obj key val)	; its field, or its dictionary's entry; an object with neither for key is refused
  (or (ks-object? obj) (error "KScript: a " (ks-class-of obj) " has no named slots, so none " key))
  (let ((i (ks-named-field (type-of obj) key)))
    (cond (i (set-oop-at obj i val))
	  ((ks-table obj) (hash-at-put (ks-table obj) key val))
	  (else (error "KScript: a " (ks-class-of obj) " has no " key))))
  val))
(define-function ks-ref (obj)	; the number a document gave obj, or 0
  (let ((r (ks-attr obj ':ref))) (cond ((long? r) r) ((string? r) (string->long r)) (else 0))))

(define-function ks-stream-value (s)	; a stream's current value; one it was saved without is undefined, as in KSWorld
  (let ((p (ks-slot-entry s '__currentValue__)))
    (if p (cdr p) 'undefined)))

(define-function ks-val (obj key)
  (let ((v (ks-slot obj key)))
    (if (and (ks-object? v) (ks-instance? v 'KSEventStream))
	(ks-stream-value v)
      v)))

(define-function ks-slot-false? (obj key)	; has the slot, and it holds false (a slot it lacks isn't false, it's missing)
  (let ((p (ks-slot-entry obj key)))
    (and p (not (ks-val obj key)))))

(define-function ks-set-val (obj key val)
  (let ((v (ks-slot obj key)))
    (if (and (ks-object? v) (ks-instance? v 'KSEventStream))
	(ks-set-slot v '__currentValue__ val)
      (ks-set-slot obj key val))))

(define-function ks-elements-of-items (items) (cond ((array? items) (array->list items)) ((hash-table? items) (array->list (hash-keys items))) (else items)))
(define-function ks-items (obj)	; a collection's elements, as a list: a Maru array's, an OrderedCollection's items, a
  (cond ((array? obj) (array->list obj))	; KSContentsCollection's array from firstIndex to lastIndex, a KSStack's contents'
	((not (ks-object? obj)) ())
	((ks-instance? obj 'KSStack) (ks-items (ks-slot obj 'contents)))
	((ks-instance? obj 'KSContentsCollection)
	 (let ((a (ks-slot obj 'array)) (first (or (ks-slot obj 'firstIndex) 1)) (last (or (ks-slot obj 'lastIndex) 0)) (out ()))
	   (for (i first (+ last 1)) (push out (array-at a (- i 1))))
	   (list-reverse! out)))
	((ks-field-index (type-of obj) 'items) (ks-elements-of-items (ks-slot obj 'items)))
	((ks-field-index (type-of obj) 'data) (ks-slot obj 'data))
	(else ())))
(set ks-set-items (lambda (obj data)	; a collection made from its elements, data a list
  (cond ((ks-instance? obj 'KSContentsCollection)
	 (ks-set-slot obj 'array (list->array data)) (ks-set-slot obj 'firstIndex 1) (ks-set-slot obj 'lastIndex (list-length data)))
	((inherits-from (type-of obj) (ks-class-type 'Set))	; a Set's members, once each, as a table's keys
	 (let ((t (if (ks-instance? obj 'IdentitySet) (identity-hash-table) (equal-hash-table))))
	   (list-do x data (hash-at-put t x 't))
	   (ks-set-slot obj 'items t)))
	((ks-field-index (type-of obj) 'items) (ks-set-slot obj 'items data))
	((ks-field-index (type-of obj) 'data) (ks-set-slot obj 'data data))
	(else (error "KScript: a " (ks-class-of obj) " keeps no elements")))))

(define-function ks-split (str sep)
  (let ((out ()) (start 0) (n (string-length str)))
    (for (i 0 n)
      (when (= sep (string-at str i))
	(and (< start i) (push out (string-copy str start (- i start))))
	(set start (+ i 1))))
    (and (< start n) (push out (string-copy str start (- n start))))
    (list-reverse! out)))

(define-function ks-find-char (str ch)
  (let ((i 0) (n (string-length str)))
    (while (and (< i n) (!= ch (string-at str i))) (incr i))
    (and (< i n) i)))

(define-function ks-parse-num (str)
  (if (or (ks-find-char str ?.) (ks-find-char str ?e) (ks-find-char str ?E))
      (string->double str)
    (string->long str)))

(define-function ks-parse-point (str)
  (let ((at (ks-find-char str ?@)))
    (if at
	(ks-point (ks-parse-num (string-copy str 0 at))
		  (ks-parse-num (string-copy str (+ at 1) (- (string-length str) (+ at 1)))))
      (ks-point 0.0 0.0))))

(define-function ks-parse-rect (str)
  (let* ((ws (ks-split str 32))
	 (p0 (ks-parse-point (or (car ws) "0@0")))
	 (p1 (ks-parse-point (or (caddr ws) "0@0"))))
    (ks-rect (<ks-point>-x p0) (<ks-point>-y p0) (<ks-point>-x p1) (<ks-point>-y p1))))

(define-function ks-parse-value (vcls vstr)
  (cond ((or (= vcls 'Number) (= vcls 'SmallInteger)) (ks-parse-num vstr))
	((= vcls 'Float) (string->double vstr))
	((= vcls 'True) 't)
	((or (= vcls 'False) (= vcls 'UndefinedObject)) ())
	((= vcls 'KSProtoObject) 'undefined)
	((or (= vcls 'Symbol) (= vcls 'ByteSymbol)) (string->symbol vstr))
	((or (= vcls 'String) (= vcls 'ByteString)) vstr)
	((= vcls 'Point) (ks-parse-point vstr))
	((= vcls 'Rectangle) (ks-parse-rect vstr))
	((= vcls 'Color)
	 (let ((ws (map ks-parse-num (ks-split vstr 32))))
	   (ks-color (/ (or (car ws) 0) 1023.0)
		     (/ (or (cadr ws) 0) 1023.0)
		     (/ (or (caddr ws) 0) 1023.0)
		     (/ (or (cadddr ws) 255) 255.0))))
	((= vcls 'MatrixTransform2x3)
	 (let ((ws (map string->double (ks-split vstr 32))))
	   (ks-matrix-rows (or (car ws) 1.0) (or (cadr ws) 0.0) (or (caddr ws) 0.0)
			   (or (cadddr ws) 0.0) (or (car (cddddr ws)) 1.0) (or (cadr (cddddr ws)) 0.0))))
	(else vstr)))

(define-function b64-val (c)
  (cond ((and (<= ?A c) (<= c ?Z)) (- c ?A))
	((and (<= ?a c) (<= c ?z)) (+ 26 (- c ?a)))
	((and (<= ?0 c) (<= c ?9)) (+ 52 (- c ?0)))
	((= c ?+) 62) ((= c ?/) 63) (else -1)))

(define-function b64-decode-words (str mode)
  (let ((len (string-length str)) (tmp (data (string-length str)))
	(bi 0) (acc 0) (bits 0))
    (for (i 0 len)
      (let ((v (b64-val (string-at str i))))
	(when (<= 0 v)
	  (set acc (+ (<< acc 6) v))
	  (set bits (+ bits 6))
	  (when (<= 8 bits)
	    (set bits (- bits 8))
	    (set-byte-at tmp bi (& 255 (>> acc bits)))
	    (incr bi)))))
    (if (= mode 'bytes)
	(let ((out (data bi)))
	  (for (i 0 bi) (set-byte-at out i (byte-at tmp i)))
	  out)
      (let* ((n (+ (+ (<< (byte-at tmp 0) 24) (<< (byte-at tmp 1) 16))
		   (+ (<< (byte-at tmp 2) 8) (byte-at tmp 3))))
	     (out (data (* n 4))))
	(for (w 0 n)
	  (let ((s (+ 4 (* w 4))) (d (* w 4)))
	    (if (= mode 'shorts)
		(let ()
		  (set-byte-at out (+ d 0) (byte-at tmp (+ s 1)))
		  (set-byte-at out (+ d 1) (byte-at tmp (+ s 0)))
		  (set-byte-at out (+ d 2) (byte-at tmp (+ s 3)))
		  (set-byte-at out (+ d 3) (byte-at tmp (+ s 2))))
	      (let ()
		(set-byte-at out (+ d 0) (byte-at tmp (+ s 3)))
		(set-byte-at out (+ d 1) (byte-at tmp (+ s 2)))
		(set-byte-at out (+ d 2) (byte-at tmp (+ s 1)))
		(set-byte-at out (+ d 3) (byte-at tmp (+ s 0)))))))
	out))))

;; A FloatArray's length in floats, from the first word of its base64: the count the document gives.
(define-function b64-word-count (str)
  (let ((acc 0) (bits 0) (got 0) (i 0))
    (while (and (< got 4) (< i (string-length str)))
      (let ((v (b64-val (string-at str i))))
	(when (<= 0 v)
	  (set acc (+ (<< acc 6) v))
	  (set bits (+ bits 6))
	  (when (<= 8 bits)
	    (set bits (- bits 8))
	    (set got (+ got 1)))))
      (set i (+ i 1)))
    (& (>> acc bits) 4294967295)))

(define-function ksworld-read-pp (path)
  (if (or (= 0 (string-compare path "http://" 0 7))
	  (= 0 (string-compare path "https://" 0 8)))
      (let ((tmp "/tmp/ksworld-download.pp"))
	((subr "system" "s>i") (concat-strings "curl -sL \"" path "\" -o " tmp))
	(car (read tmp)))
    (car (read path))))

;; a path's directory, with its slash ("" for none)
(define-function ksworld-directory (path)
  (let ((end 0))
    (for (i 0 (string-length path)) (and (= ?/ (string-at path i)) (set end (+ i 1))))
    (string-copy path 0 end)))

;; KSWorld wrote a text box's contents, its letter boxes, as spans of one font (data (span :data "..." :family ... :size
;; ... :style ... :fill ...)); reading them gives each character a letter box, as KSBox>>beCharacter made one: its unicode,
;; its font (the span's, shared by its letters) and its container.  Layout places them (ksworld-text.l).  A box in the
;; text (KSBox>>addTextContents takes boxes as well as characters) was written among the spans as (slot :ref N), and is
;; read back as itself, in its place: it is already a document object, with its own container and transformation.
(define-function ks-spans? (box) (and (ks-attr box ':__spans__) 't))	; the spans a document kept, until letters are made
(define-function ks-letter-contents (box table)
  (let ((letters ()))
    (list-do s (ks-attr box ':__spans__)
      (if (= 'slot (car s))
	  (push letters (array-at table (string->long (ks-plist-get (cdr s) ':ref))))
	(let ((font (ks-new-object 'KSFont 0 (cdr s) () () 0)) (text (ks-plist-get (cdr s) ':data)))
	  (for (i 0 (string-length text))
	    (push letters (ks-new-object 'KSBox 0 ()
			       (list (cons 'container box) (cons 'unicode (string-at text i)) (cons 'font font)
				     (cons 'transformation ()) (cons 'extent ()) (cons 'bounds ()))
			       () 0))))))
    (ks-set-attr box ':__spans__ ())
    (ks-set-slot box 'contents (ks-new-object 'KSContentsCollection 0 () () (list-reverse! letters) 0))))

(define-function ks-pp-sub (rest tag)	; an entry's (tag ...) part
  (let ((f ())) (list-do sub rest (and (pair? sub) (= tag (car sub)) (not f) (set f sub))) f))
(define-function ks-by-index (indexed)	; ((index . value) ...), any order, to the values by index from 1
  (let ((n 0)) (list-do p indexed (and (< n (car p)) (set n (car p))))
    (let ((a (array n))) (list-do p indexed (set-array-at a (- (car p) 1) (cdr p))) (array->list a))))
(define-function ks-indexed? (key)	; a collection's element's slot is named by its index, 1 ...
  (let ((s (symbol->string key))) (and (< 0 (string-length s)) (<= ?0 (string-at s 0)) (<= (string-at s 0) ?9))))

(define-function ksworld-load (path)
  (let* ((form (ksworld-read-pp path))
	 (root-id (string->long (ks-plist-get (cdr form) ':root)))
	 (entries (cdddr form))
	 (table (array)))
    ;; Pass 1: every object, by its number: an Array a Maru array of its size, anything else an instance of its class
    (list-do e entries
      (let ((cls (car e)) (rest (cdr e)) (attrs ()) (ref 0))
	(while (and rest (symbol? (car rest)))
	  (let ((k (car rest)) (v (cadr rest)))
	    (and (= k ':ref) (set ref (string->long v)))
	    (set attrs (cons k (cons v attrs)))
	    (set rest (cddr rest))))
	(set-array-at table ref
		      (if (= cls 'Array)
			  (let ((size (ks-plist-get attrs ':size)) (data (ks-pp-sub rest 'data)))
			    (array (if size (string->long size) (list-length (cdr data)))))
			(ks-new-object cls ref attrs () () 0)))
	;; a Form's image is a file beside the document
	(let ((href (ks-plist-get attrs ':href)))
	  (and href (= cls 'Form) (ks-set-attr (array-at table ref) ':__path__ (concat-string (ksworld-directory path) href))))))
    ;; Pass 2: each object's slots, elements and data
    (list-do e entries
      (let* ((cls (car e)) (rest (cdr e)))
	(while (and rest (symbol? (car rest))) (set rest (cddr rest)))
	(let* ((ref (string->long (ks-plist-get (cdr e) ':ref)))
	       (obj (array-at table ref))
	       (home (ks-plist-get (cdr e) ':__homeObject__))
	       (val-attr (ks-plist-get (cdr e) ':value))
	       (slots ()) (indexed ()) (data ()))
	  (when home (ks-set-attr obj ':__home__ (array-at table (string->long home))))
	  (list-do sub rest
	    (when (pair? sub)
	      (cond ((= (car sub) 'slot)
		     (let* ((pl (cdr sub))
			    (kstr (or (ks-plist-get pl ':keyValue) (ks-plist-get pl ':name)))
			    (key (string->symbol kstr))
			    (vid (or (ks-plist-get pl ':valueId) (ks-plist-get pl ':ref)))
			    (vcls (or (ks-plist-get pl ':valueClass) (ks-plist-get pl ':class)))
			    (vstr (or (ks-plist-get pl ':valueValue) (ks-plist-get pl ':value)))
			    (val (if vid
				     (array-at table (string->long vid))
				   (ks-parse-value (string->symbol vcls) vstr))))
		       (if (and (ks-indexed? key) (not (ks-table obj))) (push indexed (cons (string->long kstr) val))
			 (push slots (cons key val)))))
		    ((= (car sub) 'data)
		     (let ((items (cdr sub)))
		       (set data (cond ((member? cls '(FloatArray ShortPointArray ByteArray)) items)
				       ((and items (string? (car items))) (map (lambda (id) (array-at table (string->long id))) items))
				       (else items))))))))
	  (list-do p (list-reverse! slots) (ks-set-slot obj (car p) (cdr p)))	; in the document's order
	  ;; elements: a raw array's words, a list of ids, or slots 1 ... size (a nil or false element is one)
	  (let ((words (or (and (member? cls '(FloatArray ShortPointArray ByteArray)) (or (car data) val-attr)) ())))
	    (cond (words
		   (ks-set-slot obj 'data (b64-decode-words words (cond ((= cls 'ShortPointArray) 'shorts) ((= cls 'ByteArray) 'bytes) (else 'floats))))
		   (ks-set-slot obj 'count (b64-word-count words)))
		  ((array? obj)
		   (let ((i 0)) (list-do x data (set-array-at obj i x) (set i (+ i 1))))
		   (list-do p indexed (set-array-at obj (- (car p) 1) (cdr p))))
		  ((and data (pair? (car data)) (= 'span (caar data))) (ks-set-attr obj ':__spans__ data))
		  ((or data indexed)
		   (ks-set-items obj (or data (ks-by-index indexed)))))))))
    ;; Pass 3: a text box's letters, which KSWorld wrote as spans, read back into its contents as KSWorld read them
    (array-do o table (and (ks-object? o) (ks-spans? o) (ks-letter-contents o table)))
    (list (array-at table root-id) table)))
