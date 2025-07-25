;;; Test if compile-threaded function exists

(load "emit-c-threaded.l")
(println "Function exists:" (defined? 'compile-threaded))