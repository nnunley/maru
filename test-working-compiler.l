;;; test-working-compiler.l - Test the working threaded C compiler

(println "Testing working threaded C compiler...")

;; Load the working implementation
(load "emit-c-threaded-working.l")

;; Run test 2: (+ 40 2)
(println)
(println "=== Generating C code for (+ 40 2) ===")
(compile-with-forwards '(+ 40 2))