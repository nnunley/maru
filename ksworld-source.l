;;; ksworld-source.l -- KSWorld's own methods, from its sources (ksworld/CLASS.st, Squeak's file-out, read by st-fileout.g).
;;;
;;;   (ks-source-methods path)      each method of the file-out: its class, category, selector and source, whether it's
;;;                                 KScript ("selector = (params) ->") and, if kscript.g reads it, its tree, (fn PARAMS BODY...)
;;;   (ks-load-source-class class)  each KScript method of ksworld/CLASS.st becomes a method of CLASS, answering the sends a
;;;                                 document makes of its instances: documents keep the streams a class's methods made, but
;;;                                 not the methods
;;;
;;; Most of KSWorld is KScript kept in Smalltalk method chunks (ksworld/README.md), so nothing is transliterated: kscript.g
;;; reads the bodies as they were written.  A Smalltalk method (the KScript compiler's, mostly, which kscript.l replaces)
;;; has no tree.
(require "kscript.l")
(require "recover.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(tpeg-load "st-fileout.g")

(define-structure <ks-source-method> (class category selector source kscript? tree))

(define-function ks-blank? (c) (member? c '(32 9 10 13)))
(define-function ks-source-head (src)	; (selector . kscript?): KScript is "selector = (", Smalltalk a message pattern
  (let ((i 0) (n (string-length src)) (start 0))
    (while (and (< i n) (ks-blank? (string-at src i))) (set i (+ i 1)))
    (set start i)
    (while (and (< i n) (not (ks-blank? (string-at src i))) (not (= ?= (string-at src i))) (not (= ?: (string-at src i)))) (set i (+ i 1)))
    (let ((sel (string->symbol (string-copy src start (- i start)))))
      (while (and (< i n) (ks-blank? (string-at src i))) (set i (+ i 1)))
      (cons sel (and (< (+ i 1) n) (= ?= (string-at src i))
		     (let ((j (+ i 1))) (while (and (< j n) (ks-blank? (string-at src j))) (set j (+ j 1))) (and (< j n) (= ?\( (string-at src j)))))))))
(define-function ks-source-tree (src)	; (fn PARAMS BODY...) as kscript.g reads "selector = (PARAMS) -> BODY", or ()
  (let ((forms (try (kscript-parse src) (lambda (c) ()))))
    (and (pair? forms) (not (cdr forms)) (= 'assign (caar forms)) (pair? (caddr (car forms))) (= 'fn (car (caddr (car forms))))
	 (caddr (car forms)))))
(define-function ks-source-methods (path)
  (let ((out ()))
    (list-do x (parse-string <stfileout> $file (contents-of-file-named path))
      (and x (list-do raw (cdddr x)
	       (let* ((src raw) (head (ks-source-head src)))
		 (push out (new <ks-source-method> (cadr x) (caddr x) (car head) src (cdr head) (and (cdr head) (ks-source-tree src))))))))
    (list-reverse! out)))
(define-function ks-load-source-class (class)
  (list-do m (ks-source-methods (concat-strings "ksworld/" (symbol->string class) ".st"))
    (let ((tree (<ks-source-method>-tree m)))
      (and tree (ks-method class (<ks-source-method>-selector m)
			   (lambda (recv args env this) (ks-apply (ks-eval tree () recv) args env recv)))))))
