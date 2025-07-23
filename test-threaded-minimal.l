;;; Test minimal threaded backend functionality

;; Global variables from the file
(define *c-thread-counter* 0)

;; Simple utility function that doesn't use complex features
(define-function c-fresh-thread ()
  "Generate unique thread name"
  (set *c-thread-counter* (+ *c-thread-counter* 1))
  (concat-string "thread_" (long->string *c-thread-counter*)))

;; Test the function
(println "Testing threaded utilities:")
(println "Fresh thread:" (c-fresh-thread))
(println "Fresh thread:" (c-fresh-thread))

;; Simple compile function
(define-function compile-threaded-simple (expr)
  "Simple compile function that just prints the expression"
  (println "Would compile:" expr)
  (println "/* Simple threaded C code */")
  (println "#include <stdio.h>")
  (println "int main() { printf(\"Result: %ld\\n\", 42); return 0; }"))

;; Test it
(compile-threaded-simple '(+ 40 2))