;;; Refused (check/native.l): a struct with a floating member by value, until the AAPCS64's homogeneous aggregates and
;;; System V's SSE eightbytes are written; C's cabs takes a double _Complex as such a struct.
(define-struct <cpx> ((re double) (im double)))
(define (cabs (double (struct <cpx>)) *) (extern cabs))
(define-function modulus double ()
  (let (((z struct <cpx>)))
    (set (. z re) 3.0)
    (set (. z im) 4.0)
    (return (cabs z))))
