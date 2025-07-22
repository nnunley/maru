;; ARM64 Backend Test Suite
;; Test basic ARM64 assembly generation

(define (printf (int char * ...) *) (extern printf))

(define-struct <Point> ((x int) (y int)))

(define-function test-arithmetic int ((a int) (b int))
  (let ((sum (+ a b))
        (diff (- a b)))
    (printf "Sum: %d, Diff: %d\n" sum diff)
    (return sum)))

(define-function test-comparison int ((a int) (b int))
  (if (= a b)
      (return 1)
    (return 0)))

(define-function test-struct int ()
  (let (((point struct <Point>)))
    (set (member point x) 10)
    (set (member point y) 20)
    (let ((sum (+ (member point x) (member point y))))
      (printf "Point sum: %d\n" sum)
      (return sum))))

(define-function main int ((argc int) (argv char * *))
  (printf "ARM64 Backend Test\n")
  
  ;; Test arithmetic
  (test-arithmetic 5 3)
  
  ;; Test comparison
  (if (test-comparison 42 42)
      (printf "Comparison test passed\n")
    (printf "Comparison test failed\n"))
  
  ;; Test struct
  (test-struct)
  
  (return 0))