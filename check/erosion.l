;;; erosion.l's metrics (SlopCodeBench's erosion and verbosity, docs/plans/2026-11-08-erosion-metrics.md) on small sources
;;; whose answers are worked out by hand.  (erosion-run.l holds maru-lines.g to Maru's own reader on every file it measures.)
(require "erosion.l")
(require "recover.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function callables-of (text) (erosion-callables (maru-lines-read text "fixture.l") (erosion-code-lines text)))
(define-function cc-of (text) (<callable>-cc (car (callables-of text))))

;; complexity: 1, and one for each decision
(expect "a straight line is 1" (cc-of "(define-function f (x) (g x) (h x))") 1)
(expect "an if is 2" (cc-of "(define-function f (x) (if x 1 2))") 2)
(expect "a cond of three clauses and an else is 4" (cc-of "(define-function f (x) (cond (a 1) (b 2) (c 3) (else 4)))") 4)
(expect "(and a b c) is 3" (cc-of "(define-function f () (and a b c))") 3)
(expect "loops and when are decisions" (cc-of "(define-function f (l) (list-do x l (when x (while y (z)))))") 4)
(expect "a nested lambda counts toward its definition" (cc-of "(define-function f () (map (lambda (x) (if x 1 2)) l))") 2)
(expect "quoted data isn't code" (cc-of "(define-function f () '(if a b c))") 1)
(expect "every kind of definition is a callable"
	(map (lambda (c) (<callable>-name c))
	     (callables-of "(define-function a () 1)\n(define-method b <t> () 1)\n(define-form c () 1)\n(define-selector d)\n(define e (lambda () 1))\n(set f (lambda () 1))\n(define g 3)\n(print 4)"))
	'(a b c d e f))
(let ((c (car (callables-of "; a comment\n(define-function f (x)\n  ; inside\n\n  (g x))\n"))))
  (expect "a callable's source lines leave out blanks and comments" (list (<callable>-sloc c) (<callable>-first c)) '(2 2)))

;; erosion: the share of mass, CC x sqrt(SLOC), in callables of CC over 10
(define-function ifs (n) (let ((s "")) (for (i 0 n) (set s (concat-string s "(if a b) "))) s))
(define-function eroded (text) (<erosion-metrics>-erosion (erosion-of (list (cons "fixture.l" text)))))
(expect "a callable of CC 10 erodes nothing" (eroded (concat-strings "(define-function f () " (ifs 9) ")")) 0)
(expect "one of CC 11 is all the mass" (eroded (concat-strings "(define-function f () " (ifs 10) ")")) 1000)
(expect "beside one of CC 1 on one line, CC 11 on one line holds 11 of 12"
	(eroded (concat-strings "(define-function f () " (ifs 10) ")\n(define-function g () 1)")) (/ (* 1000 11) 12))

;; verbosity: lines a rule flags or a clone covers, over source lines
(define-function flagged (text) (map (lambda (f) (<verbose-finding>-rule f)) (erosion-findings (maru-lines-read text "fixture.l"))))
(expect "each rule flags its example"
	(flagged "(if c 't ())\n(if c () 't)\n(let () x)\n(not (not x))\n(cond (c x) (else y))\n(= x ())")
	'(if-t-nil if-nil-t empty-let not-not one-cond eq-nil))
(expect "and passes the plain form" (flagged "c\n(not c)\nx\n(if c x y)\n(not x)\n(let ((a 1)) a b)") ())
(define clone-a "(define-function f (a b) (let ((s (+ a b))) (if (< s 0) (- 0 s) (* s 2))))")
(define clone-b "(define-function g (x y) (let ((t (+ x y))) (if (< t 0) (- 0 t) (* t 2))))")
(expect "a subtree of twelve atoms repeated, its variables renamed, is a clone on every line it occupies"
	(<erosion-metrics>-verbosity (erosion-of (list (cons "a.l" clone-a) (cons "b.l" clone-b)))) 1000)
(define-function clone-verbosity (body)	; body repeated in two definitions whose names differ
  (<erosion-metrics>-verbosity (erosion-of (list (cons "a.l" (concat-strings "(define-function f (a) " body ")"))
					       (cons "b.l" (concat-strings "(define-function g (a) " body ")"))))))
(expect "a repeated subtree of exactly twelve atoms is a clone, of eleven isn't"
	(list (clone-verbosity "(h (+ a 1) (+ a 2) (+ a 3) 9 8)") (clone-verbosity "(h (+ a 1) (+ a 2) (+ a 3) 9)")) '(1000 0))

;; review: clone keys tell numbers, nil and dotted tails apart; rest parameters are bound; quasiquoted code isn't the callable's
(define-function two-file-verbosity (x y)
  (<erosion-metrics>-verbosity (erosion-of (list (cons "a.l" x) (cons "b.l" y)))))
(expect "but tell 0.5 from 0.25, 0 from (), and . z from 3 z"
	(list (two-file-verbosity "(h b c d e g i j k l m 0.5)" "(h b c d e g i j k l m 0.25)")
	      (two-file-verbosity "(h b c d e g i j k l m 0)" "(h b c d e g i j k l m ())")
	      (two-file-verbosity "(h b c d e g i j k l m . z)" "(h b c d e g i j k l m 3 z)"))
	'(0 0 0))
(expect "a rest parameter is bound, so clones differing only in its name are found"
	(two-file-verbosity "(define-function f (a . rest) (g a rest rest rest rest rest rest rest rest rest rest))"
			    "(define-function g (a . more) (g a more more more more more more more more more more))")
	1000)
(expect "a quasiquoted template's decisions belong to the code it makes; an unquoted part's are the callable's"
	(list (cc-of "(define-form w (c . b) `(if ,c (let () ,@b)))") (cc-of "(define-form w (c) `(f ,(if c 1 2)))")) '(1 2))

;; the ratchet: a metric that moved without an entry doesn't match its ledger, and does with one
(define m (make <erosion-metrics> erosion: 400 verbosity: 75))
(expect "the ratchet holds each metric to its ledger"
	(list (erosion-matches? m (erosion-ledger "erosion 400 a\nverbosity 75 b\n"))
	      (erosion-matches? m (erosion-ledger "erosion 401 a\nverbosity 75 b\n"))
	      (erosion-matches? m (erosion-ledger "erosion 401 a\nverbosity 75 b\nerosion -1 split\n"))
	      (erosion-matches? m (erosion-ledger "erosion 75 a\nverbosity 400 b\n")))
	'(t () t ()))
(expect "an entry may say +N" (erosion-ledger "erosion +3 why\nverbosity -2 why\n") '(3 . -2))

;; the ledger: each metric is the sum of its entries, and an entry says why
(expect "the ledger sums each metric's entries" (erosion-ledger "erosion 400 first measured\nverbosity 75 first measured\nerosion -3 split ks-eval\n") '(397 . 75))
(expect "an entry with no reason is refused" (try (erosion-ledger "erosion 4\n") (lambda (c) 'refused)) 'refused)
(expect "an entry naming neither is refused" (try (erosion-ledger "lines 4 why\n") (lambda (c) 'refused)) 'refused)

(println (if ok "erosion ok" "erosion FAILED"))
