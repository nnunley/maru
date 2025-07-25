;;; Test just loading emit-c-threaded.l

(println "About to load emit-c-threaded.l...")
(load "emit-c-threaded.l")
(println "Loading completed successfully!")
(println "compile-threaded defined?" (if (defined? 'compile-threaded) "yes" "no"))