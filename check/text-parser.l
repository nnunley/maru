;;; A string literal matches when it ends exactly at the end of the input.
(require "text-parser.l")
(let ((p (text-parser-for-on <text-parser> "abc")))
  (if (and (text-parser-match-string p "ab" 2) (text-parser-match-string p "c" 1))
      (println "text parser ok")
    (println "FAIL: a literal ending at the end of the input did not match")))
