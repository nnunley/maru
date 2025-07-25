;;; test-direct-load.l - Simple test of direct loading

(println "Testing direct .k file loading...")

;; Try to load the IR system
(println "Attempting to load ir.k...")
(require "core/compiler/ir.k")
(println "ir.k loaded successfully!")

(println "Attempting to load maru.k...")  
(require "core/maru.k")
(println "maru.k loaded successfully!")

(println "Attempting to load eval-multimethod.k...")
(require "core/eval-multimethod.k")
(println "eval-multimethod.k loaded successfully!")

;; Try to call the test function
(println "Calling test-eval function...")
(test-eval)

(println "SUCCESS: All .k files loaded and executed!")