;;; debug-text-parser.l - Debug text parser behavior

(require "text-parser.l")

(define-function debug-parser-state (parser msg)
  "Debug parser state"
  (println msg)
  (println "  Position: " (<text-parser>-position parser))
  (println "  Length: " (string-length (<text-parser>-string parser)))
  (println "  Input: '" (<text-parser>-string parser) "'")
  (when (< (<text-parser>-position parser) (string-length (<text-parser>-string parser)))
    (println "  Current char: " (string-at (<text-parser>-string parser) (<text-parser>-position parser))
             " ('" (string (string-at parser.input parser.position)) "')")))

(define-function test-detailed-parsing ()
  "Test parser behavior in detail"
  (println "=== Detailed Parser Test ===")
  
  (let ((parser (text-parser-for-on <text-parser> "%rax")))
    (debug-parser-state parser "Initial state:")
    
    ;; Try to match '%'
    (println "\nTrying to match '%'...")
    (if (text-parser-match-char parser 37) ; '%' = 37
        (println "  SUCCESS: Matched '%'")
      (println "  FAILED: Could not match '%'"))
    (debug-parser-state parser "After % match:")
    
    ;; Try to match 'r'
    (println "\nTrying to match 'r'...")
    (if (text-parser-match-char parser 114) ; 'r' = 114
        (println "  SUCCESS: Matched 'r'")
      (println "  FAILED: Could not match 'r'"))
    (debug-parser-state parser "After r match:")
    
    ;; Try to match full string directly
    (println "\nTrying fresh parser with full string match...")
    (let ((parser2 (text-parser-for-on <text-parser> "%rax")))
      (debug-parser-state parser2 "Fresh parser:")
      (if (text-parser-match-string parser2 "%rax" 4)
          (println "  SUCCESS: Matched full string")
        (println "  FAILED: Could not match full string"))
      (debug-parser-state parser2 "After string match:"))))

(test-detailed-parsing)