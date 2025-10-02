;;; test-cps-c.l -- Test continuation-passing style C backend

(require "boot.l")
(require "emit-c-cps.l")

;; Generate CPS C code with call/cc
(generate-cps-function)
(c-gen-callcc)