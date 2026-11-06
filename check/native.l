;;; Typed Maru to native code in-process (draft-ndn-maru-native-ir2-00): each unit compiled by native.l, installed in a
;;; code region, and its functions called by address through subr.  Runs on eval2, which runs maru.k.
(require "native.l")
(require "check/native-child.l")
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
	  '(-42 -3 -1 8 14 6 48 -4 -6))
  (expect "zero written to a pointer: a local, a field, an element, a global"
	  (list ((fn image 'null-local "p>l") buffer) ((fn image 'null-field "p>l") buffer) ((fn image 'null-element "p>l") buffer)
		((fn image 'null-global "p>l") buffer))
	  '(0 0 0 0)))

(let ((image (native-install (native-compile-file "check/native/floats.k"))))
  (expect "fadd" ((fn image 'fadd "dd>d") 1.25 2.5) 3.75)
  (expect "fmix, in float" ((fn image 'fmix "fff>f") 2.0 3.0 1.0) 5.5)
  (expect "fneg" ((fn image 'fneg "d>d") 1.5) -1.5)
  (expect "literals" ((fn image 'flit ">d") ) 2.375)
  (expect "a float literal, rounded to float" ((fn image 'widen "f>d") ((fn image 'flit32 ">f") )) ((fn image 'widen "f>d") 0.1))
  (expect "to long, toward zero" (list ((fn image 'to-long "d>l") 7.9) ((fn image 'to-long "d>l") -7.9)) '(7 -7))
  (expect "to int" ((fn image 'to-int "f>i") -3.5) -3)
  (expect "from long" ((fn image 'from-long "l>d") -42) -42.0)
  (expect "widen and narrow" (list ((fn image 'widen "f>d") 0.5) ((fn image 'narrow "d>f") 0.25)) '(0.5 0.25))
  (expect "every relation, on doubles" (map (lambda (ab) (apply (fn image 'relations "dd>l") ab)) '((-3.0 2.0) (2.0 -3.0) (7.0 7.0)))
	  '(14 50 41))
  (expect "nine doubles and two longs" ((fn image 'call-weigh ">d") ) 10.75)
  (expect "a double through a call" ((fn image 'call-fadd "d>d") 0.5) 2.0))

(expect "calls: ten arguments, printf's variadic ones (doubles among them, a float promoted), a global, a string"
	(native-run-main (native-install (native-compile-file "check/native/calls.k")) ())
	'("7 ok 385 9" "counter 3" "1 2.50 10 0.125 end 0.5"))
(expect "zero-global.k" (last (native-run-main (native-install (native-compile-file "check/zero-global.k")) ())) "zero global ok")
(expect "check/ir2.k" (last (native-run-main (native-install (native-compile-file "check/ir2.k")) ())) "ir2 ok")
(expect "maru-label.k" (cdr (native-run-main (native-install (native-compile-file "maru-label.k")) ()))
	'("10" "9" "GOT 9" "8" "7" "GOT 7" "6" "5" "GOT 5"))
(let ((out (native-run-main (native-install (native-compile-file "maru-test.k")) '("32"))))
  (expect "maru-test.k's primes" (pieces (car out) 32) '("2" "3" "5" "7" "11" "13" "17" "19" "23" "29" "31"))
  (expect "maru-test.k's sum" (and (member? "sum is 708" out) 1) 1)
  (expect "maru-test.k's struct" (last out) "print-foo: 84 1332"))

(let ((image (native-install (native-compile-file "check/native/labels.k"))))
  (expect "a label of one name in two functions" (list ((fn image 'first-done ">l")) ((fn image 'second-done ">l"))) '(10 20))
  (expect "a label of one name in two sibling lets" ((fn image 'sibling-done ">l")) 1100))

(let ((image (native-install (native-compile-file "check/native/structs.k"))))
  (expect "a 12-byte struct made and passed" ((fn image 'three-round ">l")) 456)
  (expect "a 16-byte struct passed and returned" ((fn image 'two-round "ll>l") 3 4) 3997)
  (expect "a 16-byte struct C returns" ((fn image 'ldiv-of "ll>l") 47 5) 902)
  (expect "a struct after seven longs, and a long after it, both on the stack" ((fn image 'call-spill ">l")) 43207)
  (expect "8-byte pieces at slots 4 past a multiple of 8" ((fn image 'call-foos ">l")) 8710876))

(let ((image (native-install (native-compile-file "check/native/stack.k"))))
  (expect "ints past the eighth argument, from C and natively"
	  (list ((fn image 'late-ints "lllllllliii>l") 1 0 0 0 0 0 0 1 1 2 3) ((fn image 'call-late-ints ">l"))) '(125 125))
  (expect "zero passed to a pointer past the eighth" ((fn image 'call-late-pointer ">l")) 0)
  (expect "a call through an unprototyped function type" ((fn image 'call-unprototyped ">l")) 21)
  (expect "every relation, on pointers, unsigned"
	  (map (lambda (ab) (apply (fn image 'pointer-relations "pp>l") ab)) '((-8 16) (16 -8) (16 16))) '(44 35 26)))

;; a frame of 9760 bytes: check/native/frame.k after a struct of 600 longs, which ir2 can't build from smaller ones
(let ((path (concat-string check-tmp "/native-frame.k")) (fields ""))
  (for (i 0 600) (set fields (concat-string fields (concat-string " (f" (concat-string (long->string i) " long)")))))
  (contents-to-file-named (concat-string "(define-struct <wide> (" (concat-string fields (concat-string "))\n" (contents-of-file-named "check/native/frame.k"))))
			  path)
  (let* ((unit (native-compile-file path)) (image (native-install unit)))
    ((subr "unlink" "s>i") path)
    (expect "a frame over 4096 bytes" (< 4096 (caddr (assq 'far-frame (<native-unit>-functions unit)))) 't)
    (expect "slots past a load's reach" ((fn image 'far-frame "l>l") 10) 46)))

;; a conditional branch reaches as far as B, 128 MB, not CBZ's 1 MB: it is lowered as the inverted test over a B.  (A
;; while body past 1 MB would take minutes to compile on eval2.)
(expect "a conditional branch as a short one over B"
	(map (lambda (i) (map car (car (parse-source <native-arm64> $program (list (list i 's0 'far)))))) '(branch-if branch-unless))
	'((CBZ B at) (CBNZ B at)))
(let ((r (car (asm 'arm64 (asm-buffer 0) '(B (reloc))))))
  (expect "B's reach" (asm-field-range 'arm64 (caddr r) (car r) 0) '(-134217728 134217724 4)))

;; what isn't written yet is refused when compiled, naming it: a struct over 16 bytes by value, a -0.0 literal
(refuses "a struct over 16 bytes taken by value" (lambda () (native-compile-file "check/native/big-argument.k"))
	 "struct <big> of 24 bytes taken as s by value, in first-of")
(refuses "a struct over 16 bytes returned by value" (lambda () (native-compile-file "check/native/big-result.k"))
	 "struct <big> of 24 bytes returned from make-big by value, in make-big")
(refuses "a struct over 16 bytes passed by value" (lambda () (native-compile-file "check/native/big-call.k"))
	 "struct <big> of 24 bytes passed to consume by value, in hand-over")
(refuses "a -0.0 literal" (lambda () (native-compile-file "check/native/negative-zero.k")) "no literal for -0.0")
;; and the lowerings hold to what the generator promises: a struct result in two registers, a call's stack arguments in
;; the area the frame keeps for them
(list-do isa (list <native-arm64> <native-x64>)
  (refuses "a struct result of 24 bytes" (lambda () (parse-source isa $program '((result 24 0 struct))))
	   "a struct result of 24 bytes is more than two registers")
  (refuses "stack arguments past the outgoing area"
	   (lambda () (parse-source isa $program '((enter 32 0) (call 0 9 ((8 0 int) (8 0 int) (8 0 int) (8 0 int) (8 0 int)
								    (8 0 int) (8 0 int) (8 0 int) (8 0 int)) ()))))
	   "bytes of stack arguments overrun the frame's 0"))

;; maru-check.k, upstream's own test: each section prints its "ok"
(let ((out (native-run-main (native-install (native-compile-file "maru-check.k")) ())))
  (list-do s '("bytes" "words" "ints" "floats" "structs" "pointers")
    (expect (concat-string "maru-check.k's " s) (and (member? (concat-string s " ok") out) 1) 1)))

;; the collector written in typed Maru, held to what maru_gc asks of it under cc: eleven reports, the nth after n
;; thousand rounds of 256 cells (the last after ten thousand), and at the end everything freed and none left in use
(define-function prefix-at? (p s i)	; whether s holds p at i
  (and (<= (+ i (string-length p)) (string-length s))
       (let ((k 0)) (while (and (< k (string-length p)) (= (string-at p k) (string-at s (+ i k)))) (set k (+ k 1))) (= k (string-length p)))))
(define-function prefix? (p s) (prefix-at? p s 0))
(define-function select (keep? l) (let ((out ())) (list-do x l (and (keep? x) (push out x))) (list-reverse! out)))
(let* ((reports (map (lambda (l) (pieces l 32)) (select (lambda (l) (prefix? "GC: " l)) (native-run-main (native-install (native-compile-file "maru-gc.k")) ()))))
       (k 0))
  (expect "maru-gc.k's reports" (list-length reports) 11)
  (list-do r reports
    (expect "maru-gc.k's cells allocated" (string->long (caddr (cdddr r))) (* 256 (if (= k 10) 10000 (* 1000 k))))
    (set k (+ k 1)))
  (let ((final (last reports)))
    (expect "maru-gc.k's collections" (< 0 (string->long (cadr (cdddr (cdddr final))))) 't)
    (expect "maru-gc.k's cells in use" (string->long (cadr final)) 0)
    (expect "maru-gc.k's bytes in use" (string->long (car (cddddr (cddddr (cdr final))))) 0)))

;; check/gc.k in place of maru-gc.k's main: the heap grows when needed and adjacent free chunks merge
(let* ((gc (contents-of-file-named "maru-gc.k"))
       (main (let ((i 0)) (while (not (prefix-at? "(define-function main " gc i)) (set i (+ i 1))) i))
       (path (concat-string check-tmp "/native-gc.k")))
  (contents-to-file-named (concat-string (string-copy gc 0 main) (contents-of-file-named "check/gc.k")) path)
  (let ((out (native-run-main (native-install (native-compile-file path)) ())))
    ((subr "unlink" "s>i") path)
    (expect "check/gc.k" (last out) "gc ok")))

(println (if ok "native ok" "native FAILED"))
