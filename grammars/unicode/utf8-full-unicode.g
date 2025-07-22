# Full Unicode UTF-8 Grammar for Maru
# Handles CJK, Emoji, RTL languages, and all Unicode planes

# UTF-8 byte sequences
utf8_1 = [\x00-\x7F]                                    # ASCII: 0xxxxxxx
utf8_2 = [\xC0-\xDF] [\x80-\xBF]                       # 2-byte: 110xxxxx 10xxxxxx
utf8_3 = [\xE0-\xEF] [\x80-\xBF] [\x80-\xBF]          # 3-byte: 1110xxxx 10xxxxxx 10xxxxxx
utf8_4 = [\xF0-\xF7] [\x80-\xBF] [\x80-\xBF] [\x80-\xBF]  # 4-byte: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

# Decode UTF-8 to codepoint
utf8_char = utf8_4:b4 -> `(codepoint ,(decode-utf8-4 b4)) ;
          | utf8_3:b3 -> `(codepoint ,(decode-utf8-3 b3)) ;
          | utf8_2:b2 -> `(codepoint ,(decode-utf8-2 b2)) ;
          | utf8_1:b1 -> `(codepoint ,(char-code b1)) ;

# Unicode blocks for categorization
ascii_block     = codepoint:cp ?(< cp 128)             -> `(ascii ,cp) ;
latin_ext       = codepoint:cp ?(and (>= cp 128) (< cp 592))   -> `(latin-extended ,cp) ;
arabic_block    = codepoint:cp ?(and (>= cp 1536) (< cp 1792)) -> `(arabic ,cp rtl) ;
hebrew_block    = codepoint:cp ?(and (>= cp 1424) (< cp 1536)) -> `(hebrew ,cp rtl) ;

# CJK Unified Ideographs
cjk_unified     = codepoint:cp ?(and (>= cp 19968) (< cp 40960))  -> `(cjk-unified ,cp) ;
cjk_ext_a       = codepoint:cp ?(and (>= cp 13312) (< cp 19904))  -> `(cjk-ext-a ,cp) ;
cjk_ext_b       = codepoint:cp ?(and (>= cp 131072) (< cp 173792)) -> `(cjk-ext-b ,cp) ;

# Japanese specific blocks
hiragana        = codepoint:cp ?(and (>= cp 12352) (< cp 12448))  -> `(hiragana ,cp) ;
katakana        = codepoint:cp ?(and (>= cp 12448) (< cp 12544))  -> `(katakana ,cp) ;
kanji           = cjk_unified  # Kanji uses CJK unified ideographs

# Korean Hangul
hangul_syllable = codepoint:cp ?(and (>= cp 44032) (< cp 55204))  -> `(hangul ,cp) ;
hangul_jamo     = codepoint:cp ?(and (>= cp 4352) (< cp 4608))    -> `(hangul-jamo ,cp) ;

# Emoji blocks (various ranges)
emoji_misc      = codepoint:cp ?(and (>= cp 9728) (< cp 9984))    -> `(emoji ,cp) ;
emoji_pictograph = codepoint:cp ?(and (>= cp 128512) (< cp 128592)) -> `(emoji ,cp) ;
emoji_supplement = codepoint:cp ?(and (>= cp 129280) (< cp 129536)) -> `(emoji ,cp) ;

# Bidirectional markers
ltr_mark = "\xE2\x80\x8E"  -> `(bidi ltr) ;    # U+200E LEFT-TO-RIGHT MARK
rtl_mark = "\xE2\x80\x8F"  -> `(bidi rtl) ;    # U+200F RIGHT-TO-LEFT MARK
ltr_embed = "\xE2\x80\xAA" -> `(bidi ltr-embed) ;  # U+202A
rtl_embed = "\xE2\x80\xAB" -> `(bidi rtl-embed) ;  # U+202B
pop_dir   = "\xE2\x80\xAC" -> `(bidi pop) ;        # U+202C

# Character classification
unicode_char = emoji_pictograph
             | emoji_supplement
             | emoji_misc
             | cjk_ext_b
             | hangul_syllable
             | cjk_unified
             | kanji
             | katakana
             | hiragana
             | hangul_jamo
             | cjk_ext_a
             | arabic_block
             | hebrew_block
             | latin_ext
             | ascii_block
             | ltr_mark
             | rtl_mark
             | ltr_embed
             | rtl_embed
             | pop_dir

# Collation weights for different scripts
char_weight = unicode_char:uc
    -> (case (car uc)
         ((ascii) `(weight ,(cadr uc) 0 0))
         ((latin-extended) `(weight ,(cadr uc) 1 0))
         ((arabic hebrew) `(weight ,(cadr uc) 2 0 ,(caddr uc)))
         ((hiragana) `(weight ,(+ 100000 (cadr uc)) 0 0))
         ((katakana) `(weight ,(+ 110000 (cadr uc)) 0 0))
         ((cjk-unified kanji) `(weight ,(+ 200000 (cadr uc)) 0 0))
         ((hangul) `(weight ,(+ 300000 (cadr uc)) 0 0))
         ((emoji) `(weight ,(+ 400000 (cadr uc)) 0 0))
         (else `(weight ,(cadr uc) 0 0))) ;

# String parsing with direction handling
unicode_string = char_weight*
    -> `(unicode-string ,@$1) ;