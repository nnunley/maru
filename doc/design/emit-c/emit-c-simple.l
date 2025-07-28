;;; emit-c-simple.l - Simplified C backend without port dependencies

;;; ================================================================
;;; SIMPLE C BACKEND
;;; ================================================================

(define-function emit-c-expression (expr)
  "Compile a Maru expression to C code string"
  (cond
    ;; Numbers
    ((long? expr) (long->string expr))
    
    ;; Strings  
    ((string? expr) 
     (concat-string "s_string(\"" (concat-string expr "\")")))
    
    ;; Symbols
    ((symbol? expr)
     (if (= expr 'nil) 
         "nil" 
         (symbol->string expr)))
    
    ;; Lists
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ;; Arithmetic - safe runtime calls
         ((= op '+) 
          (concat-string "add("
            (concat-string (emit-c-expression (cadr expr))
              (concat-string ", "
                (concat-string (emit-c-expression (caddr expr)) ")")))))
         
         ;; Subtraction
         ((= op '-)
          (concat-string "subtract("
            (concat-string (emit-c-expression (cadr expr))
              (concat-string ", "
                (concat-string (emit-c-expression (caddr expr)) ")")))))
         
         ;; Multiplication
         ((= op '*)
          (concat-string "multiply("
            (concat-string (emit-c-expression (cadr expr))
              (concat-string ", "
                (concat-string (emit-c-expression (caddr expr)) ")")))))
         
         ;; Comparison - use runtime dispatch for safety
         ((= op '<)
          (concat-string "less_than("
            (concat-string (emit-c-expression (cadr expr))
              (concat-string ", "
                (concat-string (emit-c-expression (caddr expr)) ")")))))
         
         ((= op '>)
          (concat-string "greater_than("
            (concat-string (emit-c-expression (cadr expr))
              (concat-string ", "
                (concat-string (emit-c-expression (caddr expr)) ")")))))
         
         ((= op '=)
          (concat-string "equal("
            (concat-string (emit-c-expression (cadr expr))
              (concat-string ", "
                (concat-string (emit-c-expression (caddr expr)) ")")))))
         
         ;; If expression
         ((= op 'if)
          (concat-string "("
            (concat-string (emit-c-expression (cadr expr))
              (concat-string " ? "
                (concat-string (emit-c-expression (caddr expr))
                  (concat-string " : "
                    (concat-string (emit-c-expression (cadddr expr)) ")")))))))
         
         ;; Function call
         (else
          (concat-string (symbol->string op)
            (concat-string "("
              (concat-string (emit-c-expression (cadr expr)) ")")))))))
    
    ;; Default
    (else "/* unknown */")))

(define-function emit-c-params (params)
  "Generate C parameter list from Maru parameter list"
  (if params
      (if (cdr params)
          (concat-string "oop " 
            (concat-string (symbol->string (car params))
              (concat-string ", " (emit-c-params (cdr params)))))
          (concat-string "oop " (symbol->string (car params))))
      ""))

(define-function emit-c-function (name params body)
  "Compile a Maru function definition to C code"
  (concat-string "static oop "
    (concat-string (symbol->string name)
      (concat-string "("
        (concat-string (emit-c-params params)
          (concat-string ") {\n  return "
            (concat-string (emit-c-expression body)
              ";\n}\n\n")))))))

(define-function cadddr (lst)
  (car (cdr (cdr (cdr lst)))))

(println "Simple C backend loaded!")

;; Test it
(println "Testing expressions:")
(println "(+ 1 2) =>")
(println (emit-c-expression '(+ 1 2)))
(println)

(println "(if (< x y) a b) =>")
(println (emit-c-expression '(if (< x y) a b)))
(println)

(println "Testing function definitions:")
(println "add-one function =>")
(println (emit-c-function 'add-one '(x) '(+ x 1)))

(println "max function =>")
(println (emit-c-function 'max-of-two '(a b) '(if (> a b) a b)))