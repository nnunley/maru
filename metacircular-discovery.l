;;; metacircular-discovery.l - Use Maru's metacircular nature for discovery

(println "=== Metacircular Discovery in Maru ===")
(println)

;; In a metacircular system, everything is data that can be inspected

;; Try to access the evaluator's environment
(println "1. Checking evaluator access:")

;; The global environment should be accessible
(if (defined? '*globals*)
    (let ()
      (println "Found *globals*!")
      (println "Let's see what's in it...")
      (println)
      
      ;; *globals* should be an association list
      (let ((count 0)
            (g *globals*))
        (while (and (pair? g) (< count 50))  ; Show first 50
          (let ((binding (car g)))
            (if (pair? binding)
                (let ((name (car binding))
                      (value (cdr binding)))
                  (print (format "  %-20s : " name))
                  ;; Try to identify what it is
                  (cond ((pair? value) (println "pair/list"))
                        ((array? value) (println "array"))
                        ((string? value) (println (format "string: \"%s\"" value)))
                        ((symbol? value) (println (format "symbol: %s" value)))
                        ((= (type-of value) (type-of car)) (println "built-in function"))
                        ((= (type-of value) (type-of (lambda (x) x))) (println "lambda"))
                        (else (println (format "type: %s" (type-of value)))))))
            (set count (+ count 1))
            (set g (cdr g))))
        
        (if (pair? g)
            (println (format "\n... and %d more entries" (length g))))))
    (println "*globals* not found"))

(println "\n2. Checking for environment access functions:")

(define-function check-and-show (name)
  (if (defined? name)
      (let ((val (eval name)))
        (println (format "  %-20s : %s (type: %s)" name val (type-of val))))
      (println (format "  %-20s : not defined" name))))

(check-and-show 'environment)
(check-and-show 'the-environment)
(check-and-show 'global-environment)
(check-and-show '*environment*)
(check-and-show 'current-environment)

(println "\n3. Checking type system:")
(println (format "  type-of car     : %s" (type-of car)))
(println (format "  type-of cons    : %s" (type-of cons)))
(println (format "  type-of lambda  : %s" (type-of (lambda (x) x))))
(println (format "  type-of 42      : %s" (type-of 42)))
(println (format "  type-of \"str\"   : %s" (type-of "string")))

(println "\n4. Looking for extern-related functions:")

;; Check if we can find extern in the environment
(define-function find-in-globals (name)
  (let ((g *globals*))
    (while (and (pair? g) (not (= name (car (car g)))))
      (set g (cdr g)))
    (if (pair? g)
        (cdr (car g))
        ())))

(if (defined? '*globals*)
    (let ()
      (println "\nSearching for 'extern' in globals...")
      (let ((extern-val (find-in-globals 'extern)))
        (if extern-val
            (println (format "Found extern: %s (type: %s)" extern-val (type-of extern-val)))
            (println "extern not found in globals")))
      
      (println "\nSearching for 'system' in globals...")
      (let ((system-val (find-in-globals 'system)))
        (if system-val
            (println (format "Found system: %s (type: %s)" system-val (type-of system-val)))
            (println "system not found in globals")))
      
      (println "\nSearching for 'dlopen' in globals...")
      (let ((dlopen-val (find-in-globals 'dlopen)))
        (if dlopen-val
            (println (format "Found dlopen: %s (type: %s)" dlopen-val (type-of dlopen-val)))
            (println "dlopen not found in globals")))))

(println "\n5. Metacircular inspection:")
(println "Since Maru is metacircular, we should be able to:")
(println "  - Access the evaluator's data structures")
(println "  - Modify the evaluation process")
(println "  - Define new special forms")
(println "  - Extend the language from within")

;; Try to find evaluation-related functions
(println "\n6. Looking for eval machinery:")
(define-function check-eval-func (name)
  (if (defined? name)
      (println (format "  %-20s : defined" name))
      (println (format "  %-20s : not defined" name))))

(check-eval-func 'eval)
(check-eval-func 'apply)
(check-eval-func 'eval-list)
(check-eval-func 'eval-apply)
(check-eval-func 'make-closure)
(check-eval-func 'make-environment)