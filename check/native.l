;;; Typed Maru to native code in-process (draft-ndn-maru-native-ir2-00): each unit compiled by native.l, installed in a
;;; code region, and its functions called by address through subr.  Runs on eval2, which runs maru.k.
(require "native.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function fn (image name signature) (subr (cdr (assq name image)) signature))

(let ((image (native-install (native-compile-file "check/native/add.k"))))
  (expect "add3 of 1, 2, 3" ((fn image 'add3 "lll>l") 1 2 3) 6)
  (expect "add3 of large and negative" ((fn image 'add3 "lll>l") 4000000000 -1 -2) 3999999997)
  (expect "neg of 5" ((fn image 'neg "l>l") 5) -5))

(let ((image (native-install (native-compile-file "check/native/flow.k"))))
  (expect "gcd of 1071 and 462" ((fn image 'gcd "ll>l") 1071 462) 21)
  (expect "max3, each place" (map (lambda (abc) (apply (fn image 'max3 "lll>l") abc)) '((9 2 3) (2 9 3) (2 3 9) (5 5 1))) '(9 9 9 5))
  (expect "sum below 100" ((fn image 'sum-below "l>l") 100) 4950)
  (expect "sum below 0" ((fn image 'sum-below "l>l") 0) 0)
  (expect "if as a value" (list ((fn image 'pick "lll>l") 1 10 20) ((fn image 'pick "lll>l") 0 10 20)) '(10 20))
  (expect "every relation, signed" (map (lambda (ab) (apply (fn image 'relations "ll>l") ab)) '((-3 2) (2 -3) (7 7)))
	  '(35 44 26)))

(let ((image (native-install (native-compile-file "check/native/memory.k")))
      (buffer ((subr "calloc" "ll>p") 64 8)))
  (expect "through int8" (list ((fn image 'through8 "pl>l") buffer 200) ((fn image 'through8 "pl>l") buffer -1)) '(-56 -1))
  (expect "through int16" ((fn image 'through16 "pl>l") buffer 70000) 4464)
  (expect "through int32" ((fn image 'through32 "pl>l") buffer 5000000000) 705032704)
  (expect "struct fields" ((fn image 'fields "p>l") buffer) 24)
  (expect "the fields where osdefs.k puts them" (list (byte-at buffer 0) (byte-at buffer 8) (byte-at buffer 12)) '(7 8 9))
  (for (k 0 10) (for (j 0 8) (set-byte-at buffer (+ (* 8 k) j) (if (= j 0) (+ k 1) 0))))
  (expect "sum of an array" ((fn image 'sum-array "pl>l") buffer 10) 55)
  (expect "a field of an indexed struct" (list ((fn image 'element-field "pl>l") buffer 2) (byte-at buffer (+ (* 2 16) 8))) '(41 41))
  (expect "through addressof" ((fn image 'via-address "l>l") 41) 42)
  (expect "arithmetic and bits, C's signed results"
	  (map (lambda (args) (apply (fn image 'arith "lll>l") args))
	       '((-7 6 0) (-7 2 1) (-7 2 2) (12 10 3) (12 10 4) (12 10 5) (3 4 6) (-8 1 7) (5 0 8)))
	  '(-42 -3 -1 8 14 6 48 -4 -6)))

(println (if ok "native ok" "native FAILED"))
