;;; Test conditional with unified implementation

(load "emit-c-threaded.l")

;; Test conditional: (if 1 42 0)
(compile-threaded '(if 1 42 0))