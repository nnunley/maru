;;; Test super minimal version

(println "Loading super minimal threaded backend...")
(load "emit-c-threaded-super-minimal.l")
(println "Loaded successfully!")

(println "\nTesting compile-begin:")
(compile-begin)
(println "Environment created, level:" (cadr *globals*))

(println "\nTesting compilation:")
(compile-threaded '(+ 1 2))