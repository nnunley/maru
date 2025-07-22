;; UTF-8 Support for Maru using IR2 type system
;; Pure UTF-8 implementation with proper type definitions

;; C standard library functions we need
(define (strlen  (int char *) *)                (extern strlen))
(define (strcpy  (char * char * char *) *)      (extern strcpy))
(define (strcmp  (int char * char *) *)         (extern strcmp))
(define (strdup  (char * char *) *)             (extern strdup))
(define (malloc  (void * int) *)                (extern malloc))
(define (free    (void void *) *)               (extern free))
(define (memcpy  (void * void * void * int) *)  (extern memcpy))

;; UTF-8 character length from first byte
(define-function utf8_char_length int ((c unsigned char))
  (cond
    ((< c 0x80) 1)      ;; ASCII
    ((< c 0xE0) 2)      ;; 2-byte sequence
    ((< c 0xF0) 3)      ;; 3-byte sequence
    ((< c 0xF8) 4)      ;; 4-byte sequence
    (else 0)))          ;; Invalid

;; UTF-8 string length in characters (not bytes)
(define-function utf8_strlen int ((str char *))
  (let ((len 0)
        (s (cast str unsigned char *)))
    (while (. s)
      (let ((char_len (maru_utf8_char_length (. s))))
        (if (= char_len 0)
            (set char_len 1))  ;; Skip invalid byte
        (set s (+ s char_len))
        (incr len)))
    len))

;; Decode UTF-8 character to Unicode codepoint
(define-function utf8_decode_char unsigned-int ((s unsigned char *) (len int *))
  (let ((n (utf8_char_length (at s 0)))
        (cp 0))
    (set (. len) n)
    (cond
      ((= n 1)
       (set cp (at s 0)))
      ((= n 2)
       (set cp (| (& (<< (at s 0) 6) 0x7C0)
                  (& (at s 1) 0x3F))))
      ((= n 3)
       (set cp (| (& (<< (at s 0) 12) 0xF000)
                  (| (& (<< (at s 1) 6) 0xFC0)
                     (& (at s 2) 0x3F)))))
      ((= n 4)
       (set cp (| (& (<< (at s 0) 18) 0x1C0000)
                  (| (& (<< (at s 1) 12) 0x3F000)
                     (| (& (<< (at s 2) 6) 0xFC0)
                        (& (at s 3) 0x3F))))))
      (else
       (set (. len) 1)
       (set cp 0xFFFD)))  ;; Replacement character
    cp))

;; Encode Unicode codepoint to UTF-8
(define-function utf8_encode_char int ((cp unsigned-int) (buf unsigned char *))
  (cond
    ((< cp 0x80)
     (set (at buf 0) cp)
     1)
    ((< cp 0x800)
     (set (at buf 0) (| 0xC0 (>> cp 6)))
     (set (at buf 1) (| 0x80 (& cp 0x3F)))
     2)
    ((< cp 0x10000)
     (set (at buf 0) (| 0xE0 (>> cp 12)))
     (set (at buf 1) (| 0x80 (& (>> cp 6) 0x3F)))
     (set (at buf 2) (| 0x80 (& cp 0x3F)))
     3)
    ((< cp 0x110000)
     (set (at buf 0) (| 0xF0 (>> cp 18)))
     (set (at buf 1) (| 0x80 (& (>> cp 12) 0x3F)))
     (set (at buf 2) (| 0x80 (& (>> cp 6) 0x3F)))
     (set (at buf 3) (| 0x80 (& cp 0x3F)))
     4)
    (else 0)))  ;; Invalid codepoint

;; Copy UTF-8 string
(define-function utf8_strcpy char * ((dst char *) (src char *))
  (strcpy dst src))

;; Duplicate UTF-8 string
(define-function utf8_strdup char * ((str char *))
  (strdup str))

;; Compare UTF-8 strings (byte-wise for now)
(define-function utf8_strcmp int ((s1 char *) (s2 char *))
  (strcmp s1 s2))

;; Get nth character from UTF-8 string
(define-function utf8_char_at unsigned-int ((str char *) (index int))
  (let ((s (cast str unsigned char *))
        (i 0))
    (while (and (. s) (< i index))
      (let ((len (maru_utf8_char_length (. s))))
        (if (= len 0) (set len 1))
        (set s (+ s len))
        (incr i)))
    (if (. s)
        (let ((len 0))
          (utf8_decode_char s (& len)))
        0)))

;; Count UTF-8 characters in first n bytes
(define-function utf8_nchars int ((str char *) (bytes int))
  (let ((s (cast str unsigned char *))
        (end (+ s bytes))
        (count 0))
    (while (and (< s end) (. s))
      (let ((len (maru_utf8_char_length (. s))))
        (if (= len 0) (set len 1))
        (if (<= (+ s len) end)
            (progn
              (set s (+ s len))
              (incr count))
            (set s end))))  ;; Stop if character would exceed limit
    count))

;; Unicode properties enum
(define UNICODE_SCRIPT_COMMON    0)
(define UNICODE_SCRIPT_LATIN     1)
(define UNICODE_SCRIPT_GREEK     2)
(define UNICODE_SCRIPT_CYRILLIC  3)
(define UNICODE_SCRIPT_HEBREW    4)
(define UNICODE_SCRIPT_ARABIC    5)
(define UNICODE_SCRIPT_HIRAGANA  6)
(define UNICODE_SCRIPT_KATAKANA  7)
(define UNICODE_SCRIPT_HAN       8)
(define UNICODE_SCRIPT_HANGUL    9)
(define UNICODE_SCRIPT_EMOJI    10)

;; Get script for Unicode codepoint
(define-function utf8_get_script int ((cp unsigned-int))
  (cond
    ((< cp 0x80) UNICODE_SCRIPT_LATIN)
    ((and (>= cp 0x0370) (< cp 0x0400)) UNICODE_SCRIPT_GREEK)
    ((and (>= cp 0x0400) (< cp 0x0530)) UNICODE_SCRIPT_CYRILLIC)
    ((and (>= cp 0x0590) (< cp 0x0600)) UNICODE_SCRIPT_HEBREW)
    ((and (>= cp 0x0600) (< cp 0x0700)) UNICODE_SCRIPT_ARABIC)
    ((and (>= cp 0x3040) (< cp 0x30A0)) UNICODE_SCRIPT_HIRAGANA)
    ((and (>= cp 0x30A0) (< cp 0x3100)) UNICODE_SCRIPT_KATAKANA)
    ((and (>= cp 0x4E00) (< cp 0xA000)) UNICODE_SCRIPT_HAN)
    ((and (>= cp 0xAC00) (< cp 0xD7B0)) UNICODE_SCRIPT_HANGUL)
    ((and (>= cp 0x1F600) (< cp 0x1F650)) UNICODE_SCRIPT_EMOJI)
    (else UNICODE_SCRIPT_COMMON)))

;; Text direction enum
(define TEXT_DIR_LTR     0)
(define TEXT_DIR_RTL     1)
(define TEXT_DIR_NEUTRAL 2)

;; Get text direction for codepoint
(define-function utf8_char_direction int ((cp unsigned-int))
  (let ((script (utf8_get_script cp)))
    (cond
      ((or (= script UNICODE_SCRIPT_HEBREW)
           (= script UNICODE_SCRIPT_ARABIC))
       TEXT_DIR_RTL)
      ((or (= script UNICODE_SCRIPT_LATIN)
           (= script UNICODE_SCRIPT_HAN))
       TEXT_DIR_LTR)
      (else TEXT_DIR_NEUTRAL))))

;; Check if character needs normalization
(define-function utf8_needs_normalization int ((cp unsigned-int))
  (or (and (>= cp 0x00C0) (<= cp 0x00FF))    ;; Latin-1 accented
      (and (>= cp 0x0300) (<= cp 0x036F))    ;; Combining marks
      (and (>= cp 0xAC00) (<= cp 0xD7AF))    ;; Hangul syllables
      (and (>= cp 0xFB00) (<= cp 0xFB06))))  ;; Ligatures

;; wchar_t compatibility definitions
(define wchar_t char)
(define wcslen utf8_strlen)
(define wcscmp utf8_strcmp)
(define wcscpy utf8_strcpy)
(define wcsdup utf8_strdup)