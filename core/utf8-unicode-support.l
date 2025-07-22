;; Full Unicode Support for Maru
;; Handles CJK, Emoji, RTL languages

;; UTF-8 decoding helpers
(define-function decode-utf8-2 (bytes)
  (+ (bitwise-shift-left (bitwise-and (char-code (string-at bytes 0)) 31) 6)
     (bitwise-and (char-code (string-at bytes 1)) 63)))

(define-function decode-utf8-3 (bytes)
  (+ (bitwise-shift-left (bitwise-and (char-code (string-at bytes 0)) 15) 12)
     (bitwise-shift-left (bitwise-and (char-code (string-at bytes 1)) 63) 6)
     (bitwise-and (char-code (string-at bytes 2)) 63)))

(define-function decode-utf8-4 (bytes)
  (+ (bitwise-shift-left (bitwise-and (char-code (string-at bytes 0)) 7) 18)
     (bitwise-shift-left (bitwise-and (char-code (string-at bytes 1)) 63) 12)
     (bitwise-shift-left (bitwise-and (char-code (string-at bytes 2)) 63) 6)
     (bitwise-and (char-code (string-at bytes 3)) 63)))

;; Unicode block detection
(define-function unicode-block (codepoint)
  (cond
    ;; Basic blocks
    ((< codepoint 128) 'ascii)
    ((< codepoint 256) 'latin-1)
    ((< codepoint 592) 'latin-extended)
    
    ;; RTL languages
    ((and (>= codepoint 1424) (< codepoint 1536)) 'hebrew)
    ((and (>= codepoint 1536) (< codepoint 1792)) 'arabic)
    
    ;; CJK
    ((and (>= codepoint 12352) (< codepoint 12448)) 'hiragana)
    ((and (>= codepoint 12448) (< codepoint 12544)) 'katakana)
    ((and (>= codepoint 19968) (< codepoint 40960)) 'cjk-unified)
    ((and (>= codepoint 44032) (< codepoint 55204)) 'hangul)
    
    ;; Emoji ranges (simplified)
    ((and (>= codepoint 128512) (< codepoint 128592)) 'emoji)
    ((and (>= codepoint 129280) (< codepoint 129536)) 'emoji)
    
    (else 'other)))

;; Bidirectional text handling
(define-structure <bidi-context> (direction embedding-level))

(define-function create-bidi-context ()
  (new <bidi-context> 'ltr 0))

(define-function bidi-push-direction (ctx dir)
  (set (<bidi-context>-direction ctx) dir)
  (set (<bidi-context>-embedding-level ctx) 
       (+ (<bidi-context>-embedding-level ctx) 1)))

(define-function bidi-pop-direction (ctx)
  (set (<bidi-context>-embedding-level ctx)
       (- (<bidi-context>-embedding-level ctx) 1)))

;; Collation for different scripts
(define-function script-sort-order (script)
  (case script
    ((ascii latin-1 latin-extended) 1)
    ((greek cyrillic) 2)
    ((hebrew arabic) 3)
    ((devanagari thai) 4)
    ((hiragana katakana) 5)
    ((cjk-unified) 6)
    ((hangul) 7)
    ((emoji) 8)
    (else 9)))

;; CJK specific handling
(define-function cjk-radical-sort (codepoint)
  ;; Simplified radical-based sorting
  ;; Real implementation would use Kangxi radical tables
  (let ((offset (- codepoint 19968)))  ; CJK Unified base
    (+ (* (quotient offset 214) 1000)  ; Approximate radical group
       (remainder offset 214))))        ; Stroke count approximation

;; Japanese kana ordering (gojuon)
(define hiragana-order 
  '((あ い う え お)     ; a-row
    (か き く け こ)     ; ka-row
    (さ し す せ そ)     ; sa-row
    (た ち つ て と)     ; ta-row
    (な に ぬ ね の)     ; na-row
    (は ひ ふ へ ほ)     ; ha-row
    (ま み む め も)     ; ma-row
    (や    ゆ    よ)     ; ya-row
    (ら り る れ ろ)     ; ra-row
    (わ          を ん))) ; wa-row

;; Korean Hangul decomposition
(define-function hangul-decompose (syllable)
  ;; Hangul syllable = (initial * 588) + (medial * 28) + final + 44032
  (let* ((s (- syllable 44032))
         (initial (quotient s 588))
         (medial (quotient (remainder s 588) 28))
         (final (remainder s 28)))
    (list initial medial final)))

;; Emoji handling
(define-function emoji-category (codepoint)
  (cond
    ((and (>= codepoint 128512) (< codepoint 128567)) 'emoticons)
    ((and (>= codepoint 127744) (< codepoint 128318)) 'symbols)
    ((and (>= codepoint 129280) (< codepoint 129536)) 'supplemental)
    (else 'other)))

;; Generate C code for full Unicode support
(define-function generate-unicode-c ()
  (println "/* Full Unicode Support for Maru */")
  (println "")
  (println "/* Unicode block detection */")
  (println "static int unicode_block(uint32_t cp) {")
  (println "    if (cp < 0x80) return BLOCK_ASCII;")
  (println "    if (cp < 0x100) return BLOCK_LATIN1;")
  (println "    if (cp >= 0x0590 && cp < 0x0600) return BLOCK_HEBREW;")
  (println "    if (cp >= 0x0600 && cp < 0x0700) return BLOCK_ARABIC;")
  (println "    if (cp >= 0x3040 && cp < 0x30A0) return BLOCK_HIRAGANA;")
  (println "    if (cp >= 0x30A0 && cp < 0x3100) return BLOCK_KATAKANA;")
  (println "    if (cp >= 0x4E00 && cp < 0x9FFF) return BLOCK_CJK;")
  (println "    if (cp >= 0xAC00 && cp < 0xD7AF) return BLOCK_HANGUL;")
  (println "    if (cp >= 0x1F600 && cp < 0x1F650) return BLOCK_EMOJI;")
  (println "    return BLOCK_OTHER;")
  (println "}")
  (println "")
  (println "/* Bidirectional text properties */")
  (println "static int is_rtl_char(uint32_t cp) {")
  (println "    return (cp >= 0x0590 && cp < 0x0700) ||  /* Hebrew & Arabic */")
  (println "           (cp >= 0x0700 && cp < 0x0750);    /* Syriac */")
  (println "}")
  (println ""))

;; Test full Unicode support
(define-function test-unicode ()
  (println "=== Full Unicode Test ===")
  (println "ASCII: Hello")
  (println "Chinese: 你好世界")
  (println "Japanese: こんにちは世界")
  (println "Korean: 안녕하세요")
  (println "Arabic: مرحبا بالعالم")
  (println "Hebrew: שלום עולם")
  (println "Emoji: 👋🌍😊🚀")
  (println "Mixed: Hello 你好 مرحبا 🌍"))

;; Generate the C code
(generate-unicode-c)