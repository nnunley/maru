;;; A call's arguments are elements its rule reads from the input, first argument first.
(require "check/tpeg-run.l")
(load "build/tpeg-args-source.g.l")

(expect "parameters" (try <argp/source> $callp "xy") '((1 2)))
(expect "an argument matched by a pattern" (try <argp/source> $askp "y") '(matched))
(expect "an argument that doesn't match" (try <argp/source> $askn "y") ())
(expect "position after that failure" (stays-at-start <argp/source> $askn "y") 1)
(expect "a nil argument" (try <argp/source> $calln "") '((got ())))
(expect "a zero argument" (try <argp/source> $callz "") '((got 0)))
(expect "passed along" (try <argp/source> $nest "z") '((outer 7)))
(expect "no cell left behind" (try <argp/source> $fallback "y") '(second))
(expect "on a list source" (try <argp/source> $overlist '((?y))) '((1 2)))
(finish "tpeg args")
