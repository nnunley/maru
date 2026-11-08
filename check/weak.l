;;; hash.l's weak tables, on every evaluator: a key held only by the table is collected with its entry; a key held
;;; elsewhere keeps it; and a value keeps its own key no more than the table does (an ephemeron), though it keeps alive
;;; what it holds once its key is alive, however the entries are ordered.
(require "hash.l")
(require "recover.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define collect (subr "GC_gcollect"))
(define table (weak-identity-hash-table))
(define keep (cons 'kept ()))

(define-function put-unheld (value-of)	; an entry whose key nothing else holds; value-of makes its value from its key
  (let ((k (cons 'unheld ()))) (hash-at-put table k (value-of k)) ()))
(define-function put-strong (t) (let ((k (cons 'strong ()))) (hash-at-put t k 'v) ()))
(define-function settle () (collect) ())	; one collection: an entry goes in the one where its key dies

(hash-at-put table keep 'v)
(put-unheld (lambda (k) 'w))
(put-unheld (lambda (k) (list k)))	; its value holds its key
(expect "every entry, before a collection" (hash-count table) 3)
(settle)
(expect "after one, only the entry whose key is held elsewhere" (list (hash-count table) (hash-at table keep)) '(1 v))
(let ((keys ())) (hash-do table (lambda (k v) (push keys (car k)))) (expect "and only it is visited" keys '(kept)))

;; a key reachable only through a live entry's value lives, though its entry comes before the one that holds it
(define-function put-chained ()
  (let ((inner (cons 'inner ())))
    (hash-at-put table inner 'reached)
    (hash-at-put table keep (list inner))
    ()))
(put-chained)
(settle)
(expect "a key held by a live entry's value survives" (list (hash-count table) (hash-at table (car (hash-at table keep)))) '(2 reached))
(hash-at-put table keep 'v)
(settle)
(expect "and goes once that value no longer holds it" (hash-count table) 1)

;; a chain of thirty, each key held only by the entry before it and the first by an entry put after them all, so marking
;; meets every link's entry before any link is alive and must go round again
(define head (cons 'head ()))
(define-function put-chain (n)
  (let ((keys ()) (i 0))
    (while (< i n) (push keys (cons 'link i)) (set i (+ i 1)))
    (let ((ks keys)) (while ks (hash-at-put table (car ks) (and (cdr ks) (cadr ks))) (set ks (cdr ks))))
    (hash-at-put table head (car keys))
    ()))
(define-function chain-length ()
  (let ((k (hash-at table head)) (n 0)) (while k (set n (+ n 1)) (set k (hash-at table k))) n))
(put-chain 30)
(settle)
(expect "a chain of keys each held by the entry before it survives whole" (list (hash-count table) (chain-length)) '(32 30))
(hash-at-put table head ())
(settle)
(expect "and goes whole once its head lets go" (hash-count table) 2)

;; a cache whose keys keep dying: round after round of keys put and let go, the table stays its live size, not the sum
(define-function put-round (n) (let ((i 0)) (while (< i n) (put-unheld (lambda (k) 'r)) (set i (+ i 1)))) ())
(let ((r 0)) (while (< r 20) (put-round 50) (settle) (hash-count table) (set r (+ r 1))))
(expect "twenty rounds of fifty dead keys leave a table its live size"
	(list (hash-count table) (< (array-length (<hash-table>-entries table)) 100)) '(2 t))	; keep and head

(expect "a number or nil is no weak key"
	(list (try (hash-at-put table 3 'x) (lambda (c) 'refused)) (try (hash-at-put table () 'x) (lambda (c) 'refused)))
	'(refused refused))
(expect "an identity table is still strong" (let ((t (identity-hash-table))) (put-strong t) (settle) (hash-count t)) 1)

(println (if ok "weak ok" "weak FAILED"))
