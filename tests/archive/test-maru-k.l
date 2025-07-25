;;; Test if maru.k infrastructure works

(load "boot.l")

(println "Testing maru.k infrastructure...")

;; First test - can we load ir.k?
(println "Loading ir.k...")
(if (load "core/compiler/ir.k")
    (println "ir.k loaded successfully")
  (println "Failed to load ir.k"))

;; Second test - can we load maru.k?
(println "Loading maru.k...")
(if (load "core/maru.k")
    (println "maru.k loaded successfully")
  (println "Failed to load maru.k"))

(println "Done.")