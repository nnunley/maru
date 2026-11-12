;;; The kernel's integers (doc/kernel.md), boxed or tagged as kernel-tag-int chooses when the kernel is compiled, as
;;; eval3's TAG_INT does: check/kernel.l and check.l run this main in both modes.  Prints "kernel longs ok".

(define-form expect (what test)
  `(unless ,test
     (printf "FAIL %s\n" ,what)
     (exit 1)))

(define-function odd long ((x oop)) (return (& 1 (cast x long))))

;; x as a long survives k_newLong and k_getLong, is a <long> and an isLong, and is an odd word just when it fits in one
;; tagged (its top two bits agree) and the kernel is tagged
(define-function round-trip int ((x long))	; ir2's truth value, an int
  (let* (((o oop) (k_newLong x))
	 ((fits long) 1))
    (if (< (^ x (<< x 1)) 0) (set fits 0))
    (return (and (= (k_getLong o) x) (= (object-type o) 2) (k_isLong o)
		 (= (odd o) (if-tag-int fits 0))))))

(define-function main int ((argc int) (argv char * *))
  (gc_initialise)
  (set gc_poison 165)
  (set gc_frequency 1)
  (set type_check_fatal 0)
  (let (((big long) (cast 4611686018427387904 long))	; 2^62, the least that doesn't fit tagged
	((max long) (cast 9223372036854775807 long)))	; a literal is an int32 unless cast
    (expect "small values" (and (round-trip 0) (round-trip 1) (round-trip -1) (round-trip 42) (round-trip -42)))
    (expect "the edges of a tagged value" (and (round-trip (- big 1)) (round-trip big) (round-trip (- (cast 0 long) big))
					       (round-trip (- (- (cast 0 long) big) 1))))
    (expect "INT64_MAX and INT64_MIN" (and (round-trip max) (round-trip (- (- (cast 0 long) max) 1)))))
  (expect "a symbol isn't a long" (not (k_isLong (k_newSymbolC "x"))))
  ;; an odd word through the object level, whichever the mode: get answers its value; put has no field to write
  (expect "get of an odd word" (= (get <long> bits (cast 85 oop)) 42))
  (let (((before long) type_check_failures))
    (put <long> bits (cast 85 oop) 7)
    (expect "put to an odd word fails its type check" (and (= type_check_failures (+ before 1)) (= type_check_expected 2))))
  (printf "kernel longs ok\n")
  (return 0))
