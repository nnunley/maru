;;; Generate C code only

(load "emit-c-threaded-minimal.l")
(compile-threaded '(+ 40 2))