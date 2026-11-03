;;; Memoization and growth work on every source, and a value entered twice shares its memos.
(require "check/tpeg-run.l")
(load "build/tpeg-memo-source.g.l")
(peg-enable-recursion)

(expect "left recursion over a list" (try <mt/source> $sum '(1 plus 2 plus 3)) '(6))
(expect "left recursion over a user's type" (try <mt/source> $sum (new <countdown> '(1 plus 2))) '(3))

(let ((p (source-parser-for <mt/source> '((x)))))
  (expect "matches twice" (and (source-parser-invoke-rule 'twice $twice p) 1) 1)
  (expect "the memo saved the second run" (<mt/source>-count p) 1))

;; one value entered twice, in one parser
(let* ((v '(x))
       (p (source-parser-for <mt/source> (list v v))))
  (expect "enters both" (and (source-parser-invoke-rule 'same $same p) 1) 1)
  (expect "memos are per value" (<mt/source>-count p) 1))
(finish "tpeg memo")
