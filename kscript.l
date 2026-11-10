;;; kscript.l -- KScript parser, object/method runtime, and FRP stream evaluator
;;; (VPRI TR-2012-001, Appendices I and II).

(require "ksworld-pp.l")
(require "text-parser.l")
(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)

(define-function ks-indent (self)
  (let ((s (<text-parser>-string self))
	(i (<text-parser>-position self))
	(col 0))
    (while (and (< 0 i) (!= ?\n (string-at s (- i 1))) (!= ?\r (string-at s (- i 1))))
      (decr i))
    (while (let ((c (string-at s i))) (or (= c 32) (= c ?\t)))
      (set col (+ col (if (= ?\t (string-at s i)) 4 1)))
      (incr i))
    col))

(define-function ks-utf8-prime (self)
  (let ((s (<text-parser>-string self))
	(i (<text-parser>-position self)))
    (and (< i (<text-parser>-limit self))
	 (or (and (= 8217 (string-at s i))
		  (set (<text-parser>-position self) (+ i 1)))
	     (and (<= (+ i 3) (<text-parser>-limit self))
		  (= 226 (string-at s i))
		  (= 128 (string-at s (+ i 1)))
		  (= 153 (string-at s (+ i 2)))
		  (set (<text-parser>-position self) (+ i 3)))))))

(require "cexpr.g.l")
(require "kscript.g.l")

(define-function kscript-parse (text)
  (parse-string <kscript> $program text))

(define-function kscript-read (path)
  (parse-file <kscript> $program path))

;;; ---------------------------------------------------------------- runtime values

(define-structure <ks-closure> (params body env this))
(define-structure <ks-return>  (value))

(define-function ks-closure? (x)	(= <ks-closure> (type-of x)))
(define-function ks-return? (x)		(= <ks-return>  (type-of x)))

(define-function ks-defined? (v)	(!= v 'undefined))	; false and nil, (), are values; undefined is none
(define-function ks-truthy? (v)		(and v (!= v 'undefined)))	; Maru's truth: () is false and nil, undefined neither
(define-function ks-bool (b)		(if b 't ()))

(define-function ks-not (v)
  (cond ((= v 'undefined) 'undefined)
	((ks-truthy? v) ())
	(else 't)))

(define-function number? (x)		(or (long? x) (double? x)))

(define-function ks-num (x)
  (cond ((number? x) x)
	((string? x) (ks-parse-num x))
	(else 0)))

(define-function ks-arith (op a b)
  (cond ((or (= a 'undefined) (= b 'undefined)) 'undefined)
	((and (ks-point? a) (ks-point? b))
	 (cond ((= op '+) (ks-point (+ (<ks-point>-x a) (<ks-point>-x b)) (+ (<ks-point>-y a) (<ks-point>-y b))))
	       ((= op '-) (ks-point (- (<ks-point>-x a) (<ks-point>-x b)) (- (<ks-point>-y a) (<ks-point>-y b))))
	       ((= op '*) (ks-point (* (<ks-point>-x a) (<ks-point>-x b)) (* (<ks-point>-y a) (<ks-point>-y b))))
	       ((= op '/) (ks-point (/ (<ks-point>-x a) (<ks-point>-x b)) (/ (<ks-point>-y a) (<ks-point>-y b))))))
	((and (ks-point? a) (number? b))
	 (cond ((= op '+) (ks-point (+ (<ks-point>-x a) b) (+ (<ks-point>-y a) b)))
	       ((= op '-) (ks-point (- (<ks-point>-x a) b) (- (<ks-point>-y a) b)))
	       ((= op '*) (ks-point (* (<ks-point>-x a) b) (* (<ks-point>-y a) b)))
	       ((= op '/) (ks-point (/ (<ks-point>-x a) (* 1.0 b)) (/ (<ks-point>-y a) (* 1.0 b))))))
	((and (number? a) (ks-point? b))
	 (cond ((= op '+) (ks-point (+ a (<ks-point>-x b)) (+ a (<ks-point>-y b))))
	       ((= op '*) (ks-point (* a (<ks-point>-x b)) (* a (<ks-point>-y b))))))
	(else
	 (let ((na (ks-num a)) (nb (ks-num b)))
	   (cond ((= op '+) (+ na nb))
		 ((= op '-) (- na nb))
		 ((= op '*) (* na nb))
		 ((= op '/) (if (= nb 0) 0 (/ (* 1.0 na) nb)))
		 ((= op '%) (if (= nb 0) 0 (% (if (double? na) (double->long na) na)
					      (if (double? nb) (double->long nb) nb)))))))))

(define-function ks-cmp (op a b)
  (if (or (= a 'undefined) (= b 'undefined))
      'undefined
    (let ((na (ks-num a)) (nb (ks-num b)))
      (ks-bool (cond ((= op '<)  (<  na nb))
		     ((= op '<=) (<= na nb))
		     ((= op '>)  (>  na nb))
		     ((= op '>=) (>= na nb)))))))

(define-function ks-to-string (v)
  (cond ((string? v) v)
	((not v) "nil")
	((= v 't) "true")
	((symbol? v) (symbol->string v))
	((long? v) (long->string v))
	((double? v) (format "%g" v))
	((ks-point? v) (concat-strings (ks-to-string (<ks-point>-x v)) "@" (ks-to-string (<ks-point>-y v))))
	((ks-object? v) (or (ks-val v 'name) (concat-strings "<" (symbol->string (ks-class-of v)) "#" (long->string (ks-ref v)) ">")))
	(else "")))

;;; ---------------------------------------------------------------- environments & streams

(define *ks-logical-time* 0)
;; the time of the evaluation before, the evaluator's own (ks-sort-and-evaluate-at sets it from the one evaluating): whole
;; ticks headless, milliseconds in a window (ksworld-window.l), so a timer fires for each multiple of its step that time
;; passes, once however many it passed.  An evaluator's time only moves forward (ks-sort-and-evaluate-at refuses one
;; that doesn't).
(define *ks-previous-time* -1)
(define-function ks-time-before () *ks-previous-time*)
;; the largest whole number at most a / b, for whole or fractional steps and times
(define-function ks-floor-div (a b)
  (let* ((q (/ (* 1.0 a) b)) (n (double->long q)))
    (if (< q (long->double n)) (- n 1) n)))

(define-function ks-make-stream (home type code init-val)
  (let ((s (ks-new-object 'KSEventStream 0
		(list ':__type__ type ':__code__ code ':__home__ home ':__dormant__ "false")
		(list (cons '__currentValue__ init-val) (cons '__prevValue__ init-val))
		() 0)))
    s))

(define-function ks-stream? (x)
  (and (ks-object? x) (ks-instance? x 'KSEventStream)))

(define-function ks-stream-curr (x)
  (if (ks-stream? x) (ks-stream-value x) x))

(define-function ks-stream-prev (x)
  (if (ks-stream? x)
      (let ((p (ks-slot-entry x '__prevValue__)))	; a previous false is false; a stream read without one has its current
	(if p (cdr p) (ks-stream-value x)))
    x))

;; Classes, as Smalltalk has them: a class is a value (its name, its superclass, its instance variables), named where code
;; names it; a kind's methods are found on it or up its superclasses, and a class's own (its class side) on its metaclass,
;; "NAME class", whose superclass is its superclass's.  KSWorld's classes come from their sources (ksworld-source.l), the
;; platform's (Object, Number, Array ...) from squeak-base.st, after test-pepsi.l's hierarchy.
(define *ks-globals* ())	; (name . value), Smalltalk's globals (squeak-base.st's Smalltalk)
(define *ks-classvars* ())	; ((CLASS NAME) . value), Smalltalk's class variables
(define-function ks-bit-or (a b) (| a b))	; cexpr.g's |
(define-function ks-assoc (key l)	; the pair whose car is equal to key
  (let ((found ())) (while (and l (not found)) (and (equal key (caar l)) (set found (car l))) (set l (cdr l))) found))(define-function ks-env-lookup (env this name lag?)
  (let ((pair (assq name env)))
    (cond (pair (cdr pair))
	  ((= name 'this) this)
	  ((= name 'true) 't)
	  ((or (= name 'false) (= name 'nil) (= name 'null)) ())
	  ((= name 'undefined) 'undefined)
	  ((ks-class-named name) (ks-class-named name))
	  ((assq name *ks-globals*) (cdr (assq name *ks-globals*)))	; a global, Smalltalk say
	  ((ks-object? this)
	   (let ((s (ks-slot this name)))
	     (cond ((ks-stream? s) (if lag? (ks-stream-prev s) (ks-stream-curr s)))
		   (s s)
		   (else ()))))
	  (else name))))

(define-function ks-env-set! (env this name val)
  (let ((pair (assq name env)))
    (if pair
	(set-cdr pair val)
      (if (ks-object? this)
	  (ks-set-val this name val)
	val))))

;;; ---------------------------------------------------------------- method & call dispatch

(define ks-eval)
(define ks-apply)
(define ks-stream-deps)
(define ks-fired?)
(define ks-any-fired?)

;; a trigger with streams behind it counts only if one fired this tick, not for a value it holds
(define-function ks-event? (exp val this)
  (let ((deps (ks-stream-deps exp this 1)))
    (if deps (ks-any-fired? deps) (ks-defined? val))))

(define-function ks-box-rect (box)
  (let ((b (ks-val box 'bounds))
	(e (ks-val box 'extent)))
    (cond ((ks-rect? b) b)
	  ((ks-point? e) (ks-rect 0.0 0.0 (<ks-point>-x e) (<ks-point>-y e)))
	  (else (ks-rect 0.0 0.0 0.0 0.0)))))

(define-function ks-box-set-topleft (box pt)
  (let* ((r (ks-box-rect box))
	 (w (- (<ks-rect>-right r) (<ks-rect>-left r)))
	 (h (- (<ks-rect>-bottom r) (<ks-rect>-top r)))
	 (x (<ks-point>-x pt))
	 (y (<ks-point>-y pt)))
    (ks-set-val box 'bounds (ks-rect x y (+ x w) (+ y h)))
    (let ((tr (ks-val box 'transformation)))
      (when (ks-matrix? tr)		; its translation
	(set (<ks-matrix>-e tr) (* 1.0 x))
	(set (<ks-matrix>-f tr) (* 1.0 y))))
    pt))

(define-function ks-box-set-center (box pt)
  (let* ((r (ks-box-rect box))
	 (w (- (<ks-rect>-right r) (<ks-rect>-left r)))
	 (h (- (<ks-rect>-bottom r) (<ks-rect>-top r))))
    (ks-box-set-topleft box (ks-point (- (<ks-point>-x pt) (* 0.5 w))
				      (- (<ks-point>-y pt) (* 0.5 h))))))

;; Methods by the class of their receiver (st-classes.l: a Maru selector per selector, a method per class's type).
;; (ks-methods Class (name body...) ...) defines each name (or a list of names, all the same method) with recv, args, env
;; and this bound.  A send no method answers is an error naming class and selector: nothing is quietly nil.
(define-form ks-methods (kind . clauses)
  `(let ()
     ,@(map (lambda (c)
	      (let ((fn `(lambda (recv args env this) ,@(cdr c))))
		(if (pair? (car c))
		    `(let ((f ,fn)) ,@(map (lambda (n) `(ks-method ',kind ',n f)) (car c)))
		  `(ks-method ',kind ',(car c) ,fn))))
	    clauses)))
(define-form ks-class-methods (class . clauses)	; a class's own side, its metaclass's methods
  `(let ()
     ,@(map (lambda (c)
	      `(let ((f (lambda (recv args env this) ,@(cdr c))))
		 ,@(map (lambda (n) `(ks-method (ks-meta ',class) ',n f)) (if (pair? (car c)) (car c) (list (car c))))))
	    clauses)))

;; whether pattern from p matches text from t: * matches any run, # any one character, case aside (Squeak's String>>match:)
(define-function ks-lower (c) (if (and (<= ?A c) (<= c ?Z)) (+ c 32) c))
(define-function ks-match (pattern p text t)
  (cond ((= p (string-length pattern)) (= t (string-length text)))
	((= ?* (string-at pattern p)) (or (ks-match pattern (+ p 1) text t) (and (< t (string-length text)) (ks-match pattern p text (+ t 1)))))
	((= t (string-length text)) ())
	((or (= ?# (string-at pattern p)) (= (ks-lower (string-at pattern p)) (ks-lower (string-at text t)))) (ks-match pattern (+ p 1) text (+ t 1)))
	(else ())))
;; a list sorted by before?, stably (insertion)
(define-function ks-sort (items before?)
  (let ((out ()))
    (list-do x items
      (let ((head ()) (rest out))
	(while (and rest (not (before? x (car rest)))) (push head (car rest)) (set rest (cdr rest)))
	(set out (concat-list (list-reverse! head) (cons x rest)))))
    out))

(define-function ks-squeak-name (sel)	; our name for a selector back to Squeak's: _at_put is at:put:, size and + themselves
  (let ((s (symbol->string sel)))
    (if (and (< 1 (string-length s)) (= ?_ (string-at s 0)))
	(let ((out ()))
	  (for (i 1 (string-length s)) (push out (if (= ?_ (string-at s i)) ?: (string-at s i))))
	  (string->symbol (concat-string (list->string (list-reverse! out)) ":")))
      sel)))
(define-function ks-no-method (recv sel) (error "Smalltalk: " (ks-class-of recv) " does not understand " (ks-squeak-name sel)))

;; a KSWorld object's own kind, then what every KSWorld object answers: a closure in a slot of that name, or setting or reading
;; a field it has
(define-function ks-object-send (recv sel args env this)
  (let ((m (ks-method-for 'KSObject sel)))
    (if m (m recv args env this)
      (let ((slot (ks-slot-entry recv sel)))
	(cond ((and slot (or (ks-closure? (ks-stream-curr (cdr slot)))
			     (and (ks-object? (ks-stream-curr (cdr slot))) (ks-instance? (ks-stream-curr (cdr slot)) 'KSClosure))))
	       (ks-apply (ks-stream-curr (cdr slot)) args env recv))
	      ((and args slot (not (ks-stream? (cdr slot)))) (ks-set-val recv sel (car args)))	; a field it has; a stream is set with set()
	      ((or (not slot) args) (ks-no-method recv sel))	; a field it lacks: making one would hide a missing method
	      (else (or (ks-val recv sel) ())))))))

;; the Smalltalk selector KSCompiler makes of a KScript call (its send:receiver:arguments:): rec.abc(a) is abc:, rec.abc(a,
;; b) abc:with:, in our naming _abc and _abc_with; a selector already in that naming, or with no arguments, is itself
(define-function ks-squeak-selector (sel n)
  (let ((s (symbol->string sel)))
    (if (or (= 0 n) (= ?_ (string-at s 0))) sel
      (let ((out (concat-string "_" s))) (for (i 1 n) (set out (concat-string out "_with"))) (string->symbol out)))))
(define ks-send)	; forward: ks-native-send and ks-send call each other
;; what a send nothing answers does, at the root: a stream answers as its value does, a document's object from its slots
;; (ks-object-send), and anything else is refused naming the send
(define-function ks-native-send (recv sel args env this)
  (cond ((ks-stream? recv) (ks-send (ks-stream-curr recv) sel args env this))
	((ks-object? recv) (ks-object-send recv sel args env this))
	(else (ks-no-method recv sel))))
;; a send: the receiver's kind's method, up its superclasses; else, as in Smalltalk, doesNotUnderstand: with a Message (its
;; selector in Squeak's form and ours, its arguments), which KSObject answers from its slots and Object at the root natively
(define-function ks-send (recv sel args env this)
  (if (= recv 'undefined) 'undefined	; undefined goes through every send
    (let* ((type (type-of recv))	; a class object's type is its metaclass
	   (m (or (ks-method-for-type type sel) (and args (ks-method-for-type type (ks-squeak-selector sel (list-length args))))))
	   (dnu (and (not m) (ks-method-for-type type '_doesNotUnderstand))))
      (cond (m (m recv args env this))
	    (dnu (dnu recv (list (ks-new-object 'Message 0 () (list (cons 'selector (ks-squeak-name sel)) (cons 'name sel) (cons 'arguments (list->array args))) () 0))
		      env this))
	    (else (ks-native-send recv sel args env this))))))

(ks-methods Point
  ((x _x) (<ks-point>-x recv))
  ((y _y) (<ks-point>-y recv))
  (extent (let ((ext (car args)))
	    (ks-rect (<ks-point>-x recv) (<ks-point>-y recv)
		     (+ (<ks-point>-x recv) (<ks-point>-x ext)) (+ (<ks-point>-y recv) (<ks-point>-y ext)))))
  (printString (ks-to-string recv)))

(ks-methods Rectangle
  (topLeft (ks-point (<ks-rect>-left recv) (<ks-rect>-top recv)))
  (topRight (ks-point (<ks-rect>-right recv) (<ks-rect>-top recv)))
  (bottomLeft (ks-point (<ks-rect>-left recv) (<ks-rect>-bottom recv)))
  (bottomRight (ks-point (<ks-rect>-right recv) (<ks-rect>-bottom recv)))
  (center (ks-point (* 0.5 (+ (<ks-rect>-left recv) (<ks-rect>-right recv))) (* 0.5 (+ (<ks-rect>-top recv) (<ks-rect>-bottom recv)))))
  (width (- (<ks-rect>-right recv) (<ks-rect>-left recv)))
  (height (- (<ks-rect>-bottom recv) (<ks-rect>-top recv)))
  (extent (ks-point (- (<ks-rect>-right recv) (<ks-rect>-left recv)) (- (<ks-rect>-bottom recv) (<ks-rect>-top recv))))
  (outsetBy (let ((p (car args)))
	      (ks-rect (- (<ks-rect>-left recv) (<ks-point>-x p)) (- (<ks-rect>-top recv) (<ks-point>-y p))
		       (+ (<ks-rect>-right recv) (<ks-point>-x p)) (+ (<ks-rect>-bottom recv) (<ks-point>-y p))))))

(ks-methods Number
  (abs (if (< recv 0) (- recv) recv))
  (sign (cond ((< recv 0) -1) ((> recv 0) 1) (else 0)))
  (negated (- recv))
  (squared (* recv recv))
  (sqrt ((subr "sqrt" "d>d") (* 1.0 recv)))
  (min (let ((b (car args))) (if (< recv b) recv b)))
  (max (let ((b (car args))) (if (> recv b) recv b)))
  (truncateTo (let ((q (* 1.0 (car args)))) (* (double->long (/ (* 1.0 recv) q)) q)))
  (bitAnd (& (if (double? recv) (double->long recv) recv) (car args)))
  ((printString asString) (ks-to-string recv)))

(ks-methods String
  (concat (concat-strings (ks-to-string recv) (ks-to-string (car args))))
  (size (string-length (ks-to-string recv)))
  (last (let* ((s (ks-to-string recv)) (n (car args)) (l (string-length s))) (if (<= l n) s (string-copy s (- l n) n))))
  (asNumber (ks-parse-num (ks-to-string recv)))
  ((asString printString) (ks-to-string recv))
  (findTokens (ks-split (ks-to-string recv) (string-at (ks-to-string (car args)) 0)))
  (match (ks-bool (ks-match (ks-to-string recv) 0 (ks-to-string (car args)) 0)))	; Squeak's match:, * any run, # any one
  (asBoolean (ks-bool (ks-truthy? recv))))

(ks-methods Array			; KScript's lists, Smalltalk's Arrays: Maru arrays
  (first (array-at recv 0))
  (second (array-at recv 1))
  (size (array-length recv))
  (isEmpty (ks-bool (= 0 (array-length recv))))
  (copy (list->array (array->list recv)))
  (findFirst (let ((pred (car args)) (found 0))
	       (for (i 0 (array-length recv))
		 (and (= found 0) (ks-truthy? (ks-apply pred (list (array-at recv i)) env this)) (set found (+ i 1))))
	       found))
  (sort (list->array (ks-sort (array->list recv) (lambda (a b) (ks-truthy? (if args (ks-apply (car args) (list a b) env this) (ks-cmp '<= a b))))))))

(ks-methods List
  (first (car recv))
  (second (cadr recv))
  (size (list-length recv))
  (copy (map (lambda (x) x) recv))
  (findFirst (let ((pred (car args)) (idx 0) (found 0) (cur recv))
	       (while (and cur (= found 0))
		 (incr idx)
		 (and (ks-truthy? (ks-apply pred (list (car cur)) env this)) (set found idx))
		 (set cur (cdr cur)))
	       found))
  (sort (ks-sort recv (lambda (a b) (ks-truthy? (if args (ks-apply (car args) (list a b) env this) (ks-cmp '<= a b)))))))

;; Maru's t and (): true, and false and nil as one value
(ks-methods UndefinedObject (asBoolean ()) ((asString printString) "nil"))

(ks-define-class 'Color () ())	; Color, the class, a global
(ks-class-methods Color
  (white (ks-color 1.0 1.0 1.0 1.0))
  (black (ks-color 0.0 0.0 0.0 1.0))
  (yellow (ks-color 1.0 1.0 0.0 1.0))
  (blue (ks-color 0.0 0.0 1.0 1.0))
  ((red _red) (ks-color 1.0 0.0 0.0 1.0))
  (transparent (ks-color 0.0 0.0 0.0 0.0))
  (gray (let ((g (or (car args) 0.5))) (ks-color g g g 1.0))))

(ks-methods Color
  (lighter (ks-color (min 1.0 (+ (<ks-color>-r recv) 0.15)) (min 1.0 (+ (<ks-color>-g recv) 0.15))
		     (min 1.0 (+ (<ks-color>-b recv) 0.15)) (<ks-color>-a recv)))
  (_mixed_with (let ((w (* 1.0 (car args))) (c2 (cadr args)))
		 (if (ks-color? c2)
		     (ks-color (+ (* w (<ks-color>-r recv)) (* (- 1.0 w) (<ks-color>-r c2)))
			       (+ (* w (<ks-color>-g recv)) (* (- 1.0 w) (<ks-color>-g c2)))
			       (+ (* w (<ks-color>-b recv)) (* (- 1.0 w) (<ks-color>-b c2)))
			       (<ks-color>-a recv))
		   recv)))
  (asGeziraFill recv))

;; a stream fires when it takes a defined value: it holds the value, and what depends on it is due this tick;
;; undefined stops the change, so the stream keeps its value and doesn't fire
(define-function ks-fire (s val)
  (when (ks-defined? val)
    (ks-set-slot s '__currentValue__ val)
    (ks-set-slot s '__firedAt__ *ks-logical-time*)))

;; the stream combinators: each answers undefined, which stops the change, until its stream has a value
(ks-methods KSEventStream
  (set (ks-fire recv (car args)) (car args))	; as KSNewEventStream>>set: stamps its last time
  (currentValue (ks-stream-curr recv))
  (dormant (ks-set-attr recv ':__dormant__ (if (ks-truthy? (car args)) "true" "false"))
	   (car args))
  (asBoolean (let ((val (ks-stream-curr recv))) (if (ks-defined? val) (ks-bool (ks-truthy? val)) 'undefined)))
  (delayE (ks-stream-curr recv))
  (mapE (let ((val (ks-stream-curr recv))) (if (ks-defined? val) (ks-apply (car args) (list val) env this) 'undefined)))
  (doE (let ((val (ks-stream-curr recv))) (if (ks-defined? val) (ks-apply (car args) () env this) 'undefined)))
  (collectE (let ((val (ks-stream-curr recv)))
	      (if (ks-defined? val)
		  (let* ((acc (ks-slot-entry recv '__collectAcc__))	; a false accumulator is carried on
			 (old (if acc (cdr acc) (car args)))
			 (res (ks-apply (cadr args) (list val old) env this)))
		    (and (ks-defined? res) (ks-set-slot recv '__collectAcc__ res))
		    res)
		'undefined))))

(define-function ks-looks (recv fill border) (list (cons 'fill fill) (cons 'borderFill border)))
(ks-methods KSObject
  (asBoolean (ks-bool (ks-truthy? recv)))
  (key (ks-val recv 'key))
  (value (ks-val recv 'value))
  (first (car (ks-items recv)))
  (size (list-length (ks-items recv)))
  (copy recv)
  (width (<ks-point>-x (or (ks-val recv 'extent) (ks-point 0 0))))
  (height (<ks-point>-y (or (ks-val recv 'extent) (ks-point 0 0))))
  (topLeft (if args (ks-box-set-topleft recv (car args)) (ks-send (ks-box-rect recv) 'topLeft () env this)))
  (center (if args (ks-box-set-center recv (car args)) (ks-send (ks-box-rect recv) 'center () env this)))
  (translateBy (let ((d (car args)) (r (ks-box-rect recv)))
		 (ks-box-set-topleft recv (ks-point (+ (<ks-rect>-left r) (<ks-point>-x d)) (+ (<ks-rect>-top r) (<ks-point>-y d))))))
  ((localPointFor globalPointFor pointInContainer) (or (car args) (ks-point 0 0)))
  (topContainer (let ((cur recv))
		  (while (ks-object? (ks-val cur 'container)) (set cur (ks-val cur 'container)))
		  cur))
  (defaultLooks (ks-looks recv (ks-val recv 'defaultFill) (ks-val recv 'defaultBorderFill)))
  (enteredLooks (ks-looks recv (or (ks-val recv 'enteredFill) (ks-val recv 'defaultFill)) (ks-val recv 'enteredBorderFill)))
  (pressedLooks (ks-looks recv (or (ks-val recv 'pressedFill) (ks-color 1.0 0.0 0.0 1.0)) (ks-val recv 'pressedBorderFill)))
  (selectedLooks (ks-looks recv (or (ks-val recv 'selectedFill) (ks-color 0.7 0.7 0.7 1.0)) (ks-val recv 'selectedBorderFill)))
  (unselectedLooks (ks-looks recv (ks-val recv 'defaultFill) (ks-val recv 'defaultBorderFill))))

(define-function ks-field (obj field lag?)
  (cond ((= obj 'undefined) 'undefined)
	((ks-object? obj)
	 (let ((s (ks-slot obj field)))
	   (cond ((ks-stream? s) (if lag? (ks-stream-prev s) (ks-stream-curr s)))
		 (s s)
		 ((= field 'contents) (ks-items (ks-val obj 'contents)))
		 (else ()))))
	((pair? obj)
	 (let ((p (assq field obj)))
	   (if p (cdr p) ())))
	(else (ks-send obj field () () ()))))	; a value's field is a message with no arguments, answered or an error

(define-function ks-elements (v)	; what a for, a comprehension or anyE walks: an array's, a list's or a box's elements
  (cond ((array? v) (array->list v)) ((ks-object? v) (ks-items v)) ((pair? v) v) (else ())))
(define-function ks-index (obj idx)
  (cond ((and (array? obj) (number? idx))	; counting from 0
	 (let ((k (if (double? idx) (double->long idx) idx)))
	   (if (and (<= 0 k) (< k (array-length obj))) (array-at obj k) ())))
	((and (pair? obj) (number? idx))
	 (let ((cur obj) (k (if (double? idx) (double->long idx) idx)))
	   (while (and cur (< 0 k)) (set cur (cdr cur)) (decr k))
	   (if cur (car cur) ())))
	((ks-object? obj)
	 (let ((key (if (symbol? idx) idx (string->symbol (ks-to-string idx)))))
	   (ks-val obj key)))
	(else ())))

(define-function ks-apply (fn args env caller-this)
  (cond ((ks-closure? fn)
	 (let ((new-env (<ks-closure>-env fn))
	       (ps (<ks-closure>-params fn))
	       (as args))
	   (while ps
	     (push new-env (cons (car ps) (if as (car as) ())))
	     (set ps (cdr ps))
	     (set as (cdr as)))
	   (let ((res ()) (stmts (<ks-closure>-body fn)))
	     (while (and stmts (not (ks-return? res)))
	       (set res (ks-eval (car stmts) new-env (<ks-closure>-this fn)))
	       (set stmts (cdr stmts)))
	     (if (ks-return? res) (<ks-return>-value res) res))))
	((and (ks-object? fn) (ks-instance? fn 'KSClosure))
	 (let ((cached (ks-attr fn ':__compiled__))
	       (clos-this (or (ks-slot fn 'this) caller-this)))
	   (or cached
	       (let* ((src (ks-attr fn ':source))
		      (ast (car (kscript-parse src))))
		 (set cached (new <ks-closure> (cadr ast) (cddr ast) () clos-this))
		 (ks-set-attr fn ':__compiled__ cached)))
	   (ks-apply cached args env clos-this)))
	(else ())))

;;; ---------------------------------------------------------------- evaluator

(define-function ks-range (a b step)
  (let ((na (ks-num a)) (nb (ks-num b))
	(st (if step (ks-num step) (if (<= (ks-num a) (ks-num b)) 1 -1)))
	(out ()))
    (if (< 0 st)
	(while (<= na nb) (push out na) (set na (+ na st)))
      (while (>= na nb) (push out na) (set na (+ na st))))
    (list->array (list-reverse! out))))

(define-function ks-eval (exp env this)
  (cond
    ((or (long? exp) (double? exp) (string? exp)) exp)
    ((symbol? exp) (ks-env-lookup env this exp ()))
    ((not (pair? exp)) exp)
    (else
     (let ((op (car exp)))
       (cond
	 ((= op 'stream-ref)
	  (let ((name (cadr exp)))
	    (if (ks-object? this)
		(let ((s (ks-slot this name)))
		  (if s s (ks-env-lookup env this name ())))
	      (ks-env-lookup env this name ()))))
	 ((= op 'lag)
	  (let ((inner (cadr exp)))
	    (cond ((symbol? inner) (ks-env-lookup env this inner 1))
		  ((and (pair? inner) (= (car inner) 'stream-ref))
		   (ks-env-lookup env this (cadr inner) 1))
		  ((and (pair? inner) (= (car inner) 'field))
		   (ks-field (ks-stream-curr (ks-eval (cadr inner) env this)) (caddr inner) 1))
		  (else (ks-stream-prev (ks-eval inner env this))))))
	 ((= op 'global) (cadr exp))
	 ((= op 'list)
	  (list->array (map (lambda (e) (ks-stream-curr (ks-eval e env this))) (cdr exp))))
	 ((= op 'dict)
	  (map (lambda (p) (cons (car p) (ks-stream-curr (ks-eval (cadr p) env this)))) (cdr exp)))
	 ((= op 'range)
	  (ks-range (ks-stream-curr (ks-eval (cadr exp) env this))
		    (ks-stream-curr (ks-eval (caddr exp) env this)) ()))
	 ((= op 'fn)
	  (new <ks-closure> (cadr exp) (cddr exp) env this))
	 ((= op 'field)
	  (let ((recv (ks-eval (cadr exp) env this))
		(fname (caddr exp)))
	    (if (ks-stream? recv)
		(let ((cur (ks-stream-curr recv)))
		  (if (ks-object? cur)
		      (or (ks-slot cur fname) (ks-field cur fname ()))
		    (ks-field cur fname ())))
	      (if (ks-object? recv)
		  (or (ks-slot recv fname) (ks-field recv fname ()))
		(ks-field recv fname ())))))
	 ((= op 'index)
	  (ks-index (ks-stream-curr (ks-eval (cadr exp) env this))
		    (ks-stream-curr (ks-eval (caddr exp) env this))))
	 ((and (= op 'send) (= 'super (cadr exp)))	; Smalltalk's super: the method's class's superclass up
	  (let* ((sel (caddr exp)) (args (map (lambda (a) (ks-stream-curr (ks-eval a env this))) (cdddr exp)))
		 (from (ks-superclass (ks-env-lookup env this '%class ()))) (m (ks-method-for from sel)))
	    (if m (m this args env this) (ks-no-method this sel))))
	 ((= op 'send)
	  (let ((recv (ks-eval (cadr exp) env this))
		(sel (caddr exp))
		(args (map (lambda (a) (ks-stream-curr (ks-eval a env this))) (cdddr exp))))
	    (ks-send recv sel args env this)))
	 ((= op 'cascade)	; each message to the one receiver; the last one's answer
	  (let ((recv (ks-eval (cadr exp) env this)) (res ()))
	    (list-do m (cddr exp)
	      (set res (ks-send recv (car m) (map (lambda (a) (ks-stream-curr (ks-eval a env this))) (cdr m)) env this)))
	    res))
	 ((= op 'method-return)	; Smalltalk's ^, from a block too: to the tag of the method it's in
	  ((eval 'throw) (ks-env-lookup env this '%method ()) (ks-stream-curr (ks-eval (cadr exp) env this))))	; catch.l's, loaded with the sources
	 ((= op 'assign-add) (ks-eval `(assign ,(cadr exp) (+ ,(cadr exp) ,(caddr exp))) env this))	; x += e
	 ((= op 'assign-sub) (ks-eval `(assign ,(cadr exp) (- ,(cadr exp) ,(caddr exp))) env this))	; x -= e
	 ((or (= op '&) (= op '^) (= op '<<) (= op '>>) (= op (string->symbol "|")))	; cexpr.g's bitwise operators and shifts
	  (let ((a (ks-stream-curr (ks-eval (cadr exp) env this))) (b (ks-stream-curr (ks-eval (caddr exp) env this))))
	    (cond ((= op '&) (& a b)) ((= op '^) (^ a b)) ((= op '<<) (<< a b)) ((= op '>>) (>> a b)) (else (ks-bit-or a b)))))
	 ((= op '~) (^ (ks-stream-curr (ks-eval (cadr exp) env this)) -1))
	 ((= op 'stream-expr)	; a stream of an expression, as <- makes one (KSWorld's own construction is the plan's step 3d)
	  (let ((ns (ks-make-stream this "exprE" "" (ks-stream-curr (ks-eval (cadr exp) env this)))))
	    (ks-set-attr ns ':__ast__ (cadr exp))
	    ns))
	 ((= op 'char) (cadr exp))
	 ((= op 'symbol) (cadr exp))	; #'name', a Smalltalk Symbol: Maru's symbol, text as KScript's are
	 ((= op 'classvar) (let ((p (ks-assoc (cdr exp) *ks-classvars*))) (if p (cdr p) ())))	; Smalltalk's class variables
	 ((= op 'call)
	  (let ((fn (cadr exp))
		(raw-args (cddr exp)))
	    (cond
	      ((= fn 'P)
	       (ks-point (ks-stream-curr (ks-eval (car raw-args) env this))
			 (ks-stream-curr (ks-eval (cadr raw-args) env this))))
	      ((= fn 'M)
	       (let (( vs (map (lambda (a) (ks-stream-curr (ks-eval a env this))) raw-args)))
		 (ks-matrix-rows (car vs) (cadr vs) (caddr vs) (cadddr vs) (car (cddddr vs)) (cadr (cddddr vs)))))
	      ((= fn 'mergeE)
	       (let ((res 'undefined) (as raw-args))
		 (while (and as (= res 'undefined))
		   (let ((v (ks-stream-curr (ks-eval (car as) env this))))
		     (when (and (ks-defined? v) (ks-event? (car as) v this)) (set res v)))
		   (set as (cdr as)))
		 res))
	      ((or (= fn 'anyE) (= fn 'switchColE))
	       (let* ((col (ks-stream-curr (ks-eval (car raw-args) env this)))
		      (items (ks-elements col))
		      (sname (string->symbol (ks-to-string (ks-stream-curr (ks-eval (cadr raw-args) env this)))))
		      (res 'undefined))
		 ;; the first item whose stream fired this tick, as KSWorld's switchColE takes the first updated since it last
		 ;; looked; a box without the stream, or whose stream holds an older value, is passed
		 (while (and (pair? items) (= res 'undefined))
		   (let* ((p (ks-slot-entry (car items) sname))
			  (s (and p (cdr p))))
		     (when (and (ks-stream? s) (ks-fired? s)) (set res (ks-stream-curr s))))
		   (set items (cdr items)))
		 res))
	      ((= fn 'timerE)	; fires when a multiple of its step was reached since the last evaluation
	       (let ((step (ks-num (ks-stream-curr (ks-eval (car raw-args) env this)))))
		 (if (or (<= step 0) (> (ks-floor-div *ks-logical-time* step) (ks-floor-div (ks-time-before) step)))
		     *ks-logical-time*
		   'undefined)))
	      ((or (= fn 'streamOf) (= fn 'streamof))
	       (ks-stream-curr (ks-eval (car raw-args) env this)))
	      ((= fn 'eventStream) 'undefined)
	      (else
	       (let ((fval (ks-stream-curr (ks-eval fn env this)))
		     (aval (map (lambda (a) (ks-stream-curr (ks-eval a env this))) raw-args)))
		 (ks-apply fval aval env this))))))
	 ((= op 'not)
	  (ks-not (ks-stream-curr (ks-eval (cadr exp) env this))))
	 ((= op '-)
	  (if (cddr exp)
	      (ks-arith '- (ks-stream-curr (ks-eval (cadr exp) env this))
			   (ks-stream-curr (ks-eval (caddr exp) env this)))
	    (let ((v (ks-stream-curr (ks-eval (cadr exp) env this))))
	      (if (= v 'undefined) 'undefined (- (ks-num v))))))
	 ((or (= op '+) (= op '*) (= op '/) (= op '%))
	  (ks-arith op (ks-stream-curr (ks-eval (cadr exp) env this))
		       (ks-stream-curr (ks-eval (caddr exp) env this))))
	 ((or (= op '<) (= op '<=) (= op '>) (= op '>=))
	  (ks-cmp op (ks-stream-curr (ks-eval (cadr exp) env this))
		     (ks-stream-curr (ks-eval (caddr exp) env this))))
	 ((= op '=)
	  (let ((a (ks-stream-curr (ks-eval (cadr exp) env this)))
		(b (ks-stream-curr (ks-eval (caddr exp) env this))))
	    (if (or (= a 'undefined) (= b 'undefined))
		'undefined
	      (ks-bool (equal a b)))))
	 ((= op '!=)
	  (let ((a (ks-stream-curr (ks-eval (cadr exp) env this)))
		(b (ks-stream-curr (ks-eval (caddr exp) env this))))
	    (if (or (= a 'undefined) (= b 'undefined))
		'undefined
	      (ks-bool (not (equal a b))))))
	 ((= op 'and)
	  (let ((a (ks-stream-curr (ks-eval (cadr exp) env this))))
	    (if (ks-truthy? a)
		(ks-stream-curr (ks-eval (caddr exp) env this))
	      a)))
	 ((= op 'or)
	  (let ((a (ks-stream-curr (ks-eval (cadr exp) env this))))
	    (if (ks-truthy? a)
		a
	      (ks-stream-curr (ks-eval (caddr exp) env this)))))
	 ((= op 'coalesce)
	  (let ((a (ks-stream-curr (ks-eval (cadr exp) env this))))
	    (if (ks-truthy? a)
		a
	      (ks-stream-curr (ks-eval (caddr exp) env this)))))
	 ((= op 'if)
	  (let ((c (ks-stream-curr (ks-eval (cadr exp) env this))))
	    (if (ks-truthy? c)
		(ks-eval (caddr exp) env this)
	      (if (cadddr exp)
		  (ks-eval (cadddr exp) env this)
		()))))
	 ((= op 'when-stream)
	  (let ((tval (ks-stream-curr (ks-eval (cadr exp) env this)))
		(vname (caddr exp))
		(body (cadddr exp)))
	    (if (ks-event? (cadr exp) tval this)
		(let ((sub-env (if vname (cons (cons vname tval) env) env)))
		  (ks-eval body sub-env this))
	      'undefined)))
	 ((= op 'fby)
	  (let ((init-exp (cadr exp))
		(next-exp (caddr exp))
		(on-exp (cadddr exp)))
	    (if (= *ks-logical-time* 0)
		(ks-stream-curr (ks-eval init-exp env this))
	      (if (and on-exp (not (ks-defined? (ks-stream-curr (ks-eval on-exp env this)))))
		  'undefined
		(ks-stream-curr (ks-eval next-exp env this))))))
	 ((= op 'list-comp)
	  (let* ((body-exp (cadr exp))
		 (vname (caddr exp))
		 (col-val (ks-stream-curr (ks-eval (cadddr exp) env this)))
		 (items (ks-elements col-val))
		 (cond-exp (car (cddddr exp)))
		 (out ()))
	    (when (pair? items)
	      (list-do it items
		(let ((sub-env (cons (cons vname it) env)))
		  (when (or (not cond-exp) (ks-truthy? (ks-stream-curr (ks-eval cond-exp sub-env this))))
		    (push out (ks-stream-curr (ks-eval body-exp sub-env this)))))))
	    (list->array (list-reverse! out))))
	 ((= op 'detect-comp)
	  (let* ((vname (cadr exp))
		 (col-val (ks-stream-curr (ks-eval (caddr exp) env this)))
		 (items (ks-elements col-val))
		 (cond-exp (cadddr exp))
		 (found ()) (done ()))
	    (while (and (pair? items) (not done))
	      (let* ((it (car items))
		     (sub-env (cons (cons vname it) env)))
		(when (or (not cond-exp) (ks-truthy? (ks-stream-curr (ks-eval cond-exp sub-env this))))
		  (set found it) (set done 1)))
	      (set items (cdr items)))
	    found))
	 ((= op 'begin)
	  (let ((res ()) (stmts (cdr exp)))
	    (while (and stmts (not (ks-return? res)))
	      (set res (ks-eval (car stmts) env this))
	      (set stmts (cdr stmts)))
	    res))
	 ((= op 'var)
	  (let* ((vname (cadr exp))
		 (val (if (caddr exp) (ks-stream-curr (ks-eval (caddr exp) env this)) ())))
	    (when (pair? env)
	      (set-cdr env (cons (car env) (cdr env)))
	      (set-car env (cons vname val)))
	    val))
	 ((and (= op 'assign) (pair? (caddr exp)) (= 'stream-expr (car (caddr exp))) (pair? (cadr exp)) (= 'field (car (cadr exp))))
	  ;; this.x = a stream expression: the slot holds the stream itself, not its value
	  (let ((target (ks-stream-curr (ks-eval (cadr (cadr exp)) env this))) (s (ks-eval (caddr exp) env this)))
	    (ks-set-slot target (caddr (cadr exp)) s)
	    s))
	 ((= op 'assign)
	  (let ((lhs (cadr exp))
		(val (ks-stream-curr (ks-eval (caddr exp) env this))))
	    (cond ((symbol? lhs) (ks-env-set! env this lhs val))
		  ((and (pair? lhs) (= (car lhs) 'classvar))
		   (let ((p (ks-assoc (cdr lhs) *ks-classvars*))) (if p (set-cdr p val) (push *ks-classvars* (cons (cdr lhs) val)))))
		  ((and (pair? lhs) (= (car lhs) 'field))
		   (let ((target (ks-stream-curr (ks-eval (cadr lhs) env this))))
		     (ks-set-val target (caddr lhs) val)))
		  ((and (pair? lhs) (= (car lhs) 'index))
		   (let ((target (ks-stream-curr (ks-eval (cadr lhs) env this)))
			 (idx (ks-stream-curr (ks-eval (caddr lhs) env this))))
		     (if (array? target)	; an element, counted from 0, inside the array or an error
			 (let ((k (if (double? idx) (double->long idx) idx)))
			   (if (and (long? k) (<= 0 k) (< k (array-length target))) (set-array-at target k val)
			     (error "KScript: index " idx " out of bounds for an array of " (array-length target))))
		       (ks-set-val target (string->symbol (ks-to-string idx)) val)))))
	    val))
	 ((= op 'assign-or)
	  (let ((cur (ks-stream-curr (ks-eval (cadr exp) env this))))
	    (if (ks-truthy? cur)
		cur
	      (ks-eval (list 'assign (cadr exp) (caddr exp)) env this))))
	 ((= op 'stream-def)
	  (let* ((lhs (cadr exp))
		 (name (if (symbol? lhs) lhs (caddr lhs)))
		 (rhs (caddr exp))
		 (val (ks-stream-curr (ks-eval rhs env this))))
	    (when (ks-object? this)
	      (let ((s (ks-slot this name)))
		(if (ks-stream? s)
		    (let ()
		      (ks-set-attr s ':__ast__ rhs)
		      (when (ks-defined? val) (ks-set-slot s '__currentValue__ val)))
		  (let ((ns (ks-make-stream this "exprE" "" val)))
		    (ks-set-attr ns ':__ast__ rhs)
		    (ks-set-slot this name ns)))))
	    val))
	 ((= op 'for-in)
	  (let* ((vname (cadr exp))
		 (col-val (ks-stream-curr (ks-eval (caddr exp) env this)))
		 (step-val (and (cadddr exp) (ks-stream-curr (ks-eval (cadddr exp) env this))))
		 (items (ks-elements
			 (if (and step-val (pair? (caddr exp)) (= (caaddr exp) 'range))
			     (ks-range (ks-stream-curr (ks-eval (cadr (caddr exp)) env this))
				       (ks-stream-curr (ks-eval (caddr (caddr exp)) env this))
				       step-val)
			   col-val)))
		 (body (car (cddddr exp)))
		 (res ()))
	    (when (pair? items)
	      (list-do it items
		(let ((sub-env (cons (cons vname it) env)))
		  (set res (ks-eval body sub-env this)))))
	    res))
	 ((= op 'delete)
	  (let ((target (cadr exp)))
	    (when (and (pair? target) (= (car target) 'field))
	      (let ((obj (ks-stream-curr (ks-eval (cadr target) env this))))
		(and (ks-object? obj) (ks-set-val obj (caddr target) ()))))
	    ()))
	 ((= op 'return)
	  (new <ks-return> (ks-stream-curr (ks-eval (cadr exp) env this))))
	 (else (error "KScript: no form " op " (" exp ")")))))))	; never a quiet nil

;;; ---------------------------------------------------------------- Evaluator (Figure 2, TR-2012-001)

(define-structure <ks-evaluator> (streams previous))	; previous: the time it last evaluated at

(define-function ks-evaluator-new ()
  (new <ks-evaluator> () -1))

;; a stream's code, read once; one whose code didn't read (a driver marks it :__unreadable__) has none, as a setter has
;; none, so the sort reaching it as another's dependency neither reads it again nor evaluates it
(define-function ks-stream-ast (s)
  (or (ks-attr s ':__ast__)
      (let ((code (ks-attr s ':__code__))
	    (type (ks-attr s ':__type__)))
	(when (and code (not (= type "setter")) (not (ks-attr s ':__unreadable__)))
	  (let ((ast (car (kscript-parse code))))
	    (ks-set-attr s ':__ast__ ast)
	    ast)))))

;; Collect synchronous stream dependencies of AST; lag (') and delayE break cycles (section 3.2).
(define-function ks-collect-deps (ast home acc triggers?)
  (cond
    ((symbol? ast)
     (when (ks-object? home)
       (let ((s (ks-slot home ast)))
	 (and (ks-stream? s) (not (memq s (car acc))) (set-car acc (cons s (car acc)))))))
    ((pair? ast)
     (let ((op (car ast)))
       (cond
	 ((= op 'lag) ())
	 ((and (= op 'send) (= (caddr ast) 'delayE)) ())
	 ((= op 'stream-ref)
	  (when (ks-object? home)
	    (let ((s (ks-slot home (cadr ast))))
	      (and (ks-stream? s) (not (memq s (car acc))) (set-car acc (cons s (car acc)))))))
	 ((= op 'field)
	  (let ((recv (cadr ast)) (fname (caddr ast)))
	    (ks-collect-deps recv home acc triggers?)
	    (when (and (ks-object? home)
		       (or (symbol? recv) (and (pair? recv) (= (car recv) 'stream-ref))))
	      (let* ((rname (if (symbol? recv) recv (cadr recv)))
		     (robj (ks-val home rname)))
		(when (ks-object? robj)
		  (let ((fs (ks-slot robj fname)))
		    (and (ks-stream? fs) (not (memq fs (car acc))) (set-car acc (cons fs (car acc))))))))))
	 ((and (= op 'call) (or (= (cadr ast) 'anyE) (= (cadr ast) 'switchColE)))
	  (let ((col-exp (caddr ast)) (sname-exp (cadddr ast)))
	    (ks-collect-deps col-exp home acc triggers?)
	    (when (and (ks-object? home) (string? sname-exp))
	      (let* ((sname (string->symbol sname-exp))
		     (col (ks-val home (if (symbol? col-exp) col-exp (cadr col-exp))))
		     (items (ks-elements col)))
		(when (pair? items)
		  (list-do it items
		    (let ((s (ks-slot it sname)))
		      (and (ks-stream? s) (not (memq s (car acc))) (set-car acc (cons s (car acc)))))))))))
	 ((= op 'fn) ())
	 ;; when-then recomputes on its trigger alone; its body only orders the sort
	 ((and triggers? (= op 'when-stream)) (ks-collect-deps (cadr ast) home acc triggers?))
	 (else (list-do sub (cdr ast) (ks-collect-deps sub home acc triggers?))))))))

(define-function ks-stream-deps (ast home triggers?)
  (let ((acc (list ())))
    (ks-collect-deps ast home acc triggers?)
    (car acc)))

;; a stream fired if it took a defined value this tick; undefined signals no change
(define-function ks-fired? (s)
  (= (ks-slot s '__firedAt__) *ks-logical-time*))

(define-function ks-any-fired? (streams)
  (let ((fired ()))
    (list-do s streams (and (ks-fired? s) (set fired 1)))
    fired))

;; timerE is the one source this evaluator has: it updates with no stream behind it
(define-function ks-source? (ast)
  (and (pair? ast)
       (or (and (= (car ast) 'call) (= (cadr ast) 'timerE))
	   (let ((found ()))
	     (list-do sub ast (and (ks-source? sub) (set found 1)))
	     found))))

;; a primed name isn't a dependency, so nat <- 0 fby nat' + 1 never updates
(define-function ks-due? (ast home)
  (or (= *ks-logical-time* 0)
      (ks-source? ast)
      (ks-any-fired? (ks-stream-deps ast home 1))))

(define-function ks-evaluator-add-from (ev obj)
  (ks-slots-do obj (lambda (name v)
      (when (and (ks-stream? v)
		 (not (= (ks-attr v ':__type__) "setter"))
		 (not (= (ks-attr v ':__dormant__) "true"))
		 (not (memq v (<ks-evaluator>-streams ev))))
	(set (<ks-evaluator>-streams ev) (cons v (<ks-evaluator>-streams ev)))))))

(define-function ks-visit-stream (s visited visiting sorted)
  (when (and (not (memq s (car visited))) (not (memq s (car visiting))))
    (set-car visiting (cons s (car visiting)))
    (let ((ast (ks-stream-ast s)))
      (and ast
	   (list-do d (ks-stream-deps ast (ks-attr s ':__home__) ())
	     (ks-visit-stream d visited visiting sorted))))
    (set-car visited (cons s (car visited)))
    (set-car sorted (cons s (car sorted)))))

(define-function ks-topologically-sorted-streams (ev)
  (let ((visited (list ()))
	(visiting (list ()))
	(sorted (list ())))
    (list-do s (<ks-evaluator>-streams ev)
      (ks-visit-stream s visited visiting sorted))
    (list-reverse! (car sorted))))

;; one stream's new value, if it has one this tick; a driver may wrap this to see what each stream does (ksworld-run.l)
(define ks-evaluate-stream
  (lambda (s ast home)
    (ks-fire s (ks-stream-curr (ks-eval ast (list (cons '__this__ home)) home)))))

(define-function ks-sort-and-evaluate-at (ev logical-time)
  (or (> logical-time (<ks-evaluator>-previous ev))	; a stream fired if it fired at this time, so a time can't recur
      (error "KScript: time " logical-time " isn't after " (<ks-evaluator>-previous ev) ", the last evaluated"))
  (set *ks-logical-time* logical-time)
  (set *ks-previous-time* (<ks-evaluator>-previous ev))
  (let ((sorted (ks-topologically-sorted-streams ev)))
    ;; Snapshot previous values for lagged references (') at this logical tick
    (list-do s sorted
      (ks-set-slot s '__prevValue__ (ks-stream-value s)))	; a stream with no value keeps undefined
    ;; Evaluate each stream in topological order
    (list-do s sorted
      (let ((ast (ks-stream-ast s))
	    (home (ks-attr s ':__home__)))
	(and ast (ks-due? ast home) (ks-evaluate-stream s ast home))))
    (set (<ks-evaluator>-previous ev) logical-time)
    sorted))
