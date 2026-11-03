;;; tpeg reads hexadecimal in actions, and set-list-source copies sources as parser.l's does.
(require "text-parser.l")
(require "check/tpeg-try.l")
(load "build/tpeg-literals.g.l")

(expect "hex" (parse-string <lit> $hexv "") 16)
(expect "negative hex" (parse-string <lit> $hexn "") -16)
(expect "upper case" (parse-string <lit> $upper "") 255)
(expect "decimal still" (parse-string <lit> $plain "") 16)

(let* ((from (list 'a 'b)) (to (list 'c 'd)))
  (set (<pair>-source from) 'first)
  (set (<pair>-source (cdr from)) 'second)
  (set-list-source to from)
  (expect "first source" (<pair>-source to) 'first)
  (expect "second source" (<pair>-source (cdr to)) 'second))
(finish "tpeg literals")
