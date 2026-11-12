;;; The kernel's lists, arrays and printer (doc/kernel.md), as eval3's.  Prints four structures as print and dump print
;;; them, then "kernel lists ok"; check/kernel.l and check.l compare the four lines with ./eval3 -b boot2.l's.

(define-form expect (what test)
  `(unless ,test
     (printf "FAIL %s\n" ,what)
     (exit 1)))

(define-function main int ((argc int) (argv char * *))
  (gc_initialise)
  (set gc_poison 165)		; nothing printed may come from memory nothing wrote
  (set gc_frequency 1)		; nor from memory a collection reclaimed
  (let (((a oop) (k_newArray 3))
	((x oop) nil)
	((y oop) nil))	; an intermediate value, rooted while the next allocation runs
    (gc-protect (a x y)
      (k_arrayAtPut a 0 (k_newLong 1))
      (k_arrayAtPut a 2 (k_newStringC "s"))
      ;; (list "he\"l\\lo" 'sym -42 3.5 () a (cons 1 2) (array)), built from its end
      (set x (k_cons (k_newArray 0) nil))
      (set y (k_newLong 1))
      (set x (k_cons (k_cons y (k_newLong 2)) x))
      (set x (k_cons a x))
      (set x (k_cons nil x))
      (set x (k_cons (k_newDouble 3.5) x))
      (set x (k_cons (k_newLong -42) x))
      (set x (k_cons (k_newSymbolC "sym") x))
      (set x (k_cons (k_newStringC "he\"l\\lo") x))
      (k_print x)
      (printf "\n")
      (k_dumpln x)
      (k_dumpln (k_newStringC "tab\there"))
      (set y (k_newSymbolC "quote"))
      (k_dumpln (k_cons (k_cons y (k_newLong 7)) nil))
      ;; arrays grow as they are written past their end, with nil between
      (k_arrayAtPut a 99 (k_newLong 99))
      (expect "an array grown to 100" (and (= (k_arrayLength a) 100) (= (k_getLong (k_arrayAt a 99)) 99)
					   (= (k_arrayAt a 50) nil) (= (k_arrayAt a 100) nil)))
      (k_arrayInsert a 1 (k_newLong 5))
      (expect "an insert moves the rest along" (and (= (k_arrayLength a) 101) (= (k_getLong (k_arrayAt a 1)) 5)
						    (= (object-type (k_arrayAt a 3)) 4) (= (k_getLong (k_arrayAt a 100)) 99)))
      (k_arrayAppend a (k_newLong 7))
      (expect "an append" (and (= (k_arrayLength a) 102) (= (k_getLong (k_arrayAt a 101)) 7)))
      (expect "car and cdr of a non-pair are nil" (and (= (k_car a) nil) (= (k_cdr nil) nil)))
      (expect "cadr and caddr" (and (= (object-type (k_cadr x)) 5) (= (k_getLong (k_caddr x)) -42)))))
  (printf "kernel lists ok\n")
  (return 0))
