;;; test-emit-c-threaded-comprehensive.l - Comprehensive tests for threaded C backend

(println "=== Comprehensive Threaded C Backend Tests ===")

;; Load the fixed threaded C backend
(load "emit-c-threaded-fixed.l")

;; Test 2: Expression compilation
(test-expression-compilation)