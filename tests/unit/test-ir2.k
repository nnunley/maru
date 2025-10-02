;; Test IR system using high-level Maru syntax
;; This tests the complete compilation pipeline from Maru to C

(define (printf (int char * ...) *) (extern printf))

(define-struct <Point> ((x int) (y int)))

(define-function print-point int ((p struct <Point>))
  (printf "Point with x = %d and y = %d\n" (member p x) (member p y))
  (return (+ (member p x) (member p y))))

(define-function main int ((argc int) (argv char * *))
  (let (((point struct <Point>)))
    (set (member point x) 42)
    (set (member point y) 666)
    (let ((sum (print-point point)))
      (printf "Sum is %d\n" sum)))
  (return 0))