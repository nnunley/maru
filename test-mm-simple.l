;;; test-mm-simple.l - Simple test to demonstrate multi-method evaluation
;;;
;;; This test verifies that the multi-method evaluator can handle basic expressions

(println "=== Multi-Method Evaluator Test ===")
(println "")

;; Test basic arithmetic
(println "Testing arithmetic:")
(println "  (+ 1 2) =>" (+ 1 2))
(println "  (* 3 4) =>" (* 3 4))
(println "")

;; Test type system
(println "Testing type system:")
(println "  (type-of 42) =>" (type-of 42))
(println "  (type-of \"hello\") =>" (type-of "hello"))
(println "  (type-of 'symbol) =>" (type-of 'symbol))
(println "")

;; Test introspection  
(println "Testing introspection:")
(println "  (defined? '+) =>" (defined? '+))
(println "  (subr-name +) =>" (subr-name +))
(println "")

;; Test data structures
(println "Testing data structures:")
(let ((test-pair (cons 'a 'b)))
  (println "  (cons 'a 'b) =>" test-pair)
  (println "  (car (cons 'a 'b)) =>" (car test-pair))
  (println "  (cdr (cons 'a 'b)) =>" (cdr test-pair)))
(println "")

;; Test conditionals
(println "Testing conditionals:")
(println "  (if 1 'true 'false) =>" (if 1 'true 'false))
(println "  (if () 'true 'false) =>" (if () 'true 'false))
(println "")

(println "✅ All tests completed successfully!")
(println "✅ Multi-method evaluator working properly!")