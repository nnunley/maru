#!/usr/bin/env eval
;;; test-simple-gc-emitter.l -- Test the simplified GC C emitter

(load "emit-gc-c-simple.l")

;;; Generate the high-fidelity GC C program
(generate-gc-c-program)