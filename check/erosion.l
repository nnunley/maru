;;; erosion.l's metrics (SlopCodeBench's erosion and verbosity, counted in forms: doc/plans/2026-11-10-erosion-by-reflection.md)
;;; on small sources whose answers are worked out by hand, each read by Maru's own reader from a file in the check's directory.
(require "erosion.l")
(require "recover.l")
(require "check/temp.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define fixtures (concat-strings check-tmp "/erosion-fixtures"))
(make-directory fixtures)
(define fixture-count 0)
(define-function read-text (text)	; the forms Maru's reader makes of text, through a file of its own
  (let ((path (concat-strings fixtures "/f" (long->string (set fixture-count (+ fixture-count 1))) ".l")))
    (contents-to-file-named text path)
    (find-and-read path)))
(define-function source-of-text (path text) (cons path (read-text text)))
(define-function metrics-of (texts) (erosion-of (map (lambda (t) (source-of-text "fixture.l" t)) texts)))
(define-function callables-of (text) (<erosion-metrics>-callables (metrics-of (list text))))
(define-function cc-of (text) (<callable>-cc (car (callables-of text))))
(define-function flagged (text) (map (lambda (f) (<verbose-finding>-rule f)) (<erosion-metrics>-findings (metrics-of (list text)))))
(define-function forms-of (text) (<callable>-forms (car (callables-of text))))

;; complexity: 1, and one for each decision
(expect "a straight line is 1" (cc-of "(define-function f (x) (g x) (h x))") 1)
(expect "an if is 2" (cc-of "(define-function f (x) (if x 1 2))") 2)
(expect "a cond of three clauses and an else is 4" (cc-of "(define-function f (x) (cond (a 1) (b 2) (c 3) (else 4)))") 4)
;; a cond's clauses testing one variable against distinct constants are one lookup, a decision once
(expect "a cond on distinct constants is one decision"
	(cc-of "(define-function f (x) (cond ((= x 1) a) ((= x \"s\") b) ((= x 'k) c) ((= 0 x) d) (else e)))") 2)
(expect "a constant met again, and any other test, is tried in turn"
	(cc-of "(define-function f (x) (cond ((= x 1) a) ((= x 1) b) ((g x) c)))") 4)
(expect "only tests of one variable are its lookup" (cc-of "(define-function f (x y) (cond ((= x 1) a) ((= y 2) b)))") 3)
(expect "(and a b c) is 3" (cc-of "(define-function f () (and a b c))") 3)
(expect "loops and when are decisions" (cc-of "(define-function f (l) (list-do x l (when x (while y (z)))))") 4)
(expect "a nested lambda counts toward its definition" (cc-of "(define-function f () (map (lambda (x) (if x 1 2)) l))") 2)
(expect "quoted data isn't code" (cc-of "(define-function f () '(if a b c))") 1)
(expect "every kind of definition is a callable"
	(map (lambda (c) (<callable>-name c))
	     (callables-of "(define-function a () 1)\n(define-method b <t> () 1)\n(define-form c () 1)\n(define-selector d)\n(define e (lambda () 1))\n(set f (lambda () 1))\n(define g 3)\n(print 4)"))
	'(a b c d e f))
;; forms: lists outside quoted data
(expect "a definition, its parameters and a call are three forms" (forms-of "(define-function f (x) (g x))") 3)
(expect "a quoted datum, its quote included, is no form" (forms-of "(define f (lambda () '(a (b c))))") 2)
(expect "a let's bindings, each binding, and its body's lists are forms" (forms-of "(define-function f () (let ((a (g)) b) (h a)))") 6)
(expect "a template's lists are forms; its backquote and commas aren't" (forms-of "(define-form w (c) `(if ,c (f)))") 4)
(expect "comments and blank lines aren't forms, and a callable is named by its first line"
	(let ((c (car (callables-of "; a comment\n(define-function f (x)\n  ; inside\n\n  (g x))\n"))))
	  (list (<callable>-forms c) (<callable>-line c)))
	'(3 2))

(expect "() is NIL, an atom, not a form" (forms-of "(define-function f () (g () 1))") 2)
(expect "a let with no bindings and two body forms is three forms, not the empty-let pattern"
	(list (forms-of "(define-function f () (let () (g) (h)))") (flagged "(let () (g) (h))")) '(4 ()))
(expect "an if longer than a pattern is no pattern" (flagged "(if c 't () x)") ())

;; erosion: the share of mass, CC x sqrt(forms), in callables of CC over 10
(define-function ifs (n) (let ((s "")) (for (i 0 n) (set s (concat-string s "(if a b) "))) s))
(define-function eroded (text) (<erosion-metrics>-erosion (metrics-of (list text))))
(expect "a callable of CC 10 erodes nothing" (eroded (concat-strings "(define-function f () " (ifs 9) ")")) 0)
(expect "one of CC 11 is all the mass" (eroded (concat-strings "(define-function f () " (ifs 10) ")")) 1000)
(expect "beside one of CC 1 and one form, CC 11 of eleven forms holds 11 sqrt 11 of 11 sqrt 11 + 1"
	(eroded (concat-strings "(define-function f () " (ifs 10) ")\n(define-function g () 1)"))
	(double->long (/ (* 1000.0 (* 11 (sqrt 11.0))) (+ (* 11 (sqrt 11.0)) 1.0))))

;; verbosity: forms a rule flags or a clone covers, over all forms
(expect "each rule flags its example"
	(flagged "(if c 't ())\n(if c () 't)\n(let () x)\n(not (not x))\n(cond (c x) (else y))\n(= x ())")
	'(if-t-nil if-nil-t empty-let not-not one-cond eq-nil))
(expect "and passes the plain form" (flagged "c\n(not c)\nx\n(if c x y)\n(not x)\n(let ((a 1)) a b)") ())
(define clone-a "(define-function f (a b) (let ((s (+ a b))) (if (< s 0) (- 0 s) (* s 2))))")
(define clone-b "(define-function g (x y) (let ((t (+ x y))) (if (< t 0) (- 0 t) (* t 2))))")
(define-function two-file-verbosity (x y)
  (<erosion-metrics>-verbosity (erosion-of (list (source-of-text "a.l" x) (source-of-text "b.l" y)))))
(expect "a subtree of twelve atoms repeated, its variables renamed, is a clone covering its forms: the let, 8 of 10"
	(two-file-verbosity clone-a clone-b) 800)
(define-function clone-verbosity (body)	; body repeated in two definitions whose names differ
  (two-file-verbosity (concat-strings "(define-function f (a) " body ")") (concat-strings "(define-function g (a) " body ")")))
(expect "a repeated subtree of exactly twelve atoms is a clone covering its 4 forms of 6, of eleven isn't"
	(list (clone-verbosity "(h (+ a 1) (+ a 2) (+ a 3) 9 8)") (clone-verbosity "(h (+ a 1) (+ a 2) (+ a 3) 9)")) '(666 0))
(expect "a finding inside a clone is covered once: the clone's 3 forms of 5, not 5"
	(two-file-verbosity "(define-function f (a) (h (not (not a)) 1 2 3 4 5 6 7 8 9 10))"
			    "(define-function g (b) (h (not (not b)) 1 2 3 4 5 6 7 8 9 10))")
	600)
(expect "a finding is the forms it holds: (not (not x)) is 2 of the definition's 4"
	(<erosion-metrics>-verbosity (metrics-of (list "(define-function f (x) (not (not x)))"))) 500)

;; review: clone keys tell numbers, nil and dotted tails apart; rest parameters are bound; quasiquoted code isn't the callable's
(expect "but tell 0.5 from 0.25, 0 from (), and . z from 3 z"
	(list (two-file-verbosity "(h b c d e g i j k l m 0.5)" "(h b c d e g i j k l m 0.25)")
	      (two-file-verbosity "(h b c d e g i j k l m 0)" "(h b c d e g i j k l m ())")
	      (two-file-verbosity "(h b c d e g i j k l m . z)" "(h b c d e g i j k l m 3 z)"))
	'(0 0 0))
(expect "a rest parameter is bound, so clones differing only in its name are found: the call, 1 form of 3"
	(two-file-verbosity "(define-function f (a . rest) (g a rest rest rest rest rest rest rest rest rest rest))"
			    "(define-function g (a . more) (g a more more more more more more more more more more))")
	333)
(expect "a quasiquoted template's decisions belong to the code it makes; an unquoted part's are the callable's"
	(list (cc-of "(define-form w (c . b) `(if ,c (let () ,@b)))") (cc-of "(define-form w (c) `(f ,(if c 1 2)))")) '(1 2))

;; grammars: each rule a callable, read as tpeg reads a .g file (erosion-read-file); a decision is each alternative past the
;; first, each repetition and each predicate, and the decisions in a rule's actions; a form is each node of the rule's tree
(define-function grammar-text (rules) (concat-strings "<g> : <text-parser> ()\n" rules))
(define-function read-grammar (text)	; the forms erosion reads from a .g file holding text
  (let ((path (concat-strings fixtures "/f" (long->string (set fixture-count (+ fixture-count 1))) ".g")))
    (contents-to-file-named text path)
    (erosion-read-file path)))
(define-function grammar-callables (rules) (<erosion-metrics>-callables (erosion-of (list (cons "g.g" (read-grammar (grammar-text rules)))))))
(define-function grammar-cc (rules) (map (lambda (c) (<callable>-cc c)) (grammar-callables rules)))
(define-function grammar-forms (rules) (map (lambda (c) (<callable>-forms c)) (grammar-callables rules)))
(expect "each rule is a callable, named by its rule" (map (lambda (c) (<callable>-name c)) (grammar-callables "a = \"x\" ;\nb = a ;")) '(a b))
(expect "a sequence is 1, two alternatives 2, three 3" (grammar-cc "a = \"x\" \"y\" ;\nb = x | y ;\nc = x | y | z ;") '(1 2 3))
;; a choice's alternatives led by distinct literals (a string, an object, a list pattern's literal head) are one lookup on
;; the next element, a decision if it has two keys or more; every other alternative is tried in turn, a decision each
(expect "distinct literals are one lookup, however many" (grammar-cc "a = \"x\" | \"y\" | \"z\" ;\nb = 'p . | 'q . | 'r ;") '(2 2))
(expect "a list pattern's literal head is its key" (grammar-cc "a = `( 'add . ) | `( 'mul . ) | `( 'neg ) ;") '(2))
(expect "a choice of literals leading an alternative is its keys, and a lookup of its own"
	(grammar-cc "a = ('p | 'q) . | 'r | 's ;") '(3))
(expect "strings are keyed by their first character: \"ab\" and \"ac\" are tried after \"a\""
	(grammar-cc "a = \"a\" | \"ab\" | \"ac\" ;") '(3))
(expect "a literal met again is tried in turn" (grammar-cc "a = \"x\" \"y\" | \"x\" \"z\" ;") '(2))
(expect "a key met again is tried in turn, beside a lookup of two" (grammar-cc "a = 'x b | 'x c | 'y ;") '(3))
(expect "a lookup and an alternative after it" (grammar-cc "a = \"x\" | \"y\" | b ;\nc = \"x\" | b ;") '(3 2))
(expect "each repetition is a decision" (grammar-cc "a = \"x\"* \"y\"? \"z\"+ ;") '(4))
(expect "a predicate is a decision, and its action's decisions are the rule's"
	(grammar-cc "a = !\"x\" . ;\nb = .:n &-> (cond (n 1) (else 2)) ;\nc = .:n -> (if n 1 2) ;") '(2 3 2))
(expect "the rule, its sequence and its matches are forms; an empty parameter list isn't"
	(grammar-forms "a = \"x\" \"y\" ;") '(4))
(expect "a binding, an action and the action's lists are forms" (grammar-forms "a = \"x\":v -> (list v) ;") '(6))
(expect "a rule's parameters are a form" (grammar-forms "a :p = \"x\" ;") '(3))
(expect "an object literal is data, no form inside it" (grammar-forms "a = '(1 2) ;") '(2))
(expect "a call's arguments are Maru forms" (grammar-forms "a = {b (f 1)} ;") '(3))

;; a script tpeg-repl.l reads (#!./eval tpeg-repl.l) is read by it: its Maru forms and its blocks, not the input a block takes
(define-function read-script (text)
  (let ((path (concat-strings fixtures "/f" (long->string (set fixture-count (+ fixture-count 1))) ".l")))
    (contents-to-file-named text path)
    (erosion-read-file path)))
(expect "a script's forms are its code and its blocks; a block's input isn't read"
	(map car (read-script "#!./eval tpeg-repl.l\n(define-function f (x) x)\n{\n  <s> : <text-parser> ()\n  w = [a-z]+ ;\n}\n{ ([ \\n]* w)* [ \\n]* \".\" }\nnot a form here .\n(f 1)\n"))
	'(define-function grammar-define grammar-eval f))
(expect "a span after the script's own output without a newline is still read"
	(map car (read-script "#!./eval tpeg-repl.l\n(print \"no newline\")\n(define-function g () 1)\n")) '(print define-function))
(expect "a script that fails while it runs isn't measured in part: erosion stops, saying so"
	(try (let () (read-script "#!./eval tpeg-repl.l\n(define-function g () 1)\n(error \"broken\")\n(define-function h () 2)\n") 'read)
	     (lambda (c) 'refused))
	'refused)
(expect "its rules and functions are callables"
	(map (lambda (c) (<callable>-name c))
	     (<erosion-metrics>-callables (erosion-of (list (cons "s.l" (read-script "#!./eval tpeg-repl.l\n(define-function f (x) x)\n{\n  <s2> : <text-parser> ()\n  w = [a-z]+ ;\n}\n"))))))
	'(w f))

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
