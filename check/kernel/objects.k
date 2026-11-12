;;; The kernel's objects (doc/kernel.md), as eval3's: check/kernel.l runs this main after maru-gc.k (less its main) and
;;; kernel.k, natively and through C.  Prints "kernel objects ok".

(define-form expect (what test)
  `(unless ,test
     (printf "FAIL %s\n" ,what)
     (exit 1)))

;; a subr's implementation: answers its arguments' head, so a call through <subr>-imp is seen to arrive
(define-function first-argument oop ((args oop) (env oop)) (return (<pair>-head args)))

(define-function sum-list long ((l oop))
  (let (((s long) 0))
    (while l
      (set s (+ s (k_getLong (<pair>-head l))))
      (set l (<pair>-tail l)))
    (return s)))

(define-function main int ((argc int) (argv char * *))
  (gc_initialise)
  ;; eval3's type ids (eval3.c:87): the contract boot2.l's declarations meet
  (expect "ids of nil, long, double, string, symbol, pair"
	  (and (= (object-type nil) 0) (= (object-type (k_newLong 5)) 2) (= (object-type (k_newDouble 2.5)) 3)
	       (= (object-type (k_newStringC "maru")) 4) (= (object-type (k_newSymbolC "abc")) 5)
	       (= (object-type (k_cons nil nil)) 6)))
  (expect "ids of data, _array, array, expr, form, fixed, subr"
	  (and (= (object-type (k_newData 16)) 1) (= (object-type (<array>-_array (k_newArray 3))) 7)
	       (= (object-type (k_newArray 3)) 8) (= (object-type (k_newExpr nil nil)) 9)
	       (= (object-type (k_newForm nil nil)) 10) (= (object-type (k_newFixed nil)) 11)
	       (= (object-type (k_newSubrC "first" first-argument)) 12)))
  ;; values read back through the fields
  (let (((p oop) (k_cons (k_newStringC "maru") (k_newLong 42))))
    (expect "a pair's string head, its characters" (and (= (indir (<string>-bits (<pair>-head p)) 0) 109)
							    (= (indir (<string>-bits (<pair>-head p)) 3) 117)
							    (= (k_getLong (<string>-size (<pair>-head p))) 4)))
    (expect "a pair's long tail" (= (k_getLong (<pair>-tail p)) 42)))
  (expect "a double" (= (k_getDouble (k_newDouble 2.5)) 2.5))
  (expect "a symbol's characters" (= (indir (<symbol>-bits (k_newSymbolC "abc")) 2) 99))
  (let (((a oop) (k_newArray 100)))
    (expect "an array of 100" (= (k_getLong (<array>-size a)) 100)))
  (let (((e oop) (k_newExpr (k_newLong 1) (k_newLong 2))))
    (expect "an expr's definition, environment and profile"
	    (and (= (k_getLong (<expr>-definition e)) 1) (= (k_getLong (<expr>-environment e)) 2)
		 (= (k_getLong (<expr>-profile e)) 0))))
  ;; a subr called through its imp: a function pointer in a field, natively too
  (let (((s oop) (k_newSubrC "first" first-argument)))
    (expect "a subr called through its imp"
	    (= (k_getLong ((<subr>-imp s) (k_cons (k_newLong 7) nil) nil)) 7)))
  ;; a collection on every allocation: a rooted list keeps every pair and long
  (set gc_frequency 1)
  (let (((l oop) nil) ((i long) 0))
    (gc-protect (l)
      (while (< i 2000)
	(set l (k_cons (k_newLong i) l))
	(set i (+ i 1)))
      (expect "2000 pairs, collected on every allocation" (= (sum-list l) 1999000))))
  (printf "kernel objects ok\n")
  (return 0))
