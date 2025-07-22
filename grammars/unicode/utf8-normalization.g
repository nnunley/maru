# Unicode Normalization Grammar
# Handles NFD, NFC, NFKD, NFKC normalization forms

# Combining character classes
combining_grave     = "\xCC\x80"     # U+0300 COMBINING GRAVE ACCENT
combining_acute     = "\xCC\x81"     # U+0301 COMBINING ACUTE ACCENT
combining_circumflex = "\xCC\x82"    # U+0302 COMBINING CIRCUMFLEX ACCENT
combining_tilde     = "\xCC\x83"     # U+0303 COMBINING TILDE
combining_macron    = "\xCC\x84"     # U+0304 COMBINING MACRON
combining_diaeresis = "\xCC\x88"     # U+0308 COMBINING DIAERESIS
combining_ring      = "\xCC\x8A"     # U+030A COMBINING RING ABOVE
combining_cedilla   = "\xCC\xA7"     # U+0327 COMBINING CEDILLA

# Base characters that can be combined
base_a = "a" | "A"
base_c = "c" | "C"
base_e = "e" | "E"
base_i = "i" | "I"
base_n = "n" | "N"
base_o = "o" | "O"
base_u = "u" | "U"

# Decomposed forms (NFD)
decomposed_a_grave = base_a:b combining_grave     -> `(composed ,b grave) ;
decomposed_a_acute = base_a:b combining_acute     -> `(composed ,b acute) ;
decomposed_a_tilde = base_a:b combining_tilde     -> `(composed ,b tilde) ;
decomposed_a_ring  = base_a:b combining_ring      -> `(composed ,b ring) ;

decomposed_e_grave = base_e:b combining_grave     -> `(composed ,b grave) ;
decomposed_e_acute = base_e:b combining_acute     -> `(composed ,b acute) ;

decomposed_c_cedilla = base_c:b combining_cedilla -> `(composed ,b cedilla) ;
decomposed_n_tilde = base_n:b combining_tilde     -> `(composed ,b tilde) ;

# Precomposed forms (NFC) - using actual UTF-8 bytes
precomposed_a_grave = "\xC3\xA0"   -> `(precomposed a grave) ;    # à
precomposed_A_grave = "\xC3\x80"   -> `(precomposed A grave) ;    # À
precomposed_a_acute = "\xC3\xA1"   -> `(precomposed a acute) ;    # á
precomposed_e_grave = "\xC3\xA8"   -> `(precomposed e grave) ;    # è
precomposed_e_acute = "\xC3\xA9"   -> `(precomposed e acute) ;    # é
precomposed_c_cedilla = "\xC3\xA7" -> `(precomposed c cedilla) ;  # ç
precomposed_n_tilde = "\xC3\xB1"   -> `(precomposed n tilde) ;    # ñ

# Compatibility characters (will normalize differently in NFKC/NFKD)
compat_ff = "\xEF\xAC\x80"         -> `(compat ff) ;      # ﬀ LATIN SMALL LIGATURE FF
compat_fi = "\xEF\xAC\x81"         -> `(compat fi) ;      # ﬁ LATIN SMALL LIGATURE FI
compat_fl = "\xEF\xAC\x82"         -> `(compat fl) ;      # ﬂ LATIN SMALL LIGATURE FL
superscript_2 = "\xC2\xB2"         -> `(compat super 2) ;  # ² SUPERSCRIPT TWO
fraction_half = "\xC2\xBD"         -> `(compat frac 1 2) ; # ½ VULGAR FRACTION ONE HALF

# CJK compatibility forms
cjk_compat = [\xF900-\xFAFF]       -> `(cjk-compat ,$1) ;

# Hangul decomposition
hangul_syllable = [\xAC00-\xD7AF]:s -> `(hangul-syllable ,(decompose-hangul s)) ;

# Normalization rules
nfd_char = decomposed_a_grave
         | decomposed_a_acute
         | decomposed_a_tilde
         | decomposed_e_grave
         | decomposed_e_acute
         | decomposed_c_cedilla
         | decomposed_n_tilde
         | base_char:b combining:c+ -> `(decomposed ,b ,@c) ;

nfc_char = precomposed_a_grave
         | precomposed_A_grave
         | precomposed_a_acute
         | precomposed_e_grave
         | precomposed_e_acute
         | precomposed_c_cedilla
         | precomposed_n_tilde
         | ascii_char

# Canonical ordering of combining marks
combining_sequence = combining:first combining:rest*
    -> (canonical-order (cons first rest)) ;

# Full normalization forms
normalize_nfd = (nfd_char | nfc_char | ascii_char)*
    -> (map decompose $1) ;

normalize_nfc = (nfd_char | nfc_char | ascii_char)*
    -> (map compose $1) ;

normalize_nfkd = (compat_char | nfd_char | nfc_char | ascii_char)*
    -> (map compatibility-decompose $1) ;

normalize_nfkc = (compat_char | nfd_char | nfc_char | ascii_char)*
    -> (map compatibility-compose $1) ;