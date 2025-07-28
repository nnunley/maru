;; Bootstrap verification function for generation system
;; Usage: ./eval boot.l tools/verify-bootstrap.l

(define-function verify-bootstrap ()
  (println "🔍 Verifying bootstrap capability...")
  (println "📋 Generation: " *maru-generation*)
  (println "📋 Version: " *maru-version*)
  
  ;; Test that we can load emit.l
  (let ((emit-loaded #f))
    (println "📦 Testing emit.l loading...")
    (if (catch (lambda () 
                 (load "core/compiler/emit.l")
                 (set emit-loaded #t)
                 #t)
               (lambda (err) 
                 (println "❌ emit.l failed to load: " err)
                 #f))
        (println "✅ emit.l loaded successfully")
        (println "❌ emit.l failed to load"))
    
    ;; If emit loaded, test code generation
    (if emit-loaded
        (let ((code-gen-works #f))
          (println "🏗️  Testing code generation...")
          (if (catch (lambda ()
                       ;; Try to compile a simple expression
                       (let ((result (emit-c-expression '(+ 1 2))))
                         (set code-gen-works (and result (> (string-length result) 0)))
                         code-gen-works))
                     (lambda (err)
                       (println "❌ Code generation failed: " err)
                       #f))
              (println "✅ Code generation works")
              (println "❌ Code generation failed")))
    
    emit-loaded))

;; Test function for simple bootstrap verification
(define-function simple-bootstrap-test ()
  (println "🧪 Running simple bootstrap test...")
  (println "📋 Can access generation info: " 
           (and (defined? '*maru-generation*) 
                (defined? '*maru-version*)))
  (println "📋 Current generation: " *maru-generation*)
  (println "📋 Current version: " *maru-version*)
  #t)

;; Run verification if loaded directly
(if (defined? '*maru-generation*)
    (verify-bootstrap)
    (println "⚠️  Generation tracking not available - run from full system"))

;; Always run simple test
(simple-bootstrap-test)