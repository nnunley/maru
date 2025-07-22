;;; Simple C backend test without full compilation

(require "boot.l")
(require "emit.l")
(require "emit-c.l")

;; Test C code generation directly
(println "/* Generated C test */")
(println "#include <stdio.h>")
(println "#include <stdlib.h>")
(println "typedef union Object *oop;")
(println "#define nil ((oop)0)")
(println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
(println "#define getLong(x) ((long)(x) >> 1)")
(println)

(println "int main() {")
(println "  oop _acc = nil;")

;; Test basic C emit operations
(emit LOAD LI32 42)
(emit NEG)

(println "  printf(\"Result: %ld\\n\", getLong(_acc));")
(println "  return 0;")
(println "}")