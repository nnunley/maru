;;; test-c-high-simple.l -- Simple test for high-level C backend

(require "boot.l")
(require "emit.l")
(require "emit-c-high.l")

;; Test basic expression generation
(println "=== Testing C Expression Generation ===")
(println)

;; Test literals
(println "Literal 42: " (c-gen-expr 42))
(println "String literal: " (c-gen-expr "hello"))
(println)

;; Test basic function call
(println "=== Testing Direct C Generation ===")
(println "/* Generated high-level C code */")
(println "#include <stdio.h>")
(println "#include <stdlib.h>")
(println)
(println "typedef union Object *oop;")
(println "#define nil ((oop)0)")  
(println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
(println "#define getLong(x) ((long)(x) >> 1)")
(println)

;; Test simple function generation
(println "oop add(oop a, oop b) {")
(set *c-indent-level* 1)
(c-emit-line "return LONG(getLong(a) + getLong(b));")
(set *c-indent-level* 0)
(println "}")
(println)

(println "int main() {")
(set *c-indent-level* 1)
(c-emit-line "oop result = add(LONG(40), LONG(2));")
(c-emit-line "printf(\"Result: %ld\\n\", getLong(result));")
(c-emit-line "return 0;")
(set *c-indent-level* 0)
(println "}")

(println)
(println "=== Test completed ===")