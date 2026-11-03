;;; tpeg reads hexadecimal in actions, and set-list-source copies sources as parser.l's does.
(require "check/tpeg-run.l")
(load "build/tpeg-literals.g.l")
(load "build/tpeg-literals-source.g.l")

(expect "hex" (try <lit/source> $hexv "") '(16))
(expect "negative hex" (try <lit/source> $hexn "") '(-16))
(expect "upper case" (try <lit/source> $upper "") '(255))
(expect "decimal still" (try <lit/source> $plain "") '(16))

(expect "hex on <text-parser>" (parse-string <lit> $hexv "") 16)

(let* ((from (list 'a 'b)) (to (list 'c 'd)))
  (set (<pair>-source from) 'first)
  (set (<pair>-source (cdr from)) 'second)
  (set-list-source to from)
  (expect "first source" (<pair>-source to) 'first)
  (expect "second source" (<pair>-source (cdr to)) 'second))
(finish "tpeg literals")
