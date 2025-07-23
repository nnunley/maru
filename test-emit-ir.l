;;; Test the IR-based emit system

(load "emit-ir.l")

(println "Testing IR-based emit...")

;; Simple test program
(define test-program
  '((define x 42)
    
    (define-function add (a b)
      (+ a b))
    
    (define-function main ()
      (println "Hello from IR!")
      (let ((result (add x 10)))
        (println "Result: " result))
      0)))

;; Compile to IR and generate C code
(println "Compiling test program to C via IR...")
(emit-with-ir test-program 'c)