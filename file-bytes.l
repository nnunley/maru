;;; file-bytes.l -- (file-bytes path) is a file's bytes, read whole into C memory: (address . size); byte-at reads them.
;;; Strings stop at a NUL, so binary files (fonts, images) are read this way.
(define-function file-bytes (path)
  (let ((fd ((subr "open" "si>i") path 0)))
    (and (< fd 0) (error "file-bytes: can't open " path))
    (let* ((lseek (subr "lseek" "ili>l")) (size (lseek fd 0 2)) (bytes ((subr "malloc" "l>p") size)) (at 0))
      (lseek fd 0 0)
      (while (< at size)
	(let ((n ((subr "read" "ipl>l") fd (+ bytes at) (- size at))))
	  (and (<= n 0) (error "file-bytes: short read of " path))
	  (set at (+ at n))))
      ((subr "close" "i>i") fd)
      (cons bytes size))))
