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

(expect "text after" (and (in-after "ab" 0 1) 1) 1)
(expect "text not after itself" (in-after "ab" 1 1) ())
(define l '(1 2 3))
(expect "list after" (and (in-after l l (cdr l)) 1) 1)
(expect "list not before" (in-after l (cdr l) l) ())
(expect "the end is after" (and (in-after l l ()) 1) 1)

(expect "same string" (and (in-same "x" "x") 1) 1)
(expect "different symbols" (in-same 'x 'y) ())
(expect "same number" (and (in-same 0 0) 1) 1)
(expect "in a class" (and (in-class ?5 "0123456789") 1) 1)
(expect "a symbol isn't in a class" (in-class 'a "0123456789") ())

(expect "span of text" (in-span "abc" 0 2) '(97 98))
(expect "span of a list" (in-span l l (cddr l)) '(1 2))
(expect "span of a user's type" (in-span (new <countdown> '(5 6 7)) 1 3) '(6 7))

(finish "tpeg selectors")
