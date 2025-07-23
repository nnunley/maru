;; Test the c-param-name function
(require "core/compiler/emit.l")

;; Test with a variable
(let ((var (variable 'test-param nil nil 0)))
  (println "Variable param name: " (c-param-name var)))

;; Test with a TI32
(let ((temp (TI32 8)))
  (println "TI32 param name: " (c-param-name temp)))

(println "Tests complete")