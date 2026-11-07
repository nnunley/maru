;;; law-compile.l -- reads a law file into item forms, and fills templates.
;;;
;;;   (law-file-read path)        items for rules-expand and the law runner
;;;   (law-file-numbers items)    the distinct numbers the file mentions
;;;   (template-fill lang text bindings)   {name} replaced by its binding's text
;;;   (template-render v)                  a template term as text, holes filled recursively; else v
;;;   (template-parse lang text)           the filled text, parsed by lang's grammar
;;;   (grammar-language lang class paths sentinel)  registers a grammar for domains lang.rule

(require "text-parser.l")

(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)

;; a comment's -- starts a line (after blanks), or follows a blank with a blank or the line's end after it
(define-function law-dash? (p)
  (let* ((s (<text-parser>-string p)) (i (<text-parser>-position p)) (j i) (n (string-length s)))
    (while (and (< 0 j) (member? (string-at s (- j 1)) '(9 32))) (set j (- j 1)))
    (or (= j 0) (member? (string-at s (- j 1)) '(10 13))
	(and (< j i) (or (<= n (+ i 2)) (member? (string-at s (+ i 2)) '(9 10 13 32)))))))

(require "cexpr.g.l")
(require "law.g.l")

;;; ---- items.  In a rule, a lower-case name is a logic variable, written $name;
;;; a Capitalised name, a string and a number are constants.  Elsewhere (let,
;;; set, a claim, a condition) names are plain.

(define *law-lets* ())		; (name . value) for each let so far
(define-function law-lower? (x)
  (let ((c (string-at (symbol->string x) 0))) (and (<= ?a c) (<= c ?z))))
(define-function law-var (x) (string->symbol (concat-string "$" (symbol->string x))))
(define law-conv)
(define template-holes)
;; a list's elements with each range A .. B (constant whole numbers) put in place as the numbers A to B
(define-function law-range? (x) (and (pair? x) (= 'law-range (car x))))
(define-function law-ranges (elems)
  (cond ((not elems) ())
	((law-range? (car elems))
	 (let ((a (cadr (car elems))) (b (caddr (car elems))) (out ()))
	   (or (and (long? a) (long? b)) (error "E_RANGE: a range's ends are whole numbers, not " a " and " b))
	   (while (<= a b) (push out a) (set a (+ a 1)))
	   (concat-list (list-reverse! out) (law-ranges (cdr elems)))))
	(else (cons (car elems) (law-ranges (cdr elems))))))
;; in a rule a template is a term, (template lang text ((hole . $hole)...)), so it unifies
(define-function law-template-term (x)
  (list 'template (cadr x) (caddr x) (map (lambda (n) (cons n (law-conv n 1))) (template-holes (caddr x)))))
(define-function law-list-from (elems tail var)
  (if elems (cons (law-conv (car elems) var) (law-list-from (cdr elems) tail var)) (and tail (law-conv (car tail) var))))
;; a list literal in a claim or condition is a form that builds the list: its elements are claim values, its tail a list
(define-function law-list-form (elems tail)
  (if elems (list 'cons (law-conv (car elems) 'claim) (law-list-form (cdr elems) tail))
    (if tail (law-conv (car tail) 'claim) (list 'quote ()))))
(define-function law-conv (x var)	; var: lower-case names become variables
  (cond
    ((symbol? x)		(let ((l (assq x *law-lets*)))
				  (cond (l		(if (and (pair? (cdr l)) (= var 'claim)) (list 'quote (cdr l)) (cdr l)))
					((and (= var 1) (law-lower? x))	(law-var x))
					(else		x))))
    ((not (pair? x))		x)
    ((= 'law-pair (car x))	(cons (law-conv (cadr x) var) (law-conv (caddr x) var)))
    ((and (= var 1) (= 'law-field (car x)))	(error "E_FIELD: " (caddr x) " is read in a rule or domain; a field is read in a claim or condition"))
    ((= 'law-list (car x))	(let ((elems (law-ranges (cadr x))))
				  (if (= var 'claim) (law-list-form elems (cddr x)) (law-list-from elems (cddr x) var))))
    ((= 'template (car x))	(if (= var 1) (law-template-term x) x))
    (else			(cons (car x) (map (lambda (a) (law-conv a var)) (cdr x))))))
(define-function law-goal (g scope)	; a goal's relation is a variable only if a parameter or schema variable
  (cons (if (member? (car g) scope) (law-var (car g)) (car g)) (map (lambda (a) (law-conv a 1)) (cdr g))))

(define-function law-domain (d)
  (cond ((symbol? d)		(law-conv d ()))
	((= 'law-grammar (car d))	(cons 'grammar (cdr d)))
	(else			(law-goal d ()))))
(define-function law-bindings (raw)	; (law-bind (names) domain) -> (name domain)...; (law-let n v) -> (name (let . form))
  (let ((out ()))
    (list-do b raw
      (if (= 'law-let (car b))
	  (set out (concat-list out (list (list (law-var (cadr b)) (cons 'let (law-conv (caddr b) 'claim))))))
	(list-do n (cadr b)
	  (set out (concat-list out (list (list (law-var n) (law-domain (caddr b)))))))))
    out))
(define-function law-conditions (raw)
  (let ((out ()))
    (list-do b raw (or (cadr b) (set out (concat-list out (list (law-conv (caddr b) 'claim))))))
    out))
(define-function select-binds (raw)
  (let ((out ())) (list-do b raw (and (cadr b) (set out (concat-list out (list b))))) out))

(define-function law-conv-law (it)	; (law n raw claim method size)
  (let ((raw (caddr it)))
    (list 'law (cadr it) (law-bindings (select-binds raw)) (law-conditions raw)
	  (law-conv (cadddr it) 'claim) (car (cddddr it)) (cadr (cddddr it)))))
(define-function law-item (it scope)
  (let ((k (car it)))
    (cond
      ((= k 'let)	(let ((v (law-conv (caddr it) ()))) (set *law-lets* (cons (cons (cadr it) v) *law-lets*)) (list 'let (cadr it) v)))
      ((= k 'rule)	(cons 'rule (cons (cadr it) (cons (map law-var (caddr it))
			    (map (lambda (g) (law-goal g (concat-list scope (caddr it)))) (cdddr it))))))
      ((= k 'fact)	(list 'fact (law-goal (cadr it) ())))
      ((= k 'schema)	(list 'schema (law-var (cadr it)) (map (lambda (a) (law-conv a ())) (caddr it))
			      (law-item (cadddr it) (cons (cadr it) scope))))
      ((= k 'law)	(law-conv-law it))
      (else		it))))

(define-function law-text-read (text)
  (let ((parser (text-parser-for-on <law> text)))
    (or ($program parser) (error "syntax error"))
    (set *law-lets* ())
    (let ((out ())) (list-do it (<law>-result parser) (set out (concat-list out (list (law-item it ()))))) out)))

;;; The items rules-expand takes: rules, facts, schemas and facts-from-function.
(define-function law-rules (items)
  (let ((out ()))
    (list-do it items (and (member? (car it) '(rule fact schema facts)) (set out (concat-list out (list it)))))
    out))
(define-function law-file-read (path) (law-text-read (contents-of-file-named path)))

;;; The numbers a file mentions in its rules, facts, lets and laws, not its
;;; defaults or a law's size.
(define-function law-numbers-in (x acc)
  (cond ((or (long? x) (double? x))	(if (member? x acc) acc (concat-list acc (list x))))
	((pair? x)			(law-numbers-in (cdr x) (law-numbers-in (car x) acc)))
	(else				acc)))
(define-function law-file-numbers (items)
  (let ((acc ()))
    (list-do it items
      (cond ((member? (car it) '(defaults adequacy)))
	    ((= 'law (car it))	(set acc (law-numbers-in (list (caddr it) (cadddr it) (car (cddddr it))) acc)))
	    (else		(set acc (law-numbers-in it acc)))))
    acc))

;;; ---- templates.  lang`text`: {name} is a hole, {{ and }} are braces.

(define *template-languages* ())	; (lang class rule)
(define-function template-language (lang class rule)
  (set *template-languages* (cons (list lang class rule) *template-languages*))
  lang)

(define-function template-name (lang text)
  (concat-strings (symbol->string lang) "`" text "`"))
(define template-fill)
(define-function template-term? (v) (and (pair? v) (= 'template (car v)) (pair? (cdddr v))))
(define-function template-text (v)
  (cond ((string? v)	v)
	((symbol? v)	(symbol->string v))
	((long? v)	(long->string v))
	((double? v)	(double->string v))
	((template-term? v)	(template-fill (cadr v) (caddr v) (cadddr v)))
	(else		(error "E_TEMPLATE_PARSE: a hole's value is not text: " v))))
(define-function template-render (v) (if (template-term? v) (template-text v) v))
(define-function template-value (lang text name bindings)
  (let* ((s (string->symbol name)) (b (or (assq s bindings) (assq (law-var s) bindings))))
    (or b (error "E_TEMPLATE_PARSE: no value for {" name "} in " (template-name lang text)))
    (template-text (cdr b))))
(define-function template-close (lang text i)	; index of the } that ends the hole at i
  (let ((j (+ i 1)) (n (string-length text)))
    (while (and (< j n) (!= 125 (string-at text j))) (set j (+ j 1)))
    (or (< j n) (error "E_TEMPLATE_PARSE: unclosed { in " (template-name lang text)))
    j))
(define-function template-holes (text)	; each hole's name, once, in order
  (let ((out ()) (i 0) (n (string-length text)))
    (while (< i n)
      (let ((c (string-at text i)))
	(if (and (< (+ i 1) n) (or (= c 123) (= c 125)) (= c (string-at text (+ i 1)))) (set i (+ i 2))
	  (if (!= c 123) (set i (+ i 1))
	    (let* ((j (template-close 'template text i)) (h (string->symbol (string-copy text (+ i 1) (- (- j i) 1)))))
	      (or (member? h out) (set out (concat-list out (list h))))
	      (set i (+ j 1)))))))
    out))
(define-function template-fill (lang text bindings)
  (let ((out (array)) (i 0) (n (string-length text)))
    (while (< i n)
      (let ((c (string-at text i)) (d (and (< (+ i 1) n) (string-at text (+ i 1)))))
	(if (and (= c d) (or (= c 123) (= c 125)))
	    (let () (array-append out c) (set i (+ i 2)))
	  (if (= c 123)
	      (let* ((j (template-close lang text i)) (v (template-value lang text (string-copy text (+ i 1) (- (- j i) 1)) bindings)))
		(for (k 0 (string-length v)) (array-append out (string-at v k)))
		(set i (+ j 1)))
	    (if (= c 125)
		(error "E_TEMPLATE_PARSE: lone } in " (template-name lang text))
	      (let () (array-append out c) (set i (+ i 1))))))))
    (array->string out)))

(define-function template-parse (lang text)
  (let ((entry (assq lang *template-languages*)))
    (or entry (error "E_TEMPLATE_PARSE: no template language " lang))
    (let* ((p (text-parser-for-on (cadr entry) text))
	   (rule (eval (string->symbol (concat-string "$" (symbol->string (caddr entry)))))))
      ($_ p)
      (or (and (text-parser-invoke-rule (<selector>-name rule) rule p)
	       (= (<text-parser>-position p) (<text-parser>-limit p)))
	  (error "E_TEMPLATE_PARSE: " (symbol->string lang) " cannot parse: " text))
      (<text-parser>-result p))))

;;; Grammar languages, for domains like cexpr.primary: (lang class paths sentinel),
;;; the sentinel being text the language never absorbs after a sentence
(define *grammar-languages* ())
(define-function grammar-language (lang class paths sentinel)
  (set *grammar-languages* (cons (list lang class paths sentinel) *grammar-languages*))
  lang)

(template-language 'cexpr <cexpr> 'expression)
(grammar-language 'cexpr <cexpr> '("cexpr.g") ")")
