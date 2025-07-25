;;; Test dependency tracking system

(load "emit-c-threaded-minimal.l")
(println "Loaded basic threaded backend")

;; Simple dependency tracking test
(define *missing-functions* ())

(define check-dependency (lambda (name)
  "Check if function/form is available, track if missing"
  (if (defined? name)
      (println "✓ " name " is available")
      (let ()
        (println "✗ " name " is MISSING")
        (set *missing-functions* (cons name *missing-functions*))))))

(println "\n=== Dependency Analysis ===")
(println "Checking what's needed for full eval.l compilation:\n")

;; Check basic forms needed by eval.l
(println "Basic language forms:")
(check-dependency 'define-form)
(check-dependency 'define-function) 
(check-dependency 'define-structure)

(println "\nCore evaluation functions:")
(check-dependency 'eval)
(check-dependency 'apply)
(check-dependency 'environment)

(println "\nUtility functions eval.l uses:")
(check-dependency 'null?)
(check-dependency 'reverse)
(check-dependency 'append)
(check-dependency 'assq)
(check-dependency 'member?)

(println "\nType predicates:")
(check-dependency 'pair?)
(check-dependency 'symbol?)
(check-dependency 'long?)
(check-dependency 'string?)

(println "\nString operations:")
(check-dependency 'string-append)
(check-dependency 'concat-string)
(check-dependency 'long->string)

(println "\nStructure operations:")
(check-dependency '<env>)
(check-dependency '<env>-bindings)
(check-dependency '<env>-parent)

;; Show what we found
(println "\n=== Summary ===")
(println "Missing dependencies count:" (length *missing-functions*))
(if *missing-functions*
    (let ()
      (println "\nMissing functions that need to be provided:")
      (while *missing-functions*
        (println "  -" (car *missing-functions*))
        (set *missing-functions* (cdr *missing-functions*))))
    (println "All dependencies satisfied!"))