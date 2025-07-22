;;; Test the unified emit.l with threaded C backend

(compile-begin)

(use-c-threaded-backend)

(define test-add (a b)
  (+ a b))

(define test-main ()
  (test-add 40 2))

(compile-end)