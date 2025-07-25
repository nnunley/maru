;;; debug-simple.l - Simple debug test

(require "text-parser.l")

(println "=== Simple Debug Test ===")

;; Test basic text-parser-for-on
(let ((parser (text-parser-for-on <text-parser> "%rax")))
  (println "Created parser for '%rax'")
  (println "Position: " (<text-parser>-position parser))
  (println "String: '" (<text-parser>-string parser) "'")
  (println "Length: " (string-length (<text-parser>-string parser)))
  
  ;; Try to match the string
  (println "\nTrying text-parser-match-string...")
  (if (text-parser-match-string parser "%rax" 4)
      (println "SUCCESS: Matched '%rax'")
    (println "FAILED: Could not match '%rax'"))
  
  (println "Position after: " (<text-parser>-position parser)))

(println "\n=== Simple Debug Complete ===")