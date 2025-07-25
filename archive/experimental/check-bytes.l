;; Check byte values in strings

(define-function show-bytes (str)
  (println "String: '" str "'")
  (println "Length: " (string-length str) " bytes")
  (let ((i 0))
    (while (< i (string-length str))
      (println "  byte " i ": " (string-at str i))
      (set i (+ i 1)))))

(show-bytes "café")
(println)
(show-bytes "Hello")
(println)

;; Try actual UTF-8 bytes
(let ((utf8-str (string 72 101 108 108 111 32 228 184 150 231 149 140))) ;; "Hello 世界"
  (show-bytes utf8-str))