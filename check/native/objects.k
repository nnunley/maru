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
