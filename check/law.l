;;; law.l -- runs law files.   ./eval check/law.l SUPPORT.l... FILE.law...
;;; Each SUPPORT.l (functions under test, references) loads first; then each law
;;; prints "law NAME: " (flushed before it runs) and its outcome:
;;;   TESTED n | PROVED n | REFUTED x=v ... seed=s | STARVED k of n | VACUOUS
;;;   | INCONCLUSIVE status=s input=(args) | E_BINDING ... | E_GRAMMAR ... | E_EXHAUST ...
;;; and after a file's laws, for each grammar domain they drew from,
;;;   grammar LANG.RULE: accepted a of n
;;; A file with no under test: line prints E_NO_UNDER_TEST and runs none of its
;;; laws.  The run exits 1 if any law is neither TESTED nor PROVED.
;;; See docs/rfc/draft-ndn-maru-laws-and-rules-00.md, "Laws" and "References".
(require "rules.l")
(require "law-compile.l")
(require "grammar-gen.l")

(define accept 'accept)		; a reference's verdicts, as claims name them
(define reject 'reject)
(define *law-config* ())	; the file's defaults
(define *law-sets* ())		; (Name member...)
(define *law-under* ())		; names on the under test: lines
(define *law-rules* ())		; the file's first-order rule set
(define *law-crash* ())		; (status arg...) once a reference answers neither accept nor reject
(define *law-failed* ())
(define *lb* ())  (define *lvars* ())  (define *lnames* ())	; the law: bindings (var kind data), $vars, plain names
(define *lc* ())  (define *lf* ())  (define *ls* 3)  (define *lclaim* ())  (define *lseed* 42)  (define *lmethod* ())

(define-function law-setting (key)
  (cdr (or (assq key *law-config*) (assq key '((size . 3) (trials . 100) (seed . 42) (starved_ratio . 20))))))
(define-function law-nth (l i) (if (= i 0) (car l) (law-nth (cdr l) (- i 1))))
(define-function law-take (l i) (and (> i 0) (cons (car l) (law-take (cdr l) (- i 1)))))
(define-function law-put (l i v) (if (= i 0) (cons v (cdr l)) (cons (car l) (law-put (cdr l) (- i 1) v))))
(define-function law-abs (x) (if (< x 0) (- 0 x) x))
(define-function law-number? (x) (or (long? x) (double? x)))
(define-function law-plain (v) (let ((s (symbol->string v))) (string->symbol (string-copy s 1 (- (string-length s) 1)))))
(define-function law-subst (g vars vals)
  (while vars (set g (rules-subst g (car vars) (car vals))) (set vars (cdr vars)) (set vals (cdr vals)))
  g)

;; claims and conditions: = compares values, a Capitalised name is a constant, a
;; template is filled with the law's values and parsed
(define-function law-template (lang text bindings) (template-parse lang (template-fill lang text bindings)))
(define-function law-upper? (x) (let ((c (string-at (symbol->string x) 0))) (and (<= ?A c) (<= c ?Z))))
(define-function law-ne (a b) (not (equal a b)))
(define-function law-form (x)
  (cond ((symbol? x)		(if (law-upper? x) (list 'quote x) x))
	((not (pair? x))	x)
	((= 'quote (car x))	x)
	((= 'template (car x))	(list 'law-template (list 'quote (cadr x)) (caddr x)
				      (cons 'list (map (lambda (n) (list 'cons (list 'quote n) n)) *lnames*))))
	(else			(cons (cond ((= '= (car x)) 'equal) ((= '!= (car x)) 'law-ne) (else (car x)))
				      (map law-form (cdr x))))))

;; references: anything but accept or reject is a crash, kept with its input
(define-function law-crashed (v args)
  (or *law-crash* (set *law-crash* (cons (if (and (pair? v) (= 'crash (car v))) (cadr v) v) args)))
  'crash)
(define-function law-wrap (f)
  (lambda args (let ((v (apply f args))) (if (or (= v 'accept) (= v 'reject)) v (law-crashed v args)))))
(define-function law-set-global (name v) (eval (list 'set name (list 'quote v))))

;; domains: a set, a goal whose last argument is the variable, or a grammar's
;; rule, lang.rule, its sentences generated with the law's size as fuel
(define *law-err* ())
(define *law-domains* ())	; (lang . domain), each built when first drawn from
(define *law-drawn-from* ())	; (label domain rule) for each grammar domain in this file
(define-function law-grammar-domain (lang)
  (or (cdr (assq lang *law-domains*))
      (let ((l (assq lang *grammar-languages*)))
	(and l (cdar (push *law-domains* (cons lang (grammar-domain (cadr l) (caddr l) (cadddr l)))))))))
(define-function law-grammar (v lang rule)
  (let ((label (string->symbol (concat-strings (symbol->string lang) "." (symbol->string rule)))) (d (law-grammar-domain lang)))
    (if (not d) (set *law-err* (list 'E_GRAMMAR (concat-string (symbol->string label) " names no grammar language")))
      (or (assq label *law-drawn-from*) (let () (grammar-reset d rule) (set *law-drawn-from* (concat-list *law-drawn-from* (list (list label d rule))))))
      (list v 'grammar d rule label))))
(define-function law-binding (b)
  (let ((v (car b)) (d (cadr b)))
    (cond ((and (pair? d) (= 'grammar (car d)))	(law-grammar v (cadr d) (caddr d)))
	  ((and (symbol? d) (assq d *law-sets*))	(list v 'set (cdr (assq d *law-sets*))))
	  ((symbol? d)					(list v 'goal (list d v)))
	  ((= v (rules-last d))				(list v 'goal d))
	  (else (set *law-err* (list 'E_BINDING (concat-strings (symbol->string (law-plain v)) " is not the last argument of " (symbol->string (car d)))))))))

;; drawing values; law-gen is rules-generate, but tells a value of () from none
(define-function law-gen (goal size)
  (set *rules-random* 1)
  (let* ((env (list ())) (g (rules-rename goal env)) (out (rules-rename (rules-last goal) env)))
    (rules-solve *law-rules* g *rules-empty* size (lambda (s) (list (walk* out s))))))
(define-function law-pick (l) (array-at (list->array l) (rules-rand (list-length l))))
(define-function law-draw-at (b vars vals size)	; (value) or (); a grammar's not counted toward acceptance
  (cond ((= 'set (cadr b))	(list (law-pick (caddr b))))
	((= 'grammar (cadr b))	(let ((s (grammar-regenerate (caddr b) (cadddr b) size))) (and s (list s))))
	(else			(law-gen (law-subst (caddr b) vars vals) size))))
(define-function law-draw-value (b vars vals)	; the law's own draws, at its size, are counted
  (if (= 'grammar (cadr b)) (let ((s (grammar-sentence (caddr b) (cadddr b) *ls*))) (and s (list s)))
    (law-draw-at b vars vals *ls*)))
(define-function law-draw ()		; every variable's value, earlier ones substituted into later domains
  (let ((vars ()) (vals ()) (bs *lb*) (ok 1))
    (while (and ok bs)
      (let ((v (law-draw-value (car bs) vars vals)))
	(if v (let () (set vars (concat-list vars (list (caar bs)))) (set vals (concat-list vals v))) (set ok ())))
      (set bs (cdr bs)))
    (and ok vals)))
(define-function law-values (b vars vals)	; every value of a domain
  (if (= 'set (cadr b)) (caddr b) (rules-enumerate *law-rules* (law-subst (caddr b) vars vals) *ls*)))
(define-function law-member? (b vars vals v)
  (cond ((= 'set (cadr b)) (member? v (caddr b)))
	((= 'grammar (cadr b)) (grammar-accepts? (caddr b) (cadddr b) v))
	(else (rules-holds? *law-rules* (rules-subst (law-subst (caddr b) vars vals) (car b) v) *ls*))))

;; one set of values: skip (conditions false), hold, fail or crash
(define-function law-try (vals)
  (set *law-crash* ())
  (let ((c (apply *lc* vals)))	; a crash in a condition or the claim makes no verdict
    (cond (*law-crash* 'crash) ((not c) 'skip)
	  (else (let ((h (apply *lf* vals))) (cond (*law-crash* 'crash) (h 'hold) (else 'fail)))))))

;; shrinking: a number toward 0, a set member toward the first, a rule-built or
;; generated value by drawing again at a smaller size; kept only while the claim fails
(define-function law-regen (b vars vals size)	; (value . size)...
  (let ((out ()))
    (for (s 0 size) (for (k 0 10) (let ((v (law-draw-at b vars vals s))) (and v (push out (cons (car v) s))))))
    (list-reverse! out)))
(define-function law-candidates (b vars vals v size)
  (let ((out ()))
    (cond ((law-number? v)		(list-do n *rules-numbers* (and (< (law-abs n) (law-abs v)) (push out (cons n size)))))
	  ((= 'set (cadr b))	(let ((l (caddr b))) (while (and l (not (= v (car l)))) (push out (cons (car l) size)) (set l (cdr l)))))
	  (else			(set out (law-regen b vars vals size))))
    out))
(define-function law-valid? (vals i)	; values from i on are still in their domains
  (let ((ok 1) (n (list-length *lb*)))
    (while (and ok (< i n))
      (set ok (law-member? (law-nth *lb* i) (law-take *lvars* i) (law-take vals i) (law-nth vals i)))
      (set i (+ i 1)))
    ok))
(define-function law-smaller (i vals sizes)	; (vals . sizes) with value i smaller, still failing, or ()
  (let ((out ()) (pre (law-take vals i)))
    (list-do c (law-candidates (law-nth *lb* i) (law-take *lvars* i) pre (law-nth vals i) (law-nth sizes i))
      (or out (let ((vs (law-put vals i (car c))))
		(and (law-valid? vs i) (= 'fail (law-try vs)) (set out (cons vs (law-put sizes i (cdr c))))))))
    out))
(define-function law-shrink (vals)
  (let ((sizes (map (lambda (b) *ls*) *lb*)) (more 1))
    (while more
      (set more ())
      (for (i 0 (list-length vals))
	(let ((c (law-smaller i vals sizes))) (and c (let () (set vals (car c)) (set sizes (cdr c)) (set more 1))))))
    vals))
(define-function law-failed (r vals)	; the outcome of a failing or crashing try
  (if (= r 'fail) (list 'REFUTED (law-shrink vals))
    (cons 'INCONCLUSIVE *law-crash*)))

;; TEST: trials values meeting the conditions, from at most trials x starved_ratio draws
(define-function law-test ()
  (let* ((trials (law-setting 'trials)) (limit (* trials (law-setting 'starved_ratio))) (met 0) (drawn 0) (out ()))
    (while (and (not out) (< met trials) (< drawn limit))
      (set drawn (+ drawn 1))
      (let* ((vals (law-draw)) (r (if vals (law-try vals) 'skip)))
	(if (= r 'hold) (set met (+ met 1))
	  (or (= r 'skip) (set out (law-failed r vals))))))
    (or out (if (< met trials) (list 'STARVED met drawn) (list 'TESTED met)))))
;; EXHAUST: every value up to the size
(define *law-out* ())  (define *law-met* 0)  (define *law-drawn* 0)
(define-function law-visit (vals)
  (set *law-drawn* (+ *law-drawn* 1))
  (let ((r (law-try vals)))
    (if (= r 'hold) (set *law-met* (+ *law-met* 1))
      (or (= r 'skip) (set *law-out* (law-failed r vals))))))
(define-function law-every (bs vars vals)
  (if bs
      (list-do v (law-values (car bs) vars vals)
	(or *law-out* (law-every (cdr bs) (concat-list vars (list (caar bs))) (concat-list vals (list v)))))
    (law-visit vals)))
(define-function law-exhaust ()
  (set *law-out* ()) (set *law-met* 0) (set *law-drawn* 0)
  (law-every *lb* () ())
  (cond (*law-out* *law-out*)
	((or (= 0 *law-met*) (< (* *law-met* (law-setting 'starved_ratio)) *law-drawn*))	(list 'STARVED *law-met* *law-drawn*))
	(else (list 'PROVED *law-met*))))
(define-function law-method () (rules-seed *lseed*) (if (= 'exhaustion *lmethod*) (law-exhaust) (law-test)))
(define-function law-pass? (r) (member? (car r) '(TESTED PROVED)))

;; VACUOUS: the claim names nothing under test (directly or through a variable's
;; domain), or still holds with every under-test function returning 0, and 1
(define-function law-names? (x names)
  (if (pair? x) (or (law-names? (car x) names) (law-names? (cdr x) names)) (and (symbol? x) (member? x names))))
(define-function law-uses? (b)	; a goal domain whose relation is, or reaches, one under test
  (let ((y ()))
    (and (= 'goal (cadr b))
	 (list-do u *law-under* (and (or (= u (car (caddr b))) (rules-reaches? (car (caddr b)) u *law-rules* ())) (set y 1))))
    y))
(define-function law-names-under? ()
  (or (law-names? *lclaim* *law-under*)
      (let ((y ()) (bs *lb*))
	(list-do n *lnames* (and (law-names? *lclaim* (list n)) (law-uses? (car bs)) (set y 1)) (set bs (cdr bs)))
	y)))
(define-function law-functions ()	; (name . value) for each under-test name bound to a function
  (let ((out ()))
    (list-do u *law-under*
      (let ((d (defined? u)))
	(and d (let ((f (eval u))) (and (or (expr? f) (= <subr> (type-of f))) (push out (cons u f)))))))
    out))
;; the stand-ins run in a forked child: one that errors or crashes shows the law depends on the code
(define fork	(subr "fork" ">i"))
(define waitpid	(subr "waitpid" "ipi>i"))
(define _exit	(subr "_exit" "i"))
(define status-word ((subr "malloc" "l>p") 8))
(define-function law-quiet ()	; the child's output, an error's backtrace included, goes nowhere
  (let ((fd ((subr "open" "si>i") "/dev/null" 1))) ((subr "dup2" "ii>i") fd 1) ((subr "dup2" "ii>i") fd 2)))
(define-function law-holds-with (fs k)
  (let ((pid (fork)))
    (when (= 0 pid)
      (law-quiet)
      (list-do f fs (law-set-global (car f) (lambda args k)))
      (_exit (if (law-pass? (law-method)) 0 1)))
    (waitpid pid status-word 0)
    (= 0 (+ (byte-at status-word 0) (byte-at status-word 1)))))
(define-function law-vacuous? ()
  (or (not (law-names-under?))
      (let ((fs (law-functions))) (and fs (law-holds-with fs 0) (law-holds-with fs 1)))))

(define-function law-report (r)
  (let ((k (car r)))
    (print k)
    (cond ((= k 'REFUTED)	(let ((ns *lnames*) (bs *lb*))	; a generated sentence is quoted, as it may hold a newline
				  (list-do v (cadr r) (print " " (car ns) "=") (if (= 'grammar (cadar bs)) (dump v) (print v)) (set ns (cdr ns)) (set bs (cdr bs)))
				  (print " seed=" *lseed*)))
	  ((= k 'STARVED)	(print " " (cadr r) " of " (caddr r)))
	  ((= k 'INCONCLUSIVE)	(print " status=" (cadr r) " input=" (cddr r)))
	  ((= k 'VACUOUS))
	  (else			(print " " (cadr r))))
    (println "")
    (or (law-pass? r) (set *law-failed* 1))))

(define-function law-one (it seed)	; it: (law name bindings conditions claim method size)
  (print "law " (cadr it) ": ")
  (set *law-err* ())
  (set *lb* (map law-binding (caddr it)))
  (and (not *law-err*) (= 'exhaustion (cadr (cddddr it)))	; generated sentences can't be enumerated
       (list-do b *lb* (and (= 'grammar (cadr b)) (set *law-err* (list 'E_EXHAUST (concat-string (symbol->string (car (cddddr b))) " is generated, not enumerated; use by test"))))))
  (if *law-err* (law-report *law-err*)
    (let ()
      (set *lvars* (map car *lb*)) (set *lnames* (map law-plain *lvars*))
      (set *lclaim* (car (cddddr it))) (set *lseed* seed)
      (set *lmethod* (cadr (cddddr it))) (set *ls* (or (caddr (cddddr it)) (law-setting 'size)))
      (set *lc* (eval `(lambda ,*lnames* (and 1 ,@(map law-form (cadddr it))))))
      (set *lf* (eval `(lambda ,*lnames* ,(law-form *lclaim*))))
      (let ((r (law-method)))
	(law-report (if (and (law-pass? r) (law-vacuous?)) '(VACUOUS) r))))))

(define-function law-file (path)
  (let ((items (law-file-read path)) (saved *rules-numbers*) (pos 0))
    (set *law-config* ()) (set *law-sets* ()) (set *law-under* ()) (set *law-drawn-from* ())
    (list-do it items
      (let ((k (car it)))
	(cond ((= k 'defaults)		(set *law-config* (cdr it)))
	      ((= k 'set)		(push *law-sets* (cons (cadr it) (caddr it))))
	      ((= k 'under-test)	(set *law-under* (concat-list *law-under* (cdr it))))
	      ((= k 'reference)		(law-set-global (cadr it) (law-wrap (eval (cadr it))))))))
    (list-do n (law-file-numbers items) (or (member? n *rules-numbers*) (set *rules-numbers* (concat-list *rules-numbers* (list n)))))
    (set *law-rules* (rules-expand (law-rules items)))
    (or *law-under* (let () (println "E_NO_UNDER_TEST " path ": no under test: line, so its laws test nothing") (set *law-failed* 1) (set items ())))
    (list-do it items (and (= 'law (car it)) (let () (law-one it (+ (law-setting 'seed) pos)) (set pos (+ pos 1)))))
    (list-do g *law-drawn-from*
      (let ((c (grammar-counts (cadr g) (caddr g)))) (or (= 0 (cdr c)) (println "grammar " (car g) ": accepted " (car c) " of " (cdr c)))))
    (set *rules-numbers* saved)))

(define-function law-suffix? (s x)
  (let ((n (string-length s)) (m (string-length x))) (and (<= m n) (= x (string-copy s (- n m) m)))))
(let ((args *arguments*))
  (set *arguments* ())
  (list-do a args (and (law-suffix? a ".l") (load a)))
  (list-do a args (or (law-suffix? a ".l") (law-file a)))
  (exit (if *law-failed* 1 0)))
