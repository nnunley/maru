;;; Debug emit issue

(println "Initial emit backend: " *emit-backend*)
(println "Initial C mode: " *c-generation-mode*)

(compile-begin)

(println "After compile-begin emit backend: " *emit-backend*)
(println "After compile-begin C mode: " *c-generation-mode*)

(use-c-threaded-backend)

(println "After use-c-threaded-backend emit backend: " *emit-backend*)
(println "After use-c-threaded-backend C mode: " *c-generation-mode*)

(define test 42)

(compile-end)