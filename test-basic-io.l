;;; test-basic-io.l -- Test basic I/O capabilities

(println "Testing basic I/O functions...")

;; Test open
(println "Checking for 'open' function...")
(if (defined? open)
    (println "  open is defined")
  (println "  open is NOT defined"))

;; Test file operations from boot.l
(println "\nLooking for file functions in boot.l...")

;; Try load to see if it gives us file I/O
(load "boot.l")

(println "\nAfter loading boot.l:")
(if (defined? open)
    (println "  open is defined")
  (println "  open is NOT defined"))

;; Let's create assembly using only println
(println "\n=== ARM64 Assembly Output ===")
(println "\t.section\t__TEXT,__text,regular,pure_instructions")
(println "\t.build_version macos, 11, 0")
(println "\t.globl\t_main")
(println "\t.p2align\t2")
(println "_main:")
(println "\tmov\tw0, #42")
(println "\tret")
(println "=== End Assembly ===")

(println "\nSave the above assembly to return42.s and compile with:")
(println "  clang -o return42 return42.s")