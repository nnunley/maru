;;; compile-irl.l									-*- coke -*-
;;;
;;; ./eval compile-irl.l <filename>.irl > <filename>.k
;;; ./eval compile-irl.l --library <a>.irl <b>.irl ... > <lib>.k	(no main: definitions only)

(require "text-parser.l")

(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)

(define-function irl-concat (lists)
  (let ((all ()))
    (list-do l lists (set all (concat-list all l)))
    all))

(define irl-varargs '(...))

(define-function irl-last (l)	(if (cdr l) (irl-last (cdr l)) (car l)))

(define-function irl-assign (place value)
  (cond
    ((symbol? place)		`(set ,place ,value))
    ((= 'indir  (car place))	`(set-indir  ,@(cdr place) ,value))
    ((= 'member (car place))	`(set-member ,@(cdr place) ,value))
    (else			(error "cannot assign to: "place))))

(require "tpeg.l")		; grammar blocks are read with tpeg's own rules
(require "cexpr.g.l")
(require "irl.g.l")
(require "irl-grammar.l")

(define *irl-structs*   ())	; (name field...) for each struct so far
(define *irl-functions* ())	; imported functions, already pointers
(define *irl-imports* ())	; (name . declaration) for each import so far
(define *irl-defined* ())	; each function defined so far: a second definition would replace the first silently
(define-function irl-define (form)
  (and (pair? form) (= 'define-function (car form))
       (let ()
	 (and (member? (cadr form) *irl-defined*) (error "irl: " (cadr form) " is defined twice"))
	 (push *irl-defined* (cadr form))))
  form)

(define irl-expand)

;; In a body, (irl-let decl e) scopes decl over the statements after it.
(define-function irl-body (statements)
  (and statements
       (let ((s (car statements)))
	 (if (and (pair? s) (= 'irl-let (car s)))
	     (list `(let ((,(cadr s) ,(irl-expand (caddr s)))) ,@(irl-body (cdr statements))))
	   (cons (irl-expand s) (irl-body (cdr statements)))))))

(define-function irl-expand (form)
  (cond
    ((not (pair? form))		form)
    ((= 'let (car form))	`(let ,(map (lambda (b) (list (car b) (irl-expand (cadr b)))) (cadr form))
				   ,@(irl-body (cddr form))))
    ((= 'irl-struct (car form))	(let ((fields (cdr (or (assq (cadr form) *irl-structs*) (error "no such struct: "(cadr form))))))
				  `(let (((_s struct ,(cadr form))))
				     ,@(map (lambda (f v) `(set-member _s ,f ,(irl-expand v))) fields (cddr form))
				     _s)))
    ((and (= 'addressof (car form)) (member? (cadr form) *irl-functions*))
				(cadr form))
    (else			(map irl-expand form))))

(define-function irl-literal? (e)	(or (long? e) (double? e) (string? e)))

;; Definitions stay at top level, in order; every other statement, and the
;; assignment of each computed initialiser, goes in main.  A library has no main, so there
;; either is an error naming the file.
(define *irl-library* ())	; the file being read in library mode, or ()
(define-function irl-main (form)
  (and *irl-library* (error "irl library: top-level statement in " *irl-library* ": " form))
  form)
(define-function irl-program (forms)
  (let ((defs ()) (main ()))
    (list-do f forms
      (let ((head (and (pair? f) (car f))))
	(cond
	  ((= head 'export)		(push defs f))
	  ((= head 'grammar-define)	(list-do g (irl-grammar-forms f) (push defs (irl-define g))))
	  ((= head 'define-struct)	(push *irl-structs* (cons (cadr f) (map car (caddr f))))
					(push defs f))
	  ((= head 'define-function)	(push defs (irl-define `(define-function ,(cadr f) ,(caddr f) ,(cadddr f) ,@(irl-body (cddddr f))))))
	  ((and (= head 'define) (pair? (caddr f)) (= 'extern (car (caddr f))))
					(let ((decl (cadr f)) (seen (assq (car (cadr f)) *irl-imports*)))
					  (when (pair? (irl-last decl))
					    (push *irl-functions* (car decl))
					    (set decl (concat-list decl '(*))))
					  ;; files of one library may import a name alike once each
					  (if seen (or (equal (cdr seen) decl) (error "irl: " (car decl) " imported with two types"))
					    (push *irl-imports* (cons (car decl) decl))
					    (push defs `(define ,decl ,(caddr f))))))
	  ((and (= head 'define) (= 0 (caddr f)))	; a global starts at zero (check zero_global), as ir2 can't initialise one
					(push defs `(define ,(cadr f))))
	  ((and (= head 'define) (irl-literal? (caddr f)))
					(push defs f))
	  ((= head 'define)		(push defs `(define ,(cadr f)))
					(push main (irl-main `(set ,(car (cadr f)) ,(irl-expand (caddr f))))))
	  (else				(push main (irl-main f))))))
    (if *irl-library* (list-reverse! defs)
      (concat-list (list-reverse! defs)
		   `((define-function main int () ,@(irl-body (list-reverse! main)) (return 0)))))))

(define irl-library-mode ())
(while *arguments*
  (let ((file (next-argument)))
    (if (= file "--library") (set irl-library-mode 1)
      (let ((parser (text-parser-for-on <irl> (contents-of-file-named file))))
	(or ($program parser) (error "syntax error"))
	(and irl-library-mode (set *irl-library* file))
	(list-do form (irl-program (<irl>-result parser)) (dumpln form))))))
