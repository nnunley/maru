;;; test-unified-threaded.l - Test the unified threaded implementation

(load "emit-c-threaded.l")

;; Test 1: Simple literal - generate only the C code
(compile-threaded 42)