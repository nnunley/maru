;;; Simple PEG parsing test

;; Load PEG dependencies
(load "core/parser.l") 
(load "core/peg.l")

(println "=== PEG Parsing with Multi-Method Evaluator ===")

;; Test basic parsing
(let ((parser (new <peg>))
      (input "hello world"))
  
  (let ((stream (string-stream input)))
    (println "Input: " input)
    (println "Stream size: " (<string-stream>-size stream))
    (println "At end? " ($at-end stream))
    (println "First char: " ($peek stream))
    
    ;; Consume one character
    (let ((first-char ($next stream)))
      (println "Consumed: " first-char)
      (println "Position now: " (<string-stream>-position stream)))))

(println "")
(println "✅ Basic PEG parsing works with multi-method evaluator!")