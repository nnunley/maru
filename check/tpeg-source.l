;;; A grammar matches over any source, and a match's value doesn't decide its success.
(require "check/tpeg-run.l")
(load "build/tpeg-mini.g.l")

(expect "text" (try <mini> $sum "2+3") '(5))
(expect "a list of characters" (try <mini> $sum '(?2 ?+ ?3)) '(5))
(and has-bytes (expect "binary" (try <mini> $sum (bytes-of "2+3")) '(5)))
(expect "a user's type" (try <mini> $sum (new <countdown> (list ?2 ?+ ?3))) '(5))
(expect "parse-source" (parse-source <mini> $sum '(?2 ?+ ?3)) 5)
(expect "parse-string still works" (parse-string <mini> $sum "2+3") 5)
(expect "a string literal over a list" (try <mini> $word '(?a ?b ?c)) '("abc"))
(expect "failure on a list" (try <mini> $sum '(?x)) ())

;; parse data is separate from parse state
(expect "a nil element" (try <mini> $any '(())) '(()))
(expect "a zero element" (try <mini> $any '(0)) '(0))
(expect "the end isn't an element" (try <mini> $any ()) ())
(finish "tpeg source")
