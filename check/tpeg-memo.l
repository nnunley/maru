#!./eval tpeg-repl.l
;;; Memoization and growth work on every source, and a value entered twice shares its memos.  Run by tpeg-repl.l: the
;;; grammar is a block, and the cases are input to check/tpeg-cases.l's rule.
(require "check/tpeg-run.l")
;; memos and left recursion on a source that isn't text
{
  <mt> : <source-parser> (count)
  sum = sum:a 'plus .:b -> (+ a b) | .:n -> n ;
  # two left-recursive alternatives: the second must not take the first's recursion as an answer
  ex = ex:a 'plus .:b -> (+ a b) | ex:a 'minus .:b -> (- a b) | 'n .:v -> v ;
  counted = -> (set self.count (+ 1 (or self.count 0))) `( 'x ) ;
  twice = &counted counted ;
  same = `( counted2 ) `( counted2 ) ;
  counted2 = -> (set self.count (+ 1 (or self.count 0))) 'x ;
}
(peg-enable-recursion)
(tpeg-read-file "check/tpeg-cases.l")
{ cases }
"left recursion over a list"		<mt> $sum '(1 plus 2 plus 3)			=> 6
"left recursion over a user's type"	<mt> $sum (new <countdown> '(1 plus 2))		=> 3
"both left-recursive alternatives grow"	<mt> $ex '(n 5 minus 2 plus 1)			=> 4
"the second alternative doesn't take a recursion as an answer"
					<mt> $ex '(minus 2)				=> fails
"nor with a seed to find"		<mt> $ex '(plus 2)				=> fails
.
(let ((p (source-parser-for <mt> '((x)))))
  (expect "matches twice" (and (source-parser-invoke-rule 'twice $twice p) 1) 1)
  (expect "the memo saved the second run" (<mt>-count p) 1))

;; one value entered twice, in one parser
(let* ((v '(x))
       (p (source-parser-for <mt> (list v v))))
  (expect "enters both" (and (source-parser-invoke-rule 'same $same p) 1) 1)
  (expect "memos are per value" (<mt>-count p) 1))
;; memos without growth: a call at its own cell finds no answer yet, so it fails, as on text
(peg-enable-memoisation)
(expect "memos alone: a left-recursive call fails" (try <mt> $sum '(1)) '(1))
(finish "tpeg memo")
