;;; Test current dotted syntax behavior

(println "Testing current dotted syntax...")

;; Test object access
(define-structure <test-obj> (field1 field2))

(let ((obj (new <test-obj>)))
  (set (<test-obj>-field1 obj) "hello")
  (set (<test-obj>-field2 obj) "world")
  
  (println "Direct access:")
  (println "  field1: " (<test-obj>-field1 obj))
  (println "  field2: " (<test-obj>-field2 obj))
  
  ;; Test if dotted syntax works
  (println "Attempting dotted access:")
  (println "  obj.field1 would be: ")
  ;; This will likely fail since we need to implement it
  ;;(println "  " obj.field1)
  )

;; Test reading dotted symbols
(println "Reading dotted symbols:")
(let ((sym1 (string->symbol "test.field"))
      (sym2 (string->symbol "env.rule")))
  (println "  test.field symbol: " sym1)
  (println "  env.rule symbol: " sym2))

;; Test if dotted symbols parse as single symbols
(println "Symbol names with dots:")
(println "  symbol-name of 'test.field: " (symbol->string 'test.field))

(println "Test complete")