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
;; what a global can be initialised with at its definition, where maru.k evaluates it as it compiles: a literal,
;; negated, or cast (C converts it there anyway, so the cast is dropped)
(define-function irl-constant? (e)
  (or (irl-literal? e)
      (and (pair? e) (= '- (car e)) (not (cddr e)) (irl-constant? (cadr e)))
      (and (pair? e) (= 'cast (car e)) (irl-constant? (cadr e)))))
(define-function irl-constant (e) (if (and (pair? e) (= 'cast (car e))) (irl-constant (cadr e)) e))

;; Definitions stay at top level, in order, a global's constant initialiser with it; every other
;; statement, and the assignment of each computed initialiser, goes in main.  A library has no main, so there
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
	  ((and (= head 'define) (irl-constant? (caddr f)))
					(push defs `(define ,(cadr f) ,(irl-constant (caddr f)))))
	  ((= head 'define)		(push defs `(define ,(cadr f)))
					(push main (irl-main `(set ,(car (cadr f)) ,(irl-expand (caddr f))))))
	  (else				(push main (irl-main f))))))
    ;; a program that defines main keeps it, and then has no top-level statements to run; otherwise main runs them
    (let ((own (let ((found ())) (list-do f forms (and (pair? f) (= 'define-function (car f)) (= 'main (cadr f)) (set found 't))) found)))
      (and own main (error "irl: a program defines main and also has top-level statements: " (car (list-reverse! main))))
      (if (or *irl-library* own) (list-reverse! defs)
	(concat-list (list-reverse! defs)
		     `((define-function main int () ,@(irl-body (list-reverse! main)) (return 0))))))))

(define-function irl-file-forms (file library)	; a file's maru.k forms; library: definitions only
  (let ((parser (text-parser-for-on <irl> (contents-of-file-named file))))
    (or ($program parser) (error "syntax error"))
    (and library (set *irl-library* file))
    (irl-program (<irl>-result parser))))
(define-function irl-library-forms (files)	; one library's forms, from all its files, in memory
  (let ((out ()))
    (list-do file files
      (list-do form (irl-file-forms file 1) (push out form)))
    (list-reverse! out)))

;; as a command, the forms of each file named, printed; required, with no arguments left, it
;; only defines the functions above (compile-irl-library.l)
(define irl-library-mode ())
(while *arguments*
  (let ((file (next-argument)))
    (if (= file "--library")
	(set irl-library-mode 1)
      (list-do form (irl-file-forms file irl-library-mode) (dumpln form)))))
