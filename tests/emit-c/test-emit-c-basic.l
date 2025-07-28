;;; test-emit-c-basic.l - Basic test of emit-c.l loading

(load "boot.l")
(require "lib/stream/port.l")

(println "Testing emit-c.l loading...")
(load "core/compiler/emit-c.l")
(println "emit-c.l loaded successfully!")

;; Test simple expression compilation
(println "Testing simple expression...")
(let ((output (string-port)))
  (compile-maru-expression '(+ 1 2) output)
  (println "Generated C code:")
  (println (port-contents output)))