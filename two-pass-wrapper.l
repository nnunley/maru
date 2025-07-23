;; Two-pass C generation wrapper
;; This demonstrates how to add forward declarations to the C backend output

(define-function generate-c-with-forward-declarations (func-definitions)
  ;; Add C headers
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println)
  (println "typedef union Object *oop;")
  (println "#define nil ((oop)0)")
  (println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
  (println "#define getLong(x) ((long)(x) >> 1)")
  (println)
  
  ;; Generate forward declarations manually (Pass 1)
  (println "// Forward declarations")
  (list-do func func-definitions
    (let ((name (car func))
          (params (cadr func)))
      (print "static oop " (mangle-label name) "(")
      (if (= 0 (list-length params))
          (print "void")
        (let ((first 1))
          (list-do param params
            (if first (set first ()) (print ", "))
            (print "oop " (mangle-label param)))))
      (println ");")))
  (println)
  
  ;; Generate implementations (Pass 2)
  (require "core/compiler/emit.l")
  (use-c-backend)
  
  (compile-begin)
  ;; Define the functions
  (list-do func func-definitions
    (let ((name (car func))
          (params (cadr func))
          (body (caddr func)))
      (eval `(define-function ,name ,params ,body))))
  (compile-end))

;; Example usage
(generate-c-with-forward-declarations '(
  (add-two (a b) (+ a b))
  (multiply (x y) (* x y))
  (max (a b) (if (> a b) a b))
  (test-main () (add-two (multiply 3 4) (max 5 2)))
))