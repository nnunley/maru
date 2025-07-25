;; Test two-pass system by calling gen-env-c directly
(require "core/compiler/emit.l")

;; Add C headers
(println "#include <stdio.h>")
(println "#include <stdlib.h>")
(println)
(println "typedef union Object *oop;")
(println "#define nil ((oop)0)")
(println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
(println "#define getLong(x) ((long)(x) >> 1)")
(println)

;; Create environment manually
(set *globals* (environment *globals*))

;; Define functions
(define-function add-two (a b) (+ a b))
(define-function multiply (x y) (* x y))  
(define-function max (a b) (if (> a b) a b))
(define-function test-main () (add-two (multiply 3 4) (max 5 2)))

;; Get the environment
(let ((env *globals*))
  (set *globals* (<env>-parent env))
  ;; Call the two-pass C generator directly
  (gen-env-c env))