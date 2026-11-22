;;; check/strings.l -- splitting text: (split STR SEP) on a character, (lines STR), (words STR) on spaces, empty words
;;; dropped; for check.l and the check scripts that read output.
(define-function split (str sep)
  (let ((out ()) (start 0) (n (string-length str)))
    (for (i 0 n)
      (when (= sep (string-at str i))
	(push out (string-copy str start (- i start)))
	(set start (+ i 1))))
    (and (< start n) (push out (string-copy str start (- n start))))
    (list-reverse! out)))

(define-function lines (str) (split str ?\n))
(define-function words (str) (let ((ws ())) (list-do w (split str 32) (or (= 0 (string-length w)) (push ws w))) (list-reverse! ws)))
