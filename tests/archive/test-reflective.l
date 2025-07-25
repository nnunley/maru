;;; Test the reflective evaluator

(load "reflective-eval.l")

(println "=== Testing Reflective Evaluator ===")
(println "42 =>" (reflective-eval 42))
(println "(+ 20 22) =>" (reflective-eval '(+ 20 22)))
(println "(* 6 7) =>" (reflective-eval '(* 6 7)))
(println "(if 1 42 0) =>" (reflective-eval '(if 1 42 0)))
(println "(quote hello) =>" (reflective-eval '(quote hello)))

;; Self-application test
(println "=== Self-Application Test ===")
(println "Evaluator's self-knowledge-2:" (reflective-eval self-knowledge-2))
(println "Evaluator's self-knowledge-3:" (reflective-eval self-knowledge-3))
(println "Evaluator's self-knowledge-4:" (reflective-eval self-knowledge-4))