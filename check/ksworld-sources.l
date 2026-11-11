;;; KSWorld's own methods from its sources (ksworld-source.l): a class's file-out (ksworld/CLASS.st, Squeak's chunk format,
;;; read by st-fileout.g) gives each method's category and source; a KScript one is read by kscript.g, and becomes a method
;;; of its class, answering the sends a document makes of its instances.  KSTextLayout's 74 methods are 73 KScript and 1
;;; Smalltalk, as ksworld/INDEX.txt counts them.
(require "ksworld-source.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (print "FAIL " what ": got ") (dump got) (print ", want ") (dump want) (println))))

(let* ((ms (ks-source-methods "ksworld/KSTextLayout.st"))
       (kscript (let ((n 0)) (list-do m ms (and (<ks-source-method>-kscript? m) (set n (+ n 1)))) n))
       (unread (let ((out ())) (list-do m ms (and (<ks-source-method>-kscript? m) (not (<ks-source-method>-tree m))
						 (push out (<ks-source-method>-selector m))))
		     out)))
  (expect "every method of the file-out" (list-length ms) 74)
  (expect "KScript ones as INDEX.txt counts them" kscript 73)
  (expect "every KScript method read" unread ())
  (let ((do08 (let ((f ())) (list-do m ms (and (= 'do08 (<ks-source-method>-selector m)) (set f m))) f)))
    (expect "a method's class and category" (list (<ks-source-method>-class do08) (<ks-source-method>-category do08))
	    '(KSTextLayout "key commands"))
    (expect "its parameters and body as kscript.g reads them" (<ks-source-method>-tree do08)
	    '(fn () (send this textAction "delete"))))
  ;; the three constructs the methods use that the documents' streams don't
  (expect "+= and -=" (kscript-parse "this.n += 1\nthis.n -= 2") '((assign-add (field this n) 1) (assign-sub (field this n) 2)))
  (expect "a symbol literal" (kscript-parse "x = #'wordWidth'") '((assign x (symbol wordWidth))))
  ;; KSParser's symbol is $# string, so either quote: lettersBubble.ks's textSelection.mapE asks respondsTo(#"firstInSelection")
  (expect "a symbol literal in double quotes" (kscript-parse "x = #\"firstInSelection\"") '((assign x (symbol firstInSelection))))
  (expect "a stream made from an expression" (kscript-parse "x = $$(@s.doE(() -> 1))")
	  '((assign x (stream-expr (send (stream-ref s) doE (fn () 1)))))))

;; a class's KScript methods answer its instances' sends
(ks-load-source-class 'KSTextLayout)
(expect "a source method is the class's" (and (ks-method-for 'KSTextLayout 'do08) 1) 1)

;; Smalltalk methods, read by squeak.g to KScript's trees: every one of KSContentsCollection's and KSBox's
(list-do f '("ksworld/KSContentsCollection.st" "ksworld/KSBox.st")
  (let ((unread ()) (n 0))
    (list-do m (ks-source-methods f)
      (unless (<ks-source-method>-kscript? m)
	(set n (+ n 1))
	(or (<ks-source-method>-tree m) (push unread (<ks-source-method>-selector m)))))
    (expect (concat-string "every Smalltalk method read: " f) unread ())))
(let ((ms (ks-source-methods "ksworld/KSContentsCollection.st")))
  (expect "the class definition: its superclass and instance variables" (ks-source-class-of "ksworld/KSContentsCollection.st")
	  '(KSContentsCollection Object (array firstIndex lastIndex indexCache)))
  (let ((tree-of (lambda (sel) (let ((f ())) (list-do m ms (and (= sel (<ks-source-method>-selector m)) (set f (<ks-source-method>-tree m)))) f))))
    (expect "a keyword method and its send, in KScript's naming of Smalltalk's selectors" (tree-of '_add)
	    '(fn (newObject) (method-return (send this _addLast newObject))))
    (expect "an instance variable, a temporary, a block and ^" (tree-of '_after_ifAbsent)
	    '(fn (target exceptionBlock) (var index nil) (assign index (send this _indexOf target))
		 (method-return (send (send (send index = 0) _or (fn () (send index = (send this size)))) _ifTrue_ifFalse
				      (fn () (send exceptionBlock value)) (fn () (send this _at (send index + 1)))))))
    (expect "assigning an instance variable" (tree-of '_addFirst)
	    '(fn (newObject) (send (send (field this firstIndex) = 1) _ifTrue (fn () (send this makeRoomAtFirst)))
		 (assign (field this firstIndex) (send (field this firstIndex) - 1))
		 (send (field this array) _at_put (field this firstIndex) newObject)
		 (method-return newObject)))))

;; running them: a KSContentsCollection made and used from KScript runs its own Smalltalk (new: through super basicNew,
;; setCollection:, addLast:'s makeRoomAtLast, addFirst:, at:'s bounds, removeFirst), on the platform squeak-base.st gives
(ks-load-source-class 'KSContentsCollection)
(define-function listed (v) (if (array? v) (map listed (array->list v)) v))	; an array, and arrays in it, as lists
(define-function run (text)	; a KScript program's statements in one environment; the last one's value, arrays as lists
  (let ((r ()) (env (list (cons '%top 1)))) (list-do s (kscript-parse text) (set r (ks-stream-curr (ks-eval s env ())))) (listed r)))
(expect "a collection from its class, grown and read by its own methods"
	(run "var c = KSContentsCollection.new()\nc._add(1)\nc._add(2)\nc._addFirst(0)\n[c.size(), c._at(1), c._at(3), c.removeFirst(), c.size(), c.first()]")
	'(3 0 2 0 2 1))
(expect "eleven elements in a collection made for ten: makeRoomAtLast grows it"
	(run "var c = KSContentsCollection.new()\nfor i in [1...11]\n\tc._add(i * i)\n[c.size(), c._at(11), c.last()]")
	'(11 121 121))
(expect "add:afterIndex: and removeAt:, as KSWorld's editing uses them"
	(run "var c = KSContentsCollection.new()\nc._add(10)\nc._add(30)\nc._add_afterIndex(20, 1)\nvar a = [c._at(1), c._at(2), c._at(3)]\nc._removeAt(1)\n[a, c.size(), c.first()]")
	'((10 20 30) 2 20))
(expect "an index past the end is Squeak's error, not a quiet nil"
	(try (run "var c = KSContentsCollection.new()\nc._at(1)") (lambda (c) 'refused)) 'refused)
;; a selector nothing answers is doesNotUnderstand: with a Message, as in Smalltalk: KSObject's own (from its source) calls a
;; block kept in the slot of that name, and Object's, at the root, refuses it naming the selector
(ks-load-source-class 'KSObject)
(define o (ks-basic-new (ks-class-named 'KSObject)))
(ks-set-slot o 'twice (ks-eval (car (kscript-parse "(self, n) -> n * 2")) () ()))
(expect "KSObject>>doesNotUnderstand: calls the block in the slot named by the selector" (ks-send o '_twice '(21) () o) 42)
(expect "Object>>doesNotUnderstand: names what was sent"
	(try (ks-send 3 'frobnicate () () ()) (lambda (c) (let ((s "")) (list-do p (cdr c) (set s (concat-string s (if (symbol? p) (symbol->string p) p)))) s)))
	"Smalltalk: Number does not understand frobnicate")
;; Squeak's numbers and binary selectors: a negative radix literal, and a negative literal after a binary operator
(expect "a negative radix literal" (squeak-number "-16rFF") -255)
(expect "a>-1 is a > -1" (cadr (ks-squeak-method "f\n\t^ a>-1" () ())) '(fn () (method-return (send a > -1))))
;; every form the grammar makes evaluates: += and -= on a field and a variable, the bitwise operators and shifts (cexpr.g's),
;; and a stream expression making a stream as <- does
(let ((o (ks-basic-new (ks-class-named 'KSObject))))
  (ks-set-slot o 'n 5)
  (expect "+= and -= on a field" (list (ks-eval (car (kscript-parse "this.n += 3")) () o) (ks-eval (car (kscript-parse "this.n -= 1")) () o) (ks-val o 'n)) '(8 7 7))
  (expect "+= on a variable" (run "var k = 1\nk += 41\nk") 42)
  (expect "bitwise operators and shifts" (list (run "6 & 3") (run "6 | 3") (run "6 ^ 3") (run "1 << 4") (run "32 >> 2") (run "~0")) '(2 7 5 16 8 -1))
  (ks-eval (car (kscript-parse "this.s = $$(2 + 3)")) () o)
  (expect "a stream expression makes a stream" (list (ks-stream? (ks-slot o 's)) (ks-val o 's)) '(t 5)))
(expect "a form the evaluator doesn't know is an error naming it" (try (ks-eval '(no-such-form 1) () ()) (lambda (c) 'refused)) 'refused)

;; Smalltalk's literal and brace arrays are Maru arrays, KScript's too, and an empty one isn't nil
(define-function st (text)	; a Smalltalk expression's value, as a method answering it
  ((ks-method-function 'Object (cadr (ks-squeak-method (concat-string "f\n\t^ " text) () ())) () ()) () () () ()))
(expect "a literal array and a brace array are arrays"
	(list (array? (st "#(1 2 3)")) (array->list (st "#(1 2 3)")) (array->list (st "{1. 1 + 1}"))) '(t (1 2 3) (1 2)))
(expect "an empty array is empty, and not nil"
	(list (ks-truthy? (st "#() isEmpty")) (ks-truthy? (st "#() isNil")) (ks-truthy? (st "nil isNil"))) '(t () t))
(expect "an array's collect:, inject:into: and , answer arrays and values"
	(list (array->list (st "#(1 2 3) collect: [:x | x * x]")) (st "#(1 2 3) inject: 0 into: [:a :x | a + x]") (array->list (st "#(1) , #(2)")))
	'((1 4 9) 6 (1 2)))
(expect "a list joined with an array is one list of both" (ks-send (list 1 2) (string->symbol ",") (list (list->array '(3))) () ()) '(1 2 3))
(expect "KScript and Smalltalk share arrays" (st "#(1 2 3) = {1. 2. 3}") 't)
(expect "a collection made from none is an empty array, never nil, and a list's collect: an array"
	(list (array? (st "#() collect: [:x | x]")) (array? (st "OrderedCollection new asArray")) (array? (st "Set new asArray"))
	      (array->list (ks-send (list 1 2) '_collect (list (ks-eval (car (kscript-parse "(x) -> x * 10")) () ())) () ())))
	'(t t t (10 20)))
;; a global holding nil or false is there, holding it
(set *ks-globals* (cons (cons 'Nothing ()) *ks-globals*))
(expect "a global holding nil is found" (list (st "Smalltalk at: #Nothing") (st "Smalltalk at: #Nothing ifAbsent: [1]") (st "Smalltalk includesKey: #Nothing")) '(() () t))
;; dictionaries and sets keep their keys in hash.l's tables: a Dictionary and a Set by equality (2 and 2.0 one key, two
;; equal strings one member), an IdentityDictionary and an IdentitySet by identity, and a KSWorld object's slots are its own
(define-function st-body (text)	; a Smalltalk method body's answer, with temporaries d and s
  ((ks-method-function 'Object (cadr (ks-squeak-method (concat-string "f\n\t| d s |\n\t" text) () ())) () ()) () () () ()))
(expect "a Dictionary takes 2.0 as 2, an IdentityDictionary doesn't"
	(list (st-body "d := Dictionary new. d at: 2 put: 1. d at: 2.0 put: 2. ^ d at: 2")
	      (st-body "d := IdentityDictionary new. d at: 2 put: 1. d at: 2.0 put: 2. ^ d at: 2"))
	'(2 1))
(expect "a Dictionary finds a key by an equal one, as Squeak's = has it: an array by its elements, a point by x and y"
	(list (st-body "d := Dictionary new. d at: #(1 2) put: 5. ^ d at: #(1 2) ifAbsent: [0]")
	      (st-body "d := Dictionary new. d at: 3 @ 4 put: 6. ^ d at: 3 @ 4 ifAbsent: [0]"))
	'(5 6))
(expect "removeKey:, includesKey: and at:ifAbsent: on a Dictionary"
	(list (st-body "d := Dictionary new. d at: #a put: 1. d removeKey: #a ifAbsent: [0]. ^ d includesKey: #a")
	      (st-body "d := Dictionary new. ^ d at: #b ifAbsent: [7]"))
	'(() 7))
(expect "a Set keeps equal strings once and an IdentitySet each, in the order added"
	(list (st-body "s := Set new. s add: 'ab'. s add: 'ab'. s add: 3. ^ s size")
	      (st-body "s := IdentitySet new. s add: 'ab'. s add: 'ab'. s add: 3. ^ s size")
	      (array->list (st-body "s := Set new. s add: 3. s add: 1. s add: 3. s add: 2. ^ s asArray")))
	'(2 3 (3 1 2)))
(expect "a Set's members reach what takes any collection: addAll:, , and the like"
	(list (st-body "d := OrderedCollection new. s := Set new. s add: 1. s add: 2. d addAll: s. ^ d size")
	      (array->list (st-body "s := Set new. s add: 3. ^ #(1 2) , s")))
	'(2 (1 2 3)))
(expect "a KSWorld object's slots are a table, read and written by KScript and Smalltalk alike"
	(let ((o (ks-basic-new (ks-class-named 'KSObject))))
	  (ks-set-slot o 'colour 'red)
	  (list (hash-table? (ks-table o)) (ks-send o '_at (list 'colour) () o)))
	'(t red))
;; a class is a Maru type (boot.l's define-class) under its superclass's type, and an object's class is its type's: a
;; document's object too, and one made before its class's source still reaches the superclass's methods once the class is
;; defined
(let ((o (ks-new-object 'KSBox 0 () () () 0)))
  (expect "a document's object is an instance of its class's type"
	  (list (array-at %type-names (type-of o)) (ks-object? o) (ks-class-of o)) '(<KSBox> t KSBox)))
(let ((o (ks-new-object 'LateChild 0 () () () 0)))
  (ks-set-slot o 'colour 'blue)
  (ks-define-class 'LateChild 'KSObject ())
  (expect "an object made before its class is defined reaches the superclass's methods" (ks-send o '_at (list 'colour) () o) 'blue))
;; the platform's classes keep what their primitives give them in fields, their instance variables
(let ((f (ks-ttc-font 'TimesNewRoman 12 1)))
  (expect "a TTCFont's description, point size and emphasis are fields, and its description's fonts"
	  (list (array-at %structure-fields (type-of f)) (ks-slot f 'pointSize) (ks-slot f 'emphasis)
		(array-at %structure-fields (type-of (ks-slot f 'description))))
	  '((description pointSize emphasis) 12 1 (fonts))))
(expect "a TTGlyph's font and glyph, a GeziraPath's points, floats and fill"
	(map (lambda (c) (array-at %structure-fields (ks-class-type c))) '(TTGlyph GeziraPath))
	'((font glyph) (points floats myFill)))
(expect "a GeziraPath made and filled in Smalltalk keeps its fill where a document's does, in myFill"
	(ks-slot (st "(GeziraPath path: nil) fill: 3") 'myFill) 3)
(let ((shape (ks-new-object 'KSShape 0 () (list (cons 'elements (array 0))) () 0)))
  (expect "a document's KSShape is KSWorld's, an Object with its instance variables as fields and no dictionary"
	  (list (array-at %structure-fields (type-of shape)) (ks-table shape) (ks-slot shape 'elements))
	  (list '(whole fill extent borderFill borderWidth infinite isRectangle cornerRadius shadowFill shadowOffset shadowBlur
		  elements transform offset drawingBounds hBearing) () (array 0))))
(ks-new-object 'EarlyBird 0 () () () 0)
(expect "a class whose type was made before it, with other instance variables, is refused, not given a second layout"
	(try (ks-define-class 'EarlyBird 'KSObject '(song)) (lambda (c) 'refused)) 'refused)
;; review of classes as types
(let ((shape (ks-new-object 'KSShape 7 '(:foo "x") () () 0)) (o (ks-new-object 'KSObject 8 '(:foo "y") () () 0)))
  (expect "a document's attributes are its dictionary's entries; an object with none keeps none"
	  (list (ks-ref o) (ks-attr o ':foo) (ks-ref shape) (ks-attr shape ':foo)) '(8 "y" 0 ()))
  (expect "setting an attribute on an object with no dictionary is refused, never lost"
	  (list (try (ks-set-attr shape ':__path__ "p") (lambda (c) 'refused)) (try (ks-set-attr (array 1) ':__path__ "p") (lambda (c) 'refused)))
	  '(refused refused)))
(expect "a Maru array has no named slots to set" (try (ks-set-slot (array 1) 'colour 1) (lambda (c) 'refused)) 'refused)
(ks-new-object 'Plain 0 () () () 0)
(expect "a class a document met as a dictionary, redefined as an Object subclass, is refused"
	(try (ks-define-class 'Plain 'Object ()) (lambda (c) 'refused)) 'refused)
(ks-new-object 'Ordered 0 () () () 0)
(expect "and redefined under a superclass with other fields, refused"
	(try (ks-define-class 'Ordered 'OrderedCollection ()) (lambda (c) 'refused)) 'refused)
(ks-new-object 'Reparented 0 () () () 0)
(ks-define-class 'Reparented 'IdentityDictionary ())
(expect "redefined under a superclass with the same fields, it moves under it"
	(array-at %type-names (array-at %structure-bases (ks-class-type 'Reparented))) '<IdentityDictionary>)
(ks-new-object 'Novel 0 () () () 0)
(expect "a class first met in a document has a class object, under KSObject's"
	(list (ks-class-of (ks-class-named 'Novel)) (ks-send (ks-class-named 'Novel) 'name () () ())
	      (ks-send (ks-send (ks-class-named 'Novel) 'superclass () () ()) 'name () () ()))
	(list (ks-meta 'Novel) 'Novel 'KSObject))
(expect "a declared class's class side reaches Object's" (ks-send (ks-class-named 'KSShape) 'name () () ()) 'KSShape)
(ks-instance? 3 'NeverSeen)
(expect "asking whether a value is an instance makes no class" (assq 'NeverSeen *ks-class-types*) ())
(let ((members (ks-new-object 'Set 0 () () '(1 2 1) 0)))
  (expect "a document's Set is a Set: its members once each, which Smalltalk counts and lists"
	  (list (ks-send members 'size () () ()) (ks-items members)) '(2 (1 2))))
(let ((o (ks-new-object 'KSObject 0 () (list (cons 'slots 5)) () 0)))
  (expect "a slot named slots is an entry, never the dictionary's own table"
	  (list (ks-slot o 'slots) (hash-table? (ks-table o)) (ks-send o '_at (list 'slots) () o)) '(5 t 5)))
(ks-define-class 'FieldHolder 'Object '(clock))
(let ((o (ks-new-object 'FieldHolder 0 () () () 0)) (ev (ks-evaluator-new)))
  (ks-set-slot o 'clock (ks-make-stream o "code" "timerE(1)" 0))
  (ks-evaluator-add-from ev o)
  (expect "a stream an instance variable holds is evaluated, as one a dictionary holds is"
	  (list-length (<ks-evaluator>-streams ev)) 1))
;; Smalltalk's true is Maru's t, and false and nil are one value, (), answering as nil does: ifTrue: does nothing, ifFalse: runs
(expect "true is t, false and nil are ()" (list (st "true") (st "false") (st "nil") (st "false == nil") (st "3 > 2")) '(t () () t t))
(expect "false is nil: isNil, ifTrue: and ifFalse:"
	(list (st "false isNil") (st "false ifTrue: [1]") (st "false ifFalse: [2]") (st "true ifTrue: [1] ifFalse: [2]") (st "true & false") (st "false | true"))
	'(t () 2 1 () t))

(println (if ok "ksworld sources ok" "ksworld sources FAILED"))
