;;; test-emit-c-threaded-final.l - Test the final two-pass threaded C backend

(println "Testing final two-pass threaded C backend...")

;; Load the final implementation
(load "emit-c-threaded-final.l")

;; Run a simple test
(println)
(println "=== Compiling: (+ 40 2) ===")
(compile-threaded-final '(+ 40 2))