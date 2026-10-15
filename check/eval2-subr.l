;;; Foreign calls through subr, under ./eval and ./eval2 -b boot2.l alike:
;;; typed arguments and results by name or by address, and byte access to
;;; raw memory.  Prints "subr ok".

(define failures 0)
(define-form expect (form value)
  `(let ((got ,form))
     (or (equal got ,value)
	 (let () (println "FAIL " ',form " => " got ", expected " ,value) (set failures (+ failures 1))))))

(expect ((subr "strlen" "s>l") "maru") 4)
(expect ((subr "sqrt" "d>d") 2.25) 1.5)
(expect ((subr "powf" "ff>f") 2.0 3.0) 8.0)
(expect ((subr "abs" "i") -3) 3)			; no return type: an integer, as before
(expect ((subr "snprintf" "pls.>i") 0 0 "%d-%d" 12 345) 6)	; variadic, then a return type

;; A function by address: dlsym through the program's own handle.
(let* ((dlopen (subr "dlopen" "pi>p"))
       (dlsym (subr "dlsym" "ps>p"))
       (labs-address (dlsym (dlopen 0 1) "labs")))
  (expect ((subr labs-address "l>l") -7) 7))

(let ((p ((subr "malloc" "l>p") 16)))
  (set-byte-at p 3 0xab)
  (expect (byte-at p 3) 0xab)
  ((subr "free" "p") p))

(if (= 0 failures) (println "subr ok"))
