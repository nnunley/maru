(require "text-parser.l")
(require "cexpr.g.l")
(list-do s '("0xq" "0xff" "0xz1" "0xg") (print s " => ") (dumpln (parse-string <cexpr> $expression s)))
