;;; weak.law's reference: a graph put into a weak table, keys made fresh for each run and held only where the graph says,
;;; then collected; answers whether the keys whose entries survive are the ones the law file's model says, in key order.
(require "hash.l")
(define collect (subr "GC_gcollect"))
(define *weak* ())
(define *keys* ())	; while a graph is put, the one object each key number names; dropped before collecting
(define *roots* ())
(define-function weak-key (i) (or (array-at *keys* i) (set-array-at *keys* i (cons 'key i))))
(define-function weak_put (k s) (hash-at-put *weak* (weak-key k) (map weak-key s)) 0)
(define-function hold (roots) (set *roots* (map weak-key roots)) 0)

(define-function surviving ()	; the numbers of the keys still in the table, least first
  (let ((found (array 6)) (out ()))
    (hash-do *weak* (lambda (k v) (set-array-at found (cdr k) 't)))
    (for (i 0 6) (and (array-at found i) (push out i)))
    (list-reverse! out)))
(define-function survives_as (run want)
  (set *weak* (weak-identity-hash-table)) (set *keys* (array 6)) (set *roots* ())
  (run)
  (set *keys* ())
  (collect)
  (if (equal (surviving) want) accept reject))
