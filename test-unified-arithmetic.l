;;; Test arithmetic with unified implementation

(load "emit-c-threaded.l")

;; Test arithmetic: (+ 40 2)
(compile-threaded '(+ 40 2))