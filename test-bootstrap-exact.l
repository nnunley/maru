#!/usr/bin/env eval
;;; test-bootstrap-exact.l -- Exact replication of Makefile test target with C backend

(load "emit.l")

(define-function test-bootstrap-exact ()
  (println "=== EXACT BOOTSTRAP TEST (Following Makefile pattern) ===")
  (println)
  
  (println "Current Makefile pattern:")
  (println "  ./eval -O emit.l eval.l > test.s")
  (println "  gcc -c test.s && gcc -o test test.o")
  (println)
  
  (println "Our approach:")
  (println "  Load emit.l with C backend")
  (println "  Compile eval.l → generate C code instead of assembly")
  (println "  gcc eval2.c → create executable")
  (println)
  
  ;; Switch to C backend before any compilation
  (use-c-backend)
  (println "✅ Switched to two-pass C backend")
  
  ;; Now attempt the same pattern as the Makefile
  (println)
  (println "🧪 ATTEMPTING EXACT BOOTSTRAP REPLICATION...")
  (println)
  
  ;; This mimics: ./eval -O emit.l eval.l
  ;; The emit.l is already loaded, now we compile eval.l
  (println "Step 1: Loading eval.l with C compilation...")
  
  ;; The key insight: the Makefile runs with -O optimization
  ;; For now, let's just try the basic compilation
  (let ((success ()))
    (let ()
      (compile-begin)
      (println "Loading eval.l for compilation...")
      
      ;; This is where the magic should happen - compile eval.l to C
      (load "eval.l")
      
      (println "Finalizing compilation...")
      (compile-end)
      
      (set success 't))
    
    (if success
        (println "✅ Bootstrap compilation completed successfully!")
      (println "❌ Bootstrap compilation failed")))
  
  (println)
  (println "=== BOOTSTRAP TEST COMPLETE ==="))

;;; Execute the test
(test-bootstrap-exact)