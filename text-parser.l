(require "ansiterm.l")
(require "input.l")

(define-structure <text-parser> (string limit position memos refill result foreign))	; foreign: ((type . parser)...)

(define-function text-parser-refill-default (self len) ())

(define-function text-parser-for-on (class str)
  (new class str (string-length str) 0 (array) text-parser-refill-default))

;; a parser on any source, positioned at the source's start. A string keeps the direct path below.
(define-function text-parser-for-source (class source)
  (new class source (in-limit source) (in-start source) (array) text-parser-refill-default))

;; through the input selectors, for a source that isn't a string
(define-function text-parser-at-end (self)
  (in-at-end (<text-parser>-string self) (<text-parser>-position self)))
(define-function text-parser-head (self)
  (in-head (<text-parser>-string self) (<text-parser>-position self)))
(define-function text-parser-tail (self)
  (in-tail (<text-parser>-string self) (<text-parser>-position self)))

(define text-parser-match-any
  (define-method parser-match-any <text-parser> ()
    (if (string? self.string)
	(when (or (< self.position self.limit) (self.refill self 1))
	  (set self.result (string-at self.string self.position))
	  (incr self.position))
      (when (not (text-parser-at-end self))
	(let ()
	  (set self.result (text-parser-head self))
	  (set self.position (text-parser-tail self))
	  1)))))

(define text-parser-make-class
  (define-function parser-make-class (s)
    (let* ((out (array))
	   (i   0)
	   (l   (string-length s))
	   (k   (- l 2)))
      (while (< i k)
	(let ((c (string-at s i))
	      (d (string-at s (+ i 1))))
	  (if (= ?- d)
	      (let ((e (string-at s (+ i 2))))
		(if (<= c e)
		    (if (<= (- e c) 2048)
			(for (d c (+ e 1)) (array-append out d))
		      (error "character range too large: "c"-"e))
		  (error "malformed character range: "c"-"e))
		(set i (+ i 3)))
	    (array-append out c)
	    (set i (+ i 1)))))
      (while (< i l)
	(array-append out (string-at s i))
	(set i (+ i 1)))
      (let ((c (array->string (array-sort out))))
	c))))

(define text-parser-match-class
  (define-method parser-match-class <text-parser> (class)
    (if (string? self.string)
	(when (or (< self.position self.limit) (self.refill self 1))
	  (let ((c (string-at self.string self.position)))
	    (and c
		 (let ((i (string-search class c)))
		   (and i
			(<= 0 i)
			(set self.result c)
			(incr self.position))))))
      (when (not (text-parser-at-end self))
	(let ((c (text-parser-head self)))
	  (when (in-class c class)
	    (let ()
	      (set self.result c)
	      (set self.position (text-parser-tail self))
	      1)))))))

(define text-parser-match-object
  (define-method parser-match-object <text-parser> (obj)
    (if (string? self.string)
	(when (and (or (< self.position self.limit) (self.refill self 1))
		   (= obj (string-at self.string self.position)))
	  (set self.result obj)
	  (incr self.position))
      (when (and (not (text-parser-at-end self))
		 (in-same (text-parser-head self) obj))
	(let ()
	  (set self.result (text-parser-head self))
	  (set self.position (text-parser-tail self))
	  1)))))

(define text-parser-match-char
  (define-method parser-match-object <text-parser> (obj)
    (if (string? self.string)
	(when (and (or (< self.position self.limit) (self.refill self 1))
		   (= obj (string-at self.string self.position)))
	  (set self.result (string-copy self.string self.position 1))
	  (incr self.position))
      (when (and (not (text-parser-at-end self))
		 (in-same (text-parser-head self) obj))
	(let ()
	  (set self.result (list->string (list (text-parser-head self))))
	  (set self.position (text-parser-tail self))
	  1)))))

;; consecutive elements from a non-string source, matched all or nothing: the position moves only on success
(define-function text-parser-match-elements (self string len)
  (let* ((source (<text-parser>-string self))
	 (pos    (<text-parser>-position self))
	 (i      0)
	 (ok     1))
    (while (and ok (< i len))
      (if (and (not (in-at-end source pos))
	       (in-same (in-head source pos) (string-at string i)))
	  (let ()
	    (set pos (in-tail source pos))
	    (incr i))
	(set ok ())))
    (when ok
      (let ()
	(set (<text-parser>-result self) string)
	(set (<text-parser>-position self) pos)
	1))))

(define text-parser-match-string
  (define-method parser-match-string <text-parser> (string len)
    (if (string? self.string)
	(when (and (or (<= (+ self.position len) self.limit) (self.refill self len))
		   (= 0 (string-compare self.string string self.position len)))
	  (set self.result string)
	  (incr self.position len))
      (text-parser-match-elements self string len))))

(define text-parser-list-from-to
  (define-method parser-list-from-to <text-parser> (from to)
    (if (string? self.string)
	(let ((result (array)))
	  (for (i from to)
	    (array-append result (string-at self.string i)))
	  (array->list result))
      (in-span self.string from to))))

(define text-parser-string-from-to
  (define-method parser-string-from-to <text-parser> (from to)
    (if (string? self.string)
	(string-copy self.string from (- to from))
      (list->string (in-span self.string from to)))))

(define text-parser-current-line-number
  (define-method parser-current-line-number <text-parser> ()
    (let ((line 1))
      (for (i 0 self.position)
        (and (= ?\n (string-at self.string i))
	     (incr line)))
      line)))

(define text-parser-context-with
  (define-method parser-context-with <text-parser> (message)
    (let ((start self.position)
	  (stop  self.position))
      (while (and (> start 0         ) ( = ?\n (string-at self.string (- start 1)))) (decr start))
      (while (and (> start 0         ) (!= ?\n (string-at self.string (- start 1)))) (decr start))
      (while (and (< stop  self.limit) ( = ?\n (string-at self.string stop))) (incr stop ))
      (while (and (< stop  self.limit) (!= ?\n (string-at self.string stop))) (incr stop ))
      (concat-strings
        RESET
        (string-copy self.string start (- self.position start))
	FG-RED BOLD"<-- "message" -->"RESET
	(string-copy self.string self.position (- stop self.position))))))

(define text-parser-context
  (define-method parser-context <text-parser> ()
    (text-parser-context-with self "here")))

(define text-parser-expected
  (define-method parser-expected <text-parser> (what)
    (error "at line "(format "%d"(text-parser-current-line-number self))":\n"(text-parser-context-with self (concat-string what" expected")))))

;;; ----

(define-form put (where key val)	`(set ,where (cons (cons ,key ,val) ,where)))
(define-form get (where key)		`(cdr (assq ,key ,where)))
;; (define-form del (where key)		`(set ,where (%del ,where ,key)))

;; (define-function %del (where key)
;;   (and (pair? where)
;;        (if (= key (caar where))
;; 	   (cdr where)
;; 	 (cons (car where) (%del (cdr where) key)))))

(define-form set-list-source (list source)	list)

(define-structure <memo> (state result position))

(define-method do-print <memo> ()
  (print "<memo:"self.state">"))

(define-function memo-set (self state result position)
  (with-instance-accessors <memo>
    (set self.result   result)
    (set self.position position)
    (set self.state    state)))

(define *succeeded*	'(*succeeded*))
(define *failed*	'(*failed*))
(define *active*	'(*active*))
(define *recurred*	'(*recurred*))


;;(define-form text-parser-source-range-begin (self)	`(push (<text-parser>-positions self) (<text-parser>-position ,self)))
;;(define-form text-parser-source-range-end (self)	`(pop (<text-parser>-positions ,self)))

(define-function text-parser-invoke-rule-simply-with (name rule self args)
  (apply rule (cons self args)))

(define-function text-parser-invoke-rule-simply (name rule self . args)
  (apply rule (cons self args)))

(define-function text-parser-invoke-rule-with-memo (name rule self . args)
  ;;(println "; memoised "name" "self)
  (let* ((here  (<text-parser>-position self))
	 (memos (<text-parser>-memos self))
	 (memo  (get (array-at memos here) rule)))
    ;;(println "; memo "memo)
    (cond
      (memo	(and (= *succeeded* (<memo>-state memo))
		     (let ()
		       (set (<text-parser>-result self) (<memo>-result memo))
		       (set (<text-parser>-position self) (<memo>-position memo)))))
      (else	(put (array-at memos here) rule (set memo (new <memo>)))
		(if (text-parser-invoke-rule-simply-with name rule self args)
		    (memo-set memo *succeeded* (<text-parser>-result self) (<text-parser>-position self))
		  (set (<memo>-state memo) *failed*)
		  ())))))

(define-function text-parser-invoke-rule-with-recursion (name rule self . args)
  (let* ((posn   (<text-parser>-position self))
	 (memos  (<text-parser>-memos self))
	 (memo   (get (array-at memos posn) rule)))
    (if memo
	;; this rule has already been entered at this position and has either succeeded, failed, or is in left-recursive iteration
	(let ((state  (<memo>-state  memo))
	      (result (<memo>-result memo)))
	  (cond
	    ((= state *succeeded*)	(set (<text-parser>-result  self) (<memo>-result   memo))
					(set (<text-parser>-position self) (<memo>-position memo)))
	    ((= state *active*)		(set (<memo>-state memo) *recurred*)
					())
	    (else			())))
      ;; this rule has not been entered at this position
      (put (array-at memos posn) rule (set memo (new <memo> *active* () posn)))
      (if (text-parser-invoke-rule-simply-with name rule self args)
	  ;; rule succeeded without recursion or entered recursion and found a non-recursive initial prefix
	  (let ((state (<memo>-state memo)))
	    (memo-set memo *succeeded* (<text-parser>-result self) (<text-parser>-position self))
	    (if (= state *recurred*)
		(let ()
		  (set (<text-parser>-position self) posn)	;; rewind to start of recursive match
		  (while (and (text-parser-invoke-rule-simply-with name rule self args)
			      (< (<memo>-position memo) (<text-parser>-position self)))	;; grow the prefix recursively
		    (set (<memo>-result   memo) (<text-parser>-result self))
		    (set (<memo>-position memo) (<text-parser>-position self))
		    (set (<text-parser>-position self) posn))
		  ;;(del (array-at memos posn) name)
		  (set (<text-parser>-result self) (<memo>-result memo))			;; store the final result when recursion fails to grow prefix
		  (set (<text-parser>-position self) (<memo>-position memo)))
	      (or (= state *active*) (error "unknown parser state after recursion: "state))))
	(set (<memo>-state memo) *failed*)
	()))))

(define text-parser-invoke-rule text-parser-invoke-rule-simply)

;; a foreign call, p-r: rule r of grammar type on the same input from the same position, through
;; a parser of that type kept for the caller, so its memos are its own and last the whole parse
(define-function text-parser-invoke-rule-in (self type name rule)
  (let ((sub (cdr (assq type (<text-parser>-foreign self)))))
    (or sub (let ()
	      (set sub (new type (<text-parser>-string self) (<text-parser>-limit self) 0 (array) (<text-parser>-refill self)))
	      (set (<text-parser>-foreign self) (cons (cons type sub) (<text-parser>-foreign self)))))
    (set (<text-parser>-string sub) (<text-parser>-string self))	;; the source can change between calls
    (set (<text-parser>-limit sub) (<text-parser>-limit self))
    (set (<text-parser>-position sub) (<text-parser>-position self))
    (and (text-parser-invoke-rule name rule sub)
	 (let ()
	   (set (<text-parser>-position self) (<text-parser>-position sub))
	   (set (<text-parser>-result self) (<text-parser>-result sub))
	   1))))
;;(define text-parser-invoke-rule text-parser-invoke-rule-with-memo)
;;(define text-parser-invoke-rule text-parser-invoke-rule-with-recursion)

(define-function peg-disable-memoisation ()	(println "; PEG memoisation disabled")	(set text-parser-invoke-rule text-parser-invoke-rule-simply))
(define-function peg-enable-memoisation ()	(println "; PEG memoisation enabled")	(set text-parser-invoke-rule text-parser-invoke-rule-with-memo))
(define-function peg-enable-recursion ()	(println "; PEG recursion enabled")	(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion))

(define-function parse-source (grammar rule source)
  (let ((p (text-parser-for-source grammar source)))
    (or (text-parser-invoke-rule (<selector>-name rule) rule p)	; so a left-recursive entry rule grows
	(let ()
	  (print "\nfailed to parse with gramamr "(name-of-type grammar)"."(<selector>-name rule)" near: ")
	  (and (string? source) (parser-context p))	; the context only reads a string
	  (error "abort")))
    (<text-parser>-result p)))

(define-function parse-string (grammar rule source)
  (parse-source grammar rule source))

(define-function parse-file (grammar rule path)
  (let* ((source (contents-of-file-named path))
	 (result (parse-string grammar rule source)))
    result))
