;;; Test meta-compilation of a simple eval expression

(load "emit-c-threaded.l")

;; Try to compile a simple expression that eval.l might contain
(compile-threaded '(if (long? x) x 0))