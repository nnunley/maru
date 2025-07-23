;;; Test simple function definition

(define-function simple-add (a b)
  "Add two numbers"
  (+ a b))

(println "Function defined, testing...")
(println "simple-add(3, 4) =" (simple-add 3 4))