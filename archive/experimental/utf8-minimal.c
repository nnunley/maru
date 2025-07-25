/* Minimal UTF-8 support for Maru */

/* UTF-8 character length calculation */
static inline size_t utf8_strlen(const char *str) {
    size_t len = 0;
    const unsigned char *s = (const unsigned char *)str;
    while (*s) {
        if (*s < 0x80) s++;
        else if (*s < 0xE0) s += 2;
        else if (*s < 0xF0) s += 3;
        else s += 4;
        len++;
    }
    return len;
}

/* Minimal compatibility mappings */
#define wchar_t char
#define wcslen(s) utf8_strlen(s)
#define wcscmp(s1, s2) strcmp(s1, s2)
#define wcscpy(dst, src) strcpy(dst, src)
#define wcsdup(s) strdup(s)

/* Wide I/O stubs */
typedef int wint_t;
#define getwc(fp) fgetc(fp)
#define ungetwc(c, fp) ungetc(c, fp)
#define putwc(c, fp) fputc(c, fp)
#define fwide(stream, mode) (mode)
#define wcstod(str, endptr) strtod(str, endptr)
#define wcstoul(str, endptr, base) strtoul(str, endptr, base)
#define swprintf snprintf
