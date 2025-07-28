;;; test-emit-c-functions.l - Test function compilation

(load "boot.l")
(require "lib/stream/port.l")
(load "core/compiler/emit-c.l")

(println "=== TESTING FUNCTION COMPILATION ===")
(println)

;; Test 1: Simple function
(println "Test 1: Simple function")
(let ((output (string-port)))
  (compile-maru-function 'add-one '(x) '((+ x 1)) output)
  (println (port-contents output)))

;; Test 2: Function with multiple parameters
(println "Test 2: Multiple parameters")
(let ((output (string-port)))
  (compile-maru-function 'add-two-numbers '(a b) '((+ a b)) output)
  (println (port-contents output)))

;; Test 3: Function with comparison
(println "Test 3: Function with comparison")
(let ((output (string-port)))
  (compile-maru-function 'is-greater '(x y) '((> x y)) output)
  (println (port-contents output)))

;; Test 4: Function with conditional
(println "Test 4: Function with conditional")
(let ((output (string-port)))
  (compile-maru-function 'max-of-two '(a b) '((if (> a b) a b)) output)
  (println (port-contents output)))

(println "=== FUNCTION COMPILATION TESTS COMPLETE ===")