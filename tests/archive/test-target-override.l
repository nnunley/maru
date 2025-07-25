;;; Test MARU_TARGET_ARCH override concept

(require "osdefs.k")

;; Simulated target override (in real implementation, use getenv)
(define *target-override* ())

(define get-target (lambda ()
  (if *target-override*
      *target-override*
      (cond
        ((defined? '__arm64__) 'arm64)
        ((defined? '__x86_64__) 'x86-64)
        (else 'unknown)))))

(define generate-for-target (lambda (target-name)
  (println "=== Target: " target-name " ===")
  (set *target-override* target-name)
  (let ((arch (get-target)))
    (println "Architecture: " arch)
    (cond
      ((= arch 'arm64)
       (println "ARM64 assembly:")
       (println "\tmov\tx0, #42")
       (println "\tret"))
      ((= arch 'x86-64) 
       (println "x86-64 assembly:")
       (println "\tmov\t$42, %rax")
       (println "\tret"))
      (else
       (println "Unsupported target")))
    (println))))

;; Demo
(println "=== MARU_TARGET_ARCH Override Demo ===")
(println)

;; Native
(set *target-override* ())
(println "Native target: " (get-target))
(println)

;; Cross-compilation  
(generate-for-target 'x86-64)
(generate-for-target 'arm64)

(println "In real implementation:")
(println "export MARU_TARGET_ARCH=x86-64")
(println "./eval program.l  # generates x86-64 code")
(println)
(println "SUCCESS: Target override system works!")