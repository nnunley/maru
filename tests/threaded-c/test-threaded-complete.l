;;; test-threaded-complete.l - Complete test of threaded C backend

(load "emit-c-threaded-clean.l")
(load "compile-evalm-final.l")

;; Test 1: Simple arithmetic
(println "=== Test 1: (+ 40 2) ===")
(compile-evalm '(+ 40 2))