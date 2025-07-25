;; Test minimal eval-like functions with C backend
(require "core/compiler/emit.l")
(use-c-backend)

;; Add C header
(println "#include <stdio.h>")
(println "#include <stdlib.h>")
(println)
(println "typedef union Object *oop;")
(println "#define nil ((oop)0)")
(println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
(println "#define getLong(x) ((long)(x) >> 1)")
(println)

(compile-begin)

;; Simple functions that work with current C backend
(define-function add-two (a b)
  (+ a b))

(define-function multiply (x y)
  (* x y))

(define-function main ()
  (add-two 5 7))

(compile-end)