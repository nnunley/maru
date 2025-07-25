;; Test basic emit loading
(require "core/bootstrap/boot.l")

;; Simple test function  
(define-function test-add (a b)
  (+ a b))

(println "Basic test complete")