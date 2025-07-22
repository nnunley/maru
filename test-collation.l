;; Test UTF-8 Collation
;; Demonstrates language-aware string sorting

;; Define test strings for different languages
(define french-words '("café" "çà" "âge" "être" "élève" "ecole"))
(define german-words '("Müller" "Mueller" "Mutter" "über" "Übung" "schön"))
(define spanish-words '("año" "niño" "cañón" "lluvia" "mañana" "señor"))

;; Simple ASCII-based sort (incorrect for these languages)
(define-function ascii-sort (words)
  (sort words string<?))

;; Locale-aware sort simulation (demonstrates the concept)
(define-function locale-sort (words locale)
  ;; In a real implementation, this would use the generated collation tables
  (println "Sorting with locale: " locale)
  (sort words (lambda (a b)
    ;; Simplified collation logic
    (cond
      ;; French: é comes after e, ç after c
      ((equal? locale "fr_FR")
       (string<? (replace-french-chars a) (replace-french-chars b)))
      ;; German: ä/ö/ü sort with a/o/u (or after, depending on DIN 5007)
      ((equal? locale "de_DE") 
       (string<? (replace-german-chars a) (replace-german-chars b)))
      ;; Spanish: ñ comes after n
      ((equal? locale "es_ES")
       (string<? (replace-spanish-chars a) (replace-spanish-chars b)))
      ;; Default: ASCII sort
      (else (string<? a b))))))

;; Character replacement for simplified collation
(define-function replace-french-chars (str)
  ;; In real collation, these would have secondary weights
  (string-replace (string-replace str "ç" "c~") "é" "e~"))

(define-function replace-german-chars (str)
  ;; DIN 5007-1: ä→a, ö→o, ü→u
  (string-replace (string-replace (string-replace str "ä" "a") "ö" "o") "ü" "u"))

(define-function replace-spanish-chars (str)
  ;; ñ sorts after n
  (string-replace str "ñ" "n~"))

;; Test sorting
(println "=== UTF-8 Collation Test ===")
(println)

(println "French words (ASCII sort - WRONG):")
(println "  " (ascii-sort french-words))
(println "French words (locale-aware):")
(println "  " (locale-sort french-words "fr_FR"))
(println)

(println "German words (ASCII sort - WRONG):")  
(println "  " (ascii-sort german-words))
(println "German words (locale-aware DIN 5007-1):")
(println "  " (locale-sort german-words "de_DE"))
(println)

(println "Spanish words (ASCII sort - WRONG):")
(println "  " (ascii-sort spanish-words))
(println "Spanish words (locale-aware):")
(println "  " (locale-sort spanish-words "es_ES"))
(println)

(println "=== Collation Weight Example ===")
(println "Character collation weights demonstrate sort order:")
(println "  'a' → [100, 0, 2]  (letter a, no accent, lowercase)")
(println "  'A' → [100, 0, 1]  (letter a, no accent, uppercase)")
(println "  'à' → [100, 1, 2]  (letter a, grave accent, lowercase)")
(println "  'á' → [100, 2, 2]  (letter a, acute accent, lowercase)")
(println "  'ä' → [100, 6, 2]  (letter a, diaeresis, lowercase)")
(println)
(println "Primary weight determines letter group")
(println "Secondary weight determines accent/diacritic")
(println "Tertiary weight determines case")