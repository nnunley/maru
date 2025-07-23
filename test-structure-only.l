;; Test structure system only
(require "core/bootstrap/boot.l")

(define-structure <test> (field1 field2))

(let ((obj (new <test>)))
  (set (<test>-field1 obj) 42)
  (println "Field1: " (<test>-field1 obj)))