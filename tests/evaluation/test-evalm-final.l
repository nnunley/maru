;;; test-evalm-final.l - Test final evalm compilation

(load "compile-evalm-final.l")

;; Test arithmetic
(println "=== Compiling: (+ 40 2) ===")
(compile-evalm '(+ 40 2))