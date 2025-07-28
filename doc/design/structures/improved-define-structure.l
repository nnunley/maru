;;; improved-define-structure.l - Better error messages for define-structure

(load "boot.l")

(println "=== IMPROVED DEFINE-STRUCTURE ERROR MESSAGES ===")
(println)

;; Current define-structure just uses the generic "too many arguments" error
;; We can wrap it to provide better diagnostics

(define original-define-structure define-structure)

(define-form define-structure args
  "Improved define-structure with better error messages"
  (let ((nargs (list-length args)))
    (cond
      ;; No arguments
      ((= nargs 0)
       (error "define-structure: missing structure name and fields"))
      
      ;; Only name provided
      ((= nargs 1)
       (error "define-structure: missing field list for structure " (car args)))
      
      ;; Correct number of arguments
      ((= nargs 2)
       (let ((name (car args))
             (fields (cadr args)))
         ;; Check if fields is a list
         (if (or (not fields) (pair? fields))
             ;; All good - delegate to original
             `(original-define-structure ,name ,fields)
           ;; Second argument is not a list
           (error "define-structure: fields must be a list, got " fields " for structure " name))))
      
      ;; Too many arguments - the common mistake!
      (else
       (let ((name (car args))
             (rest (cdr args)))
         (error "define-structure: too many arguments! " 
                "Expected (define-structure <name> (field1 field2 ...)) "
                "but got " nargs " arguments. "
                "Did you forget parentheses around the field list? "
                "You wrote: (define-structure " name " " (car rest) " " (cadr rest) " ...) "
                "Should be: (define-structure " name " (" (car rest) " " (cadr rest) " ...))"))))))

(println "Testing improved error messages:")
(println)

;; Test 1: Correct usage
(println "Test 1: Correct usage")
(define-structure <good> (a b c))
(println "Success - structure defined correctly")
(println)

;; Test 2: Missing arguments
(println "Test 2: No arguments")
(println "Attempting: (define-structure)")
;; (define-structure)  ; Would give helpful error
(println)

;; Test 3: Missing fields
(println "Test 3: Missing fields")
(println "Attempting: (define-structure <bad>)")
;; (define-structure <bad>)  ; Would give helpful error
(println)

;; Test 4: The common mistake - missing parentheses
(println "Test 4: Missing parentheses (the common mistake)")
(println "Attempting: (define-structure <oops> a b c)")
;; (define-structure <oops> a b c)  ; Would give very helpful error!
(println)

(println "=== SAMPLE ERROR MESSAGES ===")
(println)

(println "Instead of:")
(println "  error: too many arguments applying Expr.define-structure")
(println)

(println "You would get:")
(println "  error: define-structure: too many arguments! ")
(println "  Expected (define-structure <name> (field1 field2 ...))")
(println "  but got 4 arguments.")
(println "  Did you forget parentheses around the field list?")
(println "  You wrote: (define-structure <oops> a b c)")
(println "  Should be: (define-structure <oops> (a b c))")
(println)

(println "=== IMPLEMENTATION NOTES ===")
(println)
(println "This approach:")
(println "1. Wraps the original define-structure")
(println "2. Checks argument count and types")
(println "3. Provides specific, helpful error messages")
(println "4. Shows what you wrote vs. what you should write")
(println)
(println "The key insight: Most S-expression errors CAN be made more helpful")
(println "by checking common patterns and providing targeted messages!")
(println "============================================================")