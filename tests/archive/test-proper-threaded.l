;;; Test the proper threaded backend

;; Load the proper threaded backend
(require "emit-c-threaded-proper.l")

(println "Testing proper threaded backend with environment management:")
(compile-threaded '(+ 15 27))