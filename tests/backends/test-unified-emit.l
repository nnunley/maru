;;; Test the unified emit.l with both backends

(compile-begin)

(define test-add (a b)
  (+ a b))

(define test-main ()
  (test-add 2 3))

(compile-end)