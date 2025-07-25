;;; Test if define-function works in eval2

(define-function simple-test (x)
  "A simple test function"
  (println "Hello from function:" x))

(simple-test "world")