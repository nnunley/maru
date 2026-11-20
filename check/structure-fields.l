;;; A structure's field reads and writes on an object of its type, or of a type defined on it, and refuses anything else,
;;; naming the type: the refusal is the last line.  Reading a field of the type itself is checked inline, without a
;;; call: a hash.l lookup reads about nine fields, and calling %typecheck for each was a fifth of imaging Gezira.  A
;;; read takes under 7/4 of a call (it took twice; with no check at all, under one); erasing the checks a body has
;;; already passed is a later pass.
;;;   ./eval check/structure-fields.l     (and ./eval2 -b boot2.l, ./eval3 -b boot2.l)
(define clock (subr "clock" ">l"))	; CPU microseconds
(define-structure <sf-point> (x y))
(define-class <sf-point3> <sf-point> (z))
(define p (new <sf-point> 3 4))
(define q (new <sf-point3> 1 2 3))
(set (<sf-point>-x p) 5)
(or (= 9 (+ (<sf-point>-x p) (<sf-point>-y p))) (error "structure-fields: a field read or written wrong"))
(or (= 3 (+ (<sf-point>-x q) (<sf-point>-y q))) (error "structure-fields: a field of a derived type read wrong"))
(define-function one (x) x)
(define-function time-of (f) (let ((t (clock))) (f) (- (clock) t)))
(define-function reads () (for (i 0 200000) (<sf-point>-x p)))
(define-function calls () (for (i 0 200000) (one p)))
(reads) (calls)
(let ((r (time-of reads)) (c (time-of calls)))
  (if (< (* 4 r) (* 7 c))
      (println "structure fields ok")
    (println "structure fields slow: 200000 reads took " r " us, as many calls " c " us")))
(<sf-point>-x "not a point")
