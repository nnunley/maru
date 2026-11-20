;;; A global is found in about the same time whichever globals are in use and wherever they were allocated.  eval2's and
;;; eval3's cache of global bindings had one slot per hash: two globals in use that shared a slot evicted each other, and
;;; each lookup that missed searched every global, so a program slowed severalfold when an unrelated change moved its
;;; symbols.  Reading 500 of 3000 globals, about sixty pairs share a slot of 2003 wherever the symbols land; it stays
;;; within a small factor of reading one global as often.
(define clock (subr "clock" ">l"))	; CPU microseconds
(define-function global-name (i) (string->symbol (concat-string "g" (long->string i))))
(for (i 0 3000) (eval (list 'define (global-name i) i)))
(define names ())
(for (i 0 500) (set names (cons (global-name (* i 6)) names)))
(define many (eval (list 'lambda () (cons 'list names))))			; 500 globals
(define one (eval (list 'lambda () (cons 'list (map (lambda (n) 'g0) names)))))	; one, 500 times
(define-function time-of (f) (let ((t (clock))) (for (i 0 100) (f)) (- (clock) t)))
(time-of many)
(time-of one)
(let ((m (time-of many)) (o (time-of one)))
  (if (< m (* 3 (+ o 2000)))
      (println "global lookup ok")
    (println "global lookup slow: 500 globals took " m " us, one global as often " o " us")))
