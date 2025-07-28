;;; explore-globals.l - Explore what's available in Maru's global environment

(println "=== Exploring Maru Global Environment ===")
(println)

;; Check if *globals* exists
(if (defined? '*globals*)
    (let ()
      (println "*globals* is defined!")
      (println "Contents:")
      (let ((g *globals*))
        (while (pair? g)
          (println (format "  %s" (car (car g))))
          (set g (cdr g)))))
    (println "*globals* is not defined"))

(println)

;; Check for global-environment
(if (defined? 'global-environment)
    (println "global-environment is defined!")
    (println "global-environment is not defined"))

;; Check for the-environment
(if (defined? 'the-environment)
    (println "the-environment is defined!")
    (println "the-environment is not defined"))

;; Try to find system-related functions
(println "\n=== Checking for system functions ===")

(define-function check-defined (name)
  (if (defined? name)
      (println (format "%s is defined" name))
      (println (format "%s is NOT defined" name))))

(check-defined 'system)
(check-defined 'exit)
(check-defined 'abort)
(check-defined 'malloc)
(check-defined 'dlopen)
(check-defined 'dlsym)
(check-defined 'open)
(check-defined 'close)
(check-defined 'read)
(check-defined 'write)
(check-defined 'fork)
(check-defined 'exec)

;; Check what type various functions are
(println "\n=== Checking function types ===")

(if (defined? 'exit)
    (println (format "exit is a: %s" (type-name-of exit))))

(if (defined? 'car)
    (println (format "car is a: %s" (type-name-of car))))

(if (defined? 'open)
    (println (format "open is a: %s" (type-name-of open))))

;; Try to list all defined symbols
(println "\n=== Trying to list some globals ===")

;; Check some known globals
(if (defined? 'car) (println "car - list operation"))
(if (defined? 'cons) (println "cons - list construction"))
(if (defined? 'print) (println "print - output function"))
(if (defined? 'println) (println "println - output with newline"))
(if (defined? 'format) (println "format - string formatting"))
(if (defined? 'concat-string) (println "concat-string - string concatenation"))
(if (defined? 'open-input-file) (println "open-input-file - file input"))
(if (defined? 'open-output-file) (println "open-output-file - file output"))
(if (defined? 'close-input-port) (println "close-input-port - close input"))
(if (defined? 'close-output-port) (println "close-output-port - close output"))

(println "\nTo get a complete list, we would need access to the environment structure.")
(println "In eval.l, this would be available through internal structures.")