;;; test-emit-c-threaded-fixed.l - Test the fixed threaded C backend

(println "Testing emit-c-threaded-fixed.l...")

;; Load the fixed threaded C backend
(load "emit-c-threaded-fixed.l")

;; Test 1: Generate a simple threaded function
(println "\n=== Test 1: Simple Threaded Function (40 + 2) ===")
(generate-threaded-function)