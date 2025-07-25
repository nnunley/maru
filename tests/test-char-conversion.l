;;; Test character conversion functions

(println "Testing character conversion...")

(let ((str "env.x")
      (pos 0))
  (println "String: " str)
  (println "Character at pos 0: " (string-at str pos))
  (println "Trying string function: " (string (string-at str pos)))
  (println "Trying to make string with char: ")
  
  ;; Try different approaches
  (let ((ch (string-at str pos)))
    (println "Character code: " ch)
    
    ;; Check if we can make a single-character string
    (println "Attempting string creation...")
    
    ;; Try to use buffer or other method
    (println "Available functions test complete")))