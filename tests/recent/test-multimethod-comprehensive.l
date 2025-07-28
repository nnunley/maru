;; Comprehensive test of multimethod dispatch backend system
(require "core/compiler/emit.l")
(require "core/compiler/backend-dispatch.l")

;; Set up a string port to capture output
(define test-port (string-port))
(set *emit-output-port* test-port)

(println "=== Comprehensive Multimethod Backend Test ===\n")

;; Helper to clear and show port contents
(define-function show-output (title)
  (println title)
  (println (port-contents test-port))
  (println)
  (set (<port>-buffer test-port) (array)))

;; Test 1: Complete factorial function with C backend
(println "Test 1: Factorial Function in C\n")
(let ((comp (compiler 0)))
  ;; Create function with recursive factorial
  (let ((expr (new <expr>))
        (n (variable 'n 0 () 0)))
    (set (<expr>-defn expr) 
         `(lambda (,n)
            (if (<= ,n 1)
                1
                (* ,n (factorial (- ,n 1))))))
    (emit-definition c-backend expr 'factorial comp)
    (show-output "Factorial function:")))

;; Test 2: Complex control flow with nested structures
(println "Test 2: Complex Control Flow\n")
(let ((comp (compiler 0)))
  (let ((x (variable 'x 0 () 0))
        (y (variable 'y 0 () 0))
        (sum (variable 'sum 0 () 0))
        (i (variable 'i 0 () 0)))
    ;; Nested while with let
    (emit-expr c-backend
      `(let ((,sum 0))
         (let ((,i 1))
           (while (<= ,i 10)
             (set ,sum (+ ,sum ,i))
             (set ,i (+ ,i 1)))
           ,sum))
      comp)
    (show-output "Sum 1 to 10:")))

;; Test 3: Backend Selection
(println "Test 3: Backend Selection\n")
(let ((comp (compiler 0)))
  ;; Generate with C backend
  (emit-expr c-backend '(+ 42 58) comp)
  (println "C backend: " (port-contents test-port))
  (set (<port>-buffer test-port) (array))
  
  ;; Show that we have both backends available
  (println "Available backends: c-backend and asm-backend")
  (println "Backend types: " (type-of c-backend) " and " (type-of asm-backend))
  (println))

;; Test 4: Main function generation
(println "Test 4: Main Function\n")
(let ((comp (compiler 0)))
  (let ((expr (new <expr>))
        (argc (variable 'argc 0 () 0))
        (argv (variable 'argv 0 () 0)))
    (set (<expr>-defn expr) 
         `(lambda (,argc ,argv)
            (println "Hello from Maru!")
            (if (> ,argc 1)
                (println "First arg: " (array-at ,argv 1))
                ())
            0))
    (emit-definition c-backend expr 'main comp)
    (show-output "Main function:")))

;; Test 5: String handling
(println "Test 5: String Operations\n")
(let ((comp (compiler 0)))
  (emit-expr c-backend 
    '(println "Hello, \"World\"!\nFrom Maru") 
    comp)
  (show-output "String with escapes:"))

;; Test 6: Function calls with multiple arguments
(println "Test 6: Function Calls\n")
(let ((comp (compiler 0)))
  (let ((a (variable 'a 0 () 0))
        (b (variable 'b 0 () 0))
        (c (variable 'c 0 () 0)))
    (emit-expr c-backend 
      `(my-function ,a ,b ,c "literal" (+ ,a ,b))
      comp)
    (show-output "Complex function call:")))

(println "=== Test Complete ===")