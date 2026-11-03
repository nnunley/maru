;;; A call's arguments are elements its rule reads from the input, first argument first.
(require "check/tpeg-try.l")
(load "build/tpeg-args.g.l")

(expect "parameters" (try <argp> $callp "xy") '((1 2)))
(expect "an argument matched by a pattern" (try <argp> $askp "y") '(matched))
(expect "an argument that doesn't match" (try <argp> $askn "y") ())
(expect "position after that failure" (position-after <argp> $askn "y") 0)
(expect "a nil argument" (try <argp> $calln "") '((got ())))
(expect "a zero argument" (try <argp> $callz "") '((got 0)))
(expect "passed along" (try <argp> $nest "z") '((outer 7)))
(expect "no cell left behind" (try <argp> $fallback "y") '(second))
(expect "on a list source" (try <argp> $overlist '((?y))) '((1 2)))
(finish "tpeg args")
