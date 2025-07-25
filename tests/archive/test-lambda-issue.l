;;; Test if lambda is causing issues

(println "Testing lambda...")

(define-function test-lambda (f)
  "Test lambda function"
  (f))

;; Test with lambda
(test-lambda (lambda () (println "Lambda works")))

;; Test record-thread like function
(define-function record-something (name implementation)
  "Test record function"
  (println "Recording:" name)
  (implementation))

(record-something "test" (lambda () (println "Implementation runs")))

(println "Lambda test complete")