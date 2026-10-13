;;; ir2 must lay out every C type as osdefs.k measured it, and move pointers
;;; by bytes (maru-check.k).  Expected values are computed in the host, from
;;; osdefs.k, while the checks are expanded.
;;;
;;; ./eval2 ir-gen-c.k maru.k check/ir2.k > ir2.c && cc -o ir2 ir2.c && ./ir2

(define (printf (int    char * ...) *) (extern printf))
(define (exit   (void   int)        *) (extern exit))
(define (malloc (void * long)       *) (extern malloc))

(define-form check (what test)
  `(unless ,test
     (printf "FAIL %s\n" ,what)
     (exit 1)))

;; For C type `name` (osdefs.k's spelling) written `type...` in Maru: its size,
;; its alignment (padding before it after a char), and tail padding after it.
(define-form layout (name . type)
  (let ((size   (eval (concat-symbol 'sizeof- name)))
	(al     (eval (concat-symbol 'alignof- name)))
	(before (concat-symbols '<before- name '>))
	(after  (concat-symbols '<after- name '>)))
    `(let ()
       (define-struct ,before ((c char) (x ,@type)))
       (define-struct ,after  ((x ,@type) (c char)))
       (check ,(symbol->string (concat-symbol name '-size))      (= (sizeof ,@type) ,size))
       (check ,(symbol->string (concat-symbol name '-alignment)) (= (sizeof struct ,before) ,(align (+ al size) al)))
       (check ,(symbol->string (concat-symbol name '-tail))      (= (sizeof struct ,after)  ,(align (+ size 1) al))))))

;; Adding an integer of any width to a pointer moves it by that many bytes, and
;; the difference keeps the pointers' full width.
(define-form offset (type n)
  `(let (((n ,type) ,n))
     (check ,(symbol->string (concat-symbol type '-offset)) (= (- (+ q n) q) ,n))))

(define-function main int ((argc int) (argv char * *))
  (layout char char)  (layout short short)  (layout int int)  (layout long long)
  (layout int32 int32)  (layout int64 int64)  (layout float float)  (layout double double)
  (layout pointer void *)
  (let (((q long *) (cast (malloc 64) long *)))
    (offset char 3)  (offset short -3)  (offset int 3)  (offset long -3)
    (offset int64 8589934592))
  (printf "ir2 ok\n")
  (return 0))
