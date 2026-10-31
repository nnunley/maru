;;; SPIKE: a template's hole {x} takes the kind of the first rule asked to
;;; match where it stands (rules that can match nothing are skipped);
;;; {x: rule} names the kind instead.
(define *nullable* ())
(define-function nullable? (pe)
  (let ((k (car pe)) (a (cdr pe)))
    (cond
      ((= k 'match-rule)	(member? (car a) *nullable*))
      ((= k 'match-first)	(let ((r ())) (list-do e a (or r (set r (nullable? e)))) r))
      ((= k 'match-all)		(let ((r 1)) (list-do e a (and r (set r (nullable? e)))) r))
      ((member? k '(match-zero-more match-zero-one peek-not peek-for peek-expr result-expr)) 1)
      ((= k 'match-string)	(= 0 (string-length (car a))))
      ((member? k '(match-one-more match-require make-span make-string make-symbol)) (nullable? (car a)))
      ((= k 'make-number)	(nullable? (cadr a)))
      ((= k 'assign-result)	(nullable? (cadr a)))
      (else ()))))
(define-function compute-nullable ()
  (let ((changed 1))
    (while changed
      (set changed ())
      (list-do r *rules*
	(and (not (member? (car r) *nullable*)) (nullable? (cadr r))
	     (let () (push *nullable* (car r)) (set changed 1)))))))

(define-function hole-at (self name)
  (let* ((s (<text-parser>-string self)) (p (<text-parser>-position self)) (n (string-length s)))
    (and (< p n) (= ?{ (string-at s p)) (not (member? name *nullable*))
	 (let ((q p))
	   (while (and (< q n) (not (= ?} (string-at s q)))) (set q (+ q 1)))
	   (let* ((body (string-copy s (+ p 1) (- (- q p) 1)))
		  (colon (let ((i 0) (c ())) (while (< i (string-length body)) (and (= ?: (string-at body i)) (not c) (set c i)) (set i (+ i 1))) c))
		  (var  (string->symbol (if colon (string-copy body 0 colon) body)))
		  (want (and colon (string->symbol (let ((t (string-copy body (+ colon 1) (- (- (string-length body) colon) 1)))) (while (= ?  (string-at t 0)) (set t (string-copy t 1 (- (string-length t) 1)))) t)))))
	     (and (or (not want) (= want name))
		  (let ((q (+ q 1)))
		    (while (and (< q n) (member? (string-at s q) '(32 9))) (set q (+ q 1)))
		    (set (<text-parser>-position self) q)
		    (set (<text-parser>-result self) (list 'hole var name))
		    1)))))))

(define-function enable-holes ()
  (let ((inner text-parser-invoke-rule))
    (set text-parser-invoke-rule
	 (lambda (name rule self . args)
	   (or (hole-at self name) (apply inner (concat-list (list name rule self) args)))))))
