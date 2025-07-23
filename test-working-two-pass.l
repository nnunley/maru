;; Working two-pass example with proper forward declarations
(require "core/compiler/emit.l")
(use-c-backend)

;; Add C headers
(println "#include <stdio.h>")
(println "#include <stdlib.h>")
(println)
(println "typedef union Object *oop;")
(println "#define nil ((oop)0)")
(println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
(println "#define getLong(x) ((long)(x) >> 1)")
(println)

(compile-begin)

;; Simple functions for testing
(define-function add-two (a b)
  (+ a b))

(define-function multiply (x y) 
  (* x y))

(define-function max (a b)
  (if (> a b) a b))

(define-function test-main ()
  (add-two (multiply 3 4) (max 5 2)))

(compile-end)