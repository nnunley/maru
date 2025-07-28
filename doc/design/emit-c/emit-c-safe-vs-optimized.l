;;; emit-c-safe-vs-optimized.l - Comparison of safe vs optimized C generation

(load "boot.l")

;;; ================================================================
;;; SAFE RUNTIME DISPATCH VERSION
;;; ================================================================

(define-function emit-c-safe (expr)
  "Generate safe C code using runtime dispatch"
  (cond
    ((long? expr) (long->string expr))
    ((symbol? expr) (if (= expr 'nil) "nil" (symbol->string expr)))
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ;; Safe arithmetic - works with any oop types
         ((= op '+) 
          (concat-string "add("
            (concat-string (emit-c-safe (cadr expr))
              (concat-string ", " 
                (concat-string (emit-c-safe (caddr expr)) ")")))))
         
         ;; Safe comparison - type checks and dispatches
         ((= op '>)
          (concat-string "greater_than("
            (concat-string (emit-c-safe (cadr expr))
              (concat-string ", "
                (concat-string (emit-c-safe (caddr expr)) ")")))))
         
         ;; Conditional
         ((= op 'if)
          (concat-string "("
            (concat-string (emit-c-safe (cadr expr))
              (concat-string " ? "
                (concat-string (emit-c-safe (caddr expr))
                  (concat-string " : "
                    (concat-string (emit-c-safe (cadddr expr)) ")")))))))))
    (else "nil")))

;;; ================================================================
;;; OPTIMIZED VERSION (for known numeric types)
;;; ================================================================

(define-function emit-c-optimized (expr)
  "Generate optimized C code assuming numeric types"
  (cond
    ((long? expr) (long->string expr))
    ((symbol? expr) (if (= expr 'nil) "nil" (symbol->string expr)))
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ;; Direct arithmetic - fast but assumes Long types
         ((= op '+) 
          (concat-string "LONG("
            (concat-string (emit-c-optimized (cadr expr))
              (concat-string " + "
                (concat-string (emit-c-optimized (caddr expr)) ")")))))
         
         ;; Direct comparison - assumes Long types  
         ((= op '>)
          (concat-string "("
            (concat-string (emit-c-optimized (cadr expr))
              (concat-string " > "
                (concat-string (emit-c-optimized (caddr expr))
                  " ? s_true : nil)")))))
         
         ;; Conditional
         ((= op 'if)
          (concat-string "("
            (concat-string (emit-c-optimized (cadr expr))
              (concat-string " ? "
                (concat-string (emit-c-optimized (caddr expr))
                  (concat-string " : "
                    (concat-string (emit-c-optimized (cadddr expr)) ")")))))))))
    (else "nil")))

(define-function cadddr (lst)
  (car (cdr (cdr (cdr lst)))))

;;; ================================================================
;;; COMPARISON TESTS
;;; ================================================================

(println "=== SAFE vs OPTIMIZED C GENERATION ===")
(println)

(let ((test-expr '(if (> a b) (+ a 1) b)))
  (println "Maru expression: " test-expr)
  (println)
  
  (println "SAFE VERSION (runtime dispatch):")
  (println (emit-c-safe test-expr))
  (println "- Works with any oop types")
  (println "- Type checking at runtime") 
  (println "- Slightly slower due to function calls")
  (println)
  
  (println "OPTIMIZED VERSION (direct operations):")
  (println (emit-c-optimized test-expr))
  (println "- Assumes numeric Long types")
  (println "- Fast direct C operations")
  (println "- UNSAFE with non-numeric types!")
  (println))

(println "=== RUNTIME FUNCTION SIGNATURES NEEDED ===")
(println)
(println "For safe version, the runtime needs:")
(println "  oop add(oop a, oop b);        // Type-safe addition")
(println "  oop subtract(oop a, oop b);   // Type-safe subtraction") 
(println "  oop multiply(oop a, oop b);   // Type-safe multiplication")
(println "  oop greater_than(oop a, oop b); // Type-safe comparison")
(println "  oop less_than(oop a, oop b);    // Type-safe comparison")
(println "  oop equal(oop a, oop b);        // Type-safe equality")
(println)

(println "These functions would:")
(println "1. Check types of both operands")  
(println "2. Extract numeric values if both are numbers")
(println "3. Perform operation and return LONG() result")
(println "4. Handle type errors (string + number, etc.)")
(println "5. Support method dispatch for custom types")
(println)