;;; Floats natively: arithmetic, negation, comparison, conversion, literals, and floats passed and returned, in
;;; registers and, past the eighth, on the stack among integer arguments.

(define-function fadd double ((a double) (b double)) (return (+ a b)))
(define-function fmix float ((a float) (b float) (c float)) (return (- (* a b) (/ c a))))
(define-function fneg double ((a double)) (return (- a)))
(define-function flit double () (return (+ 2.5 (cast -0.125 double))))
(define-function flit32 float () (return 0.1))
(define-function to-long long ((a double)) (return (cast a long)))
(define-function to-int int ((a float)) (return (cast a int)))
(define-function from-long double ((n long)) (return (cast n double)))
(define-function widen double ((a float)) (return (cast a double)))
(define-function narrow float ((a double)) (return (cast a float)))

;; each relation a bit, as flow.k's integer relations
(define-function relations long ((a double) (b double))
  (let (((bits long) 0))
    (if (= a b) (set bits (+ bits 1)))
    (if (!= a b) (set bits (+ bits 2)))
    (if (< a b) (set bits (+ bits 4)))
    (if (<= a b) (set bits (+ bits 8)))
    (if (> a b) (set bits (+ bits 16)))
    (if (>= a b) (set bits (+ bits 32)))
    (return bits)))

;; nine doubles and two longs, interleaved: the ninth double is on the stack, the longs in X0 and X1
(define-function weigh double ((n long) (a double) (b double) (c double) (d double) (e double) (f double) (g double) (h double)
				(m long) (i double))
  (return (+ (* (cast n double) a) (+ b (+ c (+ d (+ e (+ f (+ g (+ h (+ (* (cast m double) i) 0.0)))))))))))

(define-function call-weigh double ()
  (return (weigh 2 1.5 1.0 1.0 1.0 1.0 1.0 1.0 1.0 3 0.25)))
(define-function call-fadd double ((x double)) (return (fadd x (fadd x 1.0))))
