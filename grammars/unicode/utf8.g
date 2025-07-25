# UTF-8 Grammar for Maru
# Parses UTF-8 byte sequences and generates character code points

# UTF-8 byte patterns:
# 0xxxxxxx                     - ASCII (1 byte)
# 110xxxxx 10xxxxxx            - 2 bytes
# 1110xxxx 10xxxxxx 10xxxxxx  - 3 bytes
# 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx - 4 bytes

# Single byte (ASCII)
ascii = < [\x00-\x7F] >
    -> (string->number $1 16) ;

# Continuation byte
continuation = [\x80-\xBF]

# 2-byte sequence
utf8_2 = < [\xC0-\xDF] > continuation:c1
    -> (+ (bitwise-shift-left (bitwise-and (string->number $1 16) 31) 6)
          (bitwise-and c1 63)) ;

# 3-byte sequence  
utf8_3 = < [\xE0-\xEF] > continuation:c1 continuation:c2
    -> (+ (bitwise-shift-left (bitwise-and (string->number $1 16) 15) 12)
          (bitwise-shift-left (bitwise-and c1 63) 6)
          (bitwise-and c2 63)) ;

# 4-byte sequence
utf8_4 = < [\xF0-\xF7] > continuation:c1 continuation:c2 continuation:c3
    -> (+ (bitwise-shift-left (bitwise-and (string->number $1 16) 7) 18)
          (bitwise-shift-left (bitwise-and c1 63) 12)
          (bitwise-shift-left (bitwise-and c2 63) 6)
          (bitwise-and c3 63)) ;

# Any UTF-8 character
utf8_char = utf8_4 | utf8_3 | utf8_2 | ascii

# UTF-8 string (sequence of characters)
utf8_string = utf8_char*
    -> (apply list $1) ;