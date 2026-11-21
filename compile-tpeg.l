;;; compile-with-tpeg.l									-*- coke -*-
;;;
;;; ./eval compile-with-tpeg.l <filename>.g ... > tee <filename>.l
;;;
;;; Generated code returns 1 for a match, never a position or a set's value, so it means the
;;; same where 0 is false: irl-grammar.l lowers value-pe's output to typed Maru.

(require "tpeg.l")
(require "record-case.l")
(require "text-parser.l")

(define-function mapN1 (fnN fn1 list)
  (if (pair? list)
      (if (pair? (cdr list))
	  (cons (fnN (car list)) (mapN1 fnN fn1 (cdr list)))
	(cons (fn1 (car list)) (mapN1 fnN fn1 (cdr list))))
    list))

;;; A grammar's rules run on the parser type its parent is. <text-parser> is the default, and is unchanged.
(define *tpeg-source* ())

(define-function tp-source? ()		*tpeg-source*)

;; the runtime operation a template calls: text-parser-match-any, or source-parser-match-any on source
(define-function tp-op (name)
  (concat-symbol (if (tp-source?) 'source-parser- 'text-parser-) name))

;; the rule and class being compiled, for the errors a list pattern or arguments give on text, and for super
(define *tp-rule* "")
(define *tp-class* ())

(define-function tp-object-literal ()
  (or (tp-source?)
      (error "rule " *tp-rule* " has an object literal, which needs a grammar on <source-parser>")))

;; {apply x args} and {super r args} call by name, which only a grammar on <source-parser> does
(define-function tp-by-name (what args)
  (or (tp-source?)
      (error "rule " *tp-rule* " calls by " what ", which needs a grammar on <source-parser>"))
  (or args (error "rule " *tp-rule* " has {" what "} with no rule name")))

;; apply runs the rule its first argument names, on this object; super runs the rule as the class's parent defines it
(define-function tp-named-call (name args prefix)
  (cond
    ((= name 'apply)	(let () (tp-by-name name args)
			   `(,(tp-op 'apply) self ',prefix ,@args)))
    ((= name 'super)	(let () (tp-by-name name args)
			   `(,(tp-op 'super) self ',prefix (array-at %structure-bases ,*tp-class*) ',(car args) ,@(cdr args))))
    (else		())))

;; A foreign rule p-r runs on an object of type <p>, which sees the input through proxy cells (source-parser.l).
;; On text the same call goes to text-parser-invoke-rule-in, so the output is the text path's as before.
(define-function tp-foreign-call (grammar name sel)
  `(,(tp-op 'invoke-rule-in) self ,(concat-symbol '< (concat-symbol grammar '>)) ',name ,sel))

;; A rule's parameters are the first elements of its input: `rule :a :b` is `.:a .:b` at its start.
;; On <source-parser> a parameter is an element the rule reads from the input. On text it stays an
;; argument of the rule's method, as it always was, since an integer position can't hold a cell.
(define-function tp-parameters (params body)
  (if (and params (tp-source?))
      `(match-all ,@(map (lambda (p) `(assign-result ,p (match-any))) params) ,body)
    body))

(define-function tp-method-parameters (params)
  (if (tp-source?) () params))

;; Left recursion, as irl-grammar.l's irl-left-recursive? finds it: the rules a pattern can call at its start. A
;; rule with parameters has no memo, so one that reaches itself this way would overflow the stack; it is refused.
(define-function tp-nullable? (pe)
  (let ((h (car pe)))
    (cond ((member? h '(match-zero-one match-zero-more peek-for peek-not result-expr)) 1)
	  ((member? h '(match-class match-string)) (= 0 (string-length (cadr pe))))
	  ((= h 'match-all)	(let ((r 1)) (list-do e (cdr pe) (or (tp-nullable? e) (set r ()))) r))
	  ((= h 'match-first)	(let ((r ())) (list-do e (cdr pe) (and (tp-nullable? e) (set r 1))) r))
	  ((member? h '(match-one-more make-span make-string make-symbol)) (tp-nullable? (cadr pe)))
	  ((member? h '(assign-result make-number)) (tp-nullable? (caddr pe)))
	  (else ()))))

(define-function tp-left-calls (pe)
  (let ((h (car pe)))
    (cond ((= h 'match-rule) (list (cadr pe)))
	  ((= h 'match-all)
	   (let ((out ()) (go 1))
	     (list-do e (cdr pe)
	       (and go
		    (let ()
		      (set out (concat-list out (tp-left-calls e)))
		      (or (tp-nullable? e) (set go ())))))
	     out))
	  ((= h 'match-first)
	   (let ((out ()))
	     (list-do e (cdr pe) (set out (concat-list out (tp-left-calls e))))
	     out))
	  ((member? h '(match-zero-one match-zero-more match-one-more peek-for peek-not make-span make-string make-symbol))
	   (tp-left-calls (cadr pe)))
	  ((member? h '(assign-result make-number)) (tp-left-calls (caddr pe)))
	  (else ()))))

(define-function tp-left-recursive? (name rules)
  (let ((seen ()) (todo (tp-left-calls (cadr (assq name rules)))) (found ()))
    (while (and todo (not found))
      (let ((r (car todo)))
	(set todo (cdr todo))
	(if (= r name)
	    (set found 1)
	    (or (member? r seen)
		(let ((d (assq r rules)))
		  (push seen r)
		  (and d (set todo (concat-list todo (tp-left-calls (cadr d))))))))))
    found))

(define-function tp-check-parameters (rules)
  (list-do r rules
    (when (and (tp-source?) (caddr r) (tp-left-recursive? (car r) rules))
      (error "rule " (car r) " has parameters and is left-recursive, which would overflow the stack with no memo for its arguments"))))

;; Direct patterns.  A list pattern is direct when each of its items is a literal atom, any element, or a direct rule
;; (one of this grammar's, with no parameters, whose whole pattern is `.:v -> e`), each perhaps bound to a name.  On a
;; list (a pair or ()) it is matched by walking the list: each element taken and its literal tested in turn, as the
;; stream path tests them, then the names bound and the rules' actions applied, so nothing runs for a pattern that fails.  Strings
;; and arrays, a dotted list, and a parser of a type derived from the grammar (which may redefine a direct rule) take
;; the stream path.  *tp-direct* off compiles every list pattern to the stream path (tpeg_direct compares the two).
(define *tp-direct* 1)
(define *tp-rules* ())	; the grammar being compiled: its rules, (name pattern parameters)

(define-function tp-direct-rule (name)	; (v e) when the rule is `.:v -> e`, else ()
  (let ((r (assq name *tp-rules*)))
    (and r (not (caddr r))
	 (let ((pe (cadr r)))
	   (and (= 'match-all (car pe)) (= 3 (list-length pe))
		(let ((a (cadr pe)) (x (caddr pe)))
		  (and (= 'assign-result (car a)) (equal '(match-any) (caddr a)) (= 'result-expr (car x))
		       (list (cadr a) (cadr x)))))))))

(define-function tp-direct-item (pe)	; (lit o), (any), (rule v e) or (bind name item), or () if pe isn't direct
  (cond ((and (= 'match-object (car pe)) (not (pair? (cadr pe))))	(list 'lit (cadr pe)))
	((equal '(match-any) pe)					'(any))
	((and (= 'match-rule (car pe)) (not (cddr pe)))		(let ((r (tp-direct-rule (cadr pe)))) (and r (cons 'rule r))))
	((= 'assign-result (car pe))				(let ((i (tp-direct-item (caddr pe)))) (and i (list 'bind (cadr pe) i))))))

(define-function tp-direct-items (exp)	; the items of a direct pattern, or () if it isn't one; '(()) for `( )
  (let* ((pes (if (= 'match-all (car exp)) (cdr exp) (list exp)))
	 (items (map tp-direct-item pes)))
    (cond ((not pes) '(()))
	  ((not (memq () items)) items))))

(define-function tp-direct-value (item e)	; item's value for element e
  (let ((k (car item)))
    (cond ((= k 'lit)	(list 'quote (cadr item)))
	  ((= k 'any)	e)
	  ((= k 'rule)	`(let ((,(cadr item) ,e)) ,(caddr item)))
	  (else		(tp-direct-value (caddr item) e)))))

(define-function tp-direct-literal (item)	; the literal item tests, or ()
  (cond ((= 'lit (car item))	(cadr item))
	((= 'bind (car item))	(tp-direct-literal (caddr item)))))

(define-function tp-direct-rules? (items)
  (let ((found ()))
    (list-do i items (and i (or (= 'rule (car i)) (and (= 'bind (car i)) (= 'rule (car (caddr i))))) (set found 1)))
    found))

(define-function tp-direct-pattern (items stream value?)
  (let ((items (if (equal items '(())) () items)) (temps ()) (walk ()) (binds ()) (n 0))
    (list-do item items
      (let ((e (concat-symbol '_e (concat-symbol (string->symbol (long->string n)) '_))))
	(push temps (list e ()))
	(push walk `(pair? _l_))
	(push walk `(let () (set ,e (car _l_)) (set _l_ (cdr _l_)) 1))
	(let ((lit (tp-direct-literal item))) (and lit (push walk `(in-same ,e ',lit))))	; as the stream tests it
	(cond ((= 'bind (car item))	(push binds `(set ,(cadr item) ,(tp-direct-value (caddr item) e))))
	      ((= 'rule (car item))	(push binds (tp-direct-value item e))))
	(set n (+ n 1))))
    `(let ((_l_ _v_) (_r_ 'stream) ,@(list-reverse! temps))
       (and (or (pair? _l_) (not _l_))
	    ,@(if (tp-direct-rules? items) `((= (type-of self) ,*tp-class*)) ())
	    (set _r_ (if (and ,@(list-reverse! walk) (not _l_))
			 (let () ,@(list-reverse! binds) 1)
		       (if (and _l_ (not (pair? _l_))) 'stream ()))))
       (if (= _r_ 'stream)
	   ,stream
	 (and _r_ (let ()
		    (set self.position (stream-tail _c_))
		    ,@(if value? '((set self.result _v_)) ())
		    1))))))

;; A list pattern enters the current element, when in-enter holds for it, and its nested pattern must
;; reach the end of that element's stream. The element is the value, and the input moves past it.
;; The nested pattern is inline, so its bindings are the rule's, and on failure the input is restored.
;; A direct pattern (tp-direct-items) on a list walks it instead, with car and cdr: no stream is made.
(define-function tp-list-pattern (exp pe-fn value?)
  (if (tp-source?)
      (let ((stream `(let ()
		       (set self.position (source-parser-stream-of self _v_))
		       (let ((_ok_ (and ,(pe-fn exp) (stream-end? self.position))))
			 (set self.position _c_)
			 (when _ok_
			   (set self.position (stream-tail _c_))
			   ,@(if value? '((set self.result _v_)) ())
			   1))))
	    (items (and *tp-direct* (tp-direct-items exp))))
	`(let ((_c_ self.position))
	   (when (and (not (stream-end? _c_)) (in-enter (stream-head _c_)))
	     (let ((_v_ (stream-head _c_)))
	       ,(if items (tp-direct-pattern items stream value?) stream)))))
      (error "rule " *tp-rule* " has a list pattern, which needs a grammar on <source-parser>")))

;; A choice dispatches on the head of the element in front of it.  An alternative whose first step enters a list
;; that starts with a literal symbol, `( 'add …), has that symbol for its key; the choice reads the element's head
;; once and tries only the alternatives keyed by it and those with no key, in their order.  in-same is identity on a
;; symbol, so an alternative passed over could not have matched; a head that isn't a symbol tries them all.  Without
;; this each alternative entered the element only to fail on its first literal: a lowering grammar's intent paid a
;; hash lookup per alternative.
(define-function tp-first-symbol (pe)
  (cond ((= (car pe) 'match-all)	(and (cdr pe) (tp-first-symbol (cadr pe))))
	((= (car pe) 'match-object)	(and (symbol? (cadr pe)) (cadr pe)))))
(define-function tp-head-key (pe)
  (cond ((= (car pe) 'match-all)	(and (cdr pe) (tp-head-key (cadr pe))))
	((= (car pe) 'assign-result)	(tp-head-key (caddr pe)))
	((= (car pe) 'match-list)	(tp-first-symbol (cadr pe)))))
(define-function tp-choice (exps pe-fn)
  (let ((keyed 0))
    (list-do e exps (and (tp-head-key e) (set keyed (+ keyed 1))))
    (if (or (< keyed 2) (not (tp-source?)))
	`(or ,@(map pe-fn exps))
      `(let ((_h_ (source-parser-head self)))
	 (or ,@(map (lambda (e)
		      (let ((k (tp-head-key e)))
			(if k `(and (or (not _h_) (= _h_ ',k)) ,(pe-fn e)) (pe-fn e))))
		    exps))))))

(define value-pe)
(define effect-pe)

(define-function value-pe (pe)
  (record-case pe
    (match-list		(exp)		(tp-list-pattern exp value-pe 1))
    (match-object	(obj)		(let () (tp-object-literal) `(,(tp-op 'match-object) self ',obj)))
    (match-rule		(name . args)	(or (tp-named-call name args '$)
					    (if args
					    `(,(tp-op 'invoke-rule-simply) ',name ,(concat-symbol '$ name) self ,@args)
					  `(,(tp-op 'invoke-rule) ',name ,(concat-symbol '$ name) self))))
    (match-rule-in	(grammar name)	(tp-foreign-call grammar name (concat-symbol '$ name)))
    (match-require	(exp alt)	`(or ,(value-pe exp) (,(tp-op 'expected) self ,alt)))
    (match-first	exps		(tp-choice exps value-pe))
    (match-all		exps		`(let ((pos self.position)) (unless (and ,@(mapN1 effect-pe value-pe exps)) (set self.position pos) ())))
    (match-zero-one	(exp)		`(let ((_list_ (array)))
					   (and ,(value-pe exp) (array-append _list_ self.result))
					   (set self.result (array->list _list_))
					   1))
    (match-zero-more	(exp)		`(let ((_list_ (array)))
					   (while ,(value-pe exp) (array-append _list_ self.result))
					   (set self.result (array->list _list_))
					   1))
    (match-one-more	(exp)		`(let ((_list_ (array)))
					   (when ,(value-pe exp)
					     (array-append _list_ self.result)
					     (while ,(value-pe exp) (array-append _list_ self.result))
					     (set self.result (array->list _list_))
					     1)))
    (peek-for		(exp)		`(let ((pos self.position))
					   (and ,(value-pe exp) (let () (set self.position pos) 1))))
    (peek-expr		(exp)		exp)
    (peek-not		(exp)		`(not (let ((pos self.position))
						(and ,(effect-pe exp) (let () (set self.position pos) 1)))))
    (match-class	(str)		(let ((len (string-length str)))
					  (cond
					    ((= len 0)	1)
					    ((= len 1)	`(,(tp-op 'match-object) self ,(string-at str 0)))
					    (else	`(,(tp-op 'match-class)  self ,(text-parser-make-class str))))))
    (match-string	(str)		(let ((len (string-length str)))
					  (cond
					    ((= len 0)	1)
					    ((= len 1)	`(,(tp-op 'match-char)   self ,(string-at str 0)))
					    (else	`(,(tp-op 'match-string) self ,str ,(string-length str))))))
    (match-any		()		`(,(tp-op 'match-any) self))
    (make-span		(exp)		`(let ((pos self.position))
					   (when ,(effect-pe exp)
					     (set self.result (,(tp-op 'list-from-to) self pos self.position))
					     1)))
    (make-string	(exp)		(record-case exp
					  (make-span (exp)	`(let ((pos self.position))
								   (when ,(effect-pe exp)
								     (set self.result (,(tp-op 'string-from-to) self pos self.position)))))
					  (else			`(and ,(value-pe exp) (set self.result (list->string self.result))))))
    (make-symbol	(exp)		(record-case exp
					  (make-span (exp)	`(let ((pos self.position))
								   (when ,(effect-pe exp)
								     (set self.result (string->symbol (,(tp-op 'string-from-to) self pos self.position))))))
					  (else			`(and ,(value-pe exp) (set self.result (string->symbol (list->string self.result)))))))
    (make-number	(r exp)		`(and ,(value-pe exp) (let () (set self.result (string->number-base (list->string self.result) ,r)) 1)))
    (assign-result	(name exp)	`(when ,(value-pe exp) (set ,name self.result) 1))
    (result-expr	(exp)		`(let () (set self.result ,exp) 1))
    (else				(error "cannot generate value for: "pe))))

(define-function effect-pe (pe)
  (record-case pe
    (match-list		(exp)		(tp-list-pattern exp effect-pe ()))
    (match-object	(obj)		(let () (tp-object-literal) `(,(tp-op 'match-object) self ',obj)))
    (match-rule		(name . args)	(or (tp-named-call name args '$$)
					    (if args
					    `(,(tp-op 'invoke-rule-simply) ',name ,(concat-symbol '$$ name) self ,@args)
					  `(,(tp-op 'invoke-rule) ',name ,(concat-symbol '$$ name) self))))
    (match-rule-in	(grammar name)	(tp-foreign-call grammar name (concat-symbol '$$ name)))
    (match-require	(exp alt)	`(or ,(effect-pe exp) (,(tp-op 'expected) self ,alt)))
    (match-first	exps		(tp-choice exps effect-pe))
    (match-all		exps		`(let ((pos self.position)) (unless (and ,@(map effect-pe exps)) (set self.position pos) ())))
    (match-zero-one	(exp)		`(if ,(effect-pe exp) 1 1))	; its value used, where typed code warns of none
    (match-zero-more	(exp)		`(let () (while ,(effect-pe exp)) 1))
    (match-one-more	(exp)		`(let ((_ok_ ()))
					   (while ,(effect-pe exp) (set _ok_ 1))
					   _ok_))
    (peek-for		(exp)		`(let ((pos self.position))
					   (and ,(effect-pe exp) (let () (set self.position pos) 1))))
    (peek-expr		(exp)		exp)
    (peek-not		(exp)		`(not (let ((pos self.position))
						(and ,(effect-pe exp) (let () (set self.position pos) 1)))))
    (match-class	(str)		(let ((len (string-length str)))
					  (cond
					    ((= len 0)	1)
					    ((= len 1)	`(,(tp-op 'match-object) self ,(string-at str 0)))
					    (else	`(,(tp-op 'match-class)  self ,(text-parser-make-class str))))))
    (match-string	(str)		(let ((len (string-length str)))
					  (cond
					    ((= len 0)	1)
					    ((= len 1)	`(,(tp-op 'match-object) self ,(string-at str 0)))
					    (else	`(,(tp-op 'match-string) self ,str ,(string-length str))))))
    (match-any		()		`(,(tp-op 'match-any) self))
    (make-span		(exp)		(effect-pe exp))
    (make-string	(exp)		(effect-pe exp))
    (make-symbol	(exp)		(effect-pe exp))
    (make-number	(r exp)		(effect-pe exp))
    (assign-result	(name exp)	`(when ,(value-pe exp) (set ,name self.result) 1))
    (result-expr	(exp)		`(let () ,exp 1))
    (else				(error "cannot generate effect for: "pe))))

(define-function find-vars-in (pe arr)
  (let ((op (car pe)))
    (cond
      ((or (= op 'match-first)
	   (= op 'match-all))		(list-do exp (cdr pe) (find-vars-in exp arr)))
      ((or (= op 'match-zero-one)
	   (= op 'match-zero-more)
	   (= op 'match-one-more)
	   (= op 'match-require)
	   (= op 'peek-for)
	   (= op 'peek-not)
	   (= op 'make-span)
	   (= op 'make-string)
	   (= op 'make-symbol))		(find-vars-in (cadr pe) arr))
      ((or (= op 'make-number))		(find-vars-in (caddr pe) arr))
      ((or (= op 'assign-result))	(array-append arr (cadr pe))
					(find-vars-in (caddr pe) arr))
      ((or (= op 'match-list))		(find-vars-in (cadr pe) arr))
      ((or (= op 'match-class)
	   (= op 'match-string)
	   (= op 'match-object)
	   (= op 'match-any)
	   (= op 'match-rule)
	   (= op 'match-rule-in)
	   (= op 'peek-expr)
	   (= op 'result-expr)))
      (else				(error "cannot find vars in: "pe)))))

(define-function find-vars (pe)
  (let ((arr  (array))
	(vars ()))
    (find-vars-in pe arr)
    (array-do var arr (or (member? var vars) (push vars var)))
    vars))

(define-function compile-value (rule class)
  (let ((name (car rule)))
    (when (member? name '(apply super))
      (error "rule name " name " is reserved by {apply} and {super}"))
    (set *tp-rule* name)
    (set *tp-class* class)
    (let* ((body (tp-parameters (caddr rule) (cadr rule)))
	   (vars (find-vars body)))
      `(define-method ,(concat-symbol '$ name) ,class ,(tp-method-parameters (caddr rule))
	 (let ,vars
	   ,(value-pe body))))))

(define-function compile-effect (rule class)
  (let ((name (car rule)))
    (set *tp-rule* name)
    (set *tp-class* class)
    (let* ((body (tp-parameters (caddr rule) (cadr rule)))
	   (vars (find-vars body)))
      `(define-method ,(concat-symbol '$$ name) ,class ,(tp-method-parameters (caddr rule))
	 (let ,vars
	   ,(effect-pe body))))))

;; (while *arguments*
;;   (let* ((spec   (parse-file <tpeg> $parser_spec (next-argument)))
;; 	 (decl   (caar spec))
;; 	 (rules  (cdr  spec))
;; 	 (names  (map car rules))
;; 	 (class  (or (car decl) "<text-parser>")))
;;     ;;(map dumpln grammar)
;;     ;;(println names)
;;     (println "(require \"text-parser.l\")")
;;     (println ";; "decl)
;;     (and decl (println "(define-class "(car decl)" "(cadr decl)" "(caddr decl)")"))
;;     (list-do name names (println "(define-selector $"name") (define-selector $$"name")"))
;;     (map-with compile-rule rules class)))

;; a grammar that stops parsing partway is an error, not a grammar that lost its remaining rules
(define-function tpeg-parse-whole-file (path)
  (let* ((source (contents-of-file-named path))
	 (p (text-parser-for-on <tpeg> source)))
    (or (text-parser-invoke-rule 'parser_spec $parser_spec p)
	(error "no grammar in "path))
    (let ((spec (<text-parser>-result p)))
      ($space p)
      (or (= (<text-parser>-position p) (<text-parser>-limit p))
	  (let ()
	    (print "\n"path": can't parse the grammar near: ")
	    (parser-context p)
	    (error "stopped parsing "path" before its end")))
      spec)))

;; The forms that define a grammar's rules on class: a selector for each rule's match and its effect, then the methods.
(define-function tp-definition-forms (class rules)
  (set *tp-rules* rules)
  (let ((names (map car rules)))
    (and (tp-source?) (tp-check-parameters rules))
    `(,@(map (lambda (name) (list 'define-selector (concat-symbol '$  name))) names)
      ,@(map (lambda (name) (list 'define-selector (concat-symbol '$$ name))) names)
      ,@(map-with compile-value  rules class)
      ,@(map-with compile-effect rules class)
      (grammar-register ',class ,class ',rules))))	; its definition, to be reflected on (grammar.l)

(define-function parse-and-compile-grammar (path)
  (let* ((spec   (tpeg-parse-whole-file path))
	 (decl   (caar spec))
	 (rules  (cdr  spec))
	 (class  (or (car decl) "<text-parser>")))
    (set *tpeg-source* (= '<source-parser> (cadr decl)))
    ;;(print "DEFINITION: ") (map dumpln decl)
    ;;(print "RULES: ") (map dumpln rules)
    `((require ,(if (tp-source?) "source-parser.l" "text-parser.l"))
      ,(and decl (list 'define-class (car decl) (cadr decl) (caddr decl)))
      ,@(tp-definition-forms class rules)
      )))

;; In process, a grammar's parser type is its class's ancestry, so a child of <source-parser> runs on source.
;; The base chain comes from boot's %structure-bases; <source-parser> is absent until its file is loaded.
(define-function tp-derives? (type base)
  (and type (or (= type base) (tp-derives? (array-at %structure-bases type) base))))

(define-function tp-source-type ()
  (and (defined? '<source-parser>) (eval '<source-parser>)))

;; Compiles rules onto class, a grammar already defined, and evaluates the forms it compiles to.
(define-function tpeg-define-rules (class rules)
  (set *tpeg-source* (tp-derives? (eval class) (tp-source-type)))
  (list-do form (tp-definition-forms class rules) (eval form))
  class)

;; Defines a grammar from its declaration, (name parent fields), and its rules.
(define-function tpeg-define (decl rules)
  (or decl (error "a grammar needs a declaration, <name> : <parent> ()"))
  (eval `(define-class ,(car decl) ,(cadr decl) ,(caddr decl)))
  (tpeg-define-rules (car decl) rules))

;; tpeg-load compiles a .g file in process; its parent must already be loaded.
(define-function tpeg-load (path)
  (let ((spec (tpeg-parse-whole-file path)))
    (tpeg-define (caar spec) (cdr spec))))

(or (defined? 'compile-tpeg-definitions-only)
    (while *arguments*
      (map dumpln (parse-and-compile-grammar (next-argument)))))
