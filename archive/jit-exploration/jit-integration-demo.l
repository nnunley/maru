;;; jit-integration-demo.l - Demonstrate JIT integration with Maru
;;;
;;; This shows how the JIT would integrate with Maru's existing
;;; eval.l and multimethod system

;;; Integration with Maru's environment system

(define-class <jit-compiled-function> <expr>
  (native-pointer    ; Function pointer from dlopen
   library-handle    ; dlopen handle
   source-form))     ; Original source for debugging

(define-method do-eval <jit-compiled-function> (env)
  ;; When evaluated, call the native function
  (call-compiled-function (<jit-compiled-function>-native-pointer self)))

;;; Multimethod for JIT compilation based on form type

(define-multimethod jit-compile (form arch))

;; Compile a constant
(define-method jit-compile <long> <architecture> ()
  (let* ((value self)
         (name (concat-string "const_" (number->string value)))
         (dylib (compile-constant-function name value))
         (handle (dlopen-prim dylib))
         (fn-ptr (dlsym-prim handle "_maru_compiled_fn")))
    (new <jit-compiled-function> () () () fn-ptr handle self)))

;; Compile a simple arithmetic expression
(define-method jit-compile <pair> <architecture> ()
  (let ((op (car self)))
    (case op
      ((+) (jit-compile-addition self (current-architecture)))
      ((-) (jit-compile-subtraction self (current-architecture)))
      (else (error "Cannot JIT compile this operation yet")))))

;;; Environment-based compilation (as discussed in design doc)

(define-class <jit-environment> <environment>
  (compilation-unit   ; All functions to compile together
   compilation-state  ; pending, compiling, compiled
   library-handle))   ; dlopen handle when compiled

(define-method compile-environment <jit-environment> <architecture> ()
  "Compile all functions in environment to native code"
  (let ((functions (filter function? (map cdr (<environment>-bindings self)))))
    (println (concat-string "Compiling " (number->string (length functions)) 
                            " functions in environment"))
    
    ;; Generate assembly for all functions
    (let ((asm-file (concat-string *jit-temp-dir* "/env_" 
                                   (number->string (object-id self)) ".s")))
      (with-output-to-file asm-file
        (lambda ()
          (for-each functions
            (lambda (fn)
              (emit-function-assembly fn (current-architecture) 
                                      (current-output-port))))))
      
      ;; Compile and load
      (let ((dylib (assemble-and-link asm-file)))
        (set (<jit-environment>-library-handle self) (dlopen-prim dylib))
        (set (<jit-environment>-compilation-state self) 'compiled)))))

;;; Smart compilation triggers

(define *jit-profile* (make-table))  ; Track function call counts

(define-function maybe-jit-compile (fn)
  "Check if function should be JIT compiled"
  (let ((count (or (table-at *jit-profile* fn) 0)))
    (set-table-at *jit-profile* fn (+ count 1))
    (when (and (>= count 100)  ; Hot function threshold
               (not (jit-compiled? fn)))
      (println (concat-string "JIT compiling hot function: " (function-name fn)))
      (jit-compile-function fn))))

;;; Example usage

(define-function demo-jit-integration ()
  (println "=== JIT Integration Demo ===\n")
  
  ;; 1. Simple constant compilation
  (println "1. Compiling constant:")
  (let ((compiled (jit-compile 42 (current-architecture))))
    (println (concat-string "   Result: " 
                            (number->string (do-eval compiled ())))))
  
  ;; 2. Environment-based compilation
  (println "\n2. Environment compilation:")
  (let ((math-env (new <jit-environment>)))
    ;; Add some functions
    (env-define math-env 'square (lambda (x) (* x x)))
    (env-define math-env 'cube (lambda (x) (* x x x)))
    (env-define math-env 'factorial 
                (lambda (n) (if (<= n 1) 1 (* n (factorial (- n 1))))))
    
    ;; Compile the environment
    (compile-environment math-env (current-architecture))
    (println "   Environment compiled successfully"))
  
  ;; 3. Profiling-based compilation
  (println "\n3. Profile-based JIT:")
  (define (hot-function x)
    (+ (* x x) (* 2 x) 1))
  
  ;; Simulate many calls
  (for (i 0 150)
    (maybe-jit-compile hot-function)
    (hot-function i))
  
  (println "   Hot function should now be JIT compiled")
  
  (println "\nDemo complete!"))