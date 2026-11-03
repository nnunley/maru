;;; input-binary.l: the binary instance of the input selectors, over <data-stream> (data-stream.k).
;;; Only binary matching loads it, so text parsing doesn't.
(require "data-stream.k")
(require "input.l")

(define-method in-enter <data-stream> ()	1)
(define-method in-start <data-stream> ()	0)
(define-method in-at-end <data-stream> (pos)	(>= pos self.limit))
(define-method in-head <data-stream> (pos)	(byte-at self.data pos))
(define-method in-tail <data-stream> (pos)	(+ pos 1))
