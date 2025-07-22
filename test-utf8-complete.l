;; Test Complete UTF-8 System
;; Demonstrates full Unicode support with collation

(println "=== Complete UTF-8 System Test ===")
(println)

;; Test data in various languages
(define test-strings
  '(;; English
    ("Hello" "hello" "HELLO")
    ;; French
    ("café" "cafe" "Café")
    ("élève" "eleve" "École")
    ;; German
    ("Müller" "Mueller" "über")
    ;; Spanish
    ("año" "ano" "niño")
    ;; Chinese
    ("北京" "上海" "中国")
    ;; Japanese
    ("こんにちは" "さようなら" "ありがとう")
    ;; Korean
    ("안녕하세요" "감사합니다" "한국")
    ;; Arabic (RTL)
    ("مرحبا" "شكرا" "عربي")
    ;; Hebrew (RTL)
    ("שלום" "תודה" "עברית")
    ;; Emoji
    ("😀" "🌍" "🚀")
    ;; Mixed
    ("ABC123" "abc123" "123ABC")))

;; Simple string display with script detection
(define-function display-string-info (str)
  (println "String: \"" str "\"")
  (println "  Bytes: " (string-length str))
  (println "  Chars: " (utf8-char-count str))
  (println "  Script: " (detect-primary-script str)))

;; Detect primary script (simplified)
(define-function detect-primary-script (str)
  (let ((first-char (string-ref str 0)))
    (cond
      ((< first-char 128) 'latin)
      ((string-contains? str "中") 'chinese)
      ((string-contains? str "こ") 'japanese)
      ((string-contains? str "한") 'korean)
      ((string-contains? str "م") 'arabic)
      ((string-contains? str "ש") 'hebrew)
      ((> first-char 127000) 'emoji)
      (else 'other))))

;; UTF-8 character count (vs byte count)
(define-function utf8-char-count (str)
  ;; Simplified - count UTF-8 start bytes
  (let ((count 0))
    (string-for-each
      (lambda (byte)
        (if (or (< byte 128)              ; ASCII
                (>= byte 192))            ; UTF-8 start byte
            (set count (+ count 1))))
      str)
    count))

;; Test basic properties
(println "1. Basic String Properties")
(println "--------------------------")
(display-string-info "Hello")
(display-string-info "你好")
(display-string-info "مرحبا")
(display-string-info "👋🌍")
(println)

;; Test collation/sorting
(println "2. Collation Examples")
(println "---------------------")
(println "ASCII sort vs locale sort:")
(let ((words '("zebra" "Zebra" "apple" "Apple" "école" "ecole")))
  (println "  Original: " words)
  (println "  ASCII: " (sort words string<?))
  (println "  Case-insensitive: " (sort words string-ci<?)))
(println)

;; Test normalization concepts
(println "3. Normalization Concepts")
(println "-------------------------")
(println "Precomposed vs Decomposed:")
(println "  Precomposed: é (single character)")
(println "  Decomposed: é (e + combining acute)")
(println "  Both should compare equal after normalization")
(println)

;; Test bidirectional text
(println "4. Bidirectional Text")
(println "---------------------")
(println "Mixed LTR/RTL:")
(println "  English: Hello (LTR)")
(println "  Arabic: مرحبا (RTL)")
(println "  Hebrew: שלום (RTL)")
(println "  Mixed: Hello مرحبا שלום")
(println)

;; Test script mixing
(println "5. Script Mixing")
(println "----------------")
(dolist (example '(("Hello 你好" "English + Chinese")
                   ("こんにちは 世界" "Japanese + Chinese")
                   ("Café 咖啡" "French + Chinese")
                   ("🌍 World 世界" "Emoji + English + Chinese")))
  (println "  " (car example) " - " (cadr example)))
(println)

;; Performance test
(println "6. Performance Test")
(println "-------------------")
(let ((test-string "Hello 你好 مرحبا 🌍")
      (iterations 1000))
  (println "String: \"" test-string "\"")
  (println "Operations: " iterations " iterations")
  
  (let ((start-time (current-time)))
    (dotimes (i iterations)
      (utf8-char-count test-string))
    (println "  Character counting: " (- (current-time) start-time) " seconds"))
  
  (let ((start-time (current-time)))
    (dotimes (i iterations)
      (string-length test-string))
    (println "  Byte counting: " (- (current-time) start-time) " seconds")))

(println)
(println "=== UTF-8 System Test Complete ===")