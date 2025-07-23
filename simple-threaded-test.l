;;; simple-threaded-test.l - Simple test of threaded concepts

;; Simple counter for thread names
(define *counter* 0)

;; Fresh thread name generator
(define-function fresh-name ()
  (set *counter* (+ *counter* 1))
  "thread1")

;; Simple test
(println "Testing thread name generation:")
(println "Name 1: " (fresh-name))
(println "Name 2: " (fresh-name))
(println "Name 3: " (fresh-name))