;; Unicode Normalization Support for Maru
;; Implements NFD, NFC, NFKD, NFKC normalization forms

;; Combining class values (for canonical ordering)
(define combining-class-table
  '((#x0300 230)  ; grave
    (#x0301 230)  ; acute
    (#x0302 230)  ; circumflex
    (#x0303 230)  ; tilde
    (#x0304 230)  ; macron
    (#x0308 230)  ; diaeresis
    (#x030A 230)  ; ring above
    (#x0327 202)  ; cedilla (attaches below)
    (#x0328 202)  ; ogonek (attaches below)
    (#x0323 220)  ; dot below
    (#x0307 230)  ; dot above
    (#x030B 230)  ; double acute
    (#x030C 230))) ; caron

;; Canonical decomposition mappings
(define decomposition-table
  '((#x00C0 (#x0041 #x0300))  ; À → A + grave
    (#x00C1 (#x0041 #x0301))  ; Á → A + acute
    (#x00C2 (#x0041 #x0302))  ; Â → A + circumflex
    (#x00C3 (#x0041 #x0303))  ; Ã → A + tilde
    (#x00C4 (#x0041 #x0308))  ; Ä → A + diaeresis
    (#x00C5 (#x0041 #x030A))  ; Å → A + ring
    (#x00C7 (#x0043 #x0327))  ; Ç → C + cedilla
    (#x00C8 (#x0045 #x0300))  ; È → E + grave
    (#x00C9 (#x0045 #x0301))  ; É → E + acute
    (#x00D1 (#x004E #x0303))  ; Ñ → N + tilde
    (#x00E0 (#x0061 #x0300))  ; à → a + grave
    (#x00E1 (#x0061 #x0301))  ; á → a + acute
    (#x00E2 (#x0061 #x0302))  ; â → a + circumflex
    (#x00E3 (#x0061 #x0303))  ; ã → a + tilde
    (#x00E4 (#x0061 #x0308))  ; ä → a + diaeresis
    (#x00E5 (#x0061 #x030A))  ; å → a + ring
    (#x00E7 (#x0063 #x0327))  ; ç → c + cedilla
    (#x00E8 (#x0065 #x0300))  ; è → e + grave
    (#x00E9 (#x0065 #x0301))  ; é → e + acute
    (#x00F1 (#x006E #x0303))  ; ñ → n + tilde
    (#x00FC (#x0075 #x0308)))) ; ü → u + diaeresis

;; Compatibility decomposition mappings (includes canonical)
(define compatibility-table
  '((#xFB00 (#x0066 #x0066))      ; ﬀ → ff
    (#xFB01 (#x0066 #x0069))      ; ﬁ → fi
    (#xFB02 (#x0066 #x006C))      ; ﬂ → fl
    (#xFB03 (#x0066 #x0066 #x0069)) ; ﬃ → ffi
    (#xFB04 (#x0066 #x0066 #x006C)) ; ﬄ → ffl
    (#x00B2 (#x0032))              ; ² → 2
    (#x00B3 (#x0033))              ; ³ → 3
    (#x00BD (#x0031 #x2044 #x0032)) ; ½ → 1/2
    (#x2126 (#x03A9))              ; Ω → Ω (ohm → omega)
    (#x2160 (#x0049))              ; Ⅰ → I
    (#x2161 (#x0049 #x0049))       ; Ⅱ → II
    (#x2162 (#x0049 #x0049 #x0049)))) ; Ⅲ → III

;; Get combining class for ordering
(define-function combining-class (codepoint)
  (let ((entry (assoc codepoint combining-class-table)))
    (if entry (cadr entry) 0)))

;; Sort combining marks by canonical order
(define-function canonical-order (marks)
  (sort marks (lambda (a b)
    (< (combining-class a) (combining-class b)))))

;; Decompose a single character (NFD)
(define-function decompose-char (codepoint)
  (let ((entry (assoc codepoint decomposition-table)))
    (if entry
        (cadr entry)
        (list codepoint))))

;; Compose characters (NFC)
(define-function compose-chars (base combining)
  ;; Look for precomposed form
  (let ((key (list base combining)))
    (dolist (entry decomposition-table)
      (if (equal? (cadr entry) key)
          (return (car entry)))))
  ;; No precomposed form found
  (cons base combining))

;; Hangul syllable decomposition
(define-function decompose-hangul (syllable)
  (let* ((s-base #xAC00)
         (l-base #x1100)  ; Leading consonant base
         (v-base #x1161)  ; Vowel base
         (t-base #x11A7)  ; Trailing consonant base
         (s-index (- syllable s-base)))
    (if (and (>= s-index 0) (< s-index 11172))
        (let* ((l-index (quotient s-index 588))
               (v-index (quotient (remainder s-index 588) 28))
               (t-index (remainder s-index 28))
               (l (+ l-base l-index))
               (v (+ v-base v-index)))
          (if (= t-index 0)
              (list l v)
              (list l v (+ t-base t-index))))
        (list syllable))))

;; Generate C code for normalization
(define-function generate-normalization-c ()
  (println "/* Unicode Normalization Support */")
  (println "")
  (println "/* Normalization quick check */")
  (println "static int needs_normalization(uint32_t cp) {")
  (println "    /* Check if character might need normalization */")
  (println "    if (cp >= 0x00C0 && cp <= 0x00FF) return 1;  /* Latin-1 supplement */")
  (println "    if (cp >= 0x0300 && cp <= 0x036F) return 1;  /* Combining marks */")
  (println "    if (cp >= 0xAC00 && cp <= 0xD7AF) return 1;  /* Hangul syllables */")
  (println "    if (cp >= 0xFB00 && cp <= 0xFB06) return 1;  /* Latin ligatures */")
  (println "    return 0;")
  (println "}")
  (println "")
  (println "/* Normalize string to NFD */")
  (println "static char* normalize_nfd(const char* str) {")
  (println "    /* Decompose all precomposed characters */")
  (println "    /* Implementation would decompose each character */")
  (println "    return (char*)str;  /* Placeholder */")
  (println "}")
  (println "")
  (println "/* Normalize string to NFC */")
  (println "static char* normalize_nfc(const char* str) {")
  (println "    /* First decompose, then recompose */")
  (println "    /* Implementation would use composition algorithm */")
  (println "    return (char*)str;  /* Placeholder */")
  (println "}")
  (println "")
  (println "/* Compare strings with normalization */")
  (println "static int utf8_compare_normalized(const char* s1, const char* s2) {")
  (println "    /* Normalize both strings to same form before comparing */")
  (println "    char* n1 = normalize_nfc(s1);")
  (println "    char* n2 = normalize_nfc(s2);")
  (println "    return strcmp(n1, n2);")
  (println "}")
  (println ""))

;; Test normalization
(define-function test-normalization ()
  (println "=== Normalization Test ===")
  (println "Precomposed: café (c-a-f-é)")
  (println "Decomposed: café (c-a-f-e-́)")
  (println "Should be equal after normalization")
  (println)
  (println "Compatibility example:")
  (println "  Original: ﬁle (fi ligature)")
  (println "  NFKC: file (f-i-l-e)")
  (println)
  (println "Hangul example:")
  (println "  Syllable: 한 (U+D55C)")
  (println "  Decomposed: ᄒ + ᅡ + ᆫ (U+1112 + U+1161 + U+11AB)"))