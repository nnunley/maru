/* UTF-8 Validation Test
 * Compares our implementation against standard references
 */

#include <stdio.h>
#include <string.h>
#include <wchar.h>
#include <locale.h>
#include <assert.h>
#include <stdint.h>
#include <time.h>

/* Include our UTF-8 library */
#include "utf8.c"

/* Test vectors from Unicode standard */
typedef struct {
    const char* utf8;
    uint32_t codepoint;
    int byte_length;
    const char* description;
} utf8_test_vector;

static utf8_test_vector test_vectors[] = {
    /* Basic ASCII */
    {"A", 0x41, 1, "ASCII capital A"},
    {"z", 0x7A, 1, "ASCII lowercase z"},
    {"0", 0x30, 1, "ASCII digit 0"},
    {" ", 0x20, 1, "ASCII space"},
    
    /* 2-byte sequences */
    {"\xC2\xA2", 0xA2, 2, "Cent sign"},
    {"\xC3\xA9", 0xE9, 2, "Latin small e with acute"},
    {"\xD0\x96", 0x416, 2, "Cyrillic capital ZHE"},
    
    /* 3-byte sequences */
    {"\xE2\x82\xAC", 0x20AC, 3, "Euro sign"},
    {"\xE4\xB8\xAD", 0x4E2D, 3, "CJK ideograph 中"},
    {"\xE3\x81\x82", 0x3042, 3, "Hiragana letter A"},
    {"\xED\x95\x9C", 0xD55C, 3, "Hangul syllable HAN"},
    
    /* 4-byte sequences */
    {"\xF0\x9F\x98\x80", 0x1F600, 4, "Grinning face emoji"},
    {"\xF0\x9F\x8C\x8D", 0x1F30D, 4, "Earth globe emoji"},
    {"\xF0\x9D\x84\x9E", 0x1D11E, 4, "Musical symbol G clef"},
    
    /* Edge cases */
    {"\x7F", 0x7F, 1, "ASCII DEL"},
    {"\xC2\x80", 0x80, 2, "First 2-byte sequence"},
    {"\xDF\xBF", 0x7FF, 2, "Last 2-byte sequence"},
    {"\xE0\xA0\x80", 0x800, 3, "First 3-byte sequence"},
    {"\xEF\xBF\xBF", 0xFFFF, 3, "Last 3-byte sequence"},
    {"\xF0\x90\x80\x80", 0x10000, 4, "First 4-byte sequence"},
    {"\xF4\x8F\xBF\xBF", 0x10FFFF, 4, "Last valid Unicode"},
    
    {NULL, 0, 0, NULL}
};

/* Normalization test cases */
typedef struct {
    const char* denormalized;
    const char* nfc;
    const char* nfd;
    const char* description;
} normalization_test;

static normalization_test norm_tests[] = {
    /* Precomposed vs decomposed */
    {"café", "café", "café", "French word with e-acute"},
    {"Åström", "Åström", "Åström", "Swedish name with ring"},
    
    /* Multiple combining marks */
    {"ệ", "ệ", "ệ", "Vietnamese e with circumflex and dot below"},
    
    /* Hangul */
    {"한글", "한글", "한글", "Korean word 'Hangul'"},
    
    {NULL, NULL, NULL, NULL}
};

/* Collation test cases */
typedef struct {
    const char* str1;
    const char* str2;
    int expected;  /* -1, 0, 1 */
    const char* locale;
    const char* description;
} collation_test;

static collation_test collation_tests[] = {
    /* Basic Latin */
    {"apple", "Apple", 1, "en_US", "Lowercase after uppercase"},
    {"abc", "xyz", -1, "en_US", "Alphabetical order"},
    
    /* Accented characters */
    {"cafe", "café", -1, "fr_FR", "Unaccented before accented"},
    {"élève", "eleve", 1, "fr_FR", "Accented after unaccented"},
    
    /* German */
    {"Müller", "Mueller", 1, "de_DE", "Umlaut after expanded form"},
    
    /* Numbers */
    {"file1", "file10", -1, "en_US", "Natural number sort"},
    
    /* Mixed scripts */
    {"Latin", "Ελληνικά", -1, "en_US", "Latin before Greek"},
    {"ABC", "中文", -1, "zh_CN", "Latin before Chinese"},
    
    {NULL, NULL, 0, NULL, NULL}
};

/* Test UTF-8 decoding */
void test_utf8_decoding() {
    printf("=== UTF-8 Decoding Test ===\n");
    int passed = 0, failed = 0;
    
    for (int i = 0; test_vectors[i].utf8; i++) {
        utf8_test_vector* tv = &test_vectors[i];
        int len;
        uint32_t decoded = utf8_decode_char((const unsigned char*)tv->utf8, &len);
        
        if (decoded == tv->codepoint && len == tv->byte_length) {
            passed++;
            printf("✓ %s: U+%04X (%d bytes)\n", tv->description, decoded, len);
        } else {
            failed++;
            printf("✗ %s: expected U+%04X (%d bytes), got U+%04X (%d bytes)\n",
                   tv->description, tv->codepoint, tv->byte_length, decoded, len);
        }
    }
    
    printf("Passed: %d, Failed: %d\n\n", passed, failed);
}

/* Test string length calculation */
void test_string_length() {
    printf("=== String Length Test ===\n");
    
    struct {
        const char* str;
        size_t expected_chars;
        const char* description;
    } length_tests[] = {
        {"Hello", 5, "ASCII string"},
        {"café", 4, "French with accent"},
        {"你好", 2, "Chinese greeting"},
        {"👋🌍", 2, "Two emoji"},
        {"Hello 世界", 8, "Mixed ASCII and CJK"},
        {"مرحبا", 5, "Arabic greeting"},
        {NULL, 0, NULL}
    };
    
    for (int i = 0; length_tests[i].str; i++) {
        size_t len = utf8_strlen(length_tests[i].str);
        printf("%s '%s': %zu chars (expected %zu) %s\n",
               length_tests[i].description,
               length_tests[i].str,
               len,
               length_tests[i].expected_chars,
               len == length_tests[i].expected_chars ? "✓" : "✗");
    }
    printf("\n");
}

/* Test collation against strcoll */
void test_collation() {
    printf("=== Collation Test ===\n");
    
    /* Set locale for strcoll comparison */
    setlocale(LC_COLLATE, "en_US.UTF-8");
    
    for (int i = 0; collation_tests[i].str1; i++) {
        collation_test* ct = &collation_tests[i];
        
        /* Our implementation */
        int our_result = utf8_compare_locale(ct->str1, ct->str2, ct->locale);
        int our_sign = (our_result > 0) - (our_result < 0);
        
        /* Standard strcoll (only works for current locale) */
        int std_result = strcoll(ct->str1, ct->str2);
        int std_sign = (std_result > 0) - (std_result < 0);
        
        printf("%s: '%s' vs '%s' (%s)\n", ct->description, ct->str1, ct->str2, ct->locale);
        printf("  Our result: %d, strcoll: %d %s\n",
               our_sign, std_sign,
               our_sign == ct->expected ? "✓" : "✗");
    }
    printf("\n");
}

/* Test Unicode properties */
void test_unicode_properties() {
    printf("=== Unicode Properties Test ===\n");
    
    struct {
        uint32_t codepoint;
        unicode_script expected;
        const char* description;
    } property_tests[] = {
        {0x0041, SCRIPT_LATIN, "Latin A"},
        {0x03B1, SCRIPT_GREEK, "Greek alpha"},
        {0x0410, SCRIPT_CYRILLIC, "Cyrillic A"},
        {0x05D0, SCRIPT_HEBREW, "Hebrew alef"},
        {0x0627, SCRIPT_ARABIC, "Arabic alef"},
        {0x3042, SCRIPT_HIRAGANA, "Hiragana A"},
        {0x30A2, SCRIPT_KATAKANA, "Katakana A"},
        {0x4E00, SCRIPT_HAN, "CJK ideograph"},
        {0xAC00, SCRIPT_HANGUL, "Hangul syllable"},
        {0x1F600, SCRIPT_EMOJI, "Grinning face"},
        {0, 0, NULL}
    };
    
    for (int i = 0; property_tests[i].description; i++) {
        unicode_script script = get_script(property_tests[i].codepoint);
        printf("%s (U+%04X): %s\n",
               property_tests[i].description,
               property_tests[i].codepoint,
               script == property_tests[i].expected ? "✓" : "✗");
    }
    printf("\n");
}

/* Performance comparison */
void test_performance() {
    printf("=== Performance Test ===\n");
    
    const char* test_string = "Hello 你好 مرحبا 🌍 Здравствуйте";
    const int iterations = 100000;
    clock_t start, end;
    
    /* Our UTF-8 strlen */
    start = clock();
    for (int i = 0; i < iterations; i++) {
        utf8_strlen(test_string);
    }
    end = clock();
    double our_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    
    /* Standard strlen (byte count) */
    start = clock();
    for (int i = 0; i < iterations; i++) {
        strlen(test_string);
    }
    end = clock();
    double std_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    
    printf("String: '%s'\n", test_string);
    printf("Iterations: %d\n", iterations);
    printf("Our UTF-8 strlen: %.4f seconds\n", our_time);
    printf("Standard strlen:  %.4f seconds\n", std_time);
    printf("Ratio: %.2fx slower\n\n", our_time / std_time);
}

int main() {
    printf("UTF-8 Implementation Validation\n");
    printf("===============================\n\n");
    
    test_utf8_decoding();
    test_string_length();
    test_unicode_properties();
    test_collation();
    test_performance();
    
    printf("Validation complete!\n");
    return 0;
}