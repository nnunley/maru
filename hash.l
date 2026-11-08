;;; hash.l -- a hash table in Maru, on every evaluator: keys by identity or by equality, kept in the order first put.
;;;
;;; An entry is (key . value) in an array, in the order its key was first put; a removed one is left as (), which a lookup
;;; passes over, and the array is compacted, and its buckets rebuilt, when as many are gone as remain.  Buckets hold the entries' indices.  An identity hash is an address,
;;; and loading a saved image moves every object, so a table keeps an anchor of its own and rehashes, before answering,
;;; once the anchor has moved.
;;;
;;; A weak table holds its keys weakly: an entry is an ephemeron (gc.c), a pair whose value the collector keeps only while
;;; something other than the table keeps the key, so an entry goes with its key, and a value holding its own key doesn't
;;; keep it.  A collected entry is cleared, key and value (), and the table drops it the next time it's used.  Its keys
;;; are objects: a number or nil has no identity to outlive, so neither is a weak key.

(define-structure <hash-table> (hash same buckets entries count removed anchor stamp weak))	; weak: () or the
;; collection count when cleared entries were last dropped

;; identity, as Smalltalk's ==: a number is itself (eval2 and eval3 box them, so two 5s needn't share an address), and
;; of one kind only (2 isn't 2.0); anything else is where it lives (Maru's = compares strings by their text)
(define-function hash-identical? (a b)
  (cond ((and (long? a) (long? b))	(= a b))
	((and (double? a) (double? b))	(= a b))
	(else				(= (address-of a) (address-of b)))))
(define-function hash-address (x) (>> (address-of x) 4))
;; a number by its value (boot.l's equal-hash), anything else by where it lives
(define-function hash-identity (x)
  (if (or (long? x) (double? x)) (equal-hash x) (hash-address x)))

;; equality is Maru's equal, each type's own (boot.l): equal-hash agrees with it, numbers by value, strings by text, pairs
;; and arrays by their elements, and a type that defines equal defines equal-hash beside it
(define-function make-hash-table (hash same)
  (let ((anchor (cons () ())))
    (new <hash-table> hash same (array 8) (array 0) 0 0 anchor (address-of anchor) ())))
(define-function identity-hash-table () (make-hash-table hash-identity hash-identical?))
(define-function equal-hash-table () (make-hash-table equal-hash equal))
(define hash-collections (subr "GC_collection_count" ">l"))
(define hash-weaken (subr "GC_weaken" "l"))
(define-function weak-identity-hash-table ()
  (let ((table (identity-hash-table))) (set (<hash-table>-weak table) (hash-collections)) table))
(define-function hash-table-same? (table a b) ((<hash-table>-same table) a b))

(define-function hash-bucket-of (table key)
  (let* ((n (array-length (<hash-table>-buckets table))) (r (% ((<hash-table>-hash table) key) n)))
    (if (< r 0) (+ r n) r)))	; % keeps the sign, and negating the least long gives itself back

;; every live entry indexed afresh into buckets of size n, the entries compacted, the anchor's place noted
(define-function hash-rebuild (table n)
  (let ((old (<hash-table>-entries table)) (entries (array 0)) (buckets (array n)))
    (set (<hash-table>-buckets table) buckets)
    (array-do e old
      (when (and e (or (car e) (not (<hash-table>-weak table))))	; a weak table's cleared entries go
	(let ((b (hash-bucket-of table (car e))))
	  (set-array-at buckets b (cons (array-length entries) (array-at buckets b)))
	  (array-append entries e))))
    (set (<hash-table>-entries table) entries)
    (set (<hash-table>-count table) (array-length entries))	; what it kept: an entry cleared meanwhile isn't among them
    (set (<hash-table>-removed table) 0)
    (set (<hash-table>-stamp table) (address-of (<hash-table>-anchor table)))))
(define-function hash-drop-cleared (table)	; a weak table's entries the collector cleared, gone
  (let ((entries (<hash-table>-entries table)) (i 0))
    (set (<hash-table>-weak table) (hash-collections))
    (while (< i (array-length entries))
      (let ((e (array-at entries i)))
	(when (and e (not (car e)))
	  (set-array-at entries i ())
	  (set (<hash-table>-count table) (- (<hash-table>-count table) 1))
	  (set (<hash-table>-removed table) (+ 1 (<hash-table>-removed table)))))
      (set i (+ i 1)))
    (and (< (<hash-table>-count table) (<hash-table>-removed table))	; as many gone as remain: compact, as hash-remove does
	 (hash-rebuild table (array-length (<hash-table>-buckets table))))))
(define-function hash-current (table)	; rehashed if a loaded image moved what its hashes were made from; a weak one rid of
  (let ((w (<hash-table>-weak table)))	; what the collector cleared since it last looked (and after a move: a loaded image's
    (and w (not (= w (hash-collections))) (hash-drop-cleared table))	; count says nothing of when it last looked)
    (or (= (<hash-table>-stamp table) (address-of (<hash-table>-anchor table)))
	(let () (and w (hash-drop-cleared table)) (hash-rebuild table (array-length (<hash-table>-buckets table)))))))

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

(define-function hash-table? (x) (= <hash-table> (type-of x)))
(define-function hash-entry (table key)	; key's entry, (key . value), to read or set its value; or ()
  (let ((i (hash-index table key))) (and i (array-at (<hash-table>-entries table) i))))
(define-function hash-includes? (table key) (and (hash-index table key) 't))
(define-function hash-at (table key . default)
  (let ((i (hash-index table key)))
    (if i (cdr (array-at (<hash-table>-entries table) i)) (car default))))
(define-function hash-new-entry (table key value)	; (key . value), an ephemeron in a weak table
  (if (not (<hash-table>-weak table))
      (cons key value)
    (and (or (not key) (long? key) (double? key)) (error "hash-at-put: " key " can't be a weak table's key: it has no identity"))
    (let ((e (cons key value))) (hash-weaken (address-of e)) e)))
(define-function hash-at-put (table key value)
  (let ((i (hash-index table key)))
    (if i
	(set-cdr (array-at (<hash-table>-entries table) i) value)
      (let ((entries (<hash-table>-entries table)) (b (hash-bucket-of table key)) (buckets (<hash-table>-buckets table))
	    (e (hash-new-entry table key value)))	; refused before the table is touched
	(set-array-at buckets b (cons (array-length entries) (array-at buckets b)))
	(array-append entries e)
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
(define-function hash-count (table) (hash-current table) (<hash-table>-count table))
(define-function hash-do (table fn)	; (fn key value) for each entry, in the order first put (in a weak table, each not yet
  (hash-current table)			; collected: fn may collect one)
  (let ((weak (<hash-table>-weak table)))
    (array-do e (<hash-table>-entries table) (and e (or (car e) (not weak)) (fn (car e) (cdr e))))))
(define-function hash-keys (table)
  (let ((out (array 0))) (hash-do table (lambda (k v) (array-append out k))) out))
