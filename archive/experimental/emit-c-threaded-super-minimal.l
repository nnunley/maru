;;; Super minimal threaded backend

;; Just the compilation environment basics
(define *globals* ())

(define-function environment (parent)
  (list parent 0 ()))

(define-form compile-begin ()
  `(set *globals* (environment *globals*)))

(define-function compile-threaded (expr)
  (println "/* Generated C code */")
  (println "#include <stdio.h>")  
  (println "int main() { printf(\"42\\n\"); return 0; }"))