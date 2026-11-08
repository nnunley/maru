;;; st-classes.l -- Smalltalk's classes as Maru types, dispatched by Maru selectors on the receiver's type.
;;;
;;; A class is a Maru type (boot.l's define-structure); its superclass is the type's base (%structure-bases), so a send
;;; inherits as any Maru selector does.  There is no root type: Object's methods are what a selector answers when the
;;; receiver's type and its bases have no method.  A class over a Maru value is that value's type (Number over <long>
;;; and <double>, String over <string> and <symbol>, Array over <array> ...); an abstract class is a type with no fields; a
;;; Maru type's base is only ever such a new, fieldless type, never another Maru type, so no selector of Maru's own (input.l's
;;; in-enter, boot.l's equal-hash, length ...) is inherited through one (<symbol> under <string> would make every symbol
;;; enterable as a sequence).  A class's fields are its instance variables, its superclasses' first; a Dictionary's
;;; include slots, the table every KSWorld object (a dictionary, through KSProtoObject) keeps its named values and a
;;; document's attributes in.  A class object is an instance of its metaclass type, under its superclass's metaclass, so
;;; a class-side method is a method of that type.

(require "hash.l")

;; an object's storage: its class's fields (instance variables), and for a Dictionary (every KSWorld object is one, through
;; KSProtoObject) the hash.l table in its slots field.  A named value is the field of that name when the class has one, and
;; otherwise an entry in the table; an attribute a document kept (:ref, :__type__ ...) is an entry keyed by its keyword
(define *ks-storage* (array))	; type -> t for a class type whose instances are objects
(define-function ks-object? (x) (and (array-at *ks-storage* (type-of x)) 't))
(define-function ks-field-index (type name)	; name's offset among type's fields, or ()
  (let ((i 0) (found ()) (fs (array-at %structure-fields type)))
    (while (and fs (not found)) (if (= name (car fs)) (set found i) (set i (+ i 1))) (set fs (cdr fs)))
    (and found i)))
(define-function ks-table (o)	; a Dictionary's table, or ()
  (and (ks-object? o) (let ((i (ks-field-index (type-of o) 'slots))) (and i (oop-at o i)))))

;; a class object: its type is its class's metaclass
(define-structure <ks-class> (name super ivars))
(define *ks-classes* ())	; (name . class object)
(define-function ks-class-named (name) (cdr (assq name *ks-classes*)))
(define-function ks-meta (name) (string->symbol (concat-string (symbol->string name) " class")))
(define-function ks-meta? (name)
  (let* ((s (symbol->string name)) (n (string-length s))) (and (< 6 n) (= " class" (string-copy s (- n 6) 6)))))
(define-function ks-meta-base (name)	; X class's X
  (let ((s (symbol->string name))) (string->symbol (string-copy s 0 (- (string-length s) 6)))))

;; classes over Maru's values, and classes with no instances of their own
(define *ks-sysclasses* '((UndefinedObject <undefined>) (Array <array>) (List <pair>)
			  (BlockClosure <ks-closure>) (Point <ks-point>) (Rectangle <ks-rect>) (Color <ks-color>)
			  (Hand <ks-hand>) (Event <ks-event>)))
(define *ks-abstract* '(Magnitude Number Collection SequenceableCollection ArrayedCollection HashedCollection Boolean True
			False Character))
(define *ks-class-types* ())	; (name . type)
(define *ks-type-classes* (array))	; type -> class name
(define-function ks-type-name (type) (or (array-at *ks-type-classes* type) (array-at %type-names type)))
(define-function ks-class-of (o) (ks-type-name (type-of o)))	; an object's class's name
(define ks-object-type)
(define-function ks-instance? (x class)	; x's class is class, by type; asking makes no class
  (let ((p (assq class *ks-class-types*))) (and p (= (type-of x) (cdr p)))))
(define-function %ks-register (name type) (push *ks-class-types* (cons name type)) (set-array-at *ks-type-classes* type name) type)
(define-function %ks-print-object (o) (print "<" (ks-class-of o) ">"))
(define-function %ks-structure (tname fields)
  (eval (list 'define-structure tname fields))
  (let ((t (eval tname)))
    t))
(define-function %ks-tname (name) (string->symbol (concat-strings "<" (symbol->string name) ">")))
(define ks-meta-type)
(define ks-define-class)
(define-function %ks-over (name types names)	; a fieldless class type with Maru's types under it, each named for messages
  (let ((t (%ks-register name (%ks-structure (%ks-tname name) ()))))
    (list-do m types (set-array-at %structure-bases m t))
    (let ((ns names)) (list-do m types (set-array-at *ks-type-classes* m (car ns)) (set ns (cdr ns))))
    t))
(define-function %ks-class (name base ivars)	; a class type: base's fields, then its own instance variables
  (let ((t (%ks-register name (if base (eval (list 'define-class (%ks-tname name) (array-at %type-names base) ivars))
				(%ks-structure (%ks-tname name) ivars)))))
    (set-array-at *ks-storage* t 't)
    (<selector>-add-method do-print t %ks-print-object)
    t))
(define-function ks-class-type (name)	; the type of the class named name
  (let ((p (assq name *ks-class-types*)))
    (cond (p (cdr p))
	  ((= name 'Object) ())	; no type: Object's methods are every selector's default
	  ((ks-meta? name) (ks-meta-type (ks-meta-base name)))
	  ((assq name *ks-sysclasses*) (%ks-register name (eval (cadr (assq name *ks-sysclasses*)))))
	  ((= name 'Number) (%ks-over name (list <long> <double>) '(Number Number)))	; numbers of both kinds
	  ((= name 'String) (%ks-over name (list <string> <symbol>) '(String Symbol)))	; text, and symbols (t among them)
	  ((member? name *ks-abstract*) (%ks-register name (%ks-structure (%ks-tname name) ())))
	  ;; first met in a document: a KSWorld object, a dictionary, with a class object
	  (else (ks-define-class name 'KSObject ()) (cdr (assq name *ks-class-types*))))))
(set ks-object-type ks-class-type)
(set ks-meta-type
     (lambda (name)	; X class: under X's superclass's metaclass, or <ks-class> for a class with none
       (let ((m (ks-meta name)))
	 (or (cdr (assq m *ks-class-types*))
	     (let ((t (eval (list 'define-class (%ks-tname m) '<ks-class> ()))))
	       (%ks-register m t))))))

;; a class: its type's base is its superclass's type, its metaclass's its superclass's metaclass
(set ks-define-class (lambda (name super ivars)
  (let* ((st (and super (ks-class-type super)))
	 (made (cdr (assq name *ks-class-types*)))
	 (fields (concat-list (and st (array-at %structure-fields st)) ivars))	; its superclass's, then its own
	 (t (or (and made (array-at *ks-storage* made) (not (equal (array-at %structure-fields made) fields))
		     (error "Smalltalk: " name " was made with fields " (array-at %structure-fields made) ", not " fields))
		made	; made before its definition (a document met it), with the same fields
		(and (not (or (= name 'Object) (assq name *ks-sysclasses*) (member? name '(Number String)) (member? name *ks-abstract*)))
		     (%ks-class name st ivars))
		(ks-class-type name))))
    (and t (not (= t st)) (or st (array-at *ks-storage* t)) (set-array-at %structure-bases t st))	; under Object: no base
    (and super (set-array-at %structure-bases (ks-meta-type name) (ks-meta-type super)))
    (let ((c (ks-class-named name)))
      (if c (let () (set (<ks-class>-super c) super) (set (<ks-class>-ivars c) ivars) c)
	(cdar (push *ks-classes* (cons name (new (ks-meta-type name) name super ivars)))))))))
(define-function ks-superclass (kind)	; a kind's superclass, a metaclass's its superclass's metaclass, or ()
  (if (ks-meta? kind)
      (let ((c (ks-class-named (ks-meta-base kind)))) (and c (<ks-class>-super c) (ks-meta (<ks-class>-super c))))
    (let ((c (ks-class-named kind))) (and c (<ks-class>-super c)))))

;; methods: a Maru selector per Smalltalk selector (#name), a method per class's type, Object's as the fallback
(define *ks-selectors* (identity-hash-table))	; selector name -> Maru selector
(define *ks-object-methods* (identity-hash-table))	; selector name -> Object's method
(define-function ks-selector (sel)
  (or (hash-at *ks-selectors* sel)
      (hash-at-put *ks-selectors* sel (selector (concat-symbol '# sel) (lambda args ())))))
(define-function ks-method (kind sel fn)
  (if (= kind 'Object) (hash-at-put *ks-object-methods* sel fn)
    (<selector>-add-method (ks-selector sel) (ks-class-type kind) fn)))
(define-function ks-method-for-type (type sel)	; type's method for sel, or its bases', or Object's
  (let ((s (hash-at *ks-selectors* sel)))
    (or (and s type (or (array-at (<selector>-methods s) type) (<selector>-inherit (<selector>-methods s) type)))
	(hash-at *ks-object-methods* sel))))
(define-function ks-method-for (kind sel) (ks-method-for-type (ks-class-type kind) sel))
(define-function ks-own-method (kind sel)	; the class's own, not inherited
  (let ((s (hash-at *ks-selectors* sel)) (t (ks-class-type kind)))
    (and s t (array-at (<selector>-methods s) t))))

;; String over <string> and <symbol>, so a symbol (t among them) answers String's methods
(ks-class-type 'String)

;; the classes the loader makes objects of before any platform or source is loaded, with the instance variables theirs
;; declare (squeak-base.st and ksworld/*.st declare them again, as they are)
(ks-define-class 'HashedCollection 'Collection ())
(ks-define-class 'Dictionary 'HashedCollection '(slots))
(ks-define-class 'IdentityDictionary 'Dictionary ())
(ks-define-class 'KSProtoObject 'IdentityDictionary ())
(ks-define-class 'KSObject 'KSProtoObject ())
(ks-define-class 'Set 'HashedCollection '(items))
(ks-define-class 'IdentitySet 'Set ())
(ks-define-class 'SequenceableCollection 'Collection ())
(ks-define-class 'ArrayedCollection 'SequenceableCollection ())
(ks-define-class 'OrderedCollection 'SequenceableCollection '(items))
(ks-define-class 'SortedCollection 'OrderedCollection '(sortBlock))
(ks-define-class 'Interval 'SequenceableCollection '(start stop step))
(ks-define-class 'Message 'Object '(selector name arguments))
(ks-define-class 'FloatArray 'ArrayedCollection '(data count))
(ks-define-class 'ShortPointArray 'ArrayedCollection '(data count))
(ks-define-class 'ByteArray 'ArrayedCollection '(data count))
(ks-define-class 'KSContentsCollection 'Object '(array firstIndex lastIndex indexCache))
(ks-define-class 'KSShape 'Object '(whole fill extent borderFill borderWidth infinite isRectangle cornerRadius shadowFill shadowOffset
			      shadowBlur elements transform offset drawingBounds hBearing))
