;;; The C library's math functions as the native back end lowers them (check/native.l): floorf, floor, ceilf, ceil,
;;; sqrtf and sqrt, declared extern as Nile's Maru back end declares them, are each one instruction, not a call, and
;;; exact: a floor is the whole number at or below, for every value, past int's range and at the infinities.
(define (floorf (float float) *) (extern floorf))
(define (ceilf (float float) *) (extern ceilf))
(define (sqrtf (float float) *) (extern sqrtf))
(define (floor (double double) *) (extern floor))
(define (ceil (double double) *) (extern ceil))
(define (sqrt (double double) *) (extern sqrt))
(define-function m-floorf float ((a float)) (return (floorf a)))
(define-function m-ceilf float ((a float)) (return (ceilf a)))
(define-function m-sqrtf float ((a float)) (return (sqrtf a)))
(define-function m-floor double ((a double)) (return (floor a)))
(define-function m-ceil double ((a double)) (return (ceil a)))
(define-function m-sqrt double ((a double)) (return (sqrt a)))
