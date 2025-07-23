;; Interactive REPL for Maru
;; Load the REPL infrastructure
(load "lib/repl.l")

;; Remove the (exit 0) by redefining the end behavior
;; Create an interactive REPL with stdin
(if (= 0 (list-length *arguments*))
    ;; No arguments - start interactive REPL
    (let ()
      (println "Maru Interactive REPL")
      (println "Type S-expressions, Ctrl-D to exit")
      (repl-stream *input* "> "))
  ;; Arguments provided - load files as before
  (while *arguments* 
    (repl-path (next-argument) ())))