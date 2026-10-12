;; Type sizes and long arithmetic as seen by the ir2 C backend.  check.sh
;; compares this program's output with the same values printed by C.

(define (printf (int char * ...) *) (extern printf))

(define-struct <int-long>   ((i int) (l long)))
(define-struct <int-double> ((i int) (d double)))

(define-function same long ((x long)) (return x))

(define-function main int ((argc int) (argv char * *))
  (printf "long %d\n"           (sizeof long))
  (printf "pointer %d\n"        (sizeof void *))
  (printf "int+long %d\n"       (sizeof struct <int-long>))
  (printf "int+double %d\n"     (sizeof struct <int-double>))
  (printf "long 2^40 %ld\n"     (same (* (cast 1048576 long) (cast 1048576 long))))
  (return 0))
