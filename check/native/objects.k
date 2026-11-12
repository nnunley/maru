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
