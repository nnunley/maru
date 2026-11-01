;;; Checks for law.g and law-compile.l (law_cexpr in check.l).  Run with no
;;; argument it runs the checks; "file F", "hole" and "parse" are the child
;;; processes whose error messages it inspects, since Maru has no catch, and
;;; "primary S..." prints whether each S is a sentence of cexpr.primary.
(require "rules.l")
(require "law-compile.l")
(require "grammar-gen.l")

(define system (subr "system" "s"))
(define ok 1)
(define-function expect (what c) (or c (and (println "FAIL " what) (set ok ()))))
(define-function has? (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (<= i n)))
(define-function child (name args)
  (system "mkdir -p /tmp/maru-check")
  (let ((out (concat-strings "/tmp/maru-check/law-" name ".out")))
    (system (concat-strings "./eval check/law-compile-test.l " args " >" out " 2>&1"))
    (contents-of-file-named out)))

(define-function suite ()
  (expect "the RFC's example reads to items"
    (equal (law-file-read "check/laws/fixtures/syntax.law")
	   '((set Type (Number Boolean))
	     (let abpq ((a . Number) (b . Number) (p . Boolean) (q . Boolean)))
	     (reference nile_accepts e t)
	     (under-test expr)
	     (facts (infix prefix) nile_signatures)
	     (rule e_var () (expr $env $t $v) (in $v $t $env))
	     (rule e_num () (expr $env Number $n) (number $n))
	     (rule e_prefix () (expr $env $t (template nile "{op}({a})" ((op . $op) (a . $a)))) (prefix $op $at $t) (expr $env $at $a))
	     (rule e_infix () (expr $env $t (template nile "({a} {op} {b})" ((a . $a) (op . $op) (b . $b)))) (infix $op $at $bt $t) (expr $env $at $a) (expr $env $bt $b))
	     (law sound (($t Type) ($e (expr ((a . Number) (b . Number) (p . Boolean) (q . Boolean)) $t $e))) () (= (nile_accepts e t) accept) () ()))))
  (let ((items (law-file-read "check/laws/fixtures/more.law")))
    (expect "defaults, lists, schemas, parameters, grammar domains, conditions"
      (equal items
	     '((defaults (trials . 50) (seed . 7))
	       (fact (color Red))
	       (rule paint () (painted $c) (color $c))
	       (rule cons () (painted_list ($h . $t)) (painted $h) (painted_list $t))
	       (rule nil () (painted_list ()))
	       (schema $r (color painted) (rule both_r () (both $r $x) ($r $x)))
	       (rule lst ($r) (all_r $r $x) ($r $x))
	       (law small (($n number) ($g (grammar cexpr primary))) ((> n 2) (< n 40)) (= (f n g) 3) exhaustion 4)
	       (law plain (($a Type) ($b Type)) () (= (+ a b) (+ b a)) () ()))))
    (expect "numbers the file mentions, in order, once"
      (equal (law-file-numbers items) '(2 40 3))))
  (let ((rs (rules-expand (law-text-read "fact color(Red)\nrule paint: color(c) => painted(c)\n"))))
    (expect "read rules expand and run" (rules-holds? rs '(painted Red) 1)))

  (define-function nile_signatures () '((infix "+" Number Number Number) (prefix "-" Number Number)))
  (expect "the example's rules expand to first-order rules"
    (equal (rules-expand (law-rules (law-file-read "check/laws/fixtures/syntax.law")))
	   '((infix (infix "+" Number Number Number))
	     (prefix (prefix "-" Number Number))
	     (e_var (expr $env $t $v) (in $v $t $env))
	     (e_num (expr $env Number $n) (number $n))
	     (e_prefix (expr $env $t (template nile "{op}({a})" ((op . $op) (a . $a)))) (prefix $op $at $t) (expr $env $at $a))
	     (e_infix (expr $env $t (template nile "({a} {op} {b})" ((a . $a) (op . $op) (b . $b)))) (infix $op $at $bt $t) (expr $env $at $a) (expr $env $bt $b)))))
  (let ((msg ()))
    (set *rules-reject* (lambda (m) (set msg m)))
    (rules-expand '((let x 1) (law l)))
    (set *rules-reject* error)
    (expect "a non-rule item is rejected by name" (and msg (has? msg "E_UNKNOWN_ITEM"))))
  (expect "let names resolve where used"
    (equal (law-text-read "let k = [a: N]\nrule r: p(k) => q(k)\nlaw l: all x: T. f(k, x)\n")
	   '((let k ((a . N))) (rule r () (q ((a . N))) (p ((a . N)))) (law l (($x T)) () (f (quote ((a . N))) x) () ()))))
  (expect "-- comments sit between items, and after a claim"
    (equal (law-text-read "-- one\nset T = A | B -- two\nlaw l: all x: T. x == 1 -- three\n-- four\n--five\n")
	   '((set T (A B)) (law l (($x T)) () (= x 1) () ()))))
  (expect "a - -1 is not a comment" (equal (law-text-read "law l: all x: T. a - -1 == 0\n") '((law l (($x T)) () (= (- a -1) 0) () ()))))
  (expect "a filler is inserted as written"
    (equal (template-parse 'cexpr (template-fill 'cexpr "{x} * c" '((x . "a + b")))) '(+ a (* b c))))
  (expect "a parenthesised filler groups"
    (equal (template-parse 'cexpr (template-fill 'cexpr "({x}) * c" '(($x . "a + b")))) '(* (+ a b) c)))
  (expect "doubled braces are literal" (equal (template-fill 'cexpr "{{ x }}" ()) "{ x }"))
  (expect "a hole fills with a number or symbol"
    (equal (template-fill 'cexpr "{n}{s}" '((n . 42) (s . y))) "42y"))

  (let ((out (child "line3" "file check/laws/fixtures/error-line3.law")))
    (expect "a malformed file fails with its line" (has? out "line 3")))
  (let ((out (child "dash" "file check/laws/fixtures/error-dash.law")))
    (expect "-- inside an expression is no comment" (has? out "line 2")))
  (let ((out (child "comment" "file check/laws/fixtures/error-comment.law")))
    (expect "--1 after a claim is no comment" (has? out "line 2")))
  (let ((out (child "hole" "hole")))
    (expect "an unbound hole is E_TEMPLATE_PARSE naming the template"
      (and (has? out "E_TEMPLATE_PARSE") (has? out "cexpr`{x} * c`"))))
  (let ((out (child "parse" "parse")))
    (expect "unparseable filled text is E_TEMPLATE_PARSE" (has? out "E_TEMPLATE_PARSE")))
  (and ok (println "law compile ok")))

(define-function driver (mode)
  (cond
    ((= mode "file")	(law-file-read (next-argument)))
    ((= mode "hole")	(template-fill 'cexpr "{x} * c" ()))
    ((= mode "parse")	(template-parse 'cexpr "a +"))
    ((= mode "primary")	(let ((d (grammar-domain <cexpr> '("cexpr.g") ")")) (vs *arguments*))
			  (set *arguments* ())
			  (list-do v vs (println (if (grammar-accepts? d 'primary v) "yes" "no")))))))
(if *arguments* (driver (next-argument)) (suite))
