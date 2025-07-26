;;; test-emit-c.l - Comprehensive test for the unified emit-c.l backend

(require "emit-c.l")

(println "=== Testing Comprehensive Multimethod C Backend ===")
(println)

;; Test 1: Simple numbers
(println "Test 1: Numbers")
(compile-maru-expression 42 (console-port))
(println)

;; Test 2: Simple arithmetic (should be idiomatic!)
(println "Test 2: Simple arithmetic")
(compile-maru-expression '(+ 5 3) (console-port))
(println)

;; Test 3: Nested arithmetic (should be much cleaner!)
(println "Test 3: Nested arithmetic")
(compile-maru-expression '(+ (* 5 6) (- 10 3)) (console-port))
(println)

;; Test 4: Comparisons (should be much cleaner!)
(println "Test 4: Comparisons")
(compile-maru-expression '(< 5 10) (console-port))
(println)

;; Test 5: Complex comparison
(println "Test 5: Complex comparison")
(compile-maru-expression '(< (+ 2 3) (* 4 5)) (console-port))
(println)

;; Test 6: If expression (should be much cleaner!)
(println "Test 6: If expression")
(compile-maru-expression '(if (< 5 10) 100 200) (console-port))
(println)

;; Test 7: Variables
(println "Test 7: Variables")
(compile-maru-expression 'x (console-port))
(println)

;; Test 8: Function call with arithmetic
(println "Test 8: Function call with arithmetic")
(compile-maru-expression '(factorial (+ 3 2)) (console-port))
(println)

;; Test 9: String
(println "Test 9: String")
(compile-maru-expression "hello world" (console-port))
(println)

;; Test 10: Complex nested expression
(println "Test 10: Complex nested")
(compile-maru-expression '(if (< (+ x 1) (* y 2)) (+ a b) (- c d)) (console-port))
(println)

;; Test 11: Quote expression
(println "Test 11: Quote")
(compile-maru-expression '(quote foo) (console-port))
(println)

;; Test 12: Nil
(println "Test 12: Nil")
(compile-maru-expression 'nil (console-port))
(println)

;; Test 13: Check that we generate idiomatic output to string
(println "Test 13: String output for verification")
(define test-port (string-port))
(compile-maru-expression '(+ (* 2 3) (- 8 2)) test-port)
(println "Generated C code:")
(println (port-contents test-port))
(println)

(println "=== All comprehensive tests completed! ===")
(println)
(println "Expected improvements:")
(println "- Arithmetic: LONG(2 * 3 + 8 - 2) instead of nested LONG/getLong")
(println "- Comparisons: (5 < 10 ? s_true : nil) instead of nested conversions")
(println "- Clean multimethod dispatch based on type-of")
(println "- Context-aware generation for optimal C code")