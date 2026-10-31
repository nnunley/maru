;;; grammar-gen.l -- sentences generated from a tpeg grammar's own records.
;;;
;;;   (grammar-domain class paths)             the grammar's rules, read from paths (later ones override)
;;;   (grammar-sentence domain rule fuel)      text class's parser accepts in full as rule, or () after 50 tries
;;;   (grammar-acceptance domain rule n fuel)  (accepted . n) of n sentences generated
;;;   (grammar-accepts? domain rule text)      class's parser accepts all of text as rule
;;;   (grammar-counts domain rule)             (accepted . generated) so far; grammar-reset clears them
;;;
;;; Choices come from rules.l's seeded source, so rules-seed reproduces them.
;;; The layout rule _ generates nothing: a sentence ending in a // comment would
;;; swallow whatever a template puts after it.
;;; See docs/rfc/draft-ndn-maru-laws-and-rules-00.md, "Generating from a grammar".

(require "tpeg.l")
(require "text-parser.l")
(require "rules.l")

(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)

(define-structure <grammar-domain> (class rules height reach counts))
(define-function grammar-pick (l) (array-at (list->array l) (rules-rand (list-length l))))
(define-function grammar-rule-body (d name)
  (cadr (or (assq name (<grammar-domain>-rules d)) (error "grammar-gen: no rule " name))))

;; minimum derivation height of each rule, by fixpoint, so bounded generation can finish
(define grammar-height)
(define-function grammar-rule-height (d name) (or (cdr (assq name (<grammar-domain>-height d))) 999))
(define-function grammar-height (d pe)
  (let ((k (car pe)) (a (cdr pe)))
    (cond
      ((= k 'match-rule)	(+ 1 (grammar-rule-height d (car a))))
      ((= k 'match-first)	(let ((m 999)) (list-do e a (set m (min m (grammar-height d e)))) m))
      ((= k 'match-all)		(let ((m 0)) (list-do e a (set m (max m (grammar-height d e)))) m))
      ((member? k '(match-one-more match-require make-span make-string make-symbol))
				(grammar-height d (car a)))
      ((member? k '(make-number assign-result))	(grammar-height d (cadr a)))
      (else 0))))
(define-function grammar-heights (d)
  (let ((changed 1))
    (while changed
      (set changed ())
      (list-do r (<grammar-domain>-rules d)
	(let ((h (grammar-height d (cadr r))))
	  (when (< h (grammar-rule-height d (car r)))
	    (set (<grammar-domain>-height d) (cons (cons (car r) h) (<grammar-domain>-height d)))
	    (set changed 1)))))))

;; the rules each rule's body can reach, by fixpoint
(define-function grammar-refs (pe)
  (cond ((not (pair? pe))		())
	((= 'match-rule (car pe))	(list (cadr pe)))
	(else				(let ((r ())) (list-do x (cdr pe) (set r (concat-list (grammar-refs x) r))) r))))
(define-function grammar-rule-reach (d name) (cdr (assq name (<grammar-domain>-reach d))))
(define-function grammar-reaches (d)
  (set (<grammar-domain>-reach d) (map (lambda (r) (cons (car r) (grammar-refs (cadr r)))) (<grammar-domain>-rules d)))
  (let ((changed 1))
    (while changed
      (set changed ())
      (list-do entry (<grammar-domain>-reach d)
	(list-do n (cdr entry)
	  (list-do m (grammar-rule-reach d n)
	    (unless (member? m (cdr entry))
	      (set-cdr entry (cons m (cdr entry)))
	      (set changed 1))))))))
(define-function grammar-reaches? (d pe name)
  (let ((r ())) (list-do n (grammar-refs pe) (or r (set r (or (= n name) (member? name (grammar-rule-reach d n)))))) r))

(define-function grammar-domain (class paths)
  (let ((rules ()))
    (list-do path paths
      (list-do r (cdr (parse-file <tpeg> $parser_spec path))
	(set rules (cons (cons (car r) (cdr r)) rules))))
    (let ((d (new <grammar-domain>)))
      (set (<grammar-domain>-class d) class)
      (set (<grammar-domain>-rules d) rules)
      (grammar-heights d)
      (grammar-reaches d)
      d)))

;; Fuel bounds a sentence and is split among a sequence's parts, so trees come
;; out balanced.  With none left, a choice takes a cheap alternative that cannot
;; lead back to the rule being expanded, so generation ends with varied leaves.
(define *grammar-current* ())	; the rule being expanded
(define grammar-gen)
(define-function grammar-leaves (d alts)
  (let ((m 999) (ok ()) (best ()))
    (list-do e alts (set m (min m (grammar-height d e))))
    (list-do e alts (and (<= (grammar-height d e) (+ m 2)) (not (grammar-reaches? d e *grammar-current*)) (push ok e)))
    (list-do e alts (and (= m (grammar-height d e)) (push best e)))
    (or ok best)))
(define-function grammar-grows? (pe)
  (and (pair? pe) (or (= 'match-rule (car pe)) (let ((r ())) (list-do x (cdr pe) (or r (set r (grammar-grows? x)))) r))))
(define-function grammar-repeat (d n pe f)
  (let ((s "") (each (/ f (max n 1))))
    (while (and s (> n 0))
      (let ((x (grammar-gen d pe each))) (set s (and x (concat-string s x))))
      (set n (- n 1)))
    s))
(define-function grammar-seq (d parts f)
  (let ((s "") (n 0))
    (list-do e parts (and (grammar-grows? e) (set n (+ n 1))))
    (let ((each (/ f (max n 1))))
      (list-do e parts (and s (let ((x (grammar-gen d e each))) (set s (and x (concat-string s x))))))
      s)))
(define-function grammar-expand (d name f)
  (if (= '_ name) ""
    (let ((outer *grammar-current*))
      (set *grammar-current* name)
      (let ((s (grammar-gen d (grammar-rule-body d name) f)))
	(set *grammar-current* outer)
	s))))
(define-function grammar-char (cs) (character->string (string-at cs (rules-rand (string-length cs)))))
(define-function grammar-gen (d pe f)
  (let ((k (car pe)) (a (cdr pe)))
    (cond
      ((= k 'match-rule)	(grammar-expand d (car a) f))
      ((= k 'match-first)	(if (> f 0) (grammar-gen d (grammar-pick a) (- f 1)) (grammar-gen d (grammar-pick (grammar-leaves d a)) 0)))
      ((= k 'match-all)		(grammar-seq d a f))
      ((= k 'match-zero-more)	(grammar-repeat d (if (> f 0) (rules-rand 3) 0) (car a) f))
      ((= k 'match-one-more)	(grammar-repeat d (+ 1 (if (> f 0) (rules-rand 2) 0)) (car a) f))
      ((= k 'match-zero-one)	(grammar-repeat d (if (> f 0) (rules-rand 2) 0) (car a) f))
      ((= k 'match-string)	(car a))
      ((= k 'match-class)	(grammar-char (text-parser-make-class (car a))))
      ((= k 'match-any)		(grammar-char "ab1 +*"))
      ((member? k '(match-require make-span make-string make-symbol)) (grammar-gen d (car a) f))
      ((member? k '(make-number assign-result))	(grammar-gen d (cadr a) f))
      ((member? k '(result-expr peek-not peek-for peek-expr)) "")
      (else			(error "grammar-gen: no case for " k)))))

;; the parser, quiet: a failed ~"..." returns no match instead of stopping
(define-function grammar-quiet (self what) ())
(define-function grammar-accepts? (d rule text)
  (let ((expected text-parser-expected) (p (text-parser-for-on (<grammar-domain>-class d) text)))
    (set text-parser-expected grammar-quiet)
    (let ((ok (text-parser-invoke-rule rule (eval (concat-symbol '$ rule)) p)))
      (set text-parser-expected expected)
      (and ok (= (<text-parser>-position p) (string-length text))))))

(define-function grammar-counter (d rule)	; (rule accepted generated)
  (or (assq rule (<grammar-domain>-counts d))
      (car (set (<grammar-domain>-counts d) (cons (list rule 0 0) (<grammar-domain>-counts d))))))
(define-function grammar-counts (d rule) (let ((c (grammar-counter d rule))) (cons (cadr c) (caddr c))))
(define-function grammar-reset (d rule) (let ((c (grammar-counter d rule))) (set-car (cdr c) 0) (set-cdr (cdr c) (list 0))))
(define-function grammar-try (d rule fuel)	; one generated sentence, if accepted
  (let ((c (cdr (grammar-counter d rule))) (s (grammar-expand d rule fuel)))
    (set-car (cdr c) (+ 1 (cadr c)))
    (and s (grammar-accepts? d rule s) (set-car c (+ 1 (car c))) s)))
(define-function grammar-sentence (d rule fuel)
  (let ((tries 0) (found ()))
    (while (and (not found) (< tries 50))
      (set tries (+ tries 1))
      (set found (grammar-try d rule fuel)))
    found))
(define-function grammar-acceptance (d rule n fuel)
  (let ((ok 0)) (for (i 0 n) (and (grammar-try d rule fuel) (set ok (+ ok 1)))) (cons ok n)))
