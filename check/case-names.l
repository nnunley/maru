;;; (case-names): the names of check/check.l's cases, read from where they're written, in order: check/parallel.l runs
;;; them, and the evidence plans may name no other (check/plan-evidence.l).
(define-function case-names ()
  (let* ((text (contents-of-file-named "check/check.l"))
	 (marker "(check \"")
	 (m (string-length marker))
	 (n (string-length text))
	 (names ())
	 (i 0))
    (while (< i (- n m))
      (if (and (or (= i 0) (= ?\n (string-at text (- i 1))))
	       (= marker (string-copy text i m)))
	  (let ((end (+ i m)))
	    (while (not (= ?\" (string-at text end))) (set end (+ end 1)))
	    (push names (string-copy text (+ i m) (- end (+ i m))))
	    (set i end))
	(set i (+ i 1))))
    (list-reverse! names)))

