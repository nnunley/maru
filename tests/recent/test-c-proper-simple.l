;; Simple test for the proper C backend implementation
(require "core/compiler/emit.l")
(require "core/compiler/emit-c-proper.l")

;; Set up a string port to capture output
(define test-port (string-port))
(set *emit-output-port* test-port)

(println "Testing direct method calls...")

;; Test 1: gen-c-expr for a number
(let ((comp (c-compiler ())))
  (println "Test 1: Number expression")
  (define result (gen-c-expr 42 comp))
  (println "Result variable: " result))

;; Test 2: gen-c-expr for a string
(let ((comp (c-compiler ())))
  (println "\nTest 2: String expression")
  (define result (gen-c-expr "hello" comp))
  (println "Result variable: " result))

;; Test 3: gen-c-binary-op
(let ((comp (c-compiler ())))
  (println "\nTest 3: Binary operation")
  (define result (gen-c-binary-op "+" 10 20 comp))
  (println "Result variable: " result))

;; Get the output
(define output (port-contents test-port))
(println "\nGenerated C code:")
(println "================")
(print output)
(println "================")