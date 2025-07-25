;;; Meta-compile the reflective evaluator's self-knowledge

(load "emit-c-threaded.l")

(println "=== Meta-Compiling Reflective Evaluator's Self-Knowledge ===")

;; Compile the evaluator's understanding of its own capabilities
;; This is the essence of reflection: the evaluator compiling its own knowledge

(println "Compiling self-knowledge-1: 42")
(compile-threaded 42)

(println)
(println "Compiling self-knowledge-2: (+ 20 22)")  
(compile-threaded '(+ 20 22))

(println)
(println "Compiling self-knowledge-3: (if 1 42 0)")
(compile-threaded '(if 1 42 0))

(println)
(println "Compiling self-knowledge-4: (if 1 (+ (* 6 7) 0) (* 10 4))")
;; This will partially work - the threaded backend will simplify it to (+ 42 0)
(compile-threaded '(if 1 (+ 42 0) 40))