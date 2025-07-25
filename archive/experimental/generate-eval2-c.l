;; Generate eval2.c using C backend with boot2.l
(require "core/compiler/emit.l")
(use-c-backend)

;; Add C headers for the evaluator
(println "#include <stdio.h>")
(println "#include <stdlib.h>")
(println "#include <stdarg.h>")
(println "#include <string.h>")
(println "#include <ctype.h>")
(println "#include <errno.h>")
(println)
(println "typedef union Object *oop;")
(println "#define nil ((oop)0)")
(println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
(println "#define getLong(x) ((long)(x) >> 1)")
(println)

;; Load the enhanced bootstrap and evaluator
(require "boot2.l")
(require "core/eval.l")