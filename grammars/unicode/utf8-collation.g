# UTF-8 Collation Grammar
# Generates collation tables for different locales and sorting rules

# Basic Latin (ASCII) collation weights
ascii_lower = [a-z]      -> (+ 100 (- $1 97)) ;     # a=100, b=101, etc.
ascii_upper = [A-Z]      -> (+ 100 (- $1 65)) ;     # A=100, B=101, etc.
ascii_digit = [0-9]      -> (+ 50 (- $1 48)) ;      # 0=50, 1=51, etc.
ascii_space = [ \t\n\r]  -> 10 ;                    # Whitespace sorts early
ascii_punct = [!-/:-@\[-`{-~] -> (+ 20 $1) ;       # Punctuation

# Diacritical marks (combining characters)
combining_grave     = [\u0300] -> 1 ;    # à
combining_acute     = [\u0301] -> 2 ;    # á
combining_circumflex = [\u0302] -> 3 ;   # â
combining_tilde     = [\u0303] -> 4 ;    # ã
combining_macron    = [\u0304] -> 5 ;    # ā
combining_diaeresis = [\u0308] -> 6 ;    # ä

# Latin Extended-A (Western European)
latin_a_grave   = [àÀ] -> 100.1 ;    # Sort after 'a'
latin_a_acute   = [áÁ] -> 100.2 ;
latin_a_circumflex = [âÂ] -> 100.3 ;
latin_a_tilde   = [ãÃ] -> 100.4 ;
latin_a_diaeresis = [äÄ] -> 100.6 ;
latin_ae        = [æÆ] -> 100.9 ;    # Sort at end of 'a'

latin_c_cedilla = [çÇ] -> 103.5 ;    # Sort between 'c' and 'd'

latin_e_grave   = [èÈ] -> 105.1 ;
latin_e_acute   = [éÉ] -> 105.2 ;
latin_e_circumflex = [êÊ] -> 105.3 ;
latin_e_diaeresis = [ëË] -> 105.6 ;

# Define locale-specific rules
locale_en = ascii_lower | ascii_upper | ascii_digit | ascii_space | ascii_punct
locale_fr = locale_en | latin_a_grave | latin_a_acute | latin_e_grave | latin_e_acute | latin_c_cedilla
locale_de = locale_en | latin_a_diaeresis | latin_o_diaeresis:o | latin_u_diaeresis:u
locale_es = locale_en | latin_n_tilde:n | latin_a_acute | latin_e_acute | latin_i_acute:i

# Collation key generation
collation_weight = locale_en    # Default to English

# Multi-level collation (primary, secondary, tertiary)
primary_weight = letter:l        -> (floor l) ;
secondary_weight = letter:l      -> (* 100 (- l (floor l))) ;
tertiary_weight = case:c         -> c ;

# Generate collation sequence
collate_char = char:c
    -> (list (primary_weight c) (secondary_weight c) (tertiary_weight c)) ;

# String collation
collate_string = collate_char*
    -> $1 ;