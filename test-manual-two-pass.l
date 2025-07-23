;; Manual two-pass test
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

(compile-begin)

;; Define functions
(define-function add-two (a b) (+ a b))
(define-function multiply (x y) (* x y))
(define-function max (a b) (if (> a b) a b))
(define-function test-main () (add-two (multiply 3 4) (max 5 2)))

;; Manual two-pass generation
(let ((env *globals*))
  (set *globals* (<env>-parent env))
  
  ;; Pass 1: Generate forward declarations manually
  (println "// Forward declarations")
  (println "static oop add_2Dtwo(oop a, oop b);")
  (println "static oop multiply(oop x, oop y);")
  (println "static oop max(oop a, oop b);")
  (println "static oop test_2Dmain(void);")
  (println)
  
  ;; Pass 2: Generate implementations
  (let* ((vars  (<env>-bindings env))
         (comp  (compiler 0))
         (index (array-length vars)))
    (use-c-backend)  ; Enable C backend
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (warn name "\n")
        (gen-definition value name comp)))))