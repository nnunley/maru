;;; input.l: the selectors tpeg reads its source through, over text, lists, arrays and a user's type.
;;; The binary instance (<data-stream>) is in input-binary.l, so text parsing doesn't load data-stream.k.
;;; A list is read from its current pair, so its position is a pair; nil, which has type <undefined>, is an empty list.
;;; A position is an integer on text or an array, and a pair on a list.

;; can a list pattern go inside this value?
(define-selector in-enter (value) ())

;; the first position in a source
(define-selector in-start (source) 0)

(define-selector in-at-end)
(define-selector in-head)
(define-selector in-tail)

;; are two elements the same, as a match on them needs
(define-selector in-same (a b) (= a b))

(define-method in-enter <undefined> ()		1)
(define-method in-enter <pair> ()		1)
(define-method in-enter <string> ()		1)
(define-method in-enter <array> ()		1)

(define-method in-start <undefined> ()		self)
(define-method in-start <pair> ()		self)
(define-method in-start <string> ()		0)
(define-method in-start <array> ()		0)

(define-method in-at-end <undefined> (pos)	1)
(define-method in-at-end <pair> (pos)		(not pos))
(define-method in-at-end <string> (pos)		(>= pos (string-length self)))
(define-method in-at-end <array> (pos)		(>= pos (array-length self)))

(define-method in-head <undefined> (pos)	())
(define-method in-head <pair> (pos)		(car pos))
(define-method in-head <string> (pos)		(string-at self pos))
(define-method in-head <array> (pos)		(array-at self pos))

(define-method in-tail <undefined> (pos)	())
(define-method in-tail <pair> (pos)		(cdr pos))
(define-method in-tail <string> (pos)		(+ pos 1))
(define-method in-tail <array> (pos)		(+ pos 1))

(define-method in-same <string> (b)		(equal self b))

;;; Streams: a cell holds one element of a source, built when it is entered. Its tail is built the
;;; first time it is asked for, and kept. Its memo table is what the rules have answered here.

(define-structure <cell> (source position end head next memo))

(define-function stream-at (source pos)
  (let ((end (in-at-end source pos)))
    (new <cell> source pos end (and (not end) (in-head source pos)) () ())))

(define-function stream-of (source)
  (stream-at source (in-start source)))

(define-function stream-end? (c)	(<cell>-end c))
(define-function stream-head (c)	(<cell>-head c))

(define-function stream-tail (c)
  (or (<cell>-next c)
      (let ((next (stream-at (<cell>-source c) (in-tail (<cell>-source c) (<cell>-position c)))))
	(set (<cell>-next c) next)
	next)))

(define-function stream-memo (c)	(<cell>-memo c))

;; the elements from cell from up to, not including, cell to, in a list
(define-function stream-span (from to)
  (let ((c from) (out ()))
    (while (and (not (= c to)) (not (stream-end? c)))
      (push out (stream-head c))
      (set c (stream-tail c)))
    (list-reverse! out)))
