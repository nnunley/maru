;; Test the proper C backend implementation
(require "core/compiler/emit.l")
(require "core/compiler/emit-c-proper.l")

;; Set up a string port to capture output
(define test-port (string-port))
(set *emit-output-port* test-port)

;; Test 1: Simple function with arithmetic
(println "Test 1: Simple arithmetic function")
(let ((comp (compiler 0))
      (c-comp (c-compiler comp)))
  ;; Create a simple function: (define (add x y) (+ x y))
  (let ((expr (new <expr>)))
    (set (<expr>-defn expr) '(lambda (x y) (+ x y)))
    (gen-definition expr 'add c-comp)))

;; Test 2: Function with if statement  
(println "Test 2: Function with if statement")
(let ((comp (compiler 0))
      (c-comp (c-compiler comp)))
  ;; Create: (define (max a b) (if (> a b) a b))
  (let ((expr (new <expr>)))
    (set (<expr>-defn expr) '(lambda (a b) (if (> a b) a b)))
    (gen-definition expr 'max c-comp)))

;; Test 3: Function with while loop
(println "Test 3: Function with while loop")
(let ((comp (compiler 0))
      (c-comp (c-compiler comp)))
  ;; Create: (define (count n) (while (> n 0) (set n (- n 1))))
  (let ((expr (new <expr>)))
    (set (<expr>-defn expr) '(lambda (n) (while (> n 0) (set n (- n 1)))))
    (gen-definition expr 'count c-comp)))

;; Get the output
(define output (port-contents test-port))
(println "\nGenerated C code:")
(println "================")
(print output)
(println "================")