;;; eval2-utf8-integration-plan.l - Plan for eval2 with Maru's native UTF-8
;;;
;;; Combines:
;;; 1. eval2.c advanced features (FFI, Double, profiling)
;;; 2. Our multimethod emit-c.l backend
;;; 3. Maru's native UTF-8 implementation
;;; 4. Proper environment isolation

(println "=== EVAL2 REPLACEMENT WITH NATIVE UTF-8 ===")
(println)

(println "ARCHITECTURAL DECISION:")
(println "• Use Maru's native UTF-8 instead of eval2.c's wchar_t")
(println "• Pure UTF-8 throughout - no wide character conversions")
(println "• Better performance and smaller memory footprint")
(println "• Seamless integration with existing Maru code")
(println)

;;; ================================================================
;;; UTF-8 STRING TYPE FOR EMIT-C.L
;;; ================================================================

(println "=== 1. UTF-8 STRING COMPILATION ===")
(println)
(println "Add to emit-c.l multimethod dispatch:")
(println)
(println "(add-method compile-to-c <string>")
(println "  '(self backend)")
(println "  '((let ((port (<c-backend>-output-port backend)))")
(println "      (if (utf8-string? self)")
(println "          ;; UTF-8 string literal")
(println "          (let ()")
(println "            (port-write port \"make_utf8_string(\\\"\")")
(println "            (port-write port (escape-utf8-string self))")
(println "            (port-write port \"\\\")\")")
(println "          ;; Regular ASCII string")
(println "          (let ()")
(println "            (port-write port \"make_string(\\\"\")")
(println "            (port-write port self)")
(println "            (port-write port \"\\\")\"))))))")
(println)

;;; ================================================================
;;; UTF-8 SUPPORT FUNCTIONS
;;; ================================================================

(println "=== 2. UTF-8 RUNTIME SUPPORT ===")
(println)
(println "Generated C code would include:")
(println)
(println "/* UTF-8 String structure */")
(println "struct Utf8String {")
(println "    oop size;        /* Character count (not byte count) */")
(println "    oop byte_size;   /* Actual byte count */")
(println "    char *bytes;     /* UTF-8 encoded bytes */")
(println "};")
(println)
(println "/* Create UTF-8 string from literal */")
(println "static oop make_utf8_string(const char *utf8_bytes) {")
(println "    size_t byte_len = strlen(utf8_bytes);")
(println "    size_t char_len = utf8_strlen(utf8_bytes);")
(println "    struct Utf8String *str = GC_malloc(sizeof(struct Utf8String));")
(println "    str->size = newLong(char_len);")
(println "    str->byte_size = newLong(byte_len);")
(println "    str->bytes = GC_malloc_atomic(byte_len + 1);")
(println "    memcpy(str->bytes, utf8_bytes, byte_len + 1);")
(println "    return (oop)str;")
(println "}")
(println)

;;; ================================================================
;;; ENVIRONMENT-AWARE UTF-8 COMPILATION
;;; ================================================================

(println "=== 3. ENVIRONMENT INTEGRATION ===")
(println)
(println "Key insight: Compile UTF-8 operations in proper environment")
(println)
(println "(define-function compile-utf8-operation (op args backend)")
(println "  \"Compile UTF-8 operation with environment awareness\"")
(println "  (compile-begin)  ; Enter compilation environment")
(println "  ")
(println "  ;; All UTF-8 functions available in environment")
(println "  (let ((result")
(println "    (cond")
(println "      ((= op 'utf8-strlen)")
(println "       (compile-utf8-strlen args backend))")
(println "      ")
(println "      ((= op 'utf8-char-at)")
(println "       (compile-utf8-char-at args backend))")
(println "      ")
(println "      ((= op 'utf8-substring)")
(println "       (compile-utf8-substring args backend))")
(println "      ")
(println "      ((= op 'utf8-normalize)")
(println "       (compile-utf8-normalize args backend)))))")
(println "  ")
(println "  (compile-end)  ; Exit compilation environment")
(println "  result))")
(println)

;;; ================================================================
;;; ADVANTAGES OVER EVAL2.C APPROACH
;;; ================================================================

(println "=== 4. WHY NATIVE UTF-8 IS SUPERIOR ===")
(println)
(println "eval2.c approach (wchar_t):")
(println "• Requires conversion between UTF-8 and wide chars")
(println "• Platform-dependent wchar_t size (2 or 4 bytes)")
(println "• Memory overhead for wide character storage")
(println "• Complex locale dependencies")
(println)
(println "Our approach (native UTF-8):")
(println "• Direct UTF-8 throughout - no conversions")
(println "• Compact memory usage")
(println "• Platform-independent")
(println "• Faster string operations")
(println "• Natural integration with Maru")
(println)

;;; ================================================================
;;; FFI WITH UTF-8 STRINGS
;;; ================================================================

(println "=== 5. FFI INTEGRATION WITH UTF-8 ===")
(println)
(println "FFI calls with UTF-8 strings:")
(println)
(println "(define-function compile-ffi-call-utf8 (name sig args backend)")
(println "  \"Compile FFI call with UTF-8 string handling\"")
(println "  (let ((port (<c-backend>-output-port backend)))")
(println "    ;; Automatically handle UTF-8 → C string conversion")
(println "    (port-write port \"ffi_call_utf8(\")")
(println "    (port-write port name)")
(println "    (port-write port \", \")")
(println "    (compile-ffi-signature sig backend)")
(println "    (port-write port \", \")")
(println "    (compile-ffi-args-utf8 args backend)")
(println "    (port-write port \")\")))")
(println)

;;; ================================================================
;;; IMPLEMENTATION ROADMAP
;;; ================================================================

(println "=== 6. IMPLEMENTATION STEPS ===")
(println)
(println "Phase 1: UTF-8 String Type (1 week)")
(println "• Add UTF8String structure to emit-c.l")
(println "• Implement compile-to-c method for UTF-8 strings")
(println "• Generate UTF-8 runtime support functions")
(println "• Test with Maru's UTF-8 test suite")
(println)
(println "Phase 2: Environment Integration (3 days)")
(println "• Ensure all UTF-8 ops use compile-begin/end")
(println "• Track string encodings in environment")
(println "• Handle mixed ASCII/UTF-8 properly")
(println)
(println "Phase 3: Full eval2 Features (2 weeks)")
(println "• Add Double type (already demonstrated)")
(println "• Implement FFI with UTF-8 support")
(println "• Add profiling instrumentation")
(println "• Complete garbage collection integration")
(println)

;;; ================================================================
;;; EXAMPLE: COMPLETE UTF-8 EVAL2
;;; ================================================================

(println "=== 7. EXAMPLE OUTPUT ===")
(println)
(println "Input Maru code:")
(println "  (define hello \"Hello, 世界!\")")
(println "  (println (utf8-strlen hello))")
(println "  (println (utf8-char-at hello 7))")
(println)
(println "Generated C code:")
(println "  static oop v_hello = nil;")
(println "  ")
(println "  static void init_globals(void) {")
(println "      v_hello = make_utf8_string(\"Hello, 世界!\");")
(println "  }")
(println "  ")
(println "  int main() {")
(println "      init_globals();")
(println "      println(utf8_strlen(v_hello));  // Output: 9")
(println "      println(utf8_char_at(v_hello, LONG(7)));  // Output: 界")
(println "      return 0;")
(println "  }")
(println)

(println "=== CONCLUSION ===")
(println)
(println "By combining:")
(println "1. Our multimethod emit-c.l backend")
(println "2. Maru's native UTF-8 implementation")
(println "3. Proper environment isolation")
(println "4. eval2.c's advanced features")
(println)
(println "We create a superior eval2 replacement that:")
(println "• Generates clean, readable C code")
(println "• Supports full Unicode with native UTF-8")
(println "• Includes FFI, Double types, and profiling")
(println "• Maintains proper compilation environments")
(println "• Avoids wchar_t complexity entirely")
(println)
(println "This is the optimal architecture for modern Maru!")
(println "=======================================================")