;;; hash.law's references: hash.l's tables against an association list kept in the order keys were first put and
;;; searched with an equality of its own (Maru's equal, or identity written here), so the model is obviously right.
(require "hash.l")
(define *table* ())
(define *model* ())	; ((key . value) ...), last put first (consed on, so no append walks it)
(define *ok* 1)
(define *model-same* ())
(define-function model-identical? (a b)	; Smalltalk's ==, written apart from hash.l's
  (if (and (or (long? a) (double? a)) (or (long? b) (double? b)))
      (and (= (long? a) (long? b)) (= a b))
    (= (address-of a) (address-of b))))
(define-function same-answer (got want) (or (= got want) (set *ok* ())))

(define-function model-cell (key)
  (let ((m *model*) (found ()))
    (while (and m (not found))
      (and (*model-same* (caar m) key) (set found (car m)))
      (set m (cdr m)))
    found))
(define-function model-put (key value)
  (let ((cell (model-cell key)))
    (if cell (set-cdr cell value) (push *model* (cons key value)))))
(define-function model-remove (key)
  (let ((cell (model-cell key)))
    (and cell (set *model* (let ((out ())) (list-do c *model* (or (= c cell) (push out c))) (list-reverse! out))))
    (if cell (cdr cell) 'absent)))

(define-function ops-put (key value) (hash-at-put *table* key value) (model-put key value))
(define-function ops-remove (key) (same-answer (hash-remove *table* key 'absent) (model-remove key)))
(define-function ops-get (key)
  (let ((cell (model-cell key)))
    (same-answer (hash-at *table* key 'absent) (if cell (cdr cell) 'absent))
    (same-answer (hash-includes? *table* key) (and cell 't))))
(define-function ops-double (n) (* 1.0 n))
(define-function ops-half (n) (+ 0.5 n))
(define-function ops-min () (<< 1 63))	; the least long, whose negation is itself
(define *kept* (list->array (list "kept" 'kept (cons 1 2) (array 2) (cons (cons 1 2) 3) "k2" 'k2 (cons 4 5))))
(define-function ops-kept (n) (array-at *kept* (% n 8)))
(define-function ops-deep (n)	; a list of n + 6 nested pairs, past hash-equal's depth
  (let ((x n)) (for (i 0 (+ n 6)) (set x (cons i x))) x))
(define-function ops-grow (n) (for (i 0 n) (ops-put (+ 100 i) i)))
(define ops-run)
(define ops-key)
(require "build/hash-ops.g.l")
(set ops-run (lambda (p) (parse-source <hash-ops> $run (list p))))
(set ops-key (lambda (k) (parse-source <hash-ops> $key (list k))))

(define-function new-table (kind)
  (set *model-same* (if (= kind 'Identity) model-identical? equal))
  (if (= kind 'Identity) (identity-hash-table) (equal-hash-table)))
;; the table holds what the model holds: its count, and every key and value in the order first put
(define-function table-agrees? ()
  (let ((pairs ()))
    (hash-do *table* (lambda (k v) (push pairs (cons k v))))
    (set pairs (list-reverse! pairs))
    (same-answer (hash-count *table*) (list-length *model*))
    (same-answer (list-length pairs) (list-length *model*))
    (let ((m (let ((r ())) (list-do c *model* (push r c)) r)))	; first put first
      (list-do p pairs
	(and m (let () (same-answer (car p) (caar m)) (same-answer (cdr p) (cdar m)) (set m (cdr m))))))
    *ok*))

(define-function programs_agree (p kind)
  (set *table* (new-table kind)) (set *model* ()) (set *ok* 1)
  (ops-run p)
  (if (table-agrees?) accept reject))

;; n numbers and n strings in, every one found again (a string by an equal copy in an equality table, by itself in an
;; identity one), half removed, and the rest still found in order
(define-function grows (n kind)
  (set *table* (new-table kind)) (set *model* ()) (set *ok* 1)
  (let ((strings (array n)))
    (for (i 0 n) (set-array-at strings i (concat-string "s" (long->string i))))
    (for (i 0 n) (ops-put i (* 2 i)) (ops-put (array-at strings i) i))
    (for (i 0 n)
      (ops-get i)
      (ops-get (if (= kind 'Identity) (array-at strings i) (concat-string "s" (long->string i)))))
    (for (i 0 n) (or (= 0 (% i 4)) (let () (ops-remove i) (ops-remove (array-at strings i)))))	; three quarters: compaction
    (for (i 0 n) (ops-get i) (ops-get (array-at strings i))))
  (if (table-agrees?) accept reject))

;; a table holding a finds b just when the model takes them as one key
(define-function finds_iff_same (a b kind)
  (let ((t (new-table kind)) (x (ops-key a)) (y (ops-key b)))
    (hash-at-put t x 1)
    (if (and (= (hash-includes? t x) 't) (= (hash-includes? t y) (and (*model-same* x y) 't))) accept reject)))
;; identity: two strings of one text are two keys, as are 2 and 2.0, but 2 and 2 (boxed apart on eval2 and eval3) are one;
;; equality: Maru's equal, so the strings are one key and 2 and 2.0 are one
(define-function key-count (table keys) (list-do k keys (hash-at-put table k 0)) (hash-count table))
(define-function key_kinds (n)
  (let ((keys (list "ab" (concat-string "a" "b") 2 2.0 (+ 1 1) 'x 'x (cons 1 2) (cons 1 2))))
    (if (equal (list (key-count (identity-hash-table) keys) (key-count (equal-hash-table) keys)) '(7 4)) accept reject)))
