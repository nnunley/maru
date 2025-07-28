;; Test the backend dispatch system
(require "core/compiler/emit.l")
(require "core/compiler/backend-dispatch.l")

;; Set up a string port to capture output
(define test-port (string-port))
(set *emit-output-port* test-port)

(println "Testing backend dispatch system...")

;; Test 1: emit-value for different types
(println "\nTest 1: emit-value")
(let ((comp (compiler 0)))
  ;; Test number
  (emit-value c-backend 42 comp)
  (println "Number: " (port-contents test-port))
  
  ;; Clear and test string
  (set (<port>-buffer test-port) (array))
  (emit-value c-backend "hello" comp)
  (println "String: " (port-contents test-port))
  
  ;; Clear and test variable
  (set (<port>-buffer test-port) (array))
  (let ((var (variable 'test-var 0 () 0)))
    (emit-value c-backend var comp)
    (println "Variable: " (port-contents test-port))))

;; Test 2: Binary operations
(println "\nTest 2: Binary operations")
(set (<port>-buffer test-port) (array))
(let ((comp (compiler 0)))
  (emit-expr c-backend '(+ 10 20) comp)
  (println "Addition: " (port-contents test-port))
  
  ;; Test with variables
  (set (<port>-buffer test-port) (array))
  (let ((x (variable 'x 0 () 0))
        (y (variable 'y 0 () 0)))
    (emit-expr c-backend `(< ,x ,y) comp)
    (println "Comparison: " (port-contents test-port))))

;; Test 3: if statement
(println "\nTest 3: if statement")
(set (<port>-buffer test-port) (array))
(let ((comp (compiler 0)))
  (let ((x (variable 'x 0 () 0)))
    (emit-if c-backend `(if (> ,x 0) ,x 0) comp)
    (println "Generated C if:")
    (println (port-contents test-port))))

;; Test 4: while loop
(println "\nTest 4: while loop")
(set (<port>-buffer test-port) (array))
(let ((comp (compiler 0)))
  (let ((n (variable 'n 0 () 0)))
    (emit-while c-backend `(while (> ,n 0) (set ,n (- ,n 1))) comp)
    (println "Generated C while:")
    (println (port-contents test-port))))

;; Test 5: let binding
(println "\nTest 5: let binding")
(set (<port>-buffer test-port) (array))
(let ((comp (compiler 0)))
  ;; Create variables
  (let ((x (variable 'x 0 () 0))
        (y (variable 'y 0 () 0)))
    ;; Build the let form properly
    (let ((let-expr (list 'let 
                          (list (list x 10) 
                                (list y 20))
                          (list '+ x y))))
      (emit-let c-backend let-expr comp)
      (println "Generated C let:")
      (println (port-contents test-port)))))

;; Test 6: Function definition
(println "\nTest 6: Function definition")
(set (<port>-buffer test-port) (array))
(let ((comp (compiler 0)))
  ;; Create a simple function
  (let ((expr (new <expr>))
        (x (variable 'x 0 () 0))
        (y (variable 'y 0 () 0)))
    (set (<expr>-defn expr) `(lambda (,x ,y) (+ ,x ,y)))
    (emit-definition c-backend expr 'add comp)
    (println "Generated C function:")
    (println (port-contents test-port))))

(println "\nBackend dispatch test complete!")