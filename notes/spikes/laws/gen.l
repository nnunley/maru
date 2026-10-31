;;; SPIKE (throwaway): generate sentences from a tpeg grammar's records.

(require "tpeg.l")
(require "text-parser.l")

;; seeded, replayable: ZX81's generator
(define *seed* 42)
(define-function rand (n)
  (set *seed* (% (+ (* *seed* 75) 74) 65537))
  (% *seed* n))
(define-function nth (l n) (if (> n 0) (nth (cdr l) (- n 1)) (car l)))
(define-function pick (l) (nth l (rand (list-length l))))

;; rules: alist name -> (body args), later grammars override earlier ones
(define-function grammar-rules (paths)
  (let ((rules ()))
    (list-do path paths
      (list-do r (cdr (parse-file <tpeg> $parser_spec path))
	(set rules (cons (cons (car r) (cdr r)) rules))))
    rules))

(define *rules* ())
(define *height* ())
(define-function rule-body (name) (cadr (or (assq name *rules*) (error "no rule: "name))))

;; minimum derivation height of each rule, by fixpoint, so a bounded
;; generator can always finish
(define height)
(define-function rule-height (name) (or (cdr (assq name *height*)) 999))
(define-function height (pe)
  (let ((k (car pe)) (a (cdr pe)))
    (cond
      ((= k 'match-rule)	(+ 1 (rule-height (car a))))
      ((= k 'match-first)	(let ((m 999)) (list-do e a (set m (min m (height e)))) m))
      ((= k 'match-all)		(let ((m 0)) (list-do e a (set m (max m (height e)))) m))
      ((member? k '(match-zero-more match-zero-one peek-not peek-for peek-expr result-expr)) 0)
      ((member? k '(match-one-more match-require make-span make-string make-symbol))
				(height (car a)))
      ((= k 'make-number)	(height (cadr a)))
      ((= k 'assign-result)	(height (cadr a)))
      (else 0))))
(define-function compute-heights ()
  (set *height* ())
  (let ((changed 1))
    (while changed
      (set changed ())
      (list-do r *rules*
	(let ((h (height (cadr r))))
	  (when (< h (rule-height (car r)))
	    (set *height* (cons (cons (car r) h) *height*))
	    (set changed 1)))))))

;; Fuel bounds a sentence and is split among a sequence's parts, so trees
;; come out balanced.  With none left, a choice takes a cheap alternative that
;; cannot lead back to the rule being expanded, so each rule appears at most
;; once more on any path and generation ends.
(define *reach* ())	; rule -> rules reachable from its body
(define-function refs (pe)
  (cond
    ((not (pair? pe))			())
    ((= 'match-rule (car pe))		(list (cadr pe)))
    (else				(let ((r ())) (list-do x (cdr pe) (set r (concat-list (refs x) r))) r))))
(define-function rule-reach (name) (cdr (assq name *reach*)))
(define-function compute-reach ()
  (set *reach* (map (lambda (r) (cons (car r) (refs (cadr r)))) *rules*))
  (let ((changed 1))
    (while changed
      (set changed ())
      (list-do entry *reach*
	(list-do n (cdr entry)
	  (list-do m (rule-reach n)
	    (unless (member? m (cdr entry))
	      (set-cdr entry (cons m (cdr entry)))
	      (set changed 1))))))))
(define-function reaches? (pe name)
  (let ((r ())) (list-do n (refs pe) (or r (set r (or (= n name) (member? name (rule-reach n)))))) r))

(define *current* ())
(define gen)
(define-function cheapest (alts)
  (let ((m 999) (best ()))
    (list-do e alts (set m (min m (height e))))
    (list-do e alts (and (= m (height e)) (push best e)))
    best))
(define-function leaves (alts)
  (let ((m 999) (ok ()))
    (list-do e alts (set m (min m (height e))))
    (list-do e alts (and (<= (height e) (+ m 2)) (not (reaches? e *current*)) (push ok e)))
    (or ok (cheapest alts))))

(define-function grows? (pe)	(and (pair? pe) (or (= 'match-rule (car pe)) (let ((r ())) (list-do x (cdr pe) (or r (set r (grows? x)))) r))))

(define-function repeat-gen (n pe f)
  (let ((s "") (ok 1) (each (/ f (max n 1))))
    (while (and ok (> n 0))
      (let ((x (gen pe each))) (if x (set s (concat-string s x)) (set ok ())))
      (set n (- n 1)))
    (and ok s)))

(define-function gen (pe f)
  (let ((k (car pe)) (a (cdr pe)))
    (cond
      ((= k 'match-rule)	(let ((outer *current*))
				  (set *current* (car a))
				  (let ((s (gen (rule-body (car a)) f)))
				    (set *current* outer)
				    s)))
      ((= k 'match-first)	(if (> f 0)
				    (gen (pick a) (- f 1))
				  (gen (pick (leaves a)) 0)))
      ((= k 'match-all)		(let ((s "") (n 0))
				  (list-do e a (and (grows? e) (set n (+ n 1))))
				  (let ((each (/ f (max n 1))))
				    (list-do e a (and s (let ((x (gen e each))) (set s (and x (concat-string s x))))))
				    s)))
      ((= k 'match-zero-more)	(repeat-gen (if (> f 0) (rand 3) 0) (car a) f))
      ((= k 'match-one-more)	(repeat-gen (+ 1 (if (> f 0) (rand 2) 0)) (car a) f))
      ((= k 'match-zero-one)	(repeat-gen (if (> f 0) (rand 2) 0) (car a) f))
      ((= k 'match-string)	(car a))
      ((= k 'match-class)	(let ((cs (text-parser-make-class (car a))))
				  (character->string (string-at cs (rand (string-length cs))))))
      ((= k 'match-any)		(character->string (string-at "ab1 +*" (rand 6))))
      ((= k 'assign-result)	(gen (cadr a) f))
      ((member? k '(match-require make-span make-string make-symbol)) (gen (car a) f))
      ((= k 'make-number)	(gen (cadr a) f))
      ((member? k '(result-expr peek-not peek-for peek-expr)) "")
      (else			(error "gen: no case for "k)))))

(define-function generate (rule fuel)	(gen (list 'match-rule rule) fuel))

;; parse TEXT as RULE of CLASS, entirely; the parse result or ()
(define *parser-init* (lambda (p) ()))
(define-function quiet-expected (self what) ())
(define-function parses (class rule text)
  (let ((expected text-parser-expected)
	(p (text-parser-for-on class text)))
    (*parser-init* p)
    (set text-parser-expected quiet-expected)
    (let ((ok (text-parser-invoke-rule rule (eval (concat-symbol '$ rule)) p)))
      (set text-parser-expected expected)
      (and ok (= (<text-parser>-position p) (string-length text))
	   (list (<text-parser>-result p))))))


;; a sentence of RULE that CLASS parses, within D, with the attempts it took
(define-function sentence (class rule d)
  (let ((tries 0) (found ()))
    (while (and (not found) (< tries 50))
      (set tries (+ tries 1))
      (let ((s (generate rule d)))
	(and s (parses class rule s) (set found s))))
    (cons found tries)))
