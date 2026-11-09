;;; A grammar keeps its definition: its rules (their names, parameters, bodies as tpeg parsed them, and annotations), its
;;; parent and fields, its own and inherited, whether loaded in process or compiled to a file first.
(require "source-parser.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(tpeg-load "check/grammar-reflect.g")
(tpeg-load "check/grammar-reflect-child.g")
(define base (grammar-of <reflect-base>))
(define child (grammar-of <reflect-child>))
(define-function names (rules) (map (lambda (r) (<grammar-rule>-name r)) rules))
(expect "a grammar's own rules, in order" (names (<grammar>-rules base)) '(digit pick pair))
(expect "its name, parent, and the fields each adds" (list (<grammar>-name base) (<grammar>-name (grammar-parent child)) (<grammar>-fields base) (<grammar>-fields child))
	'(<reflect-base> <reflect-base> (a) (b)))
(expect "a rule's annotations, in the order written" (<grammar-rule>-annotations (grammar-rule base 'pick)) '(decision left-recursive))
(expect "a rule with none" (<grammar-rule>-annotations (grammar-rule base 'pair)) ())
(expect "a rule's parameters" (<grammar-rule>-parameters (grammar-rule base 'pair)) '(x))
(expect "a rule's body is the tree tpeg parsed" (car (<grammar-rule>-body (grammar-rule base 'pick))) 'match-first)
(expect "rules, inherited ones too, nearest first, an override once" (names (grammar-rules child)) '(pick extra digit pair))
(expect "a rule by name is the nearest" (list (<grammar-rule>-annotations (grammar-rule child 'pick)) (<grammar-rule>-name (grammar-rule child 'digit)))
	'((decision) digit))
(expect "a type that isn't a grammar has none" (grammar-of <pair>) ())
(tpeg-define-rules '<reflect-base> '((pair (match-any) (y) (redefined))))
(expect "defining a rule again replaces it, in its place, and a child sees the new one"
	(list (<grammar-rule>-parameters (grammar-rule base 'pair)) (names (<grammar>-rules base)) (<grammar-rule>-annotations (grammar-rule child 'pair)))
	'((y) (digit pick pair) (redefined)))
(tpeg-load "check/grammar-reflect-tree.g")
(expect "a parameterised rule's body is as tpeg parsed it, not as compiling rewrites it"
	(<grammar-rule>-body (grammar-rule (grammar-of <reflect-tree>) 'take)) '(match-all (assign-result x (match-any)) (result-expr (list n x))))
(define-class <reflect-between> <reflect-child> ())	; a class that isn't a grammar, between two that are
(define-class <reflect-under> <reflect-between> ())
(grammar-register '<reflect-under> <reflect-under> '((more (match-any) ())))
(expect "a grammar under a class that isn't one inherits from the grammar above it"
	(names (grammar-rules (grammar-of <reflect-under>))) '(more pick extra digit pair))
(load "cexpr.g.l")	; compiled to a file by make, then loaded: it registers itself as it loads
(expect "a grammar compiled to a file reflects too" (<grammar-rule>-name (grammar-rule (grammar-of <cexpr>) 'primary)) 'primary)
(println (if ok "grammar reflect ok" "grammar reflect FAILED"))
