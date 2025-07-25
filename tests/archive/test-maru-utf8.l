;; Test Maru UTF-8 Implementation

(require "boot2.l")
(require "maru-utf8.k")

(println "=== Testing Maru UTF-8 ===")
(println)

;; Test basic UTF-8 character length
(println "Character length tests:")
(println "  ASCII 'A' (65): " (utf8-char-length 65))
(println "  2-byte 'é' (233): " (utf8-char-length 195))  
(println "  3-byte '中' (228): " (utf8-char-length 228))
(println "  4-byte '𝄞' (240): " (utf8-char-length 240))
(println)

;; Test string length
(println "String length tests:")
(println "  'Hello': " (utf8-strlen "Hello") " characters")
(println "  'café': " (utf8-strlen "café") " characters")  
(println)

;; Test character decoding
(println "Character decoding tests:")
(println "  'A' at 0: " (utf8-decode-at "ABC" 0))
(println "  'B' at 1: " (utf8-decode-at "ABC" 1))
(println)

;; Test character access
(println "Character at index:")
(println "  'Hello'[0]: " (utf8-char-at "Hello" 0))
(println "  'Hello'[1]: " (utf8-char-at "Hello" 1))
(println "  'Hello'[4]: " (utf8-char-at "Hello" 4))
(println)

;; Test script detection
(println "Script detection:")
(println "  'A' (65): " (utf8-script 65))
(println "  'α' (945): " (utf8-script 945))
(println "  '中' (20013): " (utf8-script 20013))
(println)

;; Test simple comparison
(println "String comparison:")
(println "  'abc' vs 'def': " (utf8-compare "abc" "def"))
(println "  'abc' vs 'abc': " (utf8-compare "abc" "abc"))
(println "  'def' vs 'abc': " (utf8-compare "def" "abc"))
(println)

(println "=== Test Complete ===")