;; UTF-8 Support for Maru
;; Native UTF-8 implementation using IR2 type system

;; UTF-8 character length from first byte
(define-function utf8-char-length (c)
  (if (< c 128) 1      ;; ASCII
    (if (< c 224) 2    ;; 2-byte sequence  
      (if (< c 240) 3  ;; 3-byte sequence
        (if (< c 248) 4 ;; 4-byte sequence
          0)))))       ;; Invalid

;; UTF-8 string length in characters (not bytes)
(define-function utf8-strlen (str)
  (let ((len 0)
        (i 0))
    (while (string-at str i)
      (let* ((c (string-at str i))
             (char-len (utf8-char-length c)))
        (if (= char-len 0)
            (set char-len 1))  ;; Skip invalid byte
        (set i (+ i char-len))
        (set len (+ len 1))))
    len))

;; Decode UTF-8 character at position to Unicode codepoint
(define-function utf8-decode-at (str pos)
  (let ((c0 (string-at str pos)))
    (if (< c0 128) 
        c0  ;; ASCII
      (if (< c0 224)
          ;; 2-byte sequence
          (let ((c1 (string-at str (+ pos 1))))
            (| (<< (& c0 31) 6)
               (& c1 63)))
        (if (< c0 240)
            ;; 3-byte sequence
            (let ((c1 (string-at str (+ pos 1)))
                  (c2 (string-at str (+ pos 2))))
              (| (<< (& c0 15) 12)
                 (| (<< (& c1 63) 6)
                    (& c2 63))))
          (if (< c0 248)
              ;; 4-byte sequence
              (let ((c1 (string-at str (+ pos 1)))
                    (c2 (string-at str (+ pos 2)))
                    (c3 (string-at str (+ pos 3))))
                (| (<< (& c0 7) 18)
                   (| (<< (& c1 63) 12)
                      (| (<< (& c2 63) 6)
                         (& c3 63)))))
            65533))))))  ;; Replacement character

;; Get nth UTF-8 character from string (returns codepoint)
(define-function utf8-char-at (str index)
  (let ((i 0)
        (char-index 0))
    (while (and (string-at str i) (< char-index index))
      (let* ((c (string-at str i))
             (char-len (utf8-char-length c)))
        (if (= char-len 0)
            (set char-len 1))
        (set i (+ i char-len))
        (set char-index (+ char-index 1))))
    (if (string-at str i)
        (utf8-decode-at str i)
        0)))

;; Get Unicode script for codepoint
(define-function utf8-script (codepoint)
  (if (< codepoint 128) 'latin
    (if (and (>= codepoint 880) (< codepoint 1024)) 'greek
      (if (and (>= codepoint 1024) (< codepoint 1328)) 'cyrillic
        (if (and (>= codepoint 1424) (< codepoint 1536)) 'hebrew
          (if (and (>= codepoint 1536) (< codepoint 1792)) 'arabic
            (if (and (>= codepoint 12352) (< codepoint 12448)) 'hiragana
              (if (and (>= codepoint 12448) (< codepoint 12544)) 'katakana
                (if (and (>= codepoint 19968) (< codepoint 40960)) 'cjk
                  (if (and (>= codepoint 44032) (< codepoint 55204)) 'hangul
                    (if (and (>= codepoint 128512) (< codepoint 128592)) 'emoji
                      'common)))))))))))

;; Text direction for codepoint
(define-function utf8-direction (codepoint)
  (let ((script (utf8-script codepoint)))
    (cond
      ((or (= script 'hebrew) (= script 'arabic)) 'rtl)
      ((or (= script 'latin) (= script 'cjk)) 'ltr)
      (else 'neutral))))

;; Check if character needs normalization
(define-function utf8-needs-normalization? (codepoint)
  (or (and (>= codepoint 192) (<= codepoint 255))     ;; Latin-1 accented
      (and (>= codepoint 768) (<= codepoint 879))     ;; Combining marks
      (and (>= codepoint 44032) (<= codepoint 55215)) ;; Hangul syllables
      (and (>= codepoint 64256) (<= codepoint 64262)))) ;; Ligatures

;; Simple UTF-8 string comparison
(define-function utf8-compare (s1 s2)
  (let ((i1 0) (i2 0))
    (while (and (string-at s1 i1) (string-at s2 i2))
      (let ((cp1 (utf8-decode-at s1 i1))
            (cp2 (utf8-decode-at s2 i2)))
        (if (!= cp1 cp2)
            (return (- cp1 cp2)))
        (let ((len1 (utf8-char-length (string-at s1 i1)))
              (len2 (utf8-char-length (string-at s2 i2))))
          (set i1 (+ i1 len1))
          (set i2 (+ i2 len2)))))
    (cond
      ((string-at s1 i1) 1)   ;; s1 is longer
      ((string-at s2 i2) -1)  ;; s2 is longer
      (else 0))))             ;; equal

;; Collation weight for sorting
(define-function utf8-collation-weight (codepoint)
  (cond
    ;; ASCII uppercase gets lower weight than lowercase
    ((and (>= codepoint 65) (<= codepoint 90))
     (+ 100 (- codepoint 65)))
    ;; ASCII lowercase
    ((and (>= codepoint 97) (<= codepoint 122))
     (+ 200 (- codepoint 97)))
    ;; Numbers
    ((and (>= codepoint 48) (<= codepoint 57))
     (+ 50 (- codepoint 48)))
    ;; Script-based weights
    (else
     (let ((script (utf8-script codepoint)))
       (cond
         ((= script 'latin) (+ 1000 codepoint))
         ((= script 'greek) (+ 2000 codepoint))
         ((= script 'cyrillic) (+ 3000 codepoint))
         ((= script 'hebrew) (+ 4000 codepoint))
         ((= script 'arabic) (+ 5000 codepoint))
         ((= script 'cjk) (+ 10000 (- codepoint 19968)))
         ((= script 'hangul) (+ 20000 (- codepoint 44032)))
         ((= script 'emoji) (+ 30000 codepoint))
         (else codepoint))))))

;; Locale-aware string comparison for sorting
(define-function utf8-compare-locale (s1 s2 locale)
  (let ((i1 0) (i2 0))
    (while (and (string-at s1 i1) (string-at s2 i2))
      (let ((cp1 (utf8-decode-at s1 i1))
            (cp2 (utf8-decode-at s2 i2))
            (w1 (utf8-collation-weight cp1))
            (w2 (utf8-collation-weight cp2)))
        (if (!= w1 w2)
            (return (- w1 w2)))
        (let ((len1 (utf8-char-length (string-at s1 i1)))
              (len2 (utf8-char-length (string-at s2 i2))))
          (set i1 (+ i1 len1))
          (set i2 (+ i2 len2)))))
    (cond
      ((string-at s1 i1) 1)   ;; s1 is longer
      ((string-at s2 i2) -1)  ;; s2 is longer
      (else 0))))             ;; equal

;; Test function to demonstrate UTF-8 support
(define-function test-utf8 ()
  (println "=== UTF-8 Support Test ===")
  (println)
  
  ;; Test string lengths
  (println "String lengths:")
  (println "  'Hello': " (utf8-strlen "Hello") " characters")
  (println "  'café': " (utf8-strlen "café") " characters")
  (println "  '你好': " (utf8-strlen "你好") " characters")
  (println "  '🌍🌎': " (utf8-strlen "🌍🌎") " characters")
  (println)
  
  ;; Test character access
  (println "Character at index 1:")
  (println "  'Hello'[1]: " (utf8-char-at "Hello" 1))
  (println "  'café'[1]: " (utf8-char-at "café" 1))
  (println "  '你好'[1]: " (utf8-char-at "你好" 1))
  (println)
  
  ;; Test script detection
  (println "Script detection:")
  (println "  'A': " (utf8-script 65))
  (println "  'α': " (utf8-script 945))
  (println "  '中': " (utf8-script 20013))
  (println "  '😀': " (utf8-script 128512))
  (println)
  
  ;; Test sorting
  (println "Sorting test:")
  (let ((words '("zebra" "Zebra" "apple" "Apple" "café" "cafe")))
    (println "  Original: " words)
    (println "  Sorted: " (sort words (lambda (a b) (< (utf8-compare-locale a b "en_US") 0)))))
  (println)
  
  (println "=== UTF-8 Test Complete ==="))