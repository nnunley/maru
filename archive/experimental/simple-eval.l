;;; simple-eval.l - A minimal evaluator for threaded compilation

;; Simple evaluator that handles basic expressions
(define-function simple-eval (expr)
  "Evaluate simple expressions"
  (cond
    ;; Numbers evaluate to themselves
    ((long? expr) expr)
    
    ;; Simple arithmetic
    ((and (pair? expr) (= (car expr) '+))
     (+ (simple-eval (cadr expr)) (simple-eval (caddr expr))))
    
    ((and (pair? expr) (= (car expr) '-))
     (- (simple-eval (cadr expr)) (simple-eval (caddr expr))))
    
    ((and (pair? expr) (= (car expr) '*))
     (* (simple-eval (cadr expr)) (simple-eval (caddr expr))))
    
    ;; Simple conditionals
    ((and (pair? expr) (= (car expr) 'if))
     (if (simple-eval (cadr expr))
         (simple-eval (caddr expr))
         (if (cdddr expr) (simple-eval (cadddr expr)) ())))
    
    ;; Default case
    (else 0)))

;; Test the simple evaluator
(define-function test-simple-eval ()
  "Test the simple evaluator"
  (println "Testing simple evaluator:")
  (println "(+ 1 2) = " (simple-eval '(+ 1 2)))
  (println "(* 6 7) = " (simple-eval '(* 6 7)))
  (println "(if 1 42 0) = " (simple-eval '(if 1 42 0))))

;; Main expression to compile
(simple-eval '(+ 10 32))