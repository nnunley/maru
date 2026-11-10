;;; check/source/spans.l -- definitions whose lines a line-by-line cut gets wrong (check/source.l)
(define-structure <span-a> (x)) (define-function span-b () 'b)
(define-function span-hang (x)
  (+ x 1)
  )
(define span-s "a
b
c")
(define-function span-after () 'after)
(define-function span-tail () (list "x
y"))
