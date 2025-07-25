;; Debug what form we get for if expression
(require "core/compiler/emit.l")

;; Test what we get for if
(compile-begin)

;; Use define to see what if resolves to
(println "Testing if form:")
(dumpln if)
(println "Testing (if 1 2 3):")
(dumpln '(if 1 2 3))

(compile-end)