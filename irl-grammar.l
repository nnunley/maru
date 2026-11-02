;;; irl-grammar.l -- an irl grammar block's tpeg records as typed Maru (draft-ndn-maru-sat-00
;;; [R-irl-grammar]).
;;;
;;;   (irl-grammar-forms record)	maru.k forms for one (grammar-define <G> <parent> (fields) rules...)
;;;
;;; A grammar G becomes a struct G (input pos end result, then its fields, each a long) and
;;; one function per rule, long G_rule(struct G* p): 1 with p.pos after the match and p.result
;;; set, or 0 with p.pos as it was.  An action is a maru.k form, copied in unchanged; it sees p
;;; and the rule's :x locals.  Rules the block doesn't define come from its parent, so an
;;; inherited rule calls the child's override.  No memos, no left recursion, no lists.

(define *irl-grammars* ())	; (G fields rules) for each block so far
(define *irl-g* ())		; the grammar and rule being generated, for errors
(define *irl-r* ())
(define *irl-temps* 0)

(define-function irl-grammar-name (sym)	; <sums> -> sums
  (let ((s (symbol->string sym))) (string->symbol (string-copy s 1 (- (string-length s) 2)))))
(define-function irl-grammar-fail (what) (error "irl grammar: " *irl-g* "." *irl-r* ": " what))
(define-function irl-temp () (set *irl-temps* (+ *irl-temps* 1)) (string->symbol (concat-string "_g" (format "%d" *irl-temps*))))
(define-function irl-rule-fn (rule) (string->symbol (concat-strings (symbol->string *irl-g*) "_" (symbol->string rule))))

;; the parser's state, and the input at a position, as longs
(define irl-pos '(member p pos))
(define-function irl-set-pos (v) `(set-member p pos ,v))
(define-function irl-long (n) `(cast ,n long))
(define-function irl-char-at (i) `(cast (indir (member p input) ,i) long))
(define-function irl-advance (n) `(let () ,(irl-set-pos `(+ ,irl-pos ,(irl-long n))) 1))

;; a character class's ranges, as tpeg's class strings write them: a-z or one character
(define-function irl-class-ranges (s)
  (let ((out ()) (i 0) (l (string-length s)))
    (while (< i l)
      (if (and (< (+ i 2) l) (= ?- (string-at s (+ i 1))))
	  (let () (push out (cons (string-at s i) (string-at s (+ i 2)))) (set i (+ i 3)))
	(push out (cons (string-at s i) (string-at s i)))
	(set i (+ i 1))))
    (list-reverse! out)))

;; each record's generator, by its head: an expression that is 1 if it matched, else 0
(define irl-pe)
(define-function irl-pe-all (es)
  (if (not (cdr es)) (irl-pe (car es))
    (let ((s (irl-temp)))
      `(let (((,s long) ,irl-pos)) (if (and ,@(map irl-pe es)) 1 (let () ,(irl-set-pos s) 0))))))
(define-function irl-pe-number (r e)	; the digits a span matched, in base r, a leading - negating
  (or (= 'make-span (car e)) (irl-grammar-fail "a number converts only a span"))
  (let ((s (irl-temp)) (i (irl-temp)) (v (irl-temp)) (c (irl-temp)) (neg (irl-temp)))
    `(let (((,s long) ,irl-pos))
       (if ,(irl-pe (cadr e))
	   (let (((,i long) ,s) ((,v long) ,(irl-long 0)) ((,neg long) ,(irl-long 0)) ((,c long) ,(irl-long 0)))
	     (if (and (< ,i ,irl-pos) (= ,(irl-char-at i) ,(irl-long 45))) (let () (set ,neg ,(irl-long 1)) (set ,i (+ ,i ,(irl-long 1)))))
	     (while (< ,i ,irl-pos)
	       (set ,c ,(irl-char-at i))
	       (set ,v (+ (* ,v ,(irl-long r)) (if (<= ,c ,(irl-long 57)) (- ,c ,(irl-long 48)) (- (| ,c ,(irl-long 32)) ,(irl-long 87)))))
	       (set ,i (+ ,i ,(irl-long 1))))
	     (set-member p result (if ,neg (- ,(irl-long 0) ,v) ,v))
	     1)
	 0))))
(define-function irl-pe-string (str)
  (let ((n (string-length str)) (conds ()))
    (if (= 0 n) 1
      (for (k 0 n)
	(push conds `(< (+ ,irl-pos ,(irl-long k)) (member p end)))
	(push conds `(= ,(irl-char-at `(+ ,irl-pos ,(irl-long k))) ,(irl-long (string-at str k)))))
      `(if (and ,@(list-reverse! conds)) ,(irl-advance n) 0))))
(define-function irl-pe-class (str)
  (let ((c (irl-temp)))
    `(if (< ,irl-pos (member p end))
	 (let (((,c long) ,(irl-char-at irl-pos)))
	   (if (or ,@(map (lambda (r) `(and (>= ,c ,(irl-long (car r))) (<= ,c ,(irl-long (cdr r))))) (irl-class-ranges str)))
	       ,(irl-advance 1) 0))
       0)))
(define *irl-pe-table*
  `((match-all		. ,(lambda (pe) (irl-pe-all (cdr pe))))
    (match-first	. ,(lambda (pe) `(if (or ,@(map irl-pe (cdr pe))) 1 0)))
    (match-string	. ,(lambda (pe) (irl-pe-string (cadr pe))))
    (match-class	. ,(lambda (pe) (irl-pe-class (cadr pe))))
    (match-any		. ,(lambda (pe) `(if (< ,irl-pos (member p end)) ,(irl-advance 1) 0)))
    (match-rule		. ,(lambda (pe) (if (cddr pe) (irl-grammar-fail "a rule with arguments has no typed form")
					  `(if (!= (,(irl-rule-fn (cadr pe)) p) ,(irl-long 0)) 1 0))))
    (match-zero-one	. ,(lambda (pe) `(if ,(irl-pe (cadr pe)) 1 1)))	; its value used, so ir2 sees an effect
    (match-zero-more	. ,(lambda (pe) `(let () (while ,(irl-pe (cadr pe))) 1)))
    (match-one-more	. ,(lambda (pe) `(if ,(irl-pe (cadr pe)) (let () (while ,(irl-pe (cadr pe))) 1) 0)))
    (peek-for		. ,(lambda (pe) (let ((s (irl-temp))) `(let (((,s long) ,irl-pos)) (if ,(irl-pe (cadr pe)) (let () ,(irl-set-pos s) 1) 0)))))
    (peek-not		. ,(lambda (pe) (let ((s (irl-temp))) `(let (((,s long) ,irl-pos)) (if ,(irl-pe (cadr pe)) (let () ,(irl-set-pos s) 0) 1)))))
    (peek-expr		. ,(lambda (pe) `(if ,(cadr pe) 1 0)))
    (assign-result	. ,(lambda (pe) `(if ,(irl-pe (caddr pe)) (let () (set ,(cadr pe) (member p result)) 1) 0)))
    (result-expr	. ,(lambda (pe) `(let () (set-member p result (cast ,(cadr pe) long)) 1)))
    (make-number	. ,(lambda (pe) (irl-pe-number (cadr pe) (caddr pe))))))
(define-function irl-pe (pe)
  (let ((g (cdr (assq (car pe) *irl-pe-table*))))
    (if g (g pe) (irl-grammar-fail (concat-string (symbol->string (car pe)) " has no typed value")))))

;; the :x locals a rule binds
(define-function irl-pe-vars (pe out)
  (and (pair? pe) (= 'assign-result (car pe)) (not (member? (cadr pe) out)) (push out (cadr pe)))
  (and (pair? pe) (not (member? (car pe) '(result-expr peek-expr)))
       (list-do x (cdr pe) (set out (irl-pe-vars x out))))
  out)

;; left recursion: the rules a rule can call before it consumes anything
(define-function irl-nullable? (pe)
  (let ((h (car pe)))
    (cond ((member? h '(match-zero-one match-zero-more peek-for peek-not peek-expr result-expr)) 1)
	  ((= h 'match-string) (= 0 (string-length (cadr pe))))
	  ((= h 'match-all) (let ((r 1)) (list-do e (cdr pe) (or (irl-nullable? e) (set r ()))) r))
	  ((= h 'match-first) (let ((r ())) (list-do e (cdr pe) (and (irl-nullable? e) (set r 1))) r))
	  ((member? h '(match-one-more make-span make-string make-symbol)) (irl-nullable? (cadr pe)))
	  ((member? h '(assign-result make-number)) (irl-nullable? (caddr pe)))
	  (else ()))))
(define-function irl-left-calls (pe)
  (let ((h (car pe)))
    (cond ((= h 'match-rule) (list (cadr pe)))
	  ((= h 'match-all) (let ((out ()) (go 1))
			      (list-do e (cdr pe) (and go (let () (set out (concat-list out (irl-left-calls e))) (or (irl-nullable? e) (set go ())))))
			      out))
	  ((= h 'match-first) (let ((out ())) (list-do e (cdr pe) (set out (concat-list out (irl-left-calls e)))) out))
	  ((member? h '(match-zero-one match-zero-more match-one-more peek-for peek-not make-span make-string make-symbol)) (irl-left-calls (cadr pe)))
	  ((member? h '(assign-result make-number)) (irl-left-calls (caddr pe)))
	  (else ()))))
(define-function irl-left-recursive? (rule rules)	; rule reaches itself through left calls
  (let ((seen ()) (todo (irl-left-calls (cadr (assq rule rules)))) (found ()))
    (while (and todo (not found))
      (let ((r (car todo)))
	(set todo (cdr todo))
	(if (= r rule) (set found 1)
	  (or (member? r seen)
	      (let ((d (assq r rules))) (push seen r) (and d (set todo (concat-list todo (irl-left-calls (cadr d))))))))))
    found))

(define-function irl-grammar-forms (record)	; (grammar-define <G> <parent> (fields) (rule pe args)...)
  (let* ((g (irl-grammar-name (cadr record)))
	 (parent (caddr record))
	 (own (cddddr record))
	 (base (if (= parent '<text-parser>) (list () ())
		 (or (cdr (assq (irl-grammar-name parent) *irl-grammars*)) (error "irl grammar: " g ": no grammar block " parent))))
	 (fields (concat-list (car base) (cadddr record)))
	 (rules ()))
    (list-do r (cadr base) (or (assq (car r) own) (push rules r)))
    (set rules (concat-list (list-reverse! rules) own))
    (push *irl-grammars* (list g fields rules))
    (set *irl-g* g)
    (cons `(define-struct ,g ((input char *) (pos long) (end long) (result long) ,@(map (lambda (f) (list f 'long)) fields)))
	  (map (lambda (r)
		 (set *irl-r* (car r))
		 (and (irl-left-recursive? (car r) rules) (error "irl grammar: " g "." (car r) " is left-recursive"))
		 `(define-function ,(irl-rule-fn (car r)) (long) ((p struct ,g *))
		    (let ,(map (lambda (v) `((,v long) ,(irl-long 0))) (irl-pe-vars (cadr r) ()))
		      (return (cast ,(irl-pe (cadr r)) long)))))
	       rules))))
