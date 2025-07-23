;; Simple test to see if C backend can handle basic functions from eval.l
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

;; Define a simple function similar to those in eval.l
(define-function max (a b)
  (if (> a b) a b))

(define-function test-main ()
  (max 42 24))

(compile-end)