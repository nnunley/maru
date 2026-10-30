;;; ./eval check/peg-lr.l <peg-lr.g compiled by compile-tpeg.l>
;;; A left-recursive entry rule grows under text-parser.l too.
(require "text-parser.l")
(load (next-argument))
(peg-enable-recursion)
(dumpln (parse-string <lr> $add "1+2+3"))
