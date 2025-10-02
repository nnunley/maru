;;; test-c-high-backend.l -- Test suite for high-level C backend
;;;
;;; This file tests the high-level C code generation capabilities

(require "boot.l")
(require "emit.l")
(require "emit-c-high.l")

;; Override the environment generation to use high-level approach
(define-function gen-env (env) (gen-env-high-level env))

;; Test 1: Basic arithmetic and literals
(println "/* ===== Test 1: Basic Arithmetic ===== */")

(compile-begin)

(define-function test_arithmetic (a b)
  (+ a b))

(define-function test_complex_expr ()
  (+ (* 3 4) (- 10 5)))

(compile-end)

;; Test 2: Comparisons and conditionals  
(println)
(println "/* ===== Test 2: Conditionals ===== */")

(compile-begin)

(define-function test_if (x)
  (if (< x 10)
      (+ x 1)
      (- x 1)))

(define-function test_nested_if (x y)
  (if (> x 0)
      (if (> y 0)
          (+ x y)
          x)
      y))

(compile-end)

;; Test 3: Loops and iteration
(println)
(println "/* ===== Test 3: Loops ===== */")

(compile-begin)

(define-function test_while (n)
  (let ((i 0) (sum 0))
    (while (< i n)
      (set sum (+ sum i))
      (set i (+ i 1)))
    sum))

(compile-end)

;; Test 4: Function calls and external functions
(println)
(println "/* ===== Test 4: Function Calls ===== */")

(compile-begin)

(define printf (extern 'printf))

(define-function factorial (n)
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))

(define-function test_external_call (n)
  (printf "Factorial of %d is %d\n" n (factorial n)))

(compile-end)

;; Test 5: Local variables and assignments
(println)
(println "/* ===== Test 5: Local Variables ===== */")

(compile-begin)

(define-function test_locals ()
  (let ((x 10) (y 20) (z 0))
    (set z (+ x y))
    (set x (* x 2))
    (+ x (+ y z))))

(compile-end)

;; Test 6: Boolean operations
(println)
(println "/* ===== Test 6: Boolean Operations ===== */")

(compile-begin)

(define-function test_boolean (a b c)
  (if (and (> a 0) (< b 100))
      (or (= c 42) (>= c 0))
      (not (= a b))))

(compile-end)

;; Test 7: Main function
(println)
(println "/* ===== Test 7: Main Function ===== */")

(compile-begin)

(define main
  (lambda (argc argv)
    (let ((result (test_arithmetic 40 2)))
      (printf "Result: %d\n" result)
      0)))

(compile-end)