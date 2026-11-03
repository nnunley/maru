;;; Helpers for the tpeg checks: a user's type as a source, and running a rule on any source.
(require "text-parser.l")

(define ok 1)
(define-function expect (what got want)
  (or (equal got want)
      (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))

;; a user's type that generates its elements on demand
(define-structure <countdown> (elements))
(define-method in-enter    <countdown> ()		1)
(define-method in-start    <countdown> ()		0)
(define-method in-at-end   <countdown> (pos)		(>= pos (list-length self.elements)))
(define-method in-head     <countdown> (pos)
  (let ((l self.elements))
    (for (i 0 pos) (set l (cdr l)))
    (car l)))
(define-method in-tail     <countdown> (pos)		(+ pos 1))

;; eval2 has no byte buffers: its Data type is a stub.  eval3, its successor, has them.
(define has-bytes (defined? 'data))

(define-function bytes-of (string)
  (let ((s (data-stream 8)))
    (for (i 0 (string-length string)) (data-stream-put-byte s (string-at string i)))
    (data-stream-truncate s)
    s))

(define-function finish (name) (and ok (println name " ok")))
