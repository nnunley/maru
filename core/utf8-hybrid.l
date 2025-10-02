;; UTF-8 Hybrid Implementation
;; Combines Lisp code generation with grammar-based parsing

;; Generate core UTF-8 functions using Maru's native capabilities
(define-function utf8-byte-length (byte)
  (cond
    ((< byte 128) 1)      ; ASCII
    ((< byte 224) 2)      ; 110xxxxx
    ((< byte 240) 3)      ; 1110xxxx 
    ((< byte 248) 4)      ; 11110xxx
    (else 0)))            ; Invalid

(define-function utf8-decode-char (bytes)
  (let ((b0 (car bytes)))
    (cond
      ((< b0 128) b0)     ; ASCII
      ((< b0 224)         ; 2-byte
       (+ (bitwise-shift-left (bitwise-and b0 31) 6)
          (bitwise-and (cadr bytes) 63)))
      ((< b0 240)         ; 3-byte
       (+ (bitwise-shift-left (bitwise-and b0 15) 12)
          (bitwise-shift-left (bitwise-and (cadr bytes) 63) 6)
          (bitwise-and (caddr bytes) 63)))
      ((< b0 248)         ; 4-byte
       (+ (bitwise-shift-left (bitwise-and b0 7) 18)
          (bitwise-shift-left (bitwise-and (cadr bytes) 63) 12)
          (bitwise-shift-left (bitwise-and (caddr bytes) 63) 6)
          (bitwise-and (cadddr bytes) 63)))
      (else 65533))))     ; Replacement character

;; Generate C code for UTF-8 handling
(define-function generate-minimal-utf8 ()
  (println "/* Minimal UTF-8 support for Maru */")
  (println "")
  (println "/* UTF-8 character length calculation */")
  (println "static inline size_t utf8_strlen(const char *str) {")
  (println "    size_t len = 0;")
  (println "    const unsigned char *s = (const unsigned char *)str;")
  (println "    while (*s) {")
  (println "        if (*s < 0x80) s++;")
  (println "        else if (*s < 0xE0) s += 2;")
  (println "        else if (*s < 0xF0) s += 3;")
  (println "        else s += 4;")
  (println "        len++;")
  (println "    }")
  (println "    return len;")
  (println "}")
  (println "")
  (println "/* Minimal compatibility mappings */")
  (println "#define wchar_t char")
  (println "#define wcslen(s) utf8_strlen(s)")
  (println "#define wcscmp(s1, s2) strcmp(s1, s2)")
  (println "#define wcscpy(dst, src) strcpy(dst, src)")
  (println "#define wcsdup(s) strdup(s)")
  (println "")
  (println "/* Wide I/O stubs */")
  (println "typedef int wint_t;")
  (println "#define getwc(fp) fgetc(fp)")
  (println "#define ungetwc(c, fp) ungetc(c, fp)")
  (println "#define putwc(c, fp) fputc(c, fp)")
  (println "#define fwide(stream, mode) (mode)")
  (println "#define wcstod(str, endptr) strtod(str, endptr)")
  (println "#define wcstoul(str, endptr, base) strtoul(str, endptr, base)")
  (println "#define swprintf snprintf"))

;; Generate the minimal UTF-8 library
(generate-minimal-utf8)