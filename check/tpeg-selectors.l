;;; input.l: one interface over text, binary, a list and a user's type.
(require "check/tpeg-try.l")

(define-function walk (source)
  (let ((pos (in-start source)) (out ()))
    (while (not (in-at-end source pos))
      (push out (in-head source pos))
      (set pos (in-tail source pos)))
    (list-reverse! out)))

(expect "text" (walk "ab") '(97 98))
(expect "list" (walk '(97 98)) '(97 98))
(and has-bytes (expect "binary" (walk (bytes-of "ab")) '(97 98)))
(expect "a user's type" (walk (new <countdown> '(97 98))) '(97 98))

(expect "a long has no contents" (in-enter 3) ())
(expect "an empty list has contents to enter" (and (in-enter ()) 1) 1)
(expect "an empty list is at its end" (and (in-at-end () (in-start ())) 1) 1)
(expect "a string can be entered" (and (in-enter "ab") 1) 1)

(expect "same string" (and (in-same "x" "x") 1) 1)
(expect "different symbols" (in-same 'x 'y) ())
(expect "same number" (and (in-same 0 0) 1) 1)
;; streams: a tail is built once, a cell has a memo table, and the end is a cell
(let* ((c (stream-of '(1 2)))
       (d (stream-tail c)))
  (expect "head" (stream-head c) 1)
  (expect "a tail is kept" (= d (stream-tail c)) 1)
  (expect "next head" (stream-head d) 2)
  (expect "not the end" (stream-end? d) ())
  (expect "the end" (and (stream-end? (stream-tail d)) 1) 1))
(expect "an empty stream" (and (stream-end? (stream-of ())) 1) 1)
(expect "a stream over text" (stream-head (stream-of "ab")) 97)
(expect "a stream over a user's type" (stream-head (stream-tail (stream-of (new <countdown> '(5 6))))) 6)
(and has-bytes (expect "a stream over bytes" (stream-head (stream-of (bytes-of "ab"))) 97))

(finish "tpeg selectors")
