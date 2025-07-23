;;; test-emit-c-threaded-evalm.l - Test evalm-style threaded C compilation

(println "Testing evalm-style threaded C compilation...")

;; Load the evalm-enhanced threaded C backend
(load "emit-c-threaded-evalm.l")

;; Run the evalm test
(test-evalm-compilation)