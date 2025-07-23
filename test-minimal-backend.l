;;; Test the minimal threaded backend

(println "Loading minimal threaded backend...")
(load "emit-c-threaded-minimal.l")
(println "Loading successful!")

(println "Testing compile-threaded:")
(compile-threaded '(+ 40 2))