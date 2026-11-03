;;; Memoization and growth work on every source, and a value entered twice shares its memos.
(require "check/tpeg-run.l")
(load "build/tpeg-memo.g.l")
(peg-enable-recursion)

(expect "left recursion over a list" (try <mt> $sum '(1 plus 2 plus 3)) '(6))
(expect "left recursion over a user's type" (try <mt> $sum (new <countdown> '(1 plus 2))) '(3))

(let ((p (text-parser-for-source <mt> '((x)))))
  (expect "matches twice" (and (text-parser-invoke-rule 'twice $twice p) 1) 1)
  (expect "the memo saved the second run" (<mt>-count p) 1))

;; one value entered twice, in one parser
(let* ((v '(x))
       (p (text-parser-for-source <mt> (list v v))))
  (expect "enters both" (and (text-parser-invoke-rule 'same $same p) 1) 1)
  (expect "memos are per value" (<mt>-count p) 1))
(finish "tpeg memo")
