;;; test-threaded-c.l -- Test threaded execution C backend

(require "boot.l")
(require "emit-c-threaded.l")

;; Generate threaded C code
(generate-threaded-function)