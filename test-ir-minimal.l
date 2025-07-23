(println "Starting test...")

(define-structure <test> (value))

(println "Structure defined")

(let ((t (new <test>)))
  (set (<test>-value t) 42)
  (println "Test value: " (<test>-value t)))

(println "Done")