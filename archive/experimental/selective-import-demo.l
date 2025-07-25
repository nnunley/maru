;;; Selective Import Demonstration
;;; Shows how dependency tracker can conditionally import non-shadowed values

;; Simple environment tracking
(define *globals* ())
(define *outer-bindings* ())
(define *import-log* ())

;; Environment operations
(define make-env (lambda (parent bindings)
  (list parent bindings)))

(define env-parent (lambda (env) (car env)))
(define env-bindings (lambda (env) (cadr env)))

;; Shadowing analysis
(define is-shadowed? (lambda (name env)
  "Check if name is defined locally (shadows outer)"
  (if (not env)
      #f  ; no environment, not shadowed
      (if (member? name (env-bindings env))
          #t  ; found locally, is shadowed
          (is-shadowed? name (env-parent env))))))  ; check parent

;; Import system
(define set-outer-bindings (lambda (bindings)
  (set *outer-bindings* bindings)))

(define can-import? (lambda (name)
  "Check if name can be imported (available and not shadowed)"
  (and (assq name *outer-bindings*)
       (not (is-shadowed? name *globals*)))))

(define try-import (lambda (name)
  "Try to import value from outer evaluator"
  (if (can-import? name)
      (let ((value (cadr (assq name *outer-bindings*))))
        (set *import-log* (cons (list name value) *import-log*))
        (println "IMPORTED: " name " = " value)
        value)
      (let ()
        (println "CANNOT IMPORT: " name " (shadowed or unavailable)")
        nil))))

;; Test the system
(println "=== Selective Import Demo ===")
(println)

;; Set up outer evaluator bindings
(set-outer-bindings '((pi 3.14159)
                      (helper-func "outer-helper") 
                      (+ "outer-add")
                      (debug #t)))

(println "Outer evaluator provides:")
(let ((bindings *outer-bindings*))
  (while bindings
    (println "  " (caar bindings) ": " (cadar bindings))
    (set bindings (cdr bindings))))
(println)

;; Test 1: No local definitions - should import everything
(println "--- Test 1: Clean environment (no shadowing) ---")
(set *globals* (make-env () ()))  ; empty environment
(set *import-log* ())

(println "Trying to import pi:")
(try-import 'pi)
(println "Trying to import helper-func:")  
(try-import 'helper-func)
(println)

;; Test 2: Local definition shadows outer
(println "--- Test 2: Local definition shadows outer ---")
(set *globals* (make-env () '(pi helper-func)))  ; pi and helper-func defined locally
(set *import-log* ())

(println "Trying to import pi (locally defined):")
(try-import 'pi)
(println "Trying to import debug (not locally defined):")
(try-import 'debug)
(println)

;; Show import summary
(println "--- Import Summary ---")
(println "Total imports attempted: varies by test")
(println "Import log from last test:")
(let ((log *import-log*))
  (while log
    (println "  " (caar log) " = " (cadar log))
    (set log (cdr log))))

(println)
(println "=== Demo Complete ===")
(println "SUCCESS: Selective import based on shadowing analysis works!")
(println "The system can conditionally pull values from outer evaluator")
(println "only when they won't conflict with local definitions.")