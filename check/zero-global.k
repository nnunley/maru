;;; A global declared without an initialiser starts at zero, scalar or struct.

(define (printf (int char * ...) *) (extern printf))

(define-struct Pair ((a int) (b int)))
(define (zero-pair struct Pair))
(define (zero-int int))

(define-function main int ()
  (let ((zero (and (= zero-int 0) (= (member zero-pair a) 0) (= (member zero-pair b) 0))))
    (set-member zero-pair a 5)
    (if (and zero (= (member zero-pair a) 5))
	(printf "zero global ok\n")
      (printf "zero global FAIL\n")))
  (return 0))
