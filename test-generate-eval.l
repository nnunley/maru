;; Test generating eval2.c with C backend
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

;; Try loading the core evaluator
(require "core/eval.l")