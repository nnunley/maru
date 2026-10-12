;; Pointer arithmetic as seen by the ir2 C backend.  check.sh compares this
;; program's output with the same arithmetic done in C, where adding n to a
;; pointer advances it by n elements and void * advances by bytes.

(define (printf (int    char * ...) *) (extern printf))
(define (malloc (void * long)       *) (extern malloc))

(define-struct <quad> ((a long) (b long) (c long) (d long)))

(define-function main int ((argc int) (argv char * *))
  (let ((p (cast (malloc 1024) struct <quad> *))
	(q (cast (malloc 1024) long *)))
    (printf "quad + 1 %ld\n"    (- (cast (+ p 1) long) (cast p long)))
    (printf "quad + 3 %ld\n"    (- (cast (+ p 3) long) (cast p long)))
    (printf "quad - 1 %ld\n"    (- (cast p long) (cast (- p 1) long)))
    (printf "void + 5 %ld\n"    (- (cast (+ (cast p void *) 5) long) (cast p long)))
    (printf "quad diff %ld\n"   (- (+ p 3) p))
    (printf "long + 2 %ld\n"    (- (cast (+ q 2) long) (cast q long))))
  (return 0))
