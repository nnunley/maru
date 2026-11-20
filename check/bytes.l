;;; check/bytes.l -- what the hash checks share (check/exe.l, check/git-object.l): a string's characters as a byte array,
;;; and a list of bytes as hex.
(define-function bytes-of-string (s)
  (let ((a (array)))
    (for (i 0 (string-length s)) (array-append a (string-at s i)))
    a))
(define-function hex (bytes)
  (let ((out ""))
    (list-do b bytes
      (set out (concat-string out (format "%02x" b))))
    out))
