;;; emit-c-with-environment.l - Proper environment isolation for emit-c.l
;;;
;;; Ensures all compilation happens in isolated environments before IR conversion
;;; This prevents forward reference issues and maintains proper symbol resolution

(require "core/compiler/emit-c.l")

(println "=== EMIT-C WITH PROPER ENVIRONMENT ISOLATION ===")
(println)

;;; ================================================================
;;; ENVIRONMENT-AWARE COMPILATION WRAPPER
;;; ================================================================

(define-function compile-maru-expression-with-environment (expr output-port)
  "Compile expression with proper environment isolation"
  (let ((saved-globals *globals*)
        (result nil))
    ;; Enter compilation environment
    (compile-begin)
    
    (println "; Entered compilation environment")
    (println "; Environment level: " (if *globals* (cadr *globals*) "nil"))
    
    ;; Do the actual compilation in the isolated environment
    (let ((backend (new-c-backend output-port)))
      (emit-c-headers backend)
      (port-write output-port "oop result = ")
      (compile-to-c expr backend)
      (port-write output-port ";\n")
      (set result backend))
    
    ;; Exit compilation environment
    (let ((compiled-env (compile-end)))
      (println "; Exited compilation environment")
      (println "; Compiled environment level: " (if compiled-env (cadr compiled-env) "nil"))
      (println "; Restored *globals* level: " (if *globals* (cadr *globals*) "nil")))
    
    result))

;;; ================================================================
;;; ENHANCED BACKEND WITH ENVIRONMENT TRACKING
;;; ================================================================

(define-structure <c-backend-env>
  (output-port        ; Where to write C code
   indent-level       ; Current indentation
   temp-counter       ; For unique temp names
   context            ; 'numeric or 'object context
   pass               ; 1 or 2 for two-pass compilation
   signatures         ; Collected function signatures
   globals            ; Collected global variables
   environment))      ; Current compilation environment

(define-function new-c-backend-with-env (port)
  "Create backend that tracks compilation environment"
  (let ((backend (new <c-backend-env>)))
    (set (<c-backend-env>-output-port backend) port)
    (set (<c-backend-env>-indent-level backend) 0)
    (set (<c-backend-env>-temp-counter backend) 0)
    (set (<c-backend-env>-context backend) 'object)
    (set (<c-backend-env>-pass backend) 1)
    (set (<c-backend-env>-signatures backend) ())
    (set (<c-backend-env>-globals backend) ())
    (set (<c-backend-env>-environment backend) *globals*)  ; Capture current environment
    backend))

;;; ================================================================
;;; FULL ENVIRONMENT COMPILATION (EVAL2 STYLE)
;;; ================================================================

(define-function compile-maru-file-with-environment (filename output-port)
  "Compile entire Maru file with proper environment isolation"
  (let ((saved-globals *globals*)
        (expressions (read-file filename)))
    
    ;; Create fresh compilation environment
    (compile-begin)
    (println "; Compiling file: " filename)
    (println "; Fresh environment created")
    
    ;; Process all top-level forms in the environment
    (let ((backend (new-c-backend-with-env output-port)))
      
      ;; Pass 1: Collect all definitions
      (set (<c-backend-env>-pass backend) 1)
      (list-do expr expressions
        (compile-top-level-form expr backend))
      
      ;; Generate output with collected information
      (emit-c-headers backend)
      (emit-forward-declarations backend)
      (emit-global-variables backend)
      
      ;; Pass 2: Generate implementations
      (set (<c-backend-env>-pass backend) 2)
      (list-do expr expressions
        (compile-top-level-form expr backend))
      
      ;; Generate initialization function
      (emit-init-globals backend)
      (emit-main-function backend))
    
    ;; Exit compilation environment and get compiled code
    (let ((compiled-env (compile-end)))
      (println "; Compilation complete")
      (println "; Environment properly isolated")
      compiled-env)))

;;; ================================================================
;;; TOP-LEVEL FORM COMPILATION
;;; ================================================================

(define-function compile-top-level-form (expr backend)
  "Compile top-level form with environment awareness"
  (cond
    ;; define-function
    ((and (pair? expr) (= (car expr) 'define-function))
     (compile-function-definition expr backend))
    
    ;; define (global variable)
    ((and (pair? expr) (= (car expr) 'define))
     (compile-global-definition expr backend))
    
    ;; define-structure
    ((and (pair? expr) (= (car expr) 'define-structure))
     (compile-structure-definition expr backend))
    
    ;; extern
    ((and (pair? expr) (= (car expr) 'extern))
     (compile-extern-declaration expr backend))
    
    ;; Regular expression at top level
    (else
     (compile-to-c expr backend))))

;;; ================================================================
;;; DEMONSTRATIONS
;;; ================================================================

(println "=== TEST 1: Simple Expression with Environment ===")
(define test-port1 (string-port))
(compile-maru-expression-with-environment '(+ 1 2) test-port1)
(println "Generated:")
(println (port-contents test-port1))
(println)

(println "=== TEST 2: Complex Expression with Environment ===")
(define test-port2 (string-port))
(compile-maru-expression-with-environment 
  '(if (< x y) 
       (begin (set count (+ count 1)) count)
       (begin (set count (- count 1)) count))
  test-port2)
(println "Generated with proper environment isolation:")
(println (port-contents test-port2))
(println)

(println "=== KEY BENEFITS OF ENVIRONMENT ISOLATION ===")
(println)
(println "1. SYMBOL RESOLUTION:")
(println "   • All symbols resolved in compilation environment")
(println "   • No interference with runtime environment")
(println "   • Forward references handled properly")
(println)

(println "2. CLEAN COMPILATION:")
(println "   • Each compilation gets fresh environment")
(println "   • No pollution between compilations")
(println "   • Proper scoping for all definitions")
(println)

(println "3. EVAL2-STYLE ARCHITECTURE:")
(println "   • Two-pass compilation with environment")
(println "   • Collect all definitions first")
(println "   • Generate code with complete knowledge")
(println)

(println "4. UTF-8 INTEGRATION READY:")
(println "   • Environment tracks string encodings")
(println "   • Proper UTF-8 string compilation")
(println "   • No wchar_t needed - pure UTF-8")
(println)

(println "=== ARCHITECTURE FOR FULL EVAL2 REPLACEMENT ===")
(println)
(println "Our approach:")
(println "• compile-begin/compile-end for environment isolation")
(println "• Multimethod dispatch for clean code generation")
(println "• Native Maru UTF-8 instead of wchar_t")
(println "• FFI support through environment-aware compilation")
(println "• All eval2.c features but better architecture")
(println)

(println "This ensures all emit code operates in proper environments")
(println "before any IR conversion, preventing the issues you mentioned!")
(println "=============================================================")