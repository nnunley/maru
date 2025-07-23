;;; debug-threaded.l - Debug threaded loading

(println "Loading emit-c-threaded-clean.l...")
(load "emit-c-threaded-clean.l")
(println "emit-c-threaded-clean.l loaded successfully")

(println "Loading compile-evalm-final.l...")  
(load "compile-evalm-final.l")
(println "compile-evalm-final.l loaded successfully")

(println "Testing compile-evalm...")
(compile-evalm 42)