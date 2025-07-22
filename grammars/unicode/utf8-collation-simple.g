# Simple UTF-8 Collation Grammar for Maru
# Handles basic Latin and extended Latin characters

# Basic character classes
digit     = [0-9]
lower     = [a-z]
upper     = [A-Z]
space     = [ \t\n\r]
punct     = [!-/:-@\[-`{-~]

# Extended Latin characters (using hex codes for safety)
a_grave   = "\xC3\xA0"    # à
a_acute   = "\xC3\xA1"    # á
e_grave   = "\xC3\xA8"    # è
e_acute   = "\xC3\xA9"    # é
c_cedilla = "\xC3\xA7"    # ç
n_tilde   = "\xC3\xB1"    # ñ
u_umlaut  = "\xC3\xBC"    # ü

# Weight assignments
ascii_char = lower:c   -> `(weight ,(char-code c) 0 2) ;
           | upper:c   -> `(weight ,(char-code c) 0 1) ;
           | digit:c   -> `(weight ,(+ 48 (- (char-code c) 48)) 0 0) ;
           | space     -> `(weight 32 0 0) ;
           | punct:c   -> `(weight ,(char-code c) 0 0) ;

# French accented characters
french_char = a_grave  -> `(weight 97 1 2) ;   # sorts with 'a'
            | a_acute  -> `(weight 97 2 2) ;
            | e_grave  -> `(weight 101 1 2) ;  # sorts with 'e'
            | e_acute  -> `(weight 101 2 2) ;
            | c_cedilla -> `(weight 99 5 2) ;  # sorts with 'c'

# Spanish characters
spanish_char = n_tilde -> `(weight 110 4 2) ;  # sorts after 'n'

# German characters  
german_char = u_umlaut -> `(weight 117 6 2) ;  # sorts with 'u'

# Any character with weight
weighted_char = french_char | spanish_char | german_char | ascii_char

# String of weighted characters
weighted_string = weighted_char*
                -> `(collation-key ,@$1) ;