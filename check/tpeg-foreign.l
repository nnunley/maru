;;; A foreign rule p-r runs on an object of <p>, with the input lent, and hands back where it got to.
(require "check/tpeg-run.l")
(load "build/tpeg-foreign-sa.g.l")
(load "build/tpeg-foreign-sb.g.l")
(peg-enable-recursion)

(expect "the input comes back" (try <sb> $lent '(1 2)) '(((from-a 1) (from-b 2))))
(expect "inside a list pattern" (try <sb> $nested '((1 2))) '(((from-a 1) (from-b 2))))
(expect "a foreign failure" (try <sb> $lent '(1)) ())
(expect "fields are its own" (try <sb> $field '(1)) '(()))
(finish "tpeg foreign")
