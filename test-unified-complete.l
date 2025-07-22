;;; test-unified-complete.l - Comprehensive test of unified threaded backend

(load "emit-c-threaded.l")

(println "=== Unified Threaded C Backend Test Suite ===")
(println)

;; Test 1: Simple literal
(println "Test 1: Literal 42")
(compile-threaded 42)
(println)

;; Test 2: Arithmetic
(println "Test 2: (+ 40 2)")  
(compile-threaded '(+ 40 2))
(println)

;; Test 3: Subtraction
(println "Test 3: (- 50 8)")
(compile-threaded '(- 50 8))
(println)

;; Test 4: Multiplication
(println "Test 4: (* 6 7)")
(compile-threaded '(* 6 7))
(println)

;; Test 5: True conditional
(println "Test 5: (if 1 42 0)")
(compile-threaded '(if 1 42 0))
(println)

;; Test 6: False conditional  
(println "Test 6: (if 0 42 99)")
(compile-threaded '(if 0 42 99))