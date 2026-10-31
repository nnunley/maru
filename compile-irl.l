;;; compile-irl.l									-*- coke -*-
;;;
;;; ./eval compile-irl.l <filename>.irl > <filename>.k
;;; ./eval2 ir-gen-c.k maru.k <filename>.k > <filename>.c

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

(require "cexpr.g.l")
(require "irl.g.l")

(define *irl-structs*   ())	; (name field...) for each struct so far
(define *irl-functions* ())	; imported functions, already pointers

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
;; assignment of each computed initialiser, goes in main.
(define-function irl-program (forms)
  (let ((defs ()) (main ()))
    (list-do f forms
      (let ((head (and (pair? f) (car f))))
	(cond
	  ((= head 'define-struct)	(push *irl-structs* (cons (cadr f) (map car (caddr f))))
					(push defs f))
	  ((= head 'define-function)	(push defs `(define-function ,(cadr f) ,(caddr f) ,(cadddr f) ,@(irl-body (cddddr f)))))
	  ((and (= head 'define) (pair? (caddr f)) (= 'extern (car (caddr f))))
					(let ((decl (cadr f)))
					  (when (pair? (irl-last decl))
					    (push *irl-functions* (car decl))
					    (set decl (concat-list decl '(*))))
					  (push defs `(define ,decl ,(caddr f)))))
	  ((and (= head 'define) (irl-literal? (caddr f)))
					(push defs f))
	  ((= head 'define)		(push defs `(define ,(cadr f)))
					(push main `(set ,(car (cadr f)) ,(irl-expand (caddr f)))))
	  (else				(push main f)))))
    (concat-list (list-reverse! defs)
		 `((define-function main int () ,@(irl-body (list-reverse! main)) (return 0))))))

(while *arguments*
  (let* ((file   (next-argument))
	 (parser (text-parser-for-on <irl> (contents-of-file-named file))))
    (or ($program parser) (error "syntax error"))
    (list-do form (irl-program (<irl>-result parser)) (dumpln form))))
