;;; nile-reference.l -- Nile's own parser, resolver and type checker, loaded from
;;; nile/compilers/maru/ into this tree's eval, as references for check/laws/nile.law.
;;;   (nile-accepts text type)  accept when Nile resolves and type-checks, after its prelude,
;;;                               \f(a:Number, b:Number, p:Boolean, q:Boolean) : TYPE
;;;                                   TEXT
;;;                             reject when Nile reports an error or that doesn't parse, else (crash status)
;;;   (nile-defines text)       the same for top-level definitions
;;;   (nile-signatures)         infix and prefix facts for the prelude's Number and Boolean operations
;;; Nile's checker exits on its first error, so each question runs in a forked child under
;;; an alarm (law-child and _exit are check/law.l's): nile-fatal-error and
;;; nile-op-lookup-error exit 3, a parse failure 4.  Nile's grammar is compiled in process,
;;; as nile-compiler.l does.  For claims: checks, unfired, text, unparse and non_ascii (below).
(require "print-structure.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")

;; what nile-compiler.l defines before loading the rest (it runs the compiler when loaded)
(define-method ++ <undefined> (b) b)
(define-method ++ <string>    (b) (concat-string self b))
(define-method ++ <pair>      (b) (concat-list   self b))
(define-function replicate (n x) (if (< n 1) '() (cons x (replicate (- n 1) x))))
(define-function all? (l) (if l (foldr and 't l)))
(define-function is-a? (obj type) (= (type-of obj) type))
(define-function flatten (l) (if (pair? l) (concat-list (flatten (car l)) (flatten (cdr l))) (if l (list l) l)))
(define-function filter (predicate l)
  (if (pair? l) (if (predicate (car l)) (cons (car l) (filter predicate (cdr l))) (filter predicate (cdr l)))))
(define-form nile-fatal-error message '(_exit 3))
(define nile-op-lookup-error (lambda args (_exit 3)))
(define-function nile-load (f) (load (concat-string "nile/compilers/maru/" f)))
(nile-load "nile-ast-nodes.l")
(nile-load "nile-resolve.l")
(nile-load "nile-type-check.l")
(map eval (parse-and-compile-grammar "nile/compilers/maru/nile-grammar.g"))
(template-language 'nile <nile-parser> 'expr)

(define nile-prelude
  (let ((p println))		; its grammar prints "Parsing NAME..." for each process
    (set println (lambda args 1))
    (let ((defs (parse-string <nile-parser> $start (contents-of-file-named "nile/compilers/prelude.nl")))) (set println p) defs)))

;; the facts: every prefix or infix operation on Numbers and Booleans; outfix and juxtaposition left out
(define-function nile-type-name (pattern) (string->symbol (<nile-typeref>-name (<nile-vardecl>-type pattern))))
(define-function nile-signature (sig)
  (let ((n (<nile-opsig>-name sig)) (f (<nile-opsig>-fixity sig)) (t (string->symbol (<nile-typeref>-name (<nile-opsig>-type sig)))))
    (cond ((not (string? n)) ())
	  ((= f 'pre)	(list (list 'prefix n (nile-type-name (<nile-opsig>-param sig)) t)))
	  ((= f 'in)	(let ((ps (<nile-tuplepat>-elements (<nile-opsig>-param sig))))
			  (list (list 'infix n (nile-type-name (car ps)) (nile-type-name (cadr ps)) t))))
	  (else		()))))
(define-function nile-signatures ()
  (let ((out ()))
    (list-do d nile-prelude (and (is-a? d <nile-opdef>) (set out (concat-list out (nile-signature (<nile-opdef>-sig d))))))
    out))

;; the prelude, resolved and type-checked once, quietly (resolving prints each operation); a question resolves only its own text
(define nile-prelude-env
  (let ((p print) (q println) (env (nile-resolve-env '())))
    (set print (lambda args 1)) (set println (lambda args 1))
    (map-with type-check (map-with resolve nile-prelude env) '())
    (set print p) (set println q)
    env))

;; one question, in a child: its exit status as a verdict.  An expression is parsed alone, as the body of
;; \f(a:Number, b:Number, p:Boolean, q:Boolean) : TYPE, whose signature is parsed once per type
(define alarm (subr "alarm" "i>i"))
(define-function nile-parse (rule src)	; in a child, the parser after rule matched src, or exit 4
  (define-method $error <nile-parser> () (_exit 4))	; the grammar's error rule would call error
  (define-method $$error <nile-parser> () (_exit 4))
  (let ((p (text-parser-for-on <nile-parser> src)))
    (set (<nile-parser>-indentation p) 0)
    (or (text-parser-invoke-rule 'start rule p) (_exit 4))
    p))
(define-function nile-check (defs)
  (map-with type-check (map-with resolve defs nile-prelude-env) '())
  (_exit 0))
(define-function nile-verdict (ask)	; ask: run in the child, exiting with its verdict; (crash -1) if no child ran
  (let ((st (law-child (lambda () (alarm 10) (ask)))))
    (cond ((= 0 st) accept) ((or (= st (<< 3 8)) (= st (<< 4 8))) reject) (else (list 'crash st)))))
(define nile-sigs ())
(define-function nile-sig (type)
  (or (cdr (assq type nile-sigs))
      (let ((p (text-parser-for-on <nile-parser> (concat-strings "\\f(a:Number, b:Number, p:Boolean, q:Boolean) : " (symbol->string type) "\n    a\n"))))
	(set (<nile-parser>-indentation p) 0)
	(text-parser-invoke-rule 'start $start p)
	(cdar (push nile-sigs (cons type (<nile-opdef>-sig (car (<text-parser>-result p)))))))))
(define-function nile-accepts (text type)
  (let ((sig (nile-sig (string->symbol (template-text type)))) (src (template-text text)))
    (nile-verdict (lambda ()
		    (let ((p (nile-parse $expr src)))
		      (or (= (<text-parser>-position p) (<text-parser>-limit p)) (_exit 4))
		      (nile-check (list (nile-opdef sig (nile-opbody () (<text-parser>-result p))))))))))
(define-function nile-defines (text) (nile-verdict (lambda () (nile-check (<text-parser>-result (nile-parse $start (template-text text)))))))
(define nile_accepts nile-accepts)
(define nile_defines nile-defines)
(define nile_signatures nile-signatures)

;; for claims: the rules' own verdict, the rules reached from rel that n draws at each type never use,
;; a term's text, a parsed expression printed back as the rules write it, and non-ASCII text
(define-function checks (rel env t e) (if (rules-holds? *law-rules* (list rel env t e) *ls*) accept reject))
(define-function unfired (rel env types n)
  (rules-seed *rules-seed*)
  (for (i 0 n) (list-do t (cdr (assq types *law-sets*)) (rules-generate *law-rules* (list rel env t '$e) *ls*)))
  (let ((k 0))
    (list-do r *law-rules*
      (let ((p (car (cadr r))))
	(and (or (= p rel) (rules-reaches? rel p *law-rules* ())) (not (member? r (rules-used))) (set k (+ k 1)))))
    k))
(define text template-text)
(define unparse)
(define-function unparse (x)
  (cond ((is-a? x <nile-numexpr>)	(<nile-numexpr>-number x))
	((is-a? x <nile-varexpr>)	(<nile-varexpr>-var x))
	((= 'pre (<nile-opexpr>-fixity x))	(concat-strings (<nile-opexpr>-op x) "(" (unparse (<nile-opexpr>-arg x)) ")"))
	(else (let ((a (<nile-opexpr>-arg x))) (concat-strings "(" (unparse (car a)) " " (<nile-opexpr>-op x) " " (unparse (cadr a)) ")")))))
(define-function non_ascii (s) (let ((y ())) (for (i 0 (string-length s)) (and (< 127 (string-at s i)) (set y 1))) y))
