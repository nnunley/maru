;; Simple UTF-8 Test
;; Test basic UTF-8 functionality

;; Define UTF-8 character length function
(define utf8-char-length
  (lambda (c)
    (if (< c 128) 1      ;; ASCII
      (if (< c 224) 2    ;; 2-byte sequence  
        (if (< c 240) 3  ;; 3-byte sequence
          (if (< c 248) 4 ;; 4-byte sequence
            0))))))      ;; Invalid

;; Test it
(println "UTF-8 character length tests:")
(println "  ASCII 'A' (65): " (utf8-char-length 65))
(println "  2-byte start (195): " (utf8-char-length 195))  
(println "  3-byte start (228): " (utf8-char-length 228))
(println "  4-byte start (240): " (utf8-char-length 240))

;; Simple string length counter
(define utf8-strlen
  (lambda (str)
    (let ((len 0)
          (i 0))
      (while (< i (string-length str))
        (let* ((c (string-at str i))
               (char-len (utf8-char-length c)))
          (if (= char-len 0)
              (set char-len 1))  ;; Skip invalid byte
          (set i (+ i char-len))
          (set len (+ len 1))))
      len)))

(println)
(println "String length tests:")
(println "  'Hello': " (utf8-strlen "Hello") " characters")
(println "  Actual bytes: " (string-length "Hello"))

;; Test multibyte string
(let ((mb-str "café"))
  (println)
  (println "  'café': " (utf8-strlen mb-str) " characters")  
  (println "  Actual bytes: " (string-length mb-str)))