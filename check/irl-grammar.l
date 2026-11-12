;;; A grammar calls another grammar's rule on the same input (compile-tpeg.l's foreign
;;; calls, [R-tpeg-foreign]), and irl compiles grammar blocks to typed functions whose
;;; actions are maru.k forms passed through ([R-irl-grammar], draft-ndn-maru-sat-00).
;;; Prints "irl grammar ok".
(require "text-parser.l")
(require "spawn.l")
(define ok 1)
(define-function expect (what c)
  (or c
      (let ()
	(set ok ())
	(println "FAIL " what))))
(require "check/temp.l")
(define dir check-tmp)
;; make builds both grammars and the irl library below (make check's CHECK_LIBS)
(make-directory dir)
(load "build/tpeg-foreign-a.g.l")
(load "build/tpeg-foreign-b.g.l")
(define-function try (rule s)
  (let ((p (text-parser-for-on <fb> s))) (and (rule p) (<text-parser>-result p))))
(expect "fb.sum of 12+30 is 42, through fa.num" (= 42 (try $sum "12+30")))
(expect "fb.sum of 12+ fails" (not (try $sum "12+")))
;; grammar blocks in irl, built as a library
(define-function has? (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (<= i n)))
(define shlib (if (darwin?) "dylib" "so"))
(let ((lib ((subr "dlopen" "si>p") (concat-string "build/irl-grammar." shlib) 2)))
  (expect "the grammar library builds and opens" (not (= 0 lib)))
  (or (= 0 lib)
      (let ((add (subr ((subr "dlsym" "ps>p") lib "add") "sl>l"))
	    (count (subr ((subr "dlsym" "ps>p") lib "count") "sl>l"))
	    (hexadd (subr ((subr "dlsym" "ps>p") lib "hexadd") "sl>l")))
	(expect "sums.sum of 12+30+0 is 42" (= 42 (add "12+30+0" 7)))
	(expect "an action counts 3 numbers in a field" (= 3 (count "12+30+0" 7)))
	(expect "12+ is not a sum" (= -1 (add "12+" 3)))
	(expect "the child's inherited sum calls its own num: a+5 is 15" (= 15 (hexadd "a+5" 3))))))
;; a typed grammar neither memoizes nor grows left recursion, and has no lists or strings
(define-function compile-text (name text)
  (let ((f ((subr "fopen" "ss>p") (concat-strings dir "/" name ".irl") "w")))
    ((subr "fputs" "sp>i") text f) ((subr "fclose" "p>i") f))
  (let ((out (concat-strings dir "/" name ".out")))
    (program-status (list "./eval" "compile-irl.l" "--library" (concat-strings dir "/" name ".irl")) () out out))
  (contents-of-file-named (concat-strings dir "/" name ".out")))
(expect "a left-recursive rule is an error naming it"
	(has? (compile-text "irl-grammar-lr"
			    "grammar { <lr> : <text-parser> () e = e \"+\" [0-9] | [0-9] ; }")
	      "lr.e is left-recursive"))
(expect "make-string is an error naming the rule"
	(has? (compile-text "irl-grammar-str" "grammar { <st> : <text-parser> () s = [a-z]+ $ ; }")
	      "st.s: make-string has no typed value"))
;; a grammar block registers in irl's own scope, under the root: reflected on like any grammar, its parent found there, and
;; seen by nothing outside the compilation
(require "irl-grammar.l")
(irl-grammar-forms '(grammar-define <rbase> <text-parser> (a) (num (match-class "0-9") () (token)) (sum (match-rule num) ())))
(irl-grammar-forms '(grammar-define <rchild> <rbase> (b) (num (match-class "0-9a-f") () (token hex))))
(let ((child (grammar-named 'rchild *irl-scope*)))
  (expect "an irl grammar block registers in irl's scope, with its annotations"
	  (and child (equal (<grammar-rule>-annotations (grammar-rule child 'num)) '(token hex))))
  (expect "its parent is the block it names, its rules and fields inherit"
	  (and child (equal (map (lambda (r) (<grammar-rule>-name r)) (grammar-rules-base-first child)) '(sum num))
	       (equal (grammar-all-fields child) '(a b))))
  (expect "and nothing outside irl's scope sees it" (not (grammar-named 'rchild))))
(and ok (println "irl grammar ok"))
