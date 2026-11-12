(define-object <undefined> 0 ())
;;; Maru objects in typed Maru (doc/ir2-objects.md): declared with define-object, used through their fields by type and
;;; name, never by word offset.  Lowered to eval.l's layout: the type id in the word before the object.
(define-object <pair> 19 ((head oop) (tail oop)))
(define-object <long> 3 ((bits long)) atom)

(define-function pair-swap void ((p oop))
  (let (((h oop) (<pair>-head p)))
    (set (<pair>-head p) (<pair>-tail p))
    (set (<pair>-tail p) h)))

(define-function long-bits long ((n oop))
  (return (<long>-bits n)))

;; new makes an object in its type's family: the id in the word before it, from gc_malloc, or gc_malloc_atomic for an atom
(define-function make-pair oop ((h oop) (t oop))
  (let (((p oop) (new <pair>)))
    (set (<pair>-head p) h)
    (set (<pair>-tail p) t)
    (return p)))

(define-function box long ((n long))
  (let (((b oop) (new <long>)))
    (set (<long>-bits b) n)
    (return (<long>-bits b))))

;; a type declared after the function that makes one
(define-function make-late oop ()
  (let (((l oop) (new <late>)))
    (set (<late>-x l) 99)
    (return l)))

(define-object <late> 20 ((x long)))
(define-object <slots> 21 ())

;; object-type: nil is <undefined>, an odd word is <long>, anything else the id in the word before it

(define-function type-of-arg long ((x oop)) (return (object-type x)))
(define-function is-pair int ((x oop)) (return (object-is <pair> x)))

;; the operand is evaluated once
(define (calls long) 0)
(define-function next oop () (set calls (+ calls 1)) (return (make-pair nil nil)))
(define-function once long ()
  (let (((t long) (object-type (next))))
    (return (+ calls (* 0 t)))))

;; get and put check the object's type first, as eval.l's do, calling the unit's type_check_fail when it isn't
(define (failed-expected long) 0)
(define (failed-actual long) 0)
(define-function type_check_fail void ((expected long) (actual long))
  (set failed-expected expected)
  (set failed-actual actual))

(define-function checked-head oop ((p oop)) (return (get <pair> head p)))
(define-function checked-put long ((p oop) (v oop)) (put <pair> tail p v) (return 0))
(define-function check-only void ((p oop)) (get <pair> head p))	; a get as a statement: its check is its effect
(define-function failure long () (return (+ (* 100 failed-expected) failed-actual)))

;; on a mismatch whose type_check_fail returns (a handler that recovers), get answers 0 of the field's type and put
;; writes nothing: neither touches the object
(define-function get-of-nil long () (return (cast (get <pair> tail nil) long)))
(define-function put-on-nil long () (put <pair> tail nil (cast 5 oop)) (return 1))

;; nil, the object level's constant: the zero word, natively and through C, of type oop, <undefined>'s object
(define-function nil-word long () (return (cast nil long)))
(define-function nil-type long () (return (object-type nil)))
(define-function nil-is-zero long ((x oop)) (if (= x nil) (return 1)) (return 0))

;; an odd word is a tagged <long>: get of its bits answers its value, put to it fails the type check (there is no body),
;; and boxed? tells it, and nil, from an object
(define-function untag long ((x oop)) (return (get <long> bits x)))
(define-function put-odd long ((x oop)) (put <long> bits x 7) (return 0))
(define-function is-boxed long ((x oop)) (if (boxed? x) (return 1)) (return 0))

;; (new <T> extra) makes an object extra bytes longer than its fields: a variable-sized object, as eval3's _newOops
(define-function make-slots oop ((n long))
  (let (((s oop) (new <slots> (* n (sizeof oop)))))
    (set (indir (cast s long *) (- n 1)) n)
    (return s)))
(define-function slots-size long ((s oop)) (return (gc_size s)))	; the bytes the collector gave it
