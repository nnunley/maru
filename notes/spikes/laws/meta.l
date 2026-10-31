;;; SPIKE: laws about the rule system, with Nile as the reference.
(load "notes/spikes/laws/logic.l")
(load "notes/spikes/laws/nile-rules.l")
(load "notes/spikes/laws/oracle.l")

;; expressions that ignore types, from the same engine: the agreement
;; law's independent source
(rule u-var    (uexpr $env (var $v))		(member ($v . $t) $env))
(rule u-num    (uexpr $env (num $n))		(numeral $n))
(rule u-prefix (uexpr $env (prefix $op $a))	(prefix $op $x $y) (uexpr $env $a))
(rule u-infix  (uexpr $env (infix $op $a $b))	(infix $op $x $y $z) (uexpr $env $a) (uexpr $env $b))

(define law-types '(Number Boolean))
(define-function typed (i) (if (= 0 (% i 2)) 'Number 'Boolean))

;; law sound: what the rules generate at T, Nile accepts at T
(define-function law-sound (n)
  (let ((bad ()))
    (for (i 0 n)
      (let* ((t (typed i)) (e (generate (list 'expr nile-env t '$e) 3)))
	(or (nile-accepts? (nile-text e) t) (set bad (cons (cons (nile-text e) t) bad)))))
    bad))
;; law generate-checks: what the rules generate at T, the rules check at T
(define-function law-gen-checks (n)
  (let ((bad ()))
    (for (i 0 n)
      (let* ((t (typed i)) (e (generate (list 'expr nile-env t '$e) 3)))
	(or (holds? (list 'expr nile-env t e) 3) (set bad (cons e bad)))))
    bad))
;; law agree: on expressions that ignore types, the rules and Nile agree at each T
(define-function law-agree (n)
  (let ((bad ()) (both 0) (neither 0))
    (for (i 0 n)
      (let ((e (generate (list 'uexpr nile-env '$e) 2)))
	(list-do t law-types
	  (let ((r (holds? (list 'expr nile-env t e) 3)) (o (nile-accepts? (nile-text e) t)))
	    (cond
	      ((and r o)	(set both (+ both 1)))
	      ((not (or r o))	(set neither (+ neither 1)))
	      (else		(set bad (cons (list (nile-text e) t (if r 'rules-only 'nile-only)) bad))))))))
    (list both neither bad)))
