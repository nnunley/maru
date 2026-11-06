;;; Calls compiled natively (check/native.l): ten arguments (two on the stack), variadic calls to printf with mixed
;;; arguments (on Apple arm64 the variadic ones are on the stack; on x86-64 AL counts the vector registers), a float
;;; among them promoted to double, a global, a string literal.
(define (printf (int char * ...) *) (extern printf))
(define (counter long) 0)
(define-function ten long ((a long) (b long) (c long) (d long) (e long) (f long) (g long) (h long) (i long) (j long))
  (return (+ a (+ (* 2 b) (+ (* 3 c) (+ (* 4 d) (+ (* 5 e) (+ (* 6 f) (+ (* 7 g) (+ (* 8 h) (+ (* 9 i) (* 10 j))))))))))))
(define-function bump long () (set counter (+ counter 1)) (return counter))
(define-function main int ((argc int) (argv char * *))
  (printf "%d %s %ld %d\n" 7 "ok" (ten 1 2 3 4 5 6 7 8 9 10) 9)
  (bump) (bump)
  (printf "counter %ld\n" (bump))
  (printf "%d %.2f %ld %.3f %s %.1f\n" 1 2.5 (ten 0 0 0 0 0 0 0 0 0 1) 0.125 "end" (cast 0.5 float))
  (return 0))
