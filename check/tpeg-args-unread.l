;;; A rule that leaves an argument unread is an error: it mustn't reach the caller's input as data.
(require "check/tpeg-run.l")
(load "build/tpeg-args.g.l")
(try <argp> (eval (string->symbol (concat-string "$" (next-argument)))) '(9))
(println "no error")
