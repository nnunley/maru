;;; Values held in registers from producer to consumer (check/native.l): an expression whose temporaries never touch the
;;; frame, a call in a later operand's branch (which keeps the earlier operand out of a register), more pending values
;;; than there are held registers, floats at both widths, members read through a pointer, a loop inside an operand while
;;; another waits, and int arithmetic that wraps, whose held product must be sign-extended as a load from a slot is.
(define-struct <held-pair> ((x long) (y long)))
(define-function twice long ((b long)) (return (* b 2)))
(define-function held_expr long ((a long) (b long) (c long)) (return (+ (* a b) (- c a))))
(define-function held_call_in_branch long ((a long) (b long)) (return (+ (* a 2) (if (> b 0) (twice b) b))))
(define-function held_deep long ((a long))
  (return (+ (* a 1) (+ (* a 1) (+ (* a 1) (+ (* a 1) (+ (* a 1) (+ (* a 1) (+ (* a 1) (+ (* a 1) (+ (* a 1) (+ (* a 1)
	  (+ (* a 1) (+ (* a 1) (+ (* a 1) (+ (* a 1) (* a 1)))))))))))))))))
(define-function held_float32 float ((x float) (y float)) (return (* (+ x y) (- x y))))
(define-function held_float64 double ((x double) (y double)) (return (* (+ x y) (- x y))))
(define-function held_pair_set long ((p struct <held-pair> *) (x long) (y long)) (set (. p x) x) (set (. p y) y) (return 0))
(define-function held_struct_member long ((p struct <held-pair> *)) (return (+ (. p x) (. p y))))
(define-function held_loop_in_operand long ((n long))
  (return (+ (* n 1) (let (((i long) 0) ((s long) 0))
		       (label top)
		       (if (< i n) (let () (set s (+ s i)) (set i (+ i 1)) (goto top)))
		       s))))
(define-function held_int32_negative long ((a int) (b int)) (return (cast (< (* a b) 0) long)))
(define-function held_int32_half long ((a int) (b int)) (return (cast (/ (* a b) 2) long)))
(define-function held_discard long ((a long)) (* a a) (return a))	; a product nothing reads
;; an int literal past an int's range, compared held (nothing pending) and from a slot (two values pending): both must
;; see it wrapped to 32 bits, as storing it in its int slot does (3000000000 is -1294967296)
(define-function held_literal_wide long ((x int)) (return (cast (< x 3000000000) long)))
(define-function held_literal_wide_deep long ((x int) (a long)) (return (+ (* 2 a) (+ (* 2 a) (cast (< x 3000000000) long)))))
