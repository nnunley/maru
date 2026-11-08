;;; ksworld-source.l -- KSWorld's own methods, from its sources (ksworld/CLASS.st, Squeak's file-out, read by st-fileout.g).
;;;
;;;   (ks-source-methods path)      each method of the file-out: its class, side (instance or class), category, selector and
;;;                                 source, whether it's KScript ("selector = (params) ->"), and its tree, (fn PARAMS BODY...)
;;;   (ks-source-class-of path)     (CLASS SUPERCLASS IVARS), from the class's definition
;;;   (ks-load-source-class class)  each method of ksworld/CLASS.st becomes a method of CLASS, answering the sends a document
;;;                                 makes of its instances: documents keep the streams a class's methods made, not the methods
;;;
;;; Most of KSWorld is KScript kept in Smalltalk method chunks (ksworld/README.md): kscript.g reads those bodies as they were
;;; written.  The rest is Smalltalk, which squeak.g reads to the same trees (self is this, an instance variable a field of
;;; it, a keyword selector KScript's name for it, _at_put for at:put:), so the two call each other.  A Smalltalk method runs
;;; under a tag of its own, so a ^ in one of its blocks returns from it, as in Squeak.
(require "kscript.l")
(require "recover.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(tpeg-load "st-fileout.g")

;; what squeak.g's actions build
(define-function squeak-selector (keywords)	; at put -> _at_put, as KScript names Smalltalk's at:put:
  (let ((s "")) (list-do k keywords (set s (concat-strings s "_" k))) (string->symbol s)))
(define *squeak-ivars* ())	; the instance variables of the class whose method squeak.g is reading
(define *squeak-classvars* ())	; and its class variables, (CLASS . NAMES)
(define-function squeak-name (parser x)	; self, an instance variable, a class variable, or a name
  (cond ((= x "self") 'this)
	((member? x *squeak-ivars*) `(field this ,(string->symbol x)))
	((member? x (cdr *squeak-classvars*)) `(classvar ,(car *squeak-classvars*) ,(string->symbol x)))
	(else (string->symbol x))))
(define-function squeak-keyword-send (r parts)
  `(send ,r ,(squeak-selector (map car parts)) ,@(map cdr parts)))
(define-function squeak-cascade (first rest)	; each message of the cascade to the receiver of the first
  `(cascade ,(cadr first) (,(caddr first) ,@(cdddr first))
	    ,@(map (lambda (m) (cond ((= 'keyword (car m)) (cons (squeak-selector (map car (cdr m))) (map cdr (cdr m))))
				     ((= 'binary (car m)) (cdr m))
				     (else (cdr m))))
		   rest)))
(define-function squeak-assign (v e) `(assign ,v ,e))
(define-function squeak-number (s)	; 12, -3, 2.5, 1e10, 16rFF
  (let ((r (let ((i 0) (f ())) (for (k 0 (string-length s)) (and (= ?r (string-at s k)) (set f k))) f)))
    (if r
	(let* ((neg (= ?- (string-at s 0))) (radix (string->long (string-copy s (if neg 1 0) (- r (if neg 1 0))))) (n 0))
	  (for (k (+ r 1) (string-length s))
	    (let ((c (string-at s k))) (set n (+ (* n radix) (if (<= ?A c) (+ 10 (- c ?A)) (- c ?0))))))
	  (if neg (- 0 n) n))
      (if (let ((d ())) (for (k 0 (string-length s)) (and (member? (string-at s k) '(46 101)) (set d 1))) d)
	  (string->double s)
	(string->long s)))))
(tpeg-load "squeak.g")

(define-structure <ks-source-method> (class side category selector source kscript? tree))

(define-function ks-blank? (c) (member? c '(32 9 10 13)))
(define-function ks-source-head (src)	; (selector . kscript?): KScript is "selector = (", Smalltalk a message pattern
  (let ((i 0) (n (string-length src)) (start 0))
    (while (and (< i n) (ks-blank? (string-at src i))) (set i (+ i 1)))
    (set start i)
    (while (and (< i n) (not (ks-blank? (string-at src i))) (not (= ?= (string-at src i))) (not (= ?: (string-at src i)))) (set i (+ i 1)))
    (let ((sel (string->symbol (string-copy src start (- i start)))))
      (while (and (< i n) (ks-blank? (string-at src i))) (set i (+ i 1)))
      (cons sel (and (< (+ i 1) n) (= ?= (string-at src i))
		     (let ((j (+ i 1))) (while (and (< j n) (ks-blank? (string-at src j))) (set j (+ j 1))) (and (< j n) (= ?\( (string-at src j)))))))))
;; a parse that may fail: its result, or () if it signals an error.  A catch, not recover.l's try, which would keep an undo
;; log of every write the parser makes
(define-function ks-parse-or-nil (thunk)
  (let ((tag (cons 'parse ())))
    (catch tag (lambda () (with-handler (lambda (c) (throw tag ())) thunk)))))
(define-function ks-source-tree (src)	; (fn PARAMS BODY...) as kscript.g reads "selector = (PARAMS) -> BODY", or ()
  (let ((forms (ks-parse-or-nil (lambda () (kscript-parse src)))))
    (and (pair? forms) (not (cdr forms)) (= 'assign (caar forms)) (pair? (caddr (car forms))) (= 'fn (car (caddr (car forms))))
	 (caddr (car forms)))))
(define-function ks-squeak-method (src ivars classvars)	; (SELECTOR (fn PARAMS BODY...)) as squeak.g reads a Smalltalk method, or ()
  (let ((p (text-parser-for-on <squeak> src)))
    (set *squeak-ivars* ivars)
    (set *squeak-classvars* classvars)
    (and (ks-parse-or-nil (lambda () (text-parser-invoke-rule 'method $method p))) (<text-parser>-result p))))
(define-function ks-words (s)	; a string's blank-separated words
  (let ((out ()) (w ()))
    (for (i 0 (string-length s))
      (let ((c (string-at s i)))
	(if (ks-blank? c) (and w (let () (push out (list->string (list-reverse! w))) (set w ())))
	  (push w c))))
    (and w (push out (list->string (list-reverse! w))))
    (list-reverse! out)))
(define-function assoc-string (key l)	; the pair whose car is the string key
  (let ((found ())) (while (and l (not found)) (and (= key (caar l)) (set found (car l))) (set l (cdr l))) found))
;; a file-out read once: its forms and its methods, each kept by path (KSBox.st's 370 methods take seconds to read)
(define *ks-source-forms* ())
(define-function ks-source-forms (path)
  (let ((hit (assoc-string path *ks-source-forms*)))
    (if hit (cdr hit) (cdar (push *ks-source-forms* (cons path (parse-string <stfileout> $file (contents-of-file-named path))))))))
(define-function ks-source-class-of (path)	; (CLASS SUPERCLASS IVARS), and its class variables after
  (let ((d ())) (list-do x (ks-source-forms path) (and (pair? x) (= 'definition (car x)) (set d x)))
    (and d (list (cadr d) (caddr d) (map string->symbol (ks-words (cadddr d)))))))
(define-function ks-source-classvars (path)	; (CLASS . NAMES): the class variables its definition names
  (let ((d ())) (list-do x (ks-source-forms path) (and (pair? x) (= 'definition (car x)) (set d x)))
    (and d (cons (cadr d) (and (car (cddddr d)) (ks-words (car (cddddr d))))))))
(define-function ks-read-source-methods (path)
  (let* ((forms (ks-source-forms path)) (def (let ((d ())) (list-do x forms (and (pair? x) (= 'definition (car x)) (set d x))) d))
	 (ivars (and def (ks-words (cadddr def)))) (classvars (and def (cons (cadr def) (and (car (cddddr def)) (ks-words (car (cddddr def)))))))
	 (out ()))
    (list-do x forms
      (and (pair? x) (= 'section (car x))
	   (list-do src (cddddr x)
	     (let ((head (ks-source-head src)))
	       (if (cdr head)
		   (push out (new <ks-source-method> (cadr x) (cadddr x) (caddr x) (car head) src 1 (ks-source-tree src)))
		 (let ((m (ks-squeak-method src (if (= 'class (cadddr x)) () ivars) classvars)))
		   (push out (new <ks-source-method> (cadr x) (cadddr x) (caddr x) (if m (car m) (car head)) src () (and m (cadr m))))))))))
    (list-reverse! out)))
;; a method's function: KScript runs as a closure on its receiver; Smalltalk the same, under a tag of its own, so a ^
;; anywhere in it returns from it, knowing its class, so super looks up from there, and answering self if it ends without ^
;; (a pepsi-style library method, like KScript, answers its last expression's value: test-pepsi.l's methods have no ^)
(define *ks-source-methods* ())
(define-function ks-source-methods (path)
  (let ((hit (assoc-string path *ks-source-methods*)))
    (if hit (cdr hit) (cdar (push *ks-source-methods* (cons path (ks-read-source-methods path)))))))
(define-function ks-method-function (kind tree kscript? last-value?)
  (if kscript?
      (lambda (recv args env this) (ks-apply (ks-eval tree (list (cons '%class kind)) recv) args env recv))	; super.x() too
    (lambda (recv args env this)
      (let ((tag (cons 'method ())))
	(catch tag (lambda () (let ((v (ks-apply (ks-eval tree (list (cons '%method tag) (cons '%class kind)) recv) args env recv)))
				(if last-value? v recv))))))))
(define-function ks-basic-new (class)	; Behavior>>basicNew: an instance with each instance variable nil (a dictionary's table empty)
  (ks-new-object (<ks-class>-name class) 0 () () () 0))

;; what squeak-base.st's primitives need: a Squeak symbol (#at:put:, a string or symbol) as the selector we name it by
(define-function ks-selector-of (x)
  (let ((s (if (symbol? x) (symbol->string x) x)) (parts ()) (w ()) (colon ()))
    (for (i 0 (string-length s))
      (let ((c (string-at s i)))
	(if (= c ?:) (let () (set colon 1) (push parts (list->string (list-reverse! w))) (set w ())) (push w c))))
    (if colon (squeak-selector (list-reverse! parts)) (string->symbol s))))
(define-function ks-responds? (recv sel)	; a method of its class, or a closure in a slot of that name
  (or (ks-method-for-type (type-of recv) sel)
      (and (ks-object? recv) (let ((p (ks-slot-entry recv sel))) (and p (ks-closure? (ks-stream-curr (cdr p))))))))
(define-function ks-subclasses-of (name)	; every loaded class whose superclasses include name
  (let ((out ()))
    (list-do e *ks-classes*
      (let ((k (<ks-class>-super (cdr e))) (under ()))
	(while (and k (not under)) (if (= k name) (set under 1) (set k (let ((c (ks-class-named k))) (and c (<ks-class>-super c))))))
	(and under (push out (cdr e)))))
    out))
(define-function ks-elements-of (c) (cond ((pair? c) c) ((array? c) (array->list c)) ((ks-object? c) (let ((items (ks-slot c 'items))) (if (hash-table? items) (array->list (hash-keys items)) items))) (else ())))	; a collection's elements
(define-function ks-last (l) (if (cdr l) (ks-last (cdr l)) (car l)))
(define-function ks-but-last (l) (if (cdr l) (cons (car l) (ks-but-last (cdr l))) ()))
(define-function ks-dict-key (k) (cond ((symbol? k) k) ((string? k) (string->symbol k)) (else k)))
;; a primitive's method: made in a function, so each closes over its own f (a closure made in a loop shares the loop's)
(define-function ks-primitive-function (f) (lambda (recv args env this) (apply f (cons recv args))))
;; the platform, in test-pepsi.l's form: classes, methods and primitives (Maru with self and the arguments bound)
(define-function ks-load-library (path)
  (list-do d (parse-string <squeak> $library (contents-of-file-named path))
    (let ((op (car d)))
      (cond ((= op 'class) (ks-define-class (cadr d) (caddr d) (cadddr d)))
	    ((= op 'global) (push *ks-globals* (cons (cadr d) (ks-stream-curr (ks-eval (caddr d) (list (cons '%top 1)) ())))))
	    (else
	     (let* ((class (cadr d)) (kind (if (= 'class (caddr d)) (ks-meta class) class)))
	       (if (= op 'method)
		   (ks-method kind (cadddr d) (ks-method-function kind (car (cddddr d)) () 1))
		 (ks-method kind (cadddr d) (ks-primitive-function (eval `(lambda (self ,@(car (cddddr d))) ,(cadr (cddddr d)))))))))))))
(ks-load-library "squeak-base.st")

;; what squeak-ttf.st's primitives need: a TTCFont (its description holding the font chain), a glyph of a character, the
;; left side bearing hmtx keeps, and a glyph's outline as a FloatArray, the form a document's GeziraPath keeps its floats in
(require "ksworld-text.l")	; the font chain (ks-fonts): a family, its alternatives, its generic family, a last resort
(define-function ks-ttc-font (name size style)
  (let ((d (ks-new-object 'TTFontDescription 0 () (list (cons 'fonts (ks-fonts (string->symbol (if (symbol? name) (symbol->string name) name)) style))) () 0)))
    (ks-new-object 'TTCFont 0 () (list (cons 'description d) (cons 'pointSize size) (cons 'emphasis style)) () 0)))
(define-function ks-ttc-glyph (description code)	; the first font of the chain with a glyph for code, or the first's missing glyph
  (let* ((fonts (ks-slot description 'fonts)) (f (ks-char-font fonts code)))
    (ks-new-object 'TTGlyph 0 () (list (cons 'font f) (cons 'glyph (ttf-glyph f code))) () 0)))
(define-function ttf-lsb (f glyph)
  (ttf-i16 f (if (< glyph (<ttf>-metrics f)) (+ (<ttf>-hmtx f) (+ (* 4 glyph) 2))
	       (+ (+ (<ttf>-hmtx f) (* 4 (<ttf>-metrics f))) (* 2 (- glyph (<ttf>-metrics f)))))))
(define-function ks-glyph-float-array (f glyph)
  (let* ((beziers (ttf-outline f glyph)) (floats (data (* 24 (list-length beziers)))) (i 0))
    (list-do z beziers (list-do v z (set-float-at floats i (* 1.0 v)) (set i (+ i 1))))
    (ks-new-object 'FloatArray 0 () () floats (* 6 (list-length beziers)))))
(ks-load-library "squeak-ttf.st")

(define-function ks-readable-source? (class)
  (= 0 ((subr "access" "si>i") (concat-strings "ksworld/" (symbol->string class) ".st") 4)))
;; a KSWorld class from its source: its definition (its superclass's first, if KSWorld has it), then each method
(define-function ks-load-source-class (class)
  (let* ((path (concat-strings "ksworld/" (symbol->string class) ".st")) (def (ks-source-class-of path)))
    (when def
      (let ((super (cadr def)))
	(and (not (ks-class-named super)) (ks-readable-source? super) (ks-load-source-class super))
	(ks-define-class class super (caddr def))))
    (list-do m (ks-source-methods path)
      (let ((tree (<ks-source-method>-tree m)) (kind (if (= 'class (<ks-source-method>-side m)) (ks-meta class) class)))
	(when tree	; a KScript method with parameters is its KSCompiler selector, as KSWorld compiled it: width = (aNumber) is
	  ;; width:, which a KScript call width(n) reaches (ks-squeak-selector), while width() is another method, unary width
	  (let ((f (ks-method-function kind tree (<ks-source-method>-kscript? m) ())) (sel (<ks-source-method>-selector m)))
	    (ks-method kind (if (<ks-source-method>-kscript? m) (ks-squeak-selector sel (list-length (cadr tree))) sel) f)))))
    ;; as Squeak does when a class is loaded: its class side's own initialize, if it has one
    (let ((init (ks-own-method (ks-meta class) 'initialize)))
      (and init (init (ks-class-named class) () () ())))))
