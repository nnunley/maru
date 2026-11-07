;;; ometa2.l -- OMeta2 grammar classes (KSWorld's KScript2 compiler: KSParser2, KSQuoteTranslator2 ...) run from their sources
;;; on Maru's PEG.  A class's rule methods ("name :args = choice", read by ometa2.g) become a tpeg grammar of their own,
;;; <ometa-CLASS>, over any source; its other methods are Smalltalk (ksworld-source.l), its support.  A Smalltalk expression in a
;;; rule (an action, a predicate, a result, a rule's argument) is read by squeak.g as the class's methods are, and runs with the
;;; rule's bindings as its variables and the grammar's own object as self, so self nextId is the class's method from its source.
;;;
;;;   (ometa2-load-class class)        defines <ometa-CLASS> from ksworld/CLASS.st (its superclasses' rules first)
;;;   (ometa2-match class rule input args)   rule matched against input, as CLASS match: input with: #rule withArgs: args
;;;
;;; OMeta2's own rules (anything, empty, end, exactly, token, spaces ...) are Maru's PEG's or in <ometa2-base>.
(require "ksworld-source.l")
(require "source-parser.l")
(define-function ometa2-seq (terms result)	; a sequence, its last value the result if there is one
  (let ((ts (if result (concat-list terms (list `(result-expr ,result))) terms)))
    (cond ((not ts) '(match-all)) ((not (cdr ts)) (car ts)) (else `(match-all ,@ts)))))

(tpeg-load "ometa2.g")
(define ometa2-match)	; forward: ometa2.st's primitives call it
(ks-load-library "ometa2.st")

;; the Smalltalk in rules: compiled once each, kept by number, run with the rule's bindings and the grammar's object
(define *ometa2-actions* (array))
(define *ometa2-host* ())	; the grammar object whose rules are running: self in their Smalltalk
(define *ometa2-parser* ())	; and the parser running them, for apply:withArgs:
(define-function ometa2-action (k env) (ks-stream-curr (ks-eval (array-at *ometa2-actions* k) env *ometa2-host*)))
(define-function ometa2-true? (v) (ks-truthy? v))
(define-function ometa2-compile (src ivars classvars)	; the number of a Smalltalk expression's tree
  (let ((p (text-parser-for-on <squeak> src)))
    (set *squeak-ivars* ivars) (set *squeak-classvars* classvars)
    (or (text-parser-invoke-rule 'statements $statements p) (error "OMeta2: can't read the Smalltalk " src))
    (array-append *ometa2-actions* `(begin ,@(<text-parser>-result p)))
    (- (array-length *ometa2-actions*) 1)))

;; a rule as ometa2.g reads it, made tpeg's: each Smalltalk expression run with the bindings the rule makes, and literals
;; matched as values (a tree's elements) or as characters (text)
(define-function ometa2-names (x out)	; the names a rule binds
  (cond ((not (pair? x)) out)
	((= 'assign-result (car x)) (ometa2-names (caddr x) (if (member? (cadr x) out) out (cons (cadr x) out))))
	(else (let () (list-do e x (set out (ometa2-names e out))) out))))
(define-function ometa2-finish (x names ivars classvars text?)
  (cond ((not (pair? x)) x)
	((= 'smalltalk (car x))
	 `(ometa2-action ,(ometa2-compile (cadr x) ivars classvars) (list ,@(map (lambda (n) `(cons ',n ,n)) names))))
	((= 'ometa2-char (car x)) (if text? `(match-string ,(list->string (list (cadr x)))) `(match-object ,(cadr x))))
	((= 'ometa2-exactly (car x))	; a string is equal, not the same object, so in a tree: an element, then equal to it
	 (if text? `(match-string ,(cadr x))
	   `(match-all (assign-result ometa2-element (match-any)) (peek-expr (equal ometa2-element ,(cadr x))))))
	((= 'quote (car x)) x)
	(else (map (lambda (e) (ometa2-finish e names ivars classvars text?)) x))))
(define-function ometa2-rule (src ivars classvars text?)	; (NAME EXPRESSION PARAMETERS), or () if src isn't a rule
  (let ((p (text-parser-for-on <ometa2> src)))
    (and (text-parser-invoke-rule 'rule $rule p)
	 (let* ((r (<text-parser>-result p)) (names (ometa2-names (cadr r) (caddr r))))
	   (list (car r) (ometa2-finish (cadr r) names ivars classvars text?) (caddr r))))))

(define-function ometa2-grammar-name (class) (string->symbol (concat-strings "<ometa-" (symbol->string class) ">")))
(define *ometa2-loaded* ())
(define-function ometa2-load-class (class text?)	; its Smalltalk support as a class, its rules as <ometa-CLASS>
  (unless (member? class *ometa2-loaded*)
    (push *ometa2-loaded* class)
    (ks-load-source-class class)
    (let* ((path (concat-strings "ksworld/" (symbol->string class) ".st"))
	   (def (ks-source-class-of path)) (ivars (map symbol->string (caddr def))) (cvs (ks-source-classvars path))
	   (rules ()))
      (list-do m (ks-source-methods path)
	(and (= 'instance (<ks-source-method>-side m)) (not (<ks-source-method>-tree m))
	     (let ((r (ometa2-rule (<ks-source-method>-source m) ivars cvs text?))) (and r (push rules r)))))
      (tpeg-define (list (ometa2-grammar-name class) (if text? '<text-parser> '<source-parser>) ()) (list-reverse! rules)))))

(define-function ometa2-match (class rule input args)	; class match: input with: #rule withArgs: args
  (let* ((host (ks-send (ks-class-named class) 'new () () ()))
	 (g (eval (ometa2-grammar-name class)))
	 (p (if (string? input) (text-parser-for-on g input) (source-parser-for g (list input))))
	 (saved-host *ometa2-host*) (saved-parser *ometa2-parser*))
    (set *ometa2-host* host) (set *ometa2-parser* p)
    (let ((ok (apply (if (string? input) text-parser-invoke-rule source-parser-invoke-args)
		     (cons rule (cons (eval (concat-symbol '$ rule)) (cons p args))))))
      (set *ometa2-host* saved-host) (set *ometa2-parser* saved-parser)
      (if ok (if (string? input) (<text-parser>-result p) (<source-parser>-result p)) (error "OMeta2: " class " didn't match " rule)))))
