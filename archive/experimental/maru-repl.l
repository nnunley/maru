;; Interactive REPL for Maru base system
;; Usage: ./eval boot.l maru-repl.l

;; Load necessary components
(load "lib/parser.l")
(load "lib/peg-compile.l") 
(load "lib/peg.l")

;; Define the REPL functions from repl.l without the exit
(define *parser-stream*)

(define-function repl-parser-stream (stream prompt)
  (let ((p (parser <peg> stream))
        (s *parser-stream*)
        (v))
    (set *parser-stream* stream)
    (while (let ()
             (and prompt (print prompt))
             ($sexpression p))
      (set v (<parser>-result p))
      (set v (eval v))
      (println " => "v))
    ($sspace p)
    (or (parser-stream-at-end *parser-stream*)
        (let ()
          (print "\nsyntax error near: ")
          (while (not (parser-stream-at-end *parser-stream*))
            (print (format "%c" (parser-stream-next *parser-stream*))))
          (println)
          ;; Don't error out - just return
          ))
    (set *parser-stream* s)
    v))

(define-function repl-stream (stream prompt)
  (repl-parser-stream (parser-stream stream) prompt))

;; Start the interactive REPL
(println "Welcome to Maru Interactive REPL")
(println "Enter S-expressions, Ctrl-D to exit")
(println)

;; Use stdin (*input*) with a prompt
(repl-stream *input* "maru> ")
(println "\nGoodbye!")