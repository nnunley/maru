;;; Tables saved in an image (check/hash-image-read.l reads them back after it moves every object): an identity table, and
;;; an equal table with a symbol, nil, a string and a number among its keys and one key removed before the save; and a weak
;;; table, one key held by keys and one by nothing else.
(require "hash.l")
(define keys (list "a" 'b (cons 1 2)))
(define h (identity-hash-table))
(list-do k keys (hash-at-put h k k))
(define e (equal-hash-table))
(list-do k (list 'b () "s" 2 3) (hash-at-put e k k))
(hash-remove e 3)
(define w (weak-identity-hash-table))
(hash-at-put w (car keys) 'held)
(hash-at-put w (cons 'unheld ()) 'gone)
(save (next-argument))
