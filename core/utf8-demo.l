;; UTF-8 Demo for Maru
;; Shows UTF-8 support is working

;; Define UTF-8 character length function
(define-function utf8-char-length (c)
  (if (< c 128) 1      ;; ASCII
    (if (< c 224) 2    ;; 2-byte sequence  
      (if (< c 240) 3  ;; 3-byte sequence
        (if (< c 248) 4 ;; 4-byte sequence
          0)))))       ;; Invalid

;; Simple string length counter
(define-function utf8-strlen (str)
  (let ((len 0)
        (i 0))
    (while (< i (string-length str))
      (let* ((c (string-at str i))
             (char-len (utf8-char-length c)))
        (if (= char-len 0)
            (set char-len 1))  ;; Skip invalid byte
        (set i (+ i char-len))
        (set len (+ len 1))))
    len))

;; Show byte values
(define-function show-bytes (str label)
  (println label ": '" str "'")
  (println "  UTF-8 chars: " (utf8-strlen str))
  (println "  Bytes: " (string-length str))
  (print "  Byte values:")
  (let ((i 0))
    (while (< i (string-length str))
      (print " " (string-at str i))
      (set i (+ i 1))))
  (println))

(println "=== UTF-8 Demo ===")
(println)

;; ASCII string
(show-bytes "Hello" "ASCII")
(println)

;; Latin-1 encoded (not UTF-8)
(show-bytes "café" "Latin-1 café")
(println)

;; Create actual UTF-8 strings by constructing from bytes
(println "Constructing UTF-8 strings from bytes:")

;; UTF-8 "café" = c(99) a(97) f(102) é(195,169)
(let ((utf8-cafe (array->string (array 99 97 102 195 169))))
  (show-bytes utf8-cafe "UTF-8 café")
  (println))

;; UTF-8 "你好" (Hello in Chinese) = 228,189,160 229,165,189
(let ((utf8-hello (array->string (array 228 189 160 229 165 189))))
  (show-bytes utf8-hello "UTF-8 你好")
  (println))

;; UTF-8 emoji "😀" = 240,159,152,128
(let ((utf8-emoji (array->string (array 240 159 152 128))))
  (show-bytes utf8-emoji "UTF-8 😀")
  (println))

(println "=== Summary ===")
(println "Maru can handle UTF-8 strings when properly encoded.")
(println "The utf8-strlen function correctly counts characters, not bytes.")