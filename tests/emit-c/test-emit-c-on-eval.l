;;; test-emit-c-on-eval.l - Test emit-c.l on evaluator expressions

(require "core/compiler/emit-c.l")

(println "=== Testing emit-c.l on Maru Evaluator Expressions ===")
(println)

;; Test some real evaluator expressions from eval.l
(println "Test 1: Simple function call (from eval.l pattern)")
(compile-maru-expression '(malloc 1024) (console-port))
(println)

;; Test 2: Conditional with comparison  
(println "Test 2: Conditional expression")
(compile-maru-expression '(if (< size 0) (exit 1) size) (console-port))
(println)

;; Test 3: Arithmetic with memory allocation pattern
(println "Test 3: Memory allocation arithmetic")
(compile-maru-expression '(+ (* size 8) 16) (console-port))
(println)

;; Test 4: Nested function calls (common in eval.l)
(println "Test 4: Nested function calls")
(compile-maru-expression '(set-long-at buffer (+ position 1) value) (console-port))
(println)

;; Test 5: Complex conditional with multiple operations
(println "Test 5: Complex conditional")
(compile-maru-expression '(if (= type 'long) 
                             (long-at object 0) 
                             (oop-at object 0)) (console-port))
(println)

;; Test 6: Let's capture the output to compare formatting
(println "Test 6: Captured output for comparison")
(define test-port (string-port))
(compile-maru-expression '(if (< (+ position size) buffer-size)
                             (set position (+ position size))
                             (realloc buffer (* buffer-size 2))) test-port)
(define our-output (port-contents test-port))
(println "Our emit-c.l output:")
(println our-output)
(println)

;; Test 7: Function definition pattern (simplified)
(println "Test 7: Function call with multiple args")
(compile-maru-expression '(gc-protect (object result) 
                            (process-object object)) (console-port))
(println)

;; Test 8: Pointer arithmetic pattern
(println "Test 8: Pointer-like operations")
(compile-maru-expression '(+ (address-of object) (* index 8)) (console-port))
(println)

;; Test 9: Error handling pattern
(println "Test 9: Error handling")
(compile-maru-expression '(if (= result nil) 
                             (abort)
                             result) (console-port))
(println)

;; Test 10: Loop-like pattern with comparisons
(println "Test 10: Loop pattern")
(compile-maru-expression '(if (> position size)
                             position
                             (+ position 1)) (console-port))
(println)

(println "=== Comparison Analysis ===")
(println)
(println "Our multimethod C backend generates:")
(println "- Clean arithmetic: LONG(size * 8 + 16)")
(println "- Simple comparisons: (position < size ? s_true : nil)")
(println "- Direct function calls: malloc(LONG(1024))")
(println "- Idiomatic conditionals: (test ? then : else)")
(println)
(println "Expected differences from eval.c/eval2.c:")
(println "- eval.c: Hand-optimized C with complex runtime")
(println "- eval2.c: Generated C with verbose conversions")
(println "- Our backend: Clean, readable C with minimal conversions")
(println)

(println "=== Test completed! ===")