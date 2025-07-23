;;; test-emit-c-threaded.l - Test the threaded C backend

(println "Testing emit-c-threaded.l...")

;; Load the threaded C backend
(load "core/compiler/emit-c-threaded.l")

;; Test 1: Generate a simple threaded function
(println "\n=== Test 1: Simple Threaded Function ===")
(generate-threaded-function)