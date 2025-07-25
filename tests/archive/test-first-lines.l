;;; Test first lines of emit-c-threaded.l

(println "Starting test...")

;; First definitions from emit-c-threaded.l
(define *c-thread-counter* 0)
(define *c-indent-level* 0)

(println "Basic definitions work")

;; Test function definition
(define-function c-indent ()
  "Generate indentation for current level"
  (for (i 0 *c-indent-level*) (print "    ")))

(println "c-indent defined")