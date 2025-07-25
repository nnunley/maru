/* UTF-8 String Handling for Maru
 * Replaces wcs.c wide character handling
 * Pure UTF-8 implementation - more space efficient
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>

/* Forward declaration for external use */
size_t maru_utf8_strlen(const char *str);

/* UTF-8 string length in Unicode code points (not bytes) */
size_t maru_utf8_strlen(const char *str)
{
    size_t len = 0;
    const unsigned char *s = (const unsigned char *)str;
    
    while (*s) {
        if (*s < 0x80) {
            s++;
        } else if (*s < 0xE0) {
            s += 2;
        } else if (*s < 0xF0) {
            s += 3;
        } else {
            s += 4;
        }
        len++;
    }
    return len;
}

/* UTF-8 string copy */
static char *maru_utf8_strcpy(char *dst, const char *src)
{
    char *orig_dst = dst;
    while ((*dst++ = *src++));
    return orig_dst;
}

/* UTF-8 string duplicate */
static char *maru_utf8_strdup(const char *src)
{
    size_t len = strlen(src) + 1;  /* byte length, not character length */
    char *dst = (char *)malloc(len);
    if (dst) strcpy(dst, src);
    return dst;
}

/* Get UTF-8 character at index (returns pointer to character start) */
static const char *maru_utf8_char_at(const char *str, size_t index)
{
    const unsigned char *s = (const unsigned char *)str;
    size_t i = 0;
    
    while (*s && i < index) {
        if (*s < 0x80) {
            s++;
        } else if (*s < 0xE0) {
            s += 2;
        } else if (*s < 0xF0) {
            s += 3;
        } else {
            s += 4;
        }
        i++;
    }
    return (const char *)s;
}

/* Convert single UTF-8 character to Unicode code point */
static uint32_t maru_utf8_char_to_codepoint(const char *utf8_char)
{
    const unsigned char *s = (const unsigned char *)utf8_char;
    
    if (*s < 0x80) {
        return *s;
    } else if (*s < 0xE0) {
        return ((*s & 0x1F) << 6) | (s[1] & 0x3F);
    } else if (*s < 0xF0) {
        return ((*s & 0x0F) << 12) | ((s[1] & 0x3F) << 6) | (s[2] & 0x3F);
    } else {
        return ((*s & 0x07) << 18) | ((s[1] & 0x3F) << 12) | 
               ((s[2] & 0x3F) << 6) | (s[3] & 0x3F);
    }
}

/* No-op conversions since we're staying in UTF-8 */
static char *mbs_to_utf8(const char *mbs)
{
    /* For now, assume input is already UTF-8 */
    /* In a full implementation, we'd detect encoding and convert */
    static char *utf8_buf = 0;
    static size_t buf_size = 0;
    
    size_t len = strlen(mbs) + 1;
    if (buf_size < len) {
        utf8_buf = utf8_buf ? 
            (char *)realloc(utf8_buf, len) :
            (char *)malloc(len);
        buf_size = len;
    }
    strcpy(utf8_buf, mbs);
    return utf8_buf;
}

static char *utf8_to_mbs(const char *utf8)
{
    /* For output, we keep UTF-8 */
    typedef struct { char *mbs; size_t size; } buf_t;
    static buf_t bufs[32] = {{0,0}};
    static int buf_index = 0;
    
    buf_t *buf = &bufs[buf_index++];
    if (buf_index >= 32) buf_index = 0;
    
    size_t len = strlen(utf8) + 1;
    if (buf->size < len) {
        buf->mbs = buf->mbs ? 
            (char *)realloc(buf->mbs, len) :
            (char *)malloc(len);
        buf->size = len;
    }
    strcpy(buf->mbs, utf8);
    return buf->mbs;
}

/* Size calculation helper for UTF-8 strings */
static size_t maru_utf8_byte_length(const char *str)
{
    return strlen(str);  /* UTF-8 byte length */
}

/* Compatibility macros for the migration from wchar_t */
#define mbs2wcs(mbs) mbs_to_utf8(mbs)
#define wcs2mbs(utf8) utf8_to_mbs(utf8)
#define wcslen(utf8) maru_utf8_strlen(utf8)
#define wcscpy(dst, src) maru_utf8_strcpy(dst, src)
#define wcsdup(src) maru_utf8_strdup(src)
#define wcslen_bytes(utf8) maru_utf8_byte_length(utf8)

/* UTF-8 string comparison */
static int maru_utf8_strcmp(const char *s1, const char *s2)
{
    return strcmp(s1, s2);  /* UTF-8 byte comparison is sufficient for equality */
}

/* Wide character I/O emulation for UTF-8 */
typedef int wint_t;  /* UTF-8 character as int */
#define WEOF (-1)

static wint_t getwc(FILE *fp)
{
    return fgetc(fp);  /* For now, read single bytes */
}

static wint_t ungetwc(wint_t c, FILE *fp)
{
    return ungetc(c, fp);
}

static int putwc(wint_t c, FILE *fp)
{
    return fputc(c, fp);
}

/* String to number conversions for UTF-8 */
static double wcstod(const char *str, char **endptr)
{
    return strtod(str, endptr);
}

static unsigned long wcstoul(const char *str, char **endptr, int base)
{
    return strtoul(str, endptr, base);
}

/* Wide I/O mode setting - return success for UTF-8 */
static int fwide(FILE *stream, int mode)
{
    (void)stream;  /* Suppress unused parameter warning */
    return mode;   /* Return the requested mode to indicate success */
}

/* Printf-style formatting for UTF-8 (simplified) */
static int swprintf(char *buf, size_t size, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    int result = vsnprintf(buf, size, fmt, args);
    va_end(args);
    return result;
}

/* Compatibility macros for the migration from wchar_t */
#define wcscmp(s1, s2) maru_utf8_strcmp(s1, s2)


/* Replace wchar_t with char for UTF-8 strings */
#define wchar_t char

/* Additional functions for validation test */

/* UTF-8 character length from first byte */
static inline int maru_utf8_char_length(unsigned char c) {
    if (c < 0x80) return 1;
    if (c < 0xE0) return 2;
    if (c < 0xF0) return 3;
    if (c < 0xF8) return 4;
    return 0; /* Invalid */
}

/* Decode UTF-8 sequence to codepoint */
static uint32_t maru_utf8_decode_char(const unsigned char* s, int* len) {
    int n = maru_utf8_char_length(s[0]);
    uint32_t cp = 0;
    *len = n;
    switch(n) {
        case 1: cp = s[0]; break;
        case 2: cp = ((s[0] & 0x1F) << 6) | (s[1] & 0x3F); break;
        case 3: cp = ((s[0] & 0x0F) << 12) | ((s[1] & 0x3F) << 6) | (s[2] & 0x3F); break;
        case 4: cp = ((s[0] & 0x07) << 18) | ((s[1] & 0x3F) << 12) | ((s[2] & 0x3F) << 6) | (s[3] & 0x3F); break;
        default: *len = 1; cp = 0xFFFD; /* Replacement character */
    }
    return cp;
}

/* Unicode properties for test */
typedef enum {
    SCRIPT_COMMON, SCRIPT_LATIN, SCRIPT_GREEK, SCRIPT_CYRILLIC,
    SCRIPT_HEBREW, SCRIPT_ARABIC, SCRIPT_DEVANAGARI,
    SCRIPT_HIRAGANA, SCRIPT_KATAKANA, SCRIPT_HAN,
    SCRIPT_HANGUL, SCRIPT_EMOJI
} unicode_script;

/* Get script for codepoint */
static unicode_script maru_get_script(uint32_t cp) {
    if (cp < 0x80) return SCRIPT_LATIN;
    if (cp >= 0x0370 && cp < 0x0400) return SCRIPT_GREEK;
    if (cp >= 0x0400 && cp < 0x0530) return SCRIPT_CYRILLIC;
    if (cp >= 0x0590 && cp < 0x0600) return SCRIPT_HEBREW;
    if (cp >= 0x0600 && cp < 0x0700) return SCRIPT_ARABIC;
    if (cp >= 0x3040 && cp < 0x30A0) return SCRIPT_HIRAGANA;
    if (cp >= 0x30A0 && cp < 0x3100) return SCRIPT_KATAKANA;
    if (cp >= 0x4E00 && cp < 0xA000) return SCRIPT_HAN;
    if (cp >= 0xAC00 && cp < 0xD7B0) return SCRIPT_HANGUL;
    if (cp >= 0x1F600 && cp < 0x1F650) return SCRIPT_EMOJI;
    return SCRIPT_COMMON;
}

/* Simple collation for testing */
static int maru_utf8_compare_locale(const char* s1, const char* s2, const char* locale) {
    (void)locale; /* Ignore locale for now */
    return strcmp(s1, s2);
}