;;; Test environment isolation with compile-begin/compile-end

(println "Loading enhanced threaded backend...")
(load "emit-c-threaded-minimal.l")

(println "Testing environment isolation:")

;; Show initial environment
(println "Initial *globals*:" *globals*)

;; Create first compilation environment
(println "\n=== First compilation environment ===")
(compile-begin)
(println "After compile-begin #1, *globals* level:" (if *globals* (cadr *globals*) "nil"))

;; Create nested compilation environment  
(println "\n=== Nested compilation environment ===")
(compile-begin)
(println "After compile-begin #2, *globals* level:" (if *globals* (cadr *globals*) "nil"))

;; Show that each environment is isolated
(println "Parent environment level:" (if (car *globals*) (cadr (car *globals*)) "nil"))

;; Compile something in nested environment
(println "\n=== Compiling in nested environment ===")
(compile-threaded '(+ 10 20))

;; Exit nested environment
(println "\n=== Exiting nested environment ===")
(let ((env (compile-end)))
  (println "Returned environment level:" (cadr env))
  (println "Current *globals* level:" (if *globals* (cadr *globals*) "nil")))

;; Exit first environment  
(println "\n=== Exiting first environment ===")
(let ((env (compile-end)))
  (println "Returned environment level:" (if env (cadr env) "nil"))
  (println "Final *globals*:" *globals*))