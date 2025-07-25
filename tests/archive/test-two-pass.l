#!/usr/bin/env eval
;;; test-two-pass.l -- Test two-pass C code generation

(load "emit.l")

;;; Test the two-pass C generation system
(define-function test-two-pass ()
  (println "=== Testing Two-Pass C Generation ===")
  (println)
  
  ;; Switch to C backend
  (use-c-backend)
  (println "1. Switched to C backend")
  
  ;; Create a simple test environment with functions
  (let ((env (environment ())))
    ;; Define a simple function: add(x, y) = x + y
    (let ((x (variable 'x 0 env 0))
          (y (variable 'y 0 env 1)))
      (let ((body (list '+ x y)))
        (let ((defn (list 'lambda (list x y) body)))
          (let ((expr (new <expr>)))
            (set (<expr>-defn expr) defn)
            (environment-define env 'add expr)))))
    
    ;; Define main function: main() = 42
    (let ((body (list 42)))
      (let ((defn (list 'lambda () body)))
        (let ((expr (new <expr>)))
          (set (<expr>-defn expr) defn)
          (environment-define env 'main expr))))
    
    ;; Define a constant
    (environment-define env 'test-const 123)
    
    (println "2. Created test environment with:")
    (println "   - add(x, y) function")  
    (println "   - main() function")
    (println "   - test-const constant")
    (println)
    
    (println "3. Generating C code with two-pass system:")
    (println)
    
    ;; Generate the code
    (gen-env env)
    
    (println)
    (println "4. Two-pass generation complete!")
    (println "   Pass 1: Collected function signatures")
    (println "   Pass 2: Generated forward declarations + implementations")
    
    't))

;;; Execute the test
(test-two-pass)