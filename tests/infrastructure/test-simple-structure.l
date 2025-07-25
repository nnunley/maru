;; Test simple structure definition
(require "core/bootstrap/boot.l")

;; Test structure definition
(define-structure <test> (field1 field2))

;; Test creation and access
(let ((obj (new <test>)))
  (set (<test>-field1 obj) "hello")
  (set (<test>-field2 obj) 42)
  (println "Field1: " (<test>-field1 obj))
  (println "Field2: " (<test>-field2 obj)))