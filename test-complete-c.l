;; Complete C test with main wrapper  
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

;; Simple functions
(define-function add-two (a b)
  (+ a b))

(define-function multiply (x y)
  (* x y))

(define-function test-if (x)
  (if (long? x) x 0))

(define-function maru-main ()
  (add-two (multiply 3 4) 5))

(compile-end)

;; Add C main wrapper
(println)
(println "int main() {")
(println "    oop result = maru_2Dmain();")
(println "    printf(\"Result: %ld\\n\", getLong(result));")
(println "    return 0;")
(println "}")