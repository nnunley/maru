;; Test the multimethod gen approach
(require "core/compiler/emit.l")
(require "core/compiler/gen-multimethod.l")

;; Set up a string port to capture output
(define test-port (string-port))
(set *emit-output-port* test-port)

(println "Testing multimethod gen system...")

;; Test 1: Assembly backend (default)
(println "\nTest 1: Assembly backend")
(set *current-backend* asm-backend)
(let ((comp (compiler 0)))
  ;; Test gen-if
  (gen-if asm-backend '(if 5 10 20) comp)
  ;; Show generated instructions
  (println "Generated " (<compiler>-pc comp) " instructions:")
  (for (i 0 (min 5 (<compiler>-pc comp)))
    (println "  " (array-at (<compiler>-asm comp) i))))

;; Test 2: C backend
(println "\nTest 2: C backend")
(set *current-backend* c-backend)
(port-write test-port "") ; Clear port
(let ((comp (compiler 0)))
  ;; Test gen-if
  (gen-if c-backend '(if 5 10 20) comp)
  (println "Generated C code:")
  (println (port-contents test-port)))

;; Test 3: gen-while with C backend
(println "\nTest 3: C while loop")
(set (port-buffer test-port) (array)) ; Clear port
(let ((comp (compiler 0)))
  (gen-while c-backend '(while x (set y (+ y 1))) comp)
  (println "Generated C code:")
  (println (port-contents test-port)))

;; Test 4: gen-let with C backend
(println "\nTest 4: C let binding")
(set (port-buffer test-port) (array)) ; Clear port
(let ((comp (compiler 0)))
  ;; Create some dummy variables
  (let ((x (variable 'x 0 () 0))
        (y (variable 'y 0 () 0)))
    (gen-let c-backend `(let ((,x 10) (,y 20)) (+ ,x ,y)) comp)
    (println "Generated C code:")
    (println (port-contents test-port))))

;; Test 5: Test via gen <pair> dispatch
(println "\nTest 5: Using gen with forms")
(set (port-buffer test-port) (array)) ; Clear port
(let ((comp (compiler 0)))
  ;; This should dispatch through gen <pair> to the form handler
  (gen '(if 1 2 3) comp)
  (println "Generated C code:")
  (println (port-contents test-port)))

(println "\nMultimethod test complete!")