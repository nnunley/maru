;;; Comprehensive UTF-8 test for eval2-utf8

(println "=== UTF-8 Support Test ===")

;; Basic ASCII
(println "ASCII: Hello World")

;; Latin-1 supplement
(println "Latin-1: café résumé naïve")

;; Cyrillic
(println "Cyrillic: Привет мир")

;; Chinese/Japanese/Korean
(println "Chinese: 你好世界")
(println "Japanese: こんにちは世界")
(println "Korean: 안녕하세요 세계")

;; Arabic (RTL)
(println "Arabic: مرحبا بالعالم")

;; Emoji and symbols
(println "Emoji: 🌍🚀💻🎉")
(println "Math: ∑∫∂∇±≤≥≠∞")

;; Test string length with Unicode
(define test-string "Hello🌍")
(println "String: " test-string)

;; Test arithmetic still works
(println "Math still works: " (+ (* 6 7) 2))

;; Test nested expressions
(println "Nested: " (+ (- 10 5) (* 3 4)))

(println "=== Test Complete ===")