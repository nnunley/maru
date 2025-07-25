;;; Test UTF-8 in programming constructs

(println "=== UTF-8 Programming Test ===")

;; Unicode in variable names (if supported)
;; Note: This may not work depending on implementation

;; Unicode in strings and operations
(define greeting "你好")
(define world "世界")  
(define message (concat-string greeting world))
(println "Concatenated: " message)

;; Unicode in comments
;; 这是中文注释
;; これは日本語のコメントです
;; 이것은 한국어 주석입니다

;; Test conditional with Unicode
(define test-unicode 
  (lambda (text)
    (if (string? text)
        (concat-string "Unicode string: " text)
        "Not a string")))

(println (test-unicode "🌟"))
(println (test-unicode 42))

;; Test looping with Unicode output
(define countdown
  (lambda (n)
    (if (> n 0)
        (let ()
          (println "⏰ Countdown: " n)
          (countdown (- n 1)))
        (println "🚀 Launch!"))))

(countdown 3)

(println "=== Programming Test Complete ===")