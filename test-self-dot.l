;;; Test how self.field syntax currently works

(println "Testing self.field syntax...")

(define-structure <test-class> (x y))

(define-method test-method <test-class> ()
  (println "In method, self.x = " self.x)
  (println "In method, self.y = " self.y)
  (set self.x (* self.x 2))
  (println "After doubling, self.x = " self.x))

(let ((obj (new <test-class>)))
  (set (<test-class>-x obj) 10)
  (set (<test-class>-y obj) 20)
  
  (println "Before method call:")
  (println "  x = " (<test-class>-x obj))
  (println "  y = " (<test-class>-y obj))
  
  (test-method obj)
  
  (println "After method call:")
  (println "  x = " (<test-class>-x obj))
  (println "  y = " (<test-class>-y obj)))

(println "Test complete")