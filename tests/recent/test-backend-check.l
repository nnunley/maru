;; Test backend selection logic

(define-function test-backend-selection ()
  (println "Testing backend selection...")
  (println "Checking platform defines...")
  (println "__arm64__ defined? " (defined? '__arm64__))
  (println "__x86_64__ defined? " (defined? '__x86_64__))
  (println "__i386__ defined? " (defined? '__i386__))
  
  ;; Simulate the logic from compile-end
  (cond
    ((defined? '__arm64__)
     (println "Would select ARM64 backend"))
    ((or (defined? '__x86_64__) (defined? '__i386__))
     (println "Would select ASM backend"))
    (else
     (println "Would select C backend"))))

(test-backend-selection)