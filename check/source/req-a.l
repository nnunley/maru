;;; check/source/req-a.l -- requires req-b.l, then defines req-x again (check/source-order.l)
(require "check/source/req-b.l")
(define-function req-x () (quote a))
