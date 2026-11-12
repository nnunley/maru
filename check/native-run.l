;;; What check/native.l and check/kernel.l share, on eval2 after native.l: calling an installed unit's function by
;;; name, and running its main in a child.
(define-function fn (image name signature) (subr (cdr (assq name image)) signature))
(define-function last (l) (if (cdr l) (last (cdr l)) (car l)))
;; a unit's main, run in a child: the lines it printed
(define-function native-run-main (image args)
  (let* ((argv ((subr "malloc" "l>p") (* 8 (+ 2 (list-length args)))))
	 (k 0)
	 (out (native-child
	       (lambda ()
		 (list-do a (cons "prog" args)
		   (let ((p ((subr "strdup" "s>p") a))) (for (j 0 8) (set-byte-at argv (+ (* 8 k) j) (& 255 (>> p (* 8 j)))))) (set k (+ k 1)))
		 (for (j 0 8) (set-byte-at argv (+ (* 8 k) j) 0))
		 (and code-region-write-protect (code-region-write-protect 1))	; a forked thread's JIT pages may start writable, not executable
		 (let ((status ((fn image 'main "ip>i") (+ 1 (list-length args)) argv)))
		   ((subr "fflush" "p>i") (native-stdout))	; stdout only: fflush(NULL) would reposition the loader's shared input
		   status)))))
    (expect "the child's exit status" (car out) 0)
    (cdr out)))
(define-function prefix-at? (p s i)	; whether s holds p at i
  (and (<= (+ i (string-length p)) (string-length s))
       (let ((k 0)) (while (and (< k (string-length p)) (= (string-at p k) (string-at s (+ i k)))) (set k (+ k 1))) (= k (string-length p)))))
