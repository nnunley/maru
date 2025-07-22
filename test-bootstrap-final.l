#!/usr/bin/env eval
;;; test-bootstrap-final.l -- Final bootstrap assessment

(load "emit.l")

(define-function final-bootstrap-assessment ()
  (println "=== FINAL BOOTSTRAP ASSESSMENT ===")
  (println)
  
  ;; Test our two-pass system with eval.l following Makefile pattern
  (println "Following the Makefile pattern:")
  (println "  Current: ./eval emit.l eval.l > eval2.c  (generates assembly)")
  (println "  Our goal: ./eval emit.l eval.l > eval2.c (generates C)")
  (println)
  
  ;; Switch to C backend
  (use-c-backend)
  (println "✅ Switched to two-pass C backend")
  
  ;; The key test: Can we replicate the Makefile bootstrap?
  (println)
  (println "🧪 CRITICAL TEST: Attempting eval.l compilation...")
  (println)
  
  ;; Try to load eval.l through compile-begin/compile-end
  (compile-begin)
  
  (println "Loading eval.l with two-pass C generation...")
  (load "eval.l")
  
  (println "Finalizing compilation...")
  (compile-end)
  
  't)

;;; Execute the test
(final-bootstrap-assessment)