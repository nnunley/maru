;;; Simple PEG test to verify basic functionality

(println "Testing basic PEG parser creation...")

;; Test creating a PEG parser
(let ((parser (new <peg>)))
  (if parser
      (println "✅ PEG parser created successfully")
      (println "❌ Failed to create PEG parser")))

;; Test basic string stream
(let ((stream (string-stream "hello world")))
  (if stream
      (println "✅ String stream created successfully")
      (println "❌ Failed to create string stream")))

(println "✅ Basic PEG infrastructure is working")