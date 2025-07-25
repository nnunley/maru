;;; Demonstrate environment isolation with compile-begin/compile-end

(load "threaded-backend-final.l")

(println "=== Environment Isolation Demo ===")
(println)

;; Show initial state
(println "Initial environment level:" (if *globals* (cadr *globals*) 0))

;; Create source compilation environment (like loading eval.l)
(println "\n--- Loading source file (like eval.l) ---")
(compile-begin)
(println "Created compilation environment, level:" (cadr *globals*))

;; Compile something in this environment
(println "\n--- Compiling in isolated environment ---")
(compile-threaded '(+ 100 23))

;; Show we can nest environments (like multiple source files)
(println "\n--- Loading nested source (like boot.l) ---")  
(compile-begin)
(println "Created nested environment, level:" (cadr *globals*))

;; Compile in nested environment
(println "\n--- Compiling in nested environment ---")
(compile-threaded '(+ 50 7))

;; Exit nested environment
(println "\n--- Finished with nested source ---")
(let ((nested-env (compile-end)))
  (println "Exited nested environment, returned level:" (cadr nested-env))
  (println "Current environment level:" (if *globals* (cadr *globals*) 0)))

;; Exit main compilation environment
(println "\n--- Finished with main source ---")
(let ((main-env (compile-end)))
  (println "Exited main environment, returned level:" (if main-env (cadr main-env) 0))
  (println "Final environment level:" (if *globals* (cadr *globals*) 0)))

(println "\n=== Demo Complete ===")
(println "The threaded backend can now isolate compilation of different")
(println "source files using compile-begin/compile-end environments!")