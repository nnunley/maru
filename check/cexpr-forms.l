;;; cexpr.g parses each source to its Maru form (the RFC's cexpr table).
(require "text-parser.l")
(require "cexpr.g.l")
(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)

(define rows '(("x" x) ("42" 42) ("\"hi\"" "hi")
	       ("a * b / c" (/ (* a b) c)) ("a + b * c" (+ a (* b c))) ("a << 1 + b" (<< a (+ 1 b)))
	       ("a < b == c < d" (= (< a b) (< c d))) ("a & b | c ^ d" (| (& a b) (^ c d)))
	       ("a && b || c" (or (and a b) c)) ("-a + ~b" (+ (- a) (~ b))) ("!a" (not a))
	       ("c ? a : b" (if c a b)) ("f(a, b)" (f a b))
	       ("a<<b" (<< a b)) ("a<=b" (<= a b)) ("a&&b||c" (or (and a b) c)) ("a!=b" (!= a b))
	       ("a /* c */ + b" (+ a b)) ("a - -1" (- a -1))))

(let ((ok 1))
  (list-do row rows
    (let ((form (parse-string <cexpr> $expression (car row))))
      (or (equal form (cadr row)) (let () (set ok ()) (print (car row) " gave ") (dumpln form)))))
  (and ok (println "cexpr forms ok")))
