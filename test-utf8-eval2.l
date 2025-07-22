;; Comprehensive UTF-8 Test Suite for eval2-utf8
;; Tests Unicode support across different languages and features

(println "=== UTF-8 Comprehensive Test Suite ===")

;; Test 1: Basic ASCII (should work in both versions)
(println "\n1. ASCII Test:")
(let ((ascii-string "Hello World"))
  (println "  String: " ascii-string)
  (println "  Length: " (string-length ascii-string)))

;; Test 2: Latin Extended characters
(println "\n2. Latin Extended Test:")
(let ((latin-string "Café naïve résumé"))
  (println "  String: " latin-string)
  (println "  Length: " (string-length latin-string)))

;; Test 3: Chinese characters
(println "\n3. Chinese Characters Test:")
(let ((chinese-string "你好世界"))
  (println "  String: " chinese-string)
  (println "  Length: " (string-length chinese-string)))

;; Test 4: Japanese characters (Hiragana/Katakana/Kanji)
(println "\n4. Japanese Characters Test:")
(let ((japanese-string "こんにちは カタカナ 漢字"))
  (println "  String: " japanese-string)
  (println "  Length: " (string-length japanese-string)))

;; Test 5: Arabic characters (RTL)
(println "\n5. Arabic Characters Test:")
(let ((arabic-string "مرحبا بالعالم"))
  (println "  String: " arabic-string)
  (println "  Length: " (string-length arabic-string)))

;; Test 6: Emoji and symbols
(println "\n6. Emoji and Symbols Test:")
(let ((emoji-string "👋🌍💻🚀"))
  (println "  String: " emoji-string)
  (println "  Length: " (string-length emoji-string)))

;; Test 7: Mixed multilingual content
(println "\n7. Mixed Multilingual Test:")
(let ((mixed-string "Hello 你好 こんにちは مرحبا 🌍"))
  (println "  String: " mixed-string)
  (println "  Length: " (string-length mixed-string)))

;; Test 8: String operations
(println "\n8. String Operations Test:")
(let ((str1 "Hello") (str2 " 世界"))
  (println "  str1: " str1)
  (println "  str2: " str2)
  (println "  concat: " (concat-string str1 str2)))

;; Test 9: Symbol creation with UTF-8
(println "\n9. UTF-8 Symbol Test:")
(let ((utf8-symbol (intern "测试符号")))
  (println "  Symbol: " utf8-symbol)
  (println "  Symbol?: " (symbol? utf8-symbol)))

;; Test 10: Performance test with UTF-8
(println "\n10. Performance Test:")
(let ((start-time (current-time)))
  (let ((result ()))
    (for (i 0 1000)
      (set result (cons "UTF-8 测试 🚀" result)))
    (println "  Created 1000 UTF-8 strings")
    (println "  Time: " (- (current-time) start-time) " seconds")))