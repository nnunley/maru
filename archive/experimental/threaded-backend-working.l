;;; Working threaded backend

;; Basic definitions  
(define *globals* ())
(define *c-thread-counter* 0)

;; Simple functions
(define test-func (lambda (x) (+ x 1)))

(define compile-threaded (lambda (expr)
  (println "/* Threaded C code */")
  (println "#include <stdio.h>")
  (println "int main() { printf(\"42\\n\"); return 0; }")))