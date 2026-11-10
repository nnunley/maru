;;; check/source/main.l -- run by source-run.l, as a program would be: its own definitions keep their sources
(define-function source-main-f (x)
  (+ x 1))
(println (<source>-path (source-of source-main-f)) " " (<source>-first (source-of source-main-f)) " " (line-count source-main-f))
