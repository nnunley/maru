;;; check/source-order.l -- files required before source.l are read again in the order they were evaluated: a file that
;;; requires another and then redefines one of its definitions keeps its own, as the running program does
(require "check/source/req-a.l")
(require "source.l")
(println (req-x) " " (source-form req-x))
