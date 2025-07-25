;;; test-eval-k.l - Test driver for eval.k
;;;
;;; This compiles eval.k through the IR system and runs basic tests

(load "boot.l")
(load "core/maru.k")

;; Load and compile eval.k
(println "Loading eval.k...")
(load "core/eval.k")

;; The test-eval function should have been compiled
(println "Running eval.k tests...")

;; If we have the compiled test-eval function, run it
(and (defined? 'test-eval)
     (test-eval))

(println "Done.")