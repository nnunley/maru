/* Simple UTF-8 Validation Test
 * Tests our UTF-8 implementation
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <time.h>

/* Include our UTF-8 library */
#include "utf8.c"

/* Test UTF-8 decoding */
void test_utf8_decoding() {
    printf("=== UTF-8 Decoding Test ===\n");
    
    struct {
        const char* utf8;
        uint32_t expected_codepoint;
        int expected_length;
        const char* description;
    } test_cases[] = {
        {"A", 0x41, 1, "ASCII capital A"},
        {"€", 0x20AC, 3, "Euro sign"},
        {"中", 0x4E2D, 3, "CJK ideograph"},
        {"𝄞", 0x1D11E, 4, "Musical symbol G clef"},
        {NULL, 0, 0, NULL}
    };
    
    int passed = 0, failed = 0;
    
    for (int i = 0; test_cases[i].utf8; i++) {
        int len;
        uint32_t decoded = maru_utf8_decode_char((const unsigned char*)test_cases[i].utf8, &len);
        
        if (decoded == test_cases[i].expected_codepoint && len == test_cases[i].expected_length) {
            passed++;
            printf("✓ %s: U+%04X (%d bytes)\n", test_cases[i].description, decoded, len);
        } else {
            failed++;
            printf("✗ %s: expected U+%04X (%d bytes), got U+%04X (%d bytes)\n",
                   test_cases[i].description, test_cases[i].expected_codepoint, 
                   test_cases[i].expected_length, decoded, len);
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
    } test_cases[] = {
        {"Hello", 5, "ASCII string"},
        {"café", 4, "French with accent"},
        {"你好", 2, "Chinese greeting"},
        {"👋🌍", 2, "Two emoji"},
        {"Hello 世界", 8, "Mixed ASCII and CJK"},
        {"مرحبا", 5, "Arabic greeting"},
        {NULL, 0, NULL}
    };
    
    for (int i = 0; test_cases[i].str; i++) {
        size_t len = maru_utf8_strlen(test_cases[i].str);
        printf("%s '%s': %zu chars (expected %zu) %s\n",
               test_cases[i].description,
               test_cases[i].str,
               len,
               test_cases[i].expected_chars,
               len == test_cases[i].expected_chars ? "✓" : "✗");
    }
    printf("\n");
}

/* Test Unicode script detection */
void test_unicode_scripts() {
    printf("=== Unicode Script Detection ===\n");
    
    struct {
        uint32_t codepoint;
        unicode_script expected;
        const char* description;
    } test_cases[] = {
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
    
    for (int i = 0; test_cases[i].description; i++) {
        unicode_script script = maru_get_script(test_cases[i].codepoint);
        printf("%s (U+%04X): %s\n",
               test_cases[i].description,
               test_cases[i].codepoint,
               script == test_cases[i].expected ? "✓" : "✗");
    }
    printf("\n");
}

/* Test end-to-end with Maru */
void test_maru_integration() {
    printf("=== Maru Integration Test ===\n");
    
    const char* test_strings[] = {
        "Hello World",
        "Bonjour le monde",
        "你好世界",
        "مرحبا بالعالم",
        "こんにちは世界",
        "🌍🌎🌏",
        NULL
    };
    
    printf("Testing UTF-8 strings that Maru will use:\n");
    for (int i = 0; test_strings[i]; i++) {
        size_t char_count = maru_utf8_strlen(test_strings[i]);
        size_t byte_count = strlen(test_strings[i]);
        printf("  \"%s\": %zu chars, %zu bytes\n", 
               test_strings[i], char_count, byte_count);
    }
    printf("\n");
}

int main() {
    printf("UTF-8 Implementation Test\n");
    printf("========================\n\n");
    
    test_utf8_decoding();
    test_string_length();
    test_unicode_scripts();
    test_maru_integration();
    
    printf("All tests complete!\n");
    return 0;
}