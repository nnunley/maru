;;; Raw access to any object is held to its block, on every evaluator: an index before the start (which would reach the
;;; header) or whose byte offset wraps is refused (eval2 has no data, so a pair stands in).
(require "recover.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function refused? (thunk) (try (let () (thunk) ()) (lambda (c) 't)))
(let ((p (cons 1 2)))
  (expect "a byte before a pair's start" (refused? (lambda () (byte-at p -1))) 't)
  (expect "a write before it" (refused? (lambda () (set-byte-at p -1 0))) 't)
  (expect "an index whose offset wraps to 0" (refused? (lambda () (int32-at p 4611686018427387904))) 't)
  (expect "the pair is intact" (list (car p) (cdr p)) '(1 2)))
(println (if ok "byte bounds ok" "byte bounds FAILED"))
