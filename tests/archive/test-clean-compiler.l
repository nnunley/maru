;;; test-clean-compiler.l - Test the clean threaded C compiler

(load "emit-c-threaded-clean.l")

;; Generate C code
(compile-clean '(+ 40 2))