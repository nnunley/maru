;;; Simple test of threaded backend in eval2

(load "emit-c-threaded.l")
(compile-threaded '(+ 40 2))