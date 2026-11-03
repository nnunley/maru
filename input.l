;;; input.l: the selectors tpeg reads its source through, over text, lists, binary data and a user's type.
;;; A list is read from its current pair, so its position is a pair; nil, which has type <undefined>, is an empty list.
;;; A position is an integer on text and binary data, and a pair on a list.
(require "data-stream.k")

;; can a list pattern go inside this value?
(define-selector in-enter (value) ())

;; the first position in a source
(define-selector in-start (source) 0)

;; the length of a source that has one, for the text path's limit
(define-selector in-limit (source) ())

(define-selector in-at-end)
(define-selector in-head)
(define-selector in-tail)

;; is position b later than position a in this source
(define-selector in-after (source a b) (< a b))

;; the elements from position from up to, not including, position to
(define-selector in-span (source from to)
  (let ((pos from) (out ()))
    (while (in-after source pos to)
      (push out (in-head source pos))
      (set pos (in-tail source pos)))
    (list-reverse! out)))

;; are two values the same, as a match on them needs
(define-selector in-same (a b) (= a b))

;; is element a member of the class string
(define-selector in-class (element class) ())

(define-method in-enter <undefined> ()		1)
(define-method in-enter <pair> ()		1)
(define-method in-enter <string> ()		1)
(define-method in-enter <data-stream> ()	1)

(define-method in-start <undefined> ()		self)
(define-method in-start <pair> ()		self)
(define-method in-start <string> ()		0)
(define-method in-start <data-stream> ()	0)

(define-method in-limit <string> ()		(string-length self))

(define-method in-at-end <undefined> (pos)	1)
(define-method in-at-end <pair> (pos)		(not pos))
(define-method in-at-end <string> (pos)		(>= pos (string-length self)))
(define-method in-at-end <data-stream> (pos)	(>= pos self.limit))

(define-method in-head <undefined> (pos)	())
(define-method in-head <pair> (pos)		(car pos))
(define-method in-head <string> (pos)		(string-at self pos))
(define-method in-head <data-stream> (pos)	(byte-at self.data pos))

(define-method in-tail <undefined> (pos)	())
(define-method in-tail <pair> (pos)		(cdr pos))
(define-method in-tail <string> (pos)		(+ pos 1))
(define-method in-tail <data-stream> (pos)	(+ pos 1))

;; a list's positions are its pairs: b is later if walking the tails from a reaches b, the end included
(define-method in-after <pair> (a b)
  (let ((p (and a (cdr a))))
    (while (and p (not (= p b)))
      (set p (cdr p)))
    (and a (= p b))))

(define-method in-same <string> (b)		(equal self b))

(define-method in-class <long> (class)		(and (string-search class self) 1))
