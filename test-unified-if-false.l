;;; Test false conditional with unified implementation

(load "emit-c-threaded.l")

;; Test conditional: (if 0 42 99)
(compile-threaded '(if 0 42 99))