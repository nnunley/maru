;;; source-parser.l: a parser over any source with the input selectors (input.l), as compile-tpeg.l
;;; --on source generates for it. Its position is a stream cell, so value-pe's save and restore of
;;; self.position carry over. Text stays on <text-parser> (text-parser.l), which doesn't load this.
(require "input.l")
(require "text-parser.l")	; <memo>, put, get and the states memos use, as text does; peg-enable-* apply here too

(define-structure <source-parser> (source position result foreign streams))

;; the stream of a value, kept on this parser: a value entered twice reuses its stream, and so its memos
(define-function source-parser-stream-of (self value)
  (let ((hit (assq value (<source-parser>-streams self))))
    (if hit
	(cdr hit)
      (let ((c (stream-of value)))
	(set (<source-parser>-streams self) (cons (cons value c) (<source-parser>-streams self)))
	c))))

(define-function source-parser-for (class source)
  (let ((p (new class source () () () ())))
    (set (<source-parser>-position p) (source-parser-stream-of p source))
    p))

(define source-parser-match-any
  (define-method parser-match-any <source-parser> ()
    (let ((c self.position))
      (when (not (stream-end? c))
	(set self.result (stream-head c))
	(set self.position (stream-tail c))
	1))))

;; a class is a string of characters: an element matches if it is a character in it
(define source-parser-match-class
  (define-method parser-match-class <source-parser> (class)
    (let ((c self.position))
      (when (and (not (stream-end? c))
		 (long? (stream-head c))
		 (string-search class (stream-head c)))
	(set self.result (stream-head c))
	(set self.position (stream-tail c))
	1))))

(define source-parser-match-object
  (define-method parser-match-object <source-parser> (obj)
    (let ((c self.position))
      (when (and (not (stream-end? c))
		 (in-same (stream-head c) obj))
	(set self.result obj)
	(set self.position (stream-tail c))
	1))))

;; a literal character, whose result is a one-character string, as on text
(define source-parser-match-char
  (define-method parser-match-char <source-parser> (obj)
    (let ((c self.position))
      (when (and (not (stream-end? c))
		 (in-same (stream-head c) obj))
	(set self.result (list->string (list obj)))
	(set self.position (stream-tail c))
	1))))

;; a string literal matches consecutive elements, as Warth's seq does
(define source-parser-match-string
  (define-method parser-match-string <source-parser> (string len)
    (let ((c self.position)
	  (i 0))
      (while (and (< i len)
		  (not (stream-end? c))
		  (in-same (stream-head c) (string-at string i)))
	(set c (stream-tail c))
	(incr i))
      (when (= i len)
	(set self.result string)
	(set self.position c)
	1))))

(define source-parser-list-from-to
  (define-method parser-list-from-to <source-parser> (from to)
    (stream-span from to)))

(define source-parser-string-from-to
  (define-method parser-string-from-to <source-parser> (from to)
    (list->string (stream-span from to))))

(define source-parser-expected
  (define-method parser-expected <source-parser> (what)
    (error what " expected")))

;; the cells of a call's arguments, first argument first, whose tail is the caller's input
(define-function source-parser-arguments (source args tail)
  (if (pair? args)
      (new <cell> source () () (car args) (source-parser-arguments source (cdr args) tail) ())
      tail))

;; A rule takes no parameters: its arguments are the first elements of its input. On failure the
;; saved cell is restored, so no argument cell stays behind. This is the call with no memo; a call
;; with arguments always goes through it, since its answer depends on the arguments.
(define-function source-parser-invoke-rule-plain (name rule self . args)
  (let ((saved (<source-parser>-position self)))
    (set (<source-parser>-position self) (source-parser-arguments (<source-parser>-source self) args saved))
    (or (rule self)
	(let () (set (<source-parser>-position self) saved) ()))))

(define source-parser-invoke-rule-simply source-parser-invoke-rule-plain)
;; a call by name from code with arguments, as a generated call with arguments makes it: never memoized
(define source-parser-invoke-args source-parser-invoke-rule-plain)

;; A rule with no arguments answers at its cell, in the cell's memo, keyed by the rule's name, so $r and
;; $$r share one answer. An effect matches as its value does, and the value also has a result, so a memo
;; holds the value's answer and an effect call runs the value. A call with arguments is not memoized, since
;; its answer depends on the arguments, nor is a call by name ({apply}, {super}), whose rule is a method.

;; $$r is an effect and $r a value: the two selectors of one rule
(define-function source-parser-effect? (rule)
  (= (string-at "$" 0) (string-at (symbol->string (<selector>-name rule)) 1)))

;; the key a rule's memo is kept under: its name without the $ or $$ of its selector
(define-function source-parser-memo-key (rule)
  (let* ((s (symbol->string (<selector>-name rule)))
	 (k (if (source-parser-effect? rule) 2 1)))
    (string->symbol (string-copy s k (- (string-length s) k)))))

;; the selector a call runs: the value of an effect's rule, so the one answer serves both
(define-function source-parser-memo-rule (rule key)
  (if (source-parser-effect? rule) (eval (concat-symbol '$ key)) rule))

;; the answer a memo gives: nothing on failure, else where it got to, with its result
(define-function source-parser-memo-answer (self memo)
  (if (= (<memo>-state memo) *failed*)
      ()
    (let ()
      (set (<source-parser>-result self) (<memo>-result memo))
      (set (<source-parser>-position self) (<memo>-position memo))
      1)))

(define-function source-parser-invoke-rule-with-memo (name rule self . args)
  (if args
      (apply source-parser-invoke-rule-plain (cons name (cons rule (cons self args))))
    (let* ((here (<source-parser>-position self))
	   (key  (source-parser-memo-key rule))
	   (memo (get (<cell>-memo here) key)))
      (if memo
	  (source-parser-memo-answer self memo)
	(let ((m (new <memo>)))
	  (put (<cell>-memo here) key m)
	  (if (source-parser-invoke-rule-plain name (source-parser-memo-rule rule key) self)
	      (let ()
		(memo-set m *succeeded* (<source-parser>-result self) (<source-parser>-position self))
		1)
	    (let () (set (<memo>-state m) *failed*) ())))))))

;; Left recursion grows as OMeta2's apply: does. The first pass fails or succeeds with a seed; while a
;; pass that calls the rule at its own cell reaches the seed, the next pass grows the answer. A pass
;; stops the growth when it fails, when it ends where the seed pass ended (the sentinel), or when it
;; doesn't advance past the answer so far; cells are compared by identity.
(define-function source-parser-invoke-rule-with-recursion (name rule self . args)
  (if args
      (apply source-parser-invoke-rule-plain (cons name (cons rule (cons self args))))
    (let* ((here (<source-parser>-position self))
	   (key  (source-parser-memo-key rule))
	   (vrule (source-parser-memo-rule rule key))
	   (memo (get (<cell>-memo here) key)))
      (cond
	;; the rule calls itself at its own cell: fail, and note that it recurred
	((and memo (= (<memo>-state memo) *active*))
	 (set (<memo>-state memo) *recurred*)
	 ())
	(memo
	 (source-parser-memo-answer self memo))
	(else
	 (let ((m (new <memo> *active* () here)))
	   (put (<cell>-memo here) key m)
	   (if (source-parser-invoke-rule-plain name vrule self)
	       (let ((state (<memo>-state m)))
		 (memo-set m *succeeded* (<source-parser>-result self) (<source-parser>-position self))
		 (when (= state *recurred*)
		   (let ((seed (<memo>-position m)))
		     (set (<source-parser>-position self) here)
		     (while (and (source-parser-invoke-rule-plain name vrule self)
				 (let ((end (<source-parser>-position self)))
				   (and (not (= end seed))
					(not (= end (<memo>-position m))))))
		       (memo-set m *succeeded* (<source-parser>-result self) (<source-parser>-position self))
		       (set (<source-parser>-position self) here))
		     (set (<source-parser>-result self) (<memo>-result m))
		     (set (<source-parser>-position self) (<memo>-position m))))
		 1)
	     (let () (set (<memo>-state m) *failed*) ()))))))))

(define source-parser-invoke-rule source-parser-invoke-rule-plain)

;; the rule-call strategy the three peg-* switches choose; text-parser.l calls it, and it is found by name
(define-function source-parser-choose (kind)
  (set source-parser-invoke-rule (eval (concat-symbol 'source-parser-invoke-rule- kind))))

;; the method a rule name finds on a type: its own, or the nearest parent's (what a call by name reaches)
(define-function source-parser-method-of (sel type)
  (or (array-at (<selector>-methods sel) type)
      (<selector>-inherit (<selector>-methods sel) type)))

;; {apply x args}: the rule named x on this object's type, so an override is the one called. A name with
;; no rule fails the match. prefix is $ for a value and $$ for an effect, as the rule's selectors are.
(define-function source-parser-apply (self prefix name . args)
  (let* ((sym  (concat-symbol prefix name))
	 (sel  (and (defined? sym) (eval sym)))
	 (rule (and (selector? sel) (source-parser-method-of sel (type-of self)))))
    (and rule (apply source-parser-invoke-rule-plain (cons name (cons rule (cons self args)))))))

;; {super r args}: r as the parent defines it, whatever the object's type is. parent is the base of the class
;; the calling rule is defined in, so an override reaches the rule it overrides, or what that inherits.
(define-function source-parser-super (self prefix parent name . args)
  (let* ((sel  (eval (concat-symbol prefix name)))
	 (rule (or (source-parser-method-of sel parent)
		   (error "no rule " name " in " (name-of-type parent)))))
    (apply source-parser-invoke-rule-plain (cons name (cons rule (cons self args))))))

;; A foreign rule, p-r, runs on an object of its own type. That object sees the caller's input through proxy cells:
;; a proxy's position is the caller's cell, so its head and end are the caller's, its tail is a proxy of the caller's
;; tail, and its memo is empty. When the rule returns, the caller's input is the caller's cell it got to, and its
;; result comes across. The object is kept on the caller, as text-parser.l keeps its foreign parsers, so its fields
;; are its own; the proxies are not, so no memo outlives the call.
(define-structure <proxy> (source))
(define source-parser-proxy (new <proxy> ()))

(define-method in-at-end <proxy> (c)	(stream-end? c))
(define-method in-head <proxy> (c)	(stream-head c))
(define-method in-tail <proxy> (c)	(stream-tail c))

(define-function source-parser-invoke-rule-in (self type name rule)
  (let ((sub (cdr (assq type (<source-parser>-foreign self)))))
    (or sub (let ()
	      (set sub (new type source-parser-proxy () () () ()))
	      (set (<source-parser>-foreign self) (cons (cons type sub) (<source-parser>-foreign self)))))
    (set (<source-parser>-position sub) (stream-at source-parser-proxy (<source-parser>-position self)))
    (and (source-parser-invoke-rule name rule sub)
	 (let ()
	   (set (<source-parser>-position self) (<cell>-position (<source-parser>-position sub)))
	   (set (<source-parser>-result self) (<source-parser>-result sub))
	   1))))

(define-function parse-source (grammar rule source)
  (let ((p (source-parser-for grammar source)))
    (or (source-parser-invoke-rule (<selector>-name rule) rule p)
	(error "failed to parse with grammar " (name-of-type grammar) "." (<selector>-name rule)))
    (<source-parser>-result p)))
