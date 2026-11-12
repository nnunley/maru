;;; Memoization and growth work on every source, and a value entered twice shares its memos.
(require "check/tpeg-run.l")
(load "build/tpeg-memo.g.l")
(peg-enable-recursion)

(expect "left recursion over a list" (try <mt> $sum '(1 plus 2 plus 3)) '(6))
(expect "left recursion over a user's type" (try <mt> $sum (new <countdown> '(1 plus 2))) '(3))

(expect "both left-recursive alternatives grow" (try <mt> $ex '(n 5 minus 2 plus 1)) '(4))
(expect "the second alternative doesn't take a recursion as an answer" (try <mt> $ex '(minus 2)) ())
(expect "nor with a seed to find" (try <mt> $ex '(plus 2)) ())

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
;; entering a value finds its stream in time that doesn't grow with how many the parser has entered: four times the values
;; cost about four times as long, where a search of every value entered so far cost sixteen (native-arm64.g's lowering of
;; a long function was quadratic for it)
(define clock (subr "clock" ">l"))
(define-function entering-time (n)
  (let ((values ()) (t0 0))
    (for (i 0 n) (push values (list 'x)))
    (set t0 (clock))
    (expect "entered them all" (try <mt> $entered values) (list n))
    (max 5000 (- (clock) t0))))	; at least 5 ms, so a fast machine's small count isn't noise
(let* ((few (entering-time 2000)) (many (entering-time 8000)))
  (expect "four times the values, less than eight times as long" (< many (* 8 few)) 't))
(finish "tpeg memo")
