/* Test UTF-8 functionality */
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "utf8.c"

int main() {
    printf("Testing UTF-8 functionality...\n");
    
    /* Test ASCII strings */
    const char *ascii = "Hello World";
    assert(utf8_strlen(ascii) == 11);
    printf("✓ ASCII length test passed\n");
    
    /* Test UTF-8 strings with multibyte characters */
    const char *utf8_mixed = "Hello 世界";  /* "Hello World" in English/Chinese */
    assert(utf8_strlen(utf8_mixed) == 8);  /* 6 ASCII + 2 Chinese chars */
    printf("✓ UTF-8 mixed length test passed\n");
    
    /* Test emoji */
    const char *emoji = "👋🌍";  /* Wave + Earth emoji */
    assert(utf8_strlen(emoji) == 2);
    printf("✓ Emoji length test passed\n");
    
    /* Test string duplication */
    char *dup = utf8_strdup(utf8_mixed);
    assert(strcmp(dup, utf8_mixed) == 0);
    printf("✓ UTF-8 string duplication test passed\n");
    free(dup);
    
    /* Test character indexing */
    const char *char_at_5 = utf8_char_at(utf8_mixed, 5);
    assert(*char_at_5 == ' ');
    printf("✓ UTF-8 character indexing test passed\n");
    
    /* Test codepoint conversion */
    uint32_t cp = utf8_char_to_codepoint("世");
    assert(cp == 0x4E16);  /* Unicode for "世" */
    printf("✓ UTF-8 to codepoint conversion test passed\n");
    
    /* Test wchar_t compatibility macros */
    char *converted = mbs2wcs("test");
    assert(strcmp(converted, "test") == 0);
    printf("✓ Compatibility macro test passed\n");
    
    printf("\n🎉 All UTF-8 tests passed!\n");
    return 0;
}