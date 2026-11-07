;;; hash.l -- a hash table in Maru, on every evaluator: keys by identity or by equality, kept in the order first put.
;;;
;;; An entry is (key . value) in an array, in the order its key was first put; a removed one is left as (), which a lookup
;;; passes over, and the array is compacted, and its buckets rebuilt, when as many are gone as remain.  Buckets hold the entries' indices.  An identity hash is an address,
;;; and loading a saved image moves every object, so a table keeps an anchor of its own and rehashes, before answering,
;;; once the anchor has moved.

(define-structure <hash-table> (hash same buckets entries count removed anchor stamp))

;; identity, as Smalltalk's ==: a number is itself (eval2 and eval3 box them, so two 5s needn't share an address), and
;; of one kind only (2 isn't 2.0); anything else is where it lives (Maru's = compares strings by their text)
(define-function hash-identical? (a b)
  (cond ((and (long? a) (long? b))	(= a b))
	((and (double? a) (double? b))	(= a b))
	(else				(= (address-of a) (address-of b)))))
(define-function hash-address (x) (>> (address-of x) 4))
;; a number by its double's whole part, as = compares a long with a double (2^53 + 1 is 2^53.0); one with no whole part a
;; long can hold (NaN, infinite, past 2^62) hashes as 0
(define-function hash-number (x)
  (let ((d (* 1.0 x)))
    (if (and (< -4.0e18 d) (< d 4.0e18)) (double->long d) 0)))
(define-function hash-identity (x)
  (if (or (long? x) (double? x)) (hash-number x) (hash-address x)))

;; equality is Maru's equal: 2 and 2.0 are equal, so a number hashes by its double; a string by its text, a pair by
;; its first few elements (equal walks them all), anything else by where it lives, as equal compares it
(define-function hash-text (s)
  (let ((h 7))
    (for (i 0 (string-length s)) (set h (% (+ (* h 31) (string-at s i)) 16777213)))
    h))
(define hash-equal-depth)
(define-function hash-equal (x) (hash-equal-depth x 4))
(set hash-equal-depth
     (lambda (x depth)
       (cond ((or (long? x) (double? x))	(hash-number x))
	     ((string? x)	(hash-text x))
	     ((pair? x)		(if (< 0 depth)
				    (% (+ (* 31 (hash-equal-depth (car x) (- depth 1))) (hash-equal-depth (cdr x) (- depth 1))) 16777213)
				  17))
	     (else		(hash-address x)))))

(define-function make-hash-table (hash same)
  (let ((anchor (cons () ())))
    (new <hash-table> hash same (array 8) (array 0) 0 0 anchor (address-of anchor))))
(define-function identity-hash-table () (make-hash-table hash-identity hash-identical?))
(define-function equal-hash-table () (make-hash-table hash-equal equal))
(define-function hash-table-same? (table a b) ((<hash-table>-same table) a b))

(define-function hash-bucket-of (table key)
  (let* ((n (array-length (<hash-table>-buckets table))) (r (% ((<hash-table>-hash table) key) n)))
    (if (< r 0) (+ r n) r)))	; % keeps the sign, and negating the least long gives itself back

;; every live entry indexed afresh into buckets of size n, the entries compacted, the anchor's place noted
(define-function hash-rebuild (table n)
  (let ((old (<hash-table>-entries table)) (entries (array 0)) (buckets (array n)))
    (set (<hash-table>-buckets table) buckets)
    (array-do e old
      (when e
	(let ((b (hash-bucket-of table (car e))))
	  (set-array-at buckets b (cons (array-length entries) (array-at buckets b)))
	  (array-append entries e))))
    (set (<hash-table>-entries table) entries)
    (set (<hash-table>-removed table) 0)
    (set (<hash-table>-stamp table) (address-of (<hash-table>-anchor table)))))
(define-function hash-current (table)	; rehashed if a loaded image moved what its hashes were made from
  (or (= (<hash-table>-stamp table) (address-of (<hash-table>-anchor table)))
      (hash-rebuild table (array-length (<hash-table>-buckets table)))))

;; the index of key's entry, or ()
(define-function hash-index (table key)
  (hash-current table)
  (let ((is (array-at (<hash-table>-buckets table) (hash-bucket-of table key))) (entries (<hash-table>-entries table))
	(same (<hash-table>-same table)) (found ()))
    (while (and is (not found))
      (let ((e (array-at entries (car is))))
	(and e (same (car e) key) (set found (car is))))
      (set is (cdr is)))
    found))

(define-function hash-includes? (table key) (and (hash-index table key) 't))
(define-function hash-at (table key . default)
  (let ((i (hash-index table key)))
    (if i (cdr (array-at (<hash-table>-entries table) i)) (car default))))
(define-function hash-at-put (table key value)
  (let ((i (hash-index table key)))
    (if i
	(set-cdr (array-at (<hash-table>-entries table) i) value)
      (let ((entries (<hash-table>-entries table)) (b (hash-bucket-of table key)) (buckets (<hash-table>-buckets table)))
	(set-array-at buckets b (cons (array-length entries) (array-at buckets b)))
	(array-append entries (cons key value))
	(set (<hash-table>-count table) (+ 1 (<hash-table>-count table)))
	(and (< (* 3 (array-length buckets)) (* 4 (<hash-table>-count table)))	; past three quarters full: twice the buckets
	     (hash-rebuild table (* 2 (array-length buckets))))))
    value))
(define-function hash-remove (table key . default)	; the value key had, or default if it had none
  (let ((i (hash-index table key)))
    (if (not i)
	(car default)
      (let* ((entries (<hash-table>-entries table)) (e (array-at entries i)))
	(set-array-at entries i ())
	(set (<hash-table>-count table) (- (<hash-table>-count table) 1))
	(set (<hash-table>-removed table) (+ 1 (<hash-table>-removed table)))
	(and (< (<hash-table>-count table) (<hash-table>-removed table))	; as many gone as remain: compact (a bucket's
	     (hash-rebuild table (array-length (<hash-table>-buckets table))))	; index of a removed entry finds () till then)
	(cdr e)))))
(define-function hash-count (table) (<hash-table>-count table))
(define-function hash-do (table fn)	; (fn key value) for each entry, in the order first put
  (array-do e (<hash-table>-entries table) (and e (fn (car e) (cdr e)))))
(define-function hash-keys (table)
  (let ((out (array 0))) (hash-do table (lambda (k v) (array-append out k))) out))
