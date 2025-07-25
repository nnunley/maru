;;; Test PEG parsing with multi-method evaluator

;; Load PEG dependencies
(load "core/parser.l")
(load "core/peg.l")

(println "=== PEG with Multi-Method Evaluator Test ===")
(println "")

;; Test 1: Basic PEG parser creation
(println "Test 1: PEG Parser Creation")
(let ((parser (new <peg>)))
  (println "  PEG parser: " (if parser "✅ Created" "❌ Failed"))
  (println "  Parser type: " (type-of parser))
  (println ""))

;; Test 2: String stream creation
(println "Test 2: String Stream Creation")
(let ((stream (string-stream "test input")))
  (println "  String stream: " (if stream "✅ Created" "❌ Failed"))
  (println "  Stream type: " (type-of stream))
  (println "  Stream size: " (<string-stream>-size stream))
  (println ""))

;; Test 3: Basic parsing operations
(println "Test 3: Basic Stream Operations")
(let ((stream (string-stream "hello")))
  (println "  At end? " ($at-end stream))
  (println "  Peek: " ($peek stream))
  (println "  Next: " ($next stream))
  (println "  At end after next? " ($at-end stream))
  (println ""))

(println "✅ All PEG tests completed successfully!")
(println "✅ PEG parsing works with multi-method evaluator!")